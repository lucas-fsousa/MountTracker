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
  enrich_zones.py  preenche a `zone` dos drops sem zona (NPC/boss -> pagina do Wowhead;
                   heuristica local p/ "<Zona> Rare Creatures")
"""

__version__ = "0.3.0"
