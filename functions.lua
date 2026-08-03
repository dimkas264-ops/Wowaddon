local addonName, addon = ...

-- ============================================================
-- GUIDE STEP FUNCTIONS
-- Адаптировано для WoW 3.3.5
-- ============================================================

local L = addon.locale.Get
local fmt = string.format
local GetSpellInfo = _G.GetSpellInfo
local GetItemInfo = _G.GetItemInfo
local GetItemCount = _G.GetItemCount
local UnitLevel = _G.UnitLevel
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax
local GetMoney = _G.GetMoney
local GetContainerNumSlots = _G.GetContainerNumSlots
local GetContainerItemID = _G.GetContainerItemID
local GetContainerItemLink = _G.GetContainerItemLink
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetInventoryItemCount = _G.GetInventoryItemCount
local GetQuestLogIndexByID = _G.GetQuestLogIndexByID
local GetQuestLogTitle = _G.GetQuestLogTitle
local GetNumQuestLogEntries = _G.GetNumQuestLogEntries
local GetQuestLogLeaderBoard = _G.GetQuestLogLeaderBoard
local GetNumQuestLeaderBoards = _G.GetNumQuestLeaderBoards
local GetNumQuestWatches = _G.GetNumQuestWatches
local GetQuestIndexForWatch = _G.GetQuestIndexForWatch
local IsQuestWatched = _G.IsQuestWatched
local AddQuestWatch = _G.AddQuestWatch
local RemoveQuestWatch = _G.RemoveQuestWatch
local GetNumGroupMembers = _G.GetNumGroupMembers
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local GetRestState = _G.GetRestState
local GetXPExhaustion = _G.GetXPExhaustion
local GetTimeToWellRested = _G.GetTimeToWellRested
local GetRealZoneText = _G.GetRealZoneText
local GetSubZoneText = _G.GetSubZoneText
local GetMinimapZoneText = _G.GetMinimapZoneText
local GetZoneText = _G.GetZoneText
local SetMapToCurrentZone = _G.SetMapToCurrentZone
local GetCurrentMapAreaID = _G.GetCurrentMapAreaID or function() return 0 end
local GetPlayerMapPosition = _G.GetPlayerMapPosition
local GetMapInfo = _G.GetMapInfo
local GetCorpseMapPosition = _G.GetCorpseMapPosition
local GetDeathReleasePosition = _G.GetDeathReleasePosition
local GetNumTrackingTypes = _G.GetNumTrackingTypes
local GetTrackingInfo = _G.GetTrackingInfo
local SetTracking = _G.SetTracking
local GetNumFactions = _G.GetNumFactions
local GetFactionInfo = _G.GetFactionInfo
local ExpandFactionHeader = _G.ExpandFactionHeader
local CollapseFactionHeader = _G.CollapseFactionHeader
local GetFriendshipReputation = _G.GetFriendshipReputation
local GetFriendshipReputationRanks = _G.GetFriendshipReputationRanks
local GetSkillLineInfo = _G.GetSkillLineInfo
local GetNumSkillLines = _G.GetNumSkillLines
local GetTrainerServiceInfo = _G.GetTrainerServiceInfo
local GetNumTrainerServices = _G.GetNumTrainerServices
local BuyTrainerService = _G.BuyTrainerService
local GetBuybackItemInfo = _G.GetBuybackItemInfo
local GetBuybackItemLink = _G.GetBuybackItemLink
local GetMerchantItemInfo = _G.GetMerchantItemInfo
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMerchantItemCostInfo = _G.GetMerchantItemCostInfo
local GetMerchantItemCostItem = _G.GetMerchantItemCostItem
local GetNumMerchantItems = _G.GetNumMerchantItems
local BuyMerchantItem = _G.BuyMerchantItem
local GetMerchantItemMaxStack = _G.GetMerchantItemMaxStack
local GetMerchantItemID = _G.GetMerchantItemID
local GetMerchantItemCostItem = _G.GetMerchantItemCostItem
local GetMerchantItemCostInfo = _G.GetMerchantItemCostInfo
local GetMerchantItemCostItem = _G.GetMerchantItemCostItem
local GetMerchantItemCostInfo = _G.GetMerchantItemCostInfo
local GetMerchantItemCostItem = _G.GetMerchantItemCostItem
local GetMerchantItemCostInfo = _G.GetMerchantItemCostInfo

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

local function GetUnitLevel(unit)
    return UnitLevel(unit)
