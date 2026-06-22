-- tools/edits_to_json.lua
-- Converte o SavedVariables MountTracker.lua (global MountTrackerEdits) em JSONL,
-- uma edicao por linha: { "spellID": N, "name": "...", "data": {...} }.
-- O `name` e resolvido pelo MountTrackerDump (mesmo arquivo), quando presente.
-- Mesmo padrao de tools/dump_to_json.lua (sem parser de Lua em Python).
--
-- Uso: lua edits_to_json.lua <caminho/para/MountTracker.lua>

local path = assert(arg[1], "usage: lua edits_to_json.lua <SavedVariables/MountTracker.lua>")
assert(loadfile(path))()   -- define MountTrackerEdits (e MountTrackerDump/DB) globais
local E = MountTrackerEdits or {}

-- Indice de nomes por spellID, a partir do dump (se existir no mesmo arquivo).
local names = {}
if MountTrackerDump and MountTrackerDump.mounts then
    for _, m in ipairs(MountTrackerDump.mounts) do
        if m.spellID then names[m.spellID] = m.name end
    end
end

local function esc(s)
    return (tostring(s)
        :gsub("\\", "\\\\"):gsub('"', '\\"')
        :gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t"))
end

local function jsonify(v)
    local t = type(v)
    if t == "nil" then return "null"
    elseif t == "boolean" then return tostring(v)
    elseif t == "number" then return tostring(v)
    elseif t == "string" then return '"' .. esc(v) .. '"'
    elseif t == "table" then
        local parts = {}
        for k, val in pairs(v) do
            parts[#parts + 1] = '"' .. esc(tostring(k)) .. '":' .. jsonify(val)
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end
    return "null"
end

for sp, data in pairs(E) do
    local rec = { spellID = tonumber(sp) or sp, name = names[tonumber(sp) or sp], data = data }
    io.write(jsonify(rec), "\n")
end
