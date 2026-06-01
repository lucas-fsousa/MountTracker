-- Data/Mounts_Classic.lua
-- Classic / Vanilla -- montarias curadas (fonte da verdade: Wowhead).
-- Sprint 1 (em progresso). Resolucao por spellID via C_MountJournal.GetMountFromSpell.

local ADDON, ns = ...

ns.Data.Register("Classic", {
    -- Alterac Valley (reputacao Exalted). Faction-specific: um Alliance, um Horde.
    {
        name    = "Stormpike Battle Charger",
        spellID = 23510,
        acquisition = "reputation",
        vendor  = "Stormpike Quartermaster",
        zone    = "Alterac Valley / Hillsbrad Foothills",
        requirement = { type = "reputation", factionID = 730, standing = "Exalted" }, -- Stormpike Guard (Alliance)
        cost    = { gold = 60 },
        wowhead = "https://www.wowhead.com/spell=23510",
    },
    {
        name    = "Frostwolf Howler",
        spellID = 23509,
        acquisition = "reputation",
        vendor  = "Frostwolf Quartermaster",
        zone    = "Alterac Valley / Hillsbrad Foothills",
        requirement = { type = "reputation", factionID = 729, standing = "Exalted" }, -- Frostwolf Clan (Horde)
        cost    = { gold = 60 },
        wowhead = "https://www.wowhead.com/spell=23509",
    },
})
