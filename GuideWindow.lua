local addonName, addon = ...

local RXPGuides = addon.RXPGuides
local _, class = UnitClass("player")
local _G = _G
local fmt, tinsert = string.format, table.insert

-- 3.3.5: LibUIDropDownMenu может отсутствовать
local LibDD
if LibStub then
    local success, lib = pcall(LibStub, "LibUIDropDownMenu-4.0", true)
    if success then LibDD = lib end
end

local L = addon.locale.Get

-- ============================================================
-- 3.3.5 BACKDROP FIX
-- В 3.3.5 SetBackdrop работает, но нужно правильно задавать параметры
-- ============================================================

function addon.SetResizeBounds(frame, width, height)
    if frame.SetResizeBounds then
        frame:SetResizeBounds(width, height)
    else
        frame:SetMinResize(width, height)
    end
end

addon.width, addon.height = 320, 135

-- ============================================================
-- MAIN FRAME
-- ============================================================

local RXPFrame = CreateFrame("Frame", "RXPFrame", UIParent)
addon.RXPFrame = RXPFrame
addon.enabledFrames["RXPFrame"] = RXPFrame

RXPFrame.IsFeatureEnabled = function()
    return not addon.settings.profile.hideGuideWindow, false
end

local BottomFrame = CreateFrame("Frame", "$parent_bottomFrame", RXPFrame)
local GuideName = CreateFrame("Frame", "$parentGuideName", RXPFrame)
local Footer = CreateFrame("Frame", "$parentFooter", RXPFrame)
local ScrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", BottomFrame, "UIPanelScrollFrameTemplate")
local CurrentStepFrame = CreateFrame("Frame", nil, RXPFrame)
local ScrollChild = CreateFrame("Frame", "$parent_steps", BottomFrame)
local MenuFrame = CreateFrame("Frame", "RXPG_MenuFrame", UIParent, "UIDropDownMenuTemplate")

RXPFrame.BottomFrame = BottomFrame
RXPFrame.GuideName = GuideName
RXPFrame.Footer = Footer
RXPFrame.CurrentStepFrame = CurrentStepFrame
RXPFrame.ScrollFrame = ScrollFrame
RXPFrame.ScrollChild = ScrollChild
RXPFrame.MenuFrame = MenuFrame

-- ============================================================
-- VISUALS & THEME - ОРИГИНАЛЬНЫЙ СТИЛЬ RXP
-- ============================================================

-- Цвета темы (классический RXP стиль)
addon.activeTheme = addon.activeTheme or {
    textColor = {0.9, 0.9, 0.95},        -- Белый/светло-серый заголовок
    textColorSecondary = {0.8, 0.8, 0.85}, -- Светло-серый текст шагов
    background = {0.1, 0.1, 0.12, 0.85},  -- Тёмно-серый, 85% непрозрачности
    border = {0.2, 0.2, 0.25, 0.9},      -- Тёмно-синяя рамка
    highlight = {0.3, 0.5, 0.8, 0.2},    -- Синяя подсветка
    stepActive = {0.2, 0.5, 0.8, 0.4},   -- Синий для активного шага
    stepComplete = {0.3, 0.3, 0.35, 0.3}, -- Тёмно-серый для выполненного
}

addon.colors = addon.activeTheme

-- Backdrop шаблоны для 3.3.5
local function CreateBackdrop(bgFile, edgeFile, tile, edgeSize, tileSize, insets)
    return {
        bgFile = bgFile or "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = edgeFile or "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = tile ~= false,
        edgeSize = edgeSize or 16,
        tileSize = tileSize or 16,
        insets = insets or {left = 4, right = 4, top = 4, bottom = 4}
    }
end

RXPFrame.backdrop = {}

RXPFrame.backdrop.main = CreateBackdrop(
    "Interface\\Tooltips\\UI-Tooltip-Background",
    "Interface\\Tooltips\\UI-Tooltip-Border",
    true, 16, 16, {left = 4, right = 4, top = 4, bottom = 4}
)

RXPFrame.backdrop.edge = CreateBackdrop(
    "Interface\\BUTTONS\\WHITE8X8",
    "Interface\\Tooltips\\UI-Tooltip-Border",
    true, 12, 12, {left = 3, right = 3, top = 3, bottom = 3}
)

RXPFrame.backdrop.guideName = CreateBackdrop(
    "Interface\\DialogFrame\\UI-DialogBox-Background",
    "Interface\\Tooltips\\UI-Tooltip-Border",
    true, 12, 12, {left = 3, right = 3, top = 3, bottom = 3}
)

RXPFrame.backdrop.bottom = CreateBackdrop(
    "Interface\\BUTTONS\\WHITE8X8",
    nil,
    true, 16, 16, {left = 0, right = 0, top = 0, bottom = 0}
)

function addon.ReloadStep()
    if addon.currentGuide then
        addon.SetStep(RXPCData.currentStep)
    end
end

function addon.RenderFrame(themeUpdate, isLoading)
    addon:LoadActiveTheme()
    addon.colors = addon.activeTheme

    for _, frame in pairs(addon.enabledFrames) do
        if frame.UpdateVisuals then
            frame:UpdateVisuals(true)
        end
    end
    if not themeUpdate then
        RXPFrame.GenerateMenuTable()
    end
    if addon.currentGuide and not isLoading then
        addon:ReloadGuide(true)
    end
end

function RXPFrame:UpdateVisuals()
    -- Применяем backdrop'ы ко всем фреймам
BottomFrame:SetBackdrop(nil) -- убираем рамку внутри
BottomFrame:SetBackdropColor(0,0,0,0)

    GuideName:SetBackdrop(RXPFrame.backdrop.guideName)
    GuideName:SetBackdropColor(unpack(addon.colors.background))
    GuideName:SetBackdropBorderColor(unpack(addon.colors.border))

    Footer:SetBackdrop(RXPFrame.backdrop.guideName)
    Footer:SetBackdropColor(unpack(addon.colors.background))
    Footer:SetBackdropBorderColor(unpack(addon.colors.border))

    GuideName.text:SetTextColor(unpack(addon.activeTheme.textColor))
    Footer.text:SetTextColor(0.5, 0.5, 0.55)
end

-- ============================================================
-- SETUP GUIDE WINDOW
-- ============================================================

