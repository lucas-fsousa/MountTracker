#!/usr/bin/env python3
"""Check GERAL: para TODA montaria do JOGO (curada ou nao, coletada ou nao) sem `map` ou
com expansao "Unknown", resolve do Wowhead e emite Data/Mounts_Meta.lua -- um overlay de
METADADOS (spellID -> { map | zone, expansion }) usado SO para os filtros (expansao /
current zone). Nao afeta status/glow (montaria nao-curada continua MISSING).

IMPORTANTE: a entrada e o journal COMPLETO (tools/dump_journal.lua), nao o "obtenivel
agora" (dump_all.lua). Uma montaria que ESTE personagem ja tem (ou nao pode ter) ainda
falta p/ outro player, entao os metadados precisam cobrir o jogo inteiro -- senao o filtro
de expansao mostra "Unknown" indevidamente p/ quem ainda nao a coletou.

Fonte:
  - expansao: pagina do spell ("World of Warcraft: <exp>"). Cobre todas.
  - map: vendedor/fonte -> NPC/objeto -> uiMapId (g_mapperData, match de zona estrito).
         Conteudo antigo (g_mapperData sem uiMapId) -> nome da zona ("found in"), que o
         addon resolve em runtime (ns.Waypoint.MapForZone).

Entrada: tools/_all.jsonl (gerado por: lua tools/dump_journal.lua <dump>).

Uso:
    lua tools/dump_journal.lua <dump> > tools/_all.jsonl
    python3 tools/enrich_meta.py            # gera Data/Mounts_Meta.lua
"""

import argparse
import json
import os
import re
import sys

from mtcurate import extract, wowhead
from mtcurate.http import Http

HERE = os.path.dirname(os.path.abspath(__file__))
ALL = os.path.join(HERE, "_all.jsonl")
OUT = os.path.join(HERE, "..", "Data", "Mounts_Meta.lua")
MANUAL = os.path.join(HERE, "..", "Data", "Mounts_ManualMeta.lua")

_DIFF = re.compile(r"\s*\((?:Mythic|Heroic|Normal|Raid Finder|Looking For Raid)\)\s*$", re.I)
_FACTAG = re.compile(r"\s*\((?:Alliance|Horde)\)\s*$", re.I)
_RARE = re.compile(r"(.*?)\s+Rare Creatures$", re.I)
_MANUAL_RE = re.compile(r"M\[(\d+)\]\s*=\s*\{[^}]*manualUpdate\s*=\s*true", re.I)


def manual_spellids():
    """spellIDs marcados manualUpdate=true no overlay manual (Mounts_ManualMeta.lua).
    Sao INTOCAVEIS: enrich_meta nunca os regenera/sobrescreve."""
    try:
        with open(MANUAL, encoding="utf-8") as f:
            return {int(m.group(1)) for m in _MANUAL_RE.finditer(f.read())}
    except FileNotFoundError:
        return set()


def clean_name(s):
    s = _FACTAG.sub("", _DIFF.sub("", s or "")).strip()
    m = _RARE.match(s)
    return m.group(1).strip() if m else s


def exp_from_linked_items(http, spell_html):
    """Expansao pelo item-de-montaria LINKADO na spell page. A pagina do spell costuma
    referenciar /item=N do item que ensina a mount (e as vezes itens alheios juntos, como
    'Loot-Filled Pumpkin'); filtramos pelo tooltip 'summon this mount' (is_mount_item) e so
    aceitamos se os itens-de-montaria concordam na expansao (senao ambiguo -> None)."""
    seen, ids = set(), []
    for m in re.finditer(r"/item=(\d+)", spell_html or ""):
        i = int(m.group(1))
        if i not in seen:
            seen.add(i)
            ids.append(i)
    exps = set()
    for iid in ids[:12]:
        h = wowhead.item_html(http, iid)
        if extract.is_mount_item(h):
            e = extract.expansion(h)
            if e:
                exps.add(e)
    return exps.pop() if len(exps) == 1 else None


def resolve_exp(http, sid, name):
    """Expansao de uma montaria, do mais confiavel p/ o ultimo recurso:
       1) pagina do spell (meta 'World of Warcraft: X' -- so as novas tem);
       2) item-de-montaria LINKADO na spell page -> 'Added in patch X.Y.Z' (autoritativo:
          e o proprio item que a spell referencia; ex.: Headless -> The Horseman's Reins);
       3) item por template de nome (item_for_mount): cobre o item de nome irregular sem
          link na spell page ('White Stallion Bridle', 'Reins of the Raven Lord', ...),
          exigindo match exato com um template -- nao casa item alheio;
       4) fallback: gate de REPUTACAO com faccao do Classic (CLASSIC_FACTIONS) -> Classic.
    O Wowhead tem o patch p/ TODO item da database, entao so fica sem expansao a montaria
    sem item legivel/linkado (mounts de classe, racials 'Legacy' de nome truncado...)."""
    spell_html = wowhead.spell_html(http, sid)
    e = extract.expansion(spell_html)
    if e:
        return e
    e = exp_from_linked_items(http, spell_html)
    if e:
        return e
    item_html = None
    iid = wowhead.item_for_mount(http, name)
    if iid:
        item_html = wowhead.item_html(http, iid)
        e = extract.expansion(item_html)
        if e:
            return e
    # ultimo recurso: reputacao do Classic (no item, senao no spell)
    return (extract.classic_rep_expansion(item_html)
            or extract.classic_rep_expansion(spell_html))


