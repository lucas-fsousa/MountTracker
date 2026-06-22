#!/usr/bin/env python3
"""Mescla o overlay de edicao in-game (MountTrackerEdits) na base curada Data/*.lua.

Le o SavedVariables (via tools/edits_to_json.lua), converte cada edicao do formato de
STORAGE ({cost={type,id,amount}, coords={x,y}, ...}) para o formato da Schema curada,
gera o bloco Lua no estilo do projeto e:
  - UPDATE: substitui a entry existente (casada por spellID em qualquer Data/Mounts_*.lua);
  - NEW:    insere a entry no arquivo da expansao (Data/Mounts_<expansion>.lua).

Por padrao roda em DRY-RUN (so mostra o que faria). Use --write para aplicar (faz backup
.bak de cada arquivo tocado). Revise sempre o `git diff` antes de commitar.

Uso (no WSL, com lua compilado):
    python3 tools/edits_to_curated.py \
        --dump "/mnt/c/Games/World of Warcraft/_retail_/WTF/Account/352171876#1/SavedVariables/MountTracker.lua" \
        --lua ~/lua-build/lua-5.4.7/src/lua
    # ...revise a saida, depois:
    python3 tools/edits_to_curated.py --dump "..." --lua ... --write
"""

import argparse
import glob
import json
import os
import re
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(ROOT, "Data")
CONV = os.path.join(os.path.dirname(os.path.abspath(__file__)), "edits_to_json.lua")

# Campos escalares que vao direto do storage para a Schema, na ordem de emissao.
SCALAR_ORDER = ["acquisition", "vendor", "zone", "map", "faction",
                "dropChance", "availableOverride", "wowhead"]


# --------------------------------------------------------------- carga das edicoes
def load_edits(dump_path, lua_bin):
    out = subprocess.check_output([lua_bin, CONV, dump_path], text=True)
    recs = [json.loads(l) for l in out.splitlines() if l.strip()]
    return recs


# ------------------------------------------------------ conversao storage -> Schema
def cost_to_schema(c):
    if not c or c is False:
        return None
    t = c.get("type")
    if t == "currency":
        return {"currencyID": c.get("id"), "amount": c.get("amount")}
    if t == "item":
        return {"itemID": c.get("id"), "amount": c.get("amount")}
    if t == "gold":
        return {"gold": c.get("amount")}
    return None  # none/token: sem custo verificavel


def requirement_to_schema(r):
    if not r or r is False:
        return None
    out = {"type": r.get("type")}
    for k in ("factionID", "factionName", "standing", "renownLevel", "achievementID"):
        if r.get(k) is not None:
            out[k] = r[k]
    return out


def edit_to_schema(rec):
    """Devolve um dict de campos no formato da Schema (sem `name`/`spellID`)."""
    d = rec["data"]
    s = {}
    for k in SCALAR_ORDER:
        v = d.get(k)
        if v is not None and v != "":
            s[k] = v
    # coords: storage {x,y} + map -> Schema {map, x, y}
    co = d.get("coords")
    if isinstance(co, dict) and co.get("x") is not None and co.get("y") is not None:
        s["coords"] = {"map": d.get("map"), "x": co["x"], "y": co["y"]}
    # cost / requirement (presenca explicita; `false` = remover -> simplesmente nao emite)
    if "cost" in d:
        cs = cost_to_schema(d["cost"])
        if cs:
            s["cost"] = cs
    if "requirement" in d:
        rs = requirement_to_schema(d["requirement"])
        if rs:
            s["requirement"] = rs
    return s


# ------------------------------------------------------------- gerador de Lua
def lua_num(n):
    if isinstance(n, float) and n.is_integer():
        n = int(n)
    return repr(n) if not isinstance(n, int) else str(n)


