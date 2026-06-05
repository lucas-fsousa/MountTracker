-- Data/Mounts_WoD.lua
-- Warlords of Draenor -- montarias de reputacao (geradas por tools/curate.py).

local ADDON, ns = ...

ns.Data.Register("WoD", {
    {
        name    = "Breezestrider Stallion",
        faction = "Horde",
        spellID = 171832,
        acquisition = "reputation",
        vendor  = "Dazzerian",
        zone    = "Warspear",
        coords  = { map = 1355, x = 48.8, y = 60.8 },
        requirement = { type = "reputation", factionID = 1681, standing = "Exalted" }, -- Vol'jin's Spear (Horde)
        cost    = { currencyID = 823, amount = 5000 }, -- Apexis Crystals (+5000 gold)
        wowhead = "https://www.wowhead.com/spell=171832",
    },
    {
        name    = "Pale Thorngrazer",
        faction = "Alliance",
        spellID = 171833,
        acquisition = "reputation",
        vendor  = "Crafticus Mindbender",
        zone    = "Stormshield",
        requirement = { type = "reputation", factionID = 1682, standing = "Exalted" }, -- Wrynn's Vanguard (Alliance)
        cost    = { currencyID = 823, amount = 5000 },
        wowhead = "https://www.wowhead.com/spell=171833",
    },
    {
        name    = "Corrupted Dreadwing",
        spellID = 183117,
        acquisition = "reputation",
        vendor  = "Dawn-Seeker Krisek",
        zone    = "Tanaan Jungle",
        coords  = { map = 534, x = 57.8, y = 59.4 },
        requirement = { type = "reputation", factionID = 1849, standing = "Friendly" }, -- Order of the Awakened
        cost    = { currencyID = 823, amount = 150000 },
        wowhead = "https://www.wowhead.com/spell=183117",
    },
})
