local addonName, addon = ...
addon = addon or {}
addon.startTime = debugprofilestop()

-- Event frame for 3.3.5 (without AceEvent)
addon.eventFrame = CreateFrame("Frame")
addon.eventFrame:SetScript("OnEvent", function(frame, event, ...)
    if event == "GROUP_JOINED" or event == "GROUP_FORMED" then
        addon.HideInRaid()
    elseif event == "GROUP_LEFT" then
        addon:GROUP_LEFT()
    elseif addon[event] then
        addon[event](addon, event, ...)
    end
end)
local _G = _G
-- ============================================================
-- 3.3.5 API FIXES (functions that don't exist in WotLK)
-- ============================================================

-- GetQuestID doesn't exist in 3.3.5
if not _G.GetQuestID then
    _G.GetQuestID = function()
        -- В 3.3.5 используем GetQuestLogSelection или возвращаем 0
        local questIndex = GetQuestLogSelection()
        if questIndex and questIndex > 0 then
            local _, _, _, _, _, _, _, id = GetQuestLogTitle(questIndex)
            return id or 0
        end
        return 0
    end
end

-- IsPlayerSpell doesn't exist in 3.3.5
if not _G.IsPlayerSpell then
    _G.IsPlayerSpell = function(spellID)
        return GetSpellInfo(spellID) ~= nil
    end
end

-- GetGossipActiveQuests wrapper for 3.3.5 compatibility
-- In 3.3.5: GetGossipActiveQuests(index) returns title, level, isTrivial, isComplete, isLegendary
_G.GetGossipActiveQuests = _G.GetGossipActiveQuests or function() end

-- GetGossipAvailableQuests wrapper for 3.3.5 compatibility
-- In 3.3.5: GetGossipAvailableQuests(index) returns title, level, isTrivial, frequency, isRepeatable, isLegendary
_G.GetGossipAvailableQuests = _G.GetGossipAvailableQuests or function() end
local UnitInRaid = UnitInRaid
local fmt = string.format
local rand, tinsert, select = math.random, table.insert, _G.select

-- ============================================================
-- 3.3.5 API COMPATIBILITY LAYER
-- ============================================================

-- C_Timer эмуляция
local NewTicker
if _G.C_Timer and _G.C_Timer.NewTicker then
    NewTicker = _G.C_Timer.NewTicker
else
    NewTicker = function(duration, callback)
        local ticker = {}
        local elapsed = 0
        local frame = CreateFrame("Frame")
        frame:SetScript("OnUpdate", function(self, delta)
            elapsed = elapsed + delta
            if elapsed >= duration then
                elapsed = elapsed - duration
                callback()
            end
        end)
        ticker._frame = frame
        ticker.Cancel = function(self)
            self._frame:SetScript("OnUpdate", nil)
            self._frame:Hide()
        end
        return ticker
    end
end

local function After(delay, callback)
    local f = CreateFrame("Frame")
    local elapsed = 0
    f:SetScript("OnUpdate", function(self, delta)
        elapsed = elapsed + delta
        if elapsed >= delay then
            self:SetScript("OnUpdate", nil)
            callback()
        end
    end)
end

-- C_Spell → глобальные функции
local GetSpellInfo = _G.GetSpellInfo
local GetSpellTexture = _G.GetSpellTexture
local GetSpellSubtext = _G.GetSpellSubtext or function() return "" end
local IsCurrentSpell = _G.IsCurrentSpell
local IsSpellKnown = _G.IsSpellKnown
local IsPlayerSpell = _G.IsPlayerSpell or function(spellID)
    -- Fallback for 3.3.5: check via GetSpellInfo
    local name = GetSpellInfo(spellID)
    return name ~= nil
end
-- C_Item → глобальные функции
local GetItemInfo = _G.GetItemInfo
local GetItemCount = _G.GetItemCount
local GetItemSpell = _G.GetItemSpell

-- C_Container → глобальные функции
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetContainerItemID = _G.GetContainerItemID
local GetContainerItemLink = _G.GetContainerItemLink
local GetContainerItemInfo = _G.GetContainerItemInfo

-- C_QuestLog → глобальные функции
local GetNumQuestLogEntries = _G.GetNumQuestLogEntries
local GetQuestLogTitle = _G.GetQuestLogTitle
local GetQuestLogSelection = _G.GetQuestLogSelection
local SelectQuestLogEntry = _G.SelectQuestLogEntry

-- C_GossipInfo → глобальные функции
local GossipGetNumOptions = _G.GetNumGossipOptions
local GossipGetNumActiveQuests = _G.GetNumGossipActiveQuests
local GossipGetNumAvailableQuests = _G.GetNumGossipAvailableQuests
local GossipSelectAvailableQuest = _G.SelectGossipAvailableQuest
local GossipGetActiveQuests = _G.GetGossipActiveQuests
local GossipSelectActiveQuest = _G.SelectGossipActiveQuest
local GossipGetAvailableQuests = _G.GetGossipAvailableQuests

-- C_Map → глобальные функции
local GetCurrentMapAreaID = _G.GetCurrentMapAreaID or function() return 0 end
local GetPlayerMapPosition = _G.GetPlayerMapPosition
local SetMapToCurrentZone = _G.SetMapToCurrentZone

-- C_AddOns → глобальные функции
local GetAddOnMetadata = _G.GetAddOnMetadata

-- ============================================================
-- CORE VARIABLES
-- ============================================================

addon.release = GetAddOnMetadata(addonName, "Version") or "4.0.0-335"
addon.title = GetAddOnMetadata(addonName, "Title") or "RestedXP Guides"
local cacheVersion = 29

-- ============================================================
-- LOCALE INITIALIZATION (must be before any L() calls)
-- ============================================================

addon.locale = addon.locale or {}
addon.locale.translations = addon.locale.translations or {}

function addon.locale.Get(key)
    if not key then return "" end
    return addon.locale.translations[key] or key
end

function addon.locale.SetTranslation(key, translation)
    if key and translation then
        addon.locale.translations[key] = translation
    end
end

local L = addon.locale.Get
local locale = GetLocale()

if string.match(addon.release, 'project') then
    addon.release = L('Development')
    addon.versionText = L('Development')
else
    addon.versionText = string.format("%s %s", _G.GAME_VERSION_LABEL or "Version", addon.release)
end

addon.version = 40000
local gameVersion = select(4, GetBuildInfo())
addon.gameVersion = gameVersion
local maxLevel

addon.enabledLocale = {
    ["enUS"] = false,
    ["ruRU"] = true,
}

-- Определение версии игры
if gameVersion > 30000 then
    addon.game = "WOTLK"
    maxLevel = 80
elseif gameVersion > 20000 then
    addon.game = "TBC"
    maxLevel = 70
else
    addon.game = "CLASSIC"
    maxLevel = 60
end

-- 3.3.5: C_Seasons не существует
function addon.GetSeason() return 0 end

-- ============================================================
-- DATA TABLES
-- ============================================================

local RXPGuides = {}
addon.RXPGuides = RXPGuides
_G.RXPGuides = RXPGuides

addon.guideCache = {}
addon.questQueryList = {}
addon.itemQueryList = {}
addon.questAccept = {}
addon.questTurnIn = {}
addon.disabledQuests = {}
addon.activeItems = {}
addon.activeSpells = {}
addon.activeMacros = {}
addon.functions = {}
addon.separators = {}
addon.enabledFrames = {}
addon.player = {
    localeClass = select(1, UnitClass("player")),
    class = select(2, UnitClass("player")),
    race = select(2, UnitRace("player")),
    faction = select(1, UnitFactionGroup("player")),
    guid = UnitGUID("player"),
    name = UnitName("player"),
    level = UnitLevel("player"),
    maxlevel = maxLevel,
    season = addon.GetSeason(),
    beta = false,
    lang = GetLocale():sub(1,2),
    hardcore = false,
}
addon.player.neutral = addon.player.faction == "Neutral"

addon.generatedSteps = {}

BINDING_HEADER_RXPGuides = addon.title
BINDING_HEADER_RXPTargeting = addon.title

-- ============================================================
-- ERROR HANDLING
-- ============================================================

local errorTimer = 0
addon.errors = {}
function addon.Call(label, func, ...)
    label = label or ""
    addon.lastCall = label
    local pass, r1, r2, r3, r4 = pcall(func, ...)
    if not pass then
        local msg = r1
        addon.errors[label] = addon.errors[label] or {}
        local count = addon.errors[label][msg] or 0
        addon.errors[label][msg] = count + 1
        if GetTime() - errorTimer > 30 then
            errorTimer = GetTime()
            error(msg)
        end
        return
    end
    return r1, r2, r3, r4
end

-- ============================================================
-- MESSAGE SYSTEM
-- ============================================================

local RegisterMessage_OLD = addon.RegisterMessage
local messageList = {}

local function MessageHandler(message, ...)
    for func in pairs(messageList[message]) do
        func(message, ...)
    end
end

addon.RegisterMessage = function(self, message, callback, ...)
    if not messageList[message] then
        messageList[message] = {}
        RegisterMessage_OLD(self, message, MessageHandler)
    end
    messageList[message][callback] = true
end

function addon:UnregisterMessage(message, callback)
    if not messageList[message] then return
    elseif callback then
        messageList[message][callback] = nil
    else
        table.wipe(messageList[message])
    end
end

addon.HookMessage = function(self, message, callback, ...)
    if not (messageList[message] and messageList[message][callback]) then
        addon.RegisterMessage(self, message, callback, ...)
    end
end

function addon.SendEvent(self, ...)
    if _G.WeakAuras and _G.WeakAuras.ScanEvents then
        _G.WeakAuras.ScanEvents(...)
    end
    if addon.SendMessage then
        return addon.SendMessage(self, ...)
    end
end

local messageQueue = {}
function addon:QueueMessage(...)
    tinsert(messageQueue, {...})
end

function addon.ProcessMessageQueue()
    local processed
    local removedIndexes = {}
    for i = 1, #messageQueue do
        addon:SendEvent(unpack(messageQueue[i]))
        tinsert(removedIndexes, i)
        if i >= 10 then break end
    end
    for i = #removedIndexes, 1, -1 do
        processed = true
        table.remove(messageQueue, removedIndexes[i])
    end
    return processed
end

-- ============================================================
-- QUEST AUTOMATION
-- ============================================================

local questFrame = CreateFrame("Frame")
local startTime = GetTime()

function addon.QuestAutoAccept(titleOrId)
    if not titleOrId then return end
    if addon.CheckAvailableQuest then addon.CheckAvailableQuest(titleOrId) end
    local element = addon.questAccept[titleOrId]
    if not element or (element.questId and addon.disabledQuests[element.questId]) then return end
    local step = element.step
    if step.active or (step.index > 1 and addon.currentGuide.steps[step.index - 1].active) then
        addon:SendEvent("RXP_QUEST_ACCEPT", element.questId)
        return true
    end
end

function addon.GetStepQuestReward(titleOrId)
    if not titleOrId then return 0 end
    local element = addon.questTurnIn[titleOrId]
    if not element then return 0 end
    if not addon.settings.profile.enableQuestRewardAutomation then return 0, element end
    return (element.reward >= 0 and element.reward or 0), element
end

function addon.IsPlayerSpell(id)
    if IsPlayerSpell(id) or IsSpellKnown(id, true) or IsSpellKnown(id) then
        return true
    end
    return false
end

-- ============================================================
-- PROFESSIONS & SKILLS
-- ============================================================

local currrentSkillLevel = {}
local maxSkillLevel = {}
local professionNames

function addon.GetProfessionNames()
    if not professionNames then
        professionNames = {}
        addon.professionNames = professionNames
    end
    for profession, ids in pairs(addon.professionID or {}) do
        for i, id in ipairs(ids) do
            if IsSpellKnown(id) then
                if id == 2656 then
                    professionNames[profession] = GetSpellInfo(2575)
                elseif id == 2383 then
                    professionNames[profession] = GetSpellInfo(9134)
                elseif id == 1804 then
                    professionNames[profession] = GetSpellInfo(1809)
                else
                    professionNames[profession] = GetSpellInfo(id)
                end
                if professionNames[profession] then break end
            end
        end
    end
    professionNames.riding = GetSpellInfo(33388)
    return professionNames
end

addon.currrentSkillLevel = currrentSkillLevel
function addon.GetProfessionLevel()
    local names
    if not (professionNames and professionNames.riding) then
        addon.GetProfessionNames()
    end
    names = professionNames

    if IsPlayerSpell(33388) then currrentSkillLevel["riding"] = 75
    elseif IsPlayerSpell(33391) then currrentSkillLevel["riding"] = 150
    elseif IsPlayerSpell(34090) then currrentSkillLevel["riding"] = 225
    elseif IsPlayerSpell(34091) then currrentSkillLevel["riding"] = 300
    end

    if addon.IsPlayerSpell(54197) then currrentSkillLevel["coldweatherflying"] = 1 end

    if not _G.GetSkillLineInfo then return end
    if not names.riding then names.riding = GetSpellInfo(33388) end
    for i = 1, _G.GetNumSkillLines() do
        local skillName, _, _, skillRank, _, _, skillMaxRank = _G.GetSkillLineInfo(i)
        if skillRank then
            for profession, name in pairs(names) do
                if name == skillName then
                    currrentSkillLevel[profession] = skillRank
                    maxSkillLevel[profession] = skillMaxRank
                end
            end
        end
    end
end

function addon.UpdateSkillData()
    addon.GetProfessionNames()
    addon.GetProfessionLevel()
end

function addon.GetSkillLevel(skill, useMaxValue)
    addon.UpdateSkillData()
    if skill then
        if useMaxValue then
            return maxSkillLevel[skill] or -1
        else
            return currrentSkillLevel[skill] or -1
        end
    else
        if useMaxValue then return maxSkillLevel else return currrentSkillLevel end
    end
end

-- ============================================================
-- GUIDE MANIPULATION
-- ============================================================

local function ChangeStep(srcGuide, srcStep, destGuide, destStep, func)
    local function stepindex(guide, refresh)
        if type(guide) ~= "table" then return false end
        if not guide.stepIds or refresh then
            guide.stepIds = {}
            for i, step in ipairs(guide.steps) do
                if step.stepId then guide.stepIds[step.stepId] = i end
            end
        end
        return true
    end

    srcGuide = addon:FetchGuide(addon.guideIds[srcGuide])
    destGuide = addon:FetchGuide(addon.guideIds[destGuide])

    if not (stepindex(srcGuide) and (not destGuide or stepindex(destGuide))) then return end
    srcStep = srcGuide.stepIds[srcStep]
    destStep = srcGuide.stepIds[destStep]
    if srcStep and (not destGuide or destStep) then
        func(srcGuide, srcStep, destGuide, destStep)
        stepindex(srcGuide, true)
        stepindex(destGuide, true)
        addon:ScheduleTask(addon.ReloadGuide)
        return true
    end
end

function addon.ReplaceStep(arg1, arg2, arg3, arg4)
    local function replace(srcGuide, srcStep, destGuide, destStep)
        destGuide.steps[destStep] = srcGuide.steps[srcStep]
    end
    return ChangeStep(arg1, arg2, arg3, arg4, replace)
end

function addon.RemoveStep(arg1, arg2)
    local function remove(srcGuide, srcStep)
        table.remove(srcGuide.steps, srcStep)
    end
    return ChangeStep(arg1, arg2, "", "", remove)
end

function addon.InsertStep(arg1, arg2, arg3, arg4)
    local function insert(srcGuide, srcStep, destGuide, destStep)
        table.insert(destGuide.steps, destStep, srcGuide.steps[srcStep])
    end
    return ChangeStep(arg1, arg2, arg3, arg4, insert)
end

-- ============================================================
-- TRAINER AUTOMATION
-- ============================================================

addon.skillList = {}
local spellRequest = {}
local trainerUpdate = 0

local function ProcessSpells(names, rank)
    if gameVersion > 90000 then return end
    local _, race = UnitRace("player")
    local level = UnitLevel("player")
    local entries = {race, addon.player.class}
    for _, entry in pairs(entries) do
        if addon.defaultSpellList and addon.defaultSpellList[entry] then
            for spellLvl, spells in pairs(addon.defaultSpellList[entry]) do
                if spellLvl <= level then
                    for i, spellId in ipairs(spells) do
                        if not spellRequest[spellId] then spellRequest[spellId] = true end
                        if names and rank then
                            spellRequest[spellId] = nil
                            local sName = GetSpellInfo(spellId)
                            local sRank = GetSpellSubtext(spellId)
                            for id, name in pairs(names) do
                                if sName == name and sRank == rank[id] then
                                    BuyTrainerService(id)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

local function OnTrainer()
    if not addon.settings.profile.enableTrainerAutomation then return end
    local i = GetNumTrainerServices()
    if not i or i == 0 or GetTime() - trainerUpdate > 15 then return end
    local names = {}
    local rank = {}
    for id = 1, i do
        local n, r, cat = GetTrainerServiceInfo(id)
        if cat == "available" then
            names[id] = n
            rank[id] = r
        end
    end
    ProcessSpells(names, rank)
    for spellName, spellRank in pairs(addon.skillList) do
        for id, name in pairs(names) do
            if name == spellName then
                local r = rank[id]
                r = r and tonumber(r:match("(%d+)")) or 0
                if (r <= spellRank or spellRank == 0) then
                    BuyTrainerService(id)
                    return
                end
            end
        end
    end
end

local tTimer = 0
local function trainerFrameUpdate(self, t)
    tTimer = tTimer + t
    if tTimer >= 0.2 then
        tTimer = 0
        if GetTime() - trainerUpdate > 15 then self:SetScript("OnUpdate", nil) end
        OnTrainer()
    end
end

addon.GossipGetNumOptions = GossipGetNumOptions

-- ============================================================
-- QUEST AUTOMATION HANDLER
-- ============================================================

function addon.QuestAutomation(event, arg1, arg2, arg3)
    local disabled
    if not addon.settings.profile.enableQuestAutomation or IsControlKeyDown() or addon.isHidden then
        disabled = true
    end

    if not event then
        if _G.GossipFrame and _G.GossipFrame:IsShown() then
            event = "GOSSIP_SHOW"
        elseif _G.QuestFrameGreetingPanel and _G.QuestFrameGreetingPanel:IsShown() then
            event = "QUEST_GREETING"
        elseif _G.QuestFrameProgressPanel and _G.QuestFrameProgressPanel:IsShown() then
            event = "QUEST_PROGRESS"
        elseif _G.QuestFrameDetailPanel and _G.QuestFrameDetailPanel:IsShown() then
            event = "QUEST_DETAIL"
        elseif _G.QuestFrameRewardPanel and _G.QuestFrameRewardPanel:IsShown() or
            _G.QuestFrameCompleteButton and _G.QuestFrameCompleteButton:IsShown() then
            event = "QUEST_COMPLETE"
        else
            return
        end
    end

    if event == "GOSSIP_SHOW" then
        local nActive = GossipGetNumActiveQuests()
        local nAvailable = GossipGetNumAvailableQuests()
        if not disabled then
            for i = 1, nActive do
                local title, isComplete
                title, _, _, isComplete = select(i * 6 - 5, GossipGetActiveQuests())
                local reward, isAutoTurnIn = addon.GetStepQuestReward(title)
                if isComplete and isAutoTurnIn then
                    return GossipSelectActiveQuest(i)
                end
            end
        end
        if GossipGetNumOptions() == 0 and nAvailable == 1 and nActive == 0 then
            return GossipSelectAvailableQuest(1)
        else
            for i = 1, nAvailable do
                local quest = select(i * 7 - 6, GossipGetAvailableQuests())
                if addon.QuestAutoAccept(quest) and not disabled then
                    return GossipSelectAvailableQuest(i)
                end
            end
        end
    elseif disabled then
        return
    elseif event == "QUEST_ACCEPT_CONFIRM" and addon.QuestAutoAccept(arg2) then
        ConfirmAcceptQuest()
    elseif event == "QUEST_COMPLETE" then
        local numChoices = GetNumQuestChoices()
        if numChoices <= 1 then
            GetQuestReward(1)
            addon:SendEvent("RXP_QUEST_TURNIN", GetQuestID(), numChoices, 1)
            return
        end
        local hardCodedReward = addon.GetStepQuestReward(GetQuestID())
        if hardCodedReward > 0 and addon.settings.profile.enableQuestRewardAutomation then
            GetQuestReward(hardCodedReward)
            addon:SendEvent("RXP_QUEST_TURNIN", GetQuestID(), numChoices, hardCodedReward)
            return
        end
    elseif event == "QUEST_PROGRESS" then
        local id = GetQuestID()
        if id and addon.disabledQuests[id] then return end
        if IsQuestCompletable() then
            CompleteQuest()
        elseif addon.QuestAutoAccept(id) then
            HideUIPanel(_G.QuestFrame)
        end
    elseif event == "QUEST_DETAIL" then
        local id = GetQuestID()
        if id and addon.disabledQuests[id] then return end
        if addon.QuestAutoAccept(id) then
            AcceptQuest()
            HideUIPanel(_G.QuestFrame)
        end
    elseif event == "QUEST_ACCEPTED" then
        local id = arg1 and arg2 or arg1
        if (id == GetQuestID() or addon.QuestAutoAccept(id)) and not addon.disabledQuests[id] then
            HideUIPanel(_G.QuestFrame)
        end
    elseif event == "QUEST_GREETING" then
        local nActive = GetNumActiveQuests()
        local nAvailable = GetNumAvailableQuests()
        local title, isComplete
        for i = 1, nActive do
            title, isComplete = GetActiveTitle(i)
            local reward, exists = addon.GetStepQuestReward(title)
            if exists and isComplete then return SelectActiveQuest(i) end
        end
        if GossipGetNumOptions() == 0 and nAvailable == 1 and nActive == 0 then
            SelectAvailableQuest(1)
        else
            for i = 1, nAvailable do
                title, isComplete = GetAvailableTitle(i)
                if addon.QuestAutoAccept(title) then return SelectAvailableQuest(i) end
            end
        end
    elseif event == "QUEST_TURNED_IN" and addon.questTurnIn[arg1] then
        -- turnInTimer = GetTime()
    end
end

-- ============================================================
-- CHARACTER CHECK
-- ============================================================

function addon.IsNewCharacter()
    local n = 0
    local GetQuests = _G.GetQuestsCompleted
    for i in pairs(GetQuests()) do
        n = n + 1
        if n > 1 then return false end
    end
    if UnitXP("player") == 0 then return true end
end

-- ============================================================
-- METADATA TABLE
-- ============================================================

function addon:CreateMetaDataTable(wipe)
    if wipe or addon.release ~= RXPData.release or RXPData.cacheVersion ~= cacheVersion or not cacheVersion or addon.IsNewCharacter() or addon.settings.profile.preLoadData then
        RXPCData.guideMetaData = {}
        RXPCData.guideDisabled = {}
        local deleteIndexes = {}
        local insertItems = {}
        local guides = addon.db.profile.guides
        for key, v in pairs(guides) do
            local group, subgroup, name = key:match("^(.-)|([^|]*)|(.-)")
            local newgrp, newsubgrp = addon.GroupOverride(group, subgroup)
            if newgrp ~= group or newsubgrp ~= subgroup then
                local newkey = addon.BuildGuideKey(newgrp, newsubgrp, name)
                insertItems[newkey] = v
                table.insert(deleteIndexes, key)
            end
        end
        for i, v in pairs(insertItems) do guides[i] = v end
        for _, i in ipairs(deleteIndexes) do guides[i] = nil end
    end
    RXPData.guideMetaData = nil
    local guideMetaData = RXPCData.guideMetaData or {}
    RXPCData.guideMetaData = guideMetaData
    RXPCData.guideDisabled = RXPCData.guideDisabled or {}
    guideMetaData.dungeonGuides = guideMetaData.dungeonGuides or {}
    guideMetaData.enabledDungeons = guideMetaData.enabledDungeons or {}
    guideMetaData.enabledDungeons.Horde = guideMetaData.enabledDungeons.Horde or {}
    guideMetaData.enabledDungeons.Alliance = guideMetaData.enabledDungeons.Alliance or {}
    guideMetaData.enableGroupQuests = guideMetaData.enableGroupQuests or {}
    guideMetaData.multibox = guideMetaData.multibox or {}
    guideMetaData.professionGuides = guideMetaData.professionGuides or {}
    guideMetaData.enabledProfessions = guideMetaData.enabledProfessions or {}
    guideMetaData.enabledProfessions.Horde = guideMetaData.enabledProfessions.Horde or {}
    guideMetaData.enabledProfessions.Alliance = guideMetaData.enabledProfessions.Alliance or {}
end

-- ============================================================
-- GUIDE LOADING CACHE
-- ============================================================

local updateFrame = CreateFrame("Frame")
local currentGuideGroup, currentGuideName, startStep

local function LoadCache(guide)
    if updateFrame:GetScript("OnUpdate") then return end
    updateFrame:SetScript("OnUpdate", function(self)
        if busy == GetTime() then return end
        local start = debugprofilestop()
        if not guide then
            local empty = not addon.currentGuide or addon.currentGuide.empty
            if currentGuideGroup and empty then
                local g = addon.GetGuideTable(currentGuideGroup, currentGuideName)
                if g then
                    RXPCData.currentStep = startStep
                    addon:LoadGuide(g, true)
                    currentGuideGroup = nil
                    currentGuideName = nil
                    return
                end
            end
        end
        if #addon.embeddedGuides ~= 0 then
            if addon.player.hardcore then
                while #addon.embeddedGuides > 0 and debugprofilestop() - start < 25 do
                    addon.LoadEmbeddedGuides(1)
                end
            else
                addon.LoadEmbeddedGuides()
            end
        else
            if guide then addon:FetchGuide(guide) end
            if currentGuideGroup then
                currentGuideGroup = nil
                currentGuideName = nil
                startStep = nil
                if addon.LoadDefaultGuide and (not addon.currentGuide or addon.currentGuide.empty) then
                    addon.LoadDefaultGuide()
                end
            end
            updateFrame:SetScript("OnUpdate", nil)
        end
    end)
end

-- ============================================================
-- INITIALIZATION
-- ============================================================

function addon:OnInitialize()
    local importGuidesDefault = { profile = {guides = {}, reports = {splits = {}}} }
    addon.db = LibStub("AceDB-3.0"):New("RXPDB", importGuidesDefault, 'global')
    RXPData = RXPData or {}
    RXPCData = RXPCData or {}
    RXPCData.exploredZones = RXPCData.exploredZones or {}

    local realm = _G.GetRealmName()
    RXPData.realmData = RXPData.realmData or {}
    local realmData = RXPData.realmData[realm] or {}
    RXPData.realmData[realm] = realmData
    addon.realmData = realmData

    RXPData.questNames = RXPData.questNames or {}
    RXPCData.questNameCache = RXPCData.questNameCache or {}
    if locale ~= RXPData.questNames['locale'] then
        RXPData.questNames = {}
        RXPData.questNames['locale'] = locale
        RXPCData.questNameCache = {}
    end
    RXPCData.questObjectivesCache = RXPCData.questObjectivesCache or {}
    RXPCData.questObjectivesCache[0] = RXPCData.questObjectivesCache[0] or 0

    if not RXPData.gameVersion then
        RXPData.gameVersion = gameVersion
    elseif math.floor(gameVersion / 1e4) ~= math.floor(RXPData.gameVersion / 1e4) then
        addon.db.profile.guides = {}
        RXPData.gameVersion = gameVersion
    end
    addon.settings:InitializeDatabase()
    addon.CreateMetaDataTable()
    addon.settings:InitializeSettings()

    RXPCData.completedWaypoints = RXPCData.completedWaypoints or {}
    addon.settings.profile.hardcore = false
    RXPCData.stepSkip = RXPCData.stepSkip or {}
    if not RXPCData.flightPaths or UnitLevel("player") <= 6 then
        RXPCData.flightPaths = {}
    end
    if RXPData.trainGenericSpells == nil then RXPData.trainGenericSpells = true end

    if _G.RXPOnInitialize then pcall(_G.RXPOnInitialize) end

    if addon.ui and addon.ui.v2 then addon.ui.v2:Initialize() end

    addon:ImportCustomThemes()
    addon:LoadActiveTheme()
    addon.settings:UpdateMinimapButton()
    addon.settings:SetupMapButton()
    addon.SetupGuideWindow()
    addon.RenderFrame()
    addon.SetupArrow()
    addon:CreateActiveItemFrame()
    
    addon.LoadCachedGuides()
    addon.UpdateGuideFontSize()
    addon.isHidden = not addon.settings.profile.showEnabled or addon.settings.profile.hideGuideWindow
    addon.RXPFrame:SetShown(not addon.isHidden)
    addon.RXPFrame:SetScale(addon.settings.profile.windowScale)
    addon.arrowFrame:SetSize(32 * addon.settings.profile.arrowScale, 32 * addon.settings.profile.arrowScale)
    addon.arrowFrame.text:SetFont(addon.font, addon.settings.profile.arrowText, "OUTLINE")
    addon.activeItemFrame:SetScale(addon.settings.profile.activeItemsScale)

    addon.v2:Setup()

    currentGuideGroup = RXPCData.currentGuideGroup
    currentGuideName = RXPCData.currentGuideName
    startStep = RXPCData.currentStep

    LoadCache()
    ProcessSpells()
    addon.GetProfessionLevel()

    if addon.settings.profile.preLoadData then addon.LoadAllGuides() end

    addon.ParseCompletedQuests()
end

-- ============================================================
-- ON ENABLE
-- ============================================================

function addon:OnEnable()
    addon.addonLoaded = true
-- Setup модулей (перенесено из OnInitialize)
    if addon.comms and addon.comms.Setup then addon.comms:Setup() end
    if addon.targeting and addon.targeting.Setup then addon.targeting:Setup() end
    if addon.talents and addon.talents.Setup then addon.talents:Setup() end
    if addon.settings.profile.enableTracker and addon.tracker and addon.tracker.SetupTracker then addon.tracker:SetupTracker() end
    if addon.tips and addon.tips.Setup then addon.tips:Setup() end

    addon.eventFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    addon.eventFrame:RegisterEvent("BAG_UPDATE_DELAYED")
    addon.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    addon.eventFrame:RegisterEvent("QUEST_TURNED_IN")
    addon.eventFrame:RegisterEvent("TRAINER_CLOSED")
    addon.eventFrame:RegisterEvent("TAXIMAP_OPENED")
    addon.eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
    addon.eventFrame:RegisterEvent("TRAINER_SHOW")
    addon.eventFrame:RegisterEvent("UNIT_PET")
    addon.eventFrame:RegisterEvent("PLAYER_CONTROL_LOST")
    addon.eventFrame:RegisterEvent("PLAYER_CONTROL_GAINED")
    addon.eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    addon.eventFrame:RegisterEvent("PLAYER_LEAVING_WORLD")
    addon.eventFrame:RegisterEvent("PLAYER_LOGOUT")
    addon.eventFrame:RegisterEvent("UI_INFO_MESSAGE")
    addon.eventFrame:RegisterEvent("ZONE_CHANGED")

    questFrame:RegisterEvent("QUEST_COMPLETE")
    questFrame:RegisterEvent("QUEST_PROGRESS")
    questFrame:RegisterEvent("QUEST_ACCEPT_CONFIRM")
    questFrame:RegisterEvent("QUEST_GREETING")
    questFrame:RegisterEvent("GOSSIP_SHOW")
    questFrame:RegisterEvent("QUEST_DETAIL")
    questFrame:RegisterEvent("QUEST_TURNED_IN")
    questFrame:RegisterEvent("QUEST_AUTOCOMPLETE")
    questFrame:RegisterEvent("QUEST_ACCEPTED")

    addon.settings:LoadFramePositions()

    if addon.settings.profile.hideInRaid then
        addon.eventFrame:RegisterEvent("GROUP_JOINED")
        addon.eventFrame:RegisterEvent("GROUP_FORMED")
        addon.eventFrame:RegisterEvent("GROUP_LEFT")
        addon.HideInRaid()
    end

    addon.tickers:SetupTickerLoops()

    RXPData.release = addon.release
    RXPData.cacheVersion = cacheVersion

    if addon.VendorTreasures then addon.VendorTreasures:Setup() end
    if addon.itemUpgrades then addon.itemUpgrades:Setup() end
end

-- ============================================================
-- EVENT HANDLERS
-- ============================================================

function addon:PLAYER_ENTERING_WORLD(_, isInitialLogin)
    addon.hideArrow = false
    addon.UpdateMap()
    addon.isHidden = addon.settings and addon.settings.profile.hideGuideWindow or not (addon.RXPFrame and addon.RXPFrame:IsShown())

    After(2, function()
        addon.player.maxlevel = maxLevel
        if addon.LoadDefaultGuide and (not addon.currentGuide or addon.currentGuide.empty) and not currentGuideGroup then
            addon.LoadDefaultGuide()
        end
    end)

    if isInitialLogin then
        After(4, function() addon.settings:DetectXPRate() end)
        After(20, function() addon.settings:CheckAddonCompatibility() end)
    end

    if addon.targeting and addon.targeting.Setup then
        addon.targeting:Setup()
    end
end

function addon:PLAYER_LEAVING_WORLD() addon.isHidden = true end
function addon:PLAYER_LOGOUT() addon.settings:SaveFramePositions() end
function addon:CALENDAR_UPDATE_EVENT_LIST() addon.calendarLoaded = true end

addon.explorationText = _G.ERR_ZONE_EXPLORED and _G.ERR_ZONE_EXPLORED:gsub("1%$", ""):gsub("2%$", ""):gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)") or "Discovered .+"
function addon:UI_INFO_MESSAGE(_, arg1, arg2)
    if not arg1 or arg1 ~= 408 then return end
    local subzoneExplored = arg2 and arg2:match(addon.explorationText)
    if subzoneExplored then print("Explored:", subzoneExplored) end
