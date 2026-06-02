-- UI/MainFrame.lua
-- Janela principal: lista rolavel com badge de status, detalhe e acoes por linha.

local ADDON, ns = ...

local UI = ns.UI
local ROW_HEIGHT = 56
local frame, scroll, content
local rows = {}

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

-- Cria (ou reutiliza) uma linha visual.
local function acquireRow(i)
    if rows[i] then return rows[i] end

    local r = CreateFrame("Button", nil, content, "BackdropTemplate")
    r:SetSize(1, ROW_HEIGHT)
    r:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    r:SetBackdropColor(1, 1, 1, (i % 2 == 0) and 0.04 or 0.07)

    r.icon = r:CreateTexture(nil, "ARTWORK")
    r.icon:SetSize(40, 40)
    r.icon:SetPoint("LEFT", 6, 0)
    r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Acoes: tres botoes numa unica fileira no topo direito.
    local function smallBtn(text, w)
        local b = CreateFrame("Button", nil, r, "UIPanelButtonTemplate")
        b:SetSize(w, 18)
        b:SetText(text)
        b:GetFontString():SetWordWrap(false)
        return b
    end
    r.btnWowhead = smallBtn("Wowhead", 64)
    r.btnWowhead:SetPoint("TOPRIGHT", -6, -6)
    r.btnHide = smallBtn("Hide", 46)
    r.btnHide:SetPoint("TOPRIGHT", r.btnWowhead, "TOPLEFT", -4, 0)
    r.btnObtained = smallBtn("Owned", 54)
    r.btnObtained:SetPoint("TOPRIGHT", r.btnHide, "TOPLEFT", -4, 0)

    -- Texto. Linha 1: nome (truncado, sem invadir os botoes). Linha 2: badge + detalhe.
    -- Linha 3: vendedor/origem.
    r.name = r:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    r.name:SetPoint("TOPLEFT", r.icon, "TOPRIGHT", 8, -3)
    r.name:SetPoint("RIGHT", r.btnObtained, "LEFT", -8, 0)
    r.name:SetJustifyH("LEFT")
    r.name:SetWordWrap(false)

    r.badge = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    r.badge:SetPoint("TOPLEFT", r.name, "BOTTOMLEFT", 0, -3)
    r.badge:SetJustifyH("LEFT")

    r.detail = r:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    r.detail:SetPoint("LEFT", r.badge, "RIGHT", 8, 0)
    r.detail:SetPoint("RIGHT", r, "RIGHT", -10, 0)
    r.detail:SetJustifyH("LEFT")
    r.detail:SetWordWrap(false)

    r.where = r:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    r.where:SetPoint("TOPLEFT", r.badge, "BOTTOMLEFT", 0, -3)
    r.where:SetPoint("RIGHT", r, "RIGHT", -10, 0)
    r.where:SetJustifyH("LEFT")
    r.where:SetWordWrap(false)

    rows[i] = r
    return r
end

local function refreshRow(r, item)
    r.icon:SetTexture(item.icon or 134400)
    r.name:SetText(item.name or "?")

    -- Convencao Blizzard: obtida = icone colorido; nao obtida = icone cinza.
    r.icon:SetDesaturated(not item.owned)
    if item.owned then
        r.name:SetTextColor(1, 1, 1)          -- branco
    else
        r.name:SetTextColor(0.6, 0.6, 0.6)    -- cinza
    end

    local c = ns.STATUS_COLOR[item.status] or { 1, 1, 1 }
    -- Nao-curadas mostram a categoria derivada do jogo; curadas mostram o status.
    local badgeText = (item.status == ns.STATUS.MISSING and item.category)
        or ns.STATUS_LABEL[item.status] or item.status
    r.badge:SetText(badgeText)
    r.badge:SetTextColor(c[1], c[2], c[3])

    r.detail:SetText(item.detail or "")
    if item.costHave then r.detail:SetText((item.detail or "") .. "  |cffaaaaaa(" .. item.costHave .. ")|r") end

    local e = item.entry
    local where = ""
    if e then
        if e.vendor then where = "Vendor: " .. e.vendor
        elseif e.source then where = "Source: " .. e.source end
        if e.zone then where = where .. (where ~= "" and "  -  " or "") .. e.zone end
    end
    r.where:SetText(where)

    r.btnWowhead:SetScript("OnClick", ns.Safe.Wrap("open Wowhead link", function()
        ShowWowhead(e and e.wowhead)
    end))
    r.btnWowhead:SetShown(e and e.wowhead ~= nil)

    r.btnHide:SetScript("OnClick", ns.Safe.Wrap("hide mount", function()
        ns.DB.SetHidden(item.mountID, not ns.DB.IsHidden(item.mountID))
        UI.Refresh()
    end))
    r.btnObtained:SetScript("OnClick", ns.Safe.Wrap("mark as owned", function()
        ns.DB.SetMarkedObtained(item.mountID, true)
        ns.Logic.Roadmap.Build()
        UI.Refresh()
    end))
    r.btnObtained:SetShown(not item.owned)  -- nao faz sentido "marcar obtida" o que ja e owned

    r:Show()
