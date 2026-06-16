-- Data/Mounts_ManualMeta.lua
-- Overlay de METADADOS curado A MAO (expansao / zona) para montarias que os scripts NAO
-- conseguem resolver com seguranca a partir do Wowhead -- tipicamente racials/legacy cujo
-- sourceText do jogo e so "Legacy", a spell page nao tem patch nem linka o item, e o item
-- tem nome irregular (ou nem existe). Mesmo papel do Mounts_Meta.lua (so filtros: expansao
-- e current zone; nao afeta status/glow), mas mantido A MAO.
--
-- manualUpdate = true marca cada entrada como INTOCAVEL: tools/enrich_meta.py e os demais
-- enrich_* PULAM completamente estes spellIDs -- nunca regeneram nem sobrescrevem. Curadoria
-- aqui e sempre manual e minuciosa. A zona (string) e resolvida p/ uiMapID em runtime por
-- ns.Waypoint.MapForZone (varre os mapas do jogo), entao basta o nome exato da zona.
--
-- Carregado DEPOIS de Mounts_Meta.lua no .toc; estes spellIDs nao aparecem la (enrich_meta
-- os ignora), entao nao ha conflito.

local ADDON, ns = ...
ns.Meta = ns.Meta or {}
local M = ns.Meta

-- Racials / mounts "Legacy" de Classic (o jogo so retorna "Legacy"; item de nome irregular):
M[581]   = { expansion = "Classic", zone = "Orgrimmar", manualUpdate = true }  -- Winter Wolf
M[5784]  = { expansion = "Classic", zone = "Undercity", manualUpdate = true }  -- Felsteed
M[8980]  = { expansion = "Classic", zone = "Undercity", manualUpdate = true }  -- Skeletal Horse
M[10790] = { expansion = "Classic", zone = "Darnassus", manualUpdate = true }  -- Tiger (saber vanilla de night elf)
-- Qiraji Battle Tanks coloridos: obteniveis em Ahn'Qiraj (AQ40); item "<Cor> Qiraji
-- Resonating Crystal". O nome do item nao casa a montaria, entao curados a mao.
M[25953] = { expansion = "Classic", zone = "Temple of Ahn'Qiraj", manualUpdate = true }  -- Blue Qiraji Battle Tank
M[26054] = { expansion = "Classic", zone = "Temple of Ahn'Qiraj", manualUpdate = true }  -- Red Qiraji Battle Tank
M[26055] = { expansion = "Classic", zone = "Temple of Ahn'Qiraj", manualUpdate = true }  -- Yellow Qiraji Battle Tank
M[26056] = { expansion = "Classic", zone = "Temple of Ahn'Qiraj", manualUpdate = true }  -- Green Qiraji Battle Tank
-- Black Qiraji Battle Tank: INOBTENIVEL (recompensa unica dos primeiros a completar a quest
-- dos Portoes de Ahn'Qiraj). 3 spellIDs com esse nome -> todos marcados unavailable.
M[25863] = { expansion = "Classic", unavailable = true, note = "Unobtainable: Gates of AQ event", manualUpdate = true }  -- Black Qiraji Battle Tank
M[26655] = { expansion = "Classic", unavailable = true, note = "Unobtainable: Gates of AQ event", manualUpdate = true }  -- Black Qiraji Battle Tank
M[26656] = { expansion = "Classic", unavailable = true, note = "Unobtainable: Gates of AQ event", manualUpdate = true }  -- Black Qiraji Battle Tank
