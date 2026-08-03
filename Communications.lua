--[[
    RXPGuides - Communications Module
    Адаптировано для WoW 3.3.5 (WotLK)
    Обработка синхронизации между игроками, обмена маршрутами и координации
]]

local _, addon = ...
local RXP = addon.RXP or {}
addon.RXP = RXP

local Comm = {}
RXP.Comm = Comm

-- Константы протокола
local COMM_PREFIX = "RXPv1"
local COMM_VERSION = 1
local MSG_GUIDE_SHARE = "GUIDE"
local MSG_PROGRESS = "PROG"
local MSG_QUEST_UPDATE = "QUEST"
local MSG_PARTY_SYNC = "SYNC"
local MSG_TARGET_FOUND = "TARG"

-- Таблица обработчиков сообщений
local messageHandlers = {}

-- История полученных сообщений (дедупликация)
local messageHistory = {}
local HISTORY_TIMEOUT = 30

-- Инициализация
function Comm:Init()
    -- Регистрируем префикс для аддон-коммуникаций
    local success = C_ChatInfo.RegisterAddonMessagePrefix(COMM_PREFIX)
    if not success then
        -- В 3.3.5 используем старый API
        success = RegisterAddonMessagePrefix(COMM_PREFIX)
    end

    if success then
        RXP:Debug("Communications initialized with prefix: " .. COMM_PREFIX)
    else
        RXP:Debug("Failed to register communication prefix")
    end

    -- Подписываемся на события
    if RXP.events then
        RXP.events:RegisterEvent("CHAT_MSG_ADDON", Comm.OnAddonMessage)
        RXP.events:RegisterEvent("PARTY_MEMBERS_CHANGED", Comm.OnPartyChanged)
        RXP.events:RegisterEvent("RAID_ROSTER_UPDATE", Comm.OnPartyChanged)
    end

    -- Очистка истории
    Comm:StartHistoryCleanup()
end

-- Отправка сообщения
function Comm:SendMessage(msgType, target, data)
    if not msgType then return end

    local payload = Comm:Serialize(msgType, data)
    if not payload then return end

    local channel = "WHISPER"
    local dest = target

    if not target or target == "" then
        if GetNumRaidMembers() > 0 then
            channel = "RAID"
            dest = nil
        elseif GetNumPartyMembers() > 0 then
            channel = "PARTY"
            dest = nil
        else
            -- Нет группы, не отправляем
            return
        end
    end

    -- В 3.3.5: SendAddonMessage(prefix, message, channel, target)
    local sent = SendAddonMessage(COMM_PREFIX, payload, channel, dest)

    if sent then
        RXP:Debug("Sent " .. msgType .. " via " .. channel)
    end
end

-- Сериализация данных
function Comm:Serialize(msgType, data)
    local header = COMM_VERSION .. "#" .. msgType .. "#"
    local body = ""

    if type(data) == "table" then
        -- Простая сериализация таблицы
        local parts = {}
        for k, v in pairs(data) do
            table.insert(parts, tostring(k) .. "=" .. tostring(v))
        end
        body = table.concat(parts, ";")
    elseif data then
        body = tostring(data)
    end

    local payload = header .. body

    -- Проверка длины (макс 255 для аддон-сообщений)
    if #payload > 240 then
        -- Сжимаем или разбиваем
        payload = string.sub(payload, 1, 240)
        RXP:Debug("Message truncated to fit limit")
    end

    return payload
end

-- Десериализация
function Comm:Deserialize(payload)
    if not payload or payload == "" then return nil end

    -- Проверка версии
    local versionEnd = string.find(payload, "#")
    if not versionEnd then return nil end

    local version = tonumber(string.sub(payload, 1, versionEnd - 1))
    if not version or version > COMM_VERSION then
        -- Несовместимая версия
        return nil
    end

    local typeEnd = string.find(payload, "#", versionEnd + 1)
    if not typeEnd then return nil end

    local msgType = string.sub(payload, versionEnd + 1, typeEnd - 1)
    local body = string.sub(payload, typeEnd + 1)

    -- Парсинг тела
    local data = {}
    if body and body ~= "" then
        for pair in string.gmatch(body, "([^;]+)") do
            local eqPos = string.find(pair, "=")
            if eqPos then
                local key = string.sub(pair, 1, eqPos - 1)
                local value = string.sub(pair, eqPos + 1)
                data[key] = value
            end
        end
    end

    return msgType, data
end

