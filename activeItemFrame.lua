local _, addon = ...

function addon:CreateActiveItemFrame()
    if addon.activeItemFrame then return end

    local frame = CreateFrame("Frame", "RXPActiveItemFrame", UIParent)
    frame:SetSize(40, 40)
    frame:SetPoint("CENTER", UIParent, "CENTER", 200, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    frame.cooldown = CreateFrame("Cooldown", "$parentCooldown", frame, "CooldownFrameTemplate")
    frame.cooldown:SetAllPoints()

    frame:Hide()
    addon.activeItemFrame = frame
end

function addon.UpdateItemFrame()
    local frame = addon.activeItemFrame
    if not frame then return end

    local found = false
    for itemID, data in pairs(addon.activeItems or {}) do
        local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(itemID)
        if itemTexture then
            frame.icon:SetTexture(itemTexture)
            frame:Show()
            found = true
            break
        end
    end

    if not found then
        frame:Hide()
    end
end
