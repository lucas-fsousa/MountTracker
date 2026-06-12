#!/usr/bin/env python3
"""Adiciona `requirement` (reputacao/renome) as entradas de VENDEDOR que ainda nao tem
um, colhendo do tooltip do Wowhead -- onde o jogo as vezes ESCONDE o gate (rep hidden).

Sem isso, mounts gated por uma rep que o sourceText nao mostra (ex.: Ivory Hawkstrider =
Exalted com Talon's Vengeance) eram curadas como compra simples e acendiam glow falso.

Idempotente: pula entradas que ja tem `requirement`. So mexe em entradas com vendedor/custo.

Uso:
    python3 tools/enrich_requirement.py --dry-run
    python3 tools/enrich_requirement.py
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
SPELL_RE = re.compile(r"^(\s*)spellID\s*=\s*(\d+)")
NAME_RE = re.compile(r'^\s*name\s*=\s*"((?:[^"\\]|\\.)*)"')
REQ_RE = re.compile(r"^\s*requirement\s*=")
VENDORCOST_RE = re.compile(r"^\s*(?:vendor|cost)\s*=")
MANUAL_RE = re.compile(r"^\s*manualUpdate\s*=\s*true")
INS_RE = re.compile(r"^\s*(?:cost|coords|map|zone|vendor)\s*=")


def fetch_req(http, sid, name):
    req = extract.requirement(wowhead.spell_html(http, sid))
    if not req:
        iid = wowhead.item_id(http, name)
        if iid:
            req = extract.requirement(wowhead.item_html(http, iid))
    return req


def emit_req(req):
    if req["type"] == "renown":
        return ('requirement = { type = "renown", factionID = %d, renownLevel = %d },'
                % (req["factionID"], req["renownLevel"]))
    return ('requirement = { type = "reputation", factionID = %d, standing = "%s" },'
            % (req["factionID"], req["standing"]))


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
                    block, info = [line], {"sid": None, "name": None, "indent": "        ",
                                           "ins": None, "has_req": False, "is_vendor": False,
                                           "manual": False}
                else:
                    out.append(line)
                continue
            block.append(line)
            idx = len(block) - 1
            m = SPELL_RE.match(line)
            if m:
                info["indent"], info["sid"] = m.group(1), int(m.group(2))
            m = NAME_RE.match(line)
            if m:
                info["name"] = m.group(1)
            if REQ_RE.match(line):
                info["has_req"] = True
            if VENDORCOST_RE.match(line):
                info["is_vendor"] = True
            if MANUAL_RE.match(line):
                info["manual"] = True           # entrada curada a mao -> intocavel
            if INS_RE.match(line):
                info["ins"] = idx
            if CLOSE_RE.match(line):
                if (info["sid"] and info["is_vendor"] and not info["has_req"]
                        and info["ins"] and not info["manual"]):
                    req = None
                    try:
                        req = fetch_req(http, info["sid"], info["name"])
                    except Exception as e:                       # noqa: BLE001
                        sys.stderr.write(f"  {info['name']:30s} ERRO: {e}\n")
                    if req and req.get("factionID"):
                        filled += 1
                        sys.stderr.write(f"  {info['name']:30s} -> {req['type']} "
                                         f"faction={req['factionID']} "
                                         f"{req.get('standing') or req.get('renownLevel')}\n")
                        block.insert(info["ins"] + 1, info["indent"] + emit_req(req) + "\n")
                out.extend(block)
                block, info = None, None
        total += filled
        if filled and not args.dry_run:
            with open(path, "w", encoding="utf-8", newline="\n") as f:
                f.writelines(out)
        if filled:
            sys.stderr.write(f"[req] {os.path.basename(path)}: +{filled}\n")
    sys.stderr.write(f"[req] total: {total}{'  (dry-run)' if args.dry_run else ''}\n")


if __name__ == "__main__":
    main()
