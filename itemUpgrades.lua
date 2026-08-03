local _, addon = ...

addon.itemUpgrades = {}

function addon.itemUpgrades:Setup()
    addon.itemUpgrades.frame = CreateFrame("Frame", "RXPItemUpgrades")
end

function addon.itemUpgrades:IsUpgrade(itemLink1, itemLink2)
    if not itemLink1 or not itemLink2 then return false end
    local _, _, _, ilvl1 = GetItemInfo(itemLink1)
    local _, _, _, ilvl2 = GetItemInfo(itemLink2)
    return (ilvl2 or 0) > (ilvl1 or 0)
end

function addon.itemUpgrades:GetItemScore(itemLink)
    if not itemLink then return 0 end
    local _, _, _, ilvl, _, _, _, _, itemEquipLoc = GetItemInfo(itemLink)
    return (ilvl or 0) * 10
end
