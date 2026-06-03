-- tools/audit.lua <dump>
-- Varredura de completude: reusa a logica REAL do addon (SourceParse + Expansion +
-- overlay curado) sobre o /mtrack dump e emite, em JSONL, cada montaria obtivel cujo
-- dado esta incompleto, com o que falta. Sem reimplementar regra em outra linguagem.
--
-- Uso: lua tools/audit.lua <SavedVariables/MountTracker.lua>   (rodar da raiz do repo)

local dumpPath = assert(arg[1], "usage: lua tools/audit.lua <dump>")

-- Namespace minimo + carga dos modulos PUROS do addon (sem APIs do WoW).
local ns = {}
local function load_into(f)
    local chunk = assert(loadfile(f))
    chunk("MountTracker", ns)
end
load_into("Core/Init.lua")          -- ns.Data.Register, STATUS
load_into("Logic/SourceParse.lua")  -- ns.SourceParse
load_into("Logic/Expansion.lua")    -- ns.ExpansionFor
-- Overlay curado: todos os Data/*.lua (Schema + Mounts_*).
do
    local p = assert(io.popen("ls Data/*.lua"))
    for f in p:lines() do load_into(f) end
    p:close()
end

-- Indice do overlay por spellID.
local curated = {}
for _, e in ipairs(ns.Data.All or {}) do
    if e.spellID then curated[e.spellID] = e end
end

-- Carrega o dump (define MountTrackerDump).
assert(loadfile(dumpPath))()
assert(MountTrackerDump and MountTrackerDump.mounts, "MountTrackerDump nao encontrado")

local function esc(s)
    return (tostring(s):gsub("\\", "\\\\"):gsub('"', '\\"')
        :gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t")
        :gsub("[%z\1-\31]", ""))   -- remove demais caracteres de controle
end
local function clean(s)
    s = (s or ""):gsub("|T.-|t", ""):gsub("|H.-|h(.-)|h", "%1")
        :gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|n", " ")
        :gsub("[%z\1-\31]", " ")          -- remove caracteres de controle
        :gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return s
end

for _, m in ipairs(MountTrackerDump.mounts) do
    if m.name and m.name ~= "" and not m.collected and not m.shouldHideOnChar then
        local st = m.sourceText or ""
        local entry = curated[m.spellID]
        local sources = ns.SourceParse(st)

        local expText = st .. " " .. ((entry and entry.source) or "") .. " " .. ((entry and entry.zone) or "")
        local expansion = ns.ExpansionFor(expText, entry and entry.expansion, m.spellID)

        local kinds, hasZone, hasCost, isVendor, vendorWho = {}, false, false, false, nil
        for _, s in ipairs(sources) do
            if s.kind then kinds[s.kind] = true end
            if s.kind == "Vendor" then isVendor = true; vendorWho = vendorWho or s.who end
            if s.zone then hasZone = true end
            if s.costs and #s.costs > 0 then hasCost = true end
        end
        if entry and entry.zone then hasZone = true end
        if entry and entry.cost then hasCost = true end

        -- Gate de requisito no texto do jogo (impede glow se nao-curado/nao-verificavel).
        local low = st:lower()
        local gate
        if low:find("achievement:", 1, true) then gate = "achievement"
        elseif low:find("renown:", 1, true) or (low:find("faction:", 1, true) and low:find("renown", 1, true)) then gate = "renown"
        elseif low:find("faction:", 1, true) then gate = "reputation" end

        local req = entry and entry.requirement
        local gateCovered = false
        if gate == "achievement" then
            gateCovered = req and req.type == "achievement" and req.achievementID ~= nil
        elseif gate == "renown" then
            gateCovered = req and req.type == "renown" and (req.factionID ~= nil or req.factionName ~= nil)
        elseif gate == "reputation" then
            gateCovered = req and req.type == "reputation" and req.factionID ~= nil
        end

        -- Recompensa automatica de conquista: criterio e a conquista, zona/custo N/A.
        local achReward = (gate == "achievement") and not isVendor
        local acqAch = entry and entry.acquisition == "achievement"

        local miss = {}
        if expansion == "Unknown" then miss[#miss + 1] = "expansion" end
        if not hasZone and not achReward and not acqAch then miss[#miss + 1] = "zone" end
        if isVendor and not hasCost then miss[#miss + 1] = "cost" end
        if gate and not gateCovered then miss[#miss + 1] = "gate:" .. gate end

        if #miss > 0 then
            local kindList = {}
            for k in pairs(kinds) do kindList[#kindList + 1] = k end
            table.sort(kindList)
            io.write(string.format(
                '{"spellID":%d,"name":"%s","expansion":"%s","curated":%s,"kinds":"%s",' ..
                '"gate":%s,"isVendor":%s,"hasZone":%s,"hasCost":%s,"missing":"%s","source":"%s"}\n',
                m.spellID or 0, esc(m.name), esc(expansion), tostring(entry ~= nil),
                esc(table.concat(kindList, "+")),
                gate and ('"' .. gate .. '"') or "null",
                tostring(isVendor), tostring(hasZone), tostring(hasCost),
                esc(table.concat(miss, ",")), esc(clean(st))))
        end
    end
end
