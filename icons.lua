local _, addon = ...

addon.icons = {
    -- Navigation
    ["goto"] = "|TInterface\\MINIMAP\\TRACKING\\OBJECTICONS:0:0:0:0:256:64:0:18:0:18|t",
    ["coord"] = "|TInterface\\MINIMAP\\TRACKING\\OBJECTICONS:0:0:0:0:256:64:0:18:0:18|t",
    ["zone"] = "|TInterface\\MINIMAP\\TRACKING\\FlightMaster:0|t",
    ["subzone"] = "|TInterface\\MINIMAP\\TRACKING\\FlightMaster:0|t",
    ["minimap"] = "|TInterface\\MINIMAP\\TRACKING\\FlightMaster:0|t",

    -- Quests
    ["accept"] = "|TInterface\\GossipFrame\\AvailableQuestIcon:0|t",
    ["turnin"] = "|TInterface\\GossipFrame\\ActiveQuestIcon:0|t",
    ["complete"] = "|TInterface\\GossipFrame\\IncompleteQuestIcon:0|t",
    ["skip"] = "|TInterface\\Buttons\\UI-GroupLoot-Pass-Up:0|t",

    -- Combat
    ["kill"] = "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8:0|t",
    ["die"] = "|TInterface\\TARGETINGFRAME\\UI-TargetingFrame-Skull:0|t",
    ["deathskip"] = "|TInterface\\TARGETINGFRAME\\UI-TargetingFrame-Skull:0|t",

    -- Travel
    ["fly"] = "|TInterface\\MINIMAP\\TRACKING\\FlightMaster:0|t",
    ["fp"] = "|TInterface\\MINIMAP\\TRACKING\\FlightMaster:0|t",
    ["boat"] = "|TInterface\\MINIMAP\\TRACKING\\StableMaster:0|t",
    ["zeppelin"] = "|TInterface\\MINIMAP\\TRACKING\\StableMaster:0|t",
    ["tram"] = "|TInterface\\MINIMAP\\TRACKING\\StableMaster:0|t",
    ["portal"] = "|TInterface\\MINIMAP\\TRACKING\\Ammunition:0|t",
    ["teleport"] = "|TInterface\\MINIMAP\\TRACKING\\Ammunition:0|t",
    ["hs"] = "|TInterface\\ICONS\\INV_Misc_Rune_01:0|t",
    ["home"] = "|TInterface\\ICONS\\INV_Misc_Rune_01:0|t",

    -- NPC interactions
    ["train"] = "|TInterface\\MINIMAP\\TRACKING\\Profession:0|t",
    ["vendor"] = "|TInterface\\MINIMAP\\TRACKING\\Reagents:0|t",
    ["repair"] = "|TInterface\\MINIMAP\\TRACKING\\Reagents:0|t",
    ["bank"] = "|TInterface\\MINIMAP\\TRACKING\\Banker:0|t",
    ["auction"] = "|TInterface\\MINIMAP\\TRACKING\\Auctioneer:0|t",
    ["mail"] = "|TInterface\\MINIMAP\\TRACKING\\Mailbox:0|t",
    ["stable"] = "|TInterface\\MINIMAP\\TRACKING\\StableMaster:0|t",
    ["tame"] = "|TInterface\\MINIMAP\\TRACKING\\StableMaster:0|t",

    -- Items
    ["item"] = "|TInterface\\ICONS\\INV_Misc_Bag_08:0|t",
    ["equip"] = "|TInterface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle:0|t",
    ["collect"] = "|TInterface\\ICONS\\INV_Misc_Bag_08:0|t",

    -- Spells/Talents
    ["learn"] = "|TInterface\\ICONS\\Spell_Holy_SpiritualGuidence:0|t",
    ["spell"] = "|TInterface\\ICONS\\INV_Scroll_01:0|t",
    ["talent"] = "|TInterface\\ICONS\\Ability_Marksmanship:0|t",

    -- Progress
    ["reach"] = "|TInterface\\ICONS\\Achievement_Level_10:0|t",
    ["xp"] = "|TInterface\\ICONS\\XP_ICON:0|t",
    ["reputation"] = "|TInterface\\ICONS\\Achievement_Reputation_01:0|t",
    ["skill"] = "|TInterface\\ICONS\\Trade_BlackSmithing:0|t",
    ["money"] = "|TInterface\\ICONS\\INV_Misc_Coin_01:0|t",

    -- Social
    ["group"] = "|TInterface\\ICONS\\Achievement_Reputation_08:0|t",
    ["solo"] = "|TInterface\\ICONS\\Achievement_Reputation_08:0|t",
    ["rest"] = "|TInterface\\ICONS\\Spell_Nature_Sleep:0|t",

    -- Instances
    ["dungeon"] = "|TInterface\\MINIMAP\\TRACKING\\None:0|t",
    ["raid"] = "|TInterface\\MINIMAP\\TRACKING\\None:0|t",
    ["battleground"] = "|TInterface\\MINIMAP\\TRACKING\\None:0|t",
    ["arena"] = "|TInterface\\MINIMAP\\TRACKING\\None:0|t",

    -- Misc
    ["pet"] = "|TInterface\\MINIMAP\\TRACKING\\StableMaster:0|t",
    ["mount"] = "|TInterface\\ICONS\\Ability_Mount_RidingHorse:0|t",
    ["achievement"] = "|TInterface\\ICONS\\Achievement_Quests_Completed_04:0|t",
    ["event"] = "|TInterface\\ICONS\\INV_Misc_Note_01:0|t",
    ["timer"] = "|TInterface\\ICONS\\INV_Misc_PocketWatch_01:0|t",
    ["world"] = "|TInterface\\ICONS\\Achievement_WorldEvent_Brewfest:0|t",
    ["pvp"] = "|TInterface\\ICONS\\Achievement_Level_10:0|t",
    ["race"] = "|TInterface\\ICONS\\Achievement_Character_Orc_Male:0|t",
    ["class"] = "|TInterface\\ICONS\\INV_Sword_04:0|t",
    ["profession"] = "|TInterface\\MINIMAP\\TRACKING\\Profession:0|t",
    ["faction"] = "|TInterface\\ICONS\\Achievement_Reputation_01:0|t",
    ["honor"] = "|TInterface\\ICONS\\Achievement_LegendaryRaid:0|t",
    ["custom"] = "|TInterface\\ICONS\\INV_Misc_Note_01:0|t",

    -- Text elements
    ["text"] = "",
    ["note"] = "|TInterface\\ICONS\\INV_Misc_Note_01:0|t",
    ["warning"] = "|TInterface\\DialogFrame\\UI-Dialog-Icon-AlertNew:0|t",
    ["tip"] = "|TInterface\\ICONS\\INV_Misc_Lantern_01:0|t",
    ["info"] = "|TInterface\\ICONS\\INV_Misc_Book_09:0|t",
    ["link"] = "|TInterface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up:0|t",
    ["image"] = "|TInterface\\ICONS\\INV_Misc_Film_01:0|t",
    ["video"] = "|TInterface\\ICONS\\INV_Misc_Film_01:0|t",
    ["audio"] = "|TInterface\\ICONS\\INV_Misc_Drum_01:0|t",
}

