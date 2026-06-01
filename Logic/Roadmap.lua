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
    HIDDEN           = 9,
}

-- Score de dificuldade: READY no topo; depois quem esta mais perto do custo.
local function difficulty(item)
    local base = STATUS_WEIGHT[item.status] or 5
    if item.status == ns.STATUS.NEED_CURRENCY then
        return base + (1 - (item.costPct or 0)) -- mais currency acumulada = menor score
    elseif item.status == ns.STATUS.FARM then
        -- Ordena drops pela raridade: odds boas (1/25) interleavam com os compraveis;
        -- odds ruins (1/200) caem para o fundo. Sem dado -> assume ~1/150.
        local n = item.dropChance and math.floor(1 / item.dropChance + 0.5) or 150
        return 1.5 + math.min(n, 250) / 100   -- 1/25->1.75, 1/50->2.0, 1/100->2.5, 1/200->3.5
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

    for _, cand in ipairs(candidates) do
        local item = ns.Logic.Eligibility.Evaluate(cand)
        item._diff = difficulty(item)
        items[#items + 1] = item       -- inclui owned tambem; o filtro decide o que exibir
        if item.owned then owned = owned + 1 end
    end

    table.sort(items, function(a, b)
        if a._diff ~= b._diff then return a._diff < b._diff end
        return (a.name or "") < (b.name or "")
    end)

    -- Estatisticas de diagnostico (consumidas por /mtrack scan e pela janela).
    ns._stats = {
        curated    = curatedTotal(),
        resolved   = #candidates,
        unresolved = ns._unresolved and #ns._unresolved or 0,
        owned      = owned,
        pending    = #items - owned,
    }

    ns._roadmap = items
    return items
end

-- Aplica os filtros de settings (faccao errada / ocultas) sobre o roadmap.
function Roadmap.Filtered()
    local items = ns._roadmap or Roadmap.Build()
    local s = ns.DB.Settings()
    local out = {}
    for _, item in ipairs(items) do
        local show = true
        if item.owned and not s.showOwned then show = false end
        if item.status == ns.STATUS.WRONG_FACTION and not s.showWrongFaction then show = false end
        if item.status == ns.STATUS.HIDDEN and not s.showHidden then show = false end
        if show then out[#out + 1] = item end
    end
    return out
end
