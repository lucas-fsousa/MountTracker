-- UI/EditFrame.lua
-- Janela de edicao de curadoria (so aparece com `/mtrack enable edit`). Le/grava o
-- overlay MountTrackerEdits (por spellID) e re-scaneia ao salvar, refletindo na hora.
-- Toda a logica de edicao vive aqui para nao inchar UI/MainFrame.lua.

local ADDON, ns = ...
ns.UI = ns.UI or {}
local UI = ns.UI

-- Listas fixas (viram dropdowns).
local ACQUISITIONS = { "vendor", "reputation", "drop", "world", "rare", "achievement" }
local COST_TYPES   = { "none", "gold", "currency", "item" }
local REQ_TYPES    = { "none", "reputation", "renown", "achievement" }
local STANDINGS    = { "Neutral", "Friendly", "Honored", "Revered", "Exalted" }

-- Expansoes do projeto (sem "Unknown" como opcao de gravacao).
local function expansionOptions()
    local out = {}
    for _, e in ipairs(ns.EXPANSIONS or {}) do
        if e ~= "Unknown" then out[#out + 1] = e end
    end
    return out
end

-- ------------------------------------------------------------------ resolvers de nome
local function currencyName(id)
    id = tonumber(id)
    if not id then return nil end
    local info = C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo and C_CurrencyInfo.GetCurrencyInfo(id)
    return info and info.name
end
local function itemName(id)
    id = tonumber(id)
    if not id then return nil end
    return (C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(id))
        or (GetItemInfo and GetItemInfo(id))
end
local function factionName(id)
    id = tonumber(id)
    if not id then return nil end
    if C_Reputation and C_Reputation.GetFactionDataByID then
        local d = C_Reputation.GetFactionDataByID(id)
        if d and d.name then return d.name end
    end
    if C_MajorFactions and C_MajorFactions.GetMajorFactionData then
        local m = C_MajorFactions.GetMajorFactionData(id)
        if m and m.name then return m.name end
    end
    return nil
end
local function achievementName(id)
    id = tonumber(id)
    if not id then return nil end
    return select(2, GetAchievementInfo(id))
end

-- ------------------------------------------------------------- indice de currencies
local currencyIndex
local function buildCurrencyIndex()
    if currencyIndex then return currencyIndex end
    local seen, list = {}, {}
    local function add(id, nm)
        id = tonumber(id)
        if not id or seen[id] then return end
        nm = nm or currencyName(id)
        if nm and nm ~= "" then seen[id] = true; list[#list + 1] = { id = id, name = nm } end
    end
    -- 1) currencies ja usadas nos dados curados
    for _, e in ipairs(ns.Data.All or {}) do
        if e.cost and e.cost.currencyID then add(e.cost.currencyID) end
    end
    -- 2) currencies conhecidas pelo personagem (best-effort; varia entre clientes)
    if C_CurrencyInfo and C_CurrencyInfo.GetCurrencyListSize then
        local n = C_CurrencyInfo.GetCurrencyListSize() or 0
        for i = 1, n do
            ns.Safe.Call("scan currency list", function()
                local li = C_CurrencyInfo.GetCurrencyListInfo(i)
                if li and not li.isHeader then
                    local link = C_CurrencyInfo.GetCurrencyListLink and C_CurrencyInfo.GetCurrencyListLink(i)
                    local id = link and tonumber(link:match("currency:(%d+)"))
                    if id then add(id, li.name) end
                end
            end)
        end
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    currencyIndex = list
    return list
end

-- ---------------------------------------------------------------- helpers de widget
local function label(parent, text, x, y)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT", x, y)
    fs:SetText(text)
    return fs
end

local function makeEdit(parent, w, numeric)
    local e = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    e:SetSize(w, 20)
    e:SetAutoFocus(false)
    e:SetFontObject("GameFontHighlightSmall")
    if numeric then e:SetNumeric(false) end  -- aceitamos "31.6"; validamos no collect
    e:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    e:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    return e
