-- Core/Init.lua
-- Cria o namespace compartilhado do addon e define os defaults do banco de dados.

local ADDON, ns = ...

-- Tudo do addon vive dentro de `ns` (compartilhado entre os arquivos via `...`).
ns.NAME = ADDON
ns.VERSION = "0.5.0"  -- fallback; Core/Version.lua le do .toc (fonte unica)

-- Sub-tabelas que os outros arquivos vao preencher.
ns.Data = ns.Data or {}        -- tabela curada de montarias
ns.Logic = ns.Logic or {}      -- Scanner / Eligibility / Roadmap
ns.UI = ns.UI or {}            -- frames

-- Lista mestra agregada de TODAS as entradas curadas (todas as expansoes).
ns.Data.All = ns.Data.All or {}

-- Overlay de metadados por spellID (map/zona + expansao) p/ os filtros -- inclusive de
-- montarias NAO-curadas. Preenchido por Data/Mounts_Meta.lua. Nao afeta status/glow.
ns.Meta = ns.Meta or {}

-- Cada arquivo Data/Mounts_<Exp>.lua chama isto para registrar suas montarias.
-- `expansion` rotula a sprint (ex.: "Classic", "TBC"); cada entrada recebe esse campo.
-- `expansion` pode ser nil: nesse caso a expansao e derivada do sourceText pelo
-- heuristico (Logic/Expansion.lua), igual a base ao vivo. Uma `entry.expansion`
-- ja definida tem prioridade.
function ns.Data.Register(expansion, list)
    if not list then return end
    for _, entry in ipairs(list) do
        if expansion then entry.expansion = entry.expansion or expansion end
        ns.Data.All[#ns.Data.All + 1] = entry
    end
end

-- Enum de status (centraliza as strings p/ evitar typo).
ns.STATUS = {
    READY            = "READY",            -- pode pegar agora
    NEED_CURRENCY    = "NEED_CURRENCY",    -- requisito ok, falta currency/ouro
    NEED_REQUIREMENT = "NEED_REQUIREMENT", -- falta reputacao/conquista
    WRONG_FACTION    = "WRONG_FACTION",    -- faccao oposta, inelegivel
    HIDDEN           = "HIDDEN",           -- ocultada pelo usuario
    MARKED_OBTAINED  = "MARKED_OBTAINED",  -- marcada como obtida (track indevido)
    UNKNOWN          = "UNKNOWN",          -- dado protegido pelo jogo (Secret Value)
    OWNED            = "OWNED",            -- ja coletada (so visivel com "Show owned")
    FARM             = "FARM",             -- drop/RNG: nao e "comprar", e farmar
    MISSING          = "MISSING",          -- nao-curada: usa o texto de origem do jogo
    UNAVAILABLE      = "UNAVAILABLE",      -- o jogo esconde p/ este char (faccao/legacy/locked)
}

-- Cores por status (r, g, b) p/ badges na UI.
ns.STATUS_COLOR = {
    READY            = { 0.20, 0.80, 0.20 },
    NEED_CURRENCY    = { 0.95, 0.80, 0.20 },
    NEED_REQUIREMENT = { 0.95, 0.55, 0.20 },
    WRONG_FACTION    = { 0.85, 0.25, 0.25 },
    HIDDEN           = { 0.55, 0.55, 0.55 },
    MARKED_OBTAINED  = { 0.55, 0.55, 0.55 },
    UNKNOWN          = { 0.60, 0.60, 0.75 },
    OWNED            = { 0.30, 0.85, 0.45 },
    FARM             = { 0.45, 0.70, 0.95 },
    MISSING          = { 0.80, 0.80, 0.85 },
    UNAVAILABLE      = { 0.70, 0.35, 0.35 },
}

ns.STATUS_LABEL = {
    READY            = "Ready",
    NEED_CURRENCY    = "Need currency",
    NEED_REQUIREMENT = "Need requirement",
    WRONG_FACTION    = "Wrong faction",
    HIDDEN           = "Hidden",
    MARKED_OBTAINED  = "Marked obtained",
    UNKNOWN          = "Protected data",
    OWNED            = "Owned",
    FARM             = "Farmable (RNG)",
    MISSING          = "Missing",
    UNAVAILABLE      = "Unavailable",
}

-- Helper de print com prefixo.
function ns.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffMountTracker|r: " .. tostring(msg))
end
