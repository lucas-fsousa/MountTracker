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


# ----------------------------------------------------------------------------- IO

def load_dump(dump_path, lua_bin):
    """Converte o SavedVariables em registros via o conversor Lua (JSONL)."""
    conv = os.path.join(os.path.dirname(os.path.abspath(__file__)), "dump_to_json.lua")
    out = subprocess.check_output([lua_bin, conv, dump_path], text=True)
    return [json.loads(line) for line in out.splitlines() if line.strip()]


def http_get(url, cache_dir, delay):
    """GET com cache em disco e rate-limit. Retorna o corpo (str)."""
    os.makedirs(cache_dir, exist_ok=True)
    key = re.sub(r"[^a-zA-Z0-9]+", "_", url)[:180]
    path = os.path.join(cache_dir, key)
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            return f.read()
    time.sleep(delay)  # so dorme quando realmente bate na rede
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    body = urllib.request.urlopen(req, timeout=30).read().decode("utf-8", "replace")
    with open(path, "w", encoding="utf-8") as f:
        f.write(body)
    return body


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


def extract_requirement(item_html):
    """Extrai (type, factionName, standing|renownLevel) da pagina de item."""
    m = re.search(r"Renown Rank (\d+) with (?:the )?([^.<]+?)[.<]", item_html)
    if m:
        return {"type": "renown", "faction": m.group(2).strip(), "renownLevel": int(m.group(1))}
    m = re.search(r"Requires (%s) with (?:the )?([^.<]+?)[.<]" % "|".join(STANDINGS), item_html)
    if m:
        return {"type": "reputation", "faction": m.group(2).strip(), "standing": m.group(1)}
    return None


def resolve_faction_id(name, cache_dir, delay):
    """Resolve o factionID exato pelo nome via o endpoint de sugestoes."""
    if not name:
        return None
    url = f"{WH}/search/suggestions-template?q=" + urllib.parse.quote(name)
    try:
        data = json.loads(http_get(url, cache_dir, delay))
    except Exception:
        return None
    for r in data.get("results", []):
        if r.get("typeName") == "Faction" and r.get("name", "").lower() == name.lower():
            return r.get("id")
    return None


# ----------------------------------------------------------------- sourceText bits

def st_field(src, label):
    m = re.search(re.escape(label) + r":\s*\|r\s*([^|]+)", src or "")
    return m.group(1).strip() if m else None


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


def emit_entry(rec, req, fid, costs):
    L = ["    {"]
    L.append(f"        name    = {lua_str(rec['name'])},")
    L.append(f"        spellID = {rec['spellID']},")
    acq = "reputation" if req else ("drop" if (rec.get("sourceText") or "").find("Drop:") >= 0 else "vendor")
    L.append(f'        acquisition = "{acq}",')
    vendor = st_field(rec.get("sourceText"), "Vendor")
    zone = st_field(rec.get("sourceText"), "Zone") or st_field(rec.get("sourceText"), "Location")
    if vendor:
        L.append(f"        vendor  = {lua_str(vendor)},")
    if zone:
        L.append(f"        zone    = {lua_str(zone)},")
    if req:
        if req["type"] == "renown":
            L.append("        requirement = { type = \"renown\", factionID = %s, renownLevel = %d },"
                     % (fid if fid else "nil --[[ VERIFICAR ]]", req["renownLevel"]))
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
    ap.add_argument("--expansion", default="Unknown", help="rotulo da expansao para o Register()")
    ap.add_argument("--cache", default=os.path.join(os.path.dirname(__file__), "cache"))
    ap.add_argument("--delay", type=float, default=1.0, help="segundos entre requisicoes (rate-limit)")
    ap.add_argument("--limit", type=int, default=0, help="maximo de montarias a processar (0 = todas)")
    ap.add_argument("--include-collected", action="store_true")
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
        blob = (m.get("name", "") + " " + (m.get("sourceText") or "")).lower()
        if flt and flt not in blob:
            continue
        cands.append(m)
    if args.limit:
        cands = cands[: args.limit]

    sys.stderr.write(f"[curate] {len(cands)} candidato(s)\n")
    entries, no_req = [], []
    for m in cands:
        name = m["name"]
        item_id = resolve_item_id(name, args.cache, args.delay)
        req, fid = None, None
        if item_id:
            html = http_get(f"{WH}/item={item_id}", args.cache, args.delay)
            req = extract_requirement(html)
            if req:
                fid = resolve_faction_id(req["faction"], args.cache, args.delay)
        costs = parse_costs(m.get("sourceText"))
        entries.append(emit_entry(m, req, fid, costs))
        tag = (f"renown {req['renownLevel']}" if req and req["type"] == "renown"
               else (req["standing"] if req else "-"))
        sys.stderr.write(f"  {name:32s} item={item_id} req={tag} faction={fid}\n")
        if not req:
            no_req.append(name)

    print(f'-- Gerado por tools/curate.py (revise antes de commitar)\nlocal ADDON, ns = ...\n')
    print(f'ns.Data.Register("{args.expansion}", {{')
    print("\n".join(entries))
    print("})")
    if no_req:
        sys.stderr.write(f"[curate] sem requisito detectado ({len(no_req)}): {', '.join(no_req)}\n")


if __name__ == "__main__":
    main()
