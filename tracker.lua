local _, addon = ...

addon.tracker = {}

-- Setup tracker
function addon.tracker:SetupTracker()
    if not addon.settings.profile.enableTracker then
        return
    end

    -- Create tracker frame
    if not addon.trackerFrame then
        local frame = CreateFrame("Frame", "RXPTrackerFrame", UIParent)
        frame:SetSize(200, 300)
        frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -50, -150)
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.title:SetPoint("TOP", frame, "TOP", 0, -5)
        frame.title:SetText("RXP Tracker")

        frame.content = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        frame.content:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -25)
        frame.content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5)
        frame.content:SetJustifyH("LEFT")
        frame.content:SetJustifyV("TOP")

        addon.trackerFrame = frame
    end

    addon.trackerFrame:Show()
    addon.tracker:Update()
end

-- Update tracker display
function addon.tracker:Update()
    if not addon.trackerFrame or not addon.settings.profile.enableTracker then
        return
    end

    local text = ""

    if addon.currentGuide then
        text = text .. "Guide: " .. (addon.currentGuide.name or "Unknown") .. "\n"
        text = text .. "Step: " .. (RXPCData and RXPCData.currentStep or 1) .. "\n\n"

        -- Show active quest objectives
        if addon.questLogCache then
            for questID, info in pairs(addon.questLogCache) do
                if info and not info.complete then
                    local objectives = addon.GetQuestObjectives and addon.GetQuestObjectives(questID)
                    if objectives then
                        text = text .. (info.title or "Quest") .. ":\n"
                        for _, obj in ipairs(objectives) do
                            text = text .. "  " .. (obj.text or "") .. "\n"
                        end
                        text = text .. "\n"
                    end
                end
            end
        end
    else
        text = "No guide loaded\nRight-click RXP window to select a guide"
    end

    addon.trackerFrame.content:SetText(text)
end

-- Hook into quest updates
local trackerFrame = CreateFrame("Frame")
trackerFrame:RegisterEvent("QUEST_LOG_UPDATE")
trackerFrame:RegisterEvent("QUEST_WATCH_UPDATE")
trackerFrame:SetScript("OnEvent", function()
    if addon.tracker and addon.tracker.Update then
        addon.tracker:Update()
    end
end)
