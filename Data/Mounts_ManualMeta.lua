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

-- Localizacao curada (sweep Drop/Quest/Vendor: zona do sourceText do
-- jogo + NPC/item/mapa). Ver temp/noloc_resolved.jsonl.
M[24252] = { zone = "Zul'Gurub", manualUpdate = true }  -- Swift Zulian Tiger
M[41513] = { zone = "Shattrath City, Outland", expansion = "TBC", manualUpdate = true }  -- Onyx Netherwing Drake
M[41514] = { zone = "Shattrath City, Outland", expansion = "TBC", manualUpdate = true }  -- Azure Netherwing Drake
M[41515] = { zone = "Shattrath City, Outland", expansion = "TBC", manualUpdate = true }  -- Cobalt Netherwing Drake
M[41516] = { zone = "Shattrath City, Outland", expansion = "TBC", manualUpdate = true }  -- Purple Netherwing Drake
M[41518] = { zone = "Shattrath City, Outland", expansion = "TBC", manualUpdate = true }  -- Violet Netherwing Drake
M[61465] = { zone = "Vault of Archavon", manualUpdate = true }  -- Grand Black War Mammoth
M[61467] = { zone = "Vault of Archavon", manualUpdate = true }  -- Grand Black War Mammoth
M[63844] = { zone = "Argent Tournament, Icecrown", expansion = "WotLK", manualUpdate = true }  -- Argent Hippogryph
M[64659] = { zone = "Un'Goro Crater", expansion = "Classic", manualUpdate = true }  -- Venomhide Ravasaur
M[73313] = { zone = "Icecrown Citadel", expansion = "WotLK", manualUpdate = true }  -- Crimson Deathcharger
M[75207] = { zone = "Kelp'thar Forest", manualUpdate = true }  -- Vashj'ir Seahorse
M[113199] = { zone = "The Jade Forest", expansion = "MoP", manualUpdate = true }  -- Jade Cloud Serpent
M[123182] = { zone = "Krasarang Wilds", expansion = "MoP", manualUpdate = true }  -- Kafa Yak
M[123992] = { zone = "The Jade Forest", expansion = "MoP", manualUpdate = true }  -- Azure Cloud Serpent
M[123993] = { zone = "The Jade Forest", expansion = "MoP", manualUpdate = true }  -- Golden Cloud Serpent
M[127154] = { zone = "Townlong Steppes", expansion = "MoP", manualUpdate = true }  -- Onyx Cloud Serpent
M[136163] = { zone = "Kun-Lai Summit", manualUpdate = true }  -- Grand Gryphon
M[136164] = { zone = "Kun-Lai Summit", manualUpdate = true }  -- Grand Wyvern
M[138640] = { zone = "Isle of Giants", expansion = "MoP", manualUpdate = true }  -- Bone-White Primal Raptor
M[171626] = { zone = "Garrison Trading Post", manualUpdate = true }  -- Armored Irontusk
M[171831] = { zone = "Garrison Stables", manualUpdate = true }  -- Trained Silverpelt
M[171833] = { zone = "Stormshield", expansion = "WoD", manualUpdate = true }  -- Pale Thorngrazer
M[171850] = { zone = "Suramar", expansion = "Legion", manualUpdate = true }  -- Llothien Prowler
M[189999] = { zone = "Moonglade", manualUpdate = true }  -- Grove Warden
M[230987] = { zone = "Suramar", expansion = "Legion", manualUpdate = true }  -- Arcanist's Manasaber
M[231428] = { zone = "Return to Karazhan", manualUpdate = true }  -- Smoldering Ember Wyrm
M[237286] = { zone = "Vol'dun", expansion = "BfA", manualUpdate = true }  -- Dune Scavenger
M[243795] = { zone = "Nazmir", expansion = "BfA", manualUpdate = true }  -- Leaping Veinseeker
M[253639] = { zone = "Dalaran", expansion = "WotLK", manualUpdate = true }  -- Violet Spellwing
M[259741] = { zone = "Stormsong Valley", expansion = "BfA", manualUpdate = true }  -- Honeyback Harvester
M[260174] = { zone = "Drustvar", expansion = "BfA", manualUpdate = true }  -- Terrified Pack Mule
M[260175] = { zone = "Stormsong", expansion = "BfA", manualUpdate = true }  -- Goldenmane
M[267270] = { zone = "Zuldazar", expansion = "BfA", manualUpdate = true }  -- Kua'fon
M[297560] = { zone = "Zuldazar", expansion = "BfA", manualUpdate = true }  -- Child of Torcali
M[299159] = { zone = "Mechagon", expansion = "BfA", manualUpdate = true }  -- Scrapforged Mechaspider
M[300146] = { zone = "Nazjatar", expansion = "BfA", manualUpdate = true }  -- Snapdragon Kelpstalker
M[300147] = { zone = "Nazjatar", expansion = "BfA", manualUpdate = true }  -- Deepcoral Snapdragon
M[300151] = { zone = "Nazjatar", expansion = "BfA", manualUpdate = true }  -- Inkscale Deepseeker
M[312753] = { zone = "Revendreth", expansion = "Shadowlands", manualUpdate = true }  -- Hopecrusher Gargon
M[312754] = { zone = "Revendreth", expansion = "Shadowlands", manualUpdate = true }  -- Battle Gargon Vrednic
M[312759] = { zone = "Ardenweald", expansion = "Shadowlands", manualUpdate = true }  -- Dreamlight Runestag
M[312761] = { zone = "Ardenweald", expansion = "Shadowlands", manualUpdate = true }  -- Enchanted Dreamlight Runestag
M[316339] = { zone = "Uldum", expansion = "Cataclysm", manualUpdate = true }  -- Shadowbarb Drone
M[316802] = { zone = "Uldum", expansion = "Cataclysm", manualUpdate = true }  -- Springfur Alpaca
M[332243] = { zone = "Ardenweald", expansion = "Shadowlands", manualUpdate = true }  -- Shadeleaf Runestag
M[332244] = { zone = "Ardenweald", expansion = "Shadowlands", manualUpdate = true }  -- Wakener's Runestag
M[332245] = { zone = "Ardenweald", expansion = "Shadowlands", manualUpdate = true }  -- Winterborn Runestag
M[332246] = { zone = "Ardenweald", expansion = "Shadowlands", manualUpdate = true }  -- Enchanted Shadeleaf Runestag
M[332247] = { zone = "Ardenweald", expansion = "Shadowlands", manualUpdate = true }  -- Enchanted Wakener's Runestag
M[332248] = { zone = "Ardenweald", expansion = "Shadowlands", manualUpdate = true }  -- Enchanted Winterborn Runestag
M[332252] = { zone = "Ardenweald", expansion = "Shadowlands", manualUpdate = true }  -- Shimmermist Runner
M[332455] = { zone = "Maldraxxus", expansion = "Shadowlands", manualUpdate = true }  -- War-Bred Tauralus
M[332456] = { zone = "Maldraxxus", expansion = "Shadowlands", manualUpdate = true }  -- Plaguerot Tauralus
M[332462] = { zone = "Maldraxxus", expansion = "Shadowlands", manualUpdate = true }  -- Armored War-Bred Tauralus
M[332923] = { zone = "Revendreth", expansion = "Shadowlands", manualUpdate = true }  -- Inquisition Gargon
M[332927] = { zone = "Revendreth", expansion = "Shadowlands", manualUpdate = true }  -- Sinfall Gargon
M[332932] = { zone = "Revendreth", expansion = "Shadowlands", manualUpdate = true }  -- Crypt Gargon
M[332949] = { zone = "Revendreth", expansion = "Shadowlands", manualUpdate = true }  -- Desire's Battle Gargon
M[333021] = { zone = "Revendreth", expansion = "Shadowlands", manualUpdate = true }  -- Gravestone Battle Gargon
M[333023] = { zone = "Revendreth", expansion = "Shadowlands", manualUpdate = true }  -- Battle Gargon Silessa
M[334382] = { zone = "Bastion", expansion = "Shadowlands", manualUpdate = true }  -- Phalynx of Loyalty
M[334386] = { zone = "Bastion", expansion = "Shadowlands", manualUpdate = true }  -- Phalynx of Humility
M[334391] = { zone = "Bastion", expansion = "Shadowlands", manualUpdate = true }  -- Phalynx of Courage
M[334398] = { zone = "Bastion", expansion = "Shadowlands", manualUpdate = true }  -- Phalynx of Purity
M[334403] = { zone = "Bastion", expansion = "Shadowlands", manualUpdate = true }  -- Eternal Phalynx of Purity
M[334406] = { zone = "Bastion", expansion = "Shadowlands", manualUpdate = true }  -- Eternal Phalynx of Courage
M[334408] = { zone = "Bastion", expansion = "Shadowlands", manualUpdate = true }  -- Eternal Phalynx of Loyalty
M[334409] = { zone = "Bastion", expansion = "Shadowlands", manualUpdate = true }  -- Eternal Phalynx of Humility
M[336038] = { zone = "Maldraxxus", expansion = "Shadowlands", manualUpdate = true }  -- Callow Flayedwing
M[339588] = { zone = "Revendreth", expansion = "Shadowlands", manualUpdate = true }  -- Sinrunner Blanchy
M[339957] = { zone = "Sanctum of Domination", expansion = "Shadowlands", manualUpdate = true }  -- Hand of Hrestimorak
M[344577] = { zone = "The Maw", expansion = "Shadowlands", manualUpdate = true }  -- Bound Shadehound
M[346141] = { zone = "Plaguefall", manualUpdate = true }  -- Slime Serpent
M[350219] = { zone = "The Waking Shores", expansion = "Dragonflight", manualUpdate = true }  -- Magmashell
M[353265] = { zone = "Shadow Point", expansion = "TWW", manualUpdate = true }  -- Vandal's Gearglider
M[353856] = { zone = "Ardenweald", expansion = "Shadowlands", manualUpdate = true }  -- Ardenweald Wilderling
M[353872] = { zone = "Revendreth", expansion = "Shadowlands", manualUpdate = true }  -- Sinfall Gravewing
M[353875] = { zone = "Bastion", expansion = "Shadowlands", manualUpdate = true }  -- Elysian Aquilon
M[353883] = { zone = "Maldraxxus", expansion = "Shadowlands", manualUpdate = true }  -- Maldraxxian Corpsefly
M[354354] = { zone = "The Maw", expansion = "Shadowlands", manualUpdate = true }  -- Hand of Nilganihmaht
M[354355] = { zone = "Korthia and The Maw", expansion = "Shadowlands", manualUpdate = true }  -- Hand of Salaranga
M[354358] = { zone = "Korthia", expansion = "Shadowlands", manualUpdate = true }  -- Darkmaul
M[354361] = { zone = "Korthia", expansion = "Shadowlands", manualUpdate = true }  -- Dusklight Razorwing
M[354362] = { zone = "Korthia", expansion = "Shadowlands", manualUpdate = true }  -- Maelie, the Wanderer
M[363701] = { zone = "Zereth Mortis", expansion = "Shadowlands", manualUpdate = true }  -- Patient Bufonid
M[369666] = { zone = "Blackrock Depths", expansion = "Classic", manualUpdate = true }  -- Grimhowl
M[370620] = { zone = "Ghostlands", expansion = "Classic", manualUpdate = true }  -- Elusive Emerald Hawkstrider
M[374247] = { zone = "Ohn'ahran Plains", expansion = "Dragonflight", manualUpdate = true }  -- Lizi, Thunderspine Tramper
M[395644] = { zone = "Ohn'ahran Plains", expansion = "Dragonflight", manualUpdate = true }  -- Divine Kiss of Ohn'ahra
M[404018] = { zone = "Valdrakken", expansion = "Dragonflight", manualUpdate = true }  -- Black-Furred Bakar
M[408313] = { zone = "Zaralek Cavern", expansion = "Dragonflight", manualUpdate = true }  -- Big Slick in the City
M[412088] = { zone = "Emerald Dream", expansion = "Dragonflight", manualUpdate = true }  -- Grotto Netherwing Drake
M[413922] = { zone = "Naxxramas", expansion = "WotLK", manualUpdate = true }  -- Valiance
M[425338] = { zone = "Emerald Dream", expansion = "Dragonflight", manualUpdate = true }  -- Flourishing Whimsydrake
M[427041] = { zone = "Emerald Dream", expansion = "Dragonflight", manualUpdate = true }  -- Ochre Dreamtalon
M[428068] = { zone = "Vision of Orgrimmar (Revisited)", expansion = "Classic", manualUpdate = true }  -- Voidfire Deathcycle
M[430225] = { zone = "Gilneas", expansion = "Cataclysm", manualUpdate = true }  -- Gilnean Prowler
M[431049] = { zone = "Emerald Dream", expansion = "Dragonflight", manualUpdate = true }  -- Grotto Netherwing Drake
M[431050] = { zone = "Emerald Dream", expansion = "Dragonflight", manualUpdate = true }  -- Flourishing Whimsydrake
M[442358] = { zone = "The Ringing Deeps", expansion = "TWW", manualUpdate = true }  -- Stonevault Mechsuit
M[446052] = { zone = "Isle of Dorn", expansion = "TWW", manualUpdate = true }  -- Delver's Dirigible
M[447189] = { zone = "Vision of Orgrimmar (Revisited)", expansion = "Classic", manualUpdate = true }  -- Nesting Swarmite
M[448680] = { zone = "Azj-Kahet", manualUpdate = true }  -- Widow's Undercrawler
M[448685] = { zone = "Azj-Kahet", manualUpdate = true }  -- Heritage Undercrawler
M[448689] = { zone = "Azj-Kahet", manualUpdate = true }  -- Royal Court Undercrawler
M[449264] = { zone = "Darkflame Cleft (Mythic)", expansion = "TWW", manualUpdate = true }  -- Wick
M[451489] = { zone = "City of Threads", expansion = "TWW", manualUpdate = true }  -- Siesbarg
M[466027] = { zone = "Undermine", expansion = "TWW", manualUpdate = true }  -- Darkfuse Spy-Eye
M[1218306] = { zone = "Vision of Orgrimmar (Revisited)", expansion = "Classic", manualUpdate = true }  -- Void-Scarred Pack Mother
M[1218307] = { zone = "Vision of Orgrimmar (Revisited)", expansion = "Classic", manualUpdate = true }  -- Void-Scarred Windrider
M[1221132] = { zone = "K'aresh", expansion = "TWW", manualUpdate = true }  -- Resplendent K'arroc
M[1224048] = { zone = "Isle of Dorn", expansion = "TWW", manualUpdate = true }  -- Delver's Mana-Skimmer
M[1233542] = { zone = "Shadow Point", expansion = "TWW", manualUpdate = true }  -- The Bone Freezer
M[1233559] = { zone = "K'aresh", expansion = "TWW", manualUpdate = true }  -- Blue Barry
M[1241070] = { zone = "Tazavesh", expansion = "Midnight", manualUpdate = true }  -- Translocated Gorger
M[1242904] = { zone = "March on Quel'Danas (Mythic)", expansion = "Midnight", manualUpdate = true }  -- Ashes of Belo'ren
M[1243582] = { zone = "Harandar", expansion = "Midnight", manualUpdate = true }  -- Dusk Grimlynx
M[1260356] = { zone = "Harandar", expansion = "Midnight", manualUpdate = true }  -- Echo of Aln'sharan
M[1261293] = { zone = "Isle of Quel'Danas", expansion = "Midnight", manualUpdate = true }  -- Peridot Dragonhawk
M[1261332] = { zone = "Masters' Perch", expansion = "Midnight", manualUpdate = true }  -- Duskbrute Harrower
M[1261668] = { zone = "Dalaran", expansion = "TWW", manualUpdate = true }  -- Bronze Wilderling
M[1261671] = { zone = "Dalaran", expansion = "TWW", manualUpdate = true }  -- Bronze Aquilon
M[1261677] = { zone = "Dalaran", expansion = "TWW", manualUpdate = true }  -- Bronze Corpsefly
M[1261681] = { zone = "Dalaran", expansion = "TWW", manualUpdate = true }  -- Bronze Gravewing
M[1265785] = { zone = "Silvermoon City", expansion = "Midnight", manualUpdate = true }  -- Emerald Hawkstrider
M[1284973] = { zone = "Sporefall", expansion = "Midnight", manualUpdate = true }  -- Luminous Sporeglider
