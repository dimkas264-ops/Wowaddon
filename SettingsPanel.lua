local addonName, addon = ...

local L = addon.locale.Get
local fmt = string.format

-- 3.3.5: Settings API differences
local InterfaceOptions_AddCategory = _G.InterfaceOptions_AddCategory
local InterfaceOptionsFrame_OpenToCategory = _G.InterfaceOptionsFrame_OpenToCategory

-- ============================================================
-- SETTINGS DATABASE
-- ============================================================

addon.settings = {}
addon.settings.profile = {}

local defaultSettings = {
    profile = {
        -- Window
        showEnabled = true,
        hideGuideWindow = false,
        lockFrames = false,
        windowScale = 1.0,
        frameHeight = 125,
        anchor = "auto",

        -- Fonts
        guideFontSize = 9,
        arrowText = 10,

        -- Features
        enableQuestAutomation = true,
        enableQuestRewardAutomation = false,
        enableTrainerAutomation = true,
        enableFlightPathAutomation = true,
        enableTargetAutomation = true,
        enableItemUpgrades = true,
        enableTips = true,
        enableTracker = false,

        -- Display
        showArrow = true,
        arrowScale = 1.0,
        activeItemsScale = 1.0,
        hideInRaid = false,
        showStepList = true,

        -- Advanced
        updateFrequency = 75,
        debug = false,
        preLoadData = false,
        loadAllGuides = false,

        -- Game specific
        phase = 6,
        season = 0,
        xprate = 1,
        enableGroupQuests = true,
        enableXpStepSkipping = true,
        northrendLM = false,
        loremasterMode = false,
        soloSelfFound = false,

        -- Dungeons
        dungeons = {},
        professions = nil,
    }
}

function addon.settings:InitializeDatabase()
    if not RXPSettings then RXPSettings = {} end

    -- Merge defaults with saved settings
    for k, v in pairs(defaultSettings.profile) do
        if RXPSettings[k] == nil then
            RXPSettings[k] = v
        end
    end

    self.profile = RXPSettings
end

function addon.settings:InitializeSettings()
    -- Called after database init
end

-- ============================================================
-- FRAME POSITIONS
-- ============================================================

function addon.settings:SaveFramePositions()
    if not self.profile.framePositions then
        self.profile.framePositions = {}
    end

    if addon.RXPFrame then
        local point, _, relativePoint, x, y = addon.RXPFrame:GetPoint()
        self.profile.framePositions.RXPFrame = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y,
            width = addon.RXPFrame:GetWidth(),
            height = addon.RXPFrame:GetHeight(),
        }
    end

    if addon.arrowFrame then
        local point, _, relativePoint, x, y = addon.arrowFrame:GetPoint()
        self.profile.framePositions.arrowFrame = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y,
        }
    end

    if addon.activeItemFrame then
        local point, _, relativePoint, x, y = addon.activeItemFrame:GetPoint()
        self.profile.framePositions.activeItemFrame = {
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y,
        }
    end
end

function addon.settings:LoadFramePositions()
    local positions = self.profile.framePositions
    if not positions then return end

    if positions.RXPFrame and addon.RXPFrame then
        addon.RXPFrame:ClearAllPoints()
        addon.RXPFrame:SetPoint(
            positions.RXPFrame.point,
            UIParent,
            positions.RXPFrame.relativePoint,
            positions.RXPFrame.x,
            positions.RXPFrame.y
        )
        if positions.RXPFrame.width then
            addon.RXPFrame:SetWidth(positions.RXPFrame.width)
        end
        if positions.RXPFrame.height then
            addon.RXPFrame:SetHeight(positions.RXPFrame.height)
        end
    end

    if positions.arrowFrame and addon.arrowFrame then
        addon.arrowFrame:ClearAllPoints()
        addon.arrowFrame:SetPoint(
            positions.arrowFrame.point,
            UIParent,
            positions.arrowFrame.relativePoint,
            positions.arrowFrame.x,
            positions.arrowFrame.y
        )
    end

    if positions.activeItemFrame and addon.activeItemFrame then
        addon.activeItemFrame:ClearAllPoints()
        addon.activeItemFrame:SetPoint(
            positions.activeItemFrame.point,
            UIParent,
            positions.activeItemFrame.relativePoint,
            positions.activeItemFrame.x,
            positions.activeItemFrame.y
        )
    end
end

-- ============================================================
-- MINIMAP BUTTON
-- ============================================================

