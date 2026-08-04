local addonName, addon = ...

-- ============================================================
-- 3.3.5 QUEST LOG COMPATIBILITY
-- Замена C_QuestLog на глобальные функции 3.3.5
-- ============================================================

local GetNumQuestLogEntries = _G.GetNumQuestLogEntries
local GetQuestLogTitle = _G.GetQuestLogTitle
local GetQuestLogSelection = _G.GetQuestLogSelection
local SelectQuestLogEntry = _G.SelectQuestLogEntry
local GetQuestLogLeaderBoard = _G.GetQuestLogLeaderBoard
local GetNumQuestLeaderBoards = _G.GetNumQuestLeaderBoards
local GetQuestLogTimeLeft = _G.GetQuestLogTimeLeft
local IsQuestWatched = _G.IsQuestWatched
local AddQuestWatch = _G.AddQuestWatch
local RemoveQuestWatch = _G.RemoveQuestWatch
local GetQuestIndexForWatch = _G.GetQuestIndexForWatch
local GetNumQuestWatches = _G.GetNumQuestWatches
local GetQuestLogQuestText = _G.GetQuestLogQuestText
local GetQuestLogRequiredMoney = _G.GetQuestLogRequiredMoney
local GetNumQuestLogRewards = _G.GetNumQuestLogRewards
local GetNumQuestLogChoices = _G.GetNumQuestLogChoices
local GetQuestLogRewardInfo = _G.GetQuestLogRewardInfo
local GetQuestLogChoiceInfo = _G.GetQuestLogChoiceInfo
local GetQuestLogRewardMoney = _G.GetQuestLogRewardMoney
local GetQuestLogRewardXP = _G.GetQuestLogRewardXP
local GetQuestLogRewardSpell = _G.GetQuestLogRewardSpell
local GetQuestLogRewardTitle = _G.GetQuestLogRewardTitle
local GetQuestLogRewardTalents = _G.GetQuestLogRewardTalents
local GetQuestLogIsAutoComplete = _G.GetQuestLogIsAutoComplete
local GetQuestLogCompletionText = _G.GetQuestLogCompletionText
local GetQuestLogPushable = _G.GetQuestLogPushable
local GetQuestLogGroupNum = _G.GetQuestLogGroupNum
local QuestLogPushQuest = _G.QuestLogPushQuest
local AbandonQuest = _G.AbandonQuest
local SetAbandonQuest = _G.SetAbandonQuest
local GetAbandonQuestName = _G.GetAbandonQuestName
local GetAbandonQuestItems = _G.GetAbandonQuestItems
local IsUnitOnQuest = _G.IsUnitOnQuest
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor

-- В 3.3.5 GetQuestIDFromLogIndex НЕ СУЩЕСТВУЕТ
local GetQuestIDFromLogIndex = _G.GetQuestIDFromLogIndex or function(questIndex) return nil end

-- ============================================================
-- C_QuestLog эмуляция
-- ============================================================

addon.QuestLog = {}

function addon.QuestLog.GetNumQuestLogEntries()
    return GetNumQuestLogEntries()
end

function addon.QuestLog.GetQuestLogTitle(questIndex)
    return GetQuestLogTitle(questIndex)
end

function addon.QuestLog.GetQuestLogLeaderBoard(i, questIndex)
    return GetQuestLogLeaderBoard(i, questIndex)
end

function addon.QuestLog.GetNumQuestLeaderBoards(questIndex)
    return GetNumQuestLeaderBoards(questIndex)
end

function addon.QuestLog.IsQuestWatched(questIndex)
    return IsQuestWatched(questIndex)
end

function addon.QuestLog.AddQuestWatch(questIndex)
    return AddQuestWatch(questIndex)
end

function addon.QuestLog.RemoveQuestWatch(questIndex)
    return RemoveQuestWatch(questIndex)
end

function addon.QuestLog.GetNumQuestWatches()
    return GetNumQuestWatches()
end

function addon.QuestLog.GetQuestIndexForWatch(watchIndex)
    return GetQuestIndexForWatch(watchIndex)
end

function addon.QuestLog.GetQuestLogQuestText(questIndex)
    return GetQuestLogQuestText(questIndex)
end

function addon.QuestLog.GetQuestLogRequiredMoney(questIndex)
    return GetQuestLogRequiredMoney(questIndex)
end