def lua_val(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return lua_num(v)
    if isinstance(v, str):
        return '"' + v.replace("\\", "\\\\").replace('"', '\\"') + '"'
    if isinstance(v, dict):
        inner = ", ".join("%s = %s" % (k, lua_val(val)) for k, val in v.items())
        return "{ " + inner + " }"
    return "nil"


def render_entry(name, spell_id, schema, indent="    "):
    """Bloco Lua de UMA entry, no estilo dos arquivos Data/Mounts_*.lua."""
    i2 = indent + "    "
    lines = [indent + "{"]

    def field(key, val):
        # alinhamento dos campos curtos comuns (name/spellID/etc) como no projeto
        pad = key.ljust(7) if key in ("name", "spellID", "vendor", "zone", "map", "coords",
                                      "cost", "faction", "wowhead") else key
        lines.append("%s%s = %s," % (i2, pad, val))

    field("name", lua_val(name or "?"))
    field("spellID", str(spell_id))
    # ordem de saida: acquisition, vendor, zone, map, coords, faction, cost, requirement,
    # dropChance, availableOverride, wowhead
    for key in ["acquisition", "vendor", "zone", "map", "coords", "faction",
                "cost", "requirement", "dropChance", "availableOverride", "wowhead"]:
        if key in schema:
            field(key, lua_val(schema[key]))
    lines.append(indent + "},")
    return "\n".join(lines)


# ------------------------------------------------- localizar/substituir/inserir
SPELL_RE_TMPL = r"spellID\s*=\s*%d\b"


def find_entry_span(text, spell_id):
    """Acha (start, end, indent) do bloco {...} da entry que contem `spellID = N`.
    `start` inclui a indentacao da linha de abertura; `end` inclui a virgula final.
    Por balanceamento de chaves. Retorna None se nao achar."""
    m = re.search(SPELL_RE_TMPL % spell_id, text)
    if not m:
        return None
    pos = m.start()
    # recua ate a '{' que abre a entry (profundidade -1)
    depth = 0
    i = pos
    brace = None
    while i >= 0:
        c = text[i]
        if c == "}":
            depth += 1
        elif c == "{":
            if depth == 0:
                brace = i
                break
            depth -= 1
        i -= 1
    if brace is None:
        return None
    # inclui a indentacao da linha de abertura (se antes da '{' so houver espacos)
    line_start = text.rfind("\n", 0, brace) + 1
    indent = text[line_start:brace]
    start = line_start if indent.strip() == "" else brace
    if indent.strip() != "":
        indent = "    "
    # avanca ate fechar a entry
    depth = 0
    j = brace
    n = len(text)
    while j < n:
        c = text[j]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                end = j + 1
                if end < n and text[end] == ",":
                    end += 1
                return (start, end, indent)
        j += 1
    return None


def file_for_expansion(expansion):
    if not expansion:
        return None
    p = os.path.join(DATA_DIR, "Mounts_%s.lua" % expansion)
    return p if os.path.exists(p) else None


def insert_into_register(text, entry_block):
    """Insere `entry_block` antes do `})` que fecha o ultimo Register do arquivo."""
    idx = text.rfind("})")
    if idx == -1:
        return None
    return text[:idx] + entry_block + "\n" + text[idx:]


# --------------------------------------------------------------------- main
def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dump", required=True, help="caminho do SavedVariables MountTracker.lua")
    ap.add_argument("--lua", default="lua", help="binario lua (default: lua no PATH)")
    ap.add_argument("--write", action="store_true", help="aplica as mudancas (default: dry-run)")
    args = ap.parse_args()

    recs = load_edits(args.dump, args.lua)
    if not recs:
        print("Nenhuma edicao em MountTrackerEdits.")
        return

    # indexa o conteudo de cada arquivo de dados (cache p/ multiplas edicoes)
    files = {p: open(p, encoding="utf-8").read() for p in glob.glob(os.path.join(DATA_DIR, "Mounts_*.lua"))}
    touched = {}  # path -> novo conteudo
    new_count = upd_count = skip = 0

    for rec in recs:
        sp = rec["spellID"]
        name = rec.get("name")
        schema = edit_to_schema(rec)

        # localiza o spellID em algum arquivo (UPDATE) ...
        target, span = None, None
        for p in files:
            cur = touched.get(p, files[p])
            s = find_entry_span(cur, sp)
            if s:
                target, span = p, s
                break

        if target:
            cur = touched.get(target, files[target])
            old = cur[span[0]:span[1]]
            indent = span[2]
            # preserva o `name` existente da entry, se a edicao nao trouxer um melhor
            mname = re.search(r'name\s*=\s*"([^"]*)"', old)
            if mname and (not name or name == "?"):
                name = mname.group(1)
            block = render_entry(name, sp, schema, indent=indent or "    ")
            new = cur[:span[0]] + block + cur[span[1]:]
            touched[target] = new
            upd_count += 1
            print("UPDATE %s  (spell %d, %s)" % (os.path.relpath(target, ROOT), sp, name))
            if not args.write:
                print("  ---- antes ----\n" + old)
                print("  ---- depois ---\n" + block)
        else:
            # NEW: insere no arquivo da expansao
            exp = rec["data"].get("expansion")
            p = file_for_expansion(exp)
            if not p:
                print("SKIP   spell %d (%s): expansao '%s' sem arquivo Data/Mounts_%s.lua"
                      % (sp, name, exp, exp))
                skip += 1
                continue
            cur = touched.get(p, files[p])
            block = render_entry(name, sp, schema, indent="    ")
            new = insert_into_register(cur, block)
            if not new:
                print("SKIP   spell %d (%s): nao achei `})` p/ inserir em %s"
                      % (sp, name, os.path.relpath(p, ROOT)))
                skip += 1
                continue
            touched[p] = new
            new_count += 1
            print("NEW    %s  (spell %d, %s)" % (os.path.relpath(p, ROOT), sp, name))
            if not args.write:
                print(_indent_show(block))

    print("\n%d update(s), %d new, %d skip." % (upd_count, new_count, skip))

    if args.write:
        for p, content in touched.items():
            shutil.copyfile(p, p + ".bak")
            with open(p, "w", encoding="utf-8") as fh:
                fh.write(content)
            print("escrito: %s (backup em %s.bak)" % (os.path.relpath(p, ROOT), os.path.basename(p)))
        print("Pronto. Valide com luac -p e revise o `git diff` antes de commitar.")
    else:
        print("(dry-run) nada escrito. Rode com --write para aplicar.")


def _indent_show(block):
    return "\n".join("    " + l for l in block.splitlines())


if __name__ == "__main__":
    main()