end

function addon:GET_ITEM_INFO_RECEIVED(_, itemNumber, success)
    if not success then return end
    if addon.itemQueryList[itemNumber] then
        addon.itemQueryList[itemNumber] = nil
        addon.updateStepText = true
    elseif GetTime() - startTime < 15 then
        addon.updateStepText = true
    end
end

function addon:ZONE_CHANGED() addon.UpdateMap() end
function addon:BAG_UPDATE_DELAYED(...) addon.UpdateItemFrame() end
function addon:PLAYER_REGEN_ENABLED(...) addon.UpdateItemFrame() end

function addon:QUEST_TURNED_IN(_, questId, xpReward)
    addon.recentTurnIn[questId] = GetTime()
    if questId == 10551 or questId == 10552 then
        addon:ScheduleTask(function() addon.ReloadGuide() end)
    end
end

function addon:SKILL_LINES_CHANGED(...) addon.UpdateSkillData() end

function addon:TRAINER_SHOW(...)
    trainerUpdate = GetTime()
    OnTrainer()
    if not addon.trainerFrame then addon.trainerFrame = CreateFrame("Frame", "RXPGuidesTrainerFrame", UIParent) end
    addon.trainerFrame:SetScript("OnUpdate", trainerFrameUpdate)
end

function addon:TRAINER_CLOSED(...) addon.trainerFrame:SetScript("OnUpdate", nil) end

