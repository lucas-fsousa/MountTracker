-- tools/dump_curated.lua [excludeBasename]
-- Carrega o overlay curado (todos os Data/*.lua) e imprime os spellIDs ja curados,
-- um por linha. Opcionalmente exclui um arquivo (p/ regeneracao idempotente de um
-- arquivo gerado -- ele nao conta a si mesmo). Reusa a logica real do addon.

local exclude = arg[1]
local ns = {}
local function load_into(f) assert(loadfile(f))("MountTracker", ns) end
load_into("Core/Init.lua")
load_into("Logic/SourceParse.lua")
load_into("Logic/Expansion.lua")
local p = assert(io.popen("ls Data/*.lua"))
for f in p:lines() do
    if not (exclude and f:find(exclude, 1, true)) then load_into(f) end
end
p:close()
for _, e in ipairs(ns.Data.All or {}) do
    if e.spellID then print(e.spellID) end
end
