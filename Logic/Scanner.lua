-- Logic/Scanner.lua
-- Reads the Mount Journal and resolves each curated entry to a mountID + API info.

local ADDON, ns = ...

local Scanner = {}
ns.Logic.Scanner = Scanner

-- Normalizes a mount name for matching: lowercases and strips the item-style
-- "Reins of the " / "Reins of " prefix that the Mount Journal name does NOT use.
local function normalizeName(name)
    if not name then return nil end
    name = name:lower()
    name = name:gsub("^reins of the ", "")
    name = name:gsub("^reins of ", "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    return name
end

-- Builds a normalizedName -> mountID index from the Mount Journal.
local function buildNameIndex()
    local index = {}
    local ids = C_MountJournal.GetMountIDs()
    for _, mountID in ipairs(ids) do
        local name = C_MountJournal.GetMountInfoByID(mountID)
        if name then
            index[normalizeName(name)] = mountID
        end
    end
    return index
end

-- Resolves a curated entry's mountID. Priority:
--   1) explicit entry.mountID
--   2) entry.spellID via the game API (language-independent, source of truth)
--   3) entry.name via the normalized journal index (last resort)
local function resolveMountID(entry, nameIndex)
    if entry.mountID then return entry.mountID end
    if entry.spellID and C_MountJournal.GetMountFromSpell then
        local id = C_MountJournal.GetMountFromSpell(entry.spellID)
        if id then return id end
    end
    if entry.name then return nameIndex[normalizeName(entry.name)] end
    return nil
end

-- Returns candidates for EVERY mount in the journal (live base). Curated entries
-- (ns.Data.All), indexed by spellID, are attached as `entry` overrides when present.
-- Each candidate: { entry?, mountID, spellID, sourceType, sourceText, info = {...} }
function Scanner.Collect()
    -- Indexa o overlay curado por spellID.
    local curated = {}
    for _, e in ipairs(ns.Data.All or {}) do
        if e.spellID then curated[e.spellID] = e end
    end

    local out = {}
    local seen = {}   -- spellIDs curados que existem no journal deste cliente

    local ids = C_MountJournal.GetMountIDs()
    for _, mountID in ipairs(ids) do
        local name, spellID, icon, _, isUsable, sourceType, _, isFactionSpecific, faction, _, isCollected =
            C_MountJournal.GetMountInfoByID(mountID)
        if name and name ~= "" then
            local _, _, sourceText = C_MountJournal.GetMountInfoExtraByID(mountID)
            local entry = spellID and curated[spellID] or nil
            if entry then seen[spellID] = true end
            out[#out + 1] = {
                entry      = entry,
                mountID    = mountID,
                spellID    = spellID,
                sourceType = sourceType,
                sourceText = sourceText,
                info = {
                    name              = name,
                    icon              = icon,
                    isUsable          = isUsable,
                    isFactionSpecific = isFactionSpecific,
                    faction           = faction,       -- 0 Horde, 1 Alliance (or nil)
                    isCollected       = isCollected,
                },
            }
        end
    end

    -- Curated com spellID que nao existe neste cliente (provavel typo no dado).
    local unresolved = {}
    for _, e in ipairs(ns.Data.All or {}) do
        if e.spellID and not seen[e.spellID] then
            unresolved[#unresolved + 1] = e.name or ("spell " .. e.spellID)
        end
    end
    ns._unresolved = unresolved
    if #unresolved > 0 and ns.DEBUG then
        ns.Print(("debug: %d curated entr(ies) not in journal: %s")
            :format(#unresolved, table.concat(unresolved, ", ")))
    end

    return out
end

-- Exporta TODAS as montarias do jogo (fonte da verdade) para o SavedVariables
-- MountTrackerDump. Usado para gerar dados curados em massa, com spellIDs corretos
-- e o texto de origem do proprio jogo. Rode /mtrack dump, depois /reload.
function Scanner.Dump()
    local out = {}
    local ids = C_MountJournal.GetMountIDs()
    for _, mountID in ipairs(ids) do
        local name, spellID, _, _, isUsable, sourceType, _, isFactionSpecific, faction, shouldHideOnChar, isCollected =
            C_MountJournal.GetMountInfoByID(mountID)
        local _, _, sourceText = C_MountJournal.GetMountInfoExtraByID(mountID)
        out[#out + 1] = {
            mountID          = mountID,
            spellID          = spellID,
            name             = name,
            sourceType       = sourceType,             -- 0 Drop,1 Quest,2 Vendor,...
            isFactionSpecific = isFactionSpecific,
            faction          = faction,                -- 0 Horde,1 Alliance (cru)
            shouldHideOnChar = shouldHideOnChar,       -- jogo esconderia p/ este char
            isUsable         = isUsable,
            collected        = isCollected,
            sourceText       = sourceText,             -- texto cru do jogo
        }
    end
    MountTrackerDump = {
        built = (date and date("%Y-%m-%d %H:%M")) or "",
        count = #out,
        mounts = out,
    }
    ns.Print(("dumped %d mounts to SavedVariables. Now type |cffffff00/reload|r, then share the file.")
        :format(#out))
end

-- Debug helper: prints the mountID of mounts whose name contains `query`.
function Scanner.Find(query)
    query = (query or ""):lower()
    if query == "" then ns.Print("usage: /mtrack find <part of name>") return end
    local ids = C_MountJournal.GetMountIDs()
    local found = 0
    for _, mountID in ipairs(ids) do
        local name = C_MountJournal.GetMountInfoByID(mountID)
        if name and name:lower():find(query, 1, true) then
            ns.Print(("%s  ->  mountID = %d"):format(name, mountID))
            found = found + 1
            if found >= 20 then ns.Print("...(limited to 20)") break end
        end
    end
    if found == 0 then ns.Print("no mount matching '" .. query .. "'") end
end