function addon.SetupGuideWindow()
    -- Применяем backdrop'ы
    RXPFrame:SetBackdrop(RXPFrame.backdrop.main)
    RXPFrame:SetBackdropColor(unpack(addon.colors.background))
    RXPFrame:SetBackdropBorderColor(unpack(addon.colors.border))

    BottomFrame:SetBackdrop(RXPFrame.backdrop.edge)
    BottomFrame:SetBackdropColor(unpack(addon.colors.background))
    BottomFrame:SetBackdropBorderColor(unpack(addon.colors.border))

    GuideName:SetBackdrop(RXPFrame.backdrop.guideName)
    GuideName:SetBackdropColor(unpack(addon.colors.background))
    GuideName:SetBackdropBorderColor(unpack(addon.colors.border))

    GuideName.text:SetFont(addon.font, 12, "OUTLINE")
    GuideName.text:SetText(L("Welcome to RestedXP Guides\nRight click to pick a guide"))
    GuideName.text:SetTextColor(unpack(addon.activeTheme.textColor))

    Footer.text:SetFont(addon.font, 9, "")
    Footer.text:SetText(fmt("%s %s", addon.title, addon.release))
    Footer.text:SetTextColor(unpack(addon.activeTheme.textColorSecondary))

    Footer:SetBackdrop(RXPFrame.backdrop.guideName)
    Footer:SetBackdropColor(unpack(addon.colors.background))
    Footer:SetBackdropBorderColor(unpack(addon.colors.border))

    -- Иконки (если текстуры доступны)
    local iconPath = "Interface\\AddOns\\" .. addonName .. "\\Textures\\"
    pcall(function()
        GuideName.icon:SetTexture(iconPath .. "rxp_logo-64")
        GuideName.classIcon:SetTexture(iconPath .. class)
        Footer.cog:SetNormalTexture(iconPath .. "rxp_cog-32")
    end)
end

RXPFrame:SetScript("OnShow", addon.PLAYER_ENTERING_WORLD)
RXPFrame:SetScript("OnHide", addon.PLAYER_LEAVING_WORLD)
RXPFrame:Show()

RXPFrame:SetMovable(true)
RXPFrame:EnableMouse(true)
RXPFrame:SetClampedToScreen(true)
RXPFrame:SetResizable(true)
addon.SetResizeBounds(RXPFrame, 220, 100)

-- ============================================================
-- FRAME POSITIONING - КОРРЕКТНЫЕ ANCHOR'Ы
-- ============================================================

RXPFrame:SetWidth(addon.width)
RXPFrame:SetHeight(addon.height)
RXPFrame:SetPoint("LEFT", UIParent, "LEFT", 20, 35)
RXPFrame:SetFrameStrata("MEDIUM")
RXPFrame:SetFrameLevel(10)

-- GuideName - верхняя панель с названием гайда
GuideName:SetPoint("TOPLEFT", RXPFrame, "TOPLEFT", 8, -8)
GuideName:SetPoint("TOPRIGHT", RXPFrame, "TOPRIGHT", -8, -8)
GuideName:SetHeight(35)

-- BottomFrame - основная область контента
BottomFrame:SetPoint("TOPLEFT", GuideName, "BOTTOMLEFT", 0, -4)
BottomFrame:SetPoint("BOTTOMRIGHT", Footer, "TOPRIGHT", 0, 4)

-- Footer - нижняя панель
Footer:SetPoint("BOTTOMLEFT", RXPFrame, "BOTTOMLEFT", 8, 8)
Footer:SetPoint("BOTTOMRIGHT", RXPFrame, "BOTTOMRIGHT", -8, 8)
Footer:SetHeight(22)

-- CurrentStepFrame - область активных шагов (сверху или снизу)
-- CurrentStepFrame - область активных шагов (сверху)
CurrentStepFrame:SetPoint("BOTTOMLEFT", GuideName, "TOPLEFT", 0, 4)
CurrentStepFrame:SetPoint("BOTTOMRIGHT", GuideName, "TOPRIGHT", 0, 4)
CurrentStepFrame:SetHeight(0)
CurrentStepFrame:Hide()
CurrentStepFrame:EnableMouse(true)

-- ScrollFrame - скроллируемая область
ScrollFrame:SetPoint("TOPLEFT", BottomFrame, "TOPLEFT", 2, -2)
ScrollFrame:SetPoint("BOTTOMRIGHT", BottomFrame, "BOTTOMRIGHT", -8, 2)

-- 3.3.5: ScrollBar
local ScrollBar = _G[ScrollFrame:GetName() .. "ScrollBar"]
if not ScrollBar then
    ScrollBar = CreateFrame("Slider", "$parentScrollBar", ScrollFrame, "UIPanelScrollBarTemplate")
end
ScrollFrame.ScrollBar = ScrollBar

-- Убираем фон трека
local track = _G[ScrollBar:GetName() .. "Track"]
if track then track:SetAlpha(0) end

-- Ширина скроллбара
ScrollBar:SetWidth(16)

-- Ползунок (thumb) — тонкий, без текстуры
local thumb = ScrollBar:GetThumbTexture()
if thumb then
    thumb:SetTexture("Interface\\Buttons\\WHITE8X8")
    thumb:SetVertexColor(0.4, 0.4, 0.4, 0.8)
    thumb:SetWidth(4)
    thumb:SetHeight(30)
end

-- Стрелки вверх/вниз — кастомные текстуры
local texPath = "Interface\\AddOns\\RXPGuides\\Textures\\Scrollbar\\"

local upButton = _G[ScrollBar:GetName() .. "ScrollUpButton"]
if upButton then
    upButton:SetNormalTexture(texPath .. "Up-Normal")
    upButton:SetPushedTexture(texPath .. "Up-Pushed")
    upButton:SetHighlightTexture(texPath .. "Up-Highlight")
    upButton:SetDisabledTexture(texPath .. "Up-Disabled")
    upButton:SetAlpha(1)
    upButton:EnableMouse(true)
end

local downButton = _G[ScrollBar:GetName() .. "ScrollDownButton"]
if downButton then
    downButton:SetNormalTexture(texPath .. "Down-Normal")
    downButton:SetPushedTexture(texPath .. "Down-Pushed")
    downButton:SetHighlightTexture(texPath .. "Down-Highlight")
    downButton:SetDisabledTexture(texPath .. "Down-Disabled")
    downButton:SetAlpha(1)
    downButton:EnableMouse(true)
end

ScrollFrame:SetScrollChild(ScrollChild)
ScrollChild:SetWidth(RXPFrame:GetWidth() - 25)
ScrollChild:SetWidth(RXPFrame:GetWidth() - 25)

-- ============================================================
-- GUIDE NAME & FOOTER TEXT
-- ============================================================

GuideName.text = GuideName:CreateFontString(nil, "OVERLAY", "GameFontNormal")
GuideName.text:SetPoint("LEFT", GuideName, "LEFT", 36, 0)
GuideName.text:SetPoint("RIGHT", GuideName, "RIGHT", -8, 0)
GuideName.text:SetJustifyH("CENTER")
GuideName.text:SetJustifyV("MIDDLE")
GuideName:SetFrameLevel(12)

GuideName.bg = GuideName:CreateTexture("$parentBG", "BACKGROUND")
GuideName.bg:SetAllPoints()
GuideName.bg:SetTexture(0, 0, 0, 0)

GuideName.icon = GuideName:CreateTexture("RXPIcon", "ARTWORK")
GuideName.icon:SetPoint("LEFT", GuideName, "LEFT", 6, 0)
GuideName.icon:SetSize(28, 28)

GuideName.classIcon = GuideName:CreateTexture("RXPClassIcon", "OVERLAY")
GuideName.classIcon:SetPoint("LEFT", GuideName.icon, "RIGHT", 2, 0)
GuideName.classIcon:SetSize(20, 20)

