-- Logic/Eligibility.lua
-- O cerebro: decide o STATUS de cada candidato e calcula o "quanto falta".

local ADDON, ns = ...

local Eligibility = {}
ns.Logic.Eligibility = Eligibility

-- Faccao do jogador como 0 (Horde) / 1 (Alliance) p/ comparar com info.faction.
local function playerFactionId()
    local g = UnitFactionGroup("player")
    if g == "Alliance" then return 1 elseif g == "Horde" then return 0 end
    return nil -- Neutro (Panda nivel 1) etc.
end

-- Le a reputacao classica de uma faccao: retorna reaction (1..8).
-- Pode devolver nil se a API falhar ou se o valor vier protegido (Secret Value).
local function getReputation(factionID)
    if C_Reputation and C_Reputation.GetFactionDataByID then
        local d = C_Reputation.GetFactionDataByID(factionID)
        if d then
            local reaction = ns.Safe.Value(d.reaction, nil) -- nil se for secreto
            return reaction
        end
    end
    return nil
end

-- Resolve uma Major Faction (renome) pelo NOME, via API do jogo. Usado quando o
-- dado curado tem factionName mas nao o factionID (ex.: facoes que o Wowhead nao
-- indexa). Mapa montado uma vez (lazy) e cacheado.
local _mfByName
local function majorFactionByName(name)
    if not name then return nil end
    if not _mfByName then
        _mfByName = {}
        if C_MajorFactions and C_MajorFactions.GetMajorFactionIDs then
            for _, id in ipairs(C_MajorFactions.GetMajorFactionIDs() or {}) do
                local d = C_MajorFactions.GetMajorFactionData(id)
                if d and d.name then _mfByName[d.name:lower()] = id end
            end
        end
    end
    local key = name:lower()
    return _mfByName[key] or _mfByName[key:gsub("^the ", "")] or _mfByName["the " .. key]
end

-- Standing (reaction 1..8) -> nome, p/ mostrar o nivel atual de reputacao classica.
local REACTION_TO_STANDING = {
    "Hated", "Hostile", "Unfriendly", "Neutral",
    "Friendly", "Honored", "Revered", "Exalted",
}

-- Nome de uma faccao de reputacao classica (pode ser nil se a API nao resolver).
local function reputationName(factionID)
    if factionID and C_Reputation and C_Reputation.GetFactionDataByID then
        local d = C_Reputation.GetFactionDataByID(factionID)
        if d and d.name and d.name ~= "" then return d.name end
    end
    return nil
end

-- Checa requisito: retorna (ok, faltaTexto). O faltaTexto e informativo: diz QUAL e
-- a faccao/conquista e o progresso ATUAL do personagem vs o necessario.
local function checkRequirement(req)
    if not req then return true, nil end

    if req.type == "reputation" then
        local needed = ns.STANDING_TO_REACTION[req.standing] or 8
        local current = getReputation(req.factionID)
        local fname = reputationName(req.factionID) or req.factionName or "Reputation"
        if not current then
            return false, ("%s: need %s (current hidden)"):format(fname, req.standing or "?")
        end
        if current >= needed then return true, nil end
        return false, ("%s: %s / need %s"):format(
            fname, REACTION_TO_STANDING[current] or "?", req.standing or "?")

    elseif req.type == "renown" then
        local fid = req.factionID or majorFactionByName(req.factionName)
        local d = fid and C_MajorFactions and C_MajorFactions.GetMajorFactionData(fid)
        local fname = (d and d.name) or req.factionName or "Renown faction"
        local need = req.renownLevel or 0
        if not d then
            -- Faccao nao resolvida no cliente: ainda informamos qual e quanto e preciso.
            return false, ("%s: need Renown %d"):format(fname, need)
        end
        local cur = d.renownLevel or 0
        if cur >= need then return true, nil end
        return false, ("%s: Renown %d / %d"):format(fname, cur, need)

    elseif req.type == "achievement" then
        local name, _, _, completed = GetAchievementInfo(req.achievementID)
        if completed then return true, nil end
        return false, ("Achievement: %s"):format(name or ("#" .. tostring(req.achievementID)))
    end

    return true, nil
end

