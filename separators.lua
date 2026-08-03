local _, addon = ...

addon.separators = {}

-- Parse coordinates: .goto Zone,x,y[,radius]
addon.separators["goto"] = function(t, args)
    local zone, x, y, radius = args:match("^(.-),([%d%.%-]+),([%d%.%-]+),?([%d%.%-]*)$")
    if zone then
        t[1] = zone
        t[2] = tonumber(x)
        t[3] = tonumber(y)
        t[4] = tonumber(radius) or 5
    end
end

-- Parse quest accept: .accept QuestID[,NPC Name]
addon.separators["accept"] = function(t, args)
    local questId, npc = args:match("^(%d+)%s*,?%s*(.*)$")
    if questId then
        t[1] = tonumber(questId)
        t[2] = npc and npc:trim() or nil
    end
end

-- Parse quest turnin: .turnin QuestID[,NPC Name]
addon.separators["turnin"] = function(t, args)
    local questId, npc = args:match("^(%d+)%s*,?%s*(.*)$")
    if questId then
        t[1] = tonumber(questId)
        t[2] = npc and npc:trim() or nil
    end
end

-- Parse quest complete: .complete QuestID[,Objective Index]
addon.separators["complete"] = function(t, args)
    local questId, objIndex = args:match("^(%d+)%s*,?%s*(%d*)$")
    if questId then
        t[1] = tonumber(questId)
        t[2] = tonumber(objIndex) or 0
    end
end

-- Parse kill target: .kill NPC Name[,Count]
addon.separators["kill"] = function(t, args)
    local name, count = args:match("^(.-)%s*,?%s*(%d*)$")
    if name then
        t[1] = name:trim()
        t[2] = tonumber(count) or 1
    end
end

-- Parse item check: .item ItemID[,Count]
addon.separators["item"] = function(t, args)
    local itemId, count = args:match("^(%d+)%s*,?%s*(%d*)$")
    if itemId then
        t[1] = tonumber(itemId)
        t[2] = tonumber(count) or 1
    end
end

-- Parse equip check: .equip ItemID[,Slot]
addon.separators["equip"] = function(t, args)
    local itemId, slot = args:match("^(%d+)%s*,?%s*(%d*)$")
    if itemId then
        t[1] = tonumber(itemId)
        t[2] = tonumber(slot) or 0
    end
end

-- Parse money check: .money Amount
addon.separators["money"] = function(t, args)
    t[1] = tonumber(args) or 0
end

-- Parse level check: .reach Level
addon.separators["reach"] = function(t, args)
    t[1] = tonumber(args) or 1
end

-- Parse XP check: .xp Amount
addon.separators["xp"] = function(t, args)
    t[1] = tonumber(args) or 0
end

-- Parse reputation: .reputation FactionID,Value
addon.separators["reputation"] = function(t, args)
    local factionId, value = args:match("^(%d+)%s*,?%s*([%d%-]+)$")
    if factionId then
        t[1] = tonumber(factionId)
        t[2] = tonumber(value) or 0
    end
end

-- Parse skill: .skill SkillName,Level
addon.separators["skill"] = function(t, args)
    local skill, level = args:match("^(.-)%s*,%s*(%d+)$")
    if skill then
        t[1] = skill:trim()
        t[2] = tonumber(level) or 1
    end
end

-- Parse spell learn: .learn SpellID
addon.separators["learn"] = function(t, args)
    t[1] = tonumber(args) or 0
end

-- Parse spell check: .spell SpellID
addon.separators["spell"] = function(t, args)
    t[1] = tonumber(args) or 0
end

-- Parse talent: .talent TalentName[,Rank]
addon.separators["talent"] = function(t, args)
    local talent, rank = args:match("^(.-)%s*,?%s*(%d*)$")
    if talent then
        t[1] = talent:trim()
        t[2] = tonumber(rank) or 1
    end
end

-- Parse train: .train SpellID[,Rank]
addon.separators["train"] = function(t, args)
    local spellId, rank = args:match("^(%d+)%s*,?%s*(%d*)$")
    if spellId then
        t[1] = tonumber(spellId)
        t[2] = tonumber(rank) or 0
    end
end

-- Parse vendor: .vendor ItemID[,Count]
addon.separators["vendor"] = function(t, args)
    local itemId, count = args:match("^(%d+)%s*,?%s*(%d*)$")
    if itemId then
        t[1] = tonumber(itemId)
        t[2] = tonumber(count) or 1
    end
