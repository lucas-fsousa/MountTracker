"""Le o /mtrack dump (SavedVariables MountTracker.lua) em registros Python.

Converte via o conversor Lua (tools/dump_to_json.lua), evitando um parser de Lua
em Python. Cada registro: spellID, name, sourceType, faction, shouldHideOnChar,
isUsable, collected, sourceText.
"""

import json
import os
import subprocess

_CONV = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "dump_to_json.lua")


def load(dump_path, lua_bin="lua"):
    out = subprocess.check_output([lua_bin, _CONV, dump_path], text=True)
    return [json.loads(line) for line in out.splitlines() if line.strip()]
