local addonName, addon = ...
local fmt = string.format

-- ============================================================
-- 3.3.5 MAP & NAVIGATION COMPATIBILITY
-- Замена C_Map и HereBeDragons-2.0 на старые API
-- ============================================================

local GetCurrentMapAreaID = _G.GetCurrentMapAreaID or function() return 0 end
local GetPlayerMapPosition = _G.GetPlayerMapPosition
local SetMapToCurrentZone = _G.SetMapToCurrentZone
local GetRealZoneText = _G.GetRealZoneText
local GetSubZoneText = _G.GetSubZoneText
local GetMinimapZoneText = _G.GetMinimapZoneText
local GetZoneText = _G.GetZoneText
local GetMapInfo = _G.GetMapInfo
local GetCorpseMapPosition = _G.GetCorpseMapPosition
local GetDeathReleasePosition = _G.GetDeathReleasePosition
local GetNumMapOverlays = _G.GetNumMapOverlays
local GetMapOverlayInfo = _G.GetMapOverlayInfo
local GetWorldLocFromMapPos = _G.GetWorldLocFromMapPos
local GetMapLocFromWorldLoc = _G.GetMapLocFromWorldLoc

-- ============================================================
-- HERE BE DRAGONS EMULATION (1.0 style for 3.3.5)
-- ============================================================

addon.HBD = {}
addon.HBD.mapData = {}
addon.HBD.transforms = {}

-- Базовые данные карт для 3.3.5
-- Формат: [mapID] = {width, height, instanceID}
local mapSizes = {
    -- Eastern Kingdoms
    [0] = {47710, 31853, 0},
    -- Kalimdor
    [1] = {47710, 31853, 1},
    -- Outland
    [530] = {17463, 11642, 530},
    -- Northrend
    [571] = {17751, 11834, 571},
}

function addon.HBD:GetWorldCoordinatesFromZone(x, y, zone)
    if not x or not y or not zone then return nil, nil end
    local data = mapSizes[zone]
    if not data then return nil, nil end
    local width, height = data[1], data[2]
    return x * width, y * height, zone
end

function addon.HBD:GetZoneCoordinatesFromWorld(x, y, zone, allowOutOfBounds)
    if not x or not y or not zone then return nil, nil end
    local data = mapSizes[zone]
    if not data then return nil, nil end
    local width, height = data[1], data[2]
    local nx, ny = x / width, y / height
    if not allowOutOfBounds and (nx < 0 or nx > 1 or ny < 0 or ny > 1) then
        return nil, nil
    end
    return nx, ny
end

function addon.HBD:GetPlayerZone()
    return GetCurrentMapAreaID()
end

function addon.HBD:GetPlayerWorldPosition()
    SetMapToCurrentZone()
    local mapID = GetCurrentMapAreaID()
    local x, y = GetPlayerMapPosition("player")
    if x and y and x > 0 and y > 0 then
        local wx, wy = self:GetWorldCoordinatesFromZone(x, y, mapID)
        return mapID, wx, wy
    end
    return mapID, 0, 0
end

function addon.HBD:GetLocalizedMap(mapID)
    return GetRealZoneText()
end

-- ============================================================
-- C_Map EMULATION
-- ============================================================

function addon.GetBestMapForUnit(unit)
    if unit == "player" then
        return GetCurrentMapAreaID()
    end
    return 0
end

function addon.GetPlayerMapPosition(unit)
    if not unit then unit = "player" end
    local x, y = GetPlayerMapPosition(unit)
    if x and y then
        return {x = x, y = y}
    end
    return {x = 0, y = 0}
end

function addon.GetMapInfo(mapID)
    local zoneText = GetRealZoneText()
    return {
        mapID = mapID or GetCurrentMapAreaID(),
        name = zoneText,
        mapType = 3,
        parentMapID = 0
    }
end

function addon.GetMapRectOnMap(uiMapID, topUiMapID)
    return 0, 0, 1, 1
end

function addon.GetWorldPosFromMapPos(uiMapID, mapPos)
    if not mapPos then return uiMapID, 0, 0 end
    local wx, wy = addon.HBD:GetWorldCoordinatesFromZone(mapPos.x, mapPos.y, uiMapID)
    return uiMapID, wx or 0, wy or 0
end

