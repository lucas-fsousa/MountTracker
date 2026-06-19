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
    { "TBC",          { "outland", "hellfire", "zangarmarsh", "terokkar", "blade.s edge", "netherstorm", "shattrath", "quel.danas", "zul.aman", "tempest keep", "black temple", "sunwell", "netherwing", "skettis", "eversong", "silvermoon", "ghostlands", "azuremyst", "bloodmyst", "exodar" } },
    { "Classic",      { "alterac", "winterspring", "silithus", "azshara", "felwood", "un.goro", "plaguelands", "stratholme", "scholomance", "dire maul", "blackrock", "molten core", "onyxia", "zul.gurub", "ahn.qiraj", "tanaris", "stormwind", "orgrimmar", "ironforge", "darnassus", "thunder bluff", "undercity", "dun morogh", "elwynn", "durotar", "mulgore" } },
}

-- Deriva a expansao APENAS por heuristica de zona/sourceText. E o ULTIMO recurso: o addon
-- usa primeiro o dado AUTORITATIVO (entry.expansion curado + overlay ns.Meta colhido do
-- "Added in patch" do Wowhead). Por isso aqui NAO ha mais override por spellID: a colisao
-- de zona reaproveitada (Eversong = TBC e Midnight, etc.) e resolvida pelo overlay, nao por
-- um numero magico. `spellID`/`curatedExp` ficam na assinatura por compatibilidade.
function ns.ExpansionFor(sourceText, curatedExp, spellID)
    if curatedExp then return curatedExp end
    -- Remove texturas (caminhos de icone contem palavras como "draenor" -> falso positivo).
    local t = (sourceText or ""):gsub("|T.-|t", ""):lower()
    if t:find("outland", 1, true) then  -- desambigua Nagrand/Shadowmoon (TBC) de WoD
        return "TBC"
    end
    for _, rule in ipairs(RULES) do
        for _, kw in ipairs(rule[2]) do
            if t:find(kw) then return rule[1] end
        end
    end
    return "Unknown"
end