function addon.QuestLog.GetNumQuestLogRewards(questIndex)
    return GetNumQuestLogRewards(questIndex)
end

function addon.QuestLog.GetNumQuestLogChoices(questIndex)
    return GetNumQuestLogChoices(questIndex)
end

function addon.QuestLog.GetQuestLogRewardInfo(i, questIndex)
    return GetQuestLogRewardInfo(i, questIndex)
end

function addon.QuestLog.GetQuestLogChoiceInfo(i, questIndex)
    return GetQuestLogChoiceInfo(i, questIndex)
end

function addon.QuestLog.GetQuestLogRewardMoney(questIndex)
    return GetQuestLogRewardMoney(questIndex)
end

function addon.QuestLog.GetQuestLogRewardXP(questIndex)
    return GetQuestLogRewardXP(questIndex)
end

function addon.QuestLog.GetQuestLogRewardSpell(questIndex)
    return GetQuestLogRewardSpell(questIndex)
end

function addon.QuestLog.GetQuestLogRewardTitle(questIndex)
    return GetQuestLogRewardTitle(questIndex)
end

function addon.QuestLog.GetQuestLogRewardTalents(questIndex)
    return GetQuestLogRewardTalents(questIndex)
end

function addon.QuestLog.GetQuestLogIsAutoComplete(questIndex)
    return GetQuestLogIsAutoComplete(questIndex)
end

function addon.QuestLog.GetQuestLogCompletionText(questIndex)
    return GetQuestLogCompletionText(questIndex)
end

function addon.QuestLog.GetQuestLogPushable(questIndex)
    return GetQuestLogPushable(questIndex)
end

function addon.QuestLog.GetQuestLogGroupNum(questIndex)
    return GetQuestLogGroupNum(questIndex)
end

function addon.QuestLog.QuestLogPushQuest(questIndex)
    return QuestLogPushQuest(questIndex)
end

function addon.QuestLog.AbandonQuest()
    return AbandonQuest()
end

function addon.QuestLog.SetAbandonQuest()
    return SetAbandonQuest()
end

function addon.QuestLog.GetAbandonQuestName()
    return GetAbandonQuestName()
end

function addon.QuestLog.GetAbandonQuestItems()
    return GetAbandonQuestItems()
end

function addon.QuestLog.IsUnitOnQuest(unit, questIndex)
    return IsUnitOnQuest(unit, questIndex)
end

function addon.QuestLog.GetQuestDifficultyColor(level)
    return GetQuestDifficultyColor(level)
end

function addon.QuestLog.GetQuestLogIndexByID(questID)
    return addon.GetQuestLogIndexByID(questID)
end

function addon.QuestLog.GetQuestIDFromLogIndex(questIndex)
    return GetQuestIDFromLogIndex(questIndex)
end

-- ============================================================
-- QUEST CACHE (для обратной совместимости)
-- В 3.3.5 GetQuestLogTitle НЕ возвращает questID,
-- поэтому кэш заполняется через GetQuestLogIndexByID
-- ============================================================

addon.questCache = {}
addon.questLogCache = {}
addon.questLogIndexCache = {}
addon.questAccept = addon.questAccept or {}
addon.questTurnIn = addon.questTurnIn or {}
addon.previousQuestLogState = addon.previousQuestLogState or {}

addon.previousQuestLogState = addon.previousQuestLogState or {}

addon.questAccept = addon.questAccept or {}
addon.questTurnIn = addon.questTurnIn or {}

function addon.UpdateQuestLogCache()
    table.wipe(addon.questLogCache)
    table.wipe(addon.questLogIndexCache)

    local numEntries, numQuests = GetNumQuestLogEntries()
    for i = 1, numEntries do
        local questTitle, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(i)
        if not isHeader then
            -- В 3.3.5 GetQuestLogTitle не возвращает questID
            -- Используем имя квеста как ключ для обратной совместимости
            addon.questLogCache[questTitle] = {
                index = i,
                title = questTitle,
                level = level,
                tag = questTag,
                group = suggestedGroup,
                complete = isComplete,
                daily = isDaily,
            }
        end
    end
end

-- ИСПРАВЛЕНО: Используем прямой вызов GetQuestLogIndexByID
function addon.GetQuestLogIndexByID(questID)
    if not questID then return nil end
    local numEntries = GetNumQuestLogEntries()
    for i = 1, numEntries do
        local link = GetQuestLink(i)
        if link then
            local id = tonumber(link:match("quest:(%d+)"))
            if id == questID then
                return i
            end
        end
    end
    return nil
