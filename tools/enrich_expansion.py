#!/usr/bin/env python3
"""Seta um `expansion` explicito nas entradas curadas cuja expansao o addon resolve
como "Unknown" (heuristica falhou), consultando o Wowhead (pagina do spell:
"... World of Warcraft: <expansao>"). Torna a expansao autoritativa -> filtro de
expansao e desambiguacao de "Current zone" (continente/expansao) ficam confiaveis.

Alvos: vem do relatorio da varredura (tools/_audit.jsonl) -> curadas + Unknown.
Idempotente: pula entradas que ja tem `expansion`.

Uso:
    lua tools/audit.lua <dump> > tools/_audit.jsonl
    python3 tools/enrich_expansion.py --dry-run
    python3 tools/enrich_expansion.py
"""

import argparse
import glob
import json
import os
import re
import sys

from mtcurate import extract, wowhead
from mtcurate.http import Http

HERE = os.path.dirname(os.path.abspath(__file__))
DATA = os.path.join(HERE, "..", "Data")
AUDIT = os.path.join(HERE, "_audit.jsonl")

OPEN_RE = re.compile(r"^\s*\{\s*$")
CLOSE_RE = re.compile(r"^\s*\},\s*$")
SPELL_RE = re.compile(r"^(\s*)spellID\s*=\s*(\d+)")
EXP_RE = re.compile(r"^\s*expansion\s*=")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--audit", default=AUDIT)
    ap.add_argument("--cache", default=os.path.join(HERE, "cache"))
    ap.add_argument("--delay", type=float, default=0.4)
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    rows = [json.loads(l) for l in open(args.audit, encoding="utf-8") if l.strip()]
    targets = {r["spellID"] for r in rows if r["curated"] and r["expansion"] == "Unknown"}
    sys.stderr.write(f"[exp] alvos (curadas Unknown): {len(targets)}\n")

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
                    block, info = [line], {"sid": None, "indent": "        ",
                                           "idx": None, "has_exp": False}
                else:
                    out.append(line)
                continue
            block.append(line)
            idx = len(block) - 1
            m = SPELL_RE.match(line)
            if m:
                info["indent"], info["sid"], info["idx"] = m.group(1), int(m.group(2)), idx
            if EXP_RE.match(line):
                info["has_exp"] = True
            if CLOSE_RE.match(line):
                if info["sid"] in targets and not info["has_exp"]:
                    exp = None
                    try:
                        exp = extract.expansion(wowhead.spell_html(http, info["sid"]))
                    except Exception as e:                       # noqa: BLE001
                        sys.stderr.write(f"  spell {info['sid']} ERRO: {e}\n")
                    if exp:
                        filled += 1
                        sys.stderr.write(f"  spell {info['sid']:>8} -> {exp}\n")
                        block.insert(info["idx"] + 1, f'{info["indent"]}expansion = "{exp}",\n')
                out.extend(block)
                block, info = None, None
        total += filled
        if filled and not args.dry_run:
            with open(path, "w", encoding="utf-8", newline="\n") as f:
                f.writelines(out)
        if filled:
            sys.stderr.write(f"[exp] {os.path.basename(path)}: +{filled}\n")
    sys.stderr.write(f"[exp] total: {total}{'  (dry-run)' if args.dry_run else ''}\n")


if __name__ == "__main__":
    main()
