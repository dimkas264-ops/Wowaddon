-- GuideLoaderFile.lua

print("|cff33ff99RXP|r: GuideLoaderFile starting...")

-- Ищем addon среди всех глобальных таблиц
local addon = nil
for k, v in pairs(_G) do
    if type(v) == "table" and type(v.ParseGuide) == "function" and type(v.AddGuide) == "function" then
        addon = v
        print("|cff33ff99RXP|r: Found addon in:", k)
        break
    end
end

if not addon then
    print("|cff33ff99RXP|r: |cffff0000CRITICAL: addon not found anywhere|r")
    print("|cff33ff99RXP|r: Available tables with ParseGuide:")
    for k, v in pairs(_G) do
        if type(v) == "table" and v.ParseGuide then
            print("  ", k)
        end
    end
    return
end

print("|cff33ff99RXP|r: addon found, ParseGuide type:", type(addon.ParseGuide))

-- Создаём глобальную таблицу ДО загрузки файлов гайдов
_G.RXPGuides = _G.RXPGuides or {}

_G.RXPGuides.RegisterGuide = function(guideString)
    print("|cff33ff99RXP|r: RegisterGuide called!")
    
    if not guideString or guideString == "" then
        print("|cff33ff99RXP|r: Empty guide string")
        return
    end
    
    -- Ручной парсинг заголовка
    local guide = {}
    local steps = {}
    local currentStep = nil
    local inHeader = true
    
    for line in guideString:gmatch("[^\r\n]+") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        
        if line == "" then
            -- пропускаем пустые строки
        elseif line:sub(1, 4) == "step" then
            inHeader = false
currentStep = {elements = {}, index = #steps + 1}
table.insert(steps, currentStep)
        elseif inHeader then
            local tag, value = line:match("^#(%S+)%s+(.*)")
            if tag then
                guide[tag] = value
                if tag == "name" then
                    addon.currentGuideName = value
                end
            end
        elseif currentStep then
            local ok, err = pcall(function()
                addon.ParseLine(line, currentStep)
            end)
            if not ok then
                print("|cff33ff99RXP|r: ParseLine error:", err)
            end
        end
    end
    
    guide.steps = steps
    guide.group = guide.group or "Unknown"
    guide.name = guide.name or "Unknown"
    guide.displayname = guide.displayname or guide.name
    guide.key = addon.BuildGuideKey(guide)
    guide.version = 0
    
    addon.AddGuide(guide)
    print("|cff33ff99RXP|r: Loaded guide:", guide.name)
end

print("|cff33ff99RXP|r: File guide loader ready")