function addon:PLAYER_LEVEL_UP(_, level)
    if not addon.currentGuide then return end
    ProcessSpells()
    addon.player.level = level
end

function addon:UNIT_PET(_, unit)
    if unit ~= "player" then return end
    addon.petFamily = GetPetIcon() or addon.petFamily
end

function addon:GROUP_LEFT()
    if not addon.settings.profile.hideInRaid then return end
    if not addon.settings.profile.showEnabled then return end
    for _, frame in pairs(addon.enabledFrames) do
        local shown, isSecure = frame.IsFeatureEnabled()
        if not (isSecure and InCombatLockdown()) then frame:SetShown(shown) end
    end
end

function addon.HideInRaid()
    if not addon.settings.profile.hideInRaid then return end
    if not UnitInRaid("player") then return end
    for _, frame in pairs(addon.enabledFrames) do
        if not frame:IsForbidden() then frame:Hide() end
    end
end

questFrame:SetScript("OnEvent", addon.QuestAutomation)

function addon.GetGuideTable(guideGroup, guideName)
    local index = guideGroup and guideName and fmt("%s||%s", guideGroup, guideName) or guideGroup or 0
    return addon.guides[index]
end

-- ============================================================
-- SCHEDULED TASKS
-- ============================================================

addon.scheduledTasks = {}

