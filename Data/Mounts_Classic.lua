-- Data/Mounts_Classic.lua
-- Classic / Vanilla -- montarias curadas (fonte da verdade: Wowhead).
-- Sprint 1 (em progresso). Resolucao por spellID via C_MountJournal.GetMountFromSpell.

local ADDON, ns = ...

ns.Data.Register("Classic", {
    -- Alterac Valley (reputacao Exalted). Faction-specific: um Alliance, um Horde.
    {
        name    = "Stormpike Battle Charger",
        faction = "Alliance",
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

    -- Reputacao de grind (Alliance, Winterspring). Quest do Rivern ao atingir Exalted.
    {
        name    = "Winterspring Frostsaber",
        spellID = 17229,
        acquisition = "reputation",
        vendor  = "Rivern Frostwind",
        zone    = "Winterspring (Frostsaber Rock)",
        requirement = { type = "reputation", factionID = 589, standing = "Exalted" }, -- Wintersaber Trainers
        wowhead = "https://www.wowhead.com/spell=17229",
    },

    -- Drop de RNG (~1%) do Baron Rivendare em Stratholme.
    {
        name    = "Rivendare's Deathcharger",
        spellID = 17481,
        acquisition = "drop",
        source  = "Baron Rivendare",
        zone    = "Stratholme (Eastern Plaguelands)",
        dropChance = 0.01,   -- ~1 em 100 (very rare)
        wowhead = "https://www.wowhead.com/spell=17481",
    },
})
