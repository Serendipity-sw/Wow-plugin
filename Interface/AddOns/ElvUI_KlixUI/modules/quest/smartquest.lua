local function DebugLog(...)
--[===[@debug@
printResult = "|cfff960d9KlixUI|r: "
for i,v in ipairs({...}) do
	printResult = printResult .. tostring(v) .. " "
end
DEFAULT_CHAT_FRAME:AddMessage(printResult)
--@end-debug@]===]
end

local KUI, E, L, V, P, G = unpack(select(2, ...))
local SQT = KUI:NewModule("SmartQuestTracker", 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')

local autoTracked = {}
local autoRemove
local autoSort
local removeComplete
local showDailies

-- control variables to pass arguments from on event handler to another
local skippedUpdate = false
local updateQuestIndex = nil
local newQuestIndex = nil
local doUpdate = false

local function getQuestInfo(index)
	local _, _, _, isHeader, _, isComplete, frequency, questID, _, _, isOnMap, _, isTask, _ = GetQuestLogTitle(index)

	if isHeader then
		return nil
	end

	local questMapId = GetQuestUiMapID(questID)
	local distance, reachable = GetDistanceSqToQuest(index)
	local areaid = C_Map.GetBestMapForUnit("player");

    local isDaily = frequency == LE_QUEST_FREQUENCY_DAILY
	local isWeekly =  frequency == LE_QUEST_FREQUENCY_WEEKLY

	local isCompleted = isComplete ~= nil

	local tagId = GetQuestTagInfo(questID)
	local isInstance = false
	if tagId then
	    isInstance = tagId == QUEST_TAG_DUNGEON or tagId == QUEST_TAG_HEROIC or tagId == QUEST_TAG_RAID or tagId == QUEST_TAG_RAID10 or tagId == QUEST_TAG_RAID25
	end

	return questID, questMapId, isOnMap, isCompleted, isDaily, isWeekly, isInstance, isTask
end

local function trackQuest(index, questID, markAutoTracked)
	if autoTracked[questID] ~= true and markAutoTracked then
		autoTracked[questID] = true
		AddQuestWatch(index)
	end

    if autoSort then
		SortQuestWatches()
	end
end

local function untrackQuest(index, questID)
	if autoTracked[questID] == true then
		RemoveQuestWatch(index)
		autoTracked[questID] = nil
	end

    if autoSort then
		SortQuestWatches()
	end
end

function SQT:untrackAllQuests()
	local numEntries, _ = GetNumQuestLogEntries()

	for index = 1, numEntries do
		local _, _, _, isHeader, _, _, _, _, _, _, _, _, _, _ = GetQuestLogTitle(index)
		if ( not isHeader) then
			RemoveQuestWatch(index)
		end
	end

	autoTracked = {}
end

function SQT:run_update()
	--[===[@debug@
	DebugLog("Running full update")
	--@end-debug@]===]
	SQT:RunUpdate()
end

function SQT:debugPrintQuestsHelper(onlyWatched)
	local areaid = C_Map.GetBestMapForUnit("player");
	print("#########################")
	print("Current MapID: " .. areaid)

	local inInstance, instanceType = IsInInstance()

	print("In instance: " .. tostring(inInstance))
	print("Instance type: " .. instanceType)

	local numEntries, numQuests = GetNumQuestLogEntries()
	print(numQuests .. " Quests in " .. numEntries .. " Entries.")
	local numWatches = GetNumQuestWatches()
	print(numWatches .. " Quests tracked.")
	print("#########################")

	for questIndex = 1, numEntries do
		local questID, questMapId, isOnMap, isCompleted, isDaily, isWeekly, isInstance, isWorldQuest = getQuestInfo(questIndex)
		if not (questID == nil) then
			if (not onlyWatched) or (onlyWatched and autoTracked[questID] == true) then
				print("#" .. questID .. " - |cffFF6A00" .. select(1, GetQuestLogTitle(questIndex)) .. "|r")
                print("MapID: " .. tostring(questMapId) .. " IsOnMap: " .. tostring(isOnMap) .. " isInstance: " .. tostring(isInstance))
				print("AutoTracked: " .. tostring(autoTracked[questID] == true) .. "isLocal: " .. tostring(((questMapId == 0 and isOnMap) or (questMapId == areaid)) and not (isInstance and not inInstance and not isCompleted)))
				print("Completed: ".. tostring(isCompleted) .. " Daily: " .. tostring(isDaily) .. " Weekly: " .. tostring(isWeekly) .. " WorldQuest: " .. tostring(isWorldQuest))
			end
		end
	end
end

--Function we can call when a setting changes.
function SQT:Update()
	autoRemove = SQT.db.AutoRemove
	autoSort =  SQT.db.AutoSort
	removeComplete = SQT.db.RemoveComplete
	showDailies = SQT.db.ShowDailies

    SQT:untrackAllQuests()
	SQT:run_update()
end

function SQT:RunUpdate()
	if self.update_running ~= true then
		self.update_running = true

		-- Update play information cache, so we don't run it for every quest
		self.areaID = C_Map.GetBestMapForUnit("player");
		self.inInstance = select(1, IsInInstance())

		--[===[@debug@
		DebugLog("SQT:RunUpdate")
		--@end-debug@]===]
		self:ScheduleTimer("PartialUpdate", 0.01, 1)
	else
		self.update_required = true
	end
end

function SQT:PartialUpdate(index)
	local numEntries, _ = GetNumQuestLogEntries()

	if index >= numEntries then
		--[===[@debug@
		DebugLog("Finished partial updates")
		--@end-debug@]===]

		if self.update_required == true then
			self.update_required = nil
			self.inInstance = select(1, IsInInstance())
			self.areaID = areaID
			--[===[@debug@
			DebugLog("Reschedule partial update")
			--@end-debug@]===]
			self:ScheduleTimer("PartialUpdate", 0.01, 1)
		else
			if autoSort then
				SortQuestWatches()
			end
			self.update_running = nil
		end

		return
	end

	local questID, questMapId, isOnMap, isCompleted, isDaily, isWeekly, isInstance, isWorldQuest = getQuestInfo(index)
	if not (questID == nil) then
		if isCompleted and removeComplete then
			untrackQuest(index, questID)
		elseif ((questMapId == 0 and isOnMap) or (questMapId == self.areaID)) and not (isInstance and not self.inInstance and not isCompleted) then
			trackQuest(index, questID, not isWorldQuest)
		elseif showDailies and isDaily and not inInstance then
			trackQuest(index, questID, not isWorldQuest)
		elseif showDailies and isWeekly then
			trackQuest(index, questID, not isWorldQuest)
		else
			untrackQuest(index, questID)
		end
	end

	self:ScheduleTimer("PartialUpdate", 0.01, index + 1)
end

-- event handlers

function SQT:QUEST_WATCH_UPDATE(event, questIndex)
	DebugLog("Update for quest:", questIndex)

	local questID, _, _, isCompleted, _, _, _, isWorldQuest = getQuestInfo(questIndex)
	if questID ~= nil then
		updateQuestIndex = nil
		if removeComplete and isCompleted then
			untrackQuest(questIndex, questID)
		elseif not isWorldQuest then
			trackQuest(questIndex, questID, not isWorldQuest)
		end
	end
end

function SQT:QUEST_LOG_UPDATE(event)
 	DebugLog("Running update for quests")
	-- SQT:run_update()
end

function SQT:QUEST_ACCEPTED(event, questIndex)
	DebugLog("Accepted new quest:", questIndex)

	local questID, _, _, isCompleted, _, _, _, isWorldQuest = getQuestInfo(questIndex)
	if questID ~= nil then
		updateQuestIndex = nil
		if removeComplete and isCompleted then
			untrackQuest(questIndex, questID)
		elseif not isWorldQuest then
			trackQuest(questIndex, questID, not isWorldQuest)
		end
	end
end

function SQT:QUEST_REMOVED(event, questIndex)
	DebugLog("REMOVED:", questIndex)
	autoTracked[questIndex] = nil
	-- SQT:run_update()
end

function SQT:ZONE_CHANGED()
	DebugLog("ZONE_CHANGED")
	SQT:run_update()
end

function SQT:ZONE_CHANGED_NEW_AREA()
	DebugLog("ZONE_CHANGED_NEW_AREA")
	SQT:run_update()
end

function SQT:Initialize()
	if not E.db.KlixUI.quest.smart.enable then return end
	
	SQT.db = E.db.KlixUI.quest.smart

	--Register event triggers
	SQT:RegisterEvent("ZONE_CHANGED")
	SQT:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	SQT:RegisterEvent("QUEST_WATCH_UPDATE")
	SQT:RegisterEvent("QUEST_LOG_UPDATE")
	SQT:RegisterEvent("QUEST_ACCEPTED")
	SQT:RegisterEvent("QUEST_REMOVED")
	
	function SQT:ForUpdateAll()
		SQT.db = E.db.KlixUI.quest.smart
		SQT:Update()
	end
end

KUI:RegisterModule(SQT:GetName())