end

-- Parse home: .home Location Name
addon.separators["home"] = function(t, args)
    t[1] = args:trim()
end

-- Parse fly: .fly Destination
addon.separators["fly"] = function(t, args)
    t[1] = args:trim()
end

-- Parse FP: .fp NodeID
addon.separators["fp"] = function(t, args)
    t[1] = tonumber(args) or 0
end

-- Parse zone: .zone Zone Name
addon.separators["zone"] = function(t, args)
    t[1] = args:trim()
end

-- Parse subzone: .subzone Subzone Name
addon.separators["subzone"] = function(t, args)
    t[1] = args:trim()
end

-- Parse minimap: .minimap Minimap Zone Name
addon.separators["minimap"] = function(t, args)
    t[1] = args:trim()
end

-- Parse coord: .coord x,y[,radius]
addon.separators["coord"] = function(t, args)
    local x, y, radius = args:match("^([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*,?%s*([%d%.%-]*)$")
    if x then
        t[1] = tonumber(x)
        t[2] = tonumber(y)
        t[3] = tonumber(radius) or 5
    end
end

-- Parse timer: .timer Seconds
addon.separators["timer"] = function(t, args)
    t[1] = tonumber(args) or 0
end

-- Parse die: .die (no args)
addon.separators["die"] = function(t, args)
    -- No arguments needed
end

-- Parse skip: .skip (no args)
addon.separators["skip"] = function(t, args)
    -- No arguments needed
end

-- Parse hs: .hs (no args)
addon.separators["hs"] = function(t, args)
    -- No arguments needed
end

-- Parse boat: .boat Destination
addon.separators["boat"] = function(t, args)
    t[1] = args:trim()
end

-- Parse zeppelin: .zeppelin Destination
addon.separators["zeppelin"] = function(t, args)
    t[1] = args:trim()
end

-- Parse tram: .tram Destination
addon.separators["tram"] = function(t, args)
    t[1] = args:trim()
end

-- Parse portal: .portal Destination
addon.separators["portal"] = function(t, args)
    t[1] = args:trim()
end

-- Parse teleport: .teleport Destination
addon.separators["teleport"] = function(t, args)
    t[1] = args:trim()
end

-- Parse dungeon: .dungeon Dungeon Name
addon.separators["dungeon"] = function(t, args)
    t[1] = args:trim()
end

-- Parse raid: .raid Raid Name
addon.separators["raid"] = function(t, args)
    t[1] = args:trim()
end

-- Parse battleground: .battleground BG Name
addon.separators["battleground"] = function(t, args)
    t[1] = args:trim()
end

-- Parse arena: .arena Arena Name
addon.separators["arena"] = function(t, args)
    t[1] = args:trim()
end

-- Parse world: .world Event Name
addon.separators["world"] = function(t, args)
    t[1] = args:trim()
end

-- Parse pvp: .pvp (no args)
addon.separators["pvp"] = function(t, args)
    -- No arguments needed
end

-- Parse race: .race (no args)
addon.separators["race"] = function(t, args)
    -- No arguments needed
end

-- Parse class: .class (no args)
addon.separators["class"] = function(t, args)
    -- No arguments needed
end

-- Parse profession: .profession Profession Name[,Level]
addon.separators["profession"] = function(t, args)
    local prof, level = args:match("^(.-)%s*,?%s*(%d*)$")
    if prof then
        t[1] = prof:trim()
        t[2] = tonumber(level) or 1
    end
end

-- Parse faction: .faction Faction Name[,Standing]
addon.separators["faction"] = function(t, args)
    local faction, standing = args:match("^(.-)%s*,?%s*(%d*)$")
    if faction then
        t[1] = faction:trim()
        t[2] = tonumber(standing) or 4
    end
end

-- Parse honor: .honor Amount
addon.separators["honor"] = function(t, args)
    t[1] = tonumber(args) or 0
end

-- Parse pet: .pet Pet Name
addon.separators["pet"] = function(t, args)
    t[1] = args:trim()
end

-- Parse mount: .mount Mount Name
addon.separators["mount"] = function(t, args)
    t[1] = args:trim()
end

-- Parse achievement: .achievement AchievementID
addon.separators["achievement"] = function(t, args)
    t[1] = tonumber(args) or 0
end

-- Parse event: .event Event Name
addon.separators["event"] = function(t, args)
    t[1] = args:trim()
end

