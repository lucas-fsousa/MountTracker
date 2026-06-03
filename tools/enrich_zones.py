#!/usr/bin/env python3
"""Enriquece Data/Mounts_Drops.lua com a `zone` dos drops que estao sem ela.

Para cada entrada com `source = "<NPC>"` e SEM `zone`, resolve o NPC no Wowhead e
extrai a zona ("This NPC can be found in ..."). Fontes que sao item (ex.: um ovo)
nao tem zona unica e ficam como estao.

Etiqueta: mesmo Http educado (User-Agent, rate-limit, cache) do curate.py.

Exemplos:
    python3 enrich_zones.py --dry-run            # so relata o que faria
    python3 enrich_zones.py --limit 8 --dry-run  # amostra
    python3 enrich_zones.py                       # patcha o arquivo in-place
"""

import argparse
import os
import re
import sys

from mtcurate import extract, wowhead
from mtcurate.http import Http

HERE = os.path.dirname(__file__)
DROPS = os.path.join(HERE, "..", "Data", "Mounts_Drops.lua")

OPEN_RE = re.compile(r"^\s*\{\s*$")
CLOSE_RE = re.compile(r"^\s*\},\s*$")
NAME_RE = re.compile(r'^\s*name\s*=\s*"((?:[^"\\]|\\.)*)"')
SRC_RE = re.compile(r'^(\s*)source\s*=\s*"((?:[^"\\]|\\.)*)"')
ZONE_RE = re.compile(r"^\s*zone\s*=")


def lua_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


# Sufixos de dificuldade no nome do boss que atrapalham a resolucao do NPC.
_DIFF = re.compile(r"\s*\((Mythic|Heroic|Normal|Raid Finder|Looking For Raid)\)\s*$", re.I)
# Fontes do tipo "<Zona> Rare Creatures" trazem a zona no proprio nome.
_RARE = re.compile(r"^(.*?)\s+Rare Creatures$", re.I)


def resolve_zone(http, source):
    """Zona de um drop. 1) heuristica local '<Zona> Rare Creatures'; 2) se a fonte e
    um NPC/boss, a zona vem da pagina do NPC no Wowhead. Itens-container (caches de
    faccao, baus de feriado, ovos) nao tem zona unica -> retorna None."""
    m = _RARE.match(source)
    if m:
        return m.group(1).strip()
    name = _DIFF.sub("", source).strip()
    nid = wowhead.npc_id(http, name)
    if not nid:
        return None
    return extract.drop_zone(wowhead.npc_html(http, nid))


def main():
    ap = argparse.ArgumentParser(description="Enriquece zonas dos drops via Wowhead")
    ap.add_argument("--file", default=DROPS)
    ap.add_argument("--cache", default=os.path.join(HERE, "cache"))
    ap.add_argument("--delay", type=float, default=1.0)
    ap.add_argument("--limit", type=int, default=0, help="maximo de lookups (0 = todos)")
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    http = Http(args.cache, delay=args.delay)
    with open(args.file, encoding="utf-8") as f:
        lines = f.readlines()

    out, block, binfo = [], None, None
    done = filled = 0

    def finalize(block, binfo):
        nonlocal done, filled
        if binfo["src"] and not binfo["has_zone"]:
            if args.limit and done >= args.limit:
                sys.stderr.write(f"  {binfo['name'] or '?':32s} (limite atingido)\n")
            else:
                done += 1
                zone = None
                try:
                    zone = resolve_zone(http, binfo["src"])
                except Exception as e:                       # noqa: BLE001
                    sys.stderr.write(f"  {binfo['name'] or '?':32s} ERRO: {e}\n")
                tag = zone or "(sem zona / item)"
                sys.stderr.write(f"  {binfo['name'] or '?':32s} <- {binfo['src']:28s} => {tag}\n")
                if zone:
                    filled += 1
                    indent = binfo["indent"]
                    block.insert(binfo["src_idx"] + 1, f"{indent}zone    = {lua_str(zone)},\n")
        return block

    for line in lines:
        if block is None:
            if OPEN_RE.match(line):
                block = [line]
                binfo = {"name": None, "src": None, "src_idx": None,
                         "indent": "        ", "has_zone": False}
            else:
                out.append(line)
            continue

        block.append(line)
        idx = len(block) - 1
        m = NAME_RE.match(line)
        if m:
            binfo["name"] = m.group(1)
        m = SRC_RE.match(line)
        if m:
            binfo["indent"], binfo["src"], binfo["src_idx"] = m.group(1), m.group(2), idx
        if ZONE_RE.match(line):
            binfo["has_zone"] = True
        if CLOSE_RE.match(line):
            out.extend(finalize(block, binfo))
            block, binfo = None, None

    sys.stderr.write(f"[enrich] lookups={done} zonas preenchidas={filled}\n")

    if args.dry_run:
        sys.stderr.write("[enrich] dry-run: nada gravado.\n")
        return
    with open(args.file, "w", encoding="utf-8", newline="\n") as f:
        f.writelines(out)
    sys.stderr.write(f"[enrich] gravado: {args.file}\n")


if __name__ == "__main__":
    main()
