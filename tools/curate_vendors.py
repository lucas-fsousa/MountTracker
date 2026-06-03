#!/usr/bin/env python3
"""Auto-cura montarias de VENDEDOR sem custo no overlay, resolvendo no Wowhead o
custo (listview 'sold-by'), o factionID (se houver gate de reputacao/renome) e a
expansao. Dirigido pelo dump (idempotente).

Custo: NUNCA emite uma entrada de vendedor SEM custo (curar sem custo = glow falso de
"pode comprar"). Se o custo nao resolver com confianca, a montaria e pulada e listada.

Uso:
    python3 tools/curate_vendors.py --dump <dump> --lua <lua> [--dry-run]
    python3 tools/curate_vendors.py --dump <dump> --lua <lua> > Data/Mounts_Vendors.lua
"""

import argparse
import os
import subprocess
import sys

from mtcurate import dump as dumpmod
from mtcurate import emit
from mtcurate import extract
from mtcurate import sourcetext as st
from mtcurate import wowhead
from mtcurate.http import Http

HERE = os.path.dirname(os.path.abspath(__file__))
GEN_FILE = "Mounts_Vendors.lua"


def curated_elsewhere(lua_bin):
    out = subprocess.check_output([lua_bin, "tools/dump_curated.lua", GEN_FILE], text=True)
    return {int(x) for x in out.split() if x.strip().isdigit()}


def resolve_cost(http, mount_name, src):
    """Custo curado {currencyID|itemID|gold, amount} ou None. Tenta o sourceText
    (confiavel) e, se vazio, a listview 'sold-by' do Wowhead."""
    sc = st.costs(src)
    if sc:
        c = sc[0]
        if c["ctype"] == "currency":
            return {"currencyID": c["id"], "amount": c["amount"]}, "currency(src)"
        if c["ctype"] == "item":
            return {"itemID": c["id"], "amount": c["amount"]}, "item(src)"
        if c["ctype"] == "gold":
            return {"gold": c["amount"]}, "gold(src)"
    iid = wowhead.item_id(http, mount_name)
    if not iid:
        return None, "no-item"
    sold = extract.sold_cost(wowhead.item_html(http, iid))
    if not sold:
        return None, "no-cost"
    money, ids = sold
    if money and not ids:
        return {"gold": money // 10000}, "gold(wh)"
    if ids:
        cid, cnt = ids[0]
        kind, _name = wowhead.cost_kind(http, cid)
        key = "currencyID" if kind == "currency" else "itemID"
        return {key: cid, "amount": cnt}, f"{kind}(wh)"
    return None, "empty"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dump", required=True)
    ap.add_argument("--lua", default="lua")
    ap.add_argument("--cache", default=os.path.join(HERE, "cache"))
    ap.add_argument("--delay", type=float, default=0.6)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    http = Http(args.cache, delay=args.delay)
    already = curated_elsewhere(args.lua)

    mounts = dumpmod.load(args.dump, args.lua)
    targets = [m for m in mounts
               if m.get("spellID") and m.get("name")
               and not m.get("collected") and not m.get("shouldHideOnChar")
               and m["spellID"] not in already
               and st.field(m.get("sourceText"), "Vendor")]

    by_exp, skipped = {}, []
    for m in sorted(targets, key=lambda r: r["name"]):
        sid, src = m["spellID"], m.get("sourceText") or ""
        vendor = st.field(src, "Vendor")
        zone = st.field(src, "Zone") or st.field(src, "Location")
        cost, how = resolve_cost(http, m["name"], src)
        req = st.requirement(src)
        fid = None
        if req:
            fid = req.get("factionID") or wowhead.faction_id(http, req.get("faction"))
        exp = extract.expansion(wowhead.spell_html(http, sid)) or "Unknown"

        costtxt = (",".join(f"{k}={v}" for k, v in cost.items()) if cost else "NENHUM")
        sys.stderr.write(f"  {m['name']:30s} [{exp}] vendor={vendor} cost={costtxt} ({how})"
                         f"{' req=' + req['type'] + '/' + str(fid) if req else ''}\n")

        if not cost:
            skipped.append(m["name"])
            continue

        L = ["    {"]
        L.append(f"        name    = {emit.lua_str(m['name'])},")
        L.append(f"        spellID = {sid},")
        L.append(f'        acquisition = "{"reputation" if req else "vendor"}",')
        if vendor:
            L.append(f"        vendor  = {emit.lua_str(vendor)},")
        if zone:
            L.append(f"        zone    = {emit.lua_str(zone)},")
        if req and req["type"] == "renown":
            fpart = f"factionID = {fid}" if fid else f'factionName = {emit.lua_str(req.get("faction") or "")}'
            L.append(f'        requirement = {{ type = "renown", {fpart}, renownLevel = {req["renownLevel"]} }},')
        elif req and req["type"] == "reputation":
            fpart = f"factionID = {fid}" if fid else "factionID = nil --[[ VERIFICAR ]]"
            L.append(f'        requirement = {{ type = "reputation", {fpart}, standing = "{req["standing"]}" }},')
        cparts = ", ".join(f"{k} = {v}" for k, v in cost.items())
        L.append(f"        cost    = {{ {cparts} }},")
        L.append(f'        wowhead = "https://www.wowhead.com/spell={sid}",')
        L.append("    },")
        by_exp.setdefault(exp, []).append("\n".join(L))

    if not args.dry_run:
        print("-- Data/Mounts_Vendors.lua")
        print("-- Gerado por tools/curate_vendors.py (custo/factionID/expansao via Wowhead).")
        print("local ADDON, ns = ...\n")
        for exp in sorted(by_exp):
            # Bucket "Unknown": Register(nil) -> deixa a heuristica de runtime derivar
            # a expansao do sourceText (nao forca "Unknown" sobre um palpite melhor).
            reg = "nil" if exp == "Unknown" else f'"{exp}"'
            print(f"ns.Data.Register({reg}, {{")
            print("\n".join(by_exp[exp]))
            print("})\n")

    n = sum(len(v) for v in by_exp.values())
    sys.stderr.write(f"[vendors] emitidas={n}  puladas(sem custo)={len(skipped)}: {', '.join(skipped)}\n")


if __name__ == "__main__":
    main()
