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

-- Localizacao curada (sweep do journal: npc/item/zona + mapeamento de
-- recompensas de rep/cache). Ver temp/location_sweep.jsonl.
M[54753] = { zone = "The Storm Peaks", expansion = "WotLK", manualUpdate = true }  -- White Polar Bear
M[61294] = { zone = "Sholazar Basin", manualUpdate = true }  -- Green Proto-Drake
M[138641] = { zone = "Isle of Giants", manualUpdate = true }  -- Red Primal Raptor
M[138642] = { zone = "Isle of Giants", manualUpdate = true }  -- Black Primal Raptor
M[138643] = { zone = "Isle of Giants", manualUpdate = true }  -- Green Primal Raptor
M[171619] = { map = 534, expansion = "WoD", manualUpdate = true }  -- Tundra Icehoof
M[171630] = { map = 534, expansion = "WoD", manualUpdate = true }  -- Armored Razorback
M[171634] = { zone = "Stormshield", expansion = "WoD", manualUpdate = true }  -- Domesticated Razorback
M[171825] = { zone = "Stormshield", expansion = "WoD", manualUpdate = true }  -- Mosshide Riverwallow
M[171827] = { zone = "Suramar", expansion = "Legion", manualUpdate = true }  -- Hellfire Infernal
M[171829] = { zone = "Warspear", expansion = "WoD", manualUpdate = true }  -- Shadowmane Charger
M[171837] = { map = 534, expansion = "WoD", manualUpdate = true }  -- Warsong Direfang
M[213134] = { zone = "Suramar", expansion = "Legion", manualUpdate = true }  -- Felblaze Infernal
M[214791] = { zone = "Dalaran Sewers", expansion = "Legion", manualUpdate = true }  -- Brinedeep Bottom-Feeder
M[233364] = { zone = "Suramar", manualUpdate = true }  -- Leywoven Flying Carpet
M[235764] = { zone = "Antoran Wastes", manualUpdate = true }  -- Darkspore Mana Ray
M[242874] = { zone = "Highmountain", expansion = "Legion", manualUpdate = true }  -- Highmountain Elderhorn
M[242875] = { zone = "Val'sharah", expansion = "Legion", manualUpdate = true }  -- Wild Dreamrunner
M[242881] = { zone = "Azsuna", expansion = "Legion", manualUpdate = true }  -- Cloudwing Hippogryph
M[242882] = { zone = "Stormheim", expansion = "Legion", manualUpdate = true }  -- Valarjar Stormwing
M[253106] = { zone = "Antoran Wastes", manualUpdate = true }  -- Vibrant Mana Ray
M[253108] = { zone = "Antoran Wastes", manualUpdate = true }  -- Felglow Mana Ray
M[253109] = { zone = "Antoran Wastes", manualUpdate = true }  -- Scintillating Mana Ray
M[254069] = { zone = "Antoran Wastes", expansion = "Legion", manualUpdate = true }  -- Glorious Felcrusher
M[254258] = { zone = "Antoran Wastes", expansion = "Legion", manualUpdate = true }  -- Blessed Felcrusher
M[254259] = { zone = "Antoran Wastes", manualUpdate = true }  -- Avenging Felcrusher
M[259213] = { zone = "Boralus", expansion = "BfA", manualUpdate = true }  -- Admiralty Stallion
M[266925] = { zone = "Boralus", expansion = "BfA", manualUpdate = true }  -- Siltwing Albatross
M[275868] = { zone = "Boralus", expansion = "BfA", manualUpdate = true }  -- Proudmoore Sea Scout
M[288506] = { zone = "Boralus", expansion = "BfA", manualUpdate = true }  -- Sandy Nightsaber
M[288711] = { zone = "Boralus", expansion = "BfA", manualUpdate = true }  -- Saltwater Seahorse
M[288736] = { zone = "Boralus", expansion = "BfA", manualUpdate = true }  -- Azureshell Krolusk
M[288740] = { zone = "Boralus", expansion = "BfA", manualUpdate = true }  -- Priestess' Moonsaber
M[289555] = { zone = "Battle of Dazar'alor", expansion = "BfA", manualUpdate = true }  -- Glacial Tidestorm
M[294038] = { zone = "Nazjatar", expansion = "BfA", manualUpdate = true }  -- Royal Snapdragon
M[327405] = { zone = "Maldraxxus", expansion = "Shadowlands", manualUpdate = true }  -- Colossal Slaughterclaw
M[332904] = { zone = "Revendreth", expansion = "Shadowlands", manualUpdate = true }  -- Harvester's Dredwing
M[342666] = { zone = "Ardenweald", expansion = "Shadowlands", manualUpdate = true }  -- Amber Ardenmoth
M[342667] = { zone = "Ardenweald", expansion = "Shadowlands", manualUpdate = true }  -- Vibrant Flutterwing
M[344228] = { zone = "Theater of Pain", expansion = "Shadowlands", manualUpdate = true }  -- Battle-Bound Warhound
M[344574] = { zone = "Maldraxxus", expansion = "Shadowlands", manualUpdate = true }  -- Bulbous Necroray
M[344575] = { zone = "Maldraxxus", manualUpdate = true }  -- Pestilent Necroray
M[344576] = { zone = "Maldraxxus", expansion = "Shadowlands", manualUpdate = true }  -- Infested Necroray
M[347536] = { zone = "Korthia", expansion = "Shadowlands", manualUpdate = true }  -- Tamed Mauler
M[347810] = { zone = "Korthia", expansion = "Shadowlands", manualUpdate = true }  -- Beryl Shardhide
M[352309] = { zone = "The Maw", expansion = "Shadowlands", manualUpdate = true }  -- Hand of Bahmethra
M[352441] = { zone = "Ardenweald", expansion = "Shadowlands", manualUpdate = true }  -- Wild Hunt Legsplitter
M[352742] = { zone = "Maldraxxus", expansion = "Shadowlands", manualUpdate = true }  -- Undying Darkhound
M[354352] = { zone = "The Maw", expansion = "Shadowlands", manualUpdate = true }  -- Soulbound Gloomcharger
M[354359] = { zone = "Korthia", expansion = "Shadowlands", manualUpdate = true }  -- Fierce Razorwing
M[363178] = { zone = "Torghast", expansion = "Shadowlands", manualUpdate = true }  -- Colossal Umbrahide Mawrat
M[371176] = { zone = "Zaralek Cavern", expansion = "Dragonflight", manualUpdate = true }  -- Subterranean Magmammoth
M[374090] = { zone = "The Forbidden Reach", expansion = "Dragonflight", manualUpdate = true }  -- Ancient Salamanther
M[374157] = { zone = "The Forbidden Reach", expansion = "Dragonflight", manualUpdate = true }  -- Gooey Snailemental
M[374194] = { zone = "The Forbidden Reach", manualUpdate = true }  -- Mossy Mammoth
M[385266] = { zone = "Ohn'ahran Plains", expansion = "Dragonflight", manualUpdate = true }  -- Zenet Hatchling
M[448979] = { zone = "Hallowfall", expansion = "TWW", manualUpdate = true }  -- Dauntless Imperial Lynx
M[466001] = { zone = "Undermine", expansion = "TWW", manualUpdate = true }  -- Blackwater Bonecrusher
M[466014] = { zone = "Undermine", expansion = "TWW", manualUpdate = true }  -- Steamwheedle Supplier
M[466020] = { map = 2346, expansion = "TWW", manualUpdate = true }  -- Personalized Goblin S.C.R.A.P.per
M[466021] = { zone = "Undermine", expansion = "TWW", manualUpdate = true }  -- Violet Goblin Shredder
M[466022] = { zone = "Undermine", expansion = "TWW", manualUpdate = true }  -- Venture Co-ordinator
M[466024] = { zone = "Undermine", expansion = "TWW", manualUpdate = true }  -- Bilgewater Bombardier
M[473188] = { zone = "Undermine", expansion = "TWW", manualUpdate = true }  -- Bronze Goblin Waveshredder
M[1233561] = { zone = "Hallowfall", expansion = "TWW", manualUpdate = true }  -- Curious Slateback
M[1261155] = { zone = "Voidstorm", expansion = "Midnight", manualUpdate = true }  -- Augmented Stormray
M[1261351] = { zone = "Zul'Aman", expansion = "Midnight", manualUpdate = true }  -- Witherbark Pango
M[1266700] = { zone = "Voidstorm", expansion = "Midnight", manualUpdate = true }  -- Sanguine Harrower