function addon.UpdateScheduledTasks()
    local cTime = GetTime()
    local processTable = {}
    for ref, args in pairs(addon.scheduledTasks) do processTable[ref] = args end
    for ref, args in pairs(processTable) do
        if type(ref) == "function" then
            if cTime > args[1] then
                local t = args
                addon.scheduledTasks[ref] = nil
                ref(unpack(t))
                return
            end
        elseif type(ref) == "table" then
            if cTime > args then
                addon.scheduledTasks[ref] = nil
                local element = ref.element or ref
                if element and addon.functions[element.tag] then
                    addon.Call(element.tag, addon.functions[element.tag], ref, "TaskUpdate")
                end
                return
            end
        end
    end
end

local function GetUpdateFrequency()
    local updateFrequency = 0.075
    if addon.settings.profile and addon.settings.profile.updateFrequency then
        updateFrequency = math.max(addon.settings.profile.updateFrequency / 1000, 0.005)
    end
    return updateFrequency
end

function addon.ScheduleTask(self, ref, ...)
    local updateFrequency = GetUpdateFrequency()
    local time = type(self) == "number" and self or GetTime() + updateFrequency
    if type(ref) == "table" then
        addon.scheduledTasks[ref] = time
    elseif type(ref) == "function" then
        local args = addon.scheduledTasks[ref]
        if args then args[1] = time
        elseif not args then addon.scheduledTasks[ref] = {time, ...} end
    end
