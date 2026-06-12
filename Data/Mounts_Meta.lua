-- Data/Mounts_Meta.lua
-- Gerado por tools/enrich_meta.py. Overlay de METADADOS por spellID
-- (map/zona + expansao) p/ os filtros de TODAS as montarias -- inclusive
-- nao-curadas. Nao afeta status/glow.
local ADDON, ns = ...
ns.Meta = ns.Meta or {}
local M = ns.Meta
M[458] = { map = 56 }  -- Brown Horse
M[459] = { map = 85 }  -- Gray Wolf
M[470] = { map = 84 }  -- Black Stallion
M[472] = { map = 84 }  -- Pinto
M[578] = { map = 85 }  -- Black Wolf
M[580] = { map = 85 }  -- Timber Wolf
M[3363] = { expansion = "Midnight" }  -- Nether-Swept Drake
M[6648] = { map = 84 }  -- Chestnut Mare
M[6653] = { map = 85 }  -- Dire Wolf
M[6654] = { map = 85 }  -- Brown Wolf
M[6777] = { map = 27 }  -- Gray Ram
M[6896] = { expansion = "Classic" }  -- Black Ram
M[6898] = { map = 27 }  -- White Ram
M[6899] = { map = 27 }  -- Brown Ram
M[8394] = { map = 89 }  -- Striped Frostsaber
M[8395] = { map = 1 }  -- Emerald Raptor
M[10789] = { map = 89 }  -- Spotted Frostsaber
M[10793] = { map = 89 }  -- Striped Nightsaber
M[10796] = { map = 1 }  -- Turquoise Raptor
M[10799] = { map = 1 }  -- Violet Raptor
M[10873] = { map = 27 }  -- Red Mechanostrider
M[10969] = { map = 27 }  -- Blue Mechanostrider
M[15779] = { expansion = "Classic" }  -- White Mechanostrider Mod B
M[15780] = { map = 27 }  -- Green Mechanostrider
M[16056] = { expansion = "Classic" }  -- Ancient Frostsaber
M[17229] = { map = 83 }  -- Winterspring Frostsaber
M[17453] = { map = 27 }  -- Green Mechanostrider
M[17454] = { map = 27 }  -- Unpainted Mechanostrider
M[17459] = { expansion = "Classic" }  -- Icy Blue Mechanostrider Mod A
M[17460] = { expansion = "Classic" }  -- Frost Ram
M[17461] = { expansion = "Classic" }  -- Black Ram
M[17462] = { map = 18, expansion = "Classic" }  -- Red Skeletal Horse
M[17463] = { map = 18, expansion = "Classic" }  -- Blue Skeletal Horse
M[17464] = { map = 18, expansion = "Classic" }  -- Brown Skeletal Horse
M[17465] = { map = 18, expansion = "Classic" }  -- Green Skeletal Warhorse
M[17481] = { zone = "Stratholme" }  -- Rivendare's Deathcharger
M[18989] = { map = 7 }  -- Gray Kodo
M[18990] = { map = 7 }  -- Brown Kodo
M[18991] = { expansion = "Classic" }  -- Green Kodo
M[18992] = { expansion = "Classic" }  -- Teal Kodo
M[22717] = { map = 84 }  -- Black War Steed
M[22718] = { map = 85 }  -- Black War Kodo
M[22719] = { map = 84 }  -- Black Battlestrider
M[22720] = { map = 84 }  -- Black War Ram
M[22721] = { map = 85 }  -- Black War Raptor
M[22722] = { map = 85 }  -- Red Skeletal Warhorse
M[22723] = { map = 84 }  -- Black War Tiger
M[22724] = { map = 85 }  -- Black War Wolf
M[23214] = { expansion = "Legion" }  -- Charger
M[23219] = { map = 89 }  -- Swift Mistsaber
M[23221] = { map = 89 }  -- Swift Frostsaber
M[23222] = { map = 27 }  -- Swift Yellow Mechanostrider
M[23223] = { map = 27 }  -- Swift White Mechanostrider
M[23225] = { map = 27 }  -- Swift Green Mechanostrider
M[23227] = { map = 84 }  -- Swift Palomino
M[23228] = { map = 84 }  -- Swift White Steed
M[23229] = { map = 84 }  -- Swift Brown Steed
M[23238] = { map = 27 }  -- Swift Brown Ram
M[23239] = { map = 27 }  -- Swift Gray Ram
M[23240] = { map = 27 }  -- Swift White Ram
M[23241] = { map = 1 }  -- Swift Blue Raptor
M[23242] = { map = 1 }  -- Swift Olive Raptor
M[23243] = { map = 1 }  -- Swift Orange Raptor
M[23246] = { map = 18, expansion = "Classic" }  -- Purple Skeletal Warhorse
M[23247] = { map = 7 }  -- Great White Kodo
M[23248] = { map = 7 }  -- Great Gray Kodo
M[23249] = { map = 7 }  -- Great Brown Kodo
M[23250] = { map = 85 }  -- Swift Brown Wolf
M[23251] = { map = 85 }  -- Swift Timber Wolf
M[23252] = { map = 85 }  -- Swift Gray Wolf
M[23338] = { map = 89 }  -- Swift Stormsaber
M[23509] = { map = 25 }  -- Frostwolf Howler
M[23510] = { map = 25 }  -- Stormpike Battle Charger
M[24242] = { zone = "Zul'Gurub" }  -- Swift Razzashi Raptor
M[24252] = { expansion = "Classic" }  -- Swift Zulian Tiger
M[28828] = { map = 104 }  -- Nether Drake
M[30174] = { zone = "The Cape of Stranglethorn", expansion = "TBC" }  -- Riding Turtle
M[32235] = { map = 84 }  -- Golden Gryphon
M[32239] = { map = 84 }  -- Ebon Gryphon
M[32240] = { map = 84 }  -- Snowy Gryphon
M[32242] = { map = 84 }  -- Swift Blue Gryphon
M[32243] = { map = 85 }  -- Tawny Wind Rider
M[32244] = { map = 85 }  -- Blue Wind Rider
M[32245] = { map = 85 }  -- Green Wind Rider
M[32246] = { map = 85 }  -- Swift Red Wind Rider
M[32289] = { map = 84 }  -- Swift Red Gryphon
M[32290] = { map = 84 }  -- Swift Green Gryphon
M[32292] = { map = 84 }  -- Swift Purple Gryphon
M[32295] = { map = 85 }  -- Swift Green Wind Rider
M[32296] = { map = 85 }  -- Swift Yellow Wind Rider
M[32297] = { map = 85 }  -- Swift Purple Wind Rider
M[33630] = { map = 27 }  -- Blue Mechanostrider
M[33660] = { zone = "Eversong Woods (Burning Crusade)" }  -- Swift Pink Hawkstrider
M[34406] = { zone = "The Exodar", expansion = "TBC" }  -- Brown Elekk
M[34795] = { zone = "Eversong Woods (Burning Crusade)" }  -- Red Hawkstrider
M[34896] = { map = 107 }  -- Cobalt War Talbuk
M[34897] = { map = 107 }  -- White War Talbuk
M[34898] = { map = 107 }  -- Silver War Talbuk
M[34899] = { map = 107 }  -- Tan War Talbuk
M[35018] = { zone = "Eversong Woods (Burning Crusade)" }  -- Purple Hawkstrider
M[35020] = { zone = "Eversong Woods (Burning Crusade)" }  -- Blue Hawkstrider
M[35022] = { zone = "Eversong Woods (Burning Crusade)" }  -- Black Hawkstrider
M[35025] = { zone = "Eversong Woods (Burning Crusade)" }  -- Swift Green Hawkstrider
M[35027] = { zone = "Eversong Woods (Burning Crusade)" }  -- Swift Purple Hawkstrider
M[35028] = { map = 85 }  -- Swift Warstrider
M[35710] = { zone = "The Exodar", expansion = "TBC" }  -- Gray Elekk
M[35711] = { zone = "The Exodar", expansion = "TBC" }  -- Purple Elekk
M[35712] = { zone = "The Exodar", expansion = "TBC" }  -- Great Green Elekk
M[35713] = { zone = "The Exodar", expansion = "TBC" }  -- Great Blue Elekk
M[35714] = { zone = "The Exodar", expansion = "TBC" }  -- Great Purple Elekk
M[36702] = { zone = "Karazhan" }  -- Fiery Warhorse
M[37015] = { expansion = "TBC" }  -- Swift Nether Drake
M[39315] = { map = 107 }  -- Cobalt Riding Talbuk
M[39317] = { map = 107 }  -- Silver Riding Talbuk
M[39318] = { map = 107 }  -- Tan Riding Talbuk
M[39319] = { map = 107 }  -- White Riding Talbuk
M[39798] = { map = 108 }  -- Green Riding Nether Ray
M[39800] = { map = 108 }  -- Red Riding Nether Ray
M[39801] = { map = 108 }  -- Purple Riding Nether Ray
M[39802] = { map = 108 }  -- Silver Riding Nether Ray
M[39803] = { map = 108 }  -- Blue Riding Nether Ray
M[40192] = { zone = "The Eye" }  -- Ashes of Al'ar
M[41252] = { zone = "Sethekk Halls", expansion = "TBC" }  -- Raven Lord
M[41517] = { zone = "Shadowmoon Valley" }  -- Veridian Netherwing Drake
M[42776] = { zone = "The Cape of Stranglethorn", expansion = "WotLK" }  -- Spectral Tiger
M[42777] = { zone = "The Cape of Stranglethorn", expansion = "WotLK" }  -- Swift Spectral Tiger
M[43688] = { expansion = "TBC" }  -- Amani War Bear
M[43899] = { expansion = "TBC" }  -- Brewfest Ram
M[43900] = { expansion = "TBC" }  -- Swift Brewfest Ram
M[44151] = { expansion = "TBC" }  -- Turbo-Charged Flying Machine
M[44153] = { expansion = "TBC" }  -- Flying Machine
M[44317] = { expansion = "TBC" }  -- Merciless Nether Drake
M[44744] = { expansion = "TBC" }  -- Merciless Nether Drake
M[46197] = { zone = "The Cape of Stranglethorn", expansion = "WotLK" }  -- X-51 Nether-Rocket
M[46199] = { zone = "The Cape of Stranglethorn", expansion = "WotLK" }  -- X-51 Nether-Rocket X-TREME
M[46628] = { zone = "The Eye", expansion = "TBC" }  -- Swift White Hawkstrider
M[48027] = { map = 84 }  -- Black War Elekk
M[48954] = { expansion = "TBC" }  -- Swift Zhevra
M[49193] = { expansion = "TBC" }  -- Vengeful Nether Drake
M[49322] = { expansion = "TBC" }  -- Swift Zhevra
M[49379] = { expansion = "TBC" }  -- Great Brewfest Kodo
M[51412] = { zone = "The Cape of Stranglethorn", expansion = "WotLK" }  -- Big Battle Bear
M[54729] = { map = 23 }  -- Winged Steed of the Ebon Blade
M[55531] = { expansion = "WotLK" }  -- Mechano-Hog
M[58615] = { expansion = "TBC" }  -- Brutal Nether Drake
M[58983] = { expansion = "TBC" }  -- Big Blizzard Bear
M[59567] = { expansion = "WotLK" }  -- Azure Drake
M[59568] = { expansion = "WotLK" }  -- Blue Drake
M[59569] = { zone = "The Culling of Stratholme" }  -- Bronze Drake
M[59570] = { map = 115 }  -- Red Drake
M[59571] = { zone = "The Obsidian Sanctum", expansion = "WotLK" }  -- Twilight Drake
M[59650] = { zone = "The Obsidian Sanctum", expansion = "WotLK" }  -- Black Drake
M[59785] = { map = 123 }  -- Black War Mammoth
M[59788] = { map = 123 }  -- Black War Mammoth
M[59791] = { zone = "Dalaran" }  -- Wooly Mammoth
M[59793] = { zone = "Dalaran" }  -- Wooly Mammoth
M[59797] = { map = 120 }  -- Ice Mammoth
M[59799] = { map = 120 }  -- Ice Mammoth
M[59961] = { expansion = "WotLK" }  -- Red Proto-Drake
M[59976] = { expansion = "WotLK" }  -- Black Proto-Drake
M[59996] = { zone = "Utgarde Pinnacle", expansion = "WotLK" }  -- Blue Proto-Drake
M[60002] = { map = 120 }  -- Time-Lost Proto-Drake
M[60021] = { expansion = "WotLK" }  -- Plagued Proto-Drake
M[60024] = { expansion = "WotLK" }  -- Violet Proto-Drake
M[60025] = { expansion = "WotLK" }  -- Albino Drake
M[60114] = { zone = "Dalaran" }  -- Armored Brown Bear
M[60116] = { zone = "Dalaran" }  -- Armored Brown Bear
M[60118] = { expansion = "WotLK" }  -- Black War Bear
M[60119] = { expansion = "WotLK" }  -- Black War Bear
M[60424] = { expansion = "WotLK" }  -- Mekgineer's Chopper
M[61229] = { zone = "Dalaran" }  -- Armored Snowy Gryphon
M[61230] = { zone = "Dalaran" }  -- Armored Blue Wind Rider
M[61294] = { expansion = "WotLK" }  -- Green Proto-Drake
M[61309] = { expansion = "WotLK" }  -- Magnificent Flying Carpet
M[61425] = { zone = "Dalaran" }  -- Traveler's Tundra Mammoth
M[61447] = { zone = "Dalaran" }  -- Traveler's Tundra Mammoth
M[61451] = { expansion = "WotLK" }  -- Flying Carpet
M[61465] = { expansion = "WotLK" }  -- Grand Black War Mammoth
M[61467] = { expansion = "WotLK" }  -- Grand Black War Mammoth
M[61469] = { map = 120 }  -- Grand Ice Mammoth
M[61470] = { map = 120 }  -- Grand Ice Mammoth
M[61996] = { expansion = "WotLK" }  -- Blue Dragonhawk
M[61997] = { expansion = "WotLK" }  -- Red Dragonhawk
M[62048] = { zone = "Shadowmoon Valley" }  -- Illidari Doomhawk
M[63232] = { map = 118 }  -- Stormwind Steed
M[63635] = { map = 118 }  -- Darkspear Raptor
M[63636] = { map = 118 }  -- Ironforge Ram
M[63637] = { map = 118 }  -- Darnassian Nightsaber
M[63638] = { map = 118 }  -- Gnomeregan Mechanostrider
M[63639] = { map = 118 }  -- Exodar Elekk
M[63640] = { map = 118 }  -- Orgrimmar Wolf
M[63641] = { map = 118 }  -- Thunder Bluff Kodo
M[63642] = { map = 118 }  -- Silvermoon Hawkstrider
M[63643] = { map = 118 }  -- Forsaken Warhorse
M[63796] = { zone = "Ulduar" }  -- Mimiron's Head
M[64657] = { map = 7 }  -- White Kodo
M[64731] = { expansion = "WotLK" }  -- Sea Turtle
M[64927] = { expansion = "WotLK" }  -- Deadly Gladiator's Frost Wyrm
M[64977] = { map = 18, expansion = "WotLK" }  -- Black Skeletal Horse
M[65439] = { expansion = "WotLK" }  -- Furious Gladiator's Frost Wyrm
M[65637] = { map = 118 }  -- Great Red Elekk
M[65638] = { map = 118 }  -- Swift Moonsaber
M[65639] = { map = 118 }  -- Swift Red Hawkstrider
M[65640] = { map = 118 }  -- Swift Gray Steed
M[65641] = { map = 118 }  -- Great Golden Kodo
M[65642] = { map = 118 }  -- Turbostrider
M[65643] = { map = 118 }  -- Swift Violet Ram
M[65644] = { map = 118 }  -- Swift Purple Raptor
M[65645] = { map = 118 }  -- White Skeletal Warhorse
M[65646] = { map = 118 }  -- Swift Burgundy Wolf
M[65917] = { zone = "The Cape of Stranglethorn" }  -- Magic Rooster
M[66087] = { map = 118 }  -- Silver Covenant Hippogryph
M[66088] = { zone = "Isle of Thunder" }  -- Sunreaver Dragonhawk
M[66090] = { map = 118 }  -- Quel'dorei Steed
M[66091] = { zone = "Isle of Thunder" }  -- Sunreaver Hawkstrider
M[66122] = { zone = "The Cape of Stranglethorn" }  -- Magic Rooster
M[66123] = { zone = "The Cape of Stranglethorn" }  -- Magic Rooster
M[66124] = { zone = "The Cape of Stranglethorn" }  -- Magic Rooster
M[66846] = { map = 18, expansion = "WotLK" }  -- Ochre Skeletal Warhorse
M[66847] = { zone = "Darnassus", expansion = "WotLK" }  -- Striped Dawnsaber
M[67336] = { expansion = "WotLK" }  -- Relentless Gladiator's Frost Wyrm
M[67466] = { map = 118 }  -- Argent Warhorse
M[68056] = { expansion = "WotLK" }  -- Swift Horde Wolf
M[68057] = { expansion = "WotLK" }  -- Swift Alliance Steed
M[68187] = { expansion = "WotLK" }  -- Crusader's White Warhorse
M[68188] = { expansion = "WotLK" }  -- Crusader's Black Warhorse
M[69395] = { zone = "Onyxia's Lair" }  -- Onyxian Drake
M[69820] = { expansion = "Cataclysm" }  -- Sunwalker Kodo
M[69826] = { expansion = "Cataclysm" }  -- Great Sunwalker Kodo
M[71342] = { expansion = "WotLK" }  -- X-45 Heartbreaker
M[71810] = { expansion = "Cataclysm" }  -- Wrathful Gladiator's Frost Wyrm
M[72286] = { zone = "Icecrown Citadel" }  -- Invincible
M[73629] = { expansion = "Cataclysm" }  -- Exarch's Elekk
M[73630] = { expansion = "Cataclysm" }  -- Great Exarch's Elekk
M[74856] = { zone = "The Cape of Stranglethorn", expansion = "WotLK" }  -- Blazing Hippogryph
M[74918] = { zone = "The Cape of Stranglethorn", expansion = "WotLK" }  -- Wooly White Rhino
M[75207] = { expansion = "Cataclysm" }  -- Vashj'ir Seahorse
M[75596] = { expansion = "WotLK" }  -- Frosty Flying Carpet
M[75614] = { expansion = "WotLK" }  -- Celestial Steed
M[75973] = { expansion = "WotLK" }  -- X-53 Touring Rocket
M[84751] = { expansion = "Cataclysm" }  -- Fossilized Raptor
M[87090] = { map = 85 }  -- Goblin Trike
M[87091] = { map = 85 }  -- Goblin Turbo-Trike
M[88331] = { expansion = "Cataclysm" }  -- Volcanic Stone Drake
M[88335] = { expansion = "Cataclysm" }  -- Drake of the East Wind
M[88718] = { map = 207 }  -- Phosphorescent Stone Drake
M[88741] = { map = 245 }  -- Drake of the West Wind
M[88742] = { zone = "The Vortex Pinnacle", expansion = "Cataclysm" }  -- Drake of the North Wind
M[88744] = { zone = "Throne of the Four Winds", expansion = "Cataclysm" }  -- Drake of the South Wind
M[88746] = { zone = "The Stonecore", expansion = "Cataclysm" }  -- Vitreous Stone Drake
M[88748] = { map = 249 }  -- Brown Riding Camel
M[88749] = { map = 249 }  -- Tan Riding Camel
M[88750] = { map = 69, expansion = "Cataclysm" }  -- Grey Riding Camel
M[88990] = { expansion = "Cataclysm" }  -- Dark Phoenix
M[90621] = { expansion = "Cataclysm" }  -- Golden King
M[92155] = { expansion = "Cataclysm" }  -- Ultramarine Qiraji Battle Tank
M[92231] = { map = 245 }  -- Spectral Steed
M[93326] = { expansion = "Cataclysm" }  -- Sandstone Drake
M[93623] = { zone = "The Cape of Stranglethorn", expansion = "Cataclysm" }  -- Mottled Drake
M[93644] = { map = 85 }  -- Kor'kron Annihilator
M[96491] = { zone = "Zul'Gurub" }  -- Armored Razzashi Raptor
M[96499] = { zone = "Zul'Gurub" }  -- Swift Zulian Panther
M[96503] = { zone = "The Cape of Stranglethorn", expansion = "Cataclysm" }  -- Amani Dragonhawk
M[97359] = { expansion = "Cataclysm" }  -- Flameward Hippogryph
M[97493] = { zone = "Molten Core" }  -- Pureblood Fire Hawk
M[97501] = { expansion = "Cataclysm" }  -- Felfire Hawk
M[97581] = { zone = "The Cape of Stranglethorn", expansion = "Cataclysm" }  -- Savage Raptor
M[98204] = { zone = "Zul'Aman", expansion = "Cataclysm" }  -- Amani Battle Bear
M[98718] = { zone = "Shimmering Expanse" }  -- Subdued Seahorse
M[98727] = { expansion = "Cataclysm" }  -- Winged Guardian
M[100332] = { expansion = "Cataclysm" }  -- Vicious War Steed
M[101282] = { expansion = "Cataclysm" }  -- Vicious Gladiator's Twilight Drake
M[101542] = { zone = "Firelands" }  -- Flametalon of Alysrazor
M[101573] = { zone = "The Cape of Stranglethorn", expansion = "Cataclysm" }  -- Swift Shorestrider
M[101821] = { expansion = "Cataclysm" }  -- Ruthless Gladiator's Twilight Drake
M[102346] = { zone = "Darkmoon Island" }  -- Swift Forest Strider
M[102349] = { map = 1 }  -- Swift Springstrider
M[102350] = { map = 84 }  -- Swift Lovebird
M[102488] = { zone = "The Cape of Stranglethorn", expansion = "Cataclysm" }  -- White Riding Camel
M[102514] = { zone = "The Cape of Stranglethorn", expansion = "Cataclysm" }  -- Corrupted Hippogryph
M[103081] = { zone = "Darkmoon Island" }  -- Darkmoon Dancing Bear
M[103195] = { map = 89 }  -- Mountain Horse
M[103196] = { map = 89 }  -- Swift Mountain Horse
M[107203] = { expansion = "Cataclysm" }  -- Tyrael's Charger
M[107516] = { expansion = "Cataclysm" }  -- Spectral Gryphon
M[107517] = { expansion = "Cataclysm" }  -- Spectral Wind Rider
M[107842] = { zone = "Dragon Soul" }  -- Blazing Drake
M[107845] = { zone = "Dragon Soul" }  -- Life-Binder's Handmaiden
M[110039] = { zone = "Dragon Soul" }  -- Experiment 12-B
M[110051] = { expansion = "Cataclysm" }  -- Heart of the Aspects
M[113120] = { zone = "The Cape of Stranglethorn", expansion = "Cataclysm" }  -- Feldrake
M[118089] = { zone = "Lunarfall" }  -- Azure Water Strider
M[120043] = { expansion = "MoP" }  -- Jeweled Onyx Panther
M[120395] = { map = 85 }  -- Green Dragon Turtle
M[120822] = { map = 85 }  -- Great Red Dragon Turtle
M[121820] = { expansion = "Cataclysm" }  -- Obsidian Nightwing
M[121836] = { expansion = "MoP" }  -- Sapphire Panther
M[121837] = { expansion = "MoP" }  -- Jade Panther
M[121838] = { expansion = "MoP" }  -- Ruby Panther
M[121839] = { expansion = "MoP" }  -- Sunstone Panther
M[122708] = { map = 379, expansion = "MoP" }  -- Grand Expedition Yak
M[123886] = { map = 422 }  -- Amber Scorpion
M[124408] = { map = 84 }  -- Thundering Jade Cloud Serpent
M[124550] = { expansion = "MoP" }  -- Cataclysmic Gladiator's Twilight Drake
M[126507] = { expansion = "MoP" }  -- Depleted-Kyparium Rocket
M[126508] = { expansion = "MoP" }  -- Geosynchronous World Spinner
M[127158] = { map = 379, expansion = "MoP" }  -- Heavenly Onyx Cloud Serpent
M[127165] = { map = 554 }  -- Yu'lei, Daughter of Jade
M[127169] = { expansion = "MoP" }  -- Heavenly Azure Cloud Serpent
M[127170] = { zone = "Mogu'shan Vaults", expansion = "MoP" }  -- Astral Cloud Serpent
M[127174] = { map = 390 }  -- Azure Riding Crane
M[127176] = { map = 390 }  -- Golden Riding Crane
M[127177] = { map = 390 }  -- Regal Riding Crane
M[127216] = { map = 379, expansion = "MoP" }  -- Grey Riding Yak
M[127220] = { map = 379, expansion = "MoP" }  -- Blonde Riding Yak
M[127271] = { zone = "Lunarfall" }  -- Crimson Water Strider
M[127286] = { map = 85 }  -- Black Dragon Turtle
M[127287] = { map = 85 }  -- Blue Dragon Turtle
M[127288] = { map = 85 }  -- Brown Dragon Turtle
M[127289] = { map = 85 }  -- Purple Dragon Turtle
M[127290] = { map = 85 }  -- Red Dragon Turtle
M[127293] = { map = 85 }  -- Great Green Dragon Turtle
M[127295] = { map = 85 }  -- Great Black Dragon Turtle
M[127302] = { map = 85 }  -- Great Blue Dragon Turtle
M[127308] = { map = 85 }  -- Great Brown Dragon Turtle
M[127310] = { map = 85 }  -- Great Purple Dragon Turtle
M[129918] = { map = 390 }  -- Thundering August Cloud Serpent
M[129932] = { map = 388 }  -- Green Shado-Pan Riding Tiger
M[129934] = { map = 388 }  -- Blue Shado-Pan Riding Tiger
M[129935] = { map = 388 }  -- Red Shado-Pan Riding Tiger
M[130086] = { map = 376 }  -- Brown Riding Goat
M[130092] = { map = 390 }  -- Red Flying Cloud
M[130137] = { zone = "Valley of the Four Winds" }  -- White Riding Goat
M[130138] = { zone = "Valley of the Four Winds" }  -- Black Riding Goat
M[130965] = { map = 376 }  -- Son of Galleon
M[132036] = { map = 390 }  -- Thundering Ruby Cloud Serpent
M[133023] = { expansion = "MoP" }  -- Jade Pandaren Kite
M[134359] = { expansion = "MoP" }  -- Sky Golem
M[134573] = { expansion = "MoP" }  -- Swift Windsteed
M[135416] = { map = 418 }  -- Grand Armored Gryphon
M[136163] = { expansion = "MoP" }  -- Grand Gryphon
M[136164] = { expansion = "MoP" }  -- Grand Wyvern
M[136400] = { expansion = "MoP" }  -- Armored Skyscreamer
M[136471] = { zone = "Throne of Thunder" }  -- Spawn of Horridon
M[136505] = { zone = "The Cape of Stranglethorn", expansion = "MoP" }  -- Ghastly Charger
M[138423] = { map = 507 }  -- Cobalt Primordial Direhorn
M[138424] = { map = 422 }  -- Amber Primordial Direhorn
M[138425] = { map = 422 }  -- Slate Primordial Direhorn
M[138426] = { map = 422 }  -- Jade Primordial Direhorn
M[138641] = { expansion = "MoP" }  -- Red Primal Raptor
M[138642] = { expansion = "MoP" }  -- Black Primal Raptor
M[138643] = { expansion = "MoP" }  -- Green Primal Raptor
M[139407] = { expansion = "MoP" }  -- Malevolent Gladiator's Cloud Serpent
M[139442] = { map = 504 }  -- Thundering Cobalt Cloud Serpent
M[139448] = { zone = "Throne of Thunder" }  -- Clutch of Ji-Kun
M[139595] = { expansion = "MoP" }  -- Armored Bloodwing
M[140249] = { zone = "Icecrown" }  -- Golden Primal Direhorn
M[142073] = { expansion = "MoP" }  -- Hearthsteed
M[142266] = { expansion = "MoP" }  -- Armored Red Dragonhawk
M[142478] = { expansion = "MoP" }  -- Armored Blue Dragonhawk
M[142641] = { zone = "Brawl'gar Arena" }  -- Brawler's Burly Mushan Beast
M[142878] = { expansion = "MoP" }  -- Enchanted Fey Dragon
M[142910] = { zone = "Dalaran" }  -- Ironbound Wraithcharger
M[146615] = { map = 84 }  -- Vicious Kaldorei Warsaber
M[148396] = { expansion = "MoP" }  -- Kor'kron War Wolf
M[148417] = { zone = "Siege of Orgrimmar" }  -- Kor'kron Juggernaut
M[148428] = { map = 554 }  -- Ashhide Mushan Beast
M[148476] = { map = 554 }  -- Thundering Onyx Cloud Serpent
M[148618] = { expansion = "MoP" }  -- Tyrannical Gladiator's Cloud Serpent
M[148619] = { expansion = "MoP" }  -- Grievous Gladiator's Cloud Serpent
M[148620] = { expansion = "MoP" }  -- Prideful Gladiator's Cloud Serpent
M[149801] = { expansion = "MoP" }  -- Emerald Hippogryph
M[153489] = { expansion = "MoP" }  -- Iron Skyreaver
M[163024] = { expansion = "WoD" }  -- Warforged Nightmare
M[163025] = { expansion = "WoD" }  -- Grinning Reaver
M[169952] = { expansion = "WoD" }  -- Creeping Carpet
M[170347] = { expansion = "WoD" }  -- Core Hound
M[171616] = { zone = "Lunarfall", expansion = "WoD" }  -- Witherhide Cliffstomper
M[171617] = { expansion = "WoD" }  -- Trained Icehoof
M[171620] = { map = 550 }  -- Bloodhoof Bull
M[171621] = { zone = "Blackrock Foundry" }  -- Ironhoof Destroyer
M[171622] = { map = 550 }  -- Mottled Meadowstomper
M[171623] = { expansion = "WoD" }  -- Trained Meadowstomper
M[171625] = { zone = "Stormshield" }  -- Dusty Rockhide
M[171626] = { expansion = "WoD" }  -- Armored Irontusk
M[171628] = { zone = "Lunarfall", expansion = "WoD" }  -- Rocktusk Battleboar
M[171629] = { expansion = "WoD" }  -- Armored Frostboar
M[171633] = { map = 534 }  -- Wild Goretusk
M[171636] = { map = 525 }  -- Great Greytusk
M[171637] = { expansion = "WoD" }  -- Trained Rocktusk
M[171638] = { expansion = "WoD" }  -- Trained Riverwallow
M[171824] = { map = 535 }  -- Sapphire Riverbeast
M[171826] = { expansion = "WoD" }  -- Mudback Riverbeast
M[171828] = { zone = "Spires of Arak", expansion = "WoD" }  -- Solar Spirehawk
M[171830] = { map = 539 }  -- Swift Breezestrider
M[171831] = { expansion = "WoD" }  -- Trained Silverpelt
M[171832] = { zone = "Nazjatar" }  -- Breezestrider Stallion
M[171834] = { map = 84 }  -- Vicious War Ram
M[171838] = { expansion = "WoD" }  -- Armored Frostwolf
M[171839] = { zone = "Frostwall", expansion = "WoD" }  -- Ironside Warwolf
M[171840] = { expansion = "WoD" }  -- Coldflame Infernal
M[171841] = { expansion = "WoD" }  -- Trained Snarler
M[171842] = { zone = "Warspear" }  -- Swift Frostwolf
M[171844] = { expansion = "WoD" }  -- Dustmane Direwolf
M[171846] = { zone = "Stormwind City" }  -- Champion's Treadblade
M[171847] = { expansion = "WoD" }  -- Cindermane Charger
M[171849] = { map = 543 }  -- Sunhide Gronnling
M[171851] = { map = 525 }  -- Garn Nighthowl
M[175700] = { expansion = "WoD" }  -- Emerald Drake
M[179244] = { expansion = "WoD" }  -- Chauffeured Mechano-Hog
M[179245] = { expansion = "WoD" }  -- Chauffeured Mekgineer's Chopper
M[179478] = { zone = "Ashran", expansion = "WoD" }  -- Voidtalon of the Dark Star
M[180545] = { expansion = "WoD" }  -- Mystic Runesaber
M[182912] = { zone = "Hellfire Citadel" }  -- Felsteel Annihilator
M[183889] = { map = 84 }  -- Vicious War Mechanostrider
M[186828] = { expansion = "WoD" }  -- Primal Gladiator's Felblood Gronnling
M[189043] = { expansion = "WoD" }  -- Wild Gladiator's Felblood Gronnling
M[189044] = { expansion = "WoD" }  -- Warmongering Gladiator's Felblood Gronnling
M[189364] = { expansion = "WoD" }  -- Coalfist Gronnling
M[189998] = { expansion = "WoD" }  -- Illidari Felstalker
M[189999] = { expansion = "WoD" }  -- Grove Warden
M[190690] = { map = 534 }  -- Bristling Hellboar
M[190977] = { map = 534 }  -- Deathtusk Felboar
M[191314] = { expansion = "WoD" }  -- Minion of Grumpus
M[193007] = { expansion = "Legion" }  -- Grove Defiler
M[193695] = { expansion = "Legion" }  -- Prestigious War Steed
M[194046] = { expansion = "WoD" }  -- Swift Spectral Rylak
M[194464] = { map = 111 }  -- Eclipse Dragonhawk
M[196681] = { expansion = "Legion" }  -- Spirit of Eche'ro
M[200175] = { expansion = "Legion" }  -- Felsaber
M[201098] = { expansion = "WoD" }  -- Infinite Timereaver
M[204166] = { expansion = "Legion" }  -- Prestigious War Wolf
M[213158] = { expansion = "Legion" }  -- Predatory Bloodgazer
M[213163] = { expansion = "Legion" }  -- Snowfeather Hunter
M[213164] = { expansion = "Legion" }  -- Brilliant Direbeak
M[213165] = { expansion = "Legion" }  -- Viridian Sharptalon
M[213209] = { expansion = "Legion" }  -- Steelbound Devourer
M[213339] = { expansion = "Legion" }  -- Great Northern Elderhorn
M[213349] = { expansion = "Legion" }  -- Flarecore Infernal
M[213350] = { expansion = "Legion" }  -- Frostshard Infernal
M[215545] = { map = 1961 }  -- Mastercraft Gravewing
M[222202] = { expansion = "Legion" }  -- Prestigious Bronze Courser
M[222236] = { expansion = "Legion" }  -- Prestigious Royal Courser
M[222237] = { expansion = "Legion" }  -- Prestigious Forest Courser
M[222238] = { expansion = "Legion" }  -- Prestigious Ivory Courser
M[222240] = { expansion = "Legion" }  -- Prestigious Azure Courser
M[222241] = { expansion = "Legion" }  -- Prestigious Midnight Courser
M[223018] = { zone = "Eye of Azshara", expansion = "Legion" }  -- Fathom Dweller
M[223341] = { map = 84 }  -- Vicious Gilnean Warhorse
M[223578] = { map = 84 }  -- Vicious War Elekk
M[223814] = { expansion = "Legion" }  -- Mechanized Lumber Extractor
M[225765] = { expansion = "Legion" }  -- Leyfeather Hippogryph
M[227956] = { zone = "Dalaran", expansion = "Legion" }  -- Arcadian War Turtle
M[227986] = { expansion = "Legion" }  -- Vindictive Gladiator's Storm Dragon
M[227988] = { expansion = "Legion" }  -- Fearless Gladiator's Storm Dragon
M[227989] = { expansion = "Legion" }  -- Cruel Gladiator's Storm Dragon
M[227991] = { expansion = "Legion" }  -- Ferocious Gladiator's Storm Dragon
M[227994] = { expansion = "Legion" }  -- Fierce Gladiator's Storm Dragon
M[227995] = { expansion = "Legion" }  -- Dominant Gladiator's Storm Dragon
M[228919] = { zone = "Darkmoon Island", expansion = "Legion" }  -- Darkwater Skate
M[229376] = { expansion = "Legion" }  -- Archmage's Prismatic Disc
M[229377] = { expansion = "Legion" }  -- High Priest's Lightsworn Seeker
M[229385] = { expansion = "Legion" }  -- Ban-Lu, Grandmaster's Companion
M[229386] = { expansion = "Legion" }  -- Huntmaster's Loyal Wolfhawk
M[229387] = { expansion = "Legion" }  -- Deathlord's Vilebrood Vanquisher
M[229388] = { expansion = "Legion" }  -- Battlelord's Bloodthirsty War Wyrm
M[229417] = { expansion = "Legion" }  -- Slayer's Felbroken Shrieker
M[229438] = { map = 739 }  -- Huntmaster's Fierce Wolfhawk
M[229439] = { map = 739 }  -- Huntmaster's Dire Wolfhawk
M[229487] = { map = 84 }  -- Vicious War Bear
M[229499] = { zone = "Karazhan", expansion = "Legion" }  -- Midnight
M[229512] = { map = 84 }  -- Vicious War Lion
M[230844] = { zone = "Deeprun Tram", expansion = "Legion" }  -- Brawler's Burly Basilisk
M[231428] = { expansion = "Legion" }  -- Smoldering Ember Wyrm
M[231434] = { expansion = "Legion" }  -- Shadowblade's Murderous Omen
M[231435] = { expansion = "Legion" }  -- Highlord's Golden Charger
M[231442] = { expansion = "Legion" }  -- Farseer's Raging Tempest
M[231523] = { zone = "Dalaran" }  -- Shadowblade's Lethal Omen
M[231524] = { zone = "Dalaran" }  -- Shadowblade's Baneful Omen
M[231525] = { zone = "Dalaran" }  -- Shadowblade's Crimson Omen
M[231587] = { zone = "Eastern Plaguelands" }  -- Highlord's Vengeful Charger
M[231588] = { zone = "Eastern Plaguelands" }  -- Highlord's Vigilant Charger
M[231589] = { zone = "Eastern Plaguelands" }  -- Highlord's Valorous Charger
M[232405] = { expansion = "Legion" }  -- Primal Flamesaber
M[232412] = { expansion = "Legion" }  -- Netherlord's Chaotic Wrathsteed
M[232519] = { zone = "Tomb of Sargeras", expansion = "Legion" }  -- Abyss Worm
M[232523] = { map = 84 }  -- Vicious War Turtle
M[233364] = { expansion = "Legion" }  -- Leywoven Flying Carpet
M[235764] = { expansion = "Legion" }  -- Darkspore Mana Ray
M[237287] = { map = 864 }  -- Alabaster Hyena
M[238452] = { zone = "Dalaran" }  -- Netherlord's Brimstone Wrathsteed
M[238454] = { map = 646 }  -- Netherlord's Accursed Wrathsteed
M[239013] = { zone = "Eredath" }  -- Lightforged Warframe
M[239363] = { expansion = "Legion" }  -- Swift Spectral Hippogryph
M[239766] = { expansion = "Legion" }  -- Blue Qiraji War Tank
M[239767] = { expansion = "Legion" }  -- Red Qiraji War Tank
M[239770] = { expansion = "Legion" }  -- Black Qiraji War Tank
M[242305] = { zone = "Antoran Wastes" }  -- Sable Ruinstrider
M[242896] = { map = 84 }  -- Vicious War Fox
M[243025] = { zone = "Westfall", expansion = "Legion" }  -- Riddler's Mind-Worm
M[243201] = { expansion = "Legion" }  -- Demonic Gladiator's Storm Dragon
M[243512] = { expansion = "Legion" }  -- Luminous Starseeker
M[243651] = { zone = "Antorus, the Burning Throne" }  -- Shackled Ur'zul
M[243652] = { map = 885 }  -- Vile Fiend
M[244712] = { zone = "Dazar'alor" }  -- Spectral Pterrorwing
M[245723] = { expansion = "Legion" }  -- Stormwind Skychaser
M[245725] = { expansion = "Legion" }  -- Orgrimmar Interceptor
M[247402] = { zone = "Deadwind Pass", expansion = "Legion" }  -- Lucid Nightmare
M[247448] = { zone = "Darkmoon Island", expansion = "Legion" }  -- Darkmoon Dirigible
M[253004] = { zone = "Antoran Wastes" }  -- Amethyst Ruinstrider
M[253005] = { zone = "Antoran Wastes" }  -- Beryl Ruinstrider
M[253006] = { zone = "Antoran Wastes" }  -- Russet Ruinstrider
M[253007] = { zone = "Antoran Wastes" }  -- Cerulean Ruinstrider
M[253008] = { zone = "Antoran Wastes" }  -- Umber Ruinstrider
M[253058] = { map = 882, expansion = "Legion" }  -- Maddened Chaosrunner
M[253088] = { zone = "Antorus, the Burning Throne", expansion = "Legion" }  -- Antoran Charhound
M[253106] = { expansion = "Legion" }  -- Vibrant Mana Ray
M[253107] = { map = 882, expansion = "Legion" }  -- Lambent Mana Ray
M[253108] = { expansion = "Legion" }  -- Felglow Mana Ray
M[253109] = { expansion = "Legion" }  -- Scintillating Mana Ray
M[253661] = { map = 885 }  -- Crimson Slavermaw
M[253662] = { map = 882, expansion = "Legion" }  -- Acid Belcher
M[253711] = { expansion = "Legion" }  -- Pond Nettle
M[254259] = { expansion = "Legion" }  -- Avenging Felcrusher
M[254260] = { expansion = "Legion" }  -- Bleakhoof Ruinstrider
M[254812] = { expansion = "BfA" }  -- Royal Seafeather
M[254813] = { zone = "Freehold" }  -- Sharkbait
M[255695] = { expansion = "BfA" }  -- Seabraid Stallion
M[255696] = { expansion = "BfA" }  -- Gilded Ravasaur
M[256123] = { expansion = "BfA" }  -- Xiwyllag ATV
M[258022] = { expansion = "Legion" }  -- Lightforged Felcrusher
M[258845] = { expansion = "Legion" }  -- Nightborne Manasaber
M[259202] = { expansion = "Legion" }  -- Starcursed Voidstrider
M[259395] = { expansion = "BfA" }  -- Shu-Zen, the Divine Sentinel
M[260172] = { map = 942 }  -- Dapple Gray
M[260173] = { map = 896 }  -- Smoky Charger
M[261395] = { expansion = "BfA" }  -- The Hivemind
M[261433] = { map = 84 }  -- Vicious War Basilisk
M[261437] = { expansion = "BfA" }  -- Mecha-Mogul Mk2
M[262022] = { expansion = "BfA" }  -- Dread Gladiator's Proto-Drake
M[262023] = { expansion = "BfA" }  -- Sinister Gladiator's Proto-Drake
M[262024] = { expansion = "BfA" }  -- Notorious Gladiator's Proto-Drake
M[262027] = { expansion = "BfA" }  -- Corrupted Gladiator's Proto-Drake
M[264058] = { zone = "Dazar'alor" }  -- Mighty Caravan Brutosaur
M[266058] = { zone = "Kings' Rest", expansion = "BfA" }  -- Tomb Stalker
M[267274] = { expansion = "BfA" }  -- Mag'har Direwolf
M[270562] = { expansion = "BfA" }  -- Darkforge Ram
M[270564] = { expansion = "BfA" }  -- Dawnforge Ram
M[271646] = { expansion = "BfA" }  -- Dark Iron Core Hound
M[272472] = { expansion = "BfA" }  -- Undercity Plaguebat
M[272481] = { map = 84 }  -- Vicious War Riverbeast
M[272770] = { expansion = "BfA" }  -- The Dreadwake
M[273541] = { zone = "The Underrot" }  -- Underrot Crawg
M[274610] = { expansion = "BfA" }  -- Teldrassil Hippogryph
M[275623] = { zone = "Saltstone Mine" }  -- Nazjatar Blood Serpent
M[275837] = { zone = "Dazar'alor" }  -- Cobalt Pterrordax
M[275838] = { map = 863 }  -- Captured Swampstalker
M[275840] = { map = 864 }  -- Voldunai Dunescraper
M[275841] = { map = 863 }  -- Expedition Bloodswarmer
M[275859] = { map = 896 }  -- Dusky Waycrest Gryphon
M[275866] = { map = 942 }  -- Stormsong Coastwatcher
M[278803] = { expansion = "BfA" }  -- Great Sea Ray
M[278966] = { expansion = "BfA" }  -- Fiery Hearthsteed
M[279456] = { map = 14, expansion = "BfA" }  -- Highland Mustang
M[279469] = { expansion = "BfA" }  -- Qinsho's Eternal Hound
M[279474] = { zone = "Dazar'alor" }  -- Palehide Direhorn
M[280729] = { expansion = "BfA" }  -- Frenzied Feltalon
M[280730] = { expansion = "BfA" }  -- Pureheart Courser
M[281044] = { expansion = "BfA" }  -- Prestigious Bloodforged Courser
M[281554] = { expansion = "BfA" }  -- Meat Wagon
M[281887] = { map = 84 }  -- Vicious Black Warsaber
M[281888] = { map = 84 }  -- Vicious White Warsaber
M[282682] = { expansion = "BfA" }  -- Kul Tiran Charger
M[288495] = { expansion = "BfA" }  -- Ashenvale Chimaera
M[288499] = { map = 62, expansion = "BfA" }  -- Frightened Kodo
M[288505] = { zone = "Darkshore" }  -- Kaldorei Nightsaber
M[288714] = { zone = "Dazar'alor" }  -- Bloodthirsty Dreadwing
M[288735] = { zone = "Dazar'alor" }  -- Rubyshell Krolusk
M[289083] = { zone = "Battle of Dazar'alor" }  -- G.M.O.D.
M[289639] = { expansion = "BfA" }  -- Bruce
M[290132] = { expansion = "BfA" }  -- Sylverian Dreamer
M[290133] = { expansion = "BfA" }  -- Vulpine Familiar
M[290134] = { expansion = "BfA" }  -- Hogrus, Swine of Good Fortune
M[290328] = { expansion = "BfA" }  -- Wonderwing 2.0
M[290608] = { expansion = "BfA" }  -- Crusader's Direhorn
M[290718] = { zone = "Operation: Mechagon" }  -- Aerial Unit R-21/X
M[294143] = { zone = "Razorwind Shores" }  -- X-995 Mechanocat
M[294197] = { expansion = "BfA" }  -- Obsidian Worldbreaker
M[294568] = { zone = "Warspear" }  -- Beastlord's Irontusk
M[294569] = { zone = "Warspear" }  -- Beastlord's Warwolf
M[296788] = { expansion = "BfA" }  -- Mechacycle Model W
M[297157] = { zone = "Mechagon" }  -- Junkheap Drifter
M[298367] = { map = 864 }  -- Mollie
M[299158] = { zone = "Operation: Mechagon" }  -- Mechagon Peacekeeper
M[299170] = { zone = "Mechagon" }  -- Rustbolt Resistor
M[300150] = { zone = "Nazjatar", expansion = "BfA" }  -- Fabious
M[300154] = { expansion = "BfA" }  -- Silver Tidestallion
M[302143] = { expansion = "BfA" }  -- Uncorrupted Voidwing
M[302361] = { expansion = "BfA" }  -- Alabaster Stormtalon
M[302362] = { expansion = "BfA" }  -- Alabaster Thunderwing
M[302794] = { expansion = "BfA" }  -- Swift Spectral Fathom Ray
M[302795] = { expansion = "BfA" }  -- Swift Spectral Magnetocraft
M[302796] = { expansion = "BfA" }  -- Swift Spectral Armored Gryphon
M[302797] = { expansion = "BfA" }  -- Swift Spectral Pterrordax
M[305592] = { expansion = "BfA" }  -- Mechagon Mechanostrider
M[306423] = { expansion = "BfA" }  -- Caravan Hyena
M[307256] = { expansion = "BfA" }  -- Explorer's Jungle Hopper
M[307263] = { expansion = "BfA" }  -- Explorer's Dunetrekker
M[308078] = { expansion = "BfA" }  -- Squeakers, the Trickster
M[308087] = { expansion = "Shadowlands" }  -- Lucky Yun
M[308814] = { zone = "Ny'alotha, the Waking City" }  -- Ny'alotha Allseer
M[312751] = { zone = "The Ruby Sanctum" }  -- Clutch of Ha-Li
M[312765] = { map = 1533 }  -- Sundancer
M[312767] = { map = 1565 }  -- Swift Gloomhoof
M[312777] = { expansion = "Shadowlands" }  -- Silvertip Dredwing
M[315014] = { map = 1530 }  -- Ivory Cloud Serpent
M[315132] = { expansion = "Dragonflight" }  -- Gargantuan Grrloc
M[315427] = { map = 1530 }  -- Rajani Warserpent
M[315847] = { map = 1527 }  -- Drake of the Four Winds
M[315987] = { zone = "Vision of Stormwind" }  -- Mail Muncher
M[316276] = { zone = "Thaldraszus" }  -- Wastewander Skyterror
M[316340] = { zone = "Timeless Isle" }  -- Wicked Swarmer
M[316637] = { expansion = "BfA" }  -- Awakened Mindborer
M[317177] = { expansion = "Shadowlands" }  -- Sunwarmed Furline
M[318051] = { map = 1565 }  -- Silky Shimmermoth
M[326390] = { expansion = "BfA" }  -- Steamscale Incinerator
M[332256] = { map = 1565 }  -- Duskflutter Ardenmoth
M[332464] = { zone = "Seat of the Primus" }  -- Armored Plaguerot Tauralus
M[332466] = { map = 1536 }  -- Armored Bonehoof Tauralus
M[332482] = { zone = "Oribos" }  -- Bonecleaver's Skullboar
M[332484] = { map = 1536 }  -- Lurid Bloodtusk
M[332882] = { map = 1525 }  -- Horrid Dredwing
M[332905] = { map = 1525 }  -- Endmire Flyer
M[333027] = { expansion = "Shadowlands" }  -- Loyal Gorger
M[334352] = { map = 1565 }  -- Wildseed Cradle
M[334364] = { map = 1565 }  -- Spinemaw Gladechewer
M[334365] = { expansion = "Shadowlands" }  -- Pale Acidmaw
M[334366] = { map = 1565 }  -- Wild Glimmerfur Prowler
M[334433] = { map = 1533 }  -- Silverwind Larion
M[336036] = { zone = "The Necrotic Wake" }  -- Marrowfang
M[336039] = { expansion = "Shadowlands" }  -- Gruesome Flayedwing
M[336042] = { map = 1536 }  -- Hulking Deathroc
M[336064] = { expansion = "Shadowlands" }  -- Dauntless Duskrunner
M[340503] = { map = 1565 }  -- Umbral Scythehorn
M[341639] = { map = 1525 }  -- Court Sinrunner
M[341821] = { expansion = "Shadowlands" }  -- Snowstorm
M[342334] = { map = 1533 }  -- Gilded Prowler
M[342335] = { map = 1533 }  -- Ascended Skymane
M[342668] = { expansion = "Shadowlands" }  -- Desertwing Hunter
M[342671] = { expansion = "Shadowlands" }  -- Pale Regal Cervid
M[342678] = { expansion = "Shadowlands" }  -- Vespoid Flutterer
M[342680] = { map = 1970 }  -- Deepstar Aurelid
M[343550] = { map = 1961 }  -- Battle-Hardened Aquilon
M[344575] = { expansion = "Shadowlands" }  -- Pestilent Necroray
M[346136] = { expansion = "Shadowlands" }  -- Viridian Phase-Hunter
M[346141] = { expansion = "Shadowlands" }  -- Slime Serpent
M[346719] = { expansion = "Shadowlands" }  -- Serenade
M[347251] = { map = 1961 }  -- Soaring Razorwing
M[347812] = { expansion = "Shadowlands" }  -- Sapphire Skyblazer
M[348162] = { expansion = "Shadowlands" }  -- Wandering Ancient
M[349935] = { map = 2151 }  -- Noble Bruffalon
M[349943] = { expansion = "Dragonflight" }  -- Amber Skitterfly
M[351195] = { zone = "Undercity" }  -- Vengeance
M[352926] = { zone = "The Primalist Future" }  -- Skyskin Hornstrider
M[353263] = { zone = "Tazavesh, the Veiled Market" }  -- Cartel Master's Gearglider
M[353264] = { expansion = "Shadowlands" }  -- Xy Trustee's Gearglider
M[353857] = { zone = "Heart of the Forest" }  -- Autumnal Wilderling
M[353858] = { map = 1961 }  -- Winter Wilderling
M[353859] = { map = 1961 }  -- Summer Wilderling
M[353866] = { zone = "Sinfall" }  -- Obsidian Gravewing
M[353873] = { map = 1961 }  -- Pale Gravewing
M[353877] = { map = 1961 }  -- Forsworn Aquilon
M[353884] = { zone = "Seat of the Primus" }  -- Regal Corpsefly
M[353885] = { map = 1961 }  -- Battlefield Swarmer
M[354353] = { map = 1543 }  -- Fallen Charger
M[354356] = { map = 1961 }  -- Amber Shardhide
M[356488] = { expansion = "Shadowlands" }  -- Sarge's Tale
M[356501] = { map = 1961 }  -- Rampaging Mauler
M[358072] = { expansion = "Dragonflight" }  -- Bound Blizzard
M[359013] = { zone = "Dalaran" }  -- Val'sharah Hippogryph
M[359230] = { expansion = "Shadowlands" }  -- Curious Crystalsniffer
M[359231] = { expansion = "Shadowlands" }  -- Darkened Vombata
M[359232] = { expansion = "Shadowlands" }  -- Adorned Vombata
M[359276] = { map = 1970 }  -- Anointed Protostag
M[359277] = { expansion = "Shadowlands" }  -- Sundered Zerethsteed
M[359278] = { expansion = "Shadowlands" }  -- Deathrunner
M[359317] = { expansion = "Shadowlands" }  -- Wen Lo, the River's Edge
M[359364] = { expansion = "Shadowlands" }  -- Bronzewing Vespoid
M[359366] = { expansion = "Shadowlands" }  -- Buzz
M[359367] = { expansion = "Shadowlands" }  -- Forged Spiteflyer
M[359372] = { expansion = "Shadowlands" }  -- Mawdapted Raptora
M[359373] = { expansion = "Shadowlands" }  -- Raptora Swooper
M[359376] = { expansion = "Shadowlands" }  -- Bronze Helicid
M[359377] = { expansion = "Shadowlands" }  -- Unsuccessful Prototype Fleetpod
M[359378] = { expansion = "Shadowlands" }  -- Scarlet Helicid
M[359380] = { expansion = "TWW" }  -- Depthstalker
M[359401] = { expansion = "Shadowlands" }  -- Genesis Crawler
M[359402] = { expansion = "Shadowlands" }  -- Tarachnid Creeper
M[359403] = { expansion = "Shadowlands" }  -- Ineffable Skitterer
M[359413] = { expansion = "Shadowlands" }  -- Goldplate Bufonid
M[359545] = { expansion = "Shadowlands" }  -- Carcinized Zerethsteed
M[359622] = { map = 2024 }  -- Liberated Slyvern
M[363613] = { expansion = "Shadowlands" }  -- Lightforged Ruinstrider
M[363703] = { expansion = "Shadowlands" }  -- Prototype Leaper
M[363706] = { expansion = "Shadowlands" }  -- Russet Bufonid
M[366647] = { expansion = "Dragonflight" }  -- Magenta Cloud Serpent
M[366789] = { expansion = "Dragonflight" }  -- Crusty Crawler
M[366790] = { expansion = "Dragonflight" }  -- Quawks
M[366962] = { expansion = "Dragonflight" }  -- Ash'adar, Harbinger of Dawn
M[367190] = { map = 379, expansion = "Shadowlands" }  -- [DND] Test Mount JZB
M[367620] = { expansion = "Dragonflight" }  -- Coral-Stalker Waveray
M[367673] = { expansion = "Shadowlands" }  -- Heartbond Lupine
M[367676] = { expansion = "Shadowlands" }  -- Nether-Gorged Greatwyrm
M[367826] = { expansion = "Dragonflight" }  -- Savage Green Battle Turtle
M[367875] = { expansion = "Dragonflight" }  -- Armored Siege Kodo
M[368105] = { zone = "Zereth Mortis", expansion = "Shadowlands" }  -- Colossal Plaguespew Mawrat
M[368126] = { expansion = "Dragonflight" }  -- Armored Golden Pterrordax
M[368128] = { zone = "Zereth Mortis", expansion = "Shadowlands" }  -- Colossal Wraithbound Mawrat
M[368158] = { zone = "Sepulcher of the First Ones" }  -- Zereth Overseer
M[368893] = { expansion = "Dragonflight" }  -- Winding Slitherdrake
M[369451] = { expansion = "Dragonflight" }  -- Jade, Bright Foreseer
M[369476] = { expansion = "Dragonflight" }  -- Amalgam of Rage
M[369480] = { expansion = "Dragonflight" }  -- Cerulean Marsh Hopper
M[370770] = { expansion = "Shadowlands" }  -- Tuskarr Shoreglider
M[372995] = { expansion = "Dragonflight" }  -- Swift Spectral Drake
M[373859] = { map = 2022 }  -- Loyal Magmammoth
M[374032] = { zone = "The Waking Shores", expansion = "Dragonflight" }  -- Tamed Skitterfly
M[374034] = { zone = "The Waking Shores", expansion = "Dragonflight" }  -- Azure Skitterfly
M[374048] = { zone = "The Waking Shores", expansion = "Dragonflight" }  -- Verdant Skitterfly
M[374098] = { zone = "Valdrakken", expansion = "Dragonflight" }  -- Stormhide Salamanther
M[374138] = { map = 2133 }  -- Seething Slug
M[374162] = { map = 2022 }  -- Scrappy Worldsnail
M[374194] = { expansion = "Dragonflight" }  -- Mossy Mammoth
M[374196] = { expansion = "Dragonflight" }  -- Plainswalker Bearer
M[374204] = { map = 2025 }  -- Explorer's Stonehide Packbeast
M[374278] = { expansion = "Dragonflight" }  -- Renewed Magmammoth
M[376873] = { expansion = "Dragonflight" }  -- Otto
M[376875] = { zone = "The Azure Span", expansion = "Dragonflight" }  -- Brown Scouting Ottuk
M[376880] = { zone = "The Azure Span", expansion = "Dragonflight" }  -- Yellow Scouting Ottuk
M[376910] = { zone = "The Azure Span", expansion = "Dragonflight" }  -- Brown War Ottuk
M[376912] = { expansion = "Dragonflight" }  -- Otterworldly Ottuk Carrier
M[376913] = { zone = "The Azure Span", expansion = "Dragonflight" }  -- Yellow War Ottuk
M[381529] = { expansion = "Dragonflight" }  -- Telix the Stormhorn
M[384963] = { map = 2151 }  -- Guardian Vorquin
M[385115] = { map = 2151 }  -- Majestic Armored Vorquin
M[385131] = { map = 2151 }  -- Armored Vorquin Leystrider
M[385134] = { map = 2151 }  -- Swift Armored Vorquin
M[385260] = { expansion = "Dragonflight" }  -- Bestowed Ohuna Spotter
M[385262] = { map = 2025 }  -- Duskwing Ohuna
M[385738] = { map = 2024 }  -- Temperamental Skyclaw
M[386452] = { expansion = "Shadowlands" }  -- Frostbrood Proto-Wyrm
M[394216] = { map = 2151 }  -- Crimson Vorquin
M[394218] = { map = 2151 }  -- Sapphire Vorquin
M[394219] = { map = 2151 }  -- Bronze Vorquin
M[394220] = { map = 2151 }  -- Obsidian Vorquin
M[395095] = { expansion = "Dragonflight" }  -- Whelpling
M[397406] = { expansion = "Dragonflight" }  -- Wondrous Wavewhisker
M[400733] = { expansion = "Dragonflight" }  -- Rocket Shredder 9001
M[400976] = { expansion = "Dragonflight" }  -- Gleaming Moonbeast
M[407555] = { expansion = "Dragonflight" }  -- Tarecgosa's Visage
M[408627] = { map = 2133 }  -- Igneous Shalewing
M[408648] = { expansion = "Dragonflight" }  -- Calescent Shalewing
M[408653] = { map = 2133 }  -- Boulder Hauler
M[408654] = { zone = "Dalaran" }  -- Sandy Shalewing
M[408655] = { zone = "Razorwind Shores" }  -- Morsel Sniffer
M[411565] = { expansion = "Dragonflight" }  -- Felcrystal Scorpion
M[413825] = { expansion = "Dragonflight" }  -- Scarlet Pterrordax
M[413827] = { expansion = "Dragonflight" }  -- Harbor Gryphon
M[414316] = { zone = "Thaldraszus" }  -- White War Wolf
M[414323] = { zone = "Thaldraszus" }  -- Ravenous Black Gryphon
M[414324] = { zone = "Valdrakken" }  -- Gold-Toed Albatross
M[414326] = { zone = "Mardum, the Shattered Abyss" }  -- Felstorm Dragon
M[414327] = { zone = "Thaldraszus" }  -- Sulfur Hound
M[414328] = { zone = "Thaldraszus" }  -- Perfected Juggernaut
M[414334] = { zone = "Shadowfang Keep" }  -- Scourgebound Vanquisher
M[414986] = { expansion = "Dragonflight" }  -- Royal Swarmer
M[417245] = { expansion = "Dragonflight" }  -- Ancestral Clefthoof
M[417556] = { expansion = "Dragonflight" }  -- Winding Slitherdrake
M[417888] = { expansion = "Dragonflight" }  -- Algarian Stormrider
M[418078] = { expansion = "Dragonflight" }  -- Pattie
M[418286] = { expansion = "Dragonflight" }  -- Auspicious Arborwyrm
M[419002] = { expansion = "Dragonflight" }  -- Whelpling
M[419345] = { expansion = "Dragonflight" }  -- Eve's Ghastly Rider
M[419567] = { expansion = "Dragonflight" }  -- Ginormous Grrloc
M[420097] = { zone = "Shadowmoon Valley" }  -- Azure Worldchiller
M[423871] = { map = 2200 }  -- Blossoming Dreamstag
M[423873] = { map = 2200 }  -- Suntouched Dreamstag
M[423877] = { map = 2200 }  -- Rekindled Dreamstag
M[423891] = { map = 2200 }  -- Lunar Dreamstag
M[424009] = { expansion = "Dragonflight" }  -- Runebound Firelord
M[424082] = { expansion = "Dragonflight" }  -- Mimiron's Jumpjets
M[424476] = { map = 2200 }  -- Winter Night Dreamsaber
M[424479] = { map = 2200 }  -- Evening Sun Dreamsaber
M[424482] = { map = 2200 }  -- Morning Flourish Dreamsaber
M[424484] = { zone = "Amirdrassil, the Dream's Hope" }  -- Anu'relos, Flame's Guidance
M[424601] = { expansion = "Dragonflight" }  -- Brown-Furred Spiky Bakar
M[426955] = { map = 2200 }  -- Springtide Dreamtalon
M[427043] = { map = 2200 }  -- Snowfluff Dreamtalon
M[427222] = { map = 2200 }  -- Delugen
M[427224] = { map = 2200 }  -- Talont
M[427226] = { map = 2200 }  -- Stargrazer
M[427435] = { expansion = "Dragonflight" }  -- Crimson Glimmerfur
M[427546] = { map = 2200 }  -- Mammyth
M[427549] = { map = 2200 }  -- Imagiwing
M[427724] = { map = 2200 }  -- Salatrancer
M[427777] = { expansion = "Dragonflight" }  -- Heartseeker Mana Ray
M[428005] = { expansion = "Dragonflight" }  -- Jeweled Copper Scarab
M[428013] = { expansion = "Dragonflight" }  -- Incognitro, the Indecipherable Felcycle
M[428060] = { expansion = "Dragonflight" }  -- Golden Regal Scarab
M[428062] = { expansion = "Dragonflight" }  -- Jeweled Sapphire Scarab
M[428065] = { expansion = "Dragonflight" }  -- Jeweled Jade Scarab
M[428067] = { expansion = "Dragonflight" }  -- Hateforged Blazecycle
M[431357] = { expansion = "Dragonflight" }  -- Fur-endship Fox
M[431359] = { expansion = "Dragonflight" }  -- Soaring Sky Fox
M[431360] = { expansion = "Dragonflight" }  -- Twilight Sky Prowler
M[431992] = { expansion = "Dragonflight" }  -- Compass Rose
M[432455] = { expansion = "Dragonflight" }  -- Noble Flying Carpet
M[432558] = { expansion = "Dragonflight" }  -- Majestic Azure Peafowl
M[432562] = { expansion = "Dragonflight" }  -- Brilliant Sunburst Peafowl
M[432610] = { expansion = "Dragonflight" }  -- Clayscale Hornstrider
M[433281] = { expansion = "Dragonflight" }  -- Savage Blue Battle Turtle
M[437162] = { expansion = "Dragonflight" }  -- Polly Roger
M[440444] = { expansion = "Dragonflight" }  -- Zovaal's Soul Eater
M[441313] = { expansion = "TWW" }  -- Soar
M[441324] = { zone = "Dalaran" }  -- Remembered Golden Gryphon
M[441325] = { zone = "Dalaran" }  -- Remembered Wind Rider
M[443660] = { expansion = "Dragonflight" }  -- Charming Courier
M[446352] = { expansion = "Dragonflight" }  -- Kickin' Kezan Waveshredder
M[447057] = { map = 2339 }  -- Smoldering Cinderbee
M[447151] = { zone = "Isle of Dorn" }  -- Soaring Meaderbee
M[447173] = { map = 2413, expansion = "TWW" }  -- Elder Glowmite
M[447185] = { map = 2255, expansion = "TWW" }  -- Aquamarine Swarmite
M[447405] = { expansion = "TWW" }  -- Vicious Skyflayer
M[447413] = { expansion = "Dragonflight" }  -- Pearlescent Goblin Wave Shredder
M[447957] = { map = 2255, expansion = "TWW" }  -- Ferocious Jawcrawler
M[448188] = { map = 2214 }  -- Machine Defense Unit 1-11
M[448680] = { expansion = "TWW" }  -- Widow's Undercrawler
M[448685] = { expansion = "TWW" }  -- Heritage Undercrawler
M[448689] = { expansion = "TWW" }  -- Royal Court Undercrawler
M[448845] = { expansion = "Dragonflight" }  -- Blue Old God Fish Mount
M[448849] = { expansion = "Dragonflight" }  -- Underlight Shorestalker
M[448850] = { expansion = "Dragonflight" }  -- Kah, Legend of the Deep
M[448851] = { expansion = "Dragonflight" }  -- Underlight Corrupted Behemoth
M[448939] = { map = 2215 }  -- Shackled Shadow
M[448978] = { map = 2215 }  -- Vermillion Imperial Lynx
M[449126] = { expansion = "Dragonflight" }  -- Kor'kron Warsaber
M[449132] = { expansion = "Dragonflight" }  -- Blackrock Warsaber
M[449133] = { expansion = "Dragonflight" }  -- [PH] Nightsaber Horde Mount White
M[449140] = { expansion = "Dragonflight" }  -- Sentinel War Wolf
M[449141] = { expansion = "Dragonflight" }  -- [PH] Alliance Wolf Mount
M[449142] = { expansion = "Dragonflight" }  -- Kaldorei War Wolf
M[449258] = { map = 2214 }  -- Ol' Mole Rufus
M[449269] = { map = 2214 }  -- Crimson Mudnose
M[449325] = { expansion = "TWW" }  -- Vicious Skyflayer
M[449415] = { expansion = "TWW" }  -- Slatestone Ramolith
M[449418] = { map = 2339 }  -- Shale Ramolith
M[449466] = { expansion = "TWW" }  -- Forged Gladiator's Fel Bat
M[451486] = { zone = "Nerub-ar Palace" }  -- Sureki Skyrazor
M[451487] = { map = 241 }  -- Retrained Skyrazor
M[451491] = { zone = "Nerub-ar Palace" }  -- Ascendant Skyrazor
M[452643] = { zone = "Orgrimmar" }  -- Frayfeather Hippogryph
M[452645] = { map = 111 }  -- Amani Hunting Bear
M[453255] = { expansion = "Dragonflight" }  -- Savage Ebony Battle Turtle
M[453785] = { expansion = "TWW" }  -- Earthen Ordinant's Ramolith
M[454682] = { expansion = "TWW" }  -- Startouched Furline
M[457485] = { expansion = "TWW" }  -- Grizzly Hills Packmaster
M[457650] = { expansion = "TWW" }  -- Plunderlord's Golden Crocolisk
M[457654] = { expansion = "TWW" }  -- Keg Leg's Radiant Crocolisk
M[457656] = { expansion = "TWW" }  -- Plunderlord's Midnight Crocolisk
M[457659] = { expansion = "TWW" }  -- Plunderlord's Weathered Crocolisk
M[458335] = { expansion = "TWW" }  -- Diamond Mechsuit
M[459193] = { expansion = "TWW" }  -- Hand of Reshkigaal
M[459784] = { expansion = "TWW" }  -- Golden Ashes of Al'ar
M[463025] = { expansion = "TWW" }  -- Gigantic Grrloc
M[463133] = { expansion = "TWW" }  -- Coldflame Tempest
M[464443] = { expansion = "TWW" }  -- Harmonious Salutations Bear
M[465235] = { expansion = "TWW" }  -- Trader's Gilded Brutosaur
M[466000] = { zone = "Liberation of Undermine" }  -- Darkfuse Chompactor
M[466011] = { zone = "Liberation of Undermine" }  -- Flarendo the Furious
M[466012] = { zone = "Liberation of Undermine" }  -- Thunderdrum Misfire
M[466144] = { expansion = "TWW" }  -- Prized Gladiator's Fel Bat
M[466145] = { expansion = "TWW" }  -- Vicious Electro Eel
M[466146] = { expansion = "TWW" }  -- Vicious Electro Eel
M[466423] = { expansion = "TWW" }  -- Unstable Rocket
M[466464] = { expansion = "TWW" }  -- Unstable Rocket
M[466811] = { expansion = "TWW" }  -- Chaos-Forged Gryphon
M[466812] = { expansion = "TWW" }  -- Chaos-Forged Hippogryph
M[466838] = { expansion = "TWW" }  -- Chaos-Forged Dreadwing
M[466845] = { expansion = "TWW" }  -- Chaos-Forged Wind Rider
M[468205] = { expansion = "TWW" }  -- Timbered Sky Snake
M[468353] = { zone = "Dalaran" }  -- Enchanted Spellweave Carpet
M[471538] = { zone = "Dalaran" }  -- Timely Buzzbee
M[471696] = { expansion = "TWW" }  -- Hooktalon
M[472157] = { expansion = "TWW" }  -- Astral Gladiator's Fel Bat
M[472253] = { zone = "Shattrath City" }  -- Lunar Launcher
M[472479] = { zone = "Shadowfang Keep", expansion = "TWW" }  -- Love Witch's Sweeper
M[472487] = { expansion = "TWW" }  -- Silvermoon Sweeper
M[472488] = { expansion = "TWW" }  -- Twilight Witch's Sweeper
M[472489] = { expansion = "TWW" }  -- Sky Witch's Sweeper
M[473739] = { expansion = "TWW" }  -- Meeksi Rufflefur
M[473741] = { expansion = "TWW" }  -- Meeksi Softpaw
M[473743] = { expansion = "TWW" }  -- Meeksi Rollingpaw
M[473744] = { expansion = "TWW" }  -- Meeksi Teatuft
M[473745] = { expansion = "TWW" }  -- Meeksi Brewthief
M[473861] = { expansion = "TWW" }  -- Savage Alabaster Battle Turtle
M[1214920] = { zone = "Warspear" }  -- Nightfall Skyreaver
M[1214940] = { zone = "Dalaran" }  -- Ur'zul Fleshripper
M[1216542] = { expansion = "TWW" }  -- Blazing Royal Fire Hawk
M[1217340] = { expansion = "TWW" }  -- Midnight Darkmoon Charger
M[1217341] = { expansion = "TWW" }  -- Lively Darkmoon Charger
M[1217342] = { expansion = "TWW" }  -- Violet Darkmoon Charger
M[1217343] = { expansion = "TWW" }  -- Snowy Darkmoon Charger
M[1217760] = { zone = "Liberation of Undermine" }  -- The Big G
M[1217965] = { expansion = "TWW" }  -- Shimmermist Free Runner
M[1217994] = { expansion = "TWW" }  -- Pearlescent Butterfly
M[1218012] = { expansion = "TWW" }  -- Ruby Butterfly
M[1218013] = { zone = "Shadowfang Keep" }  -- Spring Butterfly
M[1218014] = { expansion = "TWW" }  -- Midnight Butterfly
M[1218069] = { expansion = "TWW" }  -- Emerald Snail
M[1218229] = { zone = "Vision of Stormwind" }  -- Void-Scarred Gryphon
M[1218305] = { zone = "Vision of Stormwind" }  -- Void-Forged Stallion
M[1218317] = { expansion = "TWW" }  -- Void-Crystal Panther
M[1219705] = { expansion = "TWW" }  -- Spotted Black Riding Goat
M[1221155] = { zone = "Liberation of Undermine" }  -- Prototype A.S.M.R.
M[1223187] = { zone = "Tazavesh, the Veiled Market" }  -- Terror of the Wastes
M[1226144] = { zone = "Dalaran", expansion = "TWW" }  -- Chrono Corsair
M[1226511] = { expansion = "TWW" }  -- Spring Harvesthog
M[1226531] = { expansion = "TWW" }  -- Summer Harvesthog
M[1226532] = { expansion = "TWW" }  -- Winter Harvesthog
M[1226533] = { expansion = "TWW" }  -- Autumn Harvesthog
M[1226740] = { expansion = "TWW" }  -- Coldflame Cormaera
M[1226760] = { expansion = "TWW" }  -- Prophet's Great Raven
M[1226851] = { expansion = "TWW" }  -- Felborn Cormaera
M[1226855] = { expansion = "TWW" }  -- Molten Cormaera
M[1226856] = { expansion = "TWW" }  -- Lavaborn Cormaera
M[1226983] = { expansion = "TWW" }  -- Archmage's Great Raven
M[1227076] = { expansion = "TWW" }  -- Tyrannotort
M[1227192] = { expansion = "TWW" }  -- Herald of Sa'bak
M[1228865] = { expansion = "TWW" }  -- Void-Scarred Lynx
M[1229276] = { expansion = "TWW" }  -- Bloodhunter Fel Bat
M[1229283] = { expansion = "TWW" }  -- Ashplague Fel Bat
M[1229288] = { expansion = "TWW" }  -- Wretched Fel Bat
M[1233546] = { zone = "Tazavesh, the Veiled Market" }  -- Ruby Void Creeper
M[1233547] = { map = 2371 }  -- Acidic Void Creeper
M[1233925] = { expansion = "TWW" }  -- Lana'thel's Crimson Cascade
M[1234303] = { expansion = "TWW" }  -- Voidwing Dragonhawk
M[1234305] = { expansion = "TWW" }  -- Lightwing Dragonhawk
M[1234573] = { zone = "Netherstorm" }  -- Unbound Star-Eater
M[1234820] = { expansion = "TWW" }  -- Vicious Void Creeper
M[1234821] = { expansion = "TWW" }  -- Vicious Void Creeper
M[1234859] = { expansion = "TWW" }  -- Banshee's Chilling Charger
M[1234971] = { expansion = "TWW" }  -- Grandiose Grrloc
M[1235513] = { expansion = "TWW" }  -- Snowy Highmountain Eagle
M[1235756] = { expansion = "TWW" }  -- Grandmaster's Prophetic Board
M[1235763] = { expansion = "TWW" }  -- Grandmaster's Deep Board
M[1235803] = { expansion = "TWW" }  -- Grandmaster's Royal Board
M[1235806] = { expansion = "TWW" }  -- Grandmaster's Smokey Board
M[1235817] = { expansion = "TWW" }  -- Forsaken's Grotesque Charger
M[1235819] = { expansion = "TWW" }  -- Wailing Banshee's Charger
M[1235820] = { expansion = "TWW" }  -- Banshee's Sickening Charger
M[1237631] = { zone = "Boralus" }  -- Moonlit Nightsaber
M[1237703] = { zone = "Boralus" }  -- Ivory Savagemane
M[1238729] = { expansion = "TWW" }  -- Slag Basilisk
M[1238827] = { expansion = "Midnight" }  -- Swift Spectral Dragonhawk
M[1239138] = { expansion = "TWW" }  -- Voidlight Surger
M[1241263] = { map = 2339 }  -- OC91 Chariot
M[1247662] = { zone = "Blackrock Depths" }  -- Brewfest Bomber
M[1251433] = { zone = "Zul'Aman" }  -- Amani Sunfeather
M[1253938] = { map = 2413 }  -- Ruddy Sporeglider
M[1260354] = { map = 2413 }  -- Untainted Grove Crawler
M[1261322] = { map = 2395 }  -- Crimson Silvermoon Hawkstrider
M[1261336] = { map = 2393 }  -- Preyseeker's Hubris
M[1261348] = { zone = "Zul'Aman" }  -- Blessed Amani Burrower
M[1261360] = { map = 2437 }  -- Ancestral War Bear
M[1261576] = { map = 2437 }  -- Hexed Vilefeather Eagle
M[1261583] = { map = 2405 }  -- Insatiable Shredclaw
M[1261584] = { zone = "Masters' Perch" }  -- Prowling Shredclaw
M[1261585] = { zone = "Masters' Perch" }  -- Frenzied Shredclaw
M[1263369] = { zone = "Oribos" }  -- Skypaw Glimmerfur
M[1263387] = { zone = "Oribos" }  -- Crimson Lupine
M[1263635] = { zone = "Windrunner Spire" }  -- Spectral Hawkstrider
M[1264621] = { zone = "Deeprun Tram" }  -- Brawlin' Bruno
M[1264643] = { zone = "Deeprun Tram" }  -- Ballistic Bronco
M[1264988] = { zone = "Oribos" }  -- Snowpaw Glimmerfur Prowler
M[1265784] = { zone = "Magisters' Terrace" }  -- Lucent Hawkstrider
M[1268924] = { map = 2393 }  -- Silvermoon's Arcane Defender
M[1270675] = { map = 2413 }  -- Vivid Chloroceros
M[1282936] = { map = 2393 }  -- Void-Touched Hawkstrider
M[1296731] = { zone = "Silvermoon City" }  -- Cerulean Deathwalker
M[1296734] = { zone = "Silvermoon City" }  -- Amethyst Mechsuit
M[1296756] = { zone = "Silvermoon City" }  -- Blue-Chip Shreddertank
M[1296758] = { zone = "Silvermoon City" }  -- Profit-Green Shreddertank
M[1296759] = { zone = "Silvermoon City" }  -- High-Yield Shreddertank
M[1296760] = { zone = "Silvermoon City" }  -- Speculative Shreddertank