function addon.GetMapPosFromWorldPos(continentID, worldX, worldY, overrideUiMapID)
    local mapID = overrideUiMapID or continentID
    local nx, ny = addon.HBD:GetZoneCoordinatesFromWorld(worldX, worldY, mapID, true)
    return mapID, {x = nx or 0, y = ny or 0}
end

function addon.GetMapChildrenInfo(uiMapID, mapType, allDescendants)
    return {}
end

function addon.GetMapGroupID(uiMapID)
    return 0
end

function addon.GetMapGroupMembersInfo(uiMapGroupID)
    return nil
end

function addon.GetExploredMapTextures(uiMapID)
    return nil
end

function addon.GetFallbackWorldMapID()
    return 0
end

function addon.GetMapHighlightInfoAtPosition(uiMapID, x, y)
    return nil
end

function addon.GetMapArtID(uiMapID)
    return 0
end

function addon.GetMapArtLayers(uiMapID)
    return nil
end

function addon.GetMapArtLayerTextures(uiMapID, layerIndex)
    return nil
end

function addon.GetMapLinksForMap(uiMapID)
    return nil
end

function addon.GetMapOverlayInfo(uiMapID, overlayIndex)
    return nil
end

function addon.RequestMapDebugObjectInfo()
    return nil
end

function addon.GetMapDebugObjectInfo()
    return nil
end

function addon.GetMapDebugObjects()
    return nil
end

function addon.GetMapLandmarkInfo(landmarkIndex)
    return nil
end

function addon.GetNumMapLandmarks()
    return 0
end

function addon.GetNumMapOverlays(uiMapID)
    return 0
end

function addon.GetWorldMapTransformInfo(transformID)
    return nil
end

function addon.GetWorldMapTransforms()
    return nil
end

function addon.HasUserWaypoint()
    return false
end

function addon.ClearUserWaypoint()
end

function addon.SetUserWaypoint(waypoint)
end

function addon.GetUserWaypoint()
    return nil
end

function addon.GetUserWaypointFromHyperlink()
    return nil
end

function addon.GetUserWaypointPositionForMap(uiMapID)
    return nil
end

function addon.CanSetUserWaypointOnMap(uiMapID)
    return false
end

function addon.GetUserWaypointHyperlink()
    return nil
end

function addon.GetUserWaypointFromChatLine()
    return nil
end

function addon.GetMapInfoAtPosition(uiMapID, x, y)
    return addon.GetMapInfo(uiMapID)
end

function addon.GetMapLevels(uiMapID)
    return 0, 0
end

function addon.GetMapDisplayInfo(uiMapID)
    return false
end

function addon.GetMapHighlightPulseInfo()
    return 0, 0, 0, 0
end

-- ============================================================
-- ARROW / WAYPOINT SYSTEM
-- ============================================================

addon.arrowFrame = nil
addon.activeWaypoints = {}
addon.completedWaypoints = {}

function addon.SetupArrow()
    if addon.arrowFrame then return end

    local frame = CreateFrame("Frame", "RXPGuidesArrow", UIParent)
    frame:SetSize(32, 32)
    frame:SetFrameStrata("HIGH")
    frame:SetFrameLevel(100)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, -100)
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Текстура стрелки
    local arrow = frame:CreateTexture(nil, "OVERLAY")
arrow:SetTexture("Interface\\AddOns\\" .. addonName .. "\\Textures\\rxp_navigation_arrow-1")    arrow:SetAllPoints()
    arrow:SetTexCoord(0, 1, 0, 1)
    frame.arrow = arrow

    -- Текст расстояния
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("TOP", frame, "BOTTOM", 0, -2)
    text:SetText("")
    frame.text = text

    -- Текст названия точки
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("BOTTOM", frame, "TOP", 0, 2)
    title:SetText("")
    frame.title = title

    addon.arrowFrame = frame
    frame.elapsed = 0

frame:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = self.elapsed + elapsed

    if self.elapsed >= 0.05 then
        self.elapsed = 0
        addon.UpdateArrow()
    end
end)
    frame:Hide()
end

