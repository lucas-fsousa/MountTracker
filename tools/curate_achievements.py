#!/usr/bin/env python3
"""Auto-cura as montarias liberadas/recompensadas por CONQUISTA que ainda nao tem
overlay, resolvendo achievementID e expansao no Wowhead.

Dirige direto pelo DUMP (idempotente): seleciona as montarias obtiveis (nao
coletadas, nao escondidas) cujo sourceText tem 'Achievement:' e NAO tem 'Vendor:'
(recompensa automatica, sem custo) e que ainda nao estao curadas em outro arquivo.
Resolve achievementID (nome->ID) e expansao ('Added in World of Warcraft: ...') no
Wowhead, e emite entradas Lua agrupadas por expansao.

Uso:
    python3 tools/curate_achievements.py --dump <dump> --lua <lua> > Data/Mounts_Achievements.lua
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
GEN_FILE = "Mounts_Achievements.lua"   # excluido do overlay p/ regeneracao idempotente


def curated_elsewhere(lua_bin):
    """spellIDs ja curados em QUALQUER arquivo, exceto o gerado aqui."""
    out = subprocess.check_output([lua_bin, "tools/dump_curated.lua", GEN_FILE], text=True)
    return {int(x) for x in out.split() if x.strip().isdigit()}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dump", required=True)
    ap.add_argument("--lua", default="lua")
    ap.add_argument("--cache", default=os.path.join(HERE, "cache"))
    ap.add_argument("--delay", type=float, default=0.6)
    args = ap.parse_args()

    http = Http(args.cache, delay=args.delay)
    already = curated_elsewhere(args.lua)

    mounts = dumpmod.load(args.dump, args.lua)
    targets = [m for m in mounts
               if m.get("spellID") and m.get("name")
               and not m.get("collected") and not m.get("shouldHideOnChar")
               and m["spellID"] not in already
               and st.field(m.get("sourceText"), "Achievement")
               and not st.field(m.get("sourceText"), "Vendor")]

    by_exp, unresolved = {}, []
    for m in sorted(targets, key=lambda r: r["name"]):
        sid = m["spellID"]
        src = m.get("sourceText") or ""
        ach_name = st.field(src, "Achievement")
        ach_id = wowhead.achievement_id(http, ach_name) if ach_name else None
        zone = st.field(src, "Zone") or st.field(src, "Location")
        # Expansao confiavel via Wowhead (meta "Added in World of Warcraft: ...").
        # Pela pagina do SPELL (sempre temos o spellID), com fallback pelo item.
        exp = extract.expansion(wowhead.spell_html(http, sid))
        if not exp:
            iid = wowhead.item_id(http, m["name"])
            if iid:
                exp = extract.expansion(wowhead.item_html(http, iid))
        exp = exp or "Unknown"
        sys.stderr.write(f"  {m['name']:30s} [{exp}] ach='{ach_name}' -> {ach_id}\n")
        if not ach_id:
            unresolved.append(m["name"])
            continue

        L = ["    {"]
        L.append(f"        name    = {emit.lua_str(m['name'])},")
        L.append(f"        spellID = {sid},")
        L.append('        acquisition = "achievement",')
        if zone:
            L.append(f"        zone    = {emit.lua_str(zone)},")
        L.append(f"        requirement = {{ type = \"achievement\", achievementID = {ach_id} }},")
        L.append(f'        wowhead = "https://www.wowhead.com/spell={sid}",')
        L.append("    },")
        by_exp.setdefault(exp, []).append("\n".join(L))

    print("-- Data/Mounts_Achievements.lua")
    print("-- Gerado por tools/curate_achievements.py (achievementID resolvido no Wowhead).")
    print("-- Montarias liberadas por conquista (recompensa automatica; sem custo).")
    print("local ADDON, ns = ...\n")
    for exp in sorted(by_exp):
        reg = "nil" if exp == "Unknown" else f'"{exp}"'
        print(f"ns.Data.Register({reg}, {{")
        print("\n".join(by_exp[exp]))
        print("})\n")

    n = sum(len(v) for v in by_exp.values())
    sys.stderr.write(f"[ach] emitidas={n}  nao-resolvidas={len(unresolved)}: {', '.join(unresolved)}\n")


if __name__ == "__main__":
    main()
