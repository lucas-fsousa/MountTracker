-- tools/dump_journal.lua <dump>
-- Emite JSONL com TODAS as montarias do Mount Journal -- coletadas, ocultas e faltando.
-- A curadoria precisa estar correta p/ o jogo inteiro: uma montaria que ESTE personagem
-- ja tem (ou nao pode ter) ainda falta p/ outro player, entao os metadados (expansao/map)
-- tem que cobrir todas. Por isso este dump NAO filtra por collected/hidden, ao contrario
-- do dump_all.lua (que so lista o "obtenivel agora" deste personagem).
-- Reusa a logica real do addon. Saida consumida por tools/enrich_meta.py.

local dumpPath = assert(arg[1], "usage: lua tools/dump_journal.lua <dump>")
local ns = {}
local function load_into(f) assert(loadfile(f))("MountTracker", ns) end
load_into("Core/Init.lua")
load_into("Logic/SourceParse.lua")
load_into("Logic/Expansion.lua")
do
    local p = assert(io.popen("ls Data/*.lua"))
    for f in p:lines() do load_into(f) end
    p:close()
end

local curated = {}
for _, e in ipairs(ns.Data.All or {}) do
    if e.spellID then curated[e.spellID] = e end
end

assert(loadfile(dumpPath))()
assert(MountTrackerDump and MountTrackerDump.mounts, "MountTrackerDump nao encontrado")

local function esc(s)
    return (tostring(s):gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("[%z\1-\31]", " "))
end

for _, m in ipairs(MountTrackerDump.mounts) do
    if m.name and m.name ~= "" then
        local e = curated[m.spellID]
        local sources = ns.SourceParse(m.sourceText)
        local expText = (m.sourceText or "") .. " " .. ((e and e.source) or "") .. " " .. ((e and e.zone) or "")
        local exp = ns.ExpansionFor(expText, e and e.expansion, m.spellID)
        local vendor, source, zone
        for _, s in ipairs(sources) do
            if s.kind == "Vendor" and not vendor then vendor = s.who end
            if (s.kind == "Drop" or s.kind == "Treasure" or s.kind == "Object") and not source then source = s.who end
            if s.zone and not zone then zone = s.zone end
        end
        vendor = vendor or (e and e.vendor)
        source = source or (e and e.source)
        zone = zone or (e and e.zone)
        io.write(string.format(
            '{"spellID":%d,"name":"%s","collected":%s,"hidden":%s,"curated":%s,' ..
            '"expansion":"%s","map":%s,"vendor":%s,"source":%s,"zone":%s}\n',
            m.spellID or 0, esc(m.name), tostring(m.collected == true),
            tostring(m.shouldHideOnChar == true), tostring(e ~= nil), esc(exp),
            (e and e.map) and tostring(e.map) or "null",
            vendor and ('"' .. esc(vendor) .. '"') or "null",
            source and ('"' .. esc(source) .. '"') or "null",
            zone and ('"' .. esc(zone) .. '"') or "null"))
    end
end
