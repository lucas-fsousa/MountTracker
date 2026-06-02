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
assert(#dataFiles > 0, "nenhum Data\\Mounts_*.lua no .toc")

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

    if type(e.spellID) ~= "number" then err(nm, "spellID ausente/invalido") end
    if type(e.name) ~= "string" or e.name == "" then err(nm, "name ausente") end
    if type(e.acquisition) ~= "string" then err(nm, "acquisition ausente") end

    if e.spellID then
        if seenSpell[e.spellID] then err(nm, "spellID duplicado: " .. e.spellID)
        else seenSpell[e.spellID] = nm end
    end

    local r = e.requirement
    if r then
        if r.type == "renown" then
            if not (type(r.factionID) == "number" or type(r.factionName) == "string") then
                err(nm, "renown sem factionID nem factionName")
            end
            if type(r.renownLevel) ~= "number" then err(nm, "renown sem renownLevel") end
        elseif r.type == "reputation" then
            if type(r.factionID) ~= "number" then err(nm, "reputation sem factionID") end
            if not STANDINGS[r.standing] then err(nm, "standing invalido: " .. tostring(r.standing)) end
        elseif r.type == "achievement" then
            if type(r.achievementID) ~= "number" then err(nm, "achievement sem achievementID") end
        else
            err(nm, "requirement.type desconhecido: " .. tostring(r.type))
        end
    end

    local c = e.cost
    if c then
        local forms = (c.gold and 1 or 0) + (c.currencyID and 1 or 0) + (c.itemID and 1 or 0)
        if forms ~= 1 then err(nm, "cost deve ter exatamente um de gold/currencyID/itemID") end
        if (c.currencyID or c.itemID) and type(c.amount) ~= "number" then
            err(nm, "cost com currencyID/itemID sem amount")
        end
    end

    if e.dropChance ~= nil then
        if type(e.dropChance) ~= "number" or e.dropChance <= 0 or e.dropChance > 1 then
            err(nm, "dropChance fora de (0,1]: " .. tostring(e.dropChance))
        end
    end
end

print(("validate: %d arquivos de dados, %d montarias curadas"):format(#dataFiles, n))
if #errors == 0 then
    print("OK: integridade do overlay curado validada")
    os.exit(0)
else
    print(("FALHAS (%d):"):format(#errors))
    for _, m in ipairs(errors) do print("  " .. m) end
    os.exit(1)
end
