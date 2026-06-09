-- Logic/Roadmap.lua
-- Junta Scanner + Eligibility e ordena por dificuldade (mais facil primeiro).

local ADDON, ns = ...

local Roadmap = {}
ns.Logic.Roadmap = Roadmap

-- Peso base por status (menor = mais facil/prioritario).
local STATUS_WEIGHT = {
    READY            = 0,
    NEED_CURRENCY    = 1,
    NEED_REQUIREMENT = 2,
    UNKNOWN          = 3,
    FARM             = 4,
    OWNED            = 6,
    WRONG_FACTION    = 8,
    UNAVAILABLE      = 8.5,
    HIDDEN           = 9,
}

-- Score de dificuldade (menor = mais facil = topo).
local function difficulty(item)
    -- Obtenivel AGORA (glow) -> topo absoluto: e so ir buscar.
    if item.readyNow then return -1 end

    local base = STATUS_WEIGHT[item.status] or 5
    if item.status == ns.STATUS.NEED_CURRENCY then
        return base + (1 - (item.costPct or 0)) -- mais currency acumulada = menor score
    elseif item.status == ns.STATUS.FARM then
        local chance = item.dropChance
        -- Drop ~100% (raro elite): o gargalo e o raro estar UP, nao a sorte do drop.
        -- Relevancia MEDIA (nem topo, nem fundo).
        if chance and chance >= 0.9 then return 3.5 end
        -- Demais drops: pela raridade. Bons (1/25) altos; ruins (1/200) ao fundo.
        local n = chance and math.floor(1 / chance + 0.5) or 150
        return 2.0 + math.min(n, 250) / 80   -- 1/25->2.31, 1/100->3.25, 1/200->4.5
    elseif item.status == ns.STATUS.MISSING then
        -- Nao-curada: dificuldade pela categoria derivada do texto de origem.
        return item._catDiff or 4.0
    end
    return base
end

-- Counts curated entries across all source lists (for diagnostics).
local function curatedTotal()
    return #(ns.Data.All or {})
end

