"""Geracao das entradas Lua do overlay curado a partir dos dados extraidos."""

from . import sourcetext as st


def lua_str(s):
    return '"' + (s or "").replace("\\", "\\\\").replace('"', '\\"') + '"'


def entry(rec, req, fid, costs, drop_chance=None):
    src = rec.get("sourceText") or ""
    L = ["    {"]
    L.append(f"        name    = {lua_str(rec['name'])},")
    L.append(f"        spellID = {rec['spellID']},")

    is_drop = (drop_chance is not None) or (not req and "Drop:" in src)
    acq = "reputation" if req else ("drop" if is_drop else "vendor")
    L.append(f'        acquisition = "{acq}",')

    vendor = st.field(src, "Vendor")
    zone = st.field(src, "Zone") or st.field(src, "Location")
    drop_src = st.field(src, "Drop")
    if vendor:
        L.append(f"        vendor  = {lua_str(vendor)},")
    elif drop_src:
        L.append(f"        source  = {lua_str(drop_src)},")
    if zone:
        L.append(f"        zone    = {lua_str(zone)},")
    if drop_chance is not None:
        L.append("        dropChance = %.4f," % drop_chance)

    if req:
        if req["type"] == "renown":
            if fid:
                L.append('        requirement = { type = "renown", factionID = %d, renownLevel = %d },'
                         % (fid, req["renownLevel"]))
            else:
                L.append('        requirement = { type = "renown", factionName = %s, renownLevel = %d },'
                         % (lua_str(req.get("faction") or ""), req["renownLevel"]))
        else:
            L.append('        requirement = { type = "reputation", factionID = %s, standing = "%s" },'
                     % (fid if fid else "nil --[[ VERIFICAR ]]", req["standing"]))

    c = costs[0] if costs else None
    if c and c["ctype"] == "currency":
        L.append("        cost    = { currencyID = %d, amount = %d }," % (c["id"], c["amount"]))
    elif c and c["ctype"] == "item":
        L.append("        cost    = { itemID = %d, amount = %d }," % (c["id"], c["amount"]))
    elif c and c["ctype"] == "gold":
        L.append("        cost    = { gold = %d }," % c["amount"])

    L.append(f'        wowhead = "https://www.wowhead.com/spell={rec["spellID"]}",')
    L.append("    },")
    return "\n".join(L)
