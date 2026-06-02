"""Extracao de dados especificos da pagina de item do Wowhead (HTML estatico).

  requirement(html)  -> requisito de Renome/Reputacao (captura factionID do link)
  drop_chance(html)  -> chance de drop pela maior amostra count/outof
"""

import re

from .sourcetext import STANDINGS


def requirement(html):
    """Requisito do tooltip do item. Captura o factionID direto do link quando a
    faccao e hyperlinkada; senao guarda o nome para resolver depois."""
    for kind, pat in (("renown", r"Renown Rank (\d+) with (?:the )?"),
                      ("reputation", r"Requires (%s) with (?:the )?" % "|".join(STANDINGS))):
        m = re.search(pat, html)
        if not m:
            continue
        tail = html[m.end():m.end() + 160]
        fm = re.search(r"faction=(\d+)", tail)
        nm = re.search(r">([^<]+)</a>", tail) or re.search(r"^\s*([^.<]+)", tail)
        req = {"type": kind, "factionID": int(fm.group(1)) if fm else None,
               "faction": nm.group(1).strip() if nm else None}
        if kind == "renown":
            req["renownLevel"] = int(m.group(1))
        else:
            req["standing"] = m.group(1)
        return req
    return None


def drop_chance(html):
    """Estima a chance de drop pela maior amostra (count/outof) da pagina.
    ~1.0 = drop garantido (raro elite); valores baixos = RNG."""
    best = None
    for c, o in re.findall(r'"count":(\d+)[^{}]{0,40}?"outof":(\d+)', html):
        c, o = int(c), int(o)
        if o > 0 and (best is None or o > best[1]):
            best = (c, o)
    if best:
        return min(best[0] / best[1], 1.0)
    return None