function addon.settings:UpdateMinimapButton()
    -- Minimap button logic (simplified for 3.3.5)
    if self.profile.showEnabled then
        -- Show minimap button
    else
        -- Hide minimap button
    end
end

function addon.settings:SetupMapButton()
    -- World map button integration
end

-- ============================================================
-- SETTINGS PANEL
-- ============================================================

local settingsPanel = nil
local settingsWidgets = {}
local panelRegistered = false

-- Helper: create a checkbox widget
local function CreateCheckbox(parent, label, key, tooltip, yOffset)
    local cb = CreateFrame("CheckButton", "$parent_" .. key, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    cb:SetSize(24, 24)

    local text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    text:SetText(label)
    cb.text = text

    cb:SetChecked(addon.settings.profile[key] or false)

    cb:SetScript("OnClick", function(self)
        addon.settings.profile[key] = self:GetChecked() and true or false
        if key == "showEnabled" then
            if addon.settings.profile.showEnabled then
                addon.isHidden = false
                addon.RXPFrame:Show()
            else
                addon.isHidden = true
                addon.RXPFrame:Hide()
            end
        elseif key == "hideGuideWindow" then
            addon.RenderFrame()
        elseif key == "lockFrames" then
            -- Frame lock updated
        elseif key == "showArrow" then
            if addon.arrowFrame then
                if addon.settings.profile.showArrow then
                    addon.arrowFrame:Show()
                else
                    addon.arrowFrame:Hide()
                end
            end
        end
    end)

    if tooltip then
        cb:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end)
        cb:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end

    table.insert(settingsWidgets, cb)
    return cb, yOffset - 28
end

-- Helper: create a slider widget
local function CreateSlider(parent, label, key, minVal, maxVal, step, yOffset, formatStr)
    local slider = CreateFrame("Slider", "$parent_" .. key .. "Slider", parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    slider:SetWidth(200)
    slider:SetHeight(16)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetValue(addon.settings.profile[key] or minVal)

    _G[slider:GetName() .. "Text"]:SetText(label)
    _G[slider:GetName() .. "Low"]:SetText(tostring(minVal))
    _G[slider:GetName() .. "High"]:SetText(tostring(maxVal))

    local valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    valueText:SetPoint("TOP", slider, "BOTTOM", 0, -2)
    valueText:SetText(fmt(formatStr or "%s", slider:GetValue()))
    slider.valueText = valueText

    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / step + 0.5) * step
        addon.settings.profile[key] = value
        valueText:SetText(fmt(formatStr or "%s", value))

        if key == "guideFontSize" then
            addon.UpdateGuideFontSize()
        elseif key == "windowScale" then
            if addon.RXPFrame then
                addon.RXPFrame:SetScale(value)
            end
        elseif key == "arrowScale" then
            if addon.arrowFrame then
                addon.arrowFrame:SetScale(value)
            end
        end
    end)

    table.insert(settingsWidgets, slider)
    return slider, yOffset - 45
end

-- Helper: create a section header
local function CreateSectionHeader(parent, text, yOffset)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, yOffset)
    header:SetText(text)
    return header, yOffset - 25
end

