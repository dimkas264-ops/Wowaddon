local addonName, addon = ...

local L = addon.locale.Get
local fmt = string.format

-- ============================================================
-- GUIDE STEP FUNCTIONS
-- Адаптировано для WoW 3.3.5
-- Переписано: функции теперь создают element при парсинге
-- ============================================================

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
-- GOTO / WAYPOINT
-- ============================================================

addon.functions.goto = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        local args = {...}
        element.zone = args[1]
        element.x = tonumber(args[2])
        element.y = tonumber(args[3])
        element.radius = tonumber(args[4]) or 0.002
        return element
    end

    local element = self.element or self
    if not element then return end

    local step = element.step
    if not step or not step.active then return end

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
        local radius = element.radius or 0.002

        if distance <= radius then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

addon.functions.waypoint = addon.functions.goto

-- ============================================================
-- ACCEPT QUEST
-- ============================================================

addon.functions.accept = function(self, text, ...)
    if type(self) == "string" then
        -- ПАРСИНГ
        local element = {}
        element.text = text
        element.questId = tonumber((...))
        if element.questId then
            addon.questAccept = addon.questAccept or {}
            addon.questAccept[element.questId] = true
        end
        return element
    end
    -- RUNTIME
    local element = self.element or self
    if not element then return end
    -- if element.questId then
    --    addon.questAccept = addon.questAccept or {}
    --    addon.questAccept[element.questId] = true
    --    print("|cff33ff99RXP|r: [RUNTIME] accept questId=" .. element.questId)
    -- end

    local element = self.element or self
    if not element then return end

    local questID = element.questId
    if not questID then return end

    addon.questAccept[questID] = true

    local inLog = addon.IsQuestInLog(questID)

    if addon.settings and addon.settings.profile and addon.settings.profile.debug then
        print("RXP accept check: questID=" .. tostring(questID) .. " inLog=" .. tostring(inLog))
    end

    if inLog then
        element.completed = true
        addon.updateSteps = true
        return true
    end

    return false
end

-- ============================================================
-- TURNIN QUEST
-- ============================================================

addon.functions.turnin = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.questId = tonumber((...))
        if element.questId then
            addon.questAccept[element.questId] = true
            print("|cff33ff99RXP|r: accept parsed questId=" .. element.questId .. " questAccept count=" .. (function() local c=0 for _ in pairs(addon.questAccept) do c=c+1 end return c end)())
        end
        return element
    end

    local element = self.element or self
    if not element then return end

    local questID = element.questId
    if not questID then return end

    local inLog = addon.IsQuestInLog(questID)
    local wasAccepted = addon.questAccept[questID]

    if wasAccepted and not inLog then
        element.completed = true
        addon.questTurnIn[questID] = true
        addon.updateSteps = true
        return true
    end

    if inLog then
        local info = addon.GetQuestLogInfo(questID)
        if info and info.complete == 1 then
            element.questReady = true
        end
    end

    return false
end

-- ============================================================
-- COMPLETE QUEST OBJECTIVES
-- ============================================================

addon.functions.complete = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.questId = tonumber((...))
        if element.questId then
            addon.questAccept[element.questId] = true
            print("|cff33ff99RXP|r: accept parsed questId=" .. element.questId .. " questAccept count=" .. (function() local c=0 for _ in pairs(addon.questAccept) do c=c+1 end return c end)())
        end
        return element
    end

    local element = self.element or self
    if not element then return end

    local questID = element.questId
    if not questID then return end

    addon.questAccept[questID] = true

    local objectives = addon.GetQuestObjectives(questID)
    if not objectives then return false end

    local allComplete = true
    for i, obj in ipairs(objectives) do
        if not obj.finished or obj.finished == 0 or obj.finished == false then
            allComplete = false
            break
        end
    end

    if allComplete then
        element.completed = true
        addon.updateSteps = true
        return true
    end

    return false
end

-- ============================================================
-- SKIP STEP
-- ============================================================

addon.functions.skip = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

-- ============================================================
-- HEARTHSTONE / HOME
-- ============================================================

addon.functions.home = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.location = ...
        return element
    end

    local element = self.element or self
    if not element then return end

    local bindLocation = GetBindLocation()
    if element.location and bindLocation == element.location then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

