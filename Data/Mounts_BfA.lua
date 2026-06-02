-- Data/Mounts_BfA.lua
-- Battle for Azeroth -- montarias de reputacao (geradas por tools/curate.py).

local ADDON, ns = ...

ns.Data.Register("BfA", {
    {
        name    = "Unshackled Waveray",
        spellID = 291538,
        acquisition = "reputation",
        vendor  = "Finder Pruc",
        zone    = "Nazjatar",
        requirement = { type = "reputation", factionID = 2373, standing = "Exalted" }, -- Unshackled
        cost    = { currencyID = 1721, amount = 250 }, -- Prismatic Manapearl
        wowhead = "https://www.wowhead.com/spell=291538",
    },
    {
        name    = "Ankoan Waveray",
        spellID = 292407,
        acquisition = "reputation",
        vendor  = "Artisan Okata",
        zone    = "Nazjatar",
        requirement = { type = "reputation", factionID = 2400, standing = "Exalted" }, -- Ankoan
        cost    = { currencyID = 1721, amount = 250 },
        wowhead = "https://www.wowhead.com/spell=292407",
    },
    {
        name    = "Wastewander Skyterror",
        spellID = 316276,
        acquisition = "reputation",
        vendor  = "Provisioner Qorra",
        zone    = "Uldum",
        requirement = { type = "reputation", factionID = 2417, standing = "Exalted" }, -- Uldum Accord
        cost    = { gold = 24000 },
        wowhead = "https://www.wowhead.com/spell=316276",
    },
})