function addon.settings:CreateSettingsPanel()
    if settingsPanel then return settingsPanel end

    -- 3.3.5: фрейм должен иметь поле .name для отображения в списке
    settingsPanel = CreateFrame("Frame", "RXPSettingsPanel", UIParent)
    settingsPanel.name = addon.title or "RestedXP"
    settingsPanel.parent = nil  -- top-level category

    -- 3.3.5: обязательные методы для InterfaceOptions
    settingsPanel.okay = function(self) end
    settingsPanel.cancel = function(self) end
    settingsPanel.default = function(self) end
    settingsPanel.refresh = function(self) end

    -- Title
    local title = settingsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText((addon.title or "RestedXP") .. " " .. L("Settings"))

    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", "RXPSettingsScroll", settingsPanel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 16, -45)
    scrollFrame:SetPoint("BOTTOMRIGHT", -32, 16)

    local scrollChild = CreateFrame("Frame", "RXPSettingsScrollChild", scrollFrame)
    scrollChild:SetWidth(1)
    scrollChild:SetHeight(1)
    scrollFrame:SetScrollChild(scrollChild)

    settingsPanel.scrollFrame = scrollFrame
    settingsPanel.scrollChild = scrollChild

    -- Build widgets
    local y = -5
    local _, newY

    -- === WINDOW SECTION ===
    _, y = CreateSectionHeader(scrollChild, L("Window"), y)
    _, y = CreateCheckbox(scrollChild, L("Show Guide Window"), "showEnabled",
        L("Show or hide the main guide window"), y)
    _, y = CreateCheckbox(scrollChild, L("Lock Frames"), "lockFrames",
        L("Prevent frames from being moved"), y)
    _, y = CreateCheckbox(scrollChild, L("Hide Guide Window"), "hideGuideWindow",
        L("Completely hide the guide window"), y)
    _, y = CreateSlider(scrollChild, L("Window Scale"), "windowScale", 0.5, 2.0, 0.1, y, "%.1fx")
    _, y = CreateSlider(scrollChild, L("Font Size"), "guideFontSize", 6, 16, 1, y, "%d")

    -- === DISPLAY SECTION ===
    y = y - 10
    _, y = CreateSectionHeader(scrollChild, L("Display"), y)
    _, y = CreateCheckbox(scrollChild, L("Show Arrow"), "showArrow",
        L("Show directional arrow to next step"), y)
    _, y = CreateSlider(scrollChild, L("Arrow Scale"), "arrowScale", 0.5, 2.0, 0.1, y, "%.1fx")
    _, y = CreateCheckbox(scrollChild, L("Show Step List"), "showStepList",
        L("Show list of upcoming steps"), y)
    _, y = CreateCheckbox(scrollChild, L("Hide in Raid"), "hideInRaid",
        L("Hide guide window when in a raid"), y)

    -- === FEATURES SECTION ===
    y = y - 10
    _, y = CreateSectionHeader(scrollChild, L("Features"), y)
    _, y = CreateCheckbox(scrollChild, L("Quest Automation"), "enableQuestAutomation",
        L("Automatically accept and turn in quests"), y)
    _, y = CreateCheckbox(scrollChild, L("Quest Reward Automation"), "enableQuestRewardAutomation",
        L("Automatically select quest rewards"), y)
    _, y = CreateCheckbox(scrollChild, L("Trainer Automation"), "enableTrainerAutomation",
        L("Automatically learn skills from trainers"), y)
    _, y = CreateCheckbox(scrollChild, L("Flight Path Automation"), "enableFlightPathAutomation",
        L("Automatically discover flight paths"), y)
    _, y = CreateCheckbox(scrollChild, L("Target Automation"), "enableTargetAutomation",
        L("Automatically set target based on guide step"), y)
    _, y = CreateCheckbox(scrollChild, L("Item Upgrades"), "enableItemUpgrades",
        L("Show item upgrade recommendations"), y)
    _, y = CreateCheckbox(scrollChild, L("Enable Tips"), "enableTips",
        L("Show helpful tips and hints"), y)

    -- === ADVANCED SECTION ===
    y = y - 10
    _, y = CreateSectionHeader(scrollChild, L("Advanced"), y)
    _, y = CreateCheckbox(scrollChild, L("Debug Mode"), "debug",
        L("Enable debug output"), y)
    _, y = CreateCheckbox(scrollChild, L("Pre-load Data"), "preLoadData",
        L("Pre-load guide data for faster switching"), y)
    _, y = CreateCheckbox(scrollChild, L("Load All Guides"), "loadAllGuides",
        L("Load all available guides at startup"), y)
    _, y = CreateSlider(scrollChild, L("Update Frequency (ms)"), "updateFrequency", 10, 200, 5, y, "%d ms")

    -- Set scroll child height based on content
    scrollChild:SetHeight(math.abs(y) + 50)
    scrollChild:SetWidth(scrollFrame:GetWidth() - 30)

    addon.settingsPanel = settingsPanel
    return settingsPanel
end

-- ============================================================
-- REGISTER PANEL - отложенная регистрация для 3.3.5
-- ============================================================

function addon.settings:RegisterSettingsPanel()
    if panelRegistered then return end
    if not settingsPanel then
        self:CreateSettingsPanel()
    end
    if not settingsPanel then
        print("RXP ERROR: Failed to create settings panel")
        return
    end

    -- 3.3.5: InterfaceOptions_AddCategory требует, чтобы фрейм был полностью готов
    if InterfaceOptions_AddCategory then
        local ok, err = pcall(function()
            InterfaceOptions_AddCategory(settingsPanel)
        end)
        if ok then
            panelRegistered = true
            print("RXP: Settings panel registered successfully")
        else
            print("RXP ERROR: Failed to register settings panel: " .. tostring(err))
        end
    else
        print("RXP WARNING: InterfaceOptions_AddCategory not available")
    end
