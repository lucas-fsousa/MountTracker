"""Extracao de dados especificos da pagina de item do Wowhead (HTML estatico).

  requirement(html)  -> requisito de Renome/Reputacao (captura factionID do link)
  drop_chance(html)  -> chance de drop pela maior amostra count/outof
"""

import json
import re

from .sourcetext import STANDINGS


def _balanced(s, start, op="[", cl="]"):
    """Retorna a substring delimitada balanceada que comeca em `start` (aponta p/ `op`)."""
    depth = 0
    for i in range(start, len(s)):
        if s[i] == op:
            depth += 1
        elif s[i] == cl:
            depth -= 1
            if depth == 0:
                return s[start:i + 1]
    return None


def _norm_zone(s):
    """Normaliza um nome de zona p/ comparacao: remove sufixo de dificuldade e baixa."""
    s = re.sub(r"\s*\((?:Mythic|Heroic|Normal|Raid Finder|Looking For Raid)\)\s*$",
               "", s or "", flags=re.I)
    return s.strip().lower()


def _zone_eq(a, b):
    """Zonas equivalentes? Tolera o sufixo ", Continente" do sourceText do jogo:
    "Nagrand, Outland" == "Nagrand"; mantem nomes com virgula propria
    ("Tazavesh, the Veiled Market")."""
    a, b = _norm_zone(a), _norm_zone(b)
    if not a or not b:
        return False
    return a == b or a.startswith(b + ",") or b.startswith(a + ",")


def npc_coords(html, prefer_zone=None, strict=False):
    """Coordenadas de um NPC a partir do g_mapperData do Wowhead.
    Retorna (uiMapId_ou_None, x, y) em 0-100, ou None se nao houver coords.
    - Entradas com uiMapId: prefere a que CASA com `prefer_zone` (uiMapName == zona).
    - `strict=True`: SO retorna quando a zona casa (nao cai pro 1o mapa) -> uiMapID
      garantidamente correto (usado p/ o `map` do filtro de zona, que nao pode errar).
    - `strict=False`: cai pro 1o mapa se nao casar; e, se nenhuma entrada tiver uiMapId,
      retorna (None, x, y) p/ parear com a zona curada (usado p/ coords do waypoint)."""
    m = re.search(r"g_mapperData\s*=\s*(\{)", html or "")
    if not m:
        return None
    seg = _balanced(html, m.start(1), "{", "}")
    if not seg:
        return None
    try:
        data = json.loads(seg)
    except Exception:                       # noqa: BLE001
        return None

    withmap, anycoords = [], None
    for _zid, lst in data.items():
        if not isinstance(lst, list):
            continue
        for e in lst:
            if isinstance(e, dict) and e.get("coords"):
                anycoords = anycoords or e
                if e.get("uiMapId"):
                    withmap.append(e)

    if withmap:
        chosen = None
        if prefer_zone:
            for e in withmap:
                if _zone_eq(e.get("uiMapName"), prefer_zone):
                    chosen = e
                    break
        if not chosen:
            if strict:
                return None                  # exige match de zona -> nao chuta mapa
            chosen = withmap[0]
        co = chosen["coords"][0]
        return int(chosen["uiMapId"]), round(float(co[0]), 1), round(float(co[1]), 1)

    if anycoords and not strict:             # coords sem uiMapId -> pareia com a zona
        co = anycoords["coords"][0]
        return None, round(float(co[0]), 1), round(float(co[1]), 1)
    return None


def sold_cost(html):
    """Primeiro custo nao-vazio de uma listview 'sold-by' do Wowhead.
    Formato: "cost":[[ moneyCopper, [[id,count]...], [[id,count]...] ]].
    Retorna (money_copper, [(id, count), ...]) -- os ids podem ser moeda ou item,
    a resolucao do tipo fica a cargo de quem chama. Retorna None se nao houver."""
    for m in re.finditer(r'"cost":', html or ""):
        seg = _balanced(html, m.end())
        if not seg:
            continue
        try:
            arr = json.loads(seg)
        except Exception:                       # noqa: BLE001
            continue
        if not arr or not isinstance(arr[0], list) or not arr[0]:
            continue
        grp = arr[0]
        money = grp[0] if isinstance(grp[0], int) else 0
        ids = []
        for sub in grp[1:]:
            if isinstance(sub, list):
                for pair in sub:
                    if isinstance(pair, list) and len(pair) >= 2:
                        ids.append((pair[0], pair[1]))
        if money or ids:
            return money, ids
    return None


