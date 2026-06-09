#!/usr/bin/env python3
"""Adiciona um `map` (uiMapID da zona de obtencao) as entradas curadas que ainda nao
tem nem `map` nem `coords` (tipicamente DROPS). Resolve a fonte (NPC ou objeto) no
Wowhead e tira o uiMapId do g_mapperData.

Com `map` em todas as entradas, o filtro "Current zone" do addon casa por ID (unico
por zona) em vez de por nome -> imune a colisao Nagrand TBC vs WoD, etc. Sem `map`
(fonte e item/cache, ou nao resolveu), o addon cai no fallback por nome.

Idempotente: pula entradas que ja tem `map` ou `coords`.

Uso:
    python3 tools/enrich_map.py --dry-run
    python3 tools/enrich_map.py
"""

import argparse
import glob
import os
import re
import sys

from mtcurate import extract, wowhead
from mtcurate.http import Http

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "..", "Data")

OPEN_RE = re.compile(r"^\s*\{\s*$")
CLOSE_RE = re.compile(r"^\s*\},\s*$")
SOURCE_RE = re.compile(r'^(\s*)(?:source|vendor)\s*=\s*"((?:[^"\\]|\\.)*)"')
ZONE_RE = re.compile(r'^\s*zone\s*=\s*"((?:[^"\\]|\\.)*)"')
# So pula se ja tem `map`. Entradas com `coords` (vendedor) TAMBEM ganham um `map`
# estrito proprio -- o `coords.map` e nao-estrito (waypoint) e nao serve p/ o filtro.
HAS_MAP_RE = re.compile(r"^\s*map\s*=")
_DIFF = re.compile(r"\s*\((?:Mythic|Heroic|Normal|Raid Finder|Looking For Raid)\)\s*$", re.I)
_RARE = re.compile(r"^(.*?)\s+Rare Creatures$", re.I)


def resolve_map(http, source, zone):
    # "<Zona> Rare Creatures": a zona esta no nome -> deixa o addon resolver por nome
    # (nao da uiMapID confiavel aqui). Idem fontes vazias.
    if not source or _RARE.match(source):
        return None
    name = _DIFF.sub("", source).strip()
    name = re.sub(r"\s*\((?:Alliance|Horde)\)\s*$", "", name).strip()  # tira tag de faccao
    for resolver, pager in ((wowhead.npc_id, wowhead.npc_html),
                            (wowhead.object_id, wowhead.object_html)):
        rid = resolver(http, name)
        if rid:
            # strict: so aceita o uiMapID quando a zona CASA (nao chuta mapa errado).
            co = extract.npc_coords(pager(http, rid), prefer_zone=zone, strict=True)
            if co and co[0]:
                return co[0]
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cache", default=os.path.join(HERE, "cache"))
    ap.add_argument("--delay", type=float, default=0.4)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    http = Http(args.cache, delay=args.delay)
    total = 0
    for path in sorted(glob.glob(os.path.join(DATA, "Mounts_*.lua"))):
        with open(path, encoding="utf-8") as f:
            lines = f.readlines()
        out, block, info = [], None, None
        filled = 0
        for line in lines:
            if block is None:
                if OPEN_RE.match(line):
                    block, info = [line], {"src": None, "zone": None, "indent": "        ",
                                           "idx": None, "has_map": False}
                else:
                    out.append(line)
                continue
            block.append(line)
            idx = len(block) - 1
            m = SOURCE_RE.match(line)
            if m:
                info["indent"], info["src"], info["idx"] = m.group(1), m.group(2), idx
            mz = ZONE_RE.match(line)
            if mz:
                info["zone"] = mz.group(1)
                info["idx"] = idx
            if HAS_MAP_RE.match(line):
                info["has_map"] = True
            if CLOSE_RE.match(line):
                if info["src"] and not info["has_map"]:
                    mid = None
                    try:
                        mid = resolve_map(http, info["src"], info["zone"])
                    except Exception as e:                       # noqa: BLE001
                        sys.stderr.write(f"  {info['src']:30s} ERRO: {e}\n")
                    if mid:
                        filled += 1
                        sys.stderr.write(f"  {info['src']:30s} [{info['zone']}] -> map {mid}\n")
                        block.insert(info["idx"] + 1, f'{info["indent"]}map     = {mid},\n')
                out.extend(block)
                block, info = None, None
        total += filled
        if filled and not args.dry_run:
            with open(path, "w", encoding="utf-8", newline="\n") as f:
                f.writelines(out)
        if filled:
            sys.stderr.write(f"[map] {os.path.basename(path)}: +{filled}\n")
    sys.stderr.write(f"[map] total: {total}{'  (dry-run)' if args.dry_run else ''}\n")


if __name__ == "__main__":
    main()
