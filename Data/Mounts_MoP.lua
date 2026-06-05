-- Data/Mounts_MoP.lua
-- Mists of Pandaria -- montarias de reputacao (geradas por tools/curate.py).

local ADDON, ns = ...

ns.Data.Register("MoP", {
    {
        name    = "Grand Armored Wyvern",
        faction = "Horde",
        spellID = 135418,
        acquisition = "reputation",
        vendor  = "Tuskripper Grukna",
        zone    = "Krasarang Wilds",
        requirement = { type = "reputation", factionID = 1375, standing = "Exalted" }, -- Dominance Offensive
        cost    = { gold = 2000 },
        wowhead = "https://www.wowhead.com/spell=135418",
    },
    {
        name    = "Crimson Primal Direhorn",
        spellID = 140250,
        acquisition = "reputation",
        vendor  = "Vasarin Redmorn",
        zone    = "Isle of Thunder",
        requirement = { type = "reputation", factionID = 1388, standing = "Exalted" }, -- Sunreaver Onslaught
        cost    = { gold = 3000 },
        wowhead = "https://www.wowhead.com/spell=140250",
    },
    {
        name    = "Crimson Water Strider",
        spellID = 127271,
        acquisition = "reputation",
        vendor  = "Nat Pagle",
        zone    = "Garrison: Fishing Shack",
        requirement = { type = "reputation", factionID = 1358, standing = "Honored" }, -- Nat Pagle
        cost    = { itemID = 117397, amount = 100 },
        wowhead = "https://www.wowhead.com/spell=127271",
    },
})