def requirement(html):
    """Requisito de reputacao/renome do tooltip do Wowhead (o jogo as vezes ESCONDE
    isso no sourceText). Captura o factionID do link `faction=N`. Cobre:
      - "Renown Rank N with [faction=M]"            -> renown
      - "<Standing> with [faction=M]"  (Exalted...)  -> reputation
        (inclui "Requires you to be exalted with [faction=M]")
    Retorna o dict do requisito ou None."""
    h = html or ""
    m = re.search(r"Renown Rank (\d+) with[^.]{0,80}?faction=(\d+)", h, re.I)
    if m:
        return {"type": "renown", "renownLevel": int(m.group(1)),
                "factionID": int(m.group(2))}
    m = re.search(r"\b(%s)\s+with[^.]{0,80}?faction=(\d+)" % "|".join(STANDINGS), h, re.I)
    if m:
        return {"type": "reputation", "standing": m.group(1).capitalize(),
                "factionID": int(m.group(2))}
    return None


# Nome da expansao no Wowhead -> codigo interno do addon.
_WH_EXP = {
    "Classic": "Classic",
    "The Burning Crusade": "TBC",
    "Wrath of the Lich King": "WotLK",
    "Cataclysm": "Cataclysm",
    "Mists of Pandaria": "MoP",
    "Warlords of Draenor": "WoD",
    "Legion": "Legion",
    "Battle for Azeroth": "BfA",
    "Shadowlands": "Shadowlands",
    "Dragonflight": "Dragonflight",
    "The War Within": "TWW",
    "Midnight": "Midnight",
}


# Versao major do patch -> expansao. O Wowhead marca quando algo entrou no jogo via
# "Added in patch X.Y.Z" -- sinal mais confiavel que o meta p/ montarias antigas/promo/TCG,
# cujo meta "World of Warcraft: X" costuma faltar.
_PATCH_EXP = {
    1: "Classic", 2: "TBC", 3: "WotLK", 4: "Cataclysm", 5: "MoP", 6: "WoD",
    7: "Legion", 8: "BfA", 9: "Shadowlands", 10: "Dragonflight", 11: "TWW", 12: "Midnight",
}


def expansion_from_patch(html):
    """Expansao pelo "Added in patch X.Y.Z" do Wowhead (na pagina do item). O markup vem
    como `Added in patch [acronym="2.4.3.8600"]2.4.3[/acronym]` -- pegamos o 1o numero de
    versao apos o rotulo e mapeamos o major p/ a expansao. Retorna o codigo ou None."""
    m = re.search(r"Added in patch.{0,40}?(\d+)\.\d+", html or "")
    if not m:
        return None
    return _PATCH_EXP.get(int(m.group(1)))


def expansion(html):
    """Expansao a partir do Wowhead. Tenta, em ordem:
       1) meta description: 'World of Warcraft: <Exp>' (item e spell);
       2) "Added in patch X.Y.Z" -> major do patch (cobre antigas/promo/TCG sem meta).
    Retorna o codigo interno do addon ou None."""
    m = re.search(r"World of Warcraft: ([^.<\"]+)", html or "")
    if m:
        exp = _WH_EXP.get(m.group(1).strip())
        if exp:
            return exp
    return expansion_from_patch(html)


def faction_side(html):
    """Lado da faccao a partir do "side":N da pagina de item do Wowhead.
    1 = Alliance, 2 = Horde; 0/3 (ambos/neutro) -> None (sem restricao)."""
    m = re.search(r'"side":(\d)', html or "")
    if not m:
        return None
    return {"1": "Alliance", "2": "Horde"}.get(m.group(1))


def drop_zone(html):
    """Zona onde um NPC e encontrado, a partir da pagina de NPC do Wowhead:
       'This NPC can be found in <span id="locations"> ... <a ...>ZONE</a>'.
    Retorna o nome da primeira zona (a principal) ou None."""
    m = re.search(r'found in\s*<span id="locations">(.*?)</span>', html, re.S)
    if not m:
        return None
    names = re.findall(r">([^<>]{2,60})</a>", m.group(1))
    return names[0].strip() if names else None


def drop_chance(html):
    """Estima a chance de drop pela maior amostra (count/outof) da pagina.
    ~1.0 = drop garantido (raro elite); valores baixos = RNG."""
    best = None
    for c, o in re.findall(r'"count":(\d+)[^{}]{0,40}?"outof":(\d+)', html):
        c, o = int(c), int(o)
        if o > 0 and c > 0 and (best is None or o > best[1]):  # ignora amostras com 0 drops
            best = (c, o)
    if best:
        return min(best[0] / best[1], 1.0)
    return None