end

-- ============================================================
-- UPDATE LOOP
-- ============================================================

addon.updateActiveQuest = {}
addon.updateInactiveQuest = {}

local stepCounter = 1
local batchSize = 5
local updateTimer = GetTime()
local skipframe = false
local skip = 0
local updateError
local errorCount = 0
local event = ""
local updateStepIndex = 0
local busy = 0

function addon.LegacyUpdateLoop()
    if updateError then errorCount = errorCount + 1 end
    local framerate = GetFramerate()
    local shouldContinue = addon.tickers:ShouldContinue()
    if not shouldContinue then return shouldContinue end
    if framerate <= addon.tickers.tickRate and skipframe then
        updateError = false
        skipframe = false
        return
    end
    skipframe = true
    updateError = true
    local guideLoaded
    local activeQuestUpdate = 0
    skip = skip + 1
    local cycle2 = skip % 2
    event = ""
    local start = debugprofilestop()

    if not addon.loadNextStep then
        for ref, func in pairs(addon.updateActiveQuest) do
            addon.Call("updateQuest", func, ref)
            activeQuestUpdate = activeQuestUpdate + 1
            addon.updateActiveQuest[ref] = nil
        end
        if activeQuestUpdate > 0 then event = event .. "/activeQ" end
    end

    if addon.nextStep then
        skip = 1
        addon.SetStep(addon.nextStep)
        addon.questAutoAccept = true
        addon.updateBottomFrame = true
        addon.nextStep = false
    elseif addon.loadNextStep then
        event = event .. "/loadNext"
        addon.loadNextStep = false
        addon.SetStep(RXPCData.currentStep + 1)
        addon.questAutoAccept = true
        skip = 1
        addon.updateBottomFrame = true
    elseif activeQuestUpdate == 0 then
        if addon.updateSteps then
            event = event .. "/stepComplete"
            addon.UpdateStepCompletion()
        elseif addon.updateStepText and addon.currentGuide and cycle2 == 0 then
            event = event .. "/textsingle"
            addon.updateStepText = false
            local updateText
            local steps = addon.currentGuide.steps
            local update = {}