Footer.text = Footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
Footer.text:SetPoint("LEFT", Footer, "LEFT", 8, 0)
Footer.text:SetPoint("RIGHT", Footer, "RIGHT", -28, 0)
Footer.text:SetJustifyH("LEFT")
Footer.text:SetJustifyV("MIDDLE")
Footer:SetFrameLevel(12)

Footer.bg = Footer:CreateTexture("$parentBG", "BACKGROUND")
Footer.bg:SetAllPoints()
Footer.bg:SetTexture(0, 0, 0, 0)

-- Кнопка ресайза
Footer.icon = CreateFrame("Button", "$parentResize", Footer)
Footer.icon:SetFrameLevel(Footer:GetFrameLevel() + 1)
Footer.icon:SetSize(14, 14)
Footer.icon:SetPoint("BOTTOMRIGHT", Footer, "BOTTOMRIGHT", -1, 1)
Footer.icon:SetNormalTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
Footer.icon:SetHighlightTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Highlight", "ADD")
Footer.icon:SetPushedTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Down")

-- Кнопка настроек (шестерёнка)
Footer.cog = CreateFrame("Button", "$parentCogwheel", RXPFrame)
Footer.cog:SetFrameLevel(GuideName:GetFrameLevel() + 1)
Footer.cog:SetSize(18, 18)
Footer.cog:SetPoint("RIGHT", Footer, "RIGHT", -4, 0)
Footer.cog:SetHighlightTexture("Interface\\MINIMAP\\UI-Minimap-ZoomButton-Highlight", "ADD")
Footer.cog:Show()

-- ============================================================
-- MOUSE HANDLING
-- ============================================================

local isResizing = false

RXPFrame.OnMouseDown = function(self, button, resize)
    if addon.settings.profile.lockFrames then return end
    if resize or (IsAltKeyDown() and not (addon.currentGuide and addon.currentGuide.hidewindow)) then
        RXPFrame:StartSizing("BOTTOMRIGHT")
        isResizing = true
    else
        RXPFrame:StartMoving()
    end
end

RXPFrame.OnMouseUp = function(self, button)
    RXPFrame:StopMovingOrSizing()
    if isResizing then
        addon.settings.profile.frameHeight = RXPFrame:GetHeight()
        if addon.currentGuide then
            addon.updateBottomFrame = true
        end
    end
    isResizing = false
    addon.settings:SaveFramePositions()
end

RXPFrame:SetScript("OnMouseDown", RXPFrame.OnMouseDown)
RXPFrame:SetScript("OnMouseUp", RXPFrame.OnMouseUp)

Footer.icon:SetScript("OnMouseDown", function(self, button)
    RXPFrame.OnMouseDown(self, button, true)
end)
Footer.icon:SetScript("OnMouseUp", RXPFrame.OnMouseUp)

GuideName.OnMouseDown = function(self, button)
    if button == "RightButton" then
        RXPFrame.DropDownMenu()
    else
        RXPFrame.OnMouseDown(self, button)
    end
end

GuideName.OnMouseUp = function(self, button)
    if button ~= "RightButton" then RXPFrame.OnMouseUp(self, button) end
end

GuideName:SetScript("OnMouseDown", GuideName.OnMouseDown)
Footer:SetScript("OnMouseDown", GuideName.OnMouseDown)
GuideName:SetScript("OnMouseUp", GuideName.OnMouseUp)
Footer:SetScript("OnMouseUp", GuideName.OnMouseUp)

-- ============================================================
-- DROPDOWN MENU
-- ============================================================

function RXPFrame.DropDownMenu()
    RXPFrame.GenerateMenuTable()
    if _G.EasyMenu then
        _G.EasyMenu(RXPFrame.menuList, MenuFrame, "cursor", 0, 0, "MENU")
    elseif LibDD then
        LibDD:EasyMenu(RXPFrame.menuList, MenuFrame, "cursor", 0, 0, "MENU")
    end
end

Footer.cog:SetScript("OnClick", function(self) RXPFrame.DropDownMenu() end)

-- ============================================================
-- EMPTY GUIDE
-- ============================================================

addon.emptyGuide = {
    empty = true,
    hidewindow = true,
    name = "",
    group = "",
    displayname = L("Welcome to RestedXP Guides\nRight click to pick a guide"),
    steps = {{hidewindow = true, text = ""}}
}

-- ============================================================
-- ACTIVE STEP FRAME
-- ============================================================

local activeSteps = {}
RXPFrame.activeSteps = activeSteps

local function IsFrameShown(frame, step)
    step = step or (frame and frame.step)
    if not step then return true
    elseif step.hidewindow or step.hidetip then return false
    elseif step.optional and (frame and frame.bottom) then return false
    end
    return true
end

function addon.ActiveStepElementOnEnter(frame)
    -- 3.3.5: IsForbidden не существует, используем pcall
    local ok1, forbidden1 = pcall(function() return frame:IsForbidden() end)
    local ok2, forbidden2 = pcall(function() return _G.GameTooltip:IsForbidden() end)
    if (ok1 and forbidden1) or (ok2 and forbidden2) then return end
    
    local element = frame.element or frame:GetParent().element
    if element and element.tooltip then
        _G.GameTooltip:SetOwner(frame, "ANCHOR_BOTTOM", 0, -10)
        _G.GameTooltip:ClearLines()
        _G.GameTooltip:AddLine(element.tooltip, 1, 1, 1)
        _G.GameTooltip:Show()
    end
end

function addon.ActiveStepElementOnLeave(frame)
    local ok1, forbidden1 = pcall(function() return frame:IsForbidden() end)
    local ok2, forbidden2 = pcall(function() return _G.GameTooltip:IsForbidden() end)
    if (ok1 and forbidden1) or (ok2 and forbidden2) then return end
    
    local element = frame.element or frame:GetParent().element
    if element and element.tooltip and _G.GameTooltip:GetOwner() == frame then
        _G.GameTooltip:Hide()
    end
end

function addon.ActiveStepElementPostClick(button)
    local element = button:GetParent().element
    if element and not element.optional then
        local skip = button:GetChecked()
        if element.OnComplete and skip and not element.skip then
            element.OnComplete(element)
        end
        element.skip = skip
    end
    addon.updateSteps = true
    addon.UpdateMap()
end

function addon.ActiveStepElementEventHandler(frame, event, ...)
    if addon.isHidden then return end
    if frame.callback and frame.step and frame.step.active then
        addon.Call(frame.element.tag, frame.callback, frame, event, ...)
    else
        frame.callback = nil
        frame:UnregisterEvent(event)
    end
end

