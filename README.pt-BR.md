<div align="center">

# 🐎 MountTracker

### Seu roadmap pessoal de coleção de montarias — revelando as que você já pode pegar *agora* e nem sabia.

**Idioma:** [English](README.md) · **Português (BR)**

![Game](https://img.shields.io/badge/WoW-Midnight%2012.0.5-8B0000)
![Interface](https://img.shields.io/badge/Interface-120005-444)
![Dependências](https://img.shields.io/badge/depend%C3%AAncias-nenhuma-2ea44f)
![Lua](https://img.shields.io/badge/Lua-5.1-000080)
![Status](https://img.shields.io/badge/status-em%20desenvolvimento-blue)

</div>

---

## ✨ Por que o MountTracker?

Existem vários addons que listam as montarias que faltam pra você. **Nenhum deles te diz quais você já pode reivindicar.**

Você joga há anos. Em algum momento atingiu **Exaltado** com uma facção, completou uma **conquista** ou acumulou uma **moeda** — e a montaria ligada àquilo ficou lá, parada, sem ser coletada, simplesmente porque o jogo nunca te avisou.

> **O recurso-estrela do MountTracker:** ele cruza, *ao vivo*, sua reputação, moedas, ouro e conquistas com todas as montarias que você não tem, e **acende as que você já é elegível** com uma borda verde pulsante. Acabou o "peraí, eu podia ter isso esse tempo todo?".

E então monta um **roadmap** de tudo o que falta, ordenado da *mais fácil de obter* para a *mais difícil*, com o vendedor exato, o local, o custo e quanto daquela moeda você tem no bolso.

---

## 🎯 O que ele faz

- **Acompanha a coleção da conta inteira** ao vivo, pelo Mount Journal.
- **Monta um roadmap priorizado** das montarias que faltam — as mais fáceis primeiro.
- **Detecta elegibilidade oculta** — o brilho verde significa *"dá pra pegar agora."*
- **Mostra exatamente como obter cada montaria:** nome do vendedor, zona, custo (com ícone da moeda **e quanto você possui**), ou a fonte do drop e a taxa.
- **Esconde o que você não pode pegar** — montarias da facção oposta, travadas por classe e legacy/inobteníveis ficam ocultas por padrão (e a um clique de distância quando você quiser).
- **Filtro por expansão**, alternar obtidas/indisponíveis e gerenciar a lista manualmente.

---

## 🚀 Recursos num relance

| Recurso | Descrição |
|---|---|
| 🟢 **Brilho de "dá pra pegar agora"** | Borda pulsante em qualquer montaria cujos requisitos você já cumpre (reputação OK + moeda/ouro OK). |
| 🗺️ **Cobertura da coleção inteira** | Todas as montarias que faltam no jogo, usando os dados do próprio jogo — não uma lista digitada à mão. |
| 💰 **Rastreador de moeda ("have")** | O custo mostra o ícone, o nome **e o seu saldo atual** — verde quando dá pra comprar, laranja quando não. |
| 🎲 **Graduação por drop rate** | Drops de RNG são ranqueados pela chance: `1/25` é "vai farmar," `1/200` afunda pro fim — cada um com sua porcentagem. |
| ⚔️ **Filtro de facção inteligente** | Usa o sinal de visibilidade do próprio jogo pra esconder corretamente montarias da facção oposta e travadas por classe (não só as "pareadas" que outras ferramentas erram). |
| 📂 **Filtro por expansão** | Restrinja o roadmap a Classic, TBC, WotLK … até The War Within e Midnight. |
| 🏷️ **Overlay curado** | Dados verificados à mão (do Wowhead) adicionam detecção precisa de elegibilidade, drop rates e links do Wowhead por cima da base ao vivo. |
| 🧭 **Botão de minimapa** | Arraste pra qualquer ponto da borda; clique pra abrir. Zero bibliotecas externas. |
| 🔗 **Wowhead num clique** | Toda montaria tem link do Wowhead — copie direto da linha. |
| 🛡️ **Sem erro no meio da tela** | Todo ponto de entrada é blindado; se algo falha, você recebe uma mensagem discreta no chat, nunca um popup de erro Lua. |
| 🔒 **Compatível com Secret Values do Midnight** | Lida com a API de "Secret Value" do 12.0 com elegância, em vez de quebrar. |
| 🪶 **Zero dependências** | API pura do Blizzard. Sem Ace3, sem LibDBIcon, nada pra instalar junto. |

---

## 📸 Capturas de tela

> _Em breve._ Coloque suas imagens em `images/` e referencie aqui, por exemplo:
>
> `![Janela do roadmap](images/roadmap.png)`
> `![Brilho de obtenível](images/glow.png)`

---

## 📥 Instalação

**Manual (por enquanto):**

1. Baixe este repositório (botão verde **Code → Download ZIP**) ou clone.
2. Extraia a pasta `MountTracker` para:
   ```
   World of Warcraft\_retail_\Interface\AddOns\
   ```
   (A pasta precisa se chamar `MountTracker` e conter o `MountTracker.toc`.)
3. Reinicie o jogo, ou dê `/reload` se já estava aberto.
4. Confirme que o **MountTracker** está marcado na lista de AddOns na tela de personagem.

> Alvo: **Midnight 12.0.5** (`## Interface: 120005`). Jogando outra build? Edite a linha `## Interface:` no topo do `MountTracker.toc`, ou marque *"Carregar AddOns desatualizados."*

---

## 🕹️ Uso

Abra a janela pelo **botão de minimapa** ou por um slash command:

| Comando | O que faz |
|---|---|
| `/mtrack` (ou `/mtr`, `/mounttracker`) | Abre / fecha a janela do roadmap |
| `/mtrack scan` | Imprime um resumo no chat (obtidas / obteníveis / indisponíveis) |
| `/mtrack find <nome>` | Procura o ID interno de uma montaria |
| `/mtrack minimap` | Mostra / esconde o botão do minimapa |
| `/mtrack reset` | Limpa seus overrides manuais (marcada-obtida / oculta) |
| `/mtrack debug` | Liga / desliga o detalhe técnico de erros |
| `/mtrack help` | Lista todos os comandos |

**Na janela:**
- **Wowhead** — copia o link do Wowhead da montaria.
- **Hide** — esconde uma montaria que você não quer.
- **Owned** — marca como obtida (corrige um track indevido).
- Use o dropdown **Expansion** e os checkboxes **Show owned / Show unavailable** para moldar a lista.

---

## 🧠 Como funciona

O MountTracker usa um **modelo híbrido**:

1. **Base ao vivo — cobertura total.** Ele lê *todas* as montarias do Mount Journal e usa o `sourceText` do próprio jogo (vendedor, zona, facção, renome, quest) para descrever como obter cada uma. Isso cobre o jogo inteiro com zero dado manual e está sempre atualizado.
2. **Overlay curado — a mágica.** Uma tabela verificada à mão (do Wowhead, indexada por spell ID) fica por cima e adiciona o que a API não dá: **detecção precisa de elegibilidade** (você já cumpre o requisito de reputação/moeda?), **drop rates** e **links do Wowhead**.

Elegibilidade, saldos de moeda e reputação são lidos **ao vivo** toda vez, então o roadmap sempre reflete o estado real do seu personagem — incluindo o tratamento correto dos **Secret Values** do Midnight.

Uma ferramenta interna `/mtrack dump` exporta seu journal para que contribuidores expandam o overlay curado com dados precisos e independentes de idioma.

---

## 🗺️ Status e roadmap do projeto

O MountTracker está em **desenvolvimento ativo**. A base ao vivo já cobre a coleção inteira; o overlay curado de elegibilidade está sendo expandido **expansão por expansão** (Classic → TBC → WotLK → …).

- [x] Base ao vivo sobre o Mount Journal completo
- [x] Detecção de elegibilidade oculta + brilho de "obtenível agora"
- [x] "Have" de moeda, graduação por drop rate, filtros de facção e expansão
- [x] Botão de minimapa, overrides manuais, blindagem de erros
- [ ] Overlay curado de elegibilidade completo em todas as expansões
- [ ] Mapeamento boss/dungeon → expansão (reduzir o bucket "Unknown")
- [ ] Waypoints opcionais via TomTom

---

## 🤝 Como contribuir

Ajuda na curadoria é muito bem-vinda! A contribuição mais valiosa são **dados de aquisição verificados** (spell ID, facção/nível, vendedor, custo, drop rate, link do Wowhead).

1. Rode `/mtrack dump` no jogo, depois `/reload`.
2. O export vai para o seu `SavedVariables\MountTracker.lua`.
3. Abra uma issue ou PR com os dados — ou só o dump, que a gente converte.

Reports de bug e feedback de UI são igualmente bem-vindos. Inclua a saída do `/mtrack debug` se você topar com um erro.

---

## ❓ Perguntas frequentes

**Funciona para a facção oposta / outras classes?**
Montarias que seu personagem não pode obter ficam escondidas por padrão (usando o sinal do próprio jogo). Marque **"Show unavailable / hidden"** para vê-las.

**Por que uma montaria está na expansão "Unknown"?**
O texto de origem dela não cita uma zona reconhecível (comum em drops de boss, profissões e eventos sazonais). Ela continua na lista — só no bucket curinga.

**Os drop rates são exatos?**
Não — são estimativas da comunidade (Wowhead). Use como guia, não como verdade absoluta.

**Precisa de algum outro addon?**
Não. É API pura do Blizzard, com zero dependências.

---

## 📜 Licença

Lançado sob a **Licença MIT** — livre para usar, estudar e melhorar. Veja `LICENSE`.

> _World of Warcraft e os ativos relacionados são marcas registradas da Blizzard Entertainment. Este é um addon não-oficial, feito por fã._

---

<div align="center">

Feito com ❤️ para a comunidade colecionadora de montarias de WoW.
**Boa caçada — que seus brilhos verdes sejam muitos. 🐎✨**

</div>
