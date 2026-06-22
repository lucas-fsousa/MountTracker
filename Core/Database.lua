-- Core/Database.lua
-- Inicializa o SavedVariables e expoe helpers para os overrides manuais do usuario.

local ADDON, ns = ...

local DEFAULTS = {
    markedObtained = {},   -- [mountID] = true  -> corrige track indevido
    hidden         = {},   -- [mountID] = true  -> ocultadas (ex.: faccao oposta)
    settings = {
        showWrongFaction = false,
        showHidden       = false,
        showOwned        = false,
        minimapAngle     = 205,    -- posicao do botao na borda (graus)
        minimapHide      = false,  -- esconder o botao do minimapa
        expansionFilter  = "All",  -- filtro por expansao ("All" ou nome da expansao)
        zoneFilter       = "All",  -- filtro por zona ("All" ou "Current")
        categoryFilter   = "All",  -- filtro por categoria ("All" ou Vendor/Drop/...)
        textFilter       = "",     -- busca textual livre (nome / vendedor / zona / fonte)
        editMode         = false,  -- modo de edicao de curadoria (/mtrack enable edit)
    },
}

-- Copia rasa de defaults p/ chaves ausentes (sem sobrescrever o que ja existe).
local function applyDefaults(db, defaults)
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            db[k] = db[k] or {}
            applyDefaults(db[k], v)
        elseif db[k] == nil then
            db[k] = v
        end
    end
end

ns.DB = {}

-- Chamado no PLAYER_LOGIN (apos o SavedVariables estar carregado).
function ns.DB.Init()
    MountTrackerDB = MountTrackerDB or {}
    applyDefaults(MountTrackerDB, DEFAULTS)
    ns.DB.data = MountTrackerDB
    -- Overlay de edicao de curadoria (SavedVariable separado, indexado por spellID).
    -- Mantido fora do MountTrackerDB de proposito: e dado de curadoria exportavel.
    MountTrackerEdits = MountTrackerEdits or {}
    ns.DB.edits = MountTrackerEdits
end

function ns.DB.IsMarkedObtained(mountID)
    return ns.DB.data.markedObtained[mountID] == true
end

function ns.DB.SetMarkedObtained(mountID, value)
    ns.DB.data.markedObtained[mountID] = value and true or nil
end

function ns.DB.IsHidden(mountID)
    return ns.DB.data.hidden[mountID] == true
end

function ns.DB.SetHidden(mountID, value)
    ns.DB.data.hidden[mountID] = value and true or nil
end

function ns.DB.Settings()
    return ns.DB.data.settings
end

function ns.DB.EditModeOn()
    return ns.DB.data.settings.editMode == true
end

-- ---- Overlay de edicao de curadoria (MountTrackerEdits), por spellID ----------------

-- Retorna a edicao curada do usuario para um spellID (ou nil).
function ns.DB.GetEdit(spellID)
    return spellID and ns.DB.edits[spellID] or nil
end

-- Grava a edicao de um spellID. `data` ja vem no formato de storage (cost={type,id,
-- amount}, coords={x,y}, ...). Carimba _meta. Passar nil/tabela vazia remove a edicao.
function ns.DB.SetEdit(spellID, data)
    if not spellID then return end
    if not data or next(data) == nil then
        ns.DB.edits[spellID] = nil
        return
    end
    data._meta = {
        editedAt = time and time() or 0,
        char = (UnitName and (UnitName("player") .. "-" .. (GetRealmName and GetRealmName() or "?"))) or "?",
    }
    ns.DB.edits[spellID] = data
end

-- Descarta a edicao de um spellID (volta ao dado dos arquivos curados).
function ns.DB.RevertEdit(spellID)
    if spellID then ns.DB.edits[spellID] = nil end
end

-- Conta quantas edicoes existem (para o resumo do /mtrack export).
function ns.DB.CountEdits()
    local n = 0
    for _ in pairs(ns.DB.edits or {}) do n = n + 1 end
    return n
end
