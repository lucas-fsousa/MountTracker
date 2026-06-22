# MountTracker — Modo de edição in-game + export para a base curada

**Data:** 2026-06-22
**Status:** aprovado (design), implementação em andamento

## Objetivo

Permitir, dentro do jogo, editar/incluir manualmente os dados de curadoria de uma
montaria (vendedor, zona, mapa, coords, custo, requisito, expansão, etc.) a partir da
tela de detalhe. As edições são salvas, refletem **imediatamente** no roadmap (status/
glow/waypoint) para validação, e podem ser exportadas para os arquivos `Data/*.lua`
via um script Python — fechando o ciclo até uma release com a base atualizada.

Motivação concreta: montarias de conteúdo novo (ex.: Magister's Spell Bee / Decor Duel)
chegam com `sourceType` errado e sem dados de aquisição; hoje a curadoria é feita
editando os arquivos à mão. Esta feature move a coleta dos dados para o ponto onde a
informação é visível (in-game), sem perder a precisão.

## Decisões fechadas

- **Fluxo de export:** SavedVariable + script Python (consistente com `/mtrack dump →
  MountTrackerDump → tools/`). Não gera Lua copiável em janela.
- **Campos editáveis:** todos os da Schema (escopo "Tudo"), incluindo `cost` e
  `requirement` estruturados.
- **Regra de UI:** campos de valor fixo/enumerável = dropdown (com busca quando a lista
  é grande, ex.: currency); coordenadas e valores numéricos = campo livre.
- **Arquitetura:** janela de edição dedicada (`UI/EditFrame.lua`), separada do detail.

## Seção 1 — Ativação e armazenamento

### Gate
- `/mtrack enable edit` → `settings.editMode = true` (persistente em `MountTrackerDB`).
- `/mtrack disable edit` → `false`.
- Com `editMode` ligado: a tela de detalhe ganha o botão **"Edit data"** e um marcador
  visual discreto (ex.: "✎") no título. Desligado: UI inalterada.

### Storage
SavedVariable **novo e separado**: `MountTrackerEdits`, indexado por **spellID**
(mesma chave do overlay curado). Mantido fora do `MountTrackerDB` de propósito — é dado
de curadoria, separável/exportável sem misturar com hidden/marked/settings.

Adicionar `MountTrackerEdits` ao `## SavedVariables` da `.toc`.

```lua
MountTrackerEdits[1282471] = {
    acquisition = "vendor",
    vendor = "Gamesmaster Fleurian",
    zone = "Silvermoon City", map = 2393,
    coords = { x = 31.6, y = 76.7 },
    cost = { type = "currency", id = 3393, amount = 500 },
    requirement = nil,
    expansion = "Midnight",
    availableOverride = true,
    wowhead = "https://www.wowhead.com/spell=1282471",
    _meta = { editedAt = <epoch>, char = "Nome-Reino" },
}
```

### Efeito imediato (merge no Scanner)
Em `Logic/Scanner.lua`, ao montar o índice curado por spellID:
- Se existe `MountTrackerEdits[spellID]`, clona a entry de `ns.Data.All` (ou cria uma
  nova se a mount não era curada) e aplica os overrides por cima.
- Sub-objetos (`cost`, `requirement`, `coords`) são **substituídos inteiros**, não merge
  raso — previsível.
- O formato de storage (`cost = {type,id,amount}`) é convertido para o formato da
  Schema (`cost = {currencyID=…, amount=…}` / `{itemID=…}` / `{gold=…}`) nesse merge,
  numa função única reutilizada também pelo export.
- Ao salvar: `Roadmap.Build()` + `UI.Refresh()` → status/glow/waypoint atualizam na hora.

## Seção 2 — Janela de edição (`UI/EditFrame.lua`)

Janela própria (~420px), acionada pelo botão "Edit data", ancorada ao lado do detail.
Todo o código de edição isolado neste arquivo novo (não inchar `MainFrame.lua`).

Campos (ordem da Schema), label à esquerda / controle à direita:

| Campo | Controle |
|---|---|
| `name`, `spellID` | só leitura (do jogo) |
| `acquisition` | dropdown: vendor / reputation / drop / world / rare / achievement |
| `expansion` | dropdown: Classic … Midnight (lista fixa) |
| `vendor` | campo livre |
| `zone` | campo livre + uiMapID resolvido via `MapForZone` (verde=ok, vermelho=não) |
| `map` | campo livre (número) + botão "← usar o da zona" |
| `coords x / y` | dois campos livres (0–100) |
| `cost` | dropdown de tipo (gold/currency/item/token/nenhum) → revela campos: gold→amount; currency→busca de currency + amount; item→itemID + amount |
| `requirement` | dropdown de tipo (nenhum/reputation/renown/achievement) → condicional: reputation→factionID + dropdown standing (Friendly…Exalted); renown→factionID *ou* factionName + renownLevel; achievement→achievementID |
| `availableOverride` | checkbox |
| `wowhead` | campo livre (default `spell=<id>`) |

- Campos de ID (factionID/achievementID/itemID) mostram o **nome resolvido** ao lado.
- **Busca de currency:** dropdown buscável populado de 3 fontes: (1) currencyIDs já
  usadas em `ns.Data.All`, (2) currencies conhecidas pelo personagem (`C_CurrencyInfo`),
  (3) digitar o ID resolve o nome. EditBox de busca filtra por nome/ID em tempo real.
  Limitação documentada: não lista 100% das currencies do jogo; o ID digitado sempre
  funciona.
- **Botões:** `Save` (grava em `MountTrackerEdits`, re-scaneia, fecha), `Revert`
  (descarta a edição daquele spellID → volta ao dado dos arquivos), `Cancel`.
- Tudo em `ns.Safe.Wrap`; números validados antes de gravar; nenhum erro Lua no meio
  da tela (consistente com o tratamento de erros do projeto).

## Seção 3 — Export para a base curada

### Comando in-game
`/mtrack export` (revisão, não escreve arquivo): imprime quantas edições há pendentes,
lista nome+spellID, e mostra o caminho do SavedVariables. O dado em si persiste sozinho
no logout (é SavedVariable).

### Script `tools/edits_to_curated.py` (IMPLEMENTADO)
Segue o padrão de `dump_to_json.lua`/`curate.py`: `tools/edits_to_json.lua` carrega
`MountTracker.lua` via `lua` (`loadfile`), extrai `MountTrackerEdits` e emite JSONL
(resolvendo o `name` pelo `MountTrackerDump`). O Python então, para cada spellID:
- **Existe** em algum `Data/Mounts_*.lua` (casado por spellID, por balanceamento de
  chaves) → substitui a entry in-place, preservando indentação e o `name` existente.
- **Não existe** → insere uma entry nova antes do `})` do `Data/Mounts_<expansion>.lua`.
- Converte o formato de storage para o formato Schema (mesma conversão do merge).
- **Dry-run por padrão** (mostra cada UPDATE/NEW); `--write` aplica e faz backup `.bak`.
  O script **não** commita; o dev valida com `luac -p`, revisa o `git diff` e commita.
- Testado contra o SavedVariables real (UPDATE de 288587) e fixture sintético (NEW).

Caminho do SavedVariables (referência):
`...\WTF\Account\352171876#1\SavedVariables\MountTracker.lua`.

## Ordem de implementação (fatias)

1. **Fatia testável in-game** (entregue primeiro, para o usuário testar):
   - `.toc`: registra `MountTrackerEdits`.
   - `Core/Database.lua`: init de `MountTrackerEdits` + helpers Get/Set/Revert; default
     `settings.editMode`.
   - `Core/Events.lua`: `/mtrack enable|disable edit` + `/mtrack export` (resumo).
   - `Logic/Scanner.lua`: merge do override + conversão de formato.
   - `UI/EditFrame.lua`: a janela.
   - `UI/MainFrame.lua`: botão "Edit data" + marcador, gated por `editMode`.
2. **Fase de export** (depois do teste in-game):
   - `tools/edits_to_curated.py`.

## Tratamento de erros / testes

- Validação Lua de sintaxe via `luac -p` (WSL) a cada arquivo tocado.
- Toda interação de UI em `ns.Safe.Wrap`; leitura de valores potencialmente "Secret"
  via `ns.Safe.Value`.
- Teste manual in-game na Magister's Spell Bee: editar custo/coords, salvar, ver o
  status virar READY/NEED_CURRENCY e o waypoint apontar para o Fleurian.

## Não-objetivos (YAGNI)

- Não há sincronização entre personagens/contas além do SavedVariable padrão.
- Não edita os arquivos `Data/*.lua` de dentro do jogo (addons não escrevem no disco).
- Não cobre 100% das currencies do jogo num dropdown pré-carregado.
