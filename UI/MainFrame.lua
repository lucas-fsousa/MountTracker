-- UI/MainFrame.lua
-- Janela principal: lista rolavel com badge de status, detalhe e acoes por linha.

local ADDON, ns = ...

local UI = ns.UI
local ROW_HEIGHT = 72
local ROW_SPACING = 2
local ROW_STEP = ROW_HEIGHT + ROW_SPACING
local frame, scroll
local rows = {}

-- ---- Helpers de render do custo/vendedores (linha 2 e 3) ----

-- Abrevia numeros grandes: 42506 -> "42.5k", 1500000 -> "1.5M", 500 -> "500".
local function num(n)
    n = tonumber(n) or 0
    local function trim(x) return (("%.1f"):format(x):gsub("%.0$", "")) end
    if n >= 1e6 then
        return trim(n / 1e6) .. "M"
    elseif n >= 1e3 then
        return trim(n / 1e3) .. "k"
    end
    return tostring(math.floor(n))
end

local function costName(c)
    if c.ctype == "currency" then
        local ci = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(c.id)
        return ci and ci.name or "currency", ci and ci.iconFileID
    elseif c.ctype == "item" and c.id then
        return (C_Item and C_Item.GetItemInfo and C_Item.GetItemInfo(c.id)) or (GetItemInfo and GetItemInfo(c.id)) or "tokens"
    elseif c.ctype == "gold" then
        return "gold"
    end
    return ""  -- token opaco: so o icone (sem nome nem "gold")
end

