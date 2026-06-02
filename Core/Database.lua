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