-- Обработка входящего сообщения
function Comm.OnAddonMessage(event, prefix, message, channel, sender)
    if prefix ~= COMM_PREFIX then return end
    if sender == UnitName("player") then return end

    -- Дедупликация
    local msgKey = sender .. ":" .. message
    if messageHistory[msgKey] then
        return
    end
    messageHistory[msgKey] = GetTime()

    local msgType, data = Comm:Deserialize(message)
    if not msgType then return end

    RXP:Debug("Received " .. msgType .. " from " .. sender)

    -- Вызов обработчика
    local handler = messageHandlers[msgType]
    if handler then
        handler(data, sender, channel)
    end
end

-- Регистрация обработчика
function Comm:RegisterHandler(msgType, handler)
    messageHandlers[msgType] = handler
end

-- === ОБРАБОТЧИКИ СООБЩЕНИЙ ===

-- Обработчик: обновление квеста
messageHandlers[MSG_QUEST_UPDATE] = function(data, sender)
    if not data then return end

    local questId = tonumber(data.questId)
    local status = data.status  -- "accepted", "completed", "turned_in"

    if questId and status then
        RXP:Debug(string.format("Party member %s %s quest %d", sender, status, questId))

        -- Опционально: обновляем UI для отображения прогресса группы
        if RXP.UpdatePartyProgress then
            RXP:UpdatePartyProgress(sender, questId, status)
        end
    end
end

-- Обработчик: синхронизация прогресса
messageHandlers[MSG_PROGRESS] = function(data, sender)
    if not data then return end

    local stepIndex = tonumber(data.step)
    local guideName = data.guide

    if stepIndex and guideName then
        RXP:Debug(string.format("%s is on step %d of %s", sender, stepIndex, guideName))
    end
end

-- Обработчик: найдена цель
messageHandlers[MSG_TARGET_FOUND] = function(data, sender)
    if not data then return end

    local targetName = data.name
    local mapId = tonumber(data.map)
    local x = tonumber(data.x)
    local y = tonumber(data.y)

    if targetName and mapId and x and y then
        RXP:Debug(string.format("%s found %s at %d, %.1f, %.1f", sender, targetName, mapId, x, y))

        -- Опционально: добавляем временную метку на карту
        if RXP.AddTemporaryMarker then
            RXP:AddTemporaryMarker(targetName, mapId, x, y, 300) -- 5 минут
        end
    end
end

-- Обработчик: запрос синхронизации
messageHandlers[MSG_PARTY_SYNC] = function(data, sender)
    -- Отправляем текущий прогресс
    if RXP.currentGuide and RXP.currentStep then
        Comm:SendMessage(MSG_PROGRESS, sender, {
            guide = RXP.currentGuide.name,
            step = RXP.currentStep
        })
    end
end

-- === ПУБЛИЧНЫЕ ФУНКЦИИ ===

-- Отправить обновление квеста группе
function Comm:SendQuestUpdate(questId, status)
    Comm:SendMessage(MSG_QUEST_UPDATE, nil, {
        questId = questId,
        status = status
    })
end

-- Отправить прогресс
function Comm:SendProgress(guideName, stepIndex)
    Comm:SendMessage(MSG_PROGRESS, nil, {
        guide = guideName,
        step = stepIndex
    })
end

-- Отправить найденную цель
function Comm:SendTargetFound(name, mapId, x, y)
    Comm:SendMessage(MSG_TARGET_FOUND, nil, {
        name = name,
        map = mapId,
        x = string.format("%.1f", x),
        y = string.format("%.1f", y)
    })
end

-- Запросить синхронизацию с группой
function Comm:RequestSync()
    Comm:SendMessage(MSG_PARTY_SYNC, nil, {})
end

-- === ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ===

function Comm.OnPartyChanged()
    -- При изменении состава группы запрашиваем синхронизацию
    if GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then
        Comm:RequestSync()
    end
end

function Comm:StartHistoryCleanup()
    -- Очистка старой истории каждые 30 секунд
    local function cleanup()
        local now = GetTime()
        for key, time in pairs(messageHistory) do
            if now - time > HISTORY_TIMEOUT then
                messageHistory[key] = nil
            end
        end
    end

    -- В 3.3.5 нет C_Timer, используем OnUpdate
    local frame = CreateFrame("Frame")
    frame.elapsed = 0
    frame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= HISTORY_TIMEOUT then
            cleanup()
            self.elapsed = 0
        end
    end)
end

-- Экспорт
RXP.Comm = Comm
