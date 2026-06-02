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
})
