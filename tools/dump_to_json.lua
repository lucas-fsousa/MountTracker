-- tools/dump_to_json.lua
-- Converte o SavedVariables MountTracker.lua (MountTrackerDump) em JSONL (uma
-- montaria por linha), para a tool de curadoria em Python consumir sem depender
-- de um parser de Lua.
--
-- Uso: lua dump_to_json.lua <caminho/para/MountTracker.lua>

local path = assert(arg[1], "usage: lua dump_to_json.lua <SavedVariables/MountTracker.lua>")
assert(loadfile(path))()   -- defines the MountTrackerDump (and MountTrackerDB) globals
assert(MountTrackerDump and MountTrackerDump.mounts, "MountTrackerDump not found in file")

local function esc(s)
    return (tostring(s)
        :gsub("\\", "\\\\"):gsub('"', '\\"')
        :gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t"))
end

local function jval(v)
    local t = type(v)
    if v == nil then return "null"
    elseif t == "boolean" then return tostring(v)
    elseif t == "number" then return tostring(v)
    else return '"' .. esc(v) .. '"' end
end

local FIELDS = { "mountID", "spellID", "name", "sourceType", "faction",
                 "shouldHideOnChar", "isUsable", "collected", "sourceText" }

for _, m in ipairs(MountTrackerDump.mounts) do
    local parts = {}
    for _, k in ipairs(FIELDS) do
        parts[#parts + 1] = '"' .. k .. '":' .. jval(m[k])
    end
    io.write("{", table.concat(parts, ","), "}\n")
end
