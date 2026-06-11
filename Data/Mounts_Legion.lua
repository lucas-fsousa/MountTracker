-- Data/Mounts_Legion.lua
-- Legion -- montarias de reputacao (geradas por tools/curate.py).

local ADDON, ns = ...

ns.Data.Register("Legion", {
    -- The Mad Merchant (Dalaran, Broken Isles): vende a Bloodfang Widow por 2.000.000 de
    -- ouro. O item se chama "Bloodfang Cocoon" (!= nome da mount), por isso o harvest
    -- automatico nao resolveu o custo; curada a mao. map 627 = Dalaran (Legion).
    {
        name    = "Bloodfang Widow",
        spellID = 213115,
        acquisition = "vendor",
        vendor  = "The Mad Merchant",
        zone    = "Dalaran",
        map     = 627,
        cost    = { gold = 2000000 },
        wowhead = "https://www.wowhead.com/spell=213115",
    },
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