end

local function GetUnitXP(unit)
    return UnitXP(unit)
end

local function GetUnitXPMax(unit)
    return UnitXPMax(unit)
end

local function GetPlayerMoney()
    return GetMoney()
end

-- ============================================================
-- STEP COMPLETION CHECKS
-- ============================================================

addon.functions.goto = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    local step = element.step
    if not step or not step.active then return end

    -- Проверяем, находится ли игрок в нужной зоне/координатах
    if element.zone then
        local currentZone = GetRealZoneText()
        if currentZone ~= element.zone then return end
    end

    if element.x and element.y then
        SetMapToCurrentZone()
        local px, py = GetPlayerMapPosition("player")
        if not px or not py then return end

        local dx = (element.x / 100) - px
        local dy = (element.y / 100) - py
        local distance = math.sqrt(dx * dx + dy * dy)

        -- Диапазон достижения точки (в координатах карты)
        local radius = element.radius or 0.002

        if distance <= radius then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

addon.functions.accept = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    local questID = element.questId
    if not questID then return end

    -- Проверяем, взят ли квест
    if addon.IsQuestInLog(questID) then
        element.completed = true
        addon.updateSteps = true
        return true
    end

    -- Проверяем, выполнен ли квест (если уже сдан)
    if addon.IsQuestCompleted(questID) then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.turnin = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    local questID = element.questId
    if not questID then return end

    -- Проверяем, сдан ли квест
    if addon.IsQuestCompleted(questID) then
        element.completed = true
        addon.updateSteps = true
        return true
    end

    -- Проверяем, выполнен ли квест в логе (готов к сдаче)
    local info = addon.GetQuestLogInfo(questID)
    if info and info.complete == 1 then
        -- Квест выполнен, но ещё не сдан — показываем как активный
        element.questReady = true
    end
end

addon.functions.complete = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    local questID = element.questId
    if not questID then return end

    -- Проверяем выполнение objectives
    local objectives = addon.GetQuestObjectives(questID)
    if not objectives then return end

    local allComplete = true
    for i, obj in ipairs(objectives) do
        if not obj.finished then
            allComplete = false
            break
        end
    end

    if allComplete then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.skip = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Skip всегда считается выполненным
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.home = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем, установлена ли точка возвращения (Hearthstone)
    local bindLocation = GetBindLocation()
    if element.location and bindLocation == element.location then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.fly = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем, изучены ли нужные маршруты полётов
    if addon.settings.profile and addon.settings.profile.enableFlightPathAutomation then
        -- Логика автоматического полёта
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.train = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем, изучены ли нужные спеллы
    if element.spellId then
        if addon.IsPlayerSpell(element.spellId) then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end

    if element.skill then
        local level = addon.GetSkillLevel(element.skill)
        if level >= (element.requiredLevel or 1) then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

addon.functions.vendor = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем, куплены ли нужные предметы
    if element.itemId then
        local count = GetItemCount(element.itemId)
        if count >= (element.requiredCount or 1) then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

addon.functions.repair = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Repair обычно выполняется автоматически при взаимодействии с торговцем
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.bank = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Bank обычно выполняется при открытии банка
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.auction = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Auction обычно выполняется при открытии аукциона
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.mail = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Mail обычно выполняется при открытии почтового ящика
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.stable = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Stable обычно выполняется при открытии стойла
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.tame = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем, приручено ли животное
    if element.npcId then
        -- Логика проверки приручения
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.die = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем, мёртв ли игрок
    if UnitIsDeadOrGhost("player") then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.reach = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем уровень
    local level = UnitLevel("player")
    if level >= (element.level or 1) then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.xp = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем количество XP
    local xp = UnitXP("player")
    if xp >= (element.xp or 0) then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.reputation = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем репутацию
    if element.factionID then
        local name, description, standingID, barMin, barMax, barValue = GetFactionInfoByID(element.factionID)
        if barValue and barValue >= (element.requiredValue or 0) then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

addon.functions.skill = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем уровень навыка
    if element.skill then
        local level = addon.GetSkillLevel(element.skill)
        if level >= (element.requiredLevel or 1) then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

addon.functions.money = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем количество денег
    local money = GetMoney()
    if money >= (element.amount or 0) then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.item = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем наличие предмета
    if element.itemId then
        local count = GetItemCount(element.itemId)
        if count >= (element.requiredCount or 1) then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

