--[[
    RXPGuides - Targeting Module
    Адаптировано для WoW 3.3.5 (WotLK)
    Автоматический таргетинг NPC, мобов и объектов для квестов
]]

local _, addon = ...
local RXP = addon.RXP or {}
addon.RXP = RXP

local Targeting = {}
RXP.Targeting = Targeting

-- Настройки
local SCAN_INTERVAL = 0.5       -- Интервал сканирования (сек)
local TARGET_TIMEOUT = 3        -- Таймаут попыток таргета (сек)
local MAX_SCAN_RANGE = 60       -- Максимальная дистанция сканирования (ярдов)

-- Состояние
local scanFrame
local targetQueue = {}          -- Очередь целей для таргетинга
local activeTarget = nil        -- Текущая активная цель
local targetAttempts = 0        -- Количество попыток
local lastScanTime = 0
local isScanning = false

-- Таблица приоритетов таргетинга
local targetPriorities = {
    ["quest_npc"] = 1,        -- Квестовые NPC (высший приоритет)
    ["quest_mob"] = 2,        -- Квестовые мобы
    ["rare"] = 3,             -- Редкие мобы
    ["vendor"] = 4,           -- Торговцы
    ["flight_master"] = 5,    -- Распорядители полётов
}

-- Инициализация
function Targeting:Init()
    -- Создаём фрейм для сканирования
    scanFrame = CreateFrame("Frame", "RXP_TargetScanFrame")
    scanFrame:Hide()

    -- Подписываемся на события
    if RXP.events then
        RXP.events:RegisterEvent("PLAYER_TARGET_CHANGED", Targeting.OnTargetChanged)
        RXP.events:RegisterEvent("UNIT_QUEST_LOG_CHANGED", Targeting.OnQuestLogChanged)
    end

    RXP:Debug("Targeting module initialized")
end

-- === ОСНОВНЫЕ ФУНКЦИИ ТАРГЕТИНГА ===

-- Добавить цель в очередь
function Targeting:AddTarget(name, targetType, priority, mapId, x, y)
    if not name then return end

    targetType = targetType or "quest_npc"
    priority = priority or targetPriorities[targetType] or 99

    -- Проверяем, не в очереди ли уже
    for _, entry in ipairs(targetQueue) do
        if entry.name == name then
            -- Обновляем приоритет если нужно
            if priority < entry.priority then
                entry.priority = priority
            end
            return
        end
    end

    table.insert(targetQueue, {
        name = name,
        type = targetType,
        priority = priority,
        mapId = mapId,
        x = x,
        y = y,
        addedTime = GetTime(),
        attempts = 0
    })

    -- Сортируем по приоритету
    table.sort(targetQueue, function(a, b)
        return a.priority < b.priority
    end)

    RXP:Debug("Added target: " .. name .. " (priority: " .. priority .. ")")

    -- Запускаем сканирование если не активно
    if not isScanning then
        Targeting:StartScanning()
    end
end

-- Удалить цель из очереди
function Targeting:RemoveTarget(name)
    for i, entry in ipairs(targetQueue) do
        if entry.name == name then
            table.remove(targetQueue, i)
            RXP:Debug("Removed target: " .. name)
            break
        end
    end

    -- Если очередь пуста - останавливаем сканирование
    if #targetQueue == 0 then
        Targeting:StopScanning()
    end
end

-- Очистить всю очередь
function Targeting:ClearQueue()
    targetQueue = {}
    activeTarget = nil
    Targeting:StopScanning()
    RXP:Debug("Target queue cleared")
end

-- === СКАНИРОВАНИЕ ===

function Targeting:StartScanning()
    if isScanning then return end
    isScanning = true

    scanFrame:SetScript("OnUpdate", function(self, elapsed)
        lastScanTime = lastScanTime + elapsed
        if lastScanTime >= SCAN_INTERVAL then
            lastScanTime = 0
            Targeting:ProcessQueue()
        end
    end)

    scanFrame:Show()
    RXP:Debug("Target scanning started")
end

function Targeting:StopScanning()
    isScanning = false
    scanFrame:SetScript("OnUpdate", nil)
    scanFrame:Hide()
    activeTarget = nil
    RXP:Debug("Target scanning stopped")
end

