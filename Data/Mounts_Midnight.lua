-- Data/Mounts_Midnight.lua
-- Midnight (12.0) -- montarias curadas (fonte: Wowhead + dados do jogo).
-- Facções de Renome: a verificacao de elegibilidade usa C_MajorFactions.

local ADDON, ns = ...

ns.Data.Register("Midnight", {
    -- Vendedor de Silvermoon (Sergeant Vornin): liberada pela conquista
    -- "Void Response Team" (62563) + custo em Field Accolade (currency 3405).
    -- O jogo so expoe o NOME da conquista no sourceText (sem ID verificavel), entao
    -- mounts gated por conquista precisam ser curadas p/ o glow funcionar.
    {
        name    = "Unbound Manawyrm",
        spellID = 1271698,
        acquisition = "vendor",
        vendor  = "Sergeant Vornin",
        zone    = "Silvermoon City",
        coords  = { map = 2393, x = 48.4, y = 50.4 },
        requirement = { type = "achievement", achievementID = 62563 },
        cost    = { currencyID = 3405, amount = 200 },
        wowhead = "https://www.wowhead.com/spell=1271698",
    },

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
        coords  = { map = 2437, x = 45.8, y = 65.8 },
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
        coords  = { map = 2437, x = 45.8, y = 65.8 },
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
        coords  = { map = 2395, x = 43.4, y = 47.4 },
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
        coords  = { map = 2405, x = 52.4, y = 72.8 },
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
        coords  = { map = 2405, x = 52.4, y = 72.8 },
        requirement = { type = "renown", factionID = 2699, renownLevel = 19 },
        cost    = { currencyID = 3316, amount = 8000 },
        wowhead = "https://www.wowhead.com/spell=1266702",
    },

    -- Hara'ti (Harandar): o Wowhead nao expoe o factionID; resolvido em runtime
    -- pelo nome via C_MajorFactions (factionName).
    {
        name    = "Fierce Grimlynx",
        spellID = 1243593,
        acquisition = "reputation",
        vendor  = "Naynar",
        zone    = "Harandar",
        coords  = { map = 2413, x = 51.0, y = 50.8 },
        requirement = { type = "renown", factionName = "Hara'ti", renownLevel = 16 },
        cost    = { currencyID = 3316, amount = 6000 },
        wowhead = "https://www.wowhead.com/spell=1243593",
    },
    {
        name    = "Cerulean Sporeglider",
        spellID = 1253929,
        acquisition = "reputation",
        vendor  = "Naynar",
        zone    = "Harandar",
        coords  = { map = 2413, x = 51.0, y = 50.8 },
        requirement = { type = "renown", factionName = "Hara'ti", renownLevel = 19 },
        cost    = { currencyID = 3316, amount = 8000 },
        wowhead = "https://www.wowhead.com/spell=1253929",
    },

    -- Slayer's Duellum (Masters' Perch).
    {
        name    = "Prowling Shredclaw",
        spellID = 1261584,
        acquisition = "reputation",
        vendor  = "Thraxadar",
        zone    = "Masters' Perch",
        coords  = { map = 2444, x = 39.2, y = 81.0 },
        requirement = { type = "reputation", factionID = 2770, standing = "Exalted" }, -- Slayer's Duellum
        cost    = { currencyID = 3316, amount = 6000 },
        wowhead = "https://www.wowhead.com/spell=1261584",
    },
    {
        name    = "Frenzied Shredclaw",
        spellID = 1261585,
        acquisition = "reputation",
        vendor  = "Thraxadar",
        zone    = "Masters' Perch",
        coords  = { map = 2444, x = 39.2, y = 81.0 },
        requirement = { type = "reputation", factionID = 2770, standing = "Exalted" }, -- Slayer's Duellum
        cost    = { currencyID = 3316, amount = 6000 },
        wowhead = "https://www.wowhead.com/spell=1261585",
    },
})