function addon.BindActiveStepElement(frame, step, element, index)
    frame.step = step
    frame.element = element
    frame.index = index
    element.frame = frame
    if frame.button then frame.button:Enable() end

    if not element.tag then return end

    local events = element.event or addon.functions.events[element.tag]
    frame.callback = addon.functions[element.tag]
    addon.Call(element.tag, frame.callback, frame)

    local hasEvents, hasOnUpdate
    if type(events) == "string" then
        hasOnUpdate = events == "OnUpdate"
        hasEvents = not hasOnUpdate
        if hasEvents then frame:RegisterEvent(events) end
    elseif type(events) == "table" then
        for _, event in ipairs(events) do
            if event == "OnUpdate" then
                hasOnUpdate = true
            else
                frame:RegisterEvent(event)
                hasEvents = true
            end
        end
    end

    if hasOnUpdate then frame:SetScript("OnUpdate", frame.callback) end
    if hasEvents then frame:SetScript("OnEvent", addon.ActiveStepElementEventHandler) end
end

function addon.ReleaseActiveStepElement(frame)
    if frame.element and frame.element.frame == frame then
        frame.element.frame = nil
    end
    frame:UnregisterAllEvents()
    frame:SetScript("OnUpdate", nil)
    frame:SetScript("OnEvent", nil)
    frame.callback = nil
    frame.element = nil
    frame.step = nil
    frame.index = nil
end

-- ============================================================
-- STEP MANAGEMENT
-- ============================================================

function addon.SetStep(n, n2, loopback)
    if type(n) == "table" then n = n2 or 1 end
    if not n or type(n) ~= "number" then n = 1 end
    local guide = addon.currentGuide
    if not guide then return end

    -- FIX: Создаём таблицу labels если её нет
    if not guide.labels then
        guide.labels = {}
        for idx, st in ipairs(guide.steps or {}) do
            if st.label then
                guide.labels[st.label] = idx
            end
        end
    end

    addon.lastStepUpdate = GetTime()

    if n > #guide.steps then
        if guide.loop then
            if loopback then return
            else return addon.SetStep(1, nil, true) end
        end
        local isComplete = true
        for _, step in ipairs(activeSteps) do
            if step.sticky and not RXPCData.stepSkip[step.index] then
                isComplete = false
            end
        end
        if isComplete then
-- addon.functions.next может не существовать
if addon.functions and addon.functions.next then
    return addon.functions.next()
else
    -- Заглушка: просто переходим к следующему гайду или ничего не делаем
    return
end
        else
            n = #guide.steps
        end
    end

    RXPCData.currentStep = n
    RXPCData.currentStepId = guide.steps[n].stepId

    if not guide.steps[n].active then
        local step = guide.steps[n]
        for _, element in ipairs(step.elements or {}) do
            if element.OnStepActivation then
                element:OnStepActivation()
            end
        end
        addon:SendEvent("RXP_STEP_ACTIVATED", step, guide)
    end

    RXPCData.stepSkip[n + 1] = nil

    if guide.steps[n].sticky and n < #guide.steps then
        return addon.SetStep(n + 1)
    end

    local previousSteps = {}
    for _, step in ipairs(activeSteps) do
        step.active = nil
        tinsert(previousSteps, step)
    end

    table.wipe(activeSteps)
    table.wipe(addon.questAccept)
    table.wipe(addon.questTurnIn)
    table.wipe(addon.activeItems)
    table.wipe(addon.activeSpells)
    table.wipe(addon.activeMacros)

    local level = UnitLevel("player")
    local scrollHeight = 1

    for i = 1, n - 1 do
        local step = guide.steps[i]
        if step.sticky then
           local req = guide.labels and guide.labels[step.requires]
            if step.requires and req then
                local requiredSteps = {}
                req = guide.steps[req]
                  while req and req.requires and guide.labels and not RXPCData.stepSkip[req.index] and not req.active do
                    if requiredSteps[req] then
                        addon.comms.PrettyPrint('ERROR: Step requirement loop at steps %d and %d',
                            step.index or 0, req.index or 0)
                        break
                    end
                    requiredSteps[req] = true
                    req = guide.labels and guide.steps[guide.labels[req.requires]]
                end
            end
            step.reqFulfilled = not (req and (req.active or (req.sticky and not RXPCData.stepSkip[req.index])))
if not RXPCData.stepSkip[i] and step.reqFulfilled and level >= (step.level or 0) then                tinsert(activeSteps, step)
                if n > 1 then scrollHeight = n - 1 end
                step.active = true
            end
        end
    end

    local step = guide.steps[n]
    local req = step.requires and guide.labels and guide.labels[step.requires] and guide.steps[guide.labels[step.requires]]
    if step.completed and n < #guide.steps then
        return addon.SetStep(n + 1)
