-- Data/Mounts_Cataclysm.lua
-- Cataclysm -- montarias de reputacao (geradas por tools/curate.py).

local ADDON, ns = ...

ns.Data.Register("Cataclysm", {
    {
        name    = "Spectral Wolf",
        spellID = 92232,
        acquisition = "reputation",
        vendor  = "Pogg",
        zone    = "Tol Barad Peninsula",
        requirement = { type = "reputation", factionID = 1178, standing = "Exalted" }, -- Hellscream's Reach
        cost    = { currencyID = 391, amount = 165 },
        wowhead = "https://www.wowhead.com/spell=92232",
    },
})