-- ============================================================
-- FLY / FLIGHT PATH
-- ============================================================

addon.functions.fly = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    if addon.settings.profile and addon.settings.profile.enableFlightPathAutomation then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.fp = addon.functions.fly

-- ============================================================
-- TRAIN / LEARN SPELL
-- ============================================================

addon.functions.train = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        local args = {...}
        element.spellId = tonumber(args[1])
        element.skill = args[1] and not tonumber(args[1]) and args[1] or nil
        element.requiredLevel = tonumber(args[2]) or 1
        return element
    end

    local element = self.element or self
    if not element then return end

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

addon.functions.learn = addon.functions.train

-- ============================================================
-- VENDOR / BUY / SELL
-- ============================================================

addon.functions.vendor = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        local args = {...}
        element.itemId = tonumber(args[1])
        element.requiredCount = tonumber(args[2]) or 1
        return element
    end

    local element = self.element or self
    if not element then return end

    if element.itemId then
        local count = GetItemCount(element.itemId)
        if count >= (element.requiredCount or 1) then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

addon.functions.buy = addon.functions.vendor
addon.functions.sell = addon.functions.vendor

-- ============================================================
-- REPAIR
-- ============================================================

addon.functions.repair = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

-- ============================================================
-- BANK
-- ============================================================

addon.functions.bank = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

-- ============================================================
-- AUCTION
-- ============================================================

addon.functions.auction = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

-- ============================================================
-- MAIL
-- ============================================================

addon.functions.mail = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

-- ============================================================
-- STABLE
-- ============================================================

addon.functions.stable = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

-- ============================================================
-- TAME PET
-- ============================================================

addon.functions.tame = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.npcId = tonumber((...))
        return element
    end

    local element = self.element or self
    if not element then return end

    if element.npcId then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

-- ============================================================
-- DIE / DEATHSKIP
-- ============================================================

addon.functions.die = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    if UnitIsDeadOrGhost("player") then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.deathskip = addon.functions.die

-- ============================================================
-- REACH LEVEL
-- ============================================================

addon.functions.reach = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.level = tonumber((...))
        return element
    end

    local element = self.element or self
    if not element then return end

    local level = UnitLevel("player")
    if level >= (element.level or 1) then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

-- ============================================================
-- XP REQUIREMENT
-- ============================================================

addon.functions.xp = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.xp = tonumber((...))
        return element
    end

    local element = self.element or self
    if not element then return end

    local xp = UnitXP("player")
    if xp >= (element.xp or 0) then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

-- ============================================================
-- REPUTATION
-- ============================================================

addon.functions.reputation = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        local args = {...}
        element.faction = args[1]
        element.standing = tonumber(args[2]) or 4
        return element
    end

    local element = self.element or self
    if not element then return end

    if element.faction then
        local targetStanding = element.standing or 4
        for i = 1, GetNumFactions() do
            local name, _, standingID, barMin, barMax, barValue = GetFactionInfo(i)
            if name == element.faction then
                if standingID >= targetStanding then
                    element.completed = true
                    addon.updateSteps = true
                    return true
                end
                break
            end
        end
    end
end

-- ============================================================
-- SKILL
-- ============================================================

addon.functions.skill = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        local args = {...}
        element.skill = args[1]
        element.requiredLevel = tonumber(args[2]) or 1
        return element
    end

    local element = self.element or self
    if not element then return end

    if element.skill then
        local level = addon.GetSkillLevel(element.skill)
        if level >= (element.requiredLevel or 1) then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

-- ============================================================
-- MONEY
-- ============================================================

addon.functions.money = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.amount = tonumber((...))
        return element
    end

    local element = self.element or self
    if not element then return end

    local money = GetMoney()
    if money >= (element.amount or 0) then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

-- ============================================================
-- ITEM
-- ============================================================

addon.functions.item = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        local args = {...}
        element.itemId = tonumber(args[1])
        element.requiredCount = tonumber(args[2]) or 1
        return element
    end

    local element = self.element or self
    if not element then return end

    if element.itemId then
        local count = GetItemCount(element.itemId)
        if count >= (element.requiredCount or 1) then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

-- ============================================================
-- EQUIP ITEM
-- ============================================================

