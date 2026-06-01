-- Data/Mounts_Reputation.lua
-- Curated sample of reputation (vendor) mounts -- v0.
--
-- Source of truth: Wowhead. We store the SPELL ID (reliable on Wowhead) and resolve
-- it to the live Mount Journal mountID at runtime via C_MountJournal.GetMountFromSpell.
-- This is language-independent and stable across patches. `name` is kept only as a
-- human label / last-resort fallback.
--
-- TBC reputation factionIDs are stable and well documented.

local ADDON, ns = ...

ns.Data.Reputation = {
    {
        name    = "Cenarion War Hippogryph",
        spellID = 43927,
        source  = "vendor",
        vendor  = "Fedryen Swiftspear",
        zone    = "Zangarmarsh",
        requirement = { type = "reputation", factionID = 942, standing = "Exalted" }, -- Cenarion Expedition
        cost    = { gold = 1600 },
        wowhead = "https://www.wowhead.com/spell=43927",
    },
    {
        name    = "Veridian Netherwing Drake",
        spellID = 41517,
        source  = "vendor",
        vendor  = "Drake Dealer Hurlunk",
        zone    = "Shadowmoon Valley (Netherwing Ledge)",
        requirement = { type = "reputation", factionID = 1015, standing = "Exalted" }, -- Netherwing
        cost    = { gold = 200 },
        wowhead = "https://www.wowhead.com/spell=41517",
    },
    {
        name    = "Cobalt Riding Talbuk",
        spellID = 39315,
        source  = "vendor",
        vendor  = "Trader Narasu",
        zone    = "Nagrand (Garadar)",
        requirement = { type = "reputation", factionID = 941, standing = "Exalted" }, -- The Mag'har (Horde)
        cost    = { gold = 100 },
        wowhead = "https://www.wowhead.com/spell=39315",
    },
    {
        name    = "Green Riding Nether Ray",
        spellID = 39798,
        source  = "vendor",
        vendor  = "Grella",
        zone    = "Terokkar Forest (Blackwind Landing, Skettis)",
        requirement = { type = "reputation", factionID = 1031, standing = "Exalted" }, -- Sha'tari Skyguard
        cost    = { gold = 100 },
        wowhead = "https://www.wowhead.com/spell=39798",
    },
    {
        name    = "Purple Riding Nether Ray",
        spellID = 39801,
        source  = "vendor",
        vendor  = "Grella",
        zone    = "Terokkar Forest (Blackwind Landing, Skettis)",
        requirement = { type = "reputation", factionID = 1031, standing = "Exalted" }, -- Sha'tari Skyguard
        cost    = { gold = 100 },
        wowhead = "https://www.wowhead.com/spell=39801",
    },
}
