#!/usr/bin/env python3
"""Adiciona `coords` (waypoint do vendedor) as entradas curadas que tem `vendor` mas
ainda nao tem `coords`, colhendo do g_mapperData do Wowhead.

Formato emitido:
  coords = { map = <uiMapID>, x, y }     -- conteudo moderno (uiMapId no Wowhead)
  coords = { zone = "<zona>", x, y }     -- conteudo antigo (sem uiMapId; o addon
                                            resolve a zona -> uiMapID em runtime)

Patcha todos os Data/Mounts_*.lua. Idempotente (pula quem ja tem coords).

Uso:
    python3 tools/enrich_coords.py --dry-run
    python3 tools/enrich_coords.py
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
VENDOR_RE = re.compile(r'^(\s*)vendor\s*=\s*"((?:[^"\\]|\\.)*)"')
ZONE_RE = re.compile(r'^\s*zone\s*=\s*"((?:[^"\\]|\\.)*)"')
COORDS_RE = re.compile(r"^\s*coords\s*=")


def resolve(http, vendor, zone):
    name = re.sub(r"\s*\((?:Alliance|Horde)\)\s*$", "", vendor or "").strip()
    nid = wowhead.npc_id(http, name)
    if not nid:
        return None
    return extract.npc_coords(wowhead.npc_html(http, nid), prefer_zone=zone)


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
                    block, info = [line], {"vendor": None, "zone": None, "indent": "        ",
                                           "ins_idx": None, "has_coords": False}
                else:
                    out.append(line)
                continue

            block.append(line)
            idx = len(block) - 1
            m = VENDOR_RE.match(line)
            if m:
                info["indent"], info["vendor"] = m.group(1), m.group(2)
                info["ins_idx"] = idx
            mz = ZONE_RE.match(line)
            if mz:
                info["zone"] = mz.group(1)
                info["ins_idx"] = idx        # insere depois da zona quando houver
            if COORDS_RE.match(line):
                info["has_coords"] = True

            if CLOSE_RE.match(line):
                if info["vendor"] and not info["has_coords"]:
                    co = None
                    try:
                        co = resolve(http, info["vendor"], info["zone"])
                    except Exception as e:                       # noqa: BLE001
                        sys.stderr.write(f"  {info['vendor']:26s} ERRO: {e}\n")
                    if co:
                        cmap, cx, cy = co
                        if cmap:
                            ln = f'{info["indent"]}coords  = {{ map = {cmap}, x = {cx}, y = {cy} }},\n'
                        elif info["zone"]:
                            ln = f'{info["indent"]}coords  = {{ zone = "{info["zone"]}", x = {cx}, y = {cy} }},\n'
                        else:
                            ln = None
                        if ln:
                            filled += 1
                            sys.stderr.write(f"  {info['vendor']:26s} [{info['zone']}] -> {cmap or 'zone'} {cx},{cy}\n")
                            block.insert(info["ins_idx"] + 1, ln)
                out.extend(block)
                block, info = None, None

        total += filled
        if filled and not args.dry_run:
            with open(path, "w", encoding="utf-8", newline="\n") as f:
                f.writelines(out)
        if filled:
            sys.stderr.write(f"[coords] {os.path.basename(path)}: +{filled}\n")

    sys.stderr.write(f"[coords] total: {total}{'  (dry-run)' if args.dry_run else ''}\n")


if __name__ == "__main__":
    main()