for n in pairs(addon.stepUpdateList or {}) do tinsert(update, n) end
            for _, n in pairs(update) do
                if steps[n] then
                    if not updateText and steps[n].active then updateText = true end
                    addon.RXPFrame.BottomFrame.UpdateFrame(nil, n)
                    if not addon.updateStepText then addon.stepUpdateList[n] = nil end
                end
            end
            if updateText or addon.updateTipWindow then
                addon.updateTipWindow = false
                addon.RXPFrame.CurrentStepFrame.UpdateText()
            end
        elseif addon.updateBottomFrame then
            event = event .. "/bottomFrame"
            errorCount = 0
            addon.RXPFrame.BottomFrame.UpdateFrame()
            addon.RXPFrame.SetStepFrameAnchor()
            updateError = false
            skip = 1
            return 'bottomFrame'
        elseif cycle2 == 1 and next(addon.guideCache) then
            event = event .. "/cache"
            local loadGuide = true
            for _, guide in pairs(addon.guides) do
                if (loadGuide or guide.disablecaching) and not guide.steps then
                    if addon.player.hardcore then
                        LoadCache(guide)
                        loadGuide = false
                    else
                        addon:FetchGuide(guide)
                        guideLoaded = true
                        local elapsed = debugprofilestop() - start
                        if elapsed > 20 or framerate < 50 then loadGuide = false end
                    end
                end
            end
            if not next(addon.guideCache) and RXPCData.guideMetaData.enabledDungeons then
                RXPCData.guideMetaData.enabledDungeons[addon.player.faction] = addon.dungeons or RXPCData.guideMetaData.enabledDungeons[addon.player.faction]
            end
        end
    end

    local cycle4 = skip % 4
    local cycle16 = skip % 16
    local cycle32 = skip % 32

    if cycle4 == 0 then addon.tickers.CycleZero()
    elseif cycle4 == 2 then addon.tickers.CycleThree()
    elseif cycle4 == 3 then addon.tickers.CycleFour()
    elseif cycle16 == 1 then addon.tickers.CycleSixteen()
    elseif cycle32 == 29 then addon.tickers.CycleThirty()
    elseif skip ~= 1 and not guideLoaded and addon.currentGuide then
        event = event .. "/istep"
        local max = #addon.currentGuide.steps
        if stepCounter == RXPCData.currentStep then stepCounter = stepCounter + 4 end
        local batchMax = 10
        if (addon.settings.profile.updateFrequency or 0) > 75 then batchMax = 2 end
        if updateStepIndex < 5 then
            addon.RXPFrame.BottomFrame.UpdateFrame(nil, RXPCData.currentStep + updateStepIndex)
        end
        stepCounter = stepCounter + batchSize
        for n = stepCounter, stepCounter + batchSize do
            if n <= max then
                local delayed = n
                local f = CreateFrame("Frame")
                local elapsed = 0
                f:SetScript("OnUpdate", function(self, delta)
                    elapsed = elapsed + delta
                    if elapsed >= 0 then
                        self:SetScript("OnUpdate", nil)
                        addon.RXPFrame.BottomFrame.UpdateFrame(nil, delayed)
                    end
                end)
            end
        end
        updateStepIndex = (updateStepIndex + 1) % 8
        if stepCounter > max then
            stepCounter = 1
            local time = GetTime()
            local tdiff = time - updateTimer
            if tdiff > 10 then
                batchSize = math.min(batchSize + 1 * (math.ceil(tdiff / 8)), batchMax)
            elseif batchSize > 2 then
                batchSize = batchSize - 1
            end
            updateTimer = time
            skip = skip % 4096
        end
    end
    updateError = false
