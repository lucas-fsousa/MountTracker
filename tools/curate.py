#!/usr/bin/env python3
"""
MountTracker - tool de curadoria (dump + extracao do Wowhead).

Le o /mtrack dump (SavedVariables), resolve cada montaria no Wowhead (via o
endpoint publico de sugestoes), e extrai o REQUISITO que o jogo nao expoe
(Renome/Reputacao + factionID) + custo (parseado do proprio dump). Emite entradas
Lua prontas para o overlay curado (Data/Mounts_<Expansao>.lua).

Etiqueta: User-Agent identificavel, rate-limit e cache em disco (so busca o que
ainda nao tem em cache). Use com parcimonia, apenas para conteudo novo.

Uso tipico:
    python3 curate.py --dump "/caminho/MountTracker.lua" \
        --filter "Zul'Aman" --expansion Midnight --lua ~/lua-build/lua-5.4.7/src/lua
"""

import argparse
import json
import os
import re
import subprocess
import sys
import time
import urllib.parse
import urllib.request

WH = "https://www.wowhead.com"
UA = ("MountTracker-curate/0.1 (community addon; "
      "https://github.com/lucas-fsousa/MountTracker)")

STANDINGS = ("Exalted", "Revered", "Honored", "Friendly", "Neutral")

# Heuristica de expansao por zona (espelha Logic/Expansion.lua do addon).
EXP_RULES = [
    ("TWW", ["k'aresh", "kʼaresh", "isle of dorn", "dornogal", "ringing deeps", "azj-kahet", "hallowfall", "undermine", "city of threads", "khaz algar", "siren isle"]),
    ("Dragonflight", ["emerald dream", "thaldraszus", "ohn'ahran", "azure span", "waking shores", "zaralek", "forbidden reach", "valdrakken", "dragon isles", "amirdrassil"]),
    ("Shadowlands", ["oribos", "bastion", "maldraxxus", "ardenweald", "revendreth", "the maw", "korthia", "zereth mortis", "torghast"]),
    ("BfA", ["zuldazar", "nazmir", "vol'dun", "tiragarde", "drustvar", "stormsong", "nazjatar", "mechagon", "boralus", "dazar'alor", "zandalar", "kul tiras"]),
    ("Legion", ["suramar", "val'sharah", "highmountain", "stormheim", "azsuna", "broken shore", "argus", "mac'aree", "antoran", "krokuun", "trueshot lodge", "broken isles"]),
    ("WoD", ["draenor", "tanaan", "frostfire", "gorgrond", "talador", "spires of arak", "warspear", "stormshield", "ashran", "shadowmoon valley", "nagrand"]),
    ("MoP", ["pandaria", "jade forest", "valley of the four winds", "kun-lai", "townlong", "dread wastes", "vale of eternal", "timeless isle", "krasarang", "isle of thunder", "mogu"]),
    ("Cataclysm", ["mount hyjal", "vashj'ir", "deepholm", "uldum", "twilight highlands", "tol barad", "firelands", "gilneas"]),
    ("WotLK", ["northrend", "icecrown", "storm peaks", "sholazar", "grizzly hills", "howling fjord", "borean tundra", "dragonblight", "zul'drak", "crystalsong", "wintergrasp", "argent tournament", "argent crusade", "dalaran"]),
    ("TBC", ["hellfire", "zangarmarsh", "terokkar", "blade's edge", "netherstorm", "shattrath", "quel'danas", "zul'aman", "netherwing", "skettis"]),
    ("Classic", ["alterac", "winterspring", "silithus", "azshara", "felwood", "un'goro", "plaguelands", "stratholme", "scholomance", "dire maul", "blackrock", "zul'gurub", "ahn'qiraj", "tanaris", "stormwind", "orgrimmar", "ironforge", "darnassus", "thunder bluff", "undercity"]),
]


def classify_expansion(source_text):
    t = re.sub(r"\|T.+?\|t", "", source_text or "").lower()
    if "outland" in t:
        return "TBC"
    for exp, kws in EXP_RULES:
        for kw in kws:
            if kw in t:
                return exp
    return "Unknown"


