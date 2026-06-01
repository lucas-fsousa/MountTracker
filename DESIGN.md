# MountTracker — Documento de Design (Esboço de Arquitetura)

> Addon de World of Warcraft (Retail / The War Within) que rastreia as montarias da
> conta e monta um **roadmap priorizado** das mais fáceis de obter que ainda faltam —
> com destaque para as que o personagem **já é elegível a obter mas não sabe**.

Status: **rascunho de arquitetura** · Escopo da v0: **montarias de reputação (vendedor)**
· Fonte de dados: **híbrida** (APIs do jogo + tabela curada enxuta).

---

## 1. Objetivo e diferencial

O que nenhum addot existente entrega junto e in-game:

1. **Detecção de elegibilidade oculta** — "você já tem a reputação/conquista/item
   necessário, é só ir buscar". Esse é o coração do addon.
2. **Roadmap priorizado por esforço** — ordena o que falta da mais fácil → mais difícil.
3. **Gerenciamento manual** — marcar como obtida (corrigir track indevido), ocultar
   montarias de facção oposta que você não pode adquirir.
4. **Contexto de aquisição inline** — local, link Wowhead, nome do vendedor, currency
   necessária **vs. currency que o personagem tem agora**.

---

## 2. Estratégia de dados (híbrida)

| Pergunta | Fonte |
|---|---|
| Quais montarias existem? | `C_MountJournal.GetMountIDs()` |
| Já coletei? (account-wide) | `C_MountJournal.GetMountInfoByID` → `isCollected` |
| É específica de facção? Qual? | `isFactionSpecific`, `faction` (0=Horde, 1=Alliance) |
| É usável pelo personagem agora? | `isUsable` |
| Texto de origem (cru) | `C_MountJournal.GetMountInfoExtraByID` → `sourceText` |
| Tenho a reputação exigida? | `C_Reputation` / `C_MajorFactions.GetMajorFactionData` (renown) |
| Quanto da currency eu tenho? | `C_CurrencyInfo.GetCurrencyInfo(id)` → `quantity` |
| Tenho a conquista exigida? | `C_AchievementInfo` / `GetAchievementInfo(id)` → `completed` |
| **Qual vendedor / onde / link Wowhead / custo exato** | **Tabela curada** (a API não fornece) |

A API resolve o *estado* (coletada? elegível? quanto de currency?). A tabela curada
resolve o *contexto* que a API não expõe (vendedor, zona, coords, link, custo).
Mantemos a tabela **enxuta**: só montarias de reputação na v0.

---

## 3. Estrutura de arquivos

```
MountTracker/
├── MountTracker.toc            # manifesto: versão da interface, ordem de load, SavedVariables
├── Core/
│   ├── Init.lua                # namespace addon, defaults do DB, registro de eventos
│   ├── Database.lua            # SavedVariables: overrides do usuário (obtida/oculta)
│   └── Events.lua              # PLAYER_LOGIN, MOUNT_JOURNAL_*, CURRENCY_DISPLAY_UPDATE...
├── Data/
│   ├── Schema.lua              # documentação do formato de uma entrada curada
│   └── Mounts_Reputation.lua   # tabela curada (v0: só reputação/vendedor)
├── Logic/
│   ├── Scanner.lua             # lê o Mount Journal, cruza com a tabela curada
│   ├── Eligibility.lua         # decide o STATUS de cada montaria (a regra central)
│   └── Roadmap.lua             # ordena por dificuldade → lista priorizada
├── UI/
│   ├── MainFrame.lua           # janela principal + scroll list
│   ├── Row.lua                 # template de uma linha (ícone, nome, badge, ações)
│   └── Filters.lua             # filtros: status, facção, esconder ocultas
└── Libs/                       # (opcional) Ace3 / LibStub se decidirmos usar
```

**Decisão pendente:** usar **Ace3** (AceDB, AceGUI, AceEvent) ou **API pura do Blizzard**.
Recomendo API pura na v0 — menos dependências, e a UI é simples o bastante.

---

## 4. Modelo de dados curado

Cada entrada da tabela curada (`Data/Mounts_Reputation.lua`):

```lua
-- chave = mountID (o ID estável do Mount Journal)
[1304] = {
    -- Origem
    source      = "vendor",
    vendor      = "Provisioner Mukra",
    zone        = "Hellfire Peninsula",
    coords      = { x = 53.7, y = 38.0 },   -- opcional, p/ TomTom/waypoint futuro

    -- Requisito de desbloqueio (o que torna você ELEGÍVEL a comprar)
    requirement = {
        type     = "reputation",
        factionID = 946,          -- Honor Hold
        standing  = "Exalted",    -- ou renownLevel = 20 p/ facções modernas
    },

    -- Custo (o que você paga ao comprar)
    cost = {
        currencyID = nil,         -- nil = ouro
        gold       = 70,          -- em ouro (ou amount + currencyID p/ currency)
    },

    -- Referência
    wowhead = "https://www.wowhead.com/mount/...",
},
```