-- Recalcula o roadmap inteiro. Retorna lista ordenada de itens (exclui coletadas).
function Roadmap.Build()
    local candidates = ns.Logic.Scanner.Collect()
    local items = {}
    local owned = 0

    local curatedApplied, unavailable = 0, 0
    for _, cand in ipairs(candidates) do
        local item = ns.Logic.Eligibility.Evaluate(cand)
        item.readyNow = ns.Logic.Eligibility.IsReadyNow(item)
        item._diff = difficulty(item)
        items[#items + 1] = item       -- inclui owned tambem; o filtro decide o que exibir
        if item.owned then owned = owned + 1 end
        if item.status == ns.STATUS.UNAVAILABLE then unavailable = unavailable + 1 end
        if cand.entry then curatedApplied = curatedApplied + 1 end
    end

    table.sort(items, function(a, b)
        if a._diff ~= b._diff then return a._diff < b._diff end
        return (a.name or "") < (b.name or "")
    end)

    -- Estatisticas de diagnostico (consumidas por /mtrack scan e pela janela).
    ns._stats = {
        total       = #candidates,          -- todas as montarias do journal (com nome)
        curated     = curatedTotal(),       -- entradas no overlay curado
        applied     = curatedApplied,       -- overlays que casaram com o journal
        unresolved  = ns._unresolved and #ns._unresolved or 0,
        owned       = owned,
        unavailable = unavailable,          -- escondidas pelo jogo (faccao/legacy/locked)
        pending     = #items - owned - unavailable,  -- obteniveis por este personagem
    }

    ns._roadmap = items
    return items
end

-- Zonas associadas a uma montaria (curada + parseadas do sourceText).
local function itemZones(item)
    local z = {}
    if item.entry then
        -- `source` (ex.: "Eversong Woods Rare Creatures") costuma carregar a zona de
        -- drops curados que nao tem o campo `zone` -- inclui no match de zona.
        if item.entry.zone then z[#z + 1] = item.entry.zone end
        if item.entry.source then z[#z + 1] = item.entry.source end
    end
    for _, src in ipairs(item.sources or {}) do
        if src.zone then z[#z + 1] = src.zone end
    end
    return z
end

-- Tipo de mapa "Dungeon" (raids tambem usam este tipo). Fallback ao literal 4
-- se o Enum nao existir no cliente.
local DUNGEON_MAPTYPE = (Enum and Enum.UIMapType and Enum.UIMapType.Dungeon) or 4

-- Nomes da localizacao do personagem (lowercase): subzona, zona, toda a hierarquia
-- de mapas (sub-area -> zona -> ...) parando antes do continente/mundo, E TAMBEM as
-- dungeons/raids que pertencem a essas zonas (uma dungeon faz parte da zona, entao
-- seus drops de montaria devem aparecer no filtro "Current zone").
-- Resolve dois casos:
--   * "estou em Tazavesh (subzona) mas a montaria e de K'aresh (mapa)" -> sobe a arvore.
--   * "estou em Tanaris (zona aberta) e a montaria dropa em Zul'Farrak (dungeon)"
--     -> desce a arvore, incluindo as instancias filhas da zona.
-- Contexto da localizacao atual do jogador:
--   set   = conjunto de uiMapIDs (mapa atual + ancestrais ate antes do continente +
--           dungeons/raids filhas). uiMapID e UNICO por zona -> SEM colisao de nome
--           (Nagrand TBC=107 != Nagrand WoD=550). Esse e o casamento primario.
--   names = nomes (lowercase) -> FALLBACK p/ montarias sem uiMapID nos dados.
--   exp   = expansao atual (continente) -> desambigua o fallback por nome.
local function playerLocationCtx()
    local set, names, seen = {}, {}, {}
    local function addName(t)
        if t and t ~= "" then
            local l = t:lower()
            if not seen[l] then seen[l] = true; names[#names + 1] = l end
        end
    end
    local function addChildren(mid)
        if not (mid and C_Map and C_Map.GetMapChildrenInfo) then return end
        local kids = C_Map.GetMapChildrenInfo(mid, DUNGEON_MAPTYPE, true)
        if kids then
            for _, k in ipairs(kids) do
                if k.mapID then set[k.mapID] = true end
                addName(k.name)
            end
        end
    end
    addName(GetSubZoneText and GetSubZoneText())
    addName(GetZoneText and GetZoneText())
    addName(GetRealZoneText and GetRealZoneText())
    if C_Garrison and C_Garrison.IsOnGarrisonMap and ns.Safe.Value(C_Garrison.IsOnGarrisonMap(), false) then
        addName("garrison")
    end

    local continent
    if C_Map and C_Map.GetBestMapForUnit then
        local mid = C_Map.GetBestMapForUnit("player")
        local guard = 0
        while mid and guard < 12 do
            guard = guard + 1
            local info = C_Map.GetMapInfo(mid)
            if not info then break end
            if info.mapType and info.mapType <= 2 then continent = info.name; break end
            set[mid] = true
            addName(info.name)
            addChildren(mid)
            mid = info.parentMapID
        end
    end

    local expText = table.concat(names, " ") .. " " .. (continent or "")
    local exp = (ns.ExpansionFor and ns.ExpansionFor(expText, nil, nil)) or "Unknown"
    return { set = set, names = names, exp = exp }
end

-- uiMapID ESTRITO da zona de obtencao (campo `map`, colhido com match de zona
-- verificado). NAO usa `coords.map` aqui: aquele e nao-estrito (serve so p/ o waypoint)
-- e poderia apontar pra zona errada -> o filtro de zona nunca pode errar.
local function itemMapId(item)
    return (item.entry and item.entry.map) or nil
end

-- Casa a montaria com a localizacao atual.
--   1) PREFERE uiMapID: match exato por ID -> imune a colisao de nome/expansao.
--   2) Fallback por NOME (+ expansao compativel) so quando a montaria nao tem uiMapID
--      nos dados (nao-curada, ou curada ainda sem `map`/coords).
local function zoneMatches(item, ctx)
    if not ctx then return false end
    local imap = itemMapId(item)
    if imap then
        return ctx.set[imap] == true
    end
    local ie = item.expansion
    local expCompatible = (not ie or ie == "Unknown" or not ctx.exp or ctx.exp == "Unknown")
        or (ie == ctx.exp)
    local zones = itemZones(item)
    local st = item.sourceText and item.sourceText:gsub("|T.-|t", ""):lower()
    for _, pz in ipairs(ctx.names) do
        for _, z in ipairs(zones) do
            local lz = z:lower()
            if lz:find(pz, 1, true) or pz:find(lz, 1, true) then return expCompatible end
        end
        if st and st:find(pz, 1, true) then return expCompatible end
    end
    return false
end

-- Categorias distintas presentes no roadmap (p/ popular o dropdown de categoria),
-- ordenadas alfabeticamente. Inclui owned/unavailable (o filtro e independente).
function Roadmap.Categories()
    local seen, list = {}, {}
    for _, item in ipairs(ns._roadmap or Roadmap.Build()) do
        local c = item.category
        if c and not seen[c] then seen[c] = true; list[#list + 1] = c end
    end
    table.sort(list)
    return list
end

-- Aplica os filtros de settings (expansao / categoria / zona / faccao errada / ocultas).
function Roadmap.Filtered()
    local items = ns._roadmap or Roadmap.Build()
    local s = ns.DB.Settings()
    local out = {}
    local expFilter = s.expansionFilter
    local catFilter = s.categoryFilter
    local zoneCurrent = (s.zoneFilter == "Current")
    local ctx = zoneCurrent and playerLocationCtx() or nil
    for _, item in ipairs(items) do
        local show = true
        if expFilter and expFilter ~= "All" and item.expansion ~= expFilter then show = false end
        if catFilter and catFilter ~= "All" and item.category ~= catFilter then show = false end
        if zoneCurrent and not zoneMatches(item, ctx) then show = false end
        if item.owned and not s.showOwned then show = false end
        if item.status == ns.STATUS.WRONG_FACTION and not s.showWrongFaction then show = false end
        if item.status == ns.STATUS.UNAVAILABLE and not s.showWrongFaction then show = false end
        if item.status == ns.STATUS.HIDDEN and not s.showHidden then show = false end
        if show then out[#out + 1] = item end
    end
    return out
end

-- Diagnostico do filtro de zona (/mtrack zone): nomes de localizacao detectados +
-- montarias (nao-obtidas) que casam, com exemplos.
function Roadmap.ZoneDebug()
    local ctx = playerLocationCtx()
    local items = ns._roadmap or Roadmap.Build()
    local matched, examples = 0, {}
    for _, item in ipairs(items) do
        if not item.owned and zoneMatches(item, ctx) then
            matched = matched + 1
            if #examples < 5 then examples[#examples + 1] = item.name end
        end
    end
    local nmaps = 0
    for _ in pairs(ctx.set) do nmaps = nmaps + 1 end
    return ctx.names, matched, examples, ctx.exp, nmaps
end