-- Expansao de mounts de classe / racial / legacy sem item legivel no Wowhead (a expansao
-- vem da classe/raca/conteudo). Fecha o bucket "Unknown".
M[13819] = { expansion = "Classic", manualUpdate = true }  -- Warhorse (Paladin)
M[16055] = { expansion = "Classic", zone = "Darnassus", manualUpdate = true }  -- Black Nightsaber (racial NE)
M[18363] = { expansion = "Classic", zone = "Thunder Bluff", manualUpdate = true }  -- Riding Kodo (racial Tauren)
M[23161] = { expansion = "Classic", manualUpdate = true }  -- Dreadsteed (Warlock)
M[34767] = { expansion = "TBC", manualUpdate = true }  -- Thalassian Charger (Paladin Blood Elf)
M[34769] = { expansion = "TBC", manualUpdate = true }  -- Thalassian Warhorse (Paladin Blood Elf)
M[48778] = { expansion = "WotLK", manualUpdate = true }  -- Acherus Deathcharger (Death Knight)
M[55164] = { expansion = "WotLK", manualUpdate = true }  -- Swift Spectral Gryphon
M[60136] = { expansion = "WotLK", manualUpdate = true }  -- Grand Caravan Mammoth (Mei Francis, Dalaran)
M[60140] = { expansion = "WotLK", manualUpdate = true }  -- Grand Caravan Mammoth (Mei Francis, Dalaran)
