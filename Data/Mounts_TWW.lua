-- Data/Mounts_TWW.lua
-- The War Within (11.x) -- montarias de Renome (geradas por tools/curate.py).
-- Verificacao de elegibilidade via C_MajorFactions (renownLevel).

local ADDON, ns = ...

ns.Data.Register("TWW", {
    {
        name    = "Cyan Glowmite",
        spellID = 447176,
        acquisition = "reputation",
        vendor  = "Waxmonger Squick",
        zone    = "The Ringing Deeps",
        requirement = { type = "renown", factionID = 2594, renownLevel = 19 }, -- The Assembly of the Deeps
        cost    = { currencyID = 2815, amount = 11375 },
        wowhead = "https://www.wowhead.com/spell=447176",
    },
    {
        name    = "Darkfuse Chompactor",
        spellID = 466000,
        acquisition = "reputation",
        vendor  = "Ando the Gat",
        zone    = "Liberation of Undermine",
        requirement = { type = "renown", factionID = 2685, renownLevel = 17 },
        cost    = { gold = 500 },
        wowhead = "https://www.wowhead.com/spell=466000",
    },
    {
        name    = "Violet Armored Growler",
        spellID = 466002,
        acquisition = "reputation",
        vendor  = "Smaks Topskimmer",
        zone    = "Undermine",
        requirement = { type = "renown", factionID = 2653, renownLevel = 15 }, -- Bilgewater Cartel
        cost    = { currencyID = 2815, amount = 8125 },
        wowhead = "https://www.wowhead.com/spell=466002",
    },
    {
        name    = "Flarendo the Furious",
        spellID = 466011,
        acquisition = "reputation",
        vendor  = "Ando the Gat",
        zone    = "Liberation of Undermine",
        requirement = { type = "renown", factionID = 2685, renownLevel = 20 },
        cost    = { gold = 777 },
        wowhead = "https://www.wowhead.com/spell=466011",
    },
    {
        name    = "Thunderdrum Misfire",
        spellID = 466012,
        acquisition = "reputation",
        vendor  = "Ando the Gat",
        zone    = "Liberation of Undermine",
        requirement = { type = "renown", factionID = 2685, renownLevel = 8 },
        cost    = { gold = 500 },
        wowhead = "https://www.wowhead.com/spell=466012",
    },
    {
        name    = "The Topskimmer Special",
        spellID = 466016,
        acquisition = "reputation",
        vendor  = "Smaks Topskimmer",
        zone    = "Undermine",
        requirement = { type = "renown", factionID = 2653, renownLevel = 19 }, -- Bilgewater Cartel
        cost    = { currencyID = 2815, amount = 11375 },
        wowhead = "https://www.wowhead.com/spell=466016",
    },
    {
        name    = "Terror of the Wastes",
        spellID = 1223187,
        acquisition = "reputation",
        vendor  = "Om'sirik",
        zone    = "K'aresh",
        requirement = { type = "renown", factionID = 2658, renownLevel = 19 }, -- K'aresh Trust
        cost    = { currencyID = 2815, amount = 11375 },
        wowhead = "https://www.wowhead.com/spell=1223187",
    },
    {
        name    = "Ruby Void Creeper",
        spellID = 1233546,
        acquisition = "reputation",
        vendor  = "Om'sirik",
        zone    = "K'aresh",
        requirement = { type = "renown", factionID = 2658, renownLevel = 15 }, -- K'aresh Trust
        cost    = { currencyID = 2815, amount = 8125 },
        wowhead = "https://www.wowhead.com/spell=1233546",
    },

    -- Manaforge Vandals (trilha de Renome do raid Manaforge Omega). Recompensas
    -- diretas do rank -- SEM custo em moeda (so atingir o renome e resgatar).
    {
        name    = "Vandal's Gearglider",
        spellID = 353265,
        acquisition = "reputation",
        zone    = "Shadow Point",
        requirement = { type = "renown", factionID = 2736, renownLevel = 8 }, -- Manaforge Vandals
        wowhead = "https://www.wowhead.com/spell=353265",
    },
    {
        name    = "The Bone Freezer",
        spellID = 1233542,
        acquisition = "reputation",
        zone    = "Shadow Point",
        requirement = { type = "renown", factionID = 2736, renownLevel = 14 }, -- Manaforge Vandals
        wowhead = "https://www.wowhead.com/spell=1233542",
    },
})