# ----------------------------------------------------------------------------- IO

def load_dump(dump_path, lua_bin):
    """Converte o SavedVariables em registros via o conversor Lua (JSONL)."""
    conv = os.path.join(os.path.dirname(os.path.abspath(__file__)), "dump_to_json.lua")
    out = subprocess.check_output([lua_bin, conv, dump_path], text=True)
    return [json.loads(line) for line in out.splitlines() if line.strip()]


def http_get(url, cache_dir, delay, retries=3):
    """GET com cache em disco, rate-limit e retry com backoff. Retorna o corpo (str)."""
    os.makedirs(cache_dir, exist_ok=True)
    key = re.sub(r"[^a-zA-Z0-9]+", "_", url)[:180]
    path = os.path.join(cache_dir, key)
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            return f.read()
    last = None
    for attempt in range(retries):
        try:
            time.sleep(delay)  # so dorme quando realmente bate na rede
            req = urllib.request.Request(url, headers={"User-Agent": UA})
            body = urllib.request.urlopen(req, timeout=30).read().decode("utf-8", "replace")
            with open(path, "w", encoding="utf-8") as f:
                f.write(body)
            return body
        except Exception as e:           # noqa: BLE001 (queremos tolerar qualquer falha de rede)
            last = e
            time.sleep(1.5 * (attempt + 1))
    raise last


# ------------------------------------------------------------------- Wowhead bits

def resolve_item_id(name, cache_dir, delay):
    """Resolve o itemID exato pelo nome via o endpoint publico de sugestoes."""
    url = f"{WH}/search/suggestions-template?q=" + urllib.parse.quote(name)
    try:
        data = json.loads(http_get(url, cache_dir, delay))
    except Exception:
        return None
    for r in data.get("results", []):
        if r.get("typeName") == "Item" and r.get("name", "").lower() == name.lower():
            return r.get("id")
    return None


def _norm(s):
    return re.sub(r"['’ʼ`]", "'", s or "").strip().lower()


def extract_requirement(item_html):
    """Extrai requisito da pagina de item. Captura o factionID direto do link
    quando a faccao e hyperlinkada; senao guarda o nome para resolver depois."""
    for kind, pat in (("renown", r"Renown Rank (\d+) with (?:the )?"),
                      ("reputation", r"Requires (%s) with (?:the )?" % "|".join(STANDINGS))):
        m = re.search(pat, item_html)
        if not m:
            continue
        tail = item_html[m.end():m.end() + 160]
        fid = None
        fm = re.search(r"faction=(\d+)", tail)
        if fm:
            fid = int(fm.group(1))
        nm = re.search(r">([^<]+)</a>", tail) or re.search(r"^\s*([^.<]+)", tail)
        fname = nm.group(1).strip() if nm else None
        req = {"type": kind, "factionID": fid, "faction": fname}
        if kind == "renown":
            req["renownLevel"] = int(m.group(1))
        else:
            req["standing"] = m.group(1)
        return req
    return None


def extract_drop_chance(item_html):
    """Estima a chance de drop pela maior amostra (count/outof) da pagina de item.
    ~1.0 = drop garantido (raro elite); valores baixos = RNG."""
    best = None
    for c, o in re.findall(r'"count":(\d+)[^{}]{0,40}?"outof":(\d+)', item_html):
        c, o = int(c), int(o)
        if o > 0 and (best is None or o > best[1]):
            best = (c, o)
    if best:
        return min(best[0] / best[1], 1.0)
    return None


def resolve_faction_id(name, cache_dir, delay):
    """Resolve o factionID pelo nome via o endpoint de sugestoes (tolerante a apostrofo)."""
    if not name:
        return None
    url = f"{WH}/search/suggestions-template?q=" + urllib.parse.quote(name)
    try:
        data = json.loads(http_get(url, cache_dir, delay))
    except Exception:
        return None
    factions = [r for r in data.get("results", []) if r.get("typeName") == "Faction"]
    for r in factions:
        if _norm(r.get("name")) == _norm(name):
            return r.get("id")
    return factions[0].get("id") if factions else None