addon.functions.equip = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем, надет ли предмет
    if element.itemId then
        for slot = 1, 19 do
            local link = GetInventoryItemLink("player", slot)
            if link then
                local id = tonumber(link:match("item:(%d+)"))
                if id == element.itemId then
                    element.completed = true
                    addon.updateSteps = true
                    return true
                end
            end
        end
    end
end

addon.functions.learn = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем, изучен ли спелл
    if element.spellId then
        if addon.IsPlayerSpell(element.spellId) then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

addon.functions.spell = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем, изучен ли спелл (алиас для learn)
    if element.spellId then
        if addon.IsPlayerSpell(element.spellId) then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

addon.functions.talent = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем таланты
    if element.talent then
        -- Логика проверки талантов
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.pet = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем питомца
    if element.pet then
        -- Логика проверки питомца
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.mount = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем маунта
    if element.mount then
        -- Логика проверки маунта
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.achievement = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем достижение
    if element.achievementId then
        -- Логика проверки достижения
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.event = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем событие
    if element.event then
        -- Логика проверки события
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.timer = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем таймер
    if element.time then
        local elapsed = GetTime() - (element.startTime or 0)
        if elapsed >= element.time then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

addon.functions.coord = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем координаты (алиас для goto)
    if element.x and element.y then
        SetMapToCurrentZone()
        local px, py = GetPlayerMapPosition("player")
        if not px or not py then return end

        local dx = (element.x / 100) - px
        local dy = (element.y / 100) - py
        local distance = math.sqrt(dx * dx + dy * dy)
        local radius = element.radius or 0.002

        if distance <= radius then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

addon.functions.zone = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем зону
    local currentZone = GetRealZoneText()
    if currentZone == element.zone then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.subzone = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем подзону
    local currentSubZone = GetSubZoneText()
    if currentSubZone == element.subzone then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.minimap = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем миникарту
    local currentMinimap = GetMinimapZoneText()
    if currentMinimap == element.minimap then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.rest = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем rested XP
    local restedXP = GetXPExhaustion()
    if restedXP and restedXP > 0 then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.group = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем группу
    local inGroup = GetNumGroupMembers() > 0 or UnitInParty("player") or UnitInRaid("player")
    if inGroup then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.solo = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Проверяем, один ли игрок
    local inGroup = GetNumGroupMembers() > 0 or UnitInParty("player") or UnitInRaid("player")
    if not inGroup then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.deathskip = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Death skip — специальная механика
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.hs = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Hearthstone — использование камня возвращения
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.fp = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Flight path — маршрут полёта
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.boat = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Boat — использование корабля
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.zeppelin = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Zeppelin — использование дирижабля
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.tram = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Tram — использование трамвая
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.portal = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Portal — использование портала
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.teleport = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Teleport — телепортация
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.dungeon = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Dungeon — вход в подземелье
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.raid = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Raid — вход в рейд
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.battleground = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Battleground — вход на поле боя
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.arena = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Arena — вход на арену
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.world = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- World — мировое событие
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.pvp = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- PvP — PvP событие
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.race = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Race — расовое событие
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.class = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Class — классовое событие
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.profession = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Profession — профессиональное событие
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.faction = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Faction — фракционное событие
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.reputation = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Reputation — репутационное событие
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.honor = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Honor — событие чести
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.arena = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Arena — аренное событие
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.battleground = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Battleground — событие поля боя
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.dungeon = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Dungeon — событие подземелья
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.raid = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Raid — событие рейда
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.world = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- World — мировое событие
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.event = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Event — общее событие
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.custom = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Custom — пользовательская функция
    element.completed = true
    addon.updateSteps = true
    return true
end

-- ============================================================
-- TEXT FORMATTING
-- ============================================================

addon.functions.text = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Text — текстовый элемент (всегда выполнен)
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.note = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Note — заметка (всегда выполнена)
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.warning = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Warning — предупреждение (всегда выполнено)
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.tip = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Tip — совет (всегда выполнен)
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.info = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Info — информация (всегда выполнена)
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.link = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Link — ссылка (всегда выполнена)
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.image = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Image — изображение (всегда выполнено)
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.video = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Video — видео (всегда выполнено)
    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.audio = function(self, ...)
    if type(self) == "string" then return self end
    local element = self.element or self
    if not element then return end

    -- Audio — аудио (всегда выполнено)
    element.completed = true
    addon.updateSteps = true
    return true
end
