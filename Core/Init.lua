-- Core/Init.lua
-- Cria o namespace compartilhado do addon e define os defaults do banco de dados.

local ADDON, ns = ...

-- Tudo do addon vive dentro de `ns` (compartilhado entre os arquivos via `...`).
ns.NAME = ADDON
ns.VERSION = "0.1.0"

-- Sub-tabelas que os outros arquivos vao preencher.
ns.Data = ns.Data or {}        -- tabela curada de montarias
ns.Logic = ns.Logic or {}      -- Scanner / Eligibility / Roadmap
ns.UI = ns.UI or {}            -- frames

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
}

-- Helper de print com prefixo.
function ns.Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffMountTracker|r: " .. tostring(msg))
end
