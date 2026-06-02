-- Data/Mounts_Midnight.lua
-- Midnight (12.0) -- montarias curadas (fonte: Wowhead + dados do jogo).
-- Facções de Renome: a verificacao de elegibilidade usa C_MajorFactions.

local ADDON, ns = ...

ns.Data.Register("Midnight", {
    -- Amani Tribe (faction 2696), vendedor Magovu em Zul'Aman.
    -- Moeda: Voidlight Marl (currency 3316).
    -- OBS: parear renome<->montaria conforme o vendedor (verificar in-game);
    -- a 15 de renome ambas ficam NEED_REQUIREMENT de qualquer forma.
    {
        name    = "Amani Blessed Bear",
        spellID = 1261357,
        acquisition = "reputation",
        vendor  = "Magovu",
        zone    = "Zul'Aman",
        requirement = { type = "renown", factionID = 2696, renownLevel = 17 },
        cost    = { currencyID = 3316, amount = 6000 },
        wowhead = "https://www.wowhead.com/spell=1261357",
    },
    {
        name    = "Amani Windcaller",
        spellID = 1251630,
        acquisition = "reputation",
        vendor  = "Magovu",
        zone    = "Zul'Aman",
        requirement = { type = "renown", factionID = 2696, renownLevel = 19 },
        cost    = { currencyID = 3316, amount = 8000 },
        wowhead = "https://www.wowhead.com/spell=1251630",
    },

    -- Quel'Thalas / Voidstorm (geradas por tools/curate.py).
    {
        name    = "Fiery Dragonhawk",
        spellID = 1261291,
        acquisition = "reputation",
        vendor  = "Caeris Fairdawn",
        zone    = "Eversong Woods",
        requirement = { type = "renown", factionID = 2710, renownLevel = 19 },
        cost    = { currencyID = 3316, amount = 8000 },
        wowhead = "https://www.wowhead.com/spell=1261291",
    },
    {
        name    = "Ravenous Shredclaw",
        spellID = 1261579,
        acquisition = "reputation",
        vendor  = "Void Researcher Anomander",
        zone    = "Voidstorm",
        requirement = { type = "renown", factionID = 2699, renownLevel = 17 },
        cost    = { currencyID = 3316, amount = 6000 },
        wowhead = "https://www.wowhead.com/spell=1261579",
    },
    {
        name    = "Voidbound Stormray",
        spellID = 1266702,
        acquisition = "reputation",
        vendor  = "Void Researcher Anomander",
        zone    = "Voidstorm",
        requirement = { type = "renown", factionID = 2699, renownLevel = 19 },
        cost    = { currencyID = 3316, amount = 8000 },
        wowhead = "https://www.wowhead.com/spell=1266702",
    },
})