-- Обработка очереди
function Targeting:ProcessQueue()
    if #targetQueue == 0 then
        Targeting:StopScanning()
        return
    end

    -- Берём первую цель из очереди
    local target = targetQueue[1]
    local now = GetTime()

    -- Проверяем таймаут
    if target.attempts > 0 and (now - target.addedTime) > TARGET_TIMEOUT then
        RXP:Debug("Target timeout: " .. target.name)
        table.remove(targetQueue, 1)
        return
    end

    -- Пытаемся найти и выделить цель
    if Targeting:TryTarget(target) then
        -- Успех! Удаляем из очереди
        table.remove(targetQueue, 1)
        activeTarget = target.name
        targetAttempts = 0

        -- Оповещаем группу о найденной цели
        if RXP.Comm and RXP.Comm.SendTargetFound then
            local mapId = target.mapId or GetCurrentMapAreaID()
            local x, y = GetPlayerMapPosition("player")
            RXP.Comm:SendTargetFound(target.name, mapId, x * 100, y * 100)
        end
    else
        target.attempts = target.attempts + 1
    end
end

-- Попытка таргета
function Targeting:TryTarget(target)
    if not target or not target.name then return false end

    -- Проверяем, не является ли текущая цель нужной
    if UnitExists("target") and UnitName("target") == target.name then
        return true
    end

    -- Метод 1: Прямой таргет по имени
    -- В 3.3.5: TargetUnit("name") работает для NPC в радиусе
    local success = TargetUnit(target.name)
    if success and UnitExists("target") and UnitName("target") == target.name then
        return true
    end

    -- Метод 2: Таргет через /target макрос
    -- Используем SecureActionButtonTemplate для безопасного таргета
    if not RXP.targetButton then
        RXP.targetButton = CreateFrame("Button", "RXP_TargetButton", nil, "SecureActionButtonTemplate")
        RXP.targetButton:SetAttribute("type", "macro")
    end

    RXP.targetButton:SetAttribute("macrotext", "/targetexact " .. target.name)
    -- В боевом режиме нельзя программно нажать, но вне боя - можно
    if not InCombatLockdown() then
        RXP.targetButton:Click()
        if UnitExists("target") and UnitName("target") == target.name then
            return true
        end
    end

    -- Метод 3: Сканирование ближайших юнитов (nameplates)
    if Targeting:ScanNameplates(target.name) then
        return true
    end

    return false
end

-- Сканирование неймплейтов
function Targeting:ScanNameplates(targetName)
    -- В 3.3.5 неймплейты не доступны через API напрямую
    -- Используем WorldFrame:GetChildren() для доступа к неймплейтам

    local worldChildren = {WorldFrame:GetChildren()}
    for _, child in ipairs(worldChildren) do
        -- Неймплейты в 3.3.5 имеют определённую структуру
        if child:GetName() and string.find(child:GetName(), "NamePlate") then
            local healthBar = child:GetChildren()
            if healthBar then
                local nameText = healthBar:GetRegions()
                if nameText and nameText.GetText then
                    local name = nameText:GetText()
                    if name == targetName then
                        -- Нашли! Кликаем по неймплейту
                        if not InCombatLockdown() then
                            child:Click()
                            return UnitExists("target") and UnitName("target") == targetName
                        end
                    end
                end
            end
        end
    end

    return false
end

-- === ОБРАБОТЧИКИ СОБЫТИЙ ===

function Targeting.OnTargetChanged()
    -- Проверяем, является ли новая цель квестовой
    if UnitExists("target") then
        local name = UnitName("target")
        local isQuestUnit = Targeting:IsQuestTarget(name)

        if isQuestUnit then
            -- Подсвечиваем или помечаем
            RXP:Debug("Quest target acquired: " .. name)
        end

        -- Удаляем из очереди если была там
        Targeting:RemoveTarget(name)
    end
end

function Targeting.OnQuestLogChanged()
    -- Обновляем очередь таргетов на основе текущих квестов
    Targeting:UpdateQueueFromQuests()
end

-- === ПОМОЩЬ В КВЕСТАХ ===

-- Проверить, является ли юнит целью активного квеста
function Targeting:IsQuestTarget(name)
    if not name then return false end

    local numEntries = GetNumQuestLogEntries()
    for i = 1, numEntries do
        local questTitle, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i)

        if not isHeader then
            -- Получаем цели квеста
            local numObjectives = GetNumQuestLeaderBoards(i)
            for j = 1, numObjectives do
                local objectiveText, objectiveType, isFinished = GetQuestLogLeaderBoard(j, i)
                if objectiveText and string.find(objectiveText, name) then
                    return true
                end
            end
        end
    end

    return false
end

-- Обновить очередь на основе активных квестов
function Targeting:UpdateQueueFromQuests()
    Targeting:ClearQueue()

    local numEntries = GetNumQuestLogEntries()
    for i = 1, numEntries do
        local questTitle, level, questTag, isHeader, isCollapsed, isComplete = GetQuestLogTitle(i)

        if not isHeader and not isComplete then
            local numObjectives = GetNumQuestLeaderBoards(i)
            for j = 1, numObjectives do
                local objectiveText, objectiveType, isFinished = GetQuestLogLeaderBoard(j, i)

                if not isFinished and objectiveText then
                    -- Парсим имя цели из текста объектива
                    -- Примеры: "Slain: 0/10 Wolf", "Wolf slain: 0/10"
                    local targetName = Targeting:ParseObjectiveTarget(objectiveText)
                    if targetName then
                        Targeting:AddTarget(targetName, "quest_mob", 2)
                    end
                end
            end
        end
    end
