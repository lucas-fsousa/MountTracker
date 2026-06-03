#!/usr/bin/env python3
"""Formata o JSONL da varredura (tools/audit.lua) em um relatorio legivel por tiers.

Uso:
    lua tools/audit.lua <dump> > tools/_audit.jsonl
    python3 tools/audit_report.py            # imprime resumo + lista
    python3 tools/audit_report.py --md FILE  # grava relatorio em Markdown
"""

import argparse
import json
import os
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
JSONL = os.path.join(HERE, "_audit.jsonl")

EXP_ORDER = ["Classic", "TBC", "WotLK", "Cataclysm", "MoP", "WoD", "Legion",
             "BfA", "Shadowlands", "Dragonflight", "TWW", "Midnight", "Unknown"]


def has_gate(r):
    return any(x.startswith("gate:") for x in r["missing"].split(","))


def tier(r):
    miss = r["missing"].split(",")
    if has_gate(r):
        return 1  # gate sem curadoria -> nunca da glow (critico p/ a feature matadora)
    if "cost" in miss:
        return 2  # vendedor sem custo identificado
    if "zone" in miss:
        return 3  # sem zona (so localizacao)
    return 4      # expansao desconhecida


TIER_NAME = {
    1: "TIER 1 - gate de requisito sem curadoria (NAO da glow quando cumprido)",
    2: "TIER 2 - vendedor sem custo identificado",
    3: "TIER 3 - sem zona (localizacao)",
    4: "TIER 4 - expansao desconhecida",
}


def exp_key(e):
    return EXP_ORDER.index(e) if e in EXP_ORDER else len(EXP_ORDER)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--jsonl", default=JSONL)
    ap.add_argument("--md", default="")
    args = ap.parse_args()

    rows = [json.loads(l) for l in open(args.jsonl, encoding="utf-8") if l.strip()]
    for r in rows:
        r["_tier"] = tier(r)

    out = []
    def w(s=""):
        out.append(s)

    w(f"# Auditoria de montarias incompletas — {len(rows)} de 448 obtiveis\n")
    w("Resumo por tier (1 = mais critico):\n")
    tc = Counter(r["_tier"] for r in rows)
    for t in sorted(tc):
        w(f"- **{TIER_NAME[t]}**: {tc[t]}")
    w("")
    g = Counter(r["gate"] for r in rows if has_gate(r))
    w("Gates (tier 1) por tipo: " + ", ".join(f"{k}={v}" for k, v in g.items()))
    t1 = [r for r in rows if has_gate(r)]
    t1v = [r for r in t1 if r["isVendor"]]
    w(f"Tier 1 com VENDEDOR (glow relevante: precisa ID do requisito + custo): {len(t1v)}")
    w(f"Tier 1 sem vendedor (recompensa automatica da conquista; glow nao se aplica): {len(t1) - len(t1v)}")
    w("")

    for t in sorted(tc):
        w(f"\n## {TIER_NAME[t]}  ({tc[t]})\n")
        sub = [r for r in rows if r["_tier"] == t]
        by_exp = defaultdict(list)
        for r in sub:
            by_exp[r["expansion"]].append(r)
        for exp in sorted(by_exp, key=exp_key):
            items = sorted(by_exp[exp], key=lambda r: r["name"])
            w(f"### {exp}  ({len(items)})")
            for r in items:
                cur = "curada" if r["curated"] else "nao-curada"
                gate = f" gate={r['gate']}" if r["gate"] else ""
                w(f"- **{r['name']}** (spell {r['spellID']}, {cur}{gate}) "
                  f"— falta: {r['missing']}  ·  fonte: {r['source'][:70]}")
            w("")

    text = "\n".join(out)
    if args.md:
        with open(args.md, "w", encoding="utf-8", newline="\n") as f:
            f.write(text)
        print(f"gravado: {args.md}  ({len(rows)} montarias)")
    else:
        print(text)


if __name__ == "__main__":
    main()
