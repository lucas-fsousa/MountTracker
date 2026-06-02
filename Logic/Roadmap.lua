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
    if item.entry and item.entry.zone then z[#z + 1] = item.entry.zone end
    for _, src in ipairs(item.sources or {}) do
        if src.zone then z[#z + 1] = src.zone end
    end
    return z
end

-- Casa a zona da montaria com a do personagem (contains nos dois sentidos,
-- p/ tolerar "Nagrand, Outland" vs "Nagrand").
local function zoneMatches(item, playerZone)
    if not playerZone or playerZone == "" then return false end
    for _, z in ipairs(itemZones(item)) do
        local lz = z:lower()
        if lz:find(playerZone, 1, true) or playerZone:find(lz, 1, true) then
            return true
        end
    end
    return false
end

-- Aplica os filtros de settings (expansao / zona / faccao errada / ocultas).
function Roadmap.Filtered()
    local items = ns._roadmap or Roadmap.Build()
    local s = ns.DB.Settings()
    local out = {}
    local expFilter = s.expansionFilter
    local zoneCurrent = (s.zoneFilter == "Current")
    local playerZone = zoneCurrent and ((GetRealZoneText() or GetZoneText() or ""):lower()) or nil
    for _, item in ipairs(items) do
        local show = true
        if expFilter and expFilter ~= "All" and item.expansion ~= expFilter then show = false end
        if zoneCurrent and not zoneMatches(item, playerZone) then show = false end
        if item.owned and not s.showOwned then show = false end
        if item.status == ns.STATUS.WRONG_FACTION and not s.showWrongFaction then show = false end
        if item.status == ns.STATUS.UNAVAILABLE and not s.showWrongFaction then show = false end
        if item.status == ns.STATUS.HIDDEN and not s.showHidden then show = false end
        if show then out[#out + 1] = item end
    end
    return out
end
