local _, addon = ...

addon.tickers = addon.tickers or {}

-- Setup ticker loops (called from OnEnable)
function addon.tickers:SetupTickerLoops()
    local updateFrequency = 0.075
    if addon.settings and addon.settings.profile and addon.settings.profile.updateFrequency then
        updateFrequency = math.max(addon.settings.profile.updateFrequency / 1000, 0.005)
    end

    self.tickRate = 1 / updateFrequency

    -- Create main update frame
    if not self.updateFrame then
        self.updateFrame = CreateFrame("Frame", "RXPTickersFrame")
        self.updateFrame.elapsed = 0
        self.updateFrame:SetScript("OnUpdate", function(frame, elapsed)
            frame.elapsed = frame.elapsed + elapsed
            if frame.elapsed >= updateFrequency then
                frame.elapsed = 0
                if addon.LegacyUpdateLoop then
                    addon.LegacyUpdateLoop()
                end
            end
        end)
    end
end

-- Should continue processing?
function addon.tickers:ShouldContinue()
    if addon.isHidden then
        return false, "hidden"
    end
    return true
end

-- Cycle functions called from LegacyUpdateLoop
function addon.tickers.CycleZero()
    -- Update goto steps
    if addon.UpdateGotoSteps then
        addon.UpdateGotoSteps()
    end
end

function addon.tickers.CycleThree()
    -- Quest auto-accept
    if addon.questAutoAccept then
        addon.questAutoAccept = false
        if addon.QuestAutomation then
            addon.QuestAutomation()
        end
    end
    -- Map update
    if addon.updateMap then
        addon.UpdateMap(true)
    end
end

function addon.tickers.CycleFour()
    -- Process message queue
    if addon.ProcessMessageQueue then
        addon.ProcessMessageQueue()
    end
    -- Update scheduled tasks
    if addon.UpdateScheduledTasks then
        addon.UpdateScheduledTasks()
    end
    -- Clear quest cache
    if addon.ClearQuestCache then
        addon.ClearQuestCache()
    end
end

function addon.tickers.CycleSixteen()
    -- Update inactive quests
    if addon.updateInactiveQuest then
        local activeQuestUpdate = 0
        local deletedIndexes = {}

        for i, ref in ipairs(addon.updateInactiveQuest) do
            activeQuestUpdate = activeQuestUpdate + 1
            if activeQuestUpdate > 3 then
                break
            else
                if addon.UpdateQuestCompletionData then
                    addon.UpdateQuestCompletionData(ref)
                end
                table.insert(deletedIndexes, i)
            end
        end

        for i = #deletedIndexes, 1, -1 do
            table.remove(addon.updateInactiveQuest, deletedIndexes[i])
        end
    end
end

function addon.tickers.CycleThirty()
    -- Update current step frame text
    if addon.RXPFrame and addon.RXPFrame.CurrentStepFrame and addon.RXPFrame.CurrentStepFrame.UpdateText then
        addon.RXPFrame.CurrentStepFrame.UpdateText()
    end
end

-- Step completion update
function addon.UpdateStepCompletion()
    if not addon.currentGuide then
        addon.updateSteps = false
        return
    end

    local allComplete = true
    local guide = addon.currentGuide

    for _, step in ipairs(guide.steps or {}) do
        if step.active and not step.completed then
            local stepComplete = true

            for _, element in ipairs(step.elements or {}) do
                if element.tag and addon.functions[element.tag] then
                    local result = addon.functions[element.tag](element)
                    if not result and not element.optional then
                        stepComplete = false
                    end
                end
            end

            if stepComplete then
                step.completed = true
            else
                allComplete = false
            end
        end
    end

    addon.updateSteps = not allComplete

    -- Check if current step is complete and advance
    local currentStep = guide.steps[RXPCData and RXPCData.currentStep or 1]
    if currentStep and currentStep.completed and currentStep.active then
        addon.loadNextStep = true
    end
end

-- Clear quest cache
function addon.ClearQuestCache()
    -- Placeholder for cache clearing logic
end

-- Update quest completion data
function addon.UpdateQuestCompletionData(ref)
    if not ref or not ref.element then return end
    local element = ref.element

    if element.tag and addon.functions[element.tag] then
        addon.functions[element.tag](element)
    end
end