-- Events for tags
addon.functions.events = {
    ["goto"] = {"PLAYER_ENTERING_WORLD", "ZONE_CHANGED"},
    ["accept"] = "QUEST_LOG_UPDATE",
    ["turnin"] = "QUEST_LOG_UPDATE",
    ["complete"] = "QUEST_LOG_UPDATE",
    ["item"] = "BAG_UPDATE_DELAYED",
    ["equip"] = {"UNIT_INVENTORY_CHANGED", "PLAYER_EQUIPMENT_CHANGED"},
    ["money"] = "PLAYER_MONEY",
    ["reach"] = "PLAYER_LEVEL_UP",
    ["xp"] = "PLAYER_XP_UPDATE",
    ["reputation"] = "UPDATE_FACTION",
    ["skill"] = "SKILL_LINES_CHANGED",
    ["learn"] = {"SPELLS_CHANGED", "LEARNED_SPELL_IN_TAB"},
    ["spell"] = {"SPELLS_CHANGED", "LEARNED_SPELL_IN_TAB"},
    ["talent"] = "CHARACTER_POINTS_CHANGED",
    ["home"] = "HEARTHSTONE_BOUND",
    ["train"] = "TRAINER_SHOW",
    ["vendor"] = {"MERCHANT_SHOW", "MERCHANT_CLOSED"},
    ["repair"] = {"MERCHANT_SHOW", "MERCHANT_CLOSED"},
    ["die"] = {"PLAYER_DEAD", "PLAYER_UNGHOST"},
    ["group"] = {"GROUP_ROSTER_UPDATE", "PARTY_MEMBERS_CHANGED"},
    ["solo"] = {"GROUP_ROSTER_UPDATE", "PARTY_MEMBERS_CHANGED"},
    ["rest"] = {"PLAYER_UPDATE_RESTING", "PLAYER_XP_UPDATE"},
    ["fly"] = {"TAXIMAP_OPENED", "TAXIMAP_CLOSED"},
    ["fp"] = "TAXIMAP_OPENED",
    ["mount"] = {"COMPANION_UPDATE", "MOUNT_JOURNAL_USABILITY_CHANGED"},
    ["pet"] = "UNIT_PET",
    ["achievement"] = "ACHIEVEMENT_EARNED",
    ["timer"] = "OnUpdate",
    ["zone"] = {"ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA"},
    ["subzone"] = {"ZONE_CHANGED", "ZONE_CHANGED_INDOORS"},
    ["minimap"] = {"ZONE_CHANGED", "ZONE_CHANGED_INDOORS"},
    ["dungeon"] = {"PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA"},
    ["raid"] = {"PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA"},
    ["battleground"] = {"PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA"},
    ["arena"] = {"PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA"},
    ["world"] = "WORLD_STATE_UI_TIMER_UPDATE",
    ["pvp"] = {"PLAYER_FLAGS_CHANGED", "UNIT_FACTION"},
    ["profession"] = "SKILL_LINES_CHANGED",
    ["faction"] = "UPDATE_FACTION",
    ["honor"] = {"HONOR_CURRENCY_UPDATE", "CURRENCY_DISPLAY_UPDATE"},
    ["event"] = "PLAYER_ENTERING_WORLD",
    ["custom"] = "OnUpdate",
}