-- Checa custo: retorna (ok, faltaTexto, posseTexto, pct 0..1, unknown).
-- `unknown=true` quando o valor de posse vem protegido pelo jogo (Secret Value).
local function checkCost(cost)
    if not cost then return true, nil, nil, 1, false end

    if cost.currencyID then
        local info = C_CurrencyInfo.GetCurrencyInfo(cost.currencyID)
        local rawHave = info and info.quantity
        local have, secret = ns.Safe.Value(rawHave, nil)
        if secret then return false, nil, nil, 0, true end
        have = have or 0
        local need = cost.amount or 0
        local pct = need > 0 and math.min(have / need, 1) or 1
        local cname = info and info.name or ("currency " .. cost.currencyID)
        local posse = ("%d/%d %s"):format(have, need, cname)
        if have >= need then return true, nil, posse, 1, false end
        return false, ("need %d more %s"):format(need - have, cname), posse, pct, false

    elseif cost.itemID then
        local rawCount = (C_Item and C_Item.GetItemCount and C_Item.GetItemCount(cost.itemID))
            or (GetItemCount and GetItemCount(cost.itemID))
        local have, secret = ns.Safe.Value(rawCount, nil)
        if secret then return false, nil, nil, 0, true end
        have = have or 0
        local need = cost.amount or 0
        local pct = need > 0 and math.min(have / need, 1) or 1
        local iname = (C_Item and C_Item.GetItemInfo and C_Item.GetItemInfo(cost.itemID))
            or (GetItemInfo and GetItemInfo(cost.itemID)) or ("item " .. cost.itemID)
        local posse = ("%d/%d %s"):format(have, need, iname)
        if have >= need then return true, nil, posse, 1, false end
        return false, ("need %d more %s"):format(need - have, iname), posse, pct, false

    elseif cost.gold then
        local rawCopper = GetMoney()
        local haveCopper, secret = ns.Safe.Value(rawCopper, nil)
        if secret then return false, nil, nil, 0, true end
        haveCopper = haveCopper or 0
        local needCopper = cost.gold * 10000
        local haveGold = math.floor(haveCopper / 10000)
        local posse = ("%dg (have %dg)"):format(cost.gold, haveGold)
        local pct = needCopper > 0 and math.min(haveCopper / needCopper, 1) or 1
        if haveCopper >= needCopper then return true, nil, posse, 1, false end
        return false, ("need %dg more"):format(cost.gold - haveGold), posse, pct, false
    end

    return true, nil, nil, 1, false
end

-- Formata a chance de drop (fracao 0..1) como texto amigavel + tier.
-- Ex.: 1/25 -> "Drop ~1 in 25 (4.0%)"; sem dado -> nota generica.
local function formatOdds(chance, note)
    if not chance or chance <= 0 then
        return note or "Random drop - rate unknown"
    end
    local n = math.floor(1 / chance + 0.5)
    local tier
    if n <= 50 then tier = "acceptable"
    elseif n <= 100 then tier = "rare"
    else tier = "very rare" end
    return ("Drop ~1 in %d (%.1f%%) - %s"):format(n, chance * 100, tier)
end

-- Limpa o sourceText do jogo: remove texturas, desembrulha hyperlinks (mantendo o
-- texto visivel), tira codigos de cor e converte quebras (|n) em espaco.
local function cleanSource(s)
    if not s or s == "" then return "" end
    s = s:gsub("|T.-|t", "")             -- texturas (icones de currency/item)
    s = s:gsub("|H.-|h(.-)|h", "%1")     -- hyperlinks -> mantem so o texto visivel
    s = s:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")  -- codigos de cor
    s = s:gsub("|n", " ")                -- quebras de linha
    s = s:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return s
end
ns.CleanSource = cleanSource

-- Rotulo nativo do tipo de fonte (sourceType numerico do Mount Journal). Usa as
-- strings globais do proprio jogo (BATTLE_PET_SOURCE_*), compartilhadas com mounts.
-- Ex.: 1->"Drop", 2->"Quest", 3->"Vendor", 6->"Achievement", 7->"World Event"...
-- E o que cobre montarias cujo sourceText vem vazio/curto (ex.: baus de tesouro,
-- que o jogo marca como "Drop" no tipo, mesmo sem citar nada no texto).
local function nativeSourceLabel(sourceType)
    if not sourceType then return nil end
    local s = _G["BATTLE_PET_SOURCE_" .. sourceType]
    if s and s ~= "" then return s end
    return nil
end
ns.NativeSourceLabel = nativeSourceLabel

