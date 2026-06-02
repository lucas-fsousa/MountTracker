-- Data/Mounts_Shadowlands.lua
-- Shadowlands -- montarias de reputacao (geradas por tools/curate.py).

local ADDON, ns = ...

ns.Data.Register("Shadowlands", {
    {
        name    = "Heartlight Vombata",
        spellID = 359229,
        acquisition = "reputation",
        vendor  = "Vilo",
        zone    = "Zereth Mortis",
        requirement = { type = "reputation", factionID = 2478, standing = "Exalted" }, -- The Enlightened
        cost    = { currencyID = 1813, amount = 5000 }, -- Reservoir Anima
        wowhead = "https://www.wowhead.com/spell=359229",
    },
})