function addon.UpdateArrow()
    local frame = addon.arrowFrame
    if not frame then return end

    if addon.hideArrow or addon.isHidden or #addon.activeWaypoints == 0 then
        frame:Hide()
        return
    end

    local waypoint = addon.activeWaypoints[1]
    if not waypoint then
        frame:Hide()
        return
    end

    frame:Show()

    SetMapToCurrentZone()
    local px, py = GetPlayerMapPosition("player")
    if not px or not py or (px == 0 and py == 0) then
        frame:Hide()
        return
    end

    if not waypoint.x or not waypoint.y then
    frame:Hide()
    return
    end
    local wx, wy = waypoint.x / 100, waypoint.y / 100
    local dx = wx - px
    local dy = wy - py
    local distance = math.sqrt(dx * dx + dy * dy)

    -- Конвертируем расстояние в ярды (приблизительно)
    local yards = math.floor(distance * 914)

    -- Угол к цели
    local angle = math.atan2(dy, dx)
    local playerFacing = GetPlayerFacing() or 0
    local relativeAngle = angle - playerFacing

    -- Нормализуем угол
    while relativeAngle > math.pi do relativeAngle = relativeAngle - math.pi * 2 end
    while relativeAngle < -math.pi do relativeAngle = relativeAngle + math.pi * 2 end

    -- Поворачиваем стрелку
    frame.arrow:SetRotation(relativeAngle)

    -- Обновляем текст
    if yards < 1000 then
        frame.text:SetText(fmt("%.0f yd", yards))
    else
        frame.text:SetText(fmt("%.1f kyd", yards / 1000))
    end

    if waypoint.title then
        frame.title:SetText(waypoint.title)
    else
        frame.title:SetText("")
    end

    -- Проверяем достижение точки
    if distance <= (waypoint.radius or 0.002) then
        addon.CompleteWaypoint(waypoint)
    end
end

function addon.AddWaypoint(waypoint)
    if not waypoint then return end
    table.insert(addon.activeWaypoints, waypoint)
    addon.updateMap = true
end

function addon.RemoveWaypoint(waypoint)
    if not waypoint then return end
    for i, wp in ipairs(addon.activeWaypoints) do
        if wp == waypoint then
            table.remove(addon.activeWaypoints, i)
            break
        end
    end
    addon.updateMap = true
end

function addon.ClearWaypoints()
    table.wipe(addon.activeWaypoints)
    addon.updateMap = true
end

local function GetWaypointTitle(element)
    local text = type(element.text) == "string" and element.text or ""
    text = text:gsub("|T[^|]+|t", "")
    text = text:gsub("|c%x%x%x%x%x%x%x%x", "")
    text = text:gsub("|cRXP_[A-Z_]+_", ""):gsub("|r", "")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    return text ~= "" and text or "Current task"
end

function addon.UpdateTaskWaypoint()

    table.wipe(addon.activeWaypoints)

    local guide = addon.currentGuide
    if not guide or not guide.steps then
        addon.updateMap = true
        return
    end

    local startIndex = (RXPCData and RXPCData.currentStep) or 1

    for i = startIndex, #guide.steps do

        local step = guide.steps[i]

        if step then

            for _, element in ipairs(step.elements or {}) do

                if (element.tag == "goto" or element.tag == "waypoint")
                and not element.completed
                and element.x
                and element.y then

                    addon.activeWaypoints[1] = {

                        x = tonumber(element.x),

                        y = tonumber(element.y),

                        zone = element.zone,

                        radius = (tonumber(element.radius) or 5) / 1000,

                        element = element,

                        title = GetWaypointTitle(element),

                    }

                    addon.updateMap = true

                    return

                end

            end

        end

    end

    addon.updateMap = true

end

function addon.CompleteWaypoint(waypoint)
    if not waypoint then return end
    addon.RemoveWaypoint(waypoint)
    if waypoint.element then
        waypoint.element.completed = true
        addon.updateSteps = true
    end
    if addon.UpdateTaskWaypoint then addon.UpdateTaskWaypoint() end
    if waypoint.onComplete then
        waypoint.onComplete()
    end
end

-- ============================================================
-- MAP UPDATE
-- ============================================================

addon.mapCache = {}
addon.updateMap = false

function addon.UpdateMap(force)
    if not force and not addon.updateMap then return end
    addon.updateMap = false

    addon.UpdateArrow()

    -- Обновляем метки на карте (если есть интеграция)
    if addon.UpdateMapMarkers then
        addon.UpdateMapMarkers()
    end
end

-- ============================================================
-- GOTO STEP PROCESSING
-- ============================================================

function addon.UpdateGotoSteps()
    if not addon.currentGuide then return end

    for _, step in ipairs(addon.currentGuide.steps) do
        if step.active then
            for _, element in ipairs(step.elements or {}) do
                if element.tag == "goto" and not element.completed then
                    -- Проверяем, достигнуты ли координаты
                    addon.functions.goto(element)
                end
            end
        end
    end