-- Parse custom: .custom (any args)
addon.separators["custom"] = function(t, args)
    t[1] = args:trim()
end

-- Parse text/note/warning/tip/info/link/image/video/audio (no args or text)
addon.separators["text"] = function(t, args)
    t[1] = args:trim()
end

addon.separators["note"] = addon.separators["text"]
addon.separators["warning"] = addon.separators["text"]
addon.separators["tip"] = addon.separators["text"]
addon.separators["info"] = addon.separators["text"]
addon.separators["link"] = addon.separators["text"]
addon.separators["image"] = addon.separators["text"]
addon.separators["video"] = addon.separators["text"]
addon.separators["audio"] = addon.separators["text"]

-- Parse collect: .collect ItemID[,Count[,Source]]
addon.separators["collect"] = function(t, args)
    local itemId, count, source = args:match("^(%d+)%s*,?%s*(%d*)%s*,?%s*(.*)$")
    if itemId then
        t[1] = tonumber(itemId)
        t[2] = tonumber(count) or 1
        t[3] = source and source:trim() or nil
    end
end

-- Parse interact: .interact NPC Name[,Action]
addon.separators["interact"] = function(t, args)
    local name, action = args:match("^(.-)%s*,?%s*(.*)$")
    if name then
        t[1] = name:trim()
        t[2] = action and action:trim() or nil
    end
end

-- Parse loot: .loot ItemID[,Count]
addon.separators["loot"] = function(t, args)
    local itemId, count = args:match("^(%d+)%s*,?%s*(%d*)$")
    if itemId then
        t[1] = tonumber(itemId)
        t[2] = tonumber(count) or 1
    end
end

-- Parse use: .use ItemID[,Target]
addon.separators["use"] = function(t, args)
    local itemId, target = args:match("^(%d+)%s*,?%s*(.*)$")
    if itemId then
        t[1] = tonumber(itemId)
        t[2] = target and target:trim() or nil
    end
end

-- Parse cast: .cast SpellID[,Target]
addon.separators["cast"] = function(t, args)
    local spellId, target = args:match("^(%d+)%s*,?%s*(.*)$")
    if spellId then
        t[1] = tonumber(spellId)
        t[2] = target and target:trim() or nil
    end
end

-- Parse buy: .buy ItemID[,Count[,Vendor]]
addon.separators["buy"] = function(t, args)
    local itemId, count, vendor = args:match("^(%d+)%s*,?%s*(%d*)%s*,?%s*(.*)$")
    if itemId then
        t[1] = tonumber(itemId)
        t[2] = tonumber(count) or 1
        t[3] = vendor and vendor:trim() or nil
    end
end

-- Parse sell: .sell ItemID[,Count]
addon.separators["sell"] = function(t, args)
    local itemId, count = args:match("^(%d+)%s*,?%s*(%d*)$")
    if itemId then
        t[1] = tonumber(itemId)
        t[2] = tonumber(count) or 999
    end
end

-- Parse destroy: .destroy ItemID[,Count]
addon.separators["destroy"] = function(t, args)
    local itemId, count = args:match("^(%d+)%s*,?%s*(%d*)$")
    if itemId then
        t[1] = tonumber(itemId)
        t[2] = tonumber(count) or 999
    end
end

-- Parse bank: .bank (no args)
addon.separators["bank"] = function(t, args)
    -- No arguments needed
end

-- Parse auction: .auction (no args)
addon.separators["auction"] = function(t, args)
    -- No arguments needed
end

-- Parse mail: .mail (no args)
addon.separators["mail"] = function(t, args)
    -- No arguments needed
end

-- Parse stable: .stable (no args)
addon.separators["stable"] = function(t, args)
    -- No arguments needed
end

-- Parse repair: .repair (no args)
addon.separators["repair"] = function(t, args)
    -- No arguments needed
end

-- Parse deathskip: .deathskip (no args)
addon.separators["deathskip"] = function(t, args)
    -- No arguments needed
end

-- Parse group: .group (no args)
addon.separators["group"] = function(t, args)
    -- No arguments needed
end

-- Parse solo: .solo (no args)
addon.separators["solo"] = function(t, args)
    -- No arguments needed
end

-- Parse rest: .rest (no args)
addon.separators["rest"] = function(t, args)
    -- No arguments needed
end

-- Parse tame: .tame NPCID
addon.separators["tame"] = function(t, args)
    t[1] = tonumber(args) or 0
end