end

-- Парсинг имени цели из текста объектива
function Targeting:ParseObjectiveTarget(objectiveText)
    if not objectiveText then return nil end

    -- Паттерны для разных языков
    local patterns = {
        "(.-) slain:%s*%d+/%d+",      -- "Wolf slain: 0/10"
        "(.-) killed:%s*%d+/%d+",      -- "Wolf killed: 0/10"
        "Slain:%s*(.-):%s*%d+/%d+",   -- "Slain: Wolf: 0/10"
        "(.-):%s*%d+/%d+",            -- "Wolf: 0/10"
    }

    for _, pattern in ipairs(patterns) do
        local match = string.match(objectiveText, pattern)
        if match then
            return string.trim(match)
        end
    end

    return nil
end

-- === МАРКИРОВКА ЦЕЛЕЙ ===

-- Установить метку на цель (рейд-маркер)
function Targeting:SetRaidMarker(unit, markerIndex)
    if not unit or not UnitExists(unit) then return end
    if not markerIndex or markerIndex < 1 or markerIndex > 8 then return end

    -- В 3.3.5: SetRaidTarget(unit, index)
    -- 1-8: Звезда, Круг, Ромб, Треугольник, Луна, Квадрат, Крест, Череп
    if GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then
        SetRaidTarget(unit, markerIndex)
    end
end

-- Автоматическая маркировка квестовых целей
function Targeting:AutoMarkQuestTargets()
    if not RXP.db or not RXP.db.profile.autoMarkTargets then return end

    if UnitExists("target") and Targeting:IsQuestTarget(UnitName("target")) then
        -- Маркируем звездой (1)
        Targeting:SetRaidMarker("target", 1)
    end
end

-- === ИНТЕГРАЦИЯ С ГАЙДОМ ===

-- Установить цели из текущего шага гайда
function Targeting:SetGuideTargets(stepData)
    if not stepData then return end

    Targeting:ClearQueue()

    -- Добавляем NPC для принятия/сдачи квестов
    if stepData.accept then
        for _, questId in ipairs(stepData.accept) do
            local npcName = RXP.GetQuestNPC and RXP:GetQuestNPC(questId, "start")
            if npcName then
                Targeting:AddTarget(npcName, "quest_npc", 1)
            end
        end
    end

    if stepData.turnin then
        for _, questId in ipairs(stepData.turnin) do
            local npcName = RXP.GetQuestNPC and RXP:GetQuestNPC(questId, "end")
            if npcName then
                Targeting:AddTarget(npcName, "quest_npc", 1)
            end
        end
    end

    -- Добавляем цели для убийства
    if stepData.kill then
        for _, mobName in ipairs(stepData.kill) do
            Targeting:AddTarget(mobName, "quest_mob", 2)
        end
    end

    -- Добавляем цели для взаимодействия
    if stepData.interact then
        for _, name in ipairs(stepData.interact) do
            Targeting:AddTarget(name, "quest_npc", 2)
        end
    end
end

-- === КОМАНДЫ СЛЕША ===

SLASH_RXPTARGET1 = "/rxptarget"
SLASH_RXPTARGET2 = "/rxpt"
SlashCmdList["RXPTARGET"] = function(msg)
    local cmd, arg = string.match(msg, "^(%S*)%s*(.-)$")
    cmd = string.lower(cmd or "")

    if cmd == "add" and arg ~= "" then
        Targeting:AddTarget(arg, "manual", 1)
        print("RXP: Added target: " .. arg)
    elseif cmd == "clear" then
        Targeting:ClearQueue()
        print("RXP: Target queue cleared")
    elseif cmd == "list" then
        print("RXP: Target queue:")
        for i, entry in ipairs(targetQueue) do
            print(string.format("  %d. %s (%s, prio:%d)", i, entry.name, entry.type, entry.priority))
        end
    elseif cmd == "scan" then
        Targeting:UpdateQueueFromQuests()
        print("RXP: Scanned quest log for targets")
    else
        print("RXP Targeting commands:")
        print("  /rxptarget add <name> - Add target")
        print("  /rxptarget clear - Clear queue")
        print("  /rxptarget list - Show queue")
        print("  /rxptarget scan - Scan quest log")
    end
end

-- Экспорт
RXP.Targeting = Targeting