end

-- ИСПРАВЛЕНО: Прямая проверка через GetQuestLogIndexByID
function addon.IsQuestInLog(questID)
    if not questID then return false end
    local index = addon.GetQuestLogIndexByID(questID)
    return index and index > 0
end

-- ИСПРАВЛЕНО: Получаем info через GetQuestLogIndexByID + GetQuestLogTitle
function addon.GetQuestLogInfo(questID)
    if not questID then return nil end
    local index = addon.GetQuestLogIndexByID(questID)
    if not index or index == 0 then return nil end

    local questTitle, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(index)
    if isHeader then return nil end

    return {
        index = index,
        title = questTitle,
        level = level,
        tag = questTag,
        group = suggestedGroup,
        complete = isComplete,
        daily = isDaily,
    }
end

-- ============================================================
-- QUEST OBJECTIVES
-- ============================================================

function addon.GetQuestObjectives(questID)
    if not questID then return nil end
    local questIndex = addon.GetQuestLogIndexByID(questID)
    if not questIndex or questIndex == 0 then return nil end

    local objectives = {}
    local numObjectives = GetNumQuestLeaderBoards(questIndex)

    for i = 1, numObjectives do
        local text, type, finished = GetQuestLogLeaderBoard(i, questIndex)
        table.insert(objectives, {
            text = text,
            type = type,
            finished = finished,
        })
    end

    return objectives
end

function addon.IsQuestObjectiveComplete(questID, objectiveIndex)
    local objectives = addon.GetQuestObjectives(questID)
    if not objectives or not objectives[objectiveIndex] then return false end
    return objectives[objectiveIndex].finished
end

function addon.IsQuestComplete(questID)
    local info = addon.GetQuestLogInfo(questID)
    if not info then return false end
    return info.complete == 1
end

-- ============================================================
-- QUEST WATCHING
-- ============================================================

addon.watchedQuests = {}

function addon.UpdateWatchedQuests()
    table.wipe(addon.watchedQuests)
    local numWatches = GetNumQuestWatches()
    for i = 1, numWatches do
        local questIndex = GetQuestIndexForWatch(i)
        if questIndex then
            -- В 3.3.5 нет GetQuestIDFromLogIndex, используем GetQuestLogTitle
            local questTitle = GetQuestLogTitle(questIndex)
            if questTitle then
                addon.watchedQuests[questTitle] = true
            end
        end
    end
end

function addon.IsQuestWatchedByID(questID)
    addon.UpdateWatchedQuests()
    local info = addon.GetQuestLogInfo(questID)
    if info and info.title then
        return addon.watchedQuests[info.title] == true
    end
    return false
end

function addon.WatchQuestByID(questID)
    local questIndex = addon.GetQuestLogIndexByID(questID)
    if questIndex and questIndex > 0 and not IsQuestWatched(questIndex) then
        AddQuestWatch(questIndex)
    end
end

function addon.UnwatchQuestByID(questID)
    local questIndex = addon.GetQuestLogIndexByID(questID)
    if questIndex and questIndex > 0 and IsQuestWatched(questIndex) then
        RemoveQuestWatch(questIndex)
    end
end

-- ============================================================
-- QUEST TRACKING FOR GUIDE
-- ============================================================

addon.trackedQuests = {}
addon.completedQuests = {}

-- В 3.3.5 GetQuestsCompleted НЕ СУЩЕСТВУЕТ
-- Используем альтернативу: квест считается выполненным, если его нет в журнале
-- и он был отмечен как взятый (questAccept)
function addon.ParseCompletedQuests()
    -- В 3.3.5 нет GetQuestsCompleted
    -- Оставляем пустым для совместимости
end

function addon.IsQuestCompleted(questID)
    -- Квест считается выполненным, если:
    -- 1. Он был взят (questAccept[questID]) и теперь его нет в журнале
    -- 2. Или он в журнале и помечен как complete
    if addon.questAccept[questID] and not addon.IsQuestInLog(questID) then
        return true
    end
    if addon.IsQuestComplete(questID) then
        return true
    end
    return addon.completedQuests[questID] == true
end

