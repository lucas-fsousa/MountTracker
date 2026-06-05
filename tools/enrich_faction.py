#!/usr/bin/env python3
"""Adiciona o campo `faction` ("Alliance"/"Horde") as entradas curadas que sao
restritas a uma faccao, lendo o "side" da pagina de item do Wowhead.

Montarias account-wide cuja AQUISICAO e de uma so faccao (ex.: reputacao Ankoan =
Alliance) nao sao flagadas pelo jogo, entao apareciam para a faccao errada. Com o
`faction` curado, a Eligibility as esconde para a faccao oposta.

Mounts sem restricao (side 0/3 = ambos) nao recebem o campo.

Uso:
    python3 tools/enrich_faction.py --dry-run        # so relata
    python3 tools/enrich_faction.py                   # patcha os Data/Mounts_*.lua
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
NAME_RE = re.compile(r'^(\s*)name\s*=\s*"((?:[^"\\]|\\.)*)"')
FACTION_RE = re.compile(r"^\s*faction\s*=")


def side_of(http, name):
    iid = wowhead.item_id(http, name)
    if not iid:
        return None
    return extract.faction_side(wowhead.item_html(http, iid))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--cache", default=os.path.join(HERE, "cache"))
    ap.add_argument("--delay", type=float, default=0.5)
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
                    block, info = [line], {"name": None, "indent": "        ",
                                           "name_idx": None, "has_faction": False}
                else:
                    out.append(line)
                continue

            block.append(line)
            idx = len(block) - 1
            m = NAME_RE.match(line)
            if m:
                info["indent"], info["name"], info["name_idx"] = m.group(1), m.group(2), idx
            if FACTION_RE.match(line):
                info["has_faction"] = True

            if CLOSE_RE.match(line):
                if info["name"] and not info["has_faction"]:
                    side = None
                    try:
                        side = side_of(http, info["name"])
                    except Exception as e:                       # noqa: BLE001
                        sys.stderr.write(f"  {info['name']:30s} ERRO: {e}\n")
                    if side:
                        filled += 1
                        sys.stderr.write(f"  {info['name']:30s} -> {side}\n")
                        block.insert(info["name_idx"] + 1,
                                     f'{info["indent"]}faction = "{side}",\n')
                out.extend(block)
                block, info = None, None

        total += filled
        if filled and not args.dry_run:
            with open(path, "w", encoding="utf-8", newline="\n") as f:
                f.writelines(out)
        if filled:
            sys.stderr.write(f"[faction] {os.path.basename(path)}: +{filled}\n")

    sys.stderr.write(f"[faction] total marcadas: {total}{'  (dry-run)' if args.dry_run else ''}\n")


if __name__ == "__main__":
    main()