addon.functions.equip = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.itemId = tonumber((...))
        return element
    end

    local element = self.element or self
    if not element then return end

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

-- ============================================================
-- SPELL
-- ============================================================

addon.functions.spell = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.spellId = tonumber((...))
        return element
    end

    local element = self.element or self
    if not element then return end

    if element.spellId then
        if addon.IsPlayerSpell(element.spellId) then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

-- ============================================================
-- TALENT
-- ============================================================

addon.functions.talent = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.talent = ...
        return element
    end

    local element = self.element or self
    if not element then return end

    if element.talent then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

-- ============================================================
-- PET
-- ============================================================

addon.functions.pet = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.pet = ...
        return element
    end

    local element = self.element or self
    if not element then return end

    if element.pet then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

-- ============================================================
-- MOUNT
-- ============================================================

addon.functions.mount = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.mount = ...
        return element
    end

    local element = self.element or self
    if not element then return end

    if element.mount then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

-- ============================================================
-- ACHIEVEMENT
-- ============================================================

addon.functions.achievement = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.achievementId = tonumber((...))
        return element
    end

    local element = self.element or self
    if not element then return end

    if element.achievementId then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

-- ============================================================
-- TIMER
-- ============================================================

addon.functions.timer = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.time = tonumber((...))
        element.startTime = GetTime()
        return element
    end

    local element = self.element or self
    if not element then return end

    if element.time then
        local elapsed = GetTime() - (element.startTime or 0)
        if elapsed >= element.time then
            element.completed = true
            addon.updateSteps = true
            return true
        end
    end
end

-- ============================================================
-- COORD / ZONE
-- ============================================================

addon.functions.coord = addon.functions.goto

addon.functions.zone = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.zone = ...
        return element
    end

    local element = self.element or self
    if not element then return end

    local currentZone = GetRealZoneText()
    if currentZone == element.zone then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.subzone = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.subzone = ...
        return element
    end

    local element = self.element or self
    if not element then return end

    local currentSubZone = GetSubZoneText()
    if currentSubZone == element.subzone then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.minimap = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        element.minimap = ...
        return element
    end

    local element = self.element or self
    if not element then return end

    local currentMinimap = GetMinimapZoneText()
    if currentMinimap == element.minimap then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

-- ============================================================
-- REST
-- ============================================================

addon.functions.rest = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    local restedXP = GetXPExhaustion()
    if restedXP and restedXP > 0 then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

-- ============================================================
-- GROUP / SOLO
-- ============================================================

addon.functions.group = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    local inGroup = GetNumGroupMembers() > 0 or UnitInParty("player") or UnitInRaid("player")
    if inGroup then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

addon.functions.solo = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    local inGroup = GetNumGroupMembers() > 0 or UnitInParty("player") or UnitInRaid("player")
    if not inGroup then
        element.completed = true
        addon.updateSteps = true
        return true
    end
end

-- ============================================================
-- HS / BOAT / ZEPPELIN / TRAM / PORTAL / TELEPORT
-- ============================================================

addon.functions.hs = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.boat = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.zeppelin = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.tram = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.portal = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.teleport = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

-- ============================================================
-- DUNGEON / RAID / BATTLEGROUND / ARENA / WORLD
-- ============================================================

addon.functions.dungeon = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.raid = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.battleground = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.arena = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.world = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

-- ============================================================
-- PVP / RACE / CLASS / PROFESSION / FACTION / HONOR
-- ============================================================

addon.functions.pvp = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.race = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.class = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.profession = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.faction = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.honor = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.custom = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

-- ============================================================
-- TEXT / NOTE / WARNING / TIP / INFO / LINK / IMAGE / VIDEO / AUDIO
-- ============================================================

addon.functions.text = function(self, text, ...)
    if type(self) == "string" then
        local element = {}
        element.text = text
        return element
    end

    local element = self.element or self
    if not element then return end

    element.completed = true
    addon.updateSteps = true
    return true
end

addon.functions.note = addon.functions.text
addon.functions.warning = addon.functions.text
addon.functions.tip = addon.functions.text
addon.functions.info = addon.functions.text
addon.functions.link = addon.functions.text
addon.functions.image = addon.functions.text
addon.functions.video = addon.functions.text
addon.functions.audio = addon.functions.text