function addon.TrackQuestForGuide(questID, element)
    if not questID then return end
    addon.trackedQuests[questID] = addon.trackedQuests[questID] or {}
    table.insert(addon.trackedQuests[questID], element)
end

function addon.UntrackQuestForGuide(questID, element)
    if not questID or not addon.trackedQuests[questID] then return end
    for i, e in ipairs(addon.trackedQuests[questID]) do
        if e == element then
            table.remove(addon.trackedQuests[questID], i)
            break
        end
    end
end

function addon.UpdateTrackedQuests()
    addon.UpdateQuestLogCache()
    for questID, elements in pairs(addon.trackedQuests) do
        local info = addon.GetQuestLogInfo(questID)
        local isComplete = addon.IsQuestComplete(questID)
        local inLog = addon.IsQuestInLog(questID)

        for _, element in ipairs(elements) do
            if element.step and element.step.active then
                if isComplete then
                    element.questFinished = true
                elseif info then
                    element.questFinished = false
                    -- Обновляем прогресс objectives
                    local objectives = addon.GetQuestObjectives(questID)
                    if objectives then
                        element.objectives = objectives
                    end
                end
                addon.updateStepText = true
            end
        end
    end
end

-- ============================================================
-- QUEST REWARDS (для ItemUpgrades)
-- ============================================================

function addon.GetQuestRewardChoices(questID)
    local questIndex = addon.GetQuestLogIndexByID(questID)
    if not questIndex or questIndex == 0 then return {} end

    local choices = {}
    local numChoices = GetNumQuestLogChoices(questIndex)

    for i = 1, numChoices do
        local name, texture, numItems, quality, isUsable = GetQuestLogChoiceInfo(i, questIndex)
        table.insert(choices, {
            index = i,
            name = name,
            texture = texture,
            numItems = numItems,
            quality = quality,
            isUsable = isUsable,
        })
    end

    return choices
end

function addon.GetQuestRewards(questID)
    local questIndex = addon.GetQuestLogIndexByID(questID)
    if not questIndex or questIndex == 0 then return {} end

    local rewards = {}
    local numRewards = GetNumQuestLogRewards(questIndex)

    for i = 1, numRewards do
        local name, texture, numItems, quality, isUsable = GetQuestLogRewardInfo(i, questIndex)
        table.insert(rewards, {
            index = i,
            name = name,
            texture = texture,
            numItems = numItems,
            quality = quality,
            isUsable = isUsable,
        })
    end

    return rewards
end

-- ============================================================
-- QUEST EVENTS HOOK
-- ============================================================

local questLogFrame = CreateFrame("Frame")
questLogFrame:RegisterEvent("QUEST_LOG_UPDATE")
questLogFrame:RegisterEvent("QUEST_WATCH_UPDATE")
questLogFrame:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
questLogFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "QUEST_LOG_UPDATE" or event == "QUEST_WATCH_UPDATE" then
        print("RXP DEBUG: EVENT " .. event .. " fired!")
        addon.UpdateQuestLogCache()
        addon.UpdateTrackedQuests()
        
        -- Проверяем отменённые квесты (abandon)
        for questID, _ in pairs(addon.questAccept) do
            local nowInLog = addon.IsQuestInLog(questID)
            local wasInLog = addon.previousQuestLogState[questID]
            if wasInLog and not nowInLog and not addon.questTurnIn[questID] then
                addon.OnQuestAbandoned(questID)
            end
            addon.previousQuestLogState[questID] = nowInLog
        end
        
        addon.updateStepText = true
        addon.updateSteps = true
    elseif event == "UNIT_QUEST_LOG_CHANGED" then
        local unit = ...
        if unit == "player" then
            addon.UpdateQuestLogCache()
            addon.UpdateTrackedQuests()
            addon.updateStepText = true
            addon.updateSteps = true
        end
    end
end)

-- ============================================================
-- QUEST UTILITY
-- ============================================================

function addon.GetQuestLevel(questID)
    local info = addon.GetQuestLogInfo(questID)
    if info then return info.level end
    return 0
end

function addon.GetQuestTag(questID)
    local info = addon.GetQuestLogInfo(questID)
    if info then return info.tag end
    return nil
end

function addon.IsDailyQuest(questID)
    local info = addon.GetQuestLogInfo(questID)
    if info then return info.daily end
    return false
end

function addon.GetQuestGroupSize(questID)
    local info = addon.GetQuestLogInfo(questID)
    if info then return info.group end
    return 0
