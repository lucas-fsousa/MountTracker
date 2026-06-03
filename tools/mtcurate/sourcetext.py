"""Parse do texto de origem (sourceText) do proprio jogo -- fonte confiavel.

Extrai campos rotulados, custo (moeda/item/ouro), requisito de reputacao/renome
e a expansao (heuristica por zona, espelhando Logic/Expansion.lua do addon).
"""

import re

STANDINGS = ("Exalted", "Revered", "Honored", "Friendly", "Neutral")


def field(src, label):
    """Valor de um rotulo 'Label: |rVALOR' do sourceText."""
    m = re.search(re.escape(label) + r":\s*\|r\s*([^|]+)", src or "")
    return m.group(1).strip() if m else None


def costs(src):
    """Lista de custos: [{amount, ctype(currency|item|gold), id}]."""
    s = (src or "").replace(",", "")
    out = []
    # moeda/item via hyperlink, COM ou SEM icone (NUM |Htype:ID[:qty]|h [|Ticon|t])
    for amount, ctype, cid in re.findall(r"(\d+)\s*\|H(currency|item):(\d+)(?::\d+)*\|h", s):
        out.append({"amount": int(amount), "ctype": ctype, "id": int(cid)})
    if not out:
        for amount in re.findall(r"(\d+)\|T[^|]*?(?:MoneyFrame|GoldIcon)[^|]*?\|t", s, re.I):
            out.append({"amount": int(amount), "ctype": "gold", "id": None})
    return out


def requirement(src):
    """Requisito a partir do sourceText: 'Faction: X - <Standing>' ou Renown."""
    fac = field(src, "Faction")
    if not fac:
        return None
    ren = field(src, "Renown")
    if ren and ren.strip().isdigit():
        return {"type": "renown", "factionID": None, "faction": fac.strip(), "renownLevel": int(ren.strip())}
    m = re.match(r"(.+?)\s*-\s*(%s)\s*$" % "|".join(STANDINGS), fac.strip())
    if m:
        return {"type": "reputation", "factionID": None, "faction": m.group(1).strip(), "standing": m.group(2)}
    return None


# Heuristica de expansao por zona (do mais novo/especifico ao mais antigo).
EXP_RULES = [
    ("TWW", ["k'aresh", "kʼaresh", "isle of dorn", "dornogal", "ringing deeps", "azj-kahet", "hallowfall", "undermine", "city of threads", "khaz algar", "siren isle", "nerub-ar palace", "manaforge omega", "darkflame cleft"]),
    ("Dragonflight", ["emerald dream", "thaldraszus", "ohn'ahran", "azure span", "waking shores", "zaralek", "forbidden reach", "valdrakken", "dragon isles", "amirdrassil", "tyrhold", "time rift"]),
    ("Shadowlands", ["oribos", "bastion", "maldraxxus", "ardenweald", "revendreth", "the maw", "korthia", "zereth mortis", "torghast", "necrotic wake", "sepulcher"]),
    ("BfA", ["zuldazar", "nazmir", "vol'dun", "tiragarde", "drustvar", "stormsong", "nazjatar", "mechagon", "boralus", "dazar'alor", "zandalar", "kul tiras", "ny'alotha", "horrific visions", "freehold", "underrot", "chamber of heart"]),
    ("Legion", ["suramar", "val'sharah", "highmountain", "stormheim", "azsuna", "broken shore", "argus", "mac'aree", "antoran", "krokuun", "trueshot lodge", "broken isles", "nighthold"]),
    ("WoD", ["draenor", "tanaan", "frostfire", "gorgrond", "talador", "spires of arak", "warspear", "stormshield", "ashran", "shadowmoon valley", "nagrand"]),
    ("MoP", ["pandaria", "jade forest", "valley of the four winds", "kun-lai", "townlong", "dread wastes", "vale of eternal", "timeless isle", "krasarang", "isle of thunder", "mogu"]),
    ("Cataclysm", ["mount hyjal", "vashj'ir", "deepholm", "uldum", "twilight highlands", "tol barad", "firelands", "gilneas"]),
    ("WotLK", ["northrend", "icecrown", "storm peaks", "sholazar", "grizzly hills", "howling fjord", "borean tundra", "dragonblight", "zul'drak", "crystalsong", "wintergrasp", "argent tournament", "argent crusade", "dalaran"]),
    ("TBC", ["hellfire", "zangarmarsh", "terokkar", "blade's edge", "netherstorm", "shattrath", "quel'danas", "zul'aman", "netherwing", "skettis"]),
    ("Classic", ["alterac", "winterspring", "silithus", "azshara", "felwood", "un'goro", "plaguelands", "stratholme", "scholomance", "dire maul", "blackrock", "zul'gurub", "ahn'qiraj", "tanaris", "stormwind", "orgrimmar", "ironforge", "darnassus", "thunder bluff", "undercity"]),
]


def expansion(src):
    t = re.sub(r"\|T.+?\|t", "", src or "").lower()
    if "outland" in t:
        return "TBC"
    for exp, kws in EXP_RULES:
        for kw in kws:
            if kw in t:
                return exp
    return "Unknown"