end

-- ============================================================
-- TICKERS
-- ============================================================

addon.tickers = {}
function addon.tickers:SetupTickerLoops()
    local updateFrequency = GetUpdateFrequency()
    self.tickRate = 1 / updateFrequency
    if not self.legacy then self.legacy = NewTicker(updateFrequency, addon.LegacyUpdateLoop) end
end

function addon.tickers:ShouldContinue(ticker)
    if addon.isHidden then updateError = false return false, 'hidden' end
    if errorCount >= 10 then
        addon.lastEvent = event
        errorCount = 0
        updateError = false
        return false, 'error'
    end
    local gt = GetTime()
    if ticker and busy == gt then
        busy = gt
        local f = CreateFrame("Frame")
        local elapsed = 0
        f:SetScript("OnUpdate", function(self, delta)
            elapsed = elapsed + delta
            if elapsed >= 0.01 then
                self:SetScript("OnUpdate", nil)
                ticker()
            end
        end)
        return false, 'busy'
    end
    busy = gt
    return true
end

function addon.tickers.CycleZero() event = event .. "/goto"; addon.UpdateGotoSteps() end
function addon.tickers.CycleThree()
    if addon.questAutoAccept then
        addon.questAutoAccept = false
        event = event .. "/auto"
        addon.QuestAutomation()
    end
    if addon.updateMap then
        event = event .. "/map"
        addon.UpdateMap(true)
    end
end
function addon.tickers.CycleFour()
    if addon.ProcessMessageQueue() then return end
    event = event .. "/task"
    addon.UpdateScheduledTasks()
    addon.ClearQuestCache()
end
function addon.tickers.CycleSixteen()
    event = event .. "/inactiveQ"
    local activeQuestUpdate = 0
    local deletedIndexes = {}
    local element
    for i, ref in ipairs(addon.updateInactiveQuest) do
        activeQuestUpdate = activeQuestUpdate + 1
        if activeQuestUpdate > 3 then break
        else addon.UpdateQuestCompletionData(ref); tinsert(deletedIndexes, i) end
    end
    for i = #deletedIndexes, 1, -1 do
        element = deletedIndexes[i]
        table.remove(addon.updateInactiveQuest, element)
    end
end
function addon.tickers.CycleThirty()
    event = event .. "/toptext"
    addon.RXPFrame.CurrentStepFrame.UpdateText()
end

-- ============================================================
-- STEP LOGIC
-- ============================================================

function addon.HardcoreToggle() return end

function addon.GAToggle()
    if RXPCData and addon.farmGuides > 0 then
        RXPCData.GA = not RXPCData.GA
        addon.RenderFrame()
    else
        RXPCData.GA = false
        addon.RenderFrame()
    end
end

-- 3.3.5: GetFactionInfoByID не существует, используем GetFactionInfo
if not addon.GetFactionInfoByID then
    addon.GetFactionInfoByID = function(factionID)
        -- В 3.3.5 нет прямого API для получения репутации по ID
        -- Возвращаем nil, чтобы AldorScryerCheck вернул true по умолчанию
        return nil
    end
end

addon.stepLogic = {}

function addon.stepLogic.AldorScryerCheck(faction)
    if addon.game == "CLASSIC" then return true end
    local _, _, _, _, _, aldorRep = addon.GetFactionInfoByID(932)
    local _, _, _, _, _, scryerRep = addon.GetFactionInfoByID(934)
    if aldorRep and scryerRep then
        if type(faction) == "table" then
            if faction.aldor then faction = "Aldor"
            elseif faction.scryer then faction = "Scryer" end
        end
        if faction == "Aldor" then return (aldorRep > scryerRep)
        elseif faction == "Scryer" then return (aldorRep < scryerRep) end
    end
    return true
end

