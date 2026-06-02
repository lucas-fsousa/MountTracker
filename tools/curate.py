#!/usr/bin/env python3
"""
MountTracker - tool de curadoria (dump + extracao do Wowhead).

CLI/orquestracao. A logica vive no pacote `mtcurate` (modulos especializados):
  http / dump / wowhead / sourcetext / extract / emit.

Le o /mtrack dump, resolve cada montaria no Wowhead, extrai o REQUISITO que o jogo
nao expoe (Renome/Reputacao + factionID), drop chance e custo, e emite entradas
Lua para o overlay curado (Data/Mounts_<Expansao>.lua).

Etiqueta: User-Agent identificavel, rate-limit e cache em disco. Use com parcimonia.

Exemplo:
    python3 curate.py --dump "/.../MountTracker.lua" --has-cost \
        --only-with-requirement --lua ~/lua-build/lua-5.4.7/src/lua
"""

import argparse
import os
import sys

from mtcurate import dump, emit, extract, sourcetext as st, wowhead
from mtcurate.http import Http


def select_candidates(mounts, args):
    """Filtra e classifica os candidatos a curar."""
    flt = args.filter.lower()
    out = []
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
        m["_exp"] = st.expansion(src)
        if args.expansion_only and m["_exp"] != args.expansion_only:
            continue
        blob = (m.get("name", "") + " " + src).lower()
        if flt and flt not in blob:
            continue
        out.append(m)
    if args.limit:
        out = out[: args.limit]
    return out


def resolve(http, m, want_drops):
    """Resolve requisito (item->tooltip, senao sourceText), factionID e dropChance."""
    req, fid, drop_chance, html = None, None, None, None
    iid = wowhead.item_id(http, m["name"])
    if iid:
        html = wowhead.item_html(http, iid)
        req = extract.requirement(html)
    if not req:
        req = st.requirement(m.get("sourceText"))
    if req:
        fid = req.get("factionID") or wowhead.faction_id(http, req["faction"])
    elif want_drops and html and "Drop:" in (m.get("sourceText") or ""):
        drop_chance = extract.drop_chance(html)
    return iid, req, fid, drop_chance


def main():
    ap = argparse.ArgumentParser(description="MountTracker curation tool")
    ap.add_argument("--dump", required=True, help="caminho do SavedVariables MountTracker.lua")
    ap.add_argument("--lua", default="lua", help="binario lua para converter o dump")
    ap.add_argument("--filter", default="", help="substring (nome ou sourceText) para filtrar")
    ap.add_argument("--expansion-only", default="", help="so montarias dessa expansao (heuristica)")
    ap.add_argument("--cache", default=os.path.join(os.path.dirname(__file__), "cache"))
    ap.add_argument("--delay", type=float, default=1.0, help="segundos entre requisicoes")
    ap.add_argument("--limit", type=int, default=0, help="maximo a processar (0 = todas)")
    ap.add_argument("--include-collected", action="store_true")
    ap.add_argument("--has-cost", action="store_true", help="so montarias com 'Cost:' no sourceText")
    ap.add_argument("--include-drops", action="store_true", help="inclui drops (extrai dropChance)")
    ap.add_argument("--only-with-requirement", action="store_true", help="emite so req ou dropChance")
    args = ap.parse_args()

    http = Http(args.cache, delay=args.delay)
    cands = select_candidates(dump.load(args.dump, args.lua), args)
    sys.stderr.write(f"[curate] {len(cands)} candidato(s)\n")

    by_exp, no_req = {}, []
    for m in cands:
        name = m["name"]
        try:
            iid, req, fid, drop_chance = resolve(http, m, args.include_drops)
        except Exception as e:                       # noqa: BLE001
            sys.stderr.write(f"  {name:32s} ERRO: {e} (pulando)\n")
            continue
        tag = (f"renown {req['renownLevel']}" if req and req["type"] == "renown"
               else (req["standing"] if req
                     else ("drop %.1f%%" % (100 * drop_chance) if drop_chance else "-")))
        sys.stderr.write(f"  {name:32s} [{m['_exp']}] item={iid} req={tag} faction={fid}\n")

        if not req and drop_chance is None:
            no_req.append(name)
        if args.only_with_requirement and not req and drop_chance is None:
            continue
        costs = st.costs(m.get("sourceText"))
        by_exp.setdefault(m["_exp"], []).append(emit.entry(m, req, fid, costs, drop_chance))

    print("-- Gerado por tools/curate.py (revise antes de commitar)\nlocal ADDON, ns = ...\n")
    for exp in sorted(by_exp):
        print(f'ns.Data.Register("{exp}", {{')
        print("\n".join(by_exp[exp]))
        print("})\n")
    if no_req:
        sys.stderr.write(f"[curate] sem requisito ({len(no_req)}): {', '.join(no_req)}\n")


if __name__ == "__main__":
    main()
