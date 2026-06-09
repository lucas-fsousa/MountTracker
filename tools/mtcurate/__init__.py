"""MountTracker curation toolkit -- modulos especializados de extracao.

Camadas:
  http        infraestrutura de rede (cache, rate-limit, retry)
  dump        leitura do /mtrack dump (SavedVariables)
  wowhead     resolucao de IDs (item/faccao/NPC) via endpoint de sugestoes + paginas
  sourcetext  parse do texto de origem do jogo (campos, custo, expansao, requisito)
  extract     extracao da pagina do Wowhead (requisito de renome, drop chance, zona)
  emit        geracao das entradas Lua do overlay curado

Scripts (tools/):
  curate.py        pipeline dump -> Wowhead -> entradas Lua
  audit.lua/.py    varredura de completude (reusa a logica do addon sobre o dump)
  enrich_zones.py  preenche `zone` dos drops (NPC/boss; heuristica "<Zona> Rare Creatures")
  enrich_faction.py  marca `faction` (Alliance/Horde) via "side" do item no Wowhead
  enrich_coords.py   preenche `coords` (waypoint do vendedor; map/zona)
  enrich_expansion.py setta `expansion` explicito (pagina do spell) p/ as Unknown
  enrich_map.py    preenche `map` (uiMapID ESTRITO da zona) -> filtro "Current zone" por ID

  Apos regenerar curate_*.py, rode os enrich_* (eles patcham todos os Data/Mounts_*.lua,
  idempotentes -- so adicionam campos faltantes).
"""

__version__ = "0.3.0"
