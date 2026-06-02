-- Data/Mounts_Legion.lua
-- Legion -- montarias de reputacao (geradas por tools/curate.py).

local ADDON, ns = ...

ns.Data.Register("Legion", {
    {
        name    = "Brinedeep Bottom-Feeder",
        spellID = 214791,
        acquisition = "reputation",
        vendor  = "Conjurer Margoss",
        zone    = "Dalaran",
        requirement = { type = "reputation", factionID = 1975, standing = "Honored" }, -- Conjurer Margoss
        cost    = { itemID = 138777, amount = 100 },
        wowhead = "https://www.wowhead.com/spell=214791",
    },
})
