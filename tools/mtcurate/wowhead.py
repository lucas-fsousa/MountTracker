"""Resolucao de IDs no Wowhead via o endpoint publico de sugestoes.

Resolve nome -> itemID e nome -> factionID (JSON limpo, sem scraping de HTML).
Tambem busca a pagina de item (para a camada `extract`).
"""

import json
import re
import urllib.parse

BASE = "https://www.wowhead.com"


def _suggest(http, query):
    url = f"{BASE}/search/suggestions-template?q=" + urllib.parse.quote(query)
    try:
        return json.loads(http.get(url)).get("results", [])
    except Exception:                       # noqa: BLE001
        return []


def item_id(http, name):
    """itemID exato pelo nome (typeName == Item)."""
    for r in _suggest(http, name):
        if r.get("typeName") == "Item" and r.get("name", "").lower() == name.lower():
            return r.get("id")
    return None


def _norm(s):
    return re.sub(r"['’ʼ`]", "'", s or "").strip().lower()


def faction_id(http, name):
    """factionID pelo nome (tolerante a apostrofo; fallback: 1a faccao)."""
    if not name:
        return None
    facs = [r for r in _suggest(http, name) if r.get("typeName") == "Faction"]
    for r in facs:
        if _norm(r.get("name")) == _norm(name):
            return r.get("id")
    return facs[0].get("id") if facs else None


def item_html(http, iid):
    return http.get(f"{BASE}/item={iid}")


def spell_html(http, sid):
    return http.get(f"{BASE}/spell={sid}")


def _title(http, url):
    m = re.search(r"<title>([^<|]+)", http.get(url))
    return m.group(1).strip() if m else ""


def cost_kind(http, cid):
    """Classifica um id de custo do Wowhead: ('currency', nome) ou ('item', nome).
    Tenta a pagina de moeda (titulo '<Nome> - Currency'); senao trata como item."""
    t = _title(http, f"{BASE}/currency={cid}")
    if " - Currency" in t and not t.lower().startswith("currencies"):
        return "currency", t.split(" - ")[0].strip()
    t = _title(http, f"{BASE}/item={cid}")
    return "item", (t.split(" - ")[0].strip() if t else "item")


def npc_id(http, name):
    """npcID pelo nome (typeName == NPC; tolerante a apostrofo; fallback: 1o NPC)."""
    if not name:
        return None
    npcs = [r for r in _suggest(http, name) if r.get("typeName") == "NPC"]
    for r in npcs:
        if _norm(r.get("name")) == _norm(name):
            return r.get("id")
    return npcs[0].get("id") if npcs else None


def npc_html(http, nid):
    return http.get(f"{BASE}/npc={nid}")


def object_id(http, name):
    """objectID pelo nome (typeName == Object; tolerante a apostrofo; fallback: 1o)."""
    if not name:
        return None
    objs = [r for r in _suggest(http, name) if r.get("typeName") == "Object"]
    for r in objs:
        if _norm(r.get("name")) == _norm(name):
            return r.get("id")
    return objs[0].get("id") if objs else None


def object_html(http, oid):
    return http.get(f"{BASE}/object={oid}")


def achievement_id(http, name):
    """achievementID exato pelo nome (typeName == Achievement; tolerante a apostrofo)."""
    if not name:
        return None
    achs = [r for r in _suggest(http, name) if r.get("typeName") == "Achievement"]
    for r in achs:
        if _norm(r.get("name")) == _norm(name):
            return r.get("id")
    return achs[0].get("id") if achs else None