end

-- Dropdown simples de opcoes fixas. onSelect(value) chamado ao escolher.
local function makeDropdown(parent, name, w, options, onSelect)
    local dd = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dd.options = options
    dd.onSelect = onSelect
    UIDropDownMenu_SetWidth(dd, w)
    UIDropDownMenu_Initialize(dd, function(_, level)
        for _, opt in ipairs(dd.options) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = opt
            info.checked = (dd.value == opt)
            info.func = ns.Safe.Wrap("pick option", function()
                dd.value = opt
                UIDropDownMenu_SetText(dd, opt)
                if dd.onSelect then dd.onSelect(opt) end
            end)
            UIDropDownMenu_AddButton(info)
        end
    end)
    function dd:SetValue(v)
        self.value = v
        UIDropDownMenu_SetText(self, v or "")
    end
    return dd
end

-- ----------------------------------------------------------- picker de currency (busca)
local picker
local function buildPicker()
    if picker then return picker end
    local p = CreateFrame("Frame", "MountTrackerCurrencyPicker", UIParent, "BasicFrameTemplateWithInset")
    p:SetSize(260, 280)
    p:SetFrameStrata("FULLSCREEN_DIALOG")
    p:EnableMouse(true)
    p:Hide()
    tinsert(UISpecialFrames, "MountTrackerCurrencyPicker")
    p.title = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    p.title:SetPoint("TOP", 0, -5); p.title:SetText("Pick currency")

    p.search = makeEdit(p, 220, false)
    p.search:SetPoint("TOPLEFT", 14, -28)

    p.rows = {}
    for i = 1, 10 do
        local b = CreateFrame("Button", nil, p)
        b:SetSize(220, 18)
        b:SetPoint("TOPLEFT", 14, -52 - (i - 1) * 20)
        b:SetNormalFontObject("GameFontHighlightSmall")
        b:SetHighlightFontObject("GameFontNormalSmall")
        b:SetText("")
        b:GetFontString():SetJustifyH("LEFT")
        b:GetFontString():SetPoint("LEFT")
        p.rows[i] = b
    end

    function p:Refresh()
        local q = (self.search:GetText() or ""):lower()
        local idq = tonumber(q)
        local list = buildCurrencyIndex()
        local matches = {}
        for _, c in ipairs(list) do
            if q == "" or c.name:lower():find(q, 1, true) or (idq and tostring(c.id):find(q, 1, true)) then
                matches[#matches + 1] = c
                if #matches >= 10 then break end
            end
        end
        -- ID digitado que nao esta no indice: resolve na hora.
        if #matches == 0 and idq then
            local nm = currencyName(idq)
            if nm then matches[1] = { id = idq, name = nm } end
        end
        for i, b in ipairs(self.rows) do
            local c = matches[i]
            if c then
                b:SetText(("%s  (|cff888888%d|r)"):format(c.name, c.id))
                b:SetScript("OnClick", ns.Safe.Wrap("choose currency", function()
                    if self.onPick then self.onPick(c.id, c.name) end
                    self:Hide()
                end))
                b:Show()
            else
                b:Hide()
            end
        end
    end
    p.search:SetScript("OnTextChanged", ns.Safe.Wrap("filter currency", function() p:Refresh() end))
    picker = p
    return p
end

local function openCurrencyPicker(anchor, onPick)
    local p = buildPicker()
    p.onPick = onPick
    p:ClearAllPoints()
    p:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
    p.search:SetText("")
    p:Refresh()
    p:Show()
    p.search:SetFocus()
end

-- ---------------------------------------------------------------- estado do formulario
-- Constroi o estado de edicao (formato de storage) a partir do item: usa a edicao
-- existente se houver; senao deriva da entry curada atual; senao vazio.
local function formStateFromItem(item)
    local edit = ns.DB.GetEdit(item.spellID)
    if edit then
        return CopyTable and CopyTable(edit) or edit
    end
    local e = item.entry
    local st = {
        acquisition = e and e.acquisition,
        vendor      = e and e.vendor,
        zone        = e and e.zone,
        map         = e and (e.map or (e.coords and e.coords.map)),
        expansion   = (e and e.expansion) or item.expansion,
        wowhead     = e and e.wowhead,
        availableOverride = e and e.availableOverride,
    }
    if e and e.coords and e.coords.x then st.coords = { x = e.coords.x, y = e.coords.y } end
    if e and e.cost then
        if e.cost.currencyID then st.cost = { type = "currency", id = e.cost.currencyID, amount = e.cost.amount }
        elseif e.cost.itemID  then st.cost = { type = "item",     id = e.cost.itemID,     amount = e.cost.amount }
        elseif e.cost.gold    then st.cost = { type = "gold",     amount = e.cost.gold } end
    end
    if e and e.requirement then
        local r = e.requirement
        st.requirement = {
            type = r.type, factionID = type(r.factionID) == "number" and r.factionID or nil,
            factionName = r.factionName, standing = r.standing,
            renownLevel = r.renownLevel, achievementID = r.achievementID,
        }
    end
    return st
end

-- ---------------------------------------------------------------------- a janela
local editFrame
local function buildEdit()
    local f = CreateFrame("Frame", "MountTrackerEditFrame", UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(420, 600)
    f:SetFrameStrata("DIALOG")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    tinsert(UISpecialFrames, "MountTrackerEditFrame")

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.title:SetPoint("TOP", 0, -5); f.title:SetText("Edit curation data")

    -- Layout em COLUNA UNICA: label a esquerda (LX), controle em CTLX, cursor Y desce
    -- uma linha por campo. Evita sobreposicao lateral dos dropdowns (que tem moldura larga).
    local LX, CTLX = 16, 130
    local y = -30
    local function fieldRow() local cy = y; y = y - 30; return cy end  -- topo da linha atual
    local function subRow()   local cy = y; y = y - 16; return cy end  -- sublinha (info/nome)
    local function lbl(text, ty) return label(f, text, LX, ty) end

    -- nome / spellID (read-only)
    f.head = label(f, "", LX, fieldRow()); f.head:SetFontObject("GameFontNormal")

    do local ty = fieldRow(); lbl("Acquisition", ty - 2)
        f.ddAcq = makeDropdown(f, "MountTrackerEdit_Acq", 150, ACQUISITIONS)
        f.ddAcq:SetPoint("TOPLEFT", CTLX - 18, ty + 2) end

    do local ty = fieldRow(); lbl("Expansion", ty - 2)
        f.ddExp = makeDropdown(f, "MountTrackerEdit_Exp", 150, expansionOptions())
        f.ddExp:SetPoint("TOPLEFT", CTLX - 18, ty + 2) end

    do local ty = fieldRow(); lbl("Vendor / source", ty - 2)
        f.eVendor = makeEdit(f, 250, false); f.eVendor:SetPoint("TOPLEFT", CTLX, ty - 2) end

    do local ty = fieldRow(); lbl("Zone", ty - 2)
        f.eZone = makeEdit(f, 250, false); f.eZone:SetPoint("TOPLEFT", CTLX, ty - 2) end
    f.zoneInfo = label(f, "", CTLX, subRow()); f.zoneInfo:SetFontObject("GameFontDisableSmall")

    do local ty = fieldRow(); lbl("uiMapID", ty - 2)
        f.eMap = makeEdit(f, 70, true); f.eMap:SetPoint("TOPLEFT", CTLX, ty - 2)
        f.btnMapFromZone = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        f.btnMapFromZone:SetSize(130, 20); f.btnMapFromZone:SetText("usar o da zona")
        f.btnMapFromZone:SetPoint("TOPLEFT", CTLX + 80, ty - 2) end

    do local ty = fieldRow(); lbl("Coords  x / y", ty - 2)
        f.eX = makeEdit(f, 60, true); f.eX:SetPoint("TOPLEFT", CTLX, ty - 2)
        f.eY = makeEdit(f, 60, true); f.eY:SetPoint("TOPLEFT", CTLX + 70, ty - 2) end

    -- custo: linha do tipo + linha de detalhe
    do local ty = fieldRow(); lbl("Cost", ty - 2)
        f.ddCost = makeDropdown(f, "MountTrackerEdit_Cost", 120, COST_TYPES)
        f.ddCost:SetPoint("TOPLEFT", CTLX - 18, ty + 2) end
    do local ty = fieldRow()
        f.costAmount = makeEdit(f, 70, true); f.costAmount:SetPoint("TOPLEFT", CTLX, ty - 2)
        f.costAmountLbl = label(f, "amount", CTLX, ty + 14)
        f.costId = makeEdit(f, 70, true); f.costId:SetPoint("TOPLEFT", CTLX + 90, ty - 2)
        f.costIdLbl = label(f, "id", CTLX + 90, ty + 14)
        f.btnCostPick = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        f.btnCostPick:SetSize(70, 20); f.btnCostPick:SetText("search")
        f.btnCostPick:SetPoint("TOPLEFT", CTLX + 170, ty - 2) end
    f.costName = label(f, "", CTLX, subRow()); f.costName:SetFontObject("GameFontGreenSmall")

    -- requisito: linha do tipo + linha de detalhe
    do local ty = fieldRow(); lbl("Requirement", ty - 2)
        f.ddReq = makeDropdown(f, "MountTrackerEdit_Req", 130, REQ_TYPES)
        f.ddReq:SetPoint("TOPLEFT", CTLX - 18, ty + 2) end
    do local ty = fieldRow()
        f.reqFactionLbl = label(f, "factionID / name", LX, ty - 2)
        f.reqFaction = makeEdit(f, 110, false); f.reqFaction:SetPoint("TOPLEFT", CTLX, ty - 2)
        f.ddStanding = makeDropdown(f, "MountTrackerEdit_Standing", 100, STANDINGS)
        f.ddStanding:SetPoint("TOPLEFT", CTLX + 110, ty + 2)
        f.reqRenown = makeEdit(f, 50, true); f.reqRenown:SetPoint("TOPLEFT", CTLX + 120, ty - 2)
        f.reqRenownLbl = label(f, "renownLvl", CTLX + 175, ty - 2) end
    f.reqName = label(f, "", CTLX, subRow()); f.reqName:SetFontObject("GameFontGreenSmall")

    do local ty = fieldRow()
        f.cbOverride = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
        f.cbOverride:SetSize(22, 22); f.cbOverride:SetPoint("TOPLEFT", LX, ty)
        f.cbOverrideLbl = label(f, "availableOverride (ignora 'hidden' do jogo)", LX + 26, ty - 4) end

    do local ty = fieldRow(); lbl("Wowhead", ty - 2)
        f.eWowhead = makeEdit(f, 250, false); f.eWowhead:SetPoint("TOPLEFT", CTLX, ty - 2) end

    -- botoes
    f.btnSave = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.btnSave:SetSize(110, 24); f.btnSave:SetText("Save"); f.btnSave:SetPoint("BOTTOMLEFT", 16, 14)
    f.btnRevert = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.btnRevert:SetSize(110, 24); f.btnRevert:SetText("Revert"); f.btnRevert:SetPoint("BOTTOM", 0, 14)
    f.btnCancel = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.btnCancel:SetSize(110, 24); f.btnCancel:SetText("Cancel"); f.btnCancel:SetPoint("BOTTOMRIGHT", -16, 14)

    editFrame = f
    return f
end

-- Mostra/esconde os controles de custo conforme o tipo.
local function syncCostRow(f)
    local t = f.ddCost.value or "none"
    local showAmount = (t == "gold" or t == "currency" or t == "item")
    local showId = (t == "currency" or t == "item")
    f.costAmount:SetShown(showAmount); f.costAmountLbl:SetShown(showAmount)
    f.costId:SetShown(showId); f.costIdLbl:SetShown(showId)
    f.btnCostPick:SetShown(t == "currency")
    if not showId then f.costName:SetText("") end
end

-- Mostra/esconde os controles de requisito conforme o tipo, e resolve o nome.
local function syncReqRow(f)
    local t = f.ddReq.value or "none"
    local on = (t ~= "none")
    f.reqFactionLbl:SetShown(on and t ~= "achievement")
    f.reqFaction:SetShown(on)
    f.ddStanding:SetShown(t == "reputation")
    f.reqRenown:SetShown(t == "renown"); f.reqRenownLbl:SetShown(t == "renown")
    if t == "achievement" then f.reqFactionLbl:Hide() end
    -- rotulo do campo
    if t == "achievement" then f.reqFaction:SetWidth(120) end
end

local function resolveIdLabels(f)
    -- custo
    local ct = f.ddCost.value
    local idtxt = f.costId:GetText()
    if ct == "currency" then f.costName:SetText(currencyName(idtxt) or "")
    elseif ct == "item" then f.costName:SetText(itemName(idtxt) or "")
    else f.costName:SetText("") end
    -- requisito
    local rt = f.ddReq.value
    local rtxt = f.reqFaction:GetText()
    if rt == "achievement" then f.reqName:SetText(achievementName(rtxt) or "")
    elseif rt == "reputation" or rt == "renown" then
        f.reqName:SetText((tonumber(rtxt) and factionName(rtxt)) or "")
    else f.reqName:SetText("") end
    -- zona -> uiMapID
    local z = f.eZone:GetText()
    local mid = z and z ~= "" and ns.Waypoint and ns.Waypoint.MapForZone(z)
    if z == "" then f.zoneInfo:SetText("")
    elseif mid then f.zoneInfo:SetText("uiMapID " .. mid .. " (ok)"); f.zoneInfo:SetTextColor(0.4, 1, 0.4)
    else f.zoneInfo:SetText("zona nao resolvida"); f.zoneInfo:SetTextColor(1, 0.4, 0.4) end
end

-- Le os controles e devolve a tabela de storage limpa (vazios -> nil).
local function collectForm(f)
    local function s(e) local v = (e:GetText() or ""):gsub("^%s+", ""):gsub("%s+$", ""); return v ~= "" and v or nil end
    local function n(e) return tonumber(s(e) or "") end
    local st = {
        acquisition = f.ddAcq.value,
        vendor      = s(f.eVendor),
        zone        = s(f.eZone),
        map         = n(f.eMap),
        expansion   = f.ddExp.value,
        wowhead     = s(f.eWowhead),
        availableOverride = f.cbOverride:GetChecked() or nil,
    }
    local cx, cy = n(f.eX), n(f.eY)
    if cx and cy then st.coords = { x = cx, y = cy } end

    local ct = f.ddCost.value
    if ct == "gold" then st.cost = { type = "gold", amount = n(f.costAmount) }
    elseif ct == "currency" then st.cost = { type = "currency", id = n(f.costId), amount = n(f.costAmount) }
    elseif ct == "item" then st.cost = { type = "item", id = n(f.costId), amount = n(f.costAmount) }
    else st.cost = false end  -- "none": remove custo na base

    local rt = f.ddReq.value
    if rt == "reputation" then
        st.requirement = { type = "reputation", factionID = n(f.reqFaction), standing = f.ddStanding.value }
    elseif rt == "renown" then
        local fid = n(f.reqFaction)
        st.requirement = { type = "renown", renownLevel = n(f.reqRenown) }
        if fid then st.requirement.factionID = fid else st.requirement.factionName = s(f.reqFaction) end
    elseif rt == "achievement" then
        st.requirement = { type = "achievement", achievementID = n(f.reqFaction) }
    else st.requirement = false end  -- "none": remove requisito na base
    return st
end

function UI.ShowEdit(item)
    if not item or not item.spellID then
        ns.Print("This mount has no spellID; cannot edit.")
        return
    end
    local f = editFrame or buildEdit()
    f._item = item

    f:ClearAllPoints()
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

    f.head:SetText(("%s  |cff888888(spell %d)|r"):format(item.name or "?", item.spellID))

    local st = formStateFromItem(item)
    f.ddAcq:SetValue(st.acquisition or "vendor")
    f.ddExp:SetValue(st.expansion or "Unknown")
    f.eVendor:SetText(st.vendor or "")
    f.eZone:SetText(st.zone or "")
    f.eMap:SetText(st.map and tostring(st.map) or "")
    f.eX:SetText(st.coords and st.coords.x and tostring(st.coords.x) or "")
    f.eY:SetText(st.coords and st.coords.y and tostring(st.coords.y) or "")
    f.eWowhead:SetText(st.wowhead or "")
    f.cbOverride:SetChecked(st.availableOverride and true or false)

    local c = (type(st.cost) == "table" and st.cost) or nil
    f.ddCost:SetValue(c and c.type or "none")
    f.costAmount:SetText(c and c.amount and tostring(c.amount) or "")
    f.costId:SetText(c and c.id and tostring(c.id) or "")

    local r = (type(st.requirement) == "table" and st.requirement) or nil
    f.ddReq:SetValue(r and r.type or "none")
    f.reqFaction:SetText(r and (r.factionID and tostring(r.factionID) or r.factionName or
        (r.achievementID and tostring(r.achievementID))) or "")
    f.ddStanding:SetValue(r and r.standing or "Exalted")
    f.reqRenown:SetText(r and r.renownLevel and tostring(r.renownLevel) or "")

    syncCostRow(f); syncReqRow(f); resolveIdLabels(f)

    -- handlers (re-ligados a cada Show p/ capturar o item atual)
    f.ddCost.onSelect = function() syncCostRow(f); resolveIdLabels(f) end
    f.ddReq.onSelect  = function() syncReqRow(f); resolveIdLabels(f) end
    f.costId:SetScript("OnTextChanged", ns.Safe.Wrap("resolve cost id", function() resolveIdLabels(f) end))
    f.reqFaction:SetScript("OnTextChanged", ns.Safe.Wrap("resolve req id", function() resolveIdLabels(f) end))
    f.eZone:SetScript("OnTextChanged", ns.Safe.Wrap("resolve zone", function() resolveIdLabels(f) end))

    f.btnCostPick:SetScript("OnClick", ns.Safe.Wrap("open currency picker", function()
        openCurrencyPicker(f.costId, function(id)
            f.costId:SetText(tostring(id)); resolveIdLabels(f)
        end)
    end))
    f.btnMapFromZone:SetScript("OnClick", ns.Safe.Wrap("map from zone", function()
        local mid = ns.Waypoint and ns.Waypoint.MapForZone(f.eZone:GetText() or "")
        if mid then f.eMap:SetText(tostring(mid)) end
    end))

    f.btnSave:SetScript("OnClick", ns.Safe.Wrap("save edit", function()
        ns.DB.SetEdit(item.spellID, collectForm(f))
        ns.Logic.Roadmap.Build(); if ns.UI.Refresh then ns.UI.Refresh() end
        ns.Print(("saved edit for %s."):format(item.name or ("spell " .. item.spellID)))
        f:Hide()
    end))
    f.btnRevert:SetScript("OnClick", ns.Safe.Wrap("revert edit", function()
        ns.DB.RevertEdit(item.spellID)
        ns.Logic.Roadmap.Build(); if ns.UI.Refresh then ns.UI.Refresh() end
        ns.Print(("reverted edit for %s."):format(item.name or ("spell " .. item.spellID)))
        f:Hide()
    end))
    f.btnCancel:SetScript("OnClick", function() f:Hide() end)

    f:Show()
end
