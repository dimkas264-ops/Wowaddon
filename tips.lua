local _, addon = ...

addon.tips = {}

-- Setup tips system
function addon.tips:Setup()
    if not addon.settings.profile.enableTips then
        return
    end

    -- Create tips frame
    if not addon.tipsFrame then
        local frame = CreateFrame("Frame", "RXPTipsFrame", UIParent)
        frame:SetSize(300, 80)
        frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 150)
        frame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        })
        frame:SetBackdropColor(0, 0, 0, 0.8)
        frame:SetBackdropBorderColor(1, 0.82, 0, 1)

        frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.text:SetPoint("CENTER", frame, "CENTER", 0, 0)
        frame.text:SetWidth(280)
        frame.text:SetJustifyH("CENTER")
        frame.text:SetTextColor(1, 0.82, 0, 1)

        frame:Hide()
        addon.tipsFrame = frame
    end
end

-- Show a tip
function addon.tips:ShowTip(text, duration)
    if not addon.tipsFrame or not addon.settings.profile.enableTips then
        return
    end

    addon.tipsFrame.text:SetText(text)
    addon.tipsFrame:Show()

    -- Auto-hide after duration
    duration = duration or 5
    C_Timer = C_Timer or {}
    if C_Timer.After then
        C_Timer.After(duration, function()
            if addon.tipsFrame then
                addon.tipsFrame:Hide()
            end
        end)
    else
        -- Fallback for 3.3.5
        local f = CreateFrame("Frame")
        local elapsed = 0
        f:SetScript("OnUpdate", function(self, delta)
            elapsed = elapsed + delta
            if elapsed >= duration then
                self:SetScript("OnUpdate", nil)
                if addon.tipsFrame then
                    addon.tipsFrame:Hide()
                end
            end
        end)
    end
end

-- Hide tip
function addon.tips:HideTip()
    if addon.tipsFrame then
        addon.tipsFrame:Hide()
    end
end
