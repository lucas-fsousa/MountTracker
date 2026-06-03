-- Logic/Expansion.lua
-- Heuristica: deriva a expansao de uma montaria a partir das zonas no sourceText.
-- A API do journal nao expoe expansao; o sourceText quase sempre cita a zona, que
-- mapeia para uma expansao. Curadas podem sobrescrever via entry.expansion.

local ADDON, ns = ...

-- Ordem dos buckets (do mais antigo ao mais novo) -- usada pelo filtro da UI.
ns.EXPANSIONS = {
    "Classic", "TBC", "WotLK", "Cataclysm", "MoP", "WoD",
    "Legion", "BfA", "Shadowlands", "Dragonflight", "TWW", "Midnight", "Unknown",
}

-- Palavras-chave (substring, lowercase) por expansao. Ordem dentro da lista nao
-- importa; a ordem das regras sim (do mais novo/especifico ao mais antigo).
local RULES = {
    { "TWW",          { "k.aresh", "isle of dorn", "dornogal", "ringing deeps", "azj-kahet", "hallowfall", "undermine", "city of threads", "shadow point", "khaz algar", "siren isle", "nerub.ar palace", "manaforge omega", "darkflame cleft" } },
    { "Dragonflight", { "emerald dream", "thaldraszus", "ohn.ahran", "azure span", "waking shores", "zaralek", "forbidden reach", "valdrakken", "dragon isles", "amirdrassil", "tyrhold", "time rift", "dragonflight" } },
    { "Shadowlands",  { "oribos", "bastion", "maldraxxus", "ardenweald", "revendreth", "the maw", "korthia", "zereth mortis", "torghast", "sanctum of domination", "necrotic wake", "sepulcher", "shadowlands" } },
    { "BfA",          { "zuldazar", "nazmir", "vol.dun", "tiragarde", "drustvar", "stormsong", "nazjatar", "mechagon", "boralus", "dazar.alor", "zandalar", "kul tiras", "uldir", "ny.alotha", "horrific visions", "freehold", "underrot", "chamber of heart" } },
    { "Legion",       { "suramar", "val.sharah", "highmountain", "stormheim", "azsuna", "broken shore", "argus", "mac.aree", "antoran", "krokuun", "trueshot lodge", "mardum", "broken isles", "skyhold", "sanctum of light", "dreadscar", "nighthold" } },
    { "WoD",          { "draenor", "tanaan", "frostfire", "gorgrond", "talador", "spires of arak", "warspear", "stormshield", "ashran", "shadowmoon valley", "nagrand" } },
    { "MoP",          { "pandaria", "jade forest", "valley of the four winds", "kun-lai", "townlong", "dread wastes", "vale of eternal", "timeless isle", "krasarang", "isle of thunder", "isle of giants", "veiled stair", "throne of thunder", "mogu" } },
    { "Cataclysm",    { "mount hyjal", "vashj.ir", "deepholm", "uldum", "twilight highlands", "tol barad", "firelands", "dragon soul", "blackwing descent", "gilneas" } },
    { "WotLK",        { "northrend", "icecrown", "storm peaks", "sholazar", "grizzly hills", "howling fjord", "borean tundra", "dragonblight", "zul.drak", "crystalsong", "wintergrasp", "ulduar", "naxxramas", "argent tournament", "argent crusade", "dalaran" } },
    { "TBC",          { "outland", "hellfire", "zangarmarsh", "terokkar", "blade.s edge", "netherstorm", "shattrath", "quel.danas", "zul.aman", "tempest keep", "black temple", "sunwell", "netherwing", "skettis" } },
    { "Classic",      { "alterac", "winterspring", "silithus", "azshara", "felwood", "un.goro", "plaguelands", "stratholme", "scholomance", "dire maul", "blackrock", "molten core", "onyxia", "zul.gurub", "ahn.qiraj", "tanaris", "stormwind", "orgrimmar", "ironforge", "darnassus", "thunder bluff", "undercity", "dun morogh", "elwynn", "durotar", "mulgore", "eversong", "silvermoon", "ghostlands" } },
}

-- Expansoes "antigas": zonas reaproveitadas (Quel'Danas, Zul'Aman, Eversong...)
-- caem aqui pelo nome, mas montarias recentes nelas sao de Midnight.
local OLD = {
    Classic = true, TBC = true, WotLK = true, Cataclysm = true,
    MoP = true, WoD = true, Legion = true, BfA = true,
}
-- spellID a partir do qual a montaria e seguramente do Midnight (12.0).
local MIDNIGHT_SPELL = 1240000

-- Deriva a expansao. `curatedExp` (se houver) tem prioridade total.
-- `spellID` desambigua zonas reaproveitadas (ex.: Quel'Danas TBC vs Midnight).
function ns.ExpansionFor(sourceText, curatedExp, spellID)
    if curatedExp then return curatedExp end
    -- Remove texturas (caminhos de icone contem palavras como "draenor" -> falso positivo).
    local t = (sourceText or ""):gsub("|T.-|t", ""):lower()
    local exp
    if t:find("outland", 1, true) then  -- desambigua Nagrand/Shadowmoon (TBC) de WoD
        exp = "TBC"
    else
        for _, rule in ipairs(RULES) do
            for _, kw in ipairs(rule[2]) do
                if t:find(kw) then exp = rule[1]; break end
            end
            if exp then break end
        end
    end
    exp = exp or "Unknown"
    -- Override: um spellID muito alto e seguramente do Midnight (12.0). Aplica quando
    -- a zona caiu num bucket "antigo" reaproveitado (ex.: Quel'Danas/Eversong) OU
    -- quando nao deu p/ classificar (Unknown) -- ex.: world drops cujo texto ao vivo
    -- nao cita a zona. Buckets recentes (TWW/Dragonflight) tem spellID < MIDNIGHT_SPELL,
    -- entao nao sao afetados.
    if spellID and spellID >= MIDNIGHT_SPELL and (OLD[exp] or exp == "Unknown") then
        return "Midnight"
    end
    return exp
end
