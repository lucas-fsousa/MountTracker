-- Data/Mounts_TBC.lua
-- The Burning Crusade -- montarias curadas (fonte da verdade: Wowhead).
-- Resolucao por spellID -> mountID via C_MountJournal.GetMountFromSpell.

local ADDON, ns = ...

ns.Data.Register("TBC", {
    {
        name    = "Cenarion War Hippogryph",
        spellID = 43927,
        acquisition = "reputation",
        vendor  = "Fedryen Swiftspear",
        zone    = "Zangarmarsh",
        requirement = { type = "reputation", factionID = 942, standing = "Exalted" }, -- Cenarion Expedition
        cost    = { gold = 1600 },
        wowhead = "https://www.wowhead.com/spell=43927",
    },
    {
        name    = "Veridian Netherwing Drake",
        spellID = 41517,
        acquisition = "reputation",
        vendor  = "Drake Dealer Hurlunk",
        zone    = "Shadowmoon Valley (Netherwing Ledge)",
        requirement = { type = "reputation", factionID = 1015, standing = "Exalted" }, -- Netherwing
        cost    = { gold = 200 },
        wowhead = "https://www.wowhead.com/spell=41517",
    },
    {
        name    = "Cobalt Riding Talbuk",
        spellID = 39315,
        acquisition = "reputation",
        vendor  = "Trader Narasu",
        zone    = "Nagrand (Garadar)",
        requirement = { type = "reputation", factionID = 941, standing = "Exalted" }, -- The Mag'har (Horde)
        cost    = { gold = 100 },
        wowhead = "https://www.wowhead.com/spell=39315",
    },
    {
        name    = "Green Riding Nether Ray",
        spellID = 39798,
        acquisition = "reputation",
        vendor  = "Grella",
        zone    = "Terokkar Forest (Blackwind Landing, Skettis)",
        requirement = { type = "reputation", factionID = 1031, standing = "Exalted" }, -- Sha'tari Skyguard
        cost    = { gold = 100 },
        wowhead = "https://www.wowhead.com/spell=39798",
    },
    {
        name    = "Purple Riding Nether Ray",
        spellID = 39801,
        acquisition = "reputation",
        vendor  = "Grella",
        zone    = "Terokkar Forest (Blackwind Landing, Skettis)",
        requirement = { type = "reputation", factionID = 1031, standing = "Exalted" }, -- Sha'tari Skyguard
        cost    = { gold = 100 },
        wowhead = "https://www.wowhead.com/spell=39801",
    },
})
