-- Data/Schema.lua
-- Apenas documentacao do formato de uma entrada curada (nao executa logica).
--
-- Cada entrada descreve UMA montaria de vendedor/reputacao:
--
-- {
--     name        = "Cenarion War Hippogryph",  -- rotulo humano / fallback de resolucao
--     spellID     = 43927,                        -- CHAVE PRIMARIA (do Wowhead): resolvida em runtime
--                                                 --   via C_MountJournal.GetMountFromSpell -> mountID
--     mountID     = nil,                          -- opcional: ID direto do Mount Journal (tem prioridade)
--
--     source      = "vendor",
--     vendor      = "Fedryen Swiftspear",
--     zone        = "Zangarmarsh",
--     coords      = { x = 79.2, y = 63.5 },       -- opcional
--
--     requirement = {                              -- o que te torna ELEGIVEL a comprar
--         type      = "reputation",                -- "reputation" | "renown" | "achievement"
--         factionID = 942,                         -- ID da faccao (reputacao classica) ou major faction
--         standing  = "Exalted",                   -- p/ "reputation": nome do nivel
--         -- renownLevel = 20,                      -- p/ "renown"
--         -- achievementID = 12345,                 -- p/ "achievement"
--     },
--
--     cost = {                                      -- o que voce paga ao comprar
--         gold       = 1600,                        -- em ouro; OU:
--         -- currencyID = 2003, amount = 500,        -- moeda especifica
--     },
--
--     wowhead = "https://www.wowhead.com/...",
-- }
--
-- Mapa de standing -> reaction (valor numerico da API de reputacao):
--   Hated=1 Hostile=2 Unfriendly=3 Neutral=4 Friendly=5 Honored=6 Revered=7 Exalted=8

local ADDON, ns = ...

ns.STANDING_TO_REACTION = {
    Hated = 1, Hostile = 2, Unfriendly = 3, Neutral = 4,
    Friendly = 5, Honored = 6, Revered = 7, Exalted = 8,
}