-- Categoriza uma montaria nao-curada. Tenta o texto de origem (palavras-chave en-US)
-- e, se nao classificar, recorre ao `sourceType` nativo do jogo.
-- Retorna (category, baseDifficulty).
local function categorize(sourceText, sourceType)
    local s = (sourceText or ""):lower()
    local function has(p) return s:find(p, 1, true) ~= nil end

    if has("legacy")          then return "Legacy",       9.5 end
    -- Trading Post: so obtenivel quando rotaciona na loja do mes -> baixa prioridade.
    if has("trading post")    then return "Trading Post", 4.5 end
    if has("black market")    then return "Black Market", 4.0 end
    if has("promotion") or has("recruit") or has("collector's edition")
                              then return "Promotion",    9.0 end
    -- Evento/feriado: obtenivel so durante o evento -> prioridade media.
    if has("holiday:") or has("darkmoon") or has("event:")
                              then return "Holiday",       3.5 end
    if has("vendor:")         then return "Vendor",       2.2 end
    if has("renown:") or has("faction:")
                              then return "Reputation",   2.3 end
    if has("achievement")     then return "Achievement",  2.4 end
    if has("world quest")     then return "World Quest",  3.2 end
    if has("quest")           then return "Quest",        2.6 end
    if has("profession")      then return "Profession",   4.5 end
    if has("pvp") or has("arena") or has("rated") or has("conquest")
                              then return "PvP",          4.8 end
    if has("treasure")        then return "Treasure",     4.0 end
    if has("drop")            then return "Drop",         5.0 end

    -- Texto nao classificou: cai no tipo de fonte nativo do jogo (sourceType).
    -- Cobre montarias com sourceText vazio/curto (ex.: bau de tesouro = "Drop").
    local label = nativeSourceLabel(sourceType)
    if label then
        local l = label:lower()
        local map = {
            ["drop"]              = { "Drop",         5.0 },
            ["quest"]             = { "Quest",        2.6 },
            ["vendor"]            = { "Vendor",       2.2 },
            ["profession"]        = { "Profession",   4.5 },
            ["achievement"]       = { "Achievement",  2.4 },
            ["world event"]       = { "World Event",  3.5 },
            ["promotion"]         = { "Promotion",    9.0 },
            ["trading card game"] = { "TCG",          9.0 },
            ["black market"]      = { "Black Market", 4.0 },
            ["trading post"]      = { "Trading Post", 4.5 },
        }
        local m = map[l]
        if m then return m[1], m[2] end
        return label, 4.0   -- tipo desconhecido p/ nos: usa o proprio rotulo do jogo
    end

    return "Other", 4.0
end

-- Quanto o personagem possui de um custo parseado (nil = desconhecido/Secret Value).
function ns.CostHave(c)
    if c.ctype == "currency" then
        local ci = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(c.id)
        return ci and ns.Safe.Value(ci.quantity, nil) or nil
    elseif c.ctype == "item" and c.id then
        local cnt = (C_Item and C_Item.GetItemCount and C_Item.GetItemCount(c.id)) or (GetItemCount and GetItemCount(c.id))
        return ns.Safe.Value(cnt, nil)
    elseif c.ctype == "gold" then
        return ns.Safe.Value(math.floor((GetMoney() or 0) / 10000), nil)
    end
    return nil  -- token opaco (sem ID) ou desconhecido -> posse indeterminada
end

-- Palavras que indicam um requisito no texto do jogo (camada 1 = consulta nativa).
local READY_GATE_WORDS = { "renown", "exalted", "revered", "honored", "friendly", "faction:", "achievement", "requires", "holiday:", "event:" }

-- "Da pra pegar AGORA?" -> glow + topo da lista. Double-check em camadas:
--   1. Curado (Wowhead): READY = elegibilidade verificada.
--   2. Jogo nativo: se o sourceText cita requisito -> ha gate -> nao.
--   3. Fallback: nenhum requisito conhecido -> sim, se o custo esta pago.
function Eligibility.IsReadyNow(item)
    if item.owned then return false end
    if item.status == ns.STATUS.READY then return true end   -- curado verificado
    if item.entry then return false end                      -- curado, ainda nao elegivel
    if item.status ~= ns.STATUS.MISSING then return false end

    local t = (item.sourceText or ""):lower()
    for _, w in ipairs(READY_GATE_WORDS) do
        if t:find(w, 1, true) then return false end
    end
    local costSource = nil
    for _, s in ipairs(item.sources or {}) do
        if s.renown then return false end
        if not costSource and s.costs and #s.costs > 0 then costSource = s end
    end
    if not costSource then return false end
    for _, c in ipairs(costSource.costs) do
        local have = ns.CostHave(c)
        if have == nil or have < (c.amount or 0) then return false end
    end
    return true
end