def resolve_map(http, vendor, source, zone):
    """(map_uiMapID, zone_name): uiMapId estrito, ou nome de zona (fallback runtime)."""
    name = clean_name(vendor or source or "")
    if not name:
        return None, None
    for resolver, pager in ((wowhead.npc_id, wowhead.npc_html),
                            (wowhead.object_id, wowhead.object_html)):
        rid = resolver(http, name)
        if not rid:
            continue
        html = pager(http, rid)
        co = extract.npc_coords(html, prefer_zone=zone, strict=True)
        if co and co[0]:
            return co[0], None
        z = extract.drop_zone(html)         # "This NPC can be found in <zona>"
        if z:
            return None, z
    return None, None


def mount_item_id(http, sid, name):
    """itemID do item que concede a montaria: 1o item-de-montaria linkado na spell page
    (tooltip 'summon this mount'), senao por template de nome. None se nao achar."""
    for m in re.finditer(r"/item=(\d+)", wowhead.spell_html(http, sid) or ""):
        iid = int(m.group(1))
        if extract.is_mount_item(wowhead.item_html(http, iid)):
            return iid
    return wowhead.item_for_mount(http, name)


def resolve_loc_via_item(http, sid, name):
    """Zona pela pagina do ITEM que concede a montaria ("location" -> nome da zona). Cobre
    drops/world-drops cujo NPC nao tem coords (ex.: Blue Qiraji -> Temple of Ahn'Qiraj)."""
    iid = mount_item_id(http, sid, clean_name(name))
    return extract.item_location(wowhead.item_html(http, iid)) if iid else None


def lua_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--all", default=ALL)
    ap.add_argument("--cache", default=os.path.join(HERE, "cache"))
    ap.add_argument("--delay", type=float, default=0.4)
    args = ap.parse_args()

    rows = [json.loads(l) for l in open(args.all, encoding="utf-8") if l.strip()]
    http = Http(args.cache, delay=args.delay)
    manual = manual_spellids()

    meta = {}
    n_exp = n_map = n_zone = 0
    for r in rows:
        sid = r["spellID"]
        if sid in manual:
            continue                            # curado a mao -> intocavel
        # Colhe expansao AUTORITATIVA (Wowhead "Added in patch") quando: a heuristica nao
        # soube (Unknown) OU a heuristica deu uma expansao ANTIGA mas o spellID e recente --
        # sinal de ZONA REAPROVEITADA (ex.: Eversong/Zul'Aman: TBC original vs Midnight novo).
        # E so um filtro de QUAIS colher; a expansao em si vem 100% do Wowhead (sem chute).
        OLD_BUCKET = ("Classic", "TBC", "WotLK", "Cataclysm", "MoP", "WoD", "Legion", "BfA")
        needs_exp = (r["expansion"] == "Unknown"
                     or (r["expansion"] in OLD_BUCKET and r["spellID"] >= 1100000))
        needs_map = r["map"] is None and (r.get("vendor") or r.get("source"))
        if not (needs_exp or needs_map):
            continue
        entry = {}
        if needs_exp:
            try:
                e = resolve_exp(http, sid, clean_name(r["name"]))
            except Exception as ex:                       # noqa: BLE001
                e = None
                sys.stderr.write(f"  spell {sid} exp ERRO: {ex}\n")
            if e:
                entry["expansion"] = e
                n_exp += 1
        if needs_map:
            try:
                mid, zname = resolve_map(http, r.get("vendor"), r.get("source"), r.get("zone"))
            except Exception as ex:                       # noqa: BLE001
                mid, zname = None, None
                sys.stderr.write(f"  spell {sid} map ERRO: {ex}\n")
            if not mid and not zname:            # NPC sem coords -> tenta a zona do item
                try:
                    zname = resolve_loc_via_item(http, sid, r["name"])
                except Exception as ex:           # noqa: BLE001
                    sys.stderr.write(f"  spell {sid} loc-item ERRO: {ex}\n")
            if mid:
                entry["map"] = mid
                n_map += 1
            elif zname:
                entry["zone"] = zname
                n_zone += 1
        if entry:
            entry["_name"] = r["name"]
            meta[sid] = entry
        sys.stderr.write(f"  {r['name']:32s} -> {entry}\n")

    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write("-- Data/Mounts_Meta.lua\n")
        f.write("-- Gerado por tools/enrich_meta.py. Overlay de METADADOS por spellID\n")
        f.write("-- (map/zona + expansao) p/ os filtros de TODAS as montarias -- inclusive\n")
        f.write("-- nao-curadas. Nao afeta status/glow.\n")
        f.write("local ADDON, ns = ...\nns.Meta = ns.Meta or {}\n")
        f.write("local M = ns.Meta\n")
        for sid in sorted(meta):
            e = meta[sid]
            parts = []
            if e.get("map"):
                parts.append("map = %d" % e["map"])
            if e.get("zone"):
                parts.append("zone = %s" % lua_str(e["zone"]))
            if e.get("expansion"):
                parts.append("expansion = %s" % lua_str(e["expansion"]))
            f.write("M[%d] = { %s }  -- %s\n" % (sid, ", ".join(parts), e["_name"]))

    sys.stderr.write(f"[meta] entradas={len(meta)}  exp={n_exp} map={n_map} zone={n_zone}\n")
    sys.stderr.write(f"[meta] gravado: {OUT}\n")


if __name__ == "__main__":
    main()