end

-- ============================================================
-- OPEN SETTINGS
-- ============================================================

function addon.settings.OpenSettings(category)
    -- Убеждаемся, что панель зарегистрирована
    if not panelRegistered then
        addon.settings:RegisterSettingsPanel()
    end

    local panel = addon.settingsPanel
    if not panel then
        print("RXP ERROR: Settings panel not created")
        return
    end

    -- 3.3.5: открываем через InterfaceOptionsFrame
    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame:Show()
    else
        -- Фоллбэк: показываем панель напрямую
        if not panel:IsShown() then
            panel:Show()
            panel:ClearAllPoints()
            panel:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            panel:SetFrameStrata("HIGH")
            panel:SetWidth(600)
            panel:SetHeight(500)
        end
    end
end

-- ============================================================
-- IMPORT STATUS
-- ============================================================

function addon.settings:UpdateImportStatusHistory(text)
    if not self.profile.importHistory then
        self.profile.importHistory = {}
    end
    table.insert(self.profile.importHistory, {
        time = date("%H:%M:%S"),
        text = text,
    })

    -- Keep only last 50 entries
    while #self.profile.importHistory > 50 do
        table.remove(self.profile.importHistory, 1)
    end
end

-- ============================================================
-- THEME FUNCTIONS
-- ============================================================

function addon.settings.ReplaceColors(text)
    if not text then return "" end
    return text
end

function addon:ImportCustomThemes()
    -- Custom theme loading
end

function addon:LoadActiveTheme()
    addon.activeTheme = addon.activeTheme or {
        textColor = {1, 1, 1},
        background = {0, 0, 0, 0.5},
        border = {1, 1, 1, 1},
    }
    addon.colors = addon.activeTheme
end

-- ============================================================
-- DETECTION FUNCTIONS
-- ============================================================

function addon.settings:DetectXPRate()
    -- Detect XP rate (for private servers)
    local rate = 1
    -- Detection logic here
    self.profile.xprate = rate
end

function addon.settings:CheckAddonCompatibility()
    -- Check for incompatible addons
end

-- ============================================================
-- SLASH COMMANDS
-- ============================================================

SLASH_RXP1 = "/rxp"
SLASH_RXP2 = "/restedxp"

SlashCmdList["RXP"] = function(msg)
    local command, arg = msg:match("^(\S*)%s*(.-)$")
    command = strlower(command or "")

    if command == "" or command == "help" then
        print(addon.title .. " " .. addon.release)
        print("/rxp — Open settings")
        print("/rxp reset — Reset frame positions")
        print("/rxp hide — Hide guide window")
        print("/rxp show — Show guide window")
        print("/rxp import — Import guide string")
    elseif command == "reset" then
        addon.settings.profile.framePositions = nil
        addon.RXPFrame:ClearAllPoints()
        addon.RXPFrame:SetPoint("LEFT", 0, 35)
        print("Frame positions reset")
    elseif command == "hide" then
        addon.settings.profile.showEnabled = false
        addon.isHidden = true
        addon.RXPFrame:Hide()
    elseif command == "show" then
        addon.settings.profile.showEnabled = true
        addon.isHidden = false
        addon.RXPFrame:Show()
    elseif command == "import" then
        if arg and arg ~= "" then
            addon.ImportString(arg)
        else
            print("Usage: /rxp import <guide_string>")
        end
    end
end

-- ============================================================
-- FONT SETUP
-- ============================================================

addon.font = "Fonts\\FRIZQT__.TTF"

function addon.UpdateGuideFontSize()
    local size = addon.settings.profile.guideFontSize or 9
    -- Update all font strings
end

-- ============================================================
-- AUTO-REGISTER ON PLAYER LOGIN (3.3.5 fix)
-- ============================================================

local regFrame = CreateFrame("Frame")
regFrame:RegisterEvent("PLAYER_LOGIN")
regFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        -- Отложенная регистрация, чтобы InterfaceOptionsFrame был готов
        C_Timer.After(1, function()
            if addon.settings and addon.settings.RegisterSettingsPanel then
                addon.settings:RegisterSettingsPanel()
            end
        end)
    end
end)