elseif step and not step.completed and
    not (req and #activeSteps > 0 and (req.active or not req.reqFulfilled)) and
    level >= (step.level or 0) then
        step.completed = false
        addon.settings.ReplaceColors(step)
        tinsert(activeSteps, step)
        if ScrollChild.framePool[n] then
            ScrollChild.framePool[n]:SetAlpha(1)
        end
        step.active = true
        scrollHeight = n
    end

    if #activeSteps == 0 then
        if n >= #guide.steps then
            if addon.functions and addon.functions.next then
                return addon.functions.next()
            else
                return
            end
        else
            return addon.SetStep(n + 1)
        end
    end

    for _, prevstep in pairs(previousSteps) do
        if not prevstep.active then
            addon:SendEvent("RXP_STEP_DEACTIVATED", prevstep, guide)
        end
    end

    CurrentStepFrame:SetHeight(0)
    CurrentStepFrame:Hide()

    local c = 0
    local anchor = 0
    local activeTargets = {}
    local stepUnitscan = {}
    local stepMobs = {}
    local stepTargets = {}

    for _, step in ipairs(activeSteps) do
        local index = step.index
        c = c + 1
        local stepframe = CurrentStepFrame.framePool[c]
        if not stepframe then
            CurrentStepFrame.framePool[c] = CreateFrame("Frame", "$parent_frame" .. c, CurrentStepFrame)
            stepframe = CurrentStepFrame.framePool[c]
            stepframe.elements = {}
        end

        stepframe:ClearAllPoints()
        if anchor < 1 then
            stepframe:SetPoint("TOPLEFT", CurrentStepFrame, 0, 0)
            stepframe:SetPoint("TOPRIGHT", CurrentStepFrame, 0, 0)
        else
            stepframe:SetPoint("TOPLEFT", CurrentStepFrame.framePool[anchor], "BOTTOMLEFT", 0, -5)
            stepframe:SetPoint("TOPRIGHT", CurrentStepFrame.framePool[anchor], "BOTTOMRIGHT", 0, -5)
        end

        anchor = c

        if not stepframe.number then
            stepframe.number = CreateFrame("Frame", "$parent_number", stepframe)
            stepframe.number:SetPoint("TOPLEFT", stepframe, 7, 5)
            stepframe.number.text = stepframe.number:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            stepframe.number.text:SetPoint("CENTER", stepframe.number, 2, 1)
            stepframe.number.text:SetJustifyH("CENTER")
            stepframe.number.text:SetJustifyV("MIDDLE")
            stepframe.number.text:SetTextColor(0.6, 0.8, 1)
            stepframe.number.text:SetFont(addon.font, addon.settings.profile.guideFontSize, "OUTLINE")
        end

        -- Применяем backdrop к шагу
        stepframe:SetBackdrop(RXPFrame.backdrop.edge)
        stepframe:SetBackdropColor(unpack(addon.colors.background))
        stepframe:SetBackdropBorderColor(unpack(addon.colors.border))

        stepframe.number:SetBackdrop(RXPFrame.backdrop.edge)
        stepframe.number:SetBackdropColor(unpack(addon.colors.background))
        stepframe.number:SetBackdropBorderColor(unpack(addon.colors.border))

        local titletext
        if step.sticky then
            titletext = step.title or ""
        else
titletext = step.title or (fmt(L("Step %d"), index or 1))
        end

        if titletext == "" then
            stepframe.number:SetAlpha(0)
            stepframe.number:SetSize(10, 17)
        else
            stepframe.number:SetAlpha(1)
            stepframe.number.text:SetText(titletext)
            stepframe.number:SetSize(stepframe.number.text:GetStringWidth() + 10, 17)
        end

        stepframe.step = step
        stepframe.index = index
        stepframe.sticky = step.sticky

        local e = 0
        local frameHeight = 0
        for j, element in ipairs(step.elements or {}) do
            e = j
            local elementFrame = stepframe.elements[e]
            if not stepframe.elements[e] then
                stepframe.elements[e] = CreateFrame("Frame", "$parent_" .. e, stepframe, nil)
                elementFrame = stepframe.elements[e]

                local button = CreateFrame("CheckButton", "$parentCheck", elementFrame, "ChatConfigCheckButtonTemplate")
                elementFrame.button = button
                button:SetSize(12, 12)
                button:SetScript("PostClick", addon.ActiveStepElementPostClick)
                button:SetPushedTexture("")
                button:SetHighlightTexture("Interface\\MINIMAP\\UI-Minimap-ZoomButton-Highlight", "ADD")

                elementFrame.text = getglobal(elementFrame.button:GetName() .. 'Text')
                elementFrame.text:SetParent(elementFrame)
                elementFrame.text:SetJustifyH("LEFT")
                elementFrame.text:SetJustifyV("MIDDLE")
                elementFrame.text:SetTextColor(unpack(addon.activeTheme.textColorSecondary))
                elementFrame.text:SetFont(addon.font, addon.settings.profile.guideFontSize + 2, "")

                elementFrame.icon = elementFrame:CreateFontString(nil, "OVERLAY")
                elementFrame.icon:SetFontObject(_G.GameFontNormalSmall)

if elementFrame.SetMouseMotionEnabled then
    elementFrame:SetMouseMotionEnabled(true)
end
                local ht = elementFrame:CreateTexture(nil, "HIGHLIGHT")
                ht:SetAllPoints(elementFrame.text)
                ht:SetTexture("Interface\\Worldmap\\UI-QuestPoi-HighlightBar")
                ht:SetBlendMode("ADD")
                ht:Hide()
                elementFrame.highlight = ht

                elementFrame:SetScript("OnEnter", addon.ActiveStepElementOnEnter)
                elementFrame:SetScript("OnLeave", addon.ActiveStepElementOnLeave)
                button:HookScript("OnEnter", addon.ActiveStepElementOnEnter)
                button:HookScript("OnLeave", addon.ActiveStepElementOnLeave)
            end

            elementFrame.button.theme = addon.activeTheme
            local btnPath = "Interface\\AddOns\\" .. addonName .. "\\Textures\\"
            pcall(function()
                elementFrame.button:SetNormalTexture(btnPath .. "rxp-btn-blank-32")
                elementFrame.button:SetCheckedTexture(btnPath .. "rxp-checked-32")
                elementFrame.button:SetDisabledCheckedTexture(btnPath .. "rxp-checked-32")
            end)

            addon.BindActiveStepElement(elementFrame, step, element, index)

            if element.unitscan then
                for _, t in ipairs(element.unitscan) do
                    if not activeTargets[t] then
                        activeTargets[t] = true
                        tinsert(stepUnitscan, addon.GetCreatureName(t))
                    end
                end
            end
            if element.mobs then
                for _, t in ipairs(element.mobs) do
                    if not activeTargets[t] then
                        activeTargets[t] = true
                        tinsert(stepMobs, addon.GetCreatureName(t))
                    end
                end
            end
            if element.targets then
                for _, t in ipairs(element.targets) do
                    if not activeTargets[t] then
                        activeTargets[t] = true
                        tinsert(stepTargets, addon.GetCreatureName(t))
                    end
                end
            end
        end

        for n = e + 1, #stepframe.elements do
            stepframe.elements[n]:Hide()
        end

        -- Fallback: ensure minimum height for active steps
        if frameHeight < 20 and step.active then
            frameHeight = 20
        end
        stepframe:SetHeight(frameHeight)

        if step.active then
            stepframe:Show()
            if step.activeItems then
                for k, v in pairs(step.activeItems) do addon.activeItems[k] = v end
            end
            if step.activeSpells then
                for k, v in pairs(step.activeSpells) do addon.activeSpells[k] = v end
            end
            if step.activeMacros then
                for k, v in pairs(step.activeMacros) do addon.activeMacros[k] = v end
            end
        else
            stepframe:Hide()
        end
    end

    if addon.targeting then
        addon.targeting:UpdateEnemyList(stepUnitscan, stepMobs)
        addon.targeting:UpdateTargetList(stepTargets)
        if addon.settings.profile.enableTargetAutomation then
            addon.targeting:CheckNameplates()
        end
    end

    addon.UpdateItemFrame()
    CurrentStepFrame.UpdateText()
    addon.updateSteps = true
    addon.UpdateMap()
    BottomFrame:StepScroll(scrollHeight)
    addon.updateBottomFrame = true
end

-- ============================================================
-- CURRENT STEP FRAME TEXT UPDATE
-- ============================================================

CurrentStepFrame.framePool = {}

function CurrentStepFrame.UpdateText()
    addon.updateStepText = false
    local guide = addon.currentGuide
    if not guide then return end

    CurrentStepFrame:Show()
    local totalHeight, frameHeight = 0, 0
    local c, e, h, spacing = 0, 0, 0, 0
    local anchor = 0
    local loopStepIndex, stepframe, elementFrame, icon

    for _, step in ipairs(activeSteps) do
        loopStepIndex = step.index
        c = c + 1
        stepframe = CurrentStepFrame.framePool[c]

        if stepframe then
            stepframe:ClearAllPoints()
            if anchor < 1 then
                stepframe:SetPoint("TOPLEFT", CurrentStepFrame, 0, 0)
                stepframe:SetPoint("TOPRIGHT", CurrentStepFrame, 0, 0)
            else
                stepframe:SetPoint("TOPLEFT", CurrentStepFrame.framePool[anchor], "BOTTOMLEFT", 0, -5)
                stepframe:SetPoint("TOPRIGHT", CurrentStepFrame.framePool[anchor], "BOTTOMRIGHT", 0, -5)
            end

            stepframe:SetMovable(false)
            anchor = c

            stepframe.number.text:SetText(step.title or (fmt(L("Step %d"), loopStepIndex)))
            stepframe.number:SetSize(stepframe.number.text:GetStringWidth() + 10, 17)

            e = 0
            frameHeight = 0
            for j, element in ipairs(step.elements or {}) do
                e = j
                elementFrame = stepframe.elements[e]

                if elementFrame then
                    elementFrame:Show()
                    spacing = 0

                    if not IsFrameShown(elementFrame, step) then
                        elementFrame:SetAlpha(0)
                        elementFrame.button:Hide()
                        elementFrame:SetHeight(1)
                        spacing = 1
                    elseif element.text then
                        elementFrame:SetAlpha(1)
                        elementFrame.button:ClearAllPoints()
                        elementFrame.button:SetPoint("TOPLEFT", elementFrame, 6, -1)
                        elementFrame.text:ClearAllPoints()
                        elementFrame.text:SetPoint("TOPLEFT", elementFrame.button, "TOPRIGHT", 11, -1)
                        elementFrame.text:SetPoint("RIGHT", stepframe, -5, 0)

                        if element.text ~= ' ' then
                            -- FIX: Извлекаем читаемый текст
                            local rawText = element.text
                            local userText = rawText:match(">>(.+)$")
                            if userText then
                                rawText = userText:gsub("^%s+", "")
                            else
                                rawText = rawText:gsub("^%.%S+%s*[%d%.%,%-%s]*", "")
                            end
                            local text = L(rawText)
                            if addon.ReplaceNpcIds then
                                text = addon.ReplaceNpcIds(text)
                            end
                            elementFrame.text:SetText(text)
                        else
                            element.requestFromServer = true
                        end

                        h = math.ceil(elementFrame.text:GetStringHeight() * 1.1) + 1
                        elementFrame:SetHeight(h)
                        frameHeight = frameHeight + h

                        if elementFrame.text:GetWidth() > GuideName:GetWidth() + 600 then
                            elementFrame:EnableMouse(false)
                            elementFrame.button:EnableMouse(false)
                        else
                            elementFrame:EnableMouse(true)
                            elementFrame.button:EnableMouse(true)
                        end

                        elementFrame.icon:ClearAllPoints()
                        elementFrame.icon:SetPoint("TOPLEFT", elementFrame.button, "TOPRIGHT", 0, -1)

                        if element.textOnly then
                            elementFrame.button:SetChecked(true)
                            elementFrame.button:Hide()
                            element.completed = true
                        else
                            elementFrame.button:Show()
                        end
                    else
                        elementFrame:SetAlpha(0)
                        elementFrame.button:Hide()
                        elementFrame:SetHeight(1)
                        element.completed = true
                        spacing = 1
                    end

                    elementFrame:ClearAllPoints()
                    if e == 1 then
                        elementFrame:SetPoint("TOPLEFT", stepframe, 0, -10 + spacing)
                        elementFrame:SetPoint("TOPRIGHT", stepframe, 0, -10 + spacing)
                    else
                        elementFrame:SetPoint("TOPLEFT", stepframe.elements[e - 1], "BOTTOMLEFT", 0, 0 + spacing)
                        elementFrame:SetPoint("TOPRIGHT", stepframe.elements[e - 1], "BOTTOMRIGHT", 0, 0 + spacing)
                    end

                    if element.tag and element.text then
                        icon = element.icon or addon.icons[element.tag] or ""
                        elementFrame.icon:SetText(icon)
                        elementFrame.icon:Show()
                    else
                        elementFrame.icon:Hide()
                    end
                end
            end

            if not IsFrameShown(stepframe, step) then
                stepframe:SetAlpha(0)
                frameHeight = 1
                stepframe:EnableMouse(false)
            else
                if stepframe:GetWidth() > GuideName:GetWidth() + 600 then
                    stepframe:EnableMouse(false)
                else
                    stepframe:EnableMouse(true)
                end
                stepframe:SetAlpha(1)
                frameHeight = math.ceil(frameHeight + 18)
            end

            stepframe:SetHeight(frameHeight)
            if step.tip then frameHeight = -5 end
            totalHeight = totalHeight + frameHeight + 5
        end
    end

    CurrentStepFrame:SetHeight(math.max(totalHeight - 5, 0.001))
end

-- ============================================================
-- BOTTOM FRAME SCROLL & UPDATE
-- ============================================================

local stepPos = {}
local lastScrollValue

function BottomFrame:StepScroll(n)
    local value
    local step = addon.currentGuide and addon.currentGuide.steps[n]
    if not step or not IsFrameShown(nil, step) then return end

    local height = ScrollChild.f1 and ScrollChild.f1:GetHeight() or 200
    if n == 1 or not (stepPos[n] and stepPos[0] and height) then
        value = 0
    else
        value = stepPos[n] / stepPos[0] * height - 2
        local smax = height - BottomFrame:GetHeight() + 10
        if value > smax then value = smax end
    end
    if ScrollFrame.ScrollBar then ScrollFrame.ScrollBar:SetValue(value) end

    value = math.floor(value + 0.5)
    if value ~= lastScrollValue then
        addon.ScheduleTask(0, BottomFrame.StepScroll, n)
    end
    lastScrollValue = value
end

function BottomFrame.UpdateFrame(self, stepn, startFrom, skip)
    local level = UnitLevel("player")

    if not addon.currentGuide then
        addon.updateBottomFrame = false
        return
    end

    if stepPos[0] and ((not self and stepn) or (self and self.step)) and IsFrameShown(self, self and self.step) then
        -- First branch: update existing frame (stepPos exists)
        local stepNumber = stepn or self.step.index
        local frame = ScrollChild.framePool[stepNumber]
        local step = addon.currentGuide.steps[stepNumber]
        if not (frame and step) then return end

        local fheight
        local hideStep = (step.level or 0) > level or (not IsFrameShown(frame, step))
        local text, rawtext
        local stepDiff
        local start = startFrom or 1
        local n = 0
        local elements = frame.step.elements
        local nElements = elements and #elements or 0

        for i = start, nElements do
            local element = elements[i]
            if element.text or element.tooltipText or element.requestFromServer or step.active then
                stepDiff = element.step.index - RXPCData.currentStep
                element.element = element

                if element.requestFromServer then
                    addon.Call(element.tag, addon.functions[element.tag], element, "WindowUpdate")
                    addon.updateStepText = addon.updateStepText or not element.requestFromServer
                    addon.stepUpdateList[element.step.index] = not element.requestFromServer
                elseif element.tag and (stepDiff <= 8 and stepDiff >= 0 or element.keepUpdating) then
                    addon.Call(element.tag, addon.functions[element.tag], element, "WindowUpdate")
                end

                rawtext = element.tooltipText
                if type(element.text) ~= "string" then
                    if addon.settings.profile.debug then end
                elseif not rawtext then
                    local displayText = element.text
                    displayText = displayText:gsub("^%.%S+%s*", "")
                    displayText = displayText:gsub("^[%d%.%,%s]+", "")
                    local userText = displayText:match(">>(.+)$")
                    if userText then
                        displayText = userText:trim()
                    end
                    rawtext = displayText
                end

                if rawtext and not element.hideTooltip then
                    if addon.ReplaceNpcIds then
                        rawtext = addon.ReplaceNpcIds(rawtext, element)
                    end
                    if not text then text = " " .. rawtext
                    else text = text .. "\n " .. rawtext end
                end
            end
        end

        if hideStep then
            step.text = ""
            step.hiddentext = text
        else
            step.text = text
        end

        if frame.icon then
            local stepIcon = step.icon or addon.icons[step.elements and step.elements[1] and step.elements[1].tag] or ""
            if stepIcon and stepIcon ~= "" then
                frame.icon:SetTexture(stepIcon)
                frame.icon:Show()
            else
                frame.icon:Hide()
            end
        end

        if frame.text then frame.text:SetText(text) end

        if hideStep then
            frame.text:Hide()
            fheight = 1
            frame:SetAlpha(0)
        else
            frame.text:Show()
            local textHeight = frame.text:GetStringHeight()
            if textHeight then
                fheight = math.ceil(textHeight + 8)
            else
                fheight = 20
            end
            frame:SetAlpha(1)
        end

        local frameHeight = frame:GetHeight() or fheight or 20
        local hDiff = (fheight or 0) - frameHeight
        frame:SetHeight(fheight)

        for n = stepNumber + 1, #stepPos do
            stepPos[n] = stepPos[n] + hDiff
        end
        stepPos[0] = stepPos[0] + hDiff
    else
        -- Second branch: create/update all frames (initial load or full refresh)
        addon.updateBottomFrame = false
        local totalHeight = 0
        local fheight
        local frame
        local step
        local nframes = 0
        local nsteps = addon.currentGuide and #addon.currentGuide.steps or 0

        for n = 1, nsteps do
            step = addon.currentGuide.steps[n]
            frame = ScrollChild.framePool[n]

            if not frame then
                ScrollChild.framePool[n] = CreateFrame("Frame", "$parent_frame" .. n, ScrollChild)
                frame = ScrollChild.framePool[n]

                -- Иконка слева
                frame.icon = frame:CreateTexture(nil, "ARTWORK")
                frame.icon:SetSize(16, 16)
                frame.icon:SetPoint("LEFT", frame, "LEFT", 6, 0)

                -- Номер шага
                frame.number = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                frame.number:SetPoint("LEFT", frame.icon, "RIGHT", 6, 0)
                frame.number:SetTextColor(0.7, 0.7, 0.75)
                frame.number:SetFont(addon.font, 11, "")
                frame.number:SetWidth(18)
                frame.number:SetJustifyH("LEFT")

                -- Текст шага - multiline support with word wrap
                frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                frame.text:SetPoint("LEFT", frame.number, "RIGHT", 4, 0)
                frame.text:SetPoint("RIGHT", frame, "RIGHT", -4, 0)
                frame.text:SetJustifyH("LEFT")
                frame.text:SetJustifyV("TOP")
                frame.text:SetTextColor(0.85, 0.85, 0.9)
                frame.text:SetFont(addon.font, 11, "")
                -- Word wrap handled by anchor points

                -- Hover-эффект
                frame.highlight = frame:CreateTexture(nil, "HIGHLIGHT")
                frame.highlight:SetAllPoints()
                frame.highlight:SetTexture("Interface\QuestFrame\UI-QuestTitleHighlight")
                frame.highlight:SetBlendMode("ADD")
                frame.highlight:SetAlpha(0.4)
                frame.highlight:Hide()

                frame:SetScript("OnEnter", function(self) self.highlight:Show() end)
                frame:SetScript("OnLeave", function(self) self.highlight:Hide() end)
            end

            if frame then
                frame.step = step
                frame.index = n

                -- Build text from elements with proper cleaning
                local text
                -- Build text from elements
                local text
                for _, element in ipairs(step.elements or {}) do
                    local rawtext
                    
                    -- Get readable text from element
                    if element.text then
                        local displayText = element.text
                        
                        -- Check if this is raw tag text (starts with .tag)
                        if displayText:match("^%.") then
                            -- Raw tag text - try to extract >> text or clean it
                            local userText = displayText:match(">>(.+)$")
                            if userText then
                                displayText = userText:gsub("^%s+", ""):gsub("%s+$", "")
                            else
                                -- No >> found - this is a command without readable text
                                -- Skip navigation commands like .goto
                                if element.tag == "goto" or element.tag == "waypoint" then
                                    displayText = nil
                                else
                                    -- Try to clean other tags
                                    displayText = displayText:gsub("^%.%S+%s*", "")
                                    displayText = displayText:gsub("^[%d%.%,%s]+", "")
                                    if displayText == "" then
                                        displayText = nil
                                    end
                                end
                            end
                        end
                        
                        if displayText and displayText ~= "" then
                            rawtext = displayText
                        end
                    end
                    
                    -- Add icon if available
                    if rawtext then
                        local icon = element.icon or addon.icons[element.tag] or ""
                        if icon ~= "" then
                            rawtext = icon .. " " .. rawtext
                        end
                        
                        if not text then
                            text = rawtext
                        else
                            text = text .. "\n" .. rawtext
                        end
                    end
                end

                if not IsFrameShown(frame, step) then
                    frame:Hide()
                    fheight = 0.001
                else
                    frame:Show()

                    -- Номер с ведущим нулём
                    frame.number:SetText(string.format("%02d", n))

                    -- Иконка
                    local firstElement = step.elements and step.elements[1]
                    local stepIcon = firstElement and (firstElement.icon or addon.icons[firstElement.tag]) or ""
                    if stepIcon and stepIcon ~= "" then
                        frame.icon:SetTexture(stepIcon)
                        frame.icon:Show()
                    else
                        frame.icon:Hide()
                    end

                    -- Текст с переносом строк
                    if text and text ~= "" then
                        -- Calculate available width for text
                        local frameWidth = frame:GetWidth()
                        local scrollWidth = ScrollChild:GetWidth()
                        local textWidth

                        -- Safety check: if frame hasn't been laid out yet, use ScrollChild width
                        if frameWidth and frameWidth > 50 then
                            textWidth = frameWidth - frame.number:GetWidth() - 12
                        elseif scrollWidth and scrollWidth > 50 then
                            textWidth = scrollWidth - 30
                        else
                            textWidth = 200 -- fallback safe width
                        end
                        textWidth = math.max(50, textWidth)

                        -- Set text only - anchor points handle width
                        if frame.text then
                            frame.text:SetText(text)
                        end

                        -- Calculate height based on wrapped text
                        local textHeight = frame.text and frame.text:GetStringHeight() or 10
                        fheight = math.max(28, textHeight + 8)
                    else
                        frame.text:SetText("")
                        fheight = 28
                    end
                end

                frame:ClearAllPoints()
                if n == 1 then
                    frame:SetPoint("TOPLEFT", ScrollChild, 0, 0)
                    frame:SetPoint("TOPRIGHT", ScrollChild, -6, 0)
                else
                    frame:SetPoint("TOPLEFT", ScrollChild.framePool[n - 1], "BOTTOMLEFT", 0, -1)
                    frame:SetPoint("TOPRIGHT", ScrollChild.framePool[n - 1], "BOTTOMRIGHT", -6, -1)
                end

                frame:SetHeight(fheight)
                totalHeight = totalHeight + fheight
                nframes = nframes + 1
            end
        end

        for n = nframes + 1, #ScrollChild.framePool do
            if ScrollChild.framePool[n] then
                ScrollChild.framePool[n]:Hide()
            end
        end

        ScrollChild:SetHeight(totalHeight)
        stepPos[0] = totalHeight

        for n = 1, nframes do
            local frameTop = ScrollChild.framePool[n]:GetTop()
            local childTop = ScrollChild:GetTop()
            if frameTop and childTop then
                stepPos[n] = frameTop - childTop
            else
                stepPos[n] = (n - 1) * 28
            end
        end
    end
end
function addon:LoadGuide(guide, isLoading)
    if not guide then return end
    if guide.empty then
        addon.currentGuide = nil
        addon.currentGuideName = nil
        GuideName.text:SetText(guide.displayname)
        CurrentStepFrame:Hide()
        return
    end

    addon:FetchGuide(guide)
    if not guide.steps then return end

    if not guide.key then guide.key = addon.BuildGuideKey(guide) end
    if not guide.version then guide.version = 0 end

    addon.currentGuide = guide
    addon.currentGuideName = guide.name

    RXPCData.currentGuideName = guide.name
    RXPCData.currentGuideGroup = guide.group
    RXPCData.currentStep = RXPCData.currentStep or 1

    if RXPCData.currentStep > #guide.steps then
        RXPCData.currentStep = #guide.steps
    end

    GuideName.text:SetText(guide.displayname or guide.name)
    addon.SetStep(RXPCData.currentStep)

-- Принудительно показываем и обновляем BottomFrame
    BottomFrame:Show()
    addon.updateBottomFrame = true
    BottomFrame.UpdateFrame()

    if not isLoading then
        addon:SendEvent("RXP_GUIDE_LOADED", guide)
    end
end

function addon.ReloadGuide()
    if addon.currentGuide then
        addon:LoadGuide(addon.currentGuide, true)
    end
end

-- ============================================================
-- MENU GENERATION
-- ============================================================

function RXPFrame.GenerateMenuTable()
    RXPFrame.menuList = {}
    local menu = RXPFrame.menuList

    table.insert(menu, {
        text = addon.title,
        isTitle = true,
        notCheckable = 1
    })

    table.insert(menu, {
        text = L("Select Guide"),
        notCheckable = 1,
        hasArrow = true,
        menuList = {}
    })

    for group, guides in pairs(addon.guideList) do
        local groupMenu = {}
        for _, name in ipairs(guides.names_ or {}) do
            local key = guides[name]
            local guide = addon.guides[key]
            if guide then
                table.insert(groupMenu, {
                    text = guide.displayname or name,
                    notCheckable = 1,
                    func = function()
                        addon:LoadGuide(guide)
                    end
                })
            end
        end

        if #groupMenu > 0 then
            table.insert(menu[2].menuList, {
                text = group,
                notCheckable = 1,
                hasArrow = true,
                menuList = groupMenu
            })
        end
    end

table.insert(menu, {
    text = L("Settings"),
    notCheckable = 1,
    func = function()
        -- Прямое открытие настроек для 3.3.5
        if InterfaceOptionsFrame then
            InterfaceOptionsFrame:Show()
            if InterfaceOptionsFrame_OpenToCategory and addon.settingsPanel then
                InterfaceOptionsFrame_OpenToCategory(addon.settingsPanel)
            end
        end
    end
})
    table.insert(menu, {
        text = L("Close"),
        notCheckable = 1,
        func = function()
            addon.settings.profile.showEnabled = false
            addon.isHidden = true
            RXPFrame:Hide()
        end
    })
end

-- ============================================================
-- SET STEP FRAME ANCHOR
-- ============================================================

function RXPFrame.SetStepFrameAnchor()
    local top = RXPFrame:GetTop()
    local bottom = RXPFrame:GetBottom()
    local screenHeight = GetScreenHeight()
    local anchor = addon.settings.profile.anchor

    CurrentStepFrame:ClearAllPoints()

    if anchor == "top" then
        CurrentStepFrame:SetPoint("BOTTOMLEFT", GuideName, "TOPLEFT", 0, 2)
        CurrentStepFrame:SetPoint("BOTTOMRIGHT", GuideName, "TOPRIGHT", 0, 2)
    elseif anchor == "bottom" then
        CurrentStepFrame:SetPoint("TOPLEFT", Footer, "BOTTOMLEFT", 0, -2)
        CurrentStepFrame:SetPoint("TOPRIGHT", Footer, "BOTTOMRIGHT", 0, -2)
    else
        if top and top > screenHeight / 2 then
            CurrentStepFrame:SetPoint("BOTTOMLEFT", GuideName, "TOPLEFT", 0, 2)
            CurrentStepFrame:SetPoint("BOTTOMRIGHT", GuideName, "TOPRIGHT", 0, 2)
        else
            CurrentStepFrame:SetPoint("TOPLEFT", Footer, "BOTTOMLEFT", 0, -2)
            CurrentStepFrame:SetPoint("TOPRIGHT", Footer, "BOTTOMRIGHT", 0, -2)
        end
    end
end

-- ============================================================
-- FONT SIZE UPDATE
-- ============================================================

function addon.UpdateGuideFontSize()
    local size = addon.settings.profile.guideFontSize or 9
    GuideName.text:SetFont(addon.font, 11, "OUTLINE")
    Footer.text:SetFont(addon.font, 8, "")

    for _, frame in ipairs(CurrentStepFrame.framePool or {}) do
        if frame.number and frame.number.text then
            frame.number.text:SetFont(addon.font, size, "OUTLINE")
        end
        for _, element in ipairs(frame.elements or {}) do
            if element.text then
                element.text:SetFont(addon.font, size + 2, "")
            end
        end
    end

    for _, frame in ipairs(ScrollChild.framePool or {}) do
        if frame.number and frame.number.text then
            frame.number.text:SetFont(addon.font, size, "OUTLINE")
        end
        if frame.text then
            frame.text:SetFont(addon.font, size, "")
        end
    end
end

-- ============================================================
-- INITIALIZE
-- ============================================================

-- ============================================================
-- SCROLL FRAME SETUP
-- ============================================================

ScrollChild.framePool = {}
ScrollChild:SetHeight(1)

ScrollFrame:SetScript("OnScrollRangeChanged", function(self, xrange, yrange)
    local scrollBar = self.ScrollBar or _G[self:GetName() .. "ScrollBar"]
    local min, max = scrollBar:GetMinMaxValues()
    if yrange > 0 then
        if max ~= yrange then
            if math.floor(scrollBar:GetValue()) >= math.floor(max) then
                scrollBar:SetValue(yrange)
            end
            scrollBar:SetMinMaxValues(0, yrange)
        end
    else
        scrollBar:SetMinMaxValues(0, 0)
        scrollBar:SetValue(0)
    end
end)