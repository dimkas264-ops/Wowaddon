local _, addon = ...

addon.talents = {}

function addon.talents:Setup()
    if not addon.talentFrame then
        addon.talentFrame = CreateFrame("Frame", "RXPTalentFrame")
    end
end

function addon.talents:GetPointsSpent(tabIndex)
    local name, icon, pointsSpent = GetTalentTabInfo(tabIndex)
    return pointsSpent or 0
end

function addon.talents:GetTotalPoints()
    local total = 0
    for i = 1, 3 do
        total = total + addon.talents:GetPointsSpent(i)
    end
    return total
end

function addon.talents:IsTalentLearned(talentName, rank)
    rank = rank or 1
    for tab = 1, GetNumTalentTabs() do
        for i = 1, GetNumTalents(tab) do
            local name, _, _, _, spent = GetTalentInfo(tab, i)
            if name == talentName and spent >= rank then
                return true
            end
        end
    end
    return false
end
