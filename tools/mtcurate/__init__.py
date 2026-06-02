"""MountTracker curation toolkit -- modulos especializados de extracao.

Camadas:
  http        infraestrutura de rede (cache, rate-limit, retry)
  dump        leitura do /mtrack dump (SavedVariables)
  wowhead     resolucao de IDs (item/faccao) via endpoint de sugestoes
  sourcetext  parse do texto de origem do jogo (campos, custo, expansao, requisito)
  extract     extracao da pagina do Wowhead (requisito de renome, drop chance)
  emit        geracao das entradas Lua do overlay curado
"""

__version__ = "0.2.0"
