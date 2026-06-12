-- Data/Mounts_Meta.lua
-- Gerado por tools/enrich_meta.py. Overlay de METADADOS por spellID
-- (map/zona + expansao) p/ os filtros de TODAS as montarias -- inclusive
-- nao-curadas. Nao afeta status/glow.
local ADDON, ns = ...
ns.Meta = ns.Meta or {}
local M = ns.Meta
M[17481] = { zone = "Stratholme" }  -- Rivendare's Deathcharger
M[60002] = { map = 120 }  -- Time-Lost Proto-Drake
M[88718] = { map = 207 }  -- Phosphorescent Stone Drake
M[88741] = { map = 245 }  -- Drake of the West Wind
M[92155] = { expansion = "Cataclysm" }  -- Ultramarine Qiraji Battle Tank
M[107842] = { zone = "Dragon Soul" }  -- Blazing Drake
M[110039] = { zone = "Dragon Soul" }  -- Experiment 12-B
M[127271] = { zone = "Lunarfall" }  -- Crimson Water Strider
M[142641] = { zone = "Brawl'gar Arena" }  -- Brawler's Burly Mushan Beast
M[148396] = { expansion = "MoP" }  -- Kor'kron War Wolf
M[171621] = { zone = "Blackrock Foundry" }  -- Ironhoof Destroyer
M[171826] = { expansion = "WoD" }  -- Mudback Riverbeast
M[171832] = { zone = "Nazjatar" }  -- Breezestrider Stallion
M[171844] = { expansion = "WoD" }  -- Dustmane Direwolf
M[171846] = { zone = "Stormwind City" }  -- Champion's Treadblade
M[175700] = { expansion = "WoD" }  -- Emerald Drake
M[180545] = { expansion = "WoD" }  -- Mystic Runesaber
M[189999] = { expansion = "WoD" }  -- Grove Warden
M[213339] = { expansion = "Legion" }  -- Great Northern Elderhorn
M[215545] = { map = 1961 }  -- Mastercraft Gravewing
M[229376] = { expansion = "Legion" }  -- Archmage's Prismatic Disc
M[229377] = { expansion = "Legion" }  -- High Priest's Lightsworn Seeker
M[229385] = { expansion = "Legion" }  -- Ban-Lu, Grandmaster's Companion
M[229386] = { expansion = "Legion" }  -- Huntmaster's Loyal Wolfhawk
M[229387] = { expansion = "Legion" }  -- Deathlord's Vilebrood Vanquisher
M[229388] = { expansion = "Legion" }  -- Battlelord's Bloodthirsty War Wyrm
M[229438] = { map = 739 }  -- Huntmaster's Fierce Wolfhawk
M[229439] = { map = 739 }  -- Huntmaster's Dire Wolfhawk
M[231434] = { expansion = "Legion" }  -- Shadowblade's Murderous Omen
M[231435] = { expansion = "Legion" }  -- Highlord's Golden Charger
M[231523] = { zone = "Dalaran" }  -- Shadowblade's Lethal Omen
M[231524] = { zone = "Dalaran" }  -- Shadowblade's Baneful Omen
M[231525] = { zone = "Dalaran" }  -- Shadowblade's Crimson Omen
M[231587] = { zone = "Eastern Plaguelands" }  -- Highlord's Vengeful Charger
M[231588] = { zone = "Eastern Plaguelands" }  -- Highlord's Vigilant Charger
M[231589] = { zone = "Eastern Plaguelands" }  -- Highlord's Valorous Charger
M[232412] = { expansion = "Legion" }  -- Netherlord's Chaotic Wrathsteed
M[238452] = { zone = "Dalaran" }  -- Netherlord's Brimstone Wrathsteed
M[238454] = { map = 646 }  -- Netherlord's Accursed Wrathsteed
M[243512] = { expansion = "Legion" }  -- Luminous Starseeker
M[243651] = { zone = "Antorus, the Burning Throne" }  -- Shackled Ur'zul
M[247448] = { zone = "Darkmoon Island" }  -- Darkmoon Dirigible
M[253711] = { expansion = "Legion" }  -- Pond Nettle
M[254813] = { zone = "Freehold" }  -- Sharkbait
M[255696] = { expansion = "BfA" }  -- Gilded Ravasaur
M[259395] = { expansion = "BfA" }  -- Shu-Zen, the Divine Sentinel
M[273541] = { zone = "The Underrot" }  -- Underrot Crawg
M[279474] = { zone = "Dazar'alor" }  -- Palehide Direhorn
M[281554] = { expansion = "BfA" }  -- Meat Wagon
M[288499] = { map = 62, expansion = "BfA" }  -- Frightened Kodo
M[288505] = { zone = "Darkshore" }  -- Kaldorei Nightsaber
M[288714] = { zone = "Dazar'alor" }  -- Bloodthirsty Dreadwing
M[289083] = { zone = "Battle of Dazar'alor" }  -- G.M.O.D.
M[289639] = { expansion = "BfA" }  -- Bruce
M[290132] = { expansion = "BfA" }  -- Sylverian Dreamer
M[290133] = { expansion = "BfA" }  -- Vulpine Familiar
M[290134] = { expansion = "BfA" }  -- Hogrus, Swine of Good Fortune
M[298367] = { map = 864 }  -- Mollie
M[299158] = { zone = "Operation: Mechagon" }  -- Mechagon Peacekeeper
M[300150] = { zone = "Nazjatar", expansion = "BfA" }  -- Fabious
M[302143] = { expansion = "BfA" }  -- Uncorrupted Voidwing
M[308078] = { expansion = "BfA" }  -- Squeakers, the Trickster
M[308814] = { zone = "Ny'alotha, the Waking City" }  -- Ny'alotha Allseer
M[312751] = { zone = "The Ruby Sanctum" }  -- Clutch of Ha-Li
M[312777] = { expansion = "Shadowlands" }  -- Silvertip Dredwing
M[315132] = { expansion = "Dragonflight" }  -- Gargantuan Grrloc
M[315847] = { map = 1527 }  -- Drake of the Four Winds
M[315987] = { zone = "Vision of Stormwind" }  -- Mail Muncher
M[316276] = { zone = "Thaldraszus" }  -- Wastewander Skyterror
M[316340] = { zone = "Timeless Isle" }  -- Wicked Swarmer
M[317177] = { expansion = "Shadowlands" }  -- Sunwarmed Furline
M[326390] = { expansion = "BfA" }  -- Steamscale Incinerator
M[334365] = { expansion = "Shadowlands" }  -- Pale Acidmaw
M[336036] = { zone = "The Necrotic Wake" }  -- Marrowfang
M[336039] = { expansion = "Shadowlands" }  -- Gruesome Flayedwing
M[336042] = { map = 1536 }  -- Hulking Deathroc
M[336064] = { expansion = "Shadowlands" }  -- Dauntless Duskrunner
M[341821] = { expansion = "Shadowlands" }  -- Snowstorm
M[342335] = { map = 1533 }  -- Ascended Skymane
M[351195] = { zone = "Undercity" }  -- Vengeance
M[352926] = { zone = "The Primalist Future" }  -- Skyskin Hornstrider
M[353263] = { zone = "Tazavesh, the Veiled Market" }  -- Cartel Master's Gearglider
M[353264] = { expansion = "Shadowlands" }  -- Xy Trustee's Gearglider
M[353877] = { map = 1961 }  -- Forsworn Aquilon
M[353884] = { zone = "Seat of the Primus" }  -- Regal Corpsefly
M[356488] = { expansion = "Shadowlands" }  -- Sarge's Tale
M[358072] = { expansion = "Dragonflight" }  -- Bound Blizzard
M[359231] = { expansion = "Shadowlands" }  -- Darkened Vombata
M[359232] = { expansion = "Shadowlands" }  -- Adorned Vombata
M[359317] = { expansion = "Shadowlands" }  -- Wen Lo, the River's Edge
M[359364] = { expansion = "Shadowlands" }  -- Bronzewing Vespoid
M[359366] = { expansion = "Shadowlands" }  -- Buzz
M[359373] = { expansion = "Shadowlands" }  -- Raptora Swooper
M[359376] = { expansion = "Shadowlands" }  -- Bronze Helicid
M[359377] = { expansion = "Shadowlands" }  -- Unsuccessful Prototype Fleetpod
M[359401] = { expansion = "Shadowlands" }  -- Genesis Crawler
M[359545] = { expansion = "Shadowlands" }  -- Carcinized Zerethsteed
M[363703] = { expansion = "Shadowlands" }  -- Prototype Leaper
M[363706] = { expansion = "Shadowlands" }  -- Russet Bufonid
M[368158] = { zone = "Sepulcher of the First Ones" }  -- Zereth Overseer
M[369476] = { expansion = "Dragonflight" }  -- Amalgam of Rage
M[370770] = { expansion = "Shadowlands" }  -- Tuskarr Shoreglider
M[376873] = { expansion = "Dragonflight" }  -- Otto
M[400976] = { expansion = "Dragonflight" }  -- Gleaming Moonbeast
M[408654] = { zone = "Dalaran" }  -- Sandy Shalewing
M[414323] = { zone = "Thaldraszus" }  -- Ravenous Black Gryphon
M[417888] = { expansion = "Dragonflight" }  -- Algarian Stormrider
M[419567] = { expansion = "Dragonflight" }  -- Ginormous Grrloc
M[424484] = { zone = "Amirdrassil, the Dream's Hope" }  -- Anu'relos, Flame's Guidance
M[441325] = { zone = "Dalaran" }  -- Remembered Wind Rider
M[447405] = { expansion = "TWW" }  -- Vicious Skyflayer
M[449258] = { map = 2214 }  -- Ol' Mole Rufus
M[451486] = { zone = "Nerub-ar Palace" }  -- Sureki Skyrazor
M[451491] = { zone = "Nerub-ar Palace" }  -- Ascendant Skyrazor
M[463025] = { expansion = "TWW" }  -- Gigantic Grrloc
M[466000] = { zone = "Liberation of Undermine" }  -- Darkfuse Chompactor
M[466011] = { zone = "Liberation of Undermine" }  -- Flarendo the Furious
M[466012] = { zone = "Liberation of Undermine" }  -- Thunderdrum Misfire
M[466145] = { expansion = "TWW" }  -- Vicious Electro Eel
M[468205] = { expansion = "TWW" }  -- Timbered Sky Snake
M[471538] = { zone = "Dalaran" }  -- Timely Buzzbee
M[472253] = { zone = "Shattrath City" }  -- Lunar Launcher
M[1217760] = { zone = "Liberation of Undermine" }  -- The Big G
M[1218013] = { zone = "Shadowfang Keep" }  -- Spring Butterfly
M[1218069] = { expansion = "TWW" }  -- Emerald Snail
M[1218229] = { zone = "Vision of Stormwind" }  -- Void-Scarred Gryphon
M[1218305] = { zone = "Vision of Stormwind" }  -- Void-Forged Stallion
M[1218317] = { expansion = "TWW" }  -- Void-Crystal Panther
M[1221155] = { zone = "Liberation of Undermine" }  -- Prototype A.S.M.R.
M[1223187] = { zone = "Tazavesh, the Veiled Market" }  -- Terror of the Wastes
M[1227076] = { expansion = "TWW" }  -- Tyrannotort
M[1228865] = { expansion = "TWW" }  -- Void-Scarred Lynx
M[1233546] = { zone = "Tazavesh, the Veiled Market" }  -- Ruby Void Creeper
M[1233925] = { expansion = "TWW" }  -- Lana'thel's Crimson Cascade
M[1234573] = { zone = "Netherstorm" }  -- Unbound Star-Eater
M[1234821] = { expansion = "TWW" }  -- Vicious Void Creeper
M[1234971] = { expansion = "TWW" }  -- Grandiose Grrloc
M[1237631] = { zone = "Boralus" }  -- Moonlit Nightsaber
M[1237703] = { zone = "Boralus" }  -- Ivory Savagemane
M[1247662] = { zone = "Blackrock Depths" }  -- Brewfest Bomber
M[1261576] = { map = 2437 }  -- Hexed Vilefeather Eagle
M[1261584] = { zone = "Masters' Perch" }  -- Prowling Shredclaw
M[1261585] = { zone = "Masters' Perch" }  -- Frenzied Shredclaw
M[1263387] = { zone = "Oribos" }  -- Crimson Lupine
M[1263635] = { zone = "Windrunner Spire" }  -- Spectral Hawkstrider
M[1264988] = { zone = "Oribos" }  -- Snowpaw Glimmerfur Prowler
M[1265784] = { zone = "Magisters' Terrace" }  -- Lucent Hawkstrider
M[1296731] = { zone = "Silvermoon City" }  -- Cerulean Deathwalker
M[1296734] = { zone = "Silvermoon City" }  -- Amethyst Mechsuit
M[1296756] = { zone = "Silvermoon City" }  -- Blue-Chip Shreddertank
M[1296758] = { zone = "Silvermoon City" }  -- Profit-Green Shreddertank
M[1296759] = { zone = "Silvermoon City" }  -- High-Yield Shreddertank
M[1296760] = { zone = "Silvermoon City" }  -- Speculative Shreddertank