end

function addon.GetQuestTitleByID(questID)
    local info = addon.GetQuestLogInfo(questID)
    if info then return info.title end
    -- Пробуем через кэш имен
    if RXPData and RXPData.questNames and RXPData.questNames[questID] then
        return RXPData.questNames[questID]
    end
    return nil
end

function addon.CacheQuestName(questID, name)
    if not RXPData then return end
    RXPData.questNames = RXPData.questNames or {}
    if name and name ~= "" then
        RXPData.questNames[questID] = name
    end
end


-- ============================================================
-- QUEST ABANDONED HANDLER
-- Возврат к предыдущему шагу при отмене квеста
-- ============================================================

function addon.OnQuestAbandoned(questID)
    if not questID then return end
    if not addon.currentGuide then return end

    -- Ищем шаг с .accept для этого квеста
    local targetStep = nil
    for i, step in ipairs(addon.currentGuide.steps or {}) do
        for _, element in ipairs(step.elements or {}) do
            if element.tag == "accept" and element.questId == questID then
                targetStep = i
                break
            end
        end
        if targetStep then break end
    end

    if not targetStep then return end

    local currentStep = RXPCData.currentStep or 1
    if targetStep > currentStep then return end

    -- Сбрасываем completed у шага с accept и всех последующих шагов
    for i = targetStep, #addon.currentGuide.steps do
        local step = addon.currentGuide.steps[i]
        if step then
            step.completed = false
            step.active = nil
            for _, element in ipairs(step.elements or {}) do
                element.completed = false
                element.skip = false
                if element.questId == questID then
                    element.questFinished = false
                    element.questReady = false
                end
            end
        end
    end

    -- Сбрасываем stepSkip для возвращённых шагов
    for i = targetStep, #addon.currentGuide.steps do
        RXPCData.stepSkip[i] = nil
    end

    -- Удаляем квест из отслеживаемых
    addon.questAccept[questID] = nil
    addon.questTurnIn[questID] = nil
    addon.previousQuestLogState[questID] = nil

    -- Форсированный режим — шаг ВСЕГДА добавится в activeSteps
    addon.forceStepLoad = true
    addon.SetStep(targetStep)

    -- Обновляем UI
    addon.updateBottomFrame = true
    if addon.RXPFrame and addon.RXPFrame.BottomFrame and addon.RXPFrame.BottomFrame.UpdateFrame then
        addon.RXPFrame.BottomFrame.UpdateFrame()
    end
    addon.UpdateCurrentTask()

    print(string.format("|cff33ff99RXP|r: Quest abandoned (ID: %d), returned to step %d", questID, targetStep))
end


-- ============================================================
-- QUEST ABANDONED HANDLER
-- ============================================================

function addon.OnQuestAbandoned(questID)
    if not questID then return end
    if not addon.currentGuide then return end
    
    local targetStep = nil
    for i, step in ipairs(addon.currentGuide.steps or {}) do
        for _, element in ipairs(step.elements or {}) do
            if element.tag == "accept" and element.questId == questID then
                targetStep = i
                break
            end
        end
        if targetStep then break end
    end
    
    if not targetStep then return end
    
    local currentStep = RXPCData.currentStep or 1
    if targetStep > currentStep then return end
    
    for i = targetStep, #addon.currentGuide.steps do
        local step = addon.currentGuide.steps[i]
        if step then
            step.completed = false
            step.active = nil
            for _, element in ipairs(step.elements or {}) do
                element.completed = false
                element.skip = false
            end
        end
    end
    
    for i = targetStep, #addon.currentGuide.steps do
        RXPCData.stepSkip[i] = nil
    end
    
    addon.questAccept[questID] = nil
    addon.questTurnIn[questID] = nil
    addon.previousQuestLogState[questID] = nil
    
    addon.forceStepLoad = true
    addon.SetStep(targetStep)
    
    addon.updateBottomFrame = true
    if addon.RXPFrame and addon.RXPFrame.BottomFrame and addon.RXPFrame.BottomFrame.UpdateFrame then
        addon.RXPFrame.BottomFrame.UpdateFrame()
    end
    addon.UpdateCurrentTask()
    
    print(string.format("|cff33ff99RXP|r: Quest abandoned (ID: %d), returned to step %d", questID, targetStep))
end