# ----------------------------------------------------------------- sourceText bits

def st_field(src, label):
    m = re.search(re.escape(label) + r":\s*\|r\s*([^|]+)", src or "")
    return m.group(1).strip() if m else None


def requirement_from_sourcetext(src):
    """Extrai requisito do proprio sourceText do jogo (confiavel): garrison WoD/BfA
    e afins trazem 'Faction: X - Exalted' ou 'Faction: X ... Renown: N'."""
    fac = st_field(src, "Faction")
    if not fac:
        return None
    ren = st_field(src, "Renown")
    if ren and ren.strip().isdigit():
        return {"type": "renown", "factionID": None, "faction": fac.strip(), "renownLevel": int(ren.strip())}
    m = re.match(r"(.+?)\s*-\s*(%s)\s*$" % "|".join(STANDINGS), fac.strip())
    if m:
        return {"type": "reputation", "factionID": None, "faction": m.group(1).strip(), "standing": m.group(2)}
    return None


def parse_costs(src):
    s = (src or "").replace(",", "")
    costs = []
    for amount, ctype, cid in re.findall(r"(\d+)\|H(currency|item):(\d+)\|h\|T.+?\|t\|h", s):
        costs.append({"amount": int(amount), "ctype": ctype, "id": int(cid)})
    if not costs:
        for amount in re.findall(r"(\d+)\|T[^|]*?(?:MoneyFrame|GoldIcon)[^|]*?\|t", s, re.I):
            costs.append({"amount": int(amount), "ctype": "gold", "id": None})
    return costs


# ------------------------------------------------------------------- Lua emitting

def lua_str(s):
    return '"' + (s or "").replace("\\", "\\\\").replace('"', '\\"') + '"'


def emit_entry(rec, req, fid, costs, drop_chance=None):
    src = rec.get("sourceText") or ""
    L = ["    {"]
    L.append(f"        name    = {lua_str(rec['name'])},")
    L.append(f"        spellID = {rec['spellID']},")
    is_drop = (drop_chance is not None) or (not req and "Drop:" in src)
    acq = "reputation" if req else ("drop" if is_drop else "vendor")
    L.append(f'        acquisition = "{acq}",')
    vendor = st_field(src, "Vendor")
    zone = st_field(src, "Zone") or st_field(src, "Location")
    drop_src = st_field(src, "Drop")
    if vendor:
        L.append(f"        vendor  = {lua_str(vendor)},")
    elif drop_src:
        L.append(f"        source  = {lua_str(drop_src)},")
    if zone:
        L.append(f"        zone    = {lua_str(zone)},")
    if drop_chance is not None:
        L.append("        dropChance = %.4f," % drop_chance)
    if req:
        if req["type"] == "renown":
            if fid:
                L.append('        requirement = { type = "renown", factionID = %d, renownLevel = %d },'
                         % (fid, req["renownLevel"]))
            else:  # sem ID -> factionName (resolvido em runtime via C_MajorFactions)
                L.append('        requirement = { type = "renown", factionName = %s, renownLevel = %d },'
                         % (lua_str(req.get("faction") or ""), req["renownLevel"]))
        else:
            L.append('        requirement = { type = "reputation", factionID = %s, standing = "%s" },'
                     % (fid if fid else "nil --[[ VERIFICAR ]]", req["standing"]))
    c = costs[0] if costs else None
    if c and c["ctype"] == "currency":
        L.append("        cost    = { currencyID = %d, amount = %d }," % (c["id"], c["amount"]))
    elif c and c["ctype"] == "gold":
        L.append("        cost    = { gold = %d }," % c["amount"])
    elif c and c["ctype"] == "item":
        L.append("        -- cost item:%d x%d (Eligibility ainda nao checa itemID)" % (c["id"], c["amount"]))
    L.append(f'        wowhead = "https://www.wowhead.com/spell={rec["spellID"]}",')
    L.append("    },")
    return "\n".join(L)


# -------------------------------------------------------------------------- main