end

-- ============================================================
-- ZONE DETECTION
-- ============================================================

addon.currentZone = ""
addon.currentSubZone = ""

function addon.UpdateZone()
    local zone = GetRealZoneText()
    local subZone = GetSubZoneText()

    if zone ~= addon.currentZone or subZone ~= addon.currentSubZone then
        addon.currentZone = zone
        addon.currentSubZone = subZone
        addon.updateStepText = true
    end
end

-- ============================================================
-- DISTANCE CALCULATION
-- ============================================================

function addon.GetDistanceToPoint(x, y, zone)
    SetMapToCurrentZone()
    local px, py = GetPlayerMapPosition("player")
    if not px or not py then return nil end

    if zone and zone ~= GetRealZoneText() then
        return nil -- В другой зоне
    end

    local dx = (x / 100) - px
    local dy = (y / 100) - py
    return math.sqrt(dx * dx + dy * dy)
end

function addon.GetDistanceToWaypoint(waypoint)
    if not waypoint then return nil end
    return addon.GetDistanceToPoint(waypoint.x, waypoint.y, waypoint.zone)
end

-- ============================================================
-- CORPSE / DEATH POSITION
-- ============================================================

function addon.GetCorpsePosition()
    local cx, cy = GetCorpseMapPosition()
    if cx and cy then
        return {x = cx * 100, y = cy * 100}
    end
    return nil
end

function addon.GetDeathReleasePosition()
    local dx, dy = GetDeathReleasePosition()
    if dx and dy then
        return {x = dx * 100, y = dy * 100}
    end
    return nil
end

-- ============================================================
-- FLIGHT PATH DATA
-- ============================================================

addon.flightPaths = {}

function addon.LoadFlightPaths()
    -- Загрузка данных о маршрутах полётов
    -- В 3.3.5 используем стандартный API
    addon.flightPaths = RXPCData and RXPCData.flightPaths or {}
end

function addon.IsFlightPathKnown(nodeID)
    return addon.flightPaths[nodeID] == true
end

function addon.LearnFlightPath(nodeID)
    addon.flightPaths[nodeID] = true
    if RXPCData then
        RXPCData.flightPaths = addon.flightPaths
    end
end

-- ============================================================
-- INSTANCE / DUNGEON MAPS
-- ============================================================

addon.instanceMaps = {}

function addon.IsInInstance()
    local inInstance, instanceType = IsInInstance()
    return inInstance, instanceType
end

function addon.GetInstanceMap()
    local inInstance, instanceType = addon.IsInInstance()
    if not inInstance then return nil end

    local mapID = GetCurrentMapAreaID()
    return {
        mapID = mapID,
        type = instanceType,
    }
end

-- ============================================================
-- WORLD MAP INTEGRATION
-- ============================================================

function addon.SetWorldMapPoint(x, y, zone)
    -- Установка точки на карте мира
    -- В 3.3.5 используем стандартные методы
    if not WorldMapFrame then return end

    if zone then
        SetMapToCurrentZone()
    end
end

function addon.ClearWorldMapPoint()
    -- Очистка точки на карте мира
end

-- ============================================================
-- MINIMAP INTEGRATION
-- ============================================================

addon.minimapPins = {}

function addon.AddMinimapPin(x, y, zone, icon, title)
    local pin = {
        x = x,
        y = y,
        zone = zone,
        icon = icon,
        title = title,
    }
    table.insert(addon.minimapPins, pin)
    return pin
end

function addon.RemoveMinimapPin(pin)
    for i, p in ipairs(addon.minimapPins) do
        if p == pin then
            table.remove(addon.minimapPins, i)
            break
        end
    end
end

function addon.ClearMinimapPins()
    table.wipe(addon.minimapPins)
end

-- ============================================================
-- TAXI / FLIGHT MASTER
-- ============================================================

function addon.GetTaxiMap()
    -- Получение данных о такси
    local numNodes = NumTaxiNodes()
    local nodes = {}

    for i = 1, numNodes do
        local node = {
            index = i,
            name = TaxiNodeName(i),
            type = TaxiNodeGetType(i),
            x = TaxiNodePosition(i),
            y = select(2, TaxiNodePosition(i)),
        }
        table.insert(nodes, node)
    end

    return nodes
end

function addon.TakeTaxiNode(index)
    TakeTaxiNode(index)
end
