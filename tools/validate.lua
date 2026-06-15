-- tools/validate.lua
-- Valida a integridade do overlay curado (Data/Mounts_*.lua). Roda fora do WoW:
-- stuba o minimo do namespace e carrega Core/Init.lua + os arquivos de dados.
--
-- Uso: lua tools/validate.lua [repo_root]   (default: ".")
-- Sai com codigo 1 se houver qualquer problema.

local root = (arg and arg[1]) or "."
root = root:gsub("[/\\]+$", "")

-- Namespace stub: Init.lua provê ns.Data.Register; basta um ns vazio.
local ns = {}
assert(loadfile(root .. "/Core/Init.lua"))("MountTracker", ns)

-- Descobre os arquivos de dados pela ordem do .toc.
local toc = assert(io.open(root .. "/MountTracker.toc", "r"))
local dataFiles = {}
for line in toc:lines() do
    local f = line:match("^%s*Data\\(Mounts_.-%.lua)%s*$")
    if f then dataFiles[#dataFiles + 1] = f end
end
toc:close()
assert(#dataFiles > 0, "no Data\\Mounts_*.lua found in .toc")

for _, f in ipairs(dataFiles) do
    assert(loadfile(root .. "/Data/" .. f))("MountTracker", ns)
end

-- ---- Checagens ----
local STANDINGS = { Exalted = true, Revered = true, Honored = true,
                    Friendly = true, Neutral = true, Unfriendly = true,
                    Hostile = true, Hated = true }
local errors = {}
local function err(name, msg) errors[#errors + 1] = ("[%s] %s"):format(name or "?", msg) end

local seenSpell = {}
local n = 0
for _, e in ipairs(ns.Data.All) do
    n = n + 1
    local nm = e.name or ("#" .. n)

    if type(e.spellID) ~= "number" then err(nm, "spellID missing/invalid") end
    if type(e.name) ~= "string" or e.name == "" then err(nm, "name missing") end
    if type(e.acquisition) ~= "string" then err(nm, "acquisition missing") end

    if e.spellID then
        if seenSpell[e.spellID] then err(nm, "duplicate spellID: " .. e.spellID)
        else seenSpell[e.spellID] = nm end
    end

    local r = e.requirement
    -- factionID pode ser number OU tabela faction-especifica { Horde=N, Alliance=M }.
    local function validFaction(fid)
        if type(fid) == "number" then return true end
        if type(fid) == "table" and (type(fid.Horde) == "number" or type(fid.Alliance) == "number") then
            return true
        end
        return false
    end
    if r then
        if r.type == "renown" then
            if not (validFaction(r.factionID) or type(r.factionName) == "string") then
                err(nm, "renown without factionID or factionName")
            end
            if type(r.renownLevel) ~= "number" then err(nm, "renown without renownLevel") end
        elseif r.type == "reputation" then
            if not validFaction(r.factionID) then err(nm, "reputation without factionID") end
            if not STANDINGS[r.standing] then err(nm, "invalid standing: " .. tostring(r.standing)) end
        elseif r.type == "achievement" then
            if type(r.achievementID) ~= "number" then err(nm, "achievement without achievementID") end
        elseif r.type == "currency" then
            if type(r.currencyID) ~= "number" then err(nm, "currency without currencyID") end
            if type(r.quantity) ~= "number" then err(nm, "currency without quantity") end
        else
            err(nm, "unknown requirement.type: " .. tostring(r.type))
        end
    end

    local c = e.cost
    if c then
        local forms = (c.gold and 1 or 0) + (c.currencyID and 1 or 0) + (c.itemID and 1 or 0)
        if forms ~= 1 then err(nm, "cost must have exactly one of gold/currencyID/itemID") end
        if (c.currencyID or c.itemID) and type(c.amount) ~= "number" then
            err(nm, "cost with currencyID/itemID but no amount")
        end
    end

    if e.dropChance ~= nil then
        if type(e.dropChance) ~= "number" or e.dropChance <= 0 or e.dropChance > 1 then
            err(nm, "dropChance out of (0,1]: " .. tostring(e.dropChance))
        end
    end
end

print(("validate: %d data files, %d curated mounts"):format(#dataFiles, n))
if #errors == 0 then
    print("OK: curated overlay integrity validated")
    os.exit(0)
else
    print(("FAILURES (%d):"):format(#errors))
    for _, m in ipairs(errors) do print("  " .. m) end
    os.exit(1)
end
