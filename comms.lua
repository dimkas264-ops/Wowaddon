local _, addon = ...

addon.comms = {}

-- Pretty print debug message
function addon.comms.PrettyPrint(msg, ...)
    if addon.settings and addon.settings.profile and addon.settings.profile.debug then
        print("|cff33ff99RXP|r: " .. string.format(msg, ...))
    end
end

-- Pretty debug (same as PrettyPrint)
function addon.comms.PrettyDebug(msg, ...)
    addon.comms.PrettyPrint(msg, ...)
end

-- Setup communications
function addon.comms:Setup()
    if addon.Comm and addon.Comm.Init then
        addon.Comm:Init()
    end

    -- Register addon prefix for addon messages
    local prefix = "RXPGuides"
    local success = C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix(prefix)
    if not success then
        -- Fallback for 3.3.5
        success = RegisterAddonMessagePrefix and RegisterAddonMessagePrefix(prefix)
    end

    if success then
        addon.comms.PrettyPrint("Communication prefix registered: %s", prefix)
    end
end

-- Send addon message
function addon.comms:SendMessage(msg, channel, target)
    channel = channel or "PARTY"
    local prefix = "RXPGuides"

    if SendAddonMessage then
        SendAddonMessage(prefix, msg, channel, target)
    end
end

-- Handle incoming addon messages
local commFrame = CreateFrame("Frame")
commFrame:RegisterEvent("CHAT_MSG_ADDON")
commFrame:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
    if prefix ~= "RXPGuides" then return end
    if sender == UnitName("player") then return end

    addon.comms.PrettyPrint("Received message from %s [%s]: %s", sender, channel, message)
end)
