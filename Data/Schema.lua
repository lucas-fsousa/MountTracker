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
--     map         = 107,                           -- uiMapID ESTRITO da zona de obtencao
--                                                  -- (filtro "Current zone" casa por ID,
--                                                  -- imune a nomes homonimos entre xpacs)
--     coords      = { map = 2112, x = 53.0, y = 56.8 },  -- opcional: waypoint do
--                                                  -- vendedor (uiMapID + x,y em 0-100)
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
--         -- currencyID = 2003, amount = 500,        -- moeda especifica; OU:
--         -- itemID     = 117397, amount = 100,      -- item/token
--     },
--
--     -- Para acquisition "drop"/"world"/"rare": chance de drop como fracao 0..1.
--     -- Gradua a "obtenibilidade": 1/25, 1/50 = aceitavel; 1/150, 1/200 = very rare.
--     dropChance = 0.04,                            -- ex.: 1 em 25
--     source     = "Baron Rivendare",               -- NPC/fonte (no lugar de vendor)
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