function addon.stepLogic.PhaseCheck(phase)
    if type(phase) == "table" then phase = phase.phase end
    local currentPhase = addon.settings.profile.phase or 6
    if phase and currentPhase then
        local pmin, pmax
        pmin, pmax = phase:match("(%d+)%-(%d+)")
        if pmax then pmin = tonumber(pmin); pmax = tonumber(pmax)
        else pmin = tonumber(phase); pmax = 0xffff end
        if pmin and currentPhase >= pmin and currentPhase <= pmax then return true else return false end
    end
    return true
end

function addon.stepLogic.DailyCheck(step) return not (step.daily and RXPCData.skipDailies) end

function addon.IsStepShown(step, ...)
    local isShown = true
    local ignoreEntry = {}
    for _, entry in pairs({...}) do ignoreEntry[entry] = true end
    for name, check in pairs(addon.stepLogic) do
        if not ignoreEntry[name] then isShown = isShown and check(step) end
    end
    return isShown
end

function addon.stepLogic.GroupCheck(step)
    if (not addon.settings.profile.enableGroupQuests and step.group) or (addon.settings.profile.enableGroupQuests and step.solo) then return false end
    return true
end

function addon.stepLogic.AHCheck(step)
    if (not addon.settings.profile.soloSelfFound and step.ssf) or (addon.settings.profile.soloSelfFound and step.ah) then return false end
    return true
end

function addon.stepLogic.LoremasterCheck(step)
    local loremaster
    if addon.gameVersion < 50000 then
        loremaster = addon.game == "WOTLK" and addon.settings.profile.northrendLM or addon.game == "CATA" and addon.settings.profile.loremasterMode
    end
    if step.questguide and not loremaster or step.speedrunguide and loremaster then return false end
    return true
end

function addon.stepLogic.SeasonCheck(step)
    local currentSeason = addon.settings.profile.season or 0
    local SoM = currentSeason == 1
    if SoM and step.era or step.som and not SoM or SoM and addon.settings.profile.phase > 2 and step["era/som"] then return false end
    if step.season then
        for season in step.season:gmatch("[^,;%s]+") do
            if currentSeason == tonumber(season) then return true end
        end
        return false
    end
    return true
end

function addon.stepLogic.HardcoreCheck(step) return true end

function addon.stepLogic.XpRateCheck(step)
    if step.xprate then
        local rate = addon.settings.profile.xprate or 1
        if addon.game == "CLASSIC" then
            rate = 1
            if addon.settings.profile.season == 1 then
                if addon.settings.profile.phase < 3 then rate = 1.2 else rate = 1.5 end
            end
        end
        local xpmin, xpmax = 1, 0xfff
        step.xprate:gsub("^([<>]?)%s*(%d+%.?%d*)%-?(%d*%.?%d*)",
            function(op, arg1, arg2)
                if op == "<" then xpmin = 0; xpmax = tonumber(arg1) - 1e-4
                elseif op == ">" then xpmin = tonumber(arg1) + 1e-4; xpmax = 0xfff
                else xpmin = tonumber(arg1) or xpmin; xpmax = tonumber(arg2) or 0xfff end
            end)
        if rate < xpmin or rate > xpmax then return false end
    end
    return true
end

function addon.IsFreshAccount() return false end

function addon.stepLogic.FreshAccountCheck(step)
    local level = UnitLevel("player")
    local maxLevelFresh = step.fresh and tonumber(step.fresh) or 1000
    local maxLevelVeteran = step.veteran and tonumber(step.veteran) or 1000
    local fresh = addon.IsFreshAccount()
    if not (step.fresh or step.veteran) then return true
    elseif (step.fresh and level <= maxLevelFresh) and fresh then return true
    elseif (step.veteran and level <= maxLevelVeteran) and not fresh then return true end
    return false
end

function addon.stepLogic.LevelCheck(step)
    if not addon.settings.profile.enableXpStepSkipping then return true end
    local level = UnitLevel("player")
    local maxLevel = tonumber(step.maxlevel) or 1000
    if level <= maxLevel then return true end
end

function addon.stepLogic.DungeonCheck(step)
    if step.disabled then return false end
    local dungeon = step.dungeon
    local dskip = step.dungeonskip
    if dskip and addon.settings.profile.dungeons[dskip] then return false
    elseif dungeon and dungeon ~= dskip and addon.settings.profile.dungeons[dungeon] then return true
    elseif not dungeon then return true end
end

function addon.stepLogic.ProfessionCheck(step)
    local profession = step.profession
    local pskip = step.professionskip
    if not addon.settings.profile.professions then return true
    elseif pskip and addon.settings.profile.professions == pskip then return false
    elseif profession and profession ~= pskip and addon.settings.profile.professions == profession then return true
    elseif not profession then return true end
end

-- ============================================================
-- V2 EVENTS
-- ============================================================

RXP = addon

addon.v2 = addon.v2 or {}
function addon.v2:Setup() addon.v2.events:Setup() end

addon.v2.events = addon.v2.events or {}
-- AceAddon-3.0 NewModule replacement for 3.3.5
setmetatable(addon.v2.events, {__index = addon})
addon.v2.events.messagePrefix = "RXPGuidesV2_"

function addon.v2.events:Setup()
    addon.v2.events:Register("UpdateActiveSteps")
    addon.v2.events:Register("QuestDataLoaded")
end

function addon.v2.events:Register(key)
    if not key then return end
    -- Simple message registration without AceEvent
    if not addon.v2.messageHandlers then addon.v2.messageHandlers = {} end
    addon.v2.messageHandlers[key] = addon.v2.messageHandlers[key] or {}
end

function addon.v2.events:Trigger(key, ...)
    if not key then return end
    -- Simple message trigger without AceEvent
    if addon.v2.messageHandlers and addon.v2.messageHandlers[key] then
        for _, handler in pairs(addon.v2.messageHandlers[key]) do
            if type(handler) == "function" then
                handler(...)
            end
        end
    end
end

function addon.v2.events:UpdateActiveSteps(_, activeSteps, name)
    if name == addon.player.name then
        addon.v2:UpdateActiveStepsFrame(activeSteps)
        return
    end
    addon.v2:UpdateActivePartyStepsFrame(activeSteps, name)
end

function addon.v2.events:QuestDataLoaded(_, questId)
    if not questId then
        addon.v2.state.activeStepRenderRevision = (addon.v2.state.activeStepRenderRevision or 0) + 1
    end
    if addon.RXPFrame.activeSteps then
        addon.v2:UpdateActiveStepsFrame(addon.RXPFrame.activeSteps, questId)
    end
end

-- ============================================================
-- INIT HOOK (для 3.3.5 без AceAddon)
-- ============================================================

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        if addon.OnInitialize then
            addon:OnInitialize()
        end
        if addon.OnEnable then
            addon:OnEnable()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        if addon.PLAYER_ENTERING_WORLD then
            addon:PLAYER_ENTERING_WORLD(self, ...)
        end
    end
end)