-- Monta a string de um custo: valor + icone + nome da moeda + quanto o char possui.
local function costToText(costs)
    local parts = {}
    for _, c in ipairs(costs or {}) do
        local name, fid = costName(c)
        local icon = c.icon and ("|T" .. c.icon .. ":13:13|t ")
            or (fid and ("|T" .. fid .. ":13:13|t "))
            or (c.ctype == "gold" and "|TInterface\\MoneyFrame\\UI-GoldIcon:13:13|t ")
            or ""
        local have = ns.CostHave(c)

        local haveStr = ""
        if have ~= nil then
            local color = (have >= (c.amount or 0)) and "ff44dd44" or "ffdd8844"
            haveStr = (" |c%s(have %s)|r"):format(color, num(have))
        end
        parts[#parts + 1] = string.format("%s %s%s%s", num(c.amount or 0), icon, name, haveStr)
    end
    return table.concat(parts, ", ")
end

-- readyNow e calculado na camada logica (Eligibility.IsReadyNow) e guardado em
-- item.readyNow, para que o glow (aqui) e a ordenacao (Roadmap) usem o mesmo sinal.

-- Linha 2: vendedores/origem (com tag de faccao [A]/[H] quando aplicavel).
local function vendorsText(item)
    local sources = item.sources or {}
    if #sources == 0 then return item.detail or "" end
    local parts = {}
    for _, s in ipairs(sources) do
        local tag = ""
        if s.faction == "Alliance" then tag = "|cff4a78ff[A]|r "
        elseif s.faction == "Horde" then tag = "|cffe5304a[H]|r " end
        -- Sempre prefixa com o tipo da fonte ("Vendor:", "Drop:", "Quest:", ...).
        -- O rotulo fica destacado em dourado, igual ao estilo do jogo.
        local label = "|cffffd200" .. (s.kind or "Source") .. ":|r "
        parts[#parts + 1] = tag .. label .. (s.who or "?")
    end
    return table.concat(parts, "    ")
end

-- Converte um cost curado ({currencyID/itemID/gold, amount}) para o formato de lista.
local function curatedCostList(cost)
    if not cost then return nil end
    if cost.currencyID then return { { amount = cost.amount, ctype = "currency", id = cost.currencyID } } end
    if cost.itemID then return { { amount = cost.amount, ctype = "item", id = cost.itemID } } end
    if cost.gold then return { { amount = cost.gold, ctype = "gold" } } end
    return nil
end

-- Linha 3: zona (+ renome) + custo.
local function zoneCostText(item)
    local sources = item.sources or {}
    local zone, cost, renown
    for _, s in ipairs(sources) do
        if not zone and s.zone then zone = s.zone end
        if not renown and s.renown then renown = s.renown end
        if not cost and s.costs and #s.costs > 0 then cost = costToText(s.costs) end
    end
    -- Fallback: muitas montarias de renome nao trazem o custo no sourceText, mas o
    -- dado curado tem -> mostra o custo curado (moeda de troca no NPC).
    if not cost and item.entry and item.entry.cost then
        local list = curatedCostList(item.entry.cost)
        if list then cost = costToText(list) end
    end
    local parts = {}
    if zone then parts[#parts + 1] = zone end
    if renown then parts[#parts + 1] = "Renown " .. renown end
    if cost then parts[#parts + 1] = "Cost: " .. cost end
    -- Drops curados: anexa as odds.
    if item.status == ns.STATUS.FARM and item.detail then parts[#parts + 1] = item.detail end
    return table.concat(parts, "    ·    ")
end

-- Linha 4: situacao atual do personagem para esta montaria (o que falta e onde esta).
-- Mostra o `detail` enriquecido (ex.: "Hara'ti: Renown 8 / 14") colorido pelo status.
local function statusDetailText(item)
    local S = ns.STATUS
    local d = item.detail
    if not d or d == "" then return "" end
    local color
    if item.status == S.NEED_REQUIREMENT then color = "ffff5555"      -- vermelho: requisito
    elseif item.status == S.NEED_CURRENCY then color = "ffffcc55"     -- ambar: falta moeda
    elseif item.status == S.READY        then color = "ff44dd44"      -- verde: pode pegar
    elseif item.status == S.UNKNOWN      then color = "ffaaaaaa"      -- cinza: protegido
    else return "" end                                               -- demais: sem L4
    return ("|c%s%s|r"):format(color, d)
end

-- Janela propria para copiar o link do Wowhead (addons nao abrem navegador).
-- Evitamos StaticPopupDialogs porque seus internos (editBox) sao fonte comum de
-- erro entre versoes; aqui controlamos tudo com uma EditBox proria.
local copyFrame
local function ShowWowhead(url)
    if not url then return end
    if not copyFrame then
        copyFrame = CreateFrame("Frame", "MountTrackerCopyFrame", UIParent, "BasicFrameTemplateWithInset")
        copyFrame:SetSize(440, 116)
        copyFrame:SetPoint("CENTER")
        copyFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        copyFrame:EnableMouse(true)
        copyFrame:SetMovable(true)
        copyFrame:RegisterForDrag("LeftButton")
        copyFrame:SetScript("OnDragStart", copyFrame.StartMoving)
        copyFrame:SetScript("OnDragStop", copyFrame.StopMovingOrSizing)
        tinsert(UISpecialFrames, "MountTrackerCopyFrame") -- fecha com ESC

        local title = copyFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        title:SetPoint("TOP", 0, -5)
        title:SetText("Wowhead link")

        local hint = copyFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        hint:SetPoint("TOPLEFT", 16, -34)
        hint:SetText("Ctrl+C to copy, then Esc to close")

        local eb = CreateFrame("EditBox", nil, copyFrame, "InputBoxTemplate")
        eb:SetSize(400, 22)
        eb:SetPoint("TOPLEFT", 18, -54)
        eb:SetAutoFocus(false)
        eb:SetFontObject("ChatFontNormal")
        eb:SetScript("OnEscapePressed", function(self) self:ClearFocus(); copyFrame:Hide() end)
        eb:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
        -- Impede edicao destrutiva: sempre reseleciona o texto.
        eb:SetScript("OnTextChanged", function(self) self:SetText(self.url or ""); self:HighlightText() end)
        copyFrame.editBox = eb
    end
    local eb = copyFrame.editBox
    eb.url = url
    eb:SetScript("OnTextChanged", nil)   -- evita recursao ao setar o texto
    eb:SetText(url)
    eb:SetScript("OnTextChanged", function(self) self:SetText(self.url or ""); self:HighlightText() end)
    eb:SetCursorPosition(0)
    copyFrame:Show()
    eb:SetFocus()
    eb:HighlightText()
end

-- ---- Painel de detalhes (abre ao clicar numa linha) ----
-- Mostra o modelo 3D da montaria + origem/zona/custo/situacao e TODAS as acoes,
-- tirando os botoes da linha (que ficava apertada). Lazy: criado no 1o uso.
local detailFrame
local function buildDetail()
    -- Filho do frame principal: e uma EXTENSAO do roadmap -> fecha junto (auto, por ser
    -- filho) e se move junto (ancorado a direita do roadmap; nao tem drag proprio).
    local f = CreateFrame("Frame", "MountTrackerDetailFrame", frame, "BasicFrameTemplateWithInset")
    f:SetSize(340, 470)
    f:SetFrameStrata("DIALOG")
    f:EnableMouse(true)                              -- bloqueia cliques passarem por baixo
    -- A ancora (lado direito/esquerdo do roadmap) e definida no ShowDetail conforme
    -- o espaco disponivel na tela. De qualquer lado, e filho do frame -> acompanha.
    tinsert(UISpecialFrames, "MountTrackerDetailFrame")  -- fecha com ESC

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.title:SetPoint("TOP", 0, -5)
    f.title:SetText("Mount detail")

    -- Modelo 3D da montaria (gira sozinho devagar).
    f.model = CreateFrame("PlayerModel", nil, f)
    f.model:SetPoint("TOPLEFT", 12, -28)
    f.model:SetPoint("TOPRIGHT", -12, -28)
    f.model:SetHeight(190)
    f.model:SetScript("OnUpdate", function(self, elapsed)
        self._rot = ((self._rot or 0) + elapsed * 0.5) % (2 * math.pi)
        self:SetFacing(self._rot)
    end)

    f.name = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.name:SetPoint("TOPLEFT", 14, -224); f.name:SetPoint("RIGHT", -14, 0)
    f.name:SetJustifyH("LEFT"); f.name:SetWordWrap(false)

    f.badge = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.badge:SetPoint("TOPLEFT", 14, -246); f.badge:SetJustifyH("LEFT")

    f.info = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.info:SetPoint("TOPLEFT", 14, -270); f.info:SetPoint("TOPRIGHT", -14, -270)
    f.info:SetJustifyH("LEFT"); f.info:SetSpacing(4); f.info:SetWordWrap(true)

    local function actBtn(text)
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetSize(312, 22); b:SetText(text)
        b:GetFontString():SetWordWrap(false)
        return b
    end
    f.btnWay = actBtn("Set waypoint to vendor"); f.btnWay:SetPoint("BOTTOM", 0, 96)
    f.btnWowhead = actBtn("Copy Wowhead link"); f.btnWowhead:SetPoint("BOTTOM", 0, 70)
    f.btnObtained = actBtn("Mark as owned"); f.btnObtained:SetPoint("BOTTOM", 0, 44)
    f.btnHide = actBtn("Hide from roadmap"); f.btnHide:SetPoint("BOTTOM", 0, 18)

    detailFrame = f
    return f
end

function UI.ShowDetail(item)
    if not item then return end
    local f = detailFrame or buildDetail()
    f._item = item

    -- Lado em que abre: direita por padrao; esquerda se nao couber na tela.
    -- (Reavaliado a cada abertura, pois o roadmap pode ter sido movido.)
    f:ClearAllPoints()
    local right = frame:GetRight()
    local screenW = UIParent:GetWidth() or 0
    if right and screenW > 0 and (right + 6 + f:GetWidth()) > screenW then
        f:SetPoint("TOPRIGHT", frame, "TOPLEFT", -6, 0)
    else
        f:SetPoint("TOPLEFT", frame, "TOPRIGHT", 6, 0)
    end

    -- Modelo 3D do proprio mount (creatureDisplayInfoID via API do jogo).
    local disp
    if item.mountID and C_MountJournal and C_MountJournal.GetMountInfoExtraByID then
        disp = select(1, C_MountJournal.GetMountInfoExtraByID(item.mountID))
    end
    f.model:ClearModel()
    if disp and disp > 0 then
        f.model:SetDisplayInfo(disp)
        f.model:SetPortraitZoom(0)
        f.model:Show()
    else
        f.model:Hide()
    end

    f.name:SetText(item.name or "?")
    local c = ns.STATUS_COLOR[item.status] or { 1, 1, 1 }
    local badgeText = (item.status == ns.STATUS.MISSING and item.category)
        or ns.STATUS_LABEL[item.status] or item.status
    f.badge:SetText(badgeText)
    f.badge:SetTextColor(c[1], c[2], c[3])

    local lines = {}
    local v = vendorsText(item);       if v ~= "" then lines[#lines + 1] = v end
    local zc = zoneCostText(item);     if zc ~= "" then lines[#lines + 1] = zc end
    local sd = statusDetailText(item); if sd ~= "" then lines[#lines + 1] = sd end
    f.info:SetText(table.concat(lines, "\n"))

    local e = item.entry
    local url = (e and e.wowhead) or (item.spellID and ("https://www.wowhead.com/spell=" .. item.spellID))
    f.btnWowhead:SetShown(url ~= nil)
    f.btnWowhead:SetScript("OnClick", ns.Safe.Wrap("open Wowhead link", function() ShowWowhead(url) end))

    if ns.Waypoint and ns.Waypoint.CanRoute(item) then
        f.btnWay:Show()
        f.btnWay:SetScript("OnClick", ns.Safe.Wrap("set waypoint", function() ns.Waypoint.ToItem(item) end))
    else
        f.btnWay:Hide()
    end

    if item.markedOnly then
        f.btnObtained:SetText("Unmark (not actually owned)")
        f.btnObtained:SetScript("OnClick", ns.Safe.Wrap("unmark", function()
            ns.DB.SetMarkedObtained(item.mountID, false); ns.Logic.Roadmap.Build(); UI.Refresh(); f:Hide()
        end))
        f.btnObtained:Show()
    elseif not item.owned then
        f.btnObtained:SetText("Mark as owned")
        f.btnObtained:SetScript("OnClick", ns.Safe.Wrap("mark owned", function()
            ns.DB.SetMarkedObtained(item.mountID, true); ns.Logic.Roadmap.Build(); UI.Refresh(); f:Hide()
        end))
        f.btnObtained:Show()
    else
        f.btnObtained:Hide()
    end

    local hidden = ns.DB.IsHidden(item.mountID)
    f.btnHide:SetText(hidden and "Unhide from roadmap" or "Hide from roadmap")
    f.btnHide:SetScript("OnClick", ns.Safe.Wrap("hide mount", function()
        ns.DB.SetHidden(item.mountID, not hidden); UI.Refresh(); f:Hide()
    end))

    f:Show()
end

-- Cria (ou reutiliza) uma linha visual.
local function acquireRow(i)
    if rows[i] then return rows[i] end

    -- Linhas sao "slots" fixos SOBRE a area do scroll, mas filhas do FRAME principal
    -- (nao do FauxScrollFrame) -- senao o scroll interno do ScrollFrame as desloca
    -- para fora da vista (linha "shown" mas invisivel). Ancoradas ao scroll.
    local r = CreateFrame("Button", nil, frame, "BackdropTemplate")
    r:SetFrameLevel(scroll:GetFrameLevel() + 2)
    r:SetHeight(ROW_HEIGHT)
    r:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, -(i - 1) * ROW_STEP)
    r:SetPoint("TOPRIGHT", scroll, "TOPRIGHT", 0, -(i - 1) * ROW_STEP)
    r:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    r:SetBackdropColor(1, 1, 1, (i % 2 == 0) and 0.04 or 0.07)

    r.icon = r:CreateTexture(nil, "ARTWORK")
    r.icon:SetSize(60, 60)
    r.icon:SetPoint("LEFT", 8, 0)
    r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Borda brilhante pulsante: sinaliza montaria obtenivel AGORA.
    r.glow = CreateFrame("Frame", nil, r, "BackdropTemplate")
    r.glow:SetPoint("TOPLEFT", 1, -1)
    r.glow:SetPoint("BOTTOMRIGHT", -1, 1)
    r.glow:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 2 })
    r.glow:SetBackdropBorderColor(0.30, 1.0, 0.45, 1)
    r.glow:SetFrameLevel(r:GetFrameLevel() + 6)
    local ag = r.glow:CreateAnimationGroup()
    ag:SetLooping("BOUNCE")
    local a = ag:CreateAnimation("Alpha")
    a:SetFromAlpha(1.0); a:SetToAlpha(0.15); a:SetDuration(0.9); a:SetSmoothing("IN_OUT")
    r.glow.ag = ag
    r.glow:Hide()

    -- A row inteira e clicavel -> abre o painel de detalhes (com os botoes de acao).
    -- Realce ao passar o mouse + uma seta sutil indicando que da pra clicar.
    local hl = r:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.09)

    r.chevron = r:CreateFontString(nil, "OVERLAY", "GameFontDisableLarge")
    r.chevron:SetPoint("RIGHT", r, "RIGHT", -10, 0)
    r.chevron:SetText("\226\128\186")   -- "›"

    -- Texto: 4 linhas, ancoradas ao TOPO da row (nao ao icone) p/ usar toda a altura.
    -- L1: nome + badge.  L2: origem.  L3: zona/xpac + custo.  L4: status/progresso.
    r.name = r:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    r.name:SetPoint("TOPLEFT", r, "TOPLEFT", 76, -6)
    r.name:SetJustifyH("LEFT")
    r.name:SetWordWrap(false)

    r.badge = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    r.badge:SetPoint("TOPRIGHT", r, "TOPRIGHT", -22, -6)
    r.badge:SetJustifyH("RIGHT")
    r.name:SetPoint("RIGHT", r.badge, "LEFT", -6, 0)

    r.vendors = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    r.vendors:SetPoint("TOPLEFT", r.name, "BOTTOMLEFT", 0, -3)
    r.vendors:SetPoint("RIGHT", r, "RIGHT", -22, 0)
    r.vendors:SetJustifyH("LEFT")
    r.vendors:SetWordWrap(false)

    r.zonecost = r:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    r.zonecost:SetPoint("TOPLEFT", r.vendors, "BOTTOMLEFT", 0, -3)
    r.zonecost:SetPoint("RIGHT", r, "RIGHT", -22, 0)
    r.zonecost:SetJustifyH("LEFT")
    r.zonecost:SetWordWrap(false)

    -- Linha 4: situacao atual (qual requisito falta + progresso, custo, etc.).
    r.detail = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    r.detail:SetPoint("TOPLEFT", r.zonecost, "BOTTOMLEFT", 0, -3)
    r.detail:SetPoint("RIGHT", r, "RIGHT", -22, 0)
    r.detail:SetJustifyH("LEFT")
    r.detail:SetWordWrap(false)

    rows[i] = r
    return r
end

local function refreshRow(r, item)
    r.icon:SetTexture(item.icon or 134400)
    r.icon:SetDesaturated(not item.owned)  -- obtida = colorido; faltante = cinza

    r.name:SetText(item.name or "?")
    r.name:SetTextColor(item.owned and 1 or 0.95, item.owned and 1 or 0.95, item.owned and 1 or 0.95)

    local c = ns.STATUS_COLOR[item.status] or { 1, 1, 1 }
    local badgeText = (item.status == ns.STATUS.MISSING and item.category)
        or ns.STATUS_LABEL[item.status] or item.status
    r.badge:SetText(badgeText)
    r.badge:SetTextColor(c[1], c[2], c[3])

    r.vendors:SetText(vendorsText(item))
    r.zonecost:SetText(zoneCostText(item))
    r.detail:SetText(statusDetailText(item))

    -- Glow de "obtenivel agora".
    if item.readyNow then
        r.glow:Show()
        if not r.glow.ag:IsPlaying() then r.glow.ag:Play() end
    else
        r.glow.ag:Stop()
        r.glow:Hide()
    end

    -- Clicar na row abre o painel de detalhes (modelo 3D + todas as acoes).
    r:SetScript("OnClick", ns.Safe.Wrap("open mount detail", function()
        UI.ShowDetail(item)
    end))

    r:Show()
end

-- Constroi a janela (lazy, na primeira abertura).
local function buildFrame()
    frame = CreateFrame("Frame", "MountTrackerFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(560, 596)   -- +linha de filtro (Category); mantem a area da lista
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("HIGH")
    tinsert(UISpecialFrames, "MountTrackerFrame") -- fecha com ESC

    -- O painel de detalhes e uma extensao do roadmap: fecha junto (e nao reaparece
    -- "stale" ao reabrir). Por ser filho do frame ele ja some visualmente; aqui
    -- garantimos o estado Hidden.
    frame:HookScript("OnHide", function()
        if detailFrame then detailFrame:Hide() end
    end)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", 0, -5)
    frame.title:SetText("MountTracker  -  mount roadmap")

    -- Dropdown: filtro por expansao.
    local ddLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ddLabel:SetPoint("TOPLEFT", 14, -28)
    ddLabel:SetText("Expansion:")

    local dd = CreateFrame("Frame", "MountTrackerExpDropdown", frame, "UIDropDownMenuTemplate")
    dd:SetPoint("LEFT", ddLabel, "RIGHT", -6, -2)
    UIDropDownMenu_SetWidth(dd, 110)
    UIDropDownMenu_Initialize(dd, function(_, level)
        local function add(label, value)
            local info = UIDropDownMenu_CreateInfo()
            info.text, info.value = label, value
            info.checked = (ns.DB.Settings().expansionFilter or "All") == value
            info.func = ns.Safe.Wrap("apply expansion filter", function()
                ns.DB.Settings().expansionFilter = value
                UIDropDownMenu_SetText(dd, label)
                UI.RefreshTop()
            end)
            UIDropDownMenu_AddButton(info)
        end
        add("All expansions", "All")
        for _, e in ipairs(ns.EXPANSIONS) do add(e, e) end
    end)
    frame.ddExp = dd

    -- Dropdown: filtro por zona (All / zona atual do personagem).
    local zdLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    zdLabel:SetPoint("TOPLEFT", 250, -28)
    zdLabel:SetText("Zone:")

    local zd = CreateFrame("Frame", "MountTrackerZoneDropdown", frame, "UIDropDownMenuTemplate")
    zd:SetPoint("LEFT", zdLabel, "RIGHT", -6, -2)
    UIDropDownMenu_SetWidth(zd, 150)
    UIDropDownMenu_Initialize(zd, function(_, level)
        local function add(label, value)
            local info = UIDropDownMenu_CreateInfo()
            info.text, info.value = label, value
            info.checked = (ns.DB.Settings().zoneFilter or "All") == value
            info.func = ns.Safe.Wrap("apply zone filter", function()
                ns.DB.Settings().zoneFilter = value
                UI.RefreshTop()
            end)
            UIDropDownMenu_AddButton(info)
        end
        add("All zones", "All")
        add("Current zone", "Current")
    end)
    frame.ddZone = zd

    -- Dropdown: filtro por categoria (Vendor / Reputation / Drop / Achievement / ...).
    local cdLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cdLabel:SetPoint("TOPLEFT", 14, -54)
    cdLabel:SetText("Category:")

    local cdd = CreateFrame("Frame", "MountTrackerCatDropdown", frame, "UIDropDownMenuTemplate")
    cdd:SetPoint("LEFT", cdLabel, "RIGHT", -6, -2)
    UIDropDownMenu_SetWidth(cdd, 150)
    UIDropDownMenu_Initialize(cdd, function(_, level)
        local function add(label, value)
            local info = UIDropDownMenu_CreateInfo()
            info.text, info.value = label, value
            info.checked = (ns.DB.Settings().categoryFilter or "All") == value
            info.func = ns.Safe.Wrap("apply category filter", function()
                ns.DB.Settings().categoryFilter = value
                UIDropDownMenu_SetText(cdd, label)
                UI.RefreshTop()
            end)
            UIDropDownMenu_AddButton(info)
        end
        add("All categories", "All")
        for _, c in ipairs(ns.Logic.Roadmap.Categories()) do add(c, c) end
    end)
    frame.ddCat = cdd

    -- Checkbox: mostrar indisponiveis / ocultas.
    local cb = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 16, -82)
    local cbLabel = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cbLabel:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    cbLabel:SetText("Show unavailable / hidden")
    cb:SetScript("OnClick", ns.Safe.Wrap("apply filter", function(self)
        local s = ns.DB.Settings()
        s.showWrongFaction = self:GetChecked()
        s.showHidden = self:GetChecked()
        UI.RefreshTop()
    end))
    frame.cbWrong = cb

    -- Checkbox: mostrar montarias ja obtidas (aparecem coloridas; as faltantes, cinza).
    local cb2 = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    cb2:SetPoint("TOPLEFT", 320, -82)
    local cb2Label = cb2:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cb2Label:SetPoint("LEFT", cb2, "RIGHT", 2, 0)
    cb2Label:SetText("Show owned")
    cb2:SetScript("OnClick", ns.Safe.Wrap("apply filter", function(self)
        ns.DB.Settings().showOwned = self:GetChecked()
        UI.RefreshTop()
    end))
    frame.cbOwned = cb2

    -- Scroll virtualizado (FauxScrollFrame): renderiza so as linhas visiveis e
    -- recicla ao rolar -> aguenta milhares de itens (inclui as owned) sem travar.
    scroll = CreateFrame("ScrollFrame", "MountTrackerScrollFrame", frame, "FauxScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -110)
    scroll:SetPoint("BOTTOMRIGHT", -30, 10)
    scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ROW_STEP, UI.Refresh)
    end)
    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local bar = _G[self:GetName() .. "ScrollBar"]
        if bar then bar:SetValue(bar:GetValue() - delta * 3 * ROW_STEP) end
    end)

    frame.empty = frame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    frame.empty:SetPoint("TOPLEFT", scroll, "TOPLEFT", 6, -16)
    frame.empty:SetWidth(480)
    frame.empty:SetJustifyH("LEFT")
    frame.empty:SetText("Nothing in roadmap. Type /mtrack scan or adjust filters.")

    -- CreateFrame devolve o frame ja visivel; escondemos para o primeiro Toggle abrir.
    frame:Hide()
end

function UI.Refresh()
    if not frame then return end
    local items = ns.Logic.Roadmap.Filtered()
    local numVisible = math.max(1, math.floor(scroll:GetHeight() / ROW_STEP))

    FauxScrollFrame_Update(scroll, #items, numVisible, ROW_STEP)
    -- Clampa o offset: ao encolher a lista (ex.: aplicar filtro de zona), a barra
    -- pode ter ficado "rolada" alem do fim -> renderizaria itens nil (tela em branco).
    local maxOffset = math.max(0, #items - numVisible)
    local offset = math.min(FauxScrollFrame_GetOffset(scroll), maxOffset)

    for i = 1, numVisible do
        local item = items[offset + i]
        local r = acquireRow(i)
        if item then refreshRow(r, item) else r:Hide() end
    end
    for i = numVisible + 1, #rows do rows[i]:Hide() end  -- janela encolheu

    frame.title:SetText(("MountTracker  -  mount roadmap  (%d)"):format(#items))

    if #items == 0 then
        if (ns.DB.Settings().zoneFilter or "All") == "Current" then
            frame.empty:SetText(("No missing mounts from your current zone\n(%s).\n\nMove to a zone with mounts, or set Zone to \"All zones\".")
                :format(GetRealZoneText() or GetZoneText() or "?"))
        else
            local s = ns._stats or {}
            frame.empty:SetText(("Nothing to show with current filters.\n\n%d owned  |  %d obtainable  |  %d unavailable\n\nThe %d unavailable are hidden by the game for this\ncharacter (other faction / class / legacy).\nTick \"Show unavailable / hidden\" to reveal them.")
                :format(s.owned or 0, s.pending or 0, s.unavailable or 0, s.unavailable or 0))
        end
        frame.empty:Show()
    else
        frame.empty:Hide()
    end
    frame.cbWrong:SetChecked(ns.DB.Settings().showWrongFaction)
    frame.cbOwned:SetChecked(ns.DB.Settings().showOwned)
    local ef = ns.DB.Settings().expansionFilter or "All"
    UIDropDownMenu_SetText(frame.ddExp, ef == "All" and "All expansions" or ef)
    local cf = ns.DB.Settings().categoryFilter or "All"
    if frame.ddCat then UIDropDownMenu_SetText(frame.ddCat, cf == "All" and "All categories" or cf) end
    if (ns.DB.Settings().zoneFilter or "All") == "Current" then
        -- Mostra o nome da zona atual direto (o label "Zone:" ja contextualiza).
        local z = GetRealZoneText() or GetZoneText() or "current"
        UIDropDownMenu_SetText(frame.ddZone, z)
    else
        UIDropDownMenu_SetText(frame.ddZone, "All zones")
    end
end

-- Volta a lista ao topo e re-renderiza (usado quando um filtro muda).
function UI.RefreshTop()
    if scroll then
        local bar = _G[scroll:GetName() .. "ScrollBar"]
        if bar then bar:SetValue(0) end
    end
    UI.Refresh()
end

function UI.Toggle()
    if not frame then buildFrame() end
    if frame:IsShown() then
        frame:Hide()
    else
        ns.Logic.Roadmap.Build()
        UI.Refresh()
        frame:Show()
    end
end