end

-- Constroi a janela (lazy, na primeira abertura).
local function buildFrame()
    frame = CreateFrame("Frame", "MountTrackerFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(560, 460)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetFrameStrata("HIGH")
    tinsert(UISpecialFrames, "MountTrackerFrame") -- fecha com ESC

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", 0, -5)
    frame.title:SetText("MountTracker  -  mount roadmap")

    -- Checkbox: mostrar faccao errada.
    local cb = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 12, -28)
    local cbLabel = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cbLabel:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    cbLabel:SetText("Show opposite faction / hidden")
    cb:SetScript("OnClick", ns.Safe.Wrap("apply filter", function(self)
        local s = ns.DB.Settings()
        s.showWrongFaction = self:GetChecked()
        s.showHidden = self:GetChecked()
        UI.Refresh()
    end))
    frame.cbWrong = cb

    -- Checkbox: mostrar montarias ja obtidas (aparecem coloridas; as faltantes, cinza).
    local cb2 = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    cb2:SetPoint("TOPLEFT", 320, -28)
    local cb2Label = cb2:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    cb2Label:SetPoint("LEFT", cb2, "RIGHT", 2, 0)
    cb2Label:SetText("Show owned")
    cb2:SetScript("OnClick", ns.Safe.Wrap("apply filter", function(self)
        ns.DB.Settings().showOwned = self:GetChecked()
        UI.Refresh()
    end))
    frame.cbOwned = cb2

    scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -56)
    scroll:SetPoint("BOTTOMRIGHT", -30, 10)

    content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)

    frame.empty = content:CreateFontString(nil, "OVERLAY", "GameFontDisable")
    frame.empty:SetPoint("TOP", 0, -20)
    frame.empty:SetText("Nothing in roadmap. Type /mtrack scan or adjust filters.")

    -- CreateFrame devolve o frame ja visivel; escondemos para o primeiro Toggle abrir.
    frame:Hide()
end

local MAX_ROWS = 200   -- limite de render (832 frames travariam); top-N ja e o que importa

function UI.Refresh()
    if not frame then return end
    local items = ns.Logic.Roadmap.Filtered()
    local width = scroll:GetWidth()
    content:SetWidth(width)

    for _, r in ipairs(rows) do r:Hide() end

    local shown = math.min(#items, MAX_ROWS)
    for i = 1, shown do
        local r = acquireRow(i)
        r:SetWidth(width)
        r:SetPoint("TOPLEFT", 0, -(i - 1) * (ROW_HEIGHT + 2))
        r:SetPoint("TOPRIGHT", 0, -(i - 1) * (ROW_HEIGHT + 2))
        refreshRow(r, items[i])
    end

    local extra = #items - shown
    frame.title:SetText(extra > 0
        and ("MountTracker  -  mount roadmap  (top %d of %d)"):format(shown, #items)
        or  "MountTracker  -  mount roadmap")

    content:SetHeight(math.max(1, shown * (ROW_HEIGHT + 2)))
    if #items == 0 then
        local s = ns._stats or {}
        frame.empty:SetText(("Nothing to show.\n\n%d curated  |  %d owned  |  %d pending  |  %d unresolved\n\nIf everything is owned, that's expected.\nType /mtrack scan for details, or expand the curated list.")
            :format(s.curated or 0, s.owned or 0, s.pending or 0, s.unresolved or 0))
        frame.empty:Show()
    else
        frame.empty:Hide()
    end
    frame.cbWrong:SetChecked(ns.DB.Settings().showWrongFaction)
    frame.cbOwned:SetChecked(ns.DB.Settings().showOwned)
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