Para currency moderna (ex.: Trader's Tender, Bronze, selos): `cost = { currencyID = 2003, amount = 500 }`.

---

## 5. Máquina de status (o cérebro — `Logic/Eligibility.lua`)

Para cada montaria **não coletada** com entrada curada, calculamos um STATUS:

| Status | Condição | Cor/Badge |
|---|---|---|
| `READY` | Requisito satisfeito **E** custo pagável agora (currency/ouro suficiente) | 🟢 Verde — "pode pegar agora!" |
| `NEED_CURRENCY` | Requisito satisfeito, mas falta currency/ouro | 🟡 Amarelo — falta X de Y |
| `NEED_REQUIREMENT` | Reputação/conquista ainda não atingida | 🟠 Laranja — falta tanto de rep |
| `WRONG_FACTION` | `isFactionSpecific` e `faction ≠ facção do jogador` | 🔴 Vermelho — inelegível por facção |
| `HIDDEN` | Usuário ocultou manualmente | (filtrado por padrão) |
| `MARKED_OBTAINED` | Usuário marcou como obtida (corrige track indevido) | (sai da lista) |

Pseudo-fluxo:

```
para cada mountID com entrada curada:
    info = GetMountInfoByID(mountID)
    se info.isCollected ou DB.markedObtained[mountID]: pular
    se DB.hidden[mountID]: status = HIDDEN
    senão se info.isFactionSpecific e info.faction ≠ playerFaction: status = WRONG_FACTION
    senão:
        reqOk = checaRequisito(entry.requirement)      -- rep/renown/conquista
        custoOk = checaCusto(entry.cost)               -- currency/ouro atual
        se não reqOk:        status = NEED_REQUIREMENT
        senão se não custoOk: status = NEED_CURRENCY
        senão:               status = READY
    guardar { mountID, status, faltaRep, faltaCurrency, entry, info }
```

> **Por que "elegível mas não sabe" funciona:** o jogador frequentemente já está
> Exalted/Renown numa facção antiga. `READY` acende verde e mostra exatamente onde ir.

---

## 6. Roadmap / priorização (`Logic/Roadmap.lua`)

Ordenação da lista (mais fácil primeiro):

1. `READY` no topo (pode pegar agora — zero esforço).
2. `NEED_CURRENCY` — ordenado por **% de currency já acumulada** (quase lá primeiro).
3. `NEED_REQUIREMENT` — ordenado por **proximidade da reputação** (faltando menos primeiro).
4. `WRONG_FACTION` e `HIDDEN` no fim (ou escondidos por filtro).

Score de dificuldade simples (menor = mais fácil), refinável depois:
`READY=0` · `NEED_CURRENCY = 1 + (1 - currencyPct)` · `NEED_REQUIREMENT = 2 + repRestantePct`.

---

## 7. Persistência (`Core/Database.lua` → SavedVariables)

Declarado no `.toc`: `## SavedVariables: MountTrackerDB`

```lua
MountTrackerDB = {
    markedObtained = { [mountID] = true },   -- track indevido corrigido
    hidden         = { [mountID] = true },   -- ocultas manualmente (ex.: facção oposta)
    settings       = { showWrongFaction = false, showHidden = false },
}
```

Account-wide (montarias e coleção já são por conta no WoW moderno). Sem necessidade de
dados por personagem na v0, exceto currency/rep que são lidas ao vivo da API.

---

## 8. Interface (UI/)

Janela única, abrível por `/mtrack`, `/mtr` ou `/mounttracker` (slash command) e/ou ícone minimap.

```
┌─ MountTracker ───────────────────────────────[x]┐
│ Filtros: [✓Ready] [✓Need Cur] [✓Need Rep] [ Oculta]│
│ ─────────────────────────────────────────────────│
│ 🟢 Reins of the X      Honor Hold · Hellfire P.    │
│    Vendedor: Provisioner Mukra · 70g (tem 5.000g)  │
│    [Marcar obtida] [Ocultar] [Wowhead]             │
│ ─────────────────────────────────────────────────│
│ 🟡 Reins of the Y      Maw · 1.500/2.500 Stygia    │
│    Vendedor: Ve'nari · faltam 1.000 Stygia         │
│    [Marcar obtida] [Ocultar] [Wowhead]             │
│ ─────────────────────────────────────────────────│
│ 🟠 Reins of the Z      precisa Exalted (tem Honored)│
│    ...                                              │
└────────────────────────────────────────────────────┘
```

Cada **linha** mostra: ícone · nome · badge de status · local/vendedor · custo vs. posse.
Ações por linha: **Marcar obtida** · **Ocultar** · **Wowhead** (copia link / popup com URL,
pois addons não abrem navegador — mostramos a URL para copiar).

---

## 9. Fluxo de eventos

- `PLAYER_LOGIN` → inicializa DB, faz scan inicial, monta roadmap.
- `MOUNT_JOURNAL_USABILITY_CHANGED` / nova montaria aprendida → re-scan.
- `CURRENCY_DISPLAY_UPDATE` → recalcula status de custo (refresh leve).
- `UPDATE_FACTION` → recalcula requisitos de reputação.
- Abrir a janela → render a partir do último roadmap calculado (recalcula se "sujo").

---

## 10. Roadmap de implementação (fases)

- **Fase 0 (esboço — você está aqui):** este documento.
- **Fase 1 — Esqueleto:** `.toc`, namespace, slash command, janela vazia, SavedVariables.
- **Fase 2 — Scanner + Eligibility:** ler Mount Journal, cruzar com ~10 montarias curadas
  de exemplo, computar status. Saída em chat (debug) antes da UI.
- **Fase 3 — UI:** lista rolável, badges, ações (marcar obtida / ocultar / wowhead).
- **Fase 4 — Roadmap:** ordenação por dificuldade + filtros.
- **Fase 5 — Curadoria:** expandir `Mounts_Reputation.lua` para todas as de reputação.
- **Futuro:** conquista, drop, quest; waypoint TomTom; export.

---

## 11. Decisões em aberto (a confirmar antes da Fase 1)

1. **Ace3 vs. API pura?** → recomendo API pura na v0.
2. **Botão de minimapa** (LibDBIcon) ou só slash command? → slash command na v0.
3. **Versão de interface alvo do `.toc`** — confirmar a build atual de TWW em uso.
4. **Currency "Wowhead link"** — popup com URL para copiar (não dá pra abrir navegador in-game).