-- Avalia UM candidato. Retorna um "item de roadmap" enriquecido.
function Eligibility.Evaluate(cand)
    local info, entry, mountID = cand.info, cand.entry, cand.mountID
    local S = ns.STATUS

    -- Texto p/ derivar a expansao: o sourceText AO VIVO + os campos curados
    -- (source/zone). Drops em zonas reaproveitadas (ex.: "Eversong Woods Rare
    -- Creatures" do Midnight) muitas vezes nao trazem a zona no texto ao vivo;
    -- o dado curado preenche essa lacuna p/ a classificacao acertar (Midnight).
    local expText = cand.sourceText or ""
    if entry then expText = expText .. " " .. (entry.source or "") .. " " .. (entry.zone or "") end

    local item = {
        mountID = mountID,
        spellID = cand.spellID,
        name    = info.name or (entry and entry.name),
        icon    = info.icon,
        entry   = entry,
        sourceText = cand.sourceText,
        sources = ns.SourceParse and ns.SourceParse(cand.sourceText) or {},
        expansion = ns.ExpansionFor and ns.ExpansionFor(expText, entry and entry.expansion, cand.spellID) or "Unknown",
        costPct = 0,
    }

    -- 1) Ja coletada ou marcada como obtida -> status OWNED (so aparece com "Show owned").
    if info.isCollected or ns.DB.IsMarkedObtained(mountID) then
        item.owned = true
        -- markedOnly = marcada a mao mas NAO realmente coletada -> reversivel ("Unmark").
        item.markedOnly = (not info.isCollected) and ns.DB.IsMarkedObtained(mountID) or nil
        item.status = S.OWNED
        item.detail = info.isCollected and "Already collected" or "Marked as owned (click Unmark to undo)"
        return item
    end

    -- 2) Oculta manualmente.
    if ns.DB.IsHidden(mountID) then
        item.status = S.HIDDEN
        return item
    end

    -- 2.5) O jogo esconde esta montaria para este personagem (faccao oposta, classe,
    --      legacy/inobtenivel). Sinal autoritativo do proprio Mount Journal.
    if cand.shouldHideOnChar then
        item.status = S.UNAVAILABLE
        item.detail = ns.CleanSource and ns.CleanSource(cand.sourceText) or ""
        return item
    end

    -- 3) Faccao oposta (inelegivel) -- sinal do proprio mount (quando o jogo flaga).
    local pf = playerFactionId()
    if info.isFactionSpecific and info.faction ~= nil and pf ~= nil and info.faction ~= pf then
        item.status = S.WRONG_FACTION
        item.detail = "Opposite faction mount"
        return item
    end

    -- 3b) Restricao de faccao do CONTEUDO curado (ex.: reputacao Ankoan = so Alliance).
    --     O jogo NAO flaga a montaria (ela e account-wide), mas a aquisicao pertence a
    --     uma unica faccao -> esconde para a faccao oposta (so aparece com "show hidden").
    if entry and entry.faction then
        local g = UnitFactionGroup("player")
        if (g == "Alliance" or g == "Horde") and entry.faction ~= g then
            item.status = S.WRONG_FACTION
            item.detail = entry.faction .. "-only (acquisition)"
            return item
        end
    end

    -- 3.5) Nao-curada: usa o texto de origem do proprio jogo (base ao vivo).
    --      Cobertura total imediata; a curadoria (overlay) refina depois.
    if not entry then
        local cat, baseDiff = categorize(cand.sourceText, cand.sourceType)
        item.status   = S.MISSING
        item.category = cat
        item._catDiff = baseDiff
        item.detail   = cleanSource(cand.sourceText)
        -- sourceText vazio (ex.: bau de tesouro): mostra ao menos o tipo nativo,
        -- p/ a linha de origem nao ficar em branco/"?".
        if item.detail == "" then
            item.detail = nativeSourceLabel(cand.sourceType) or ""
        end
        return item
    end

    -- 4) Drop / RNG: nao e "comprar", e farmar. Se houver requisito de desbloqueio
    --    (ex.: conquista) e ele faltar, mostramos isso; senao, status FARM com as odds.
    if entry.acquisition == "drop" or entry.acquisition == "world" or entry.acquisition == "rare" then
        local reqOk, reqMissing = checkRequirement(entry.requirement)
        if not reqOk then
            item.status = S.NEED_REQUIREMENT
            item.detail = reqMissing
        else
            item.status = S.FARM
            item.dropChance = entry.dropChance     -- consumido pela ordenacao (Roadmap)
            item.detail = formatOdds(entry.dropChance, entry.dropNote)
        end
        return item
    end

    -- 5) Requisito + custo (vendedor/reputacao/conquista/quest).
    local reqOk, reqMissing = checkRequirement(entry.requirement)
    local costOk, costMissing, costHave, costPct, costUnknown = checkCost(entry.cost)
    item.costPct  = costPct or 0
    item.costHave = costHave

    if costUnknown then
        -- Value protected by the game (Secret Value): can't assert the status.
        item.status = S.UNKNOWN
        item.detail = "Balance protected by game - check at vendor"
    elseif not reqOk then
        item.status = S.NEED_REQUIREMENT
        item.detail = reqMissing
    elseif not costOk then
        item.status = S.NEED_CURRENCY
        item.detail = costMissing
    else
        item.status = S.READY
        item.detail = "Can buy now"
    end

    return item
end