def main():
    ap = argparse.ArgumentParser(description="MountTracker curation tool")
    ap.add_argument("--dump", required=True, help="caminho do SavedVariables MountTracker.lua")
    ap.add_argument("--lua", default="lua", help="binario lua para converter o dump")
    ap.add_argument("--filter", default="", help="substring (nome ou sourceText) para filtrar candidatos")
    ap.add_argument("--expansion-only", default="", help="processa so montarias dessa expansao (heuristica de zona)")
    ap.add_argument("--cache", default=os.path.join(os.path.dirname(__file__), "cache"))
    ap.add_argument("--delay", type=float, default=1.0, help="segundos entre requisicoes (rate-limit)")
    ap.add_argument("--limit", type=int, default=0, help="maximo de montarias a processar (0 = todas)")
    ap.add_argument("--include-collected", action="store_true")
    ap.add_argument("--has-cost", action="store_true", help="so montarias com 'Cost:' no sourceText")
    ap.add_argument("--include-drops", action="store_true", help="inclui drops (extrai dropChance)")
    ap.add_argument("--only-with-requirement", action="store_true", help="emite so as que tem requisito ou dropChance")
    args = ap.parse_args()

    mounts = load_dump(args.dump, args.lua)
    flt = args.filter.lower()
    cands = []
    for m in mounts:
        if not m.get("name"):
            continue
        if not args.include_collected and m.get("collected"):
            continue
        if m.get("shouldHideOnChar"):
            continue
        src = m.get("sourceText") or ""
        if args.has_cost and "Cost:" not in src and not (args.include_drops and "Drop:" in src):
            continue
        m["_exp"] = classify_expansion(m.get("sourceText"))
        if args.expansion_only and m["_exp"] != args.expansion_only:
            continue
        blob = (m.get("name", "") + " " + (m.get("sourceText") or "")).lower()
        if flt and flt not in blob:
            continue
        cands.append(m)
    if args.limit:
        cands = cands[: args.limit]

    sys.stderr.write(f"[curate] {len(cands)} candidato(s)\n")
    by_exp, no_req = {}, []
    for m in cands:
        name = m["name"]
        try:
            item_id = resolve_item_id(name, args.cache, args.delay)
            req, fid, drop_chance = None, None, None
            html = None
            if item_id:                                         # 1) tooltip do item (renome moderno)
                html = http_get(f"{WH}/item={item_id}", args.cache, args.delay)
                req = extract_requirement(html)
            if not req:                                         # 2) sourceText do jogo (rep/garrison)
                req = requirement_from_sourcetext(m.get("sourceText"))
            if req:
                fid = req.get("factionID") or resolve_faction_id(req["faction"], args.cache, args.delay)
            elif html and "Drop:" in (m.get("sourceText") or ""):  # 3) drop chance
                drop_chance = extract_drop_chance(html)
        except Exception as e:                       # noqa: BLE001
            sys.stderr.write(f"  {name:32s} ERRO: {e} (pulando)\n")
            continue
        costs = parse_costs(m.get("sourceText"))
        tag = (f"renown {req['renownLevel']}" if req and req["type"] == "renown"
               else (req["standing"] if req else ("drop %.1f%%" % (100 * drop_chance) if drop_chance else "-")))
        sys.stderr.write(f"  {name:32s} [{m['_exp']}] item={item_id} req={tag} faction={fid}\n")
        if not req and drop_chance is None:
            no_req.append(name)
        if args.only_with_requirement and not req and drop_chance is None:
            continue
        by_exp.setdefault(m["_exp"], []).append(emit_entry(m, req, fid, costs, drop_chance))

    print("-- Gerado por tools/curate.py (revise antes de commitar)\nlocal ADDON, ns = ...\n")
    for exp in sorted(by_exp):
        print(f'ns.Data.Register("{exp}", {{')
        print("\n".join(by_exp[exp]))
        print("})\n")
    if no_req:
        sys.stderr.write(f"[curate] sem requisito detectado ({len(no_req)}): {', '.join(no_req)}\n")


if __name__ == "__main__":
    main()
