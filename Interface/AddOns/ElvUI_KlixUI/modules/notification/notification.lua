local KUI, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule("KuiSkins")
local NF = KUI:NewModule("Notification", "AceEvent-3.0", "AceHook-3.0")
local CH = E:GetModule("Chat")
local S = E:GetModule("Skins")
NF.modName = L["Notification"]

-- Credits RealUI

--Cache global variables
--Lua functions
local _G = _G
local select, unpack, type, pairs, ipairs, tostring, next = select, unpack, type, pairs, ipairs, tostring, next
local table = table
local tinsert, tremove = table.insert, table.remove
local floor = math.floor
local format, find, gsub, sub = string.format, string.find, string.gsub, string.sub

--WoW API / Variables
local CreateFrame = CreateFrame
local UnitIsAFK = UnitIsAFK
local GetScreenWidth = GetScreenWidth
local IsShiftKeyDown = IsShiftKeyDown
local HasNewMail = HasNewMail
local GetAtlasInfo = GetAtlasInfo
local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetObjectIconTextureCoords = GetObjectIconTextureCoords
local GetInstanceInfo = GetInstanceInfo
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemDurability = GetInventoryItemDurability
local GetLFGDungeonInfo = GetLFGDungeonInfo
local GetRealmName = GetRealmName
local GetTime = GetTime
local C_Calendar_GetDate = C_Calendar.GetDate
local C_Calendar_GetNumGuildEvents = C_Calendar.GetNumGuildEvents
local C_Calendar_GetGuildEventInfo = C_Calendar.GetGuildEventInfo
local C_Calendar_GetNumDayEvents = C_Calendar.GetNumDayEvents
local C_Calendar_GetDayEvent = C_Calendar.GetDayEvent
local C_Calendar_GetNumPendingInvites = C_Calendar.GetNumPendingInvites
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Scenario_GetInfo = C_Scenario.GetInfo
local C_VignetteInfo_GetVignetteInfo = C_VignetteInfo.GetVignetteInfo
local InCombatLockdown = InCombatLockdown
local LoadAddOn = LoadAddOn
local C_Vignettes = C_Vignettes
local PlaySoundFile = PlaySoundFile
local PlaySound = PlaySound
local C_Timer = C_Timer
local SocialQueueUtil_SortGroupMembers = SocialQueueUtil_SortGroupMembers
--local C_VignettesGetVignetteInfoFromInstanceID = C_Vignettes.GetVignetteInfoFromInstanceID
local C_LFGListGetActivityInfo = C_LFGList.GetActivityInfo
local C_LFGListGetSearchResultInfo = C_LFGList.GetSearchResultInfo
local C_SocialQueueGetGroupMembers = C_SocialQueue.GetGroupMembers
local C_SocialQueueGetGroupQueues = C_SocialQueue.GetGroupQueues
local C_PvPGetBrawlInfo = C_PvP.GetBrawlInfo
local GetGameTime = GetGameTime
local CreateAnimationGroup = CreateAnimationGroup
local CalendarGetAbsMonth = CalendarGetAbsMonth
local BNGetNumFriends = BNGetNumFriends
local BNGetFriendInfo = BNGetFriendInfo
local BNGetGameAccountInfo = BNGetGameAccountInfo
local SOCIAL_QUEUE_QUEUED_FOR = SOCIAL_QUEUE_QUEUED_FOR:gsub(':%s?$','') --some language have `:` on end
local IsInRaid = IsInRaid

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: SLASH_TESTNOTIFICATION1, MAIL_LABEL, HAVE_MAIL, MINIMAP_TRACKING_REPAIR, CalendarFrame
-- GLOBALS: CALENDAR, Calendar_Toggle, BAG_UPDATE, BACKPACK_CONTAINER, NUM_BAG_SLOTS, ToggleBackpack
-- GLOBALS: SocialQueueUtil_GetQueueName, LFG_LIST_AND_MORE, UNKNOWN, SocialQueueUtil_SortGroupMembers
-- GLOBALS: enable

local bannerWidth = 255
local bannerHeight = 68
local max_active_toasts = 3
local fadeout_delay = 5
local toasts = {}
local activeToasts = {}
local queuedToasts = {}
local anchorFrame
local alertBagsFull
local shouldAlertBags = false

local VignetteExclusionMapIDs = {
	[579] = true, -- Lunarfall: Alliance garrison
	[585] = true, -- Frostwall: Horde garrison
	[646] = true, -- Scenario: The Broken Shore
}

function NF:SpawnToast(toast)
	if not toast then return end

	if #activeToasts >= max_active_toasts then
		tinsert(queuedToasts, toast)

		return false
	end

	if UnitIsAFK("player") then
		tinsert(queuedToasts, toast)
		self:RegisterEvent("PLAYER_FLAGS_CHANGED")

		return false
	end

	local YOffset = 0
	if E:GetScreenQuadrant(anchorFrame):find("TOP") then
		YOffset = -54
	else
		YOffset = 54
	end

	toast:ClearAllPoints()
	if #activeToasts > 0 then
		if E:GetScreenQuadrant(anchorFrame):find("TOP") then
			toast:SetPoint("TOP", activeToasts[#activeToasts], "BOTTOM", 0, -4 - YOffset)
		else
			toast:SetPoint("BOTTOM", activeToasts[#activeToasts], "TOP", 0, 4 - YOffset)
		end
	else
		toast:SetPoint("TOP", anchorFrame, "TOP", 0, 1 - YOffset)
	end

	tinsert(activeToasts, toast)

	toast:Show()
	toast.AnimIn.AnimMove:SetOffset(0, YOffset)
	toast.AnimOut.AnimMove:SetOffset(0, -YOffset)
	toast.AnimIn:Play()
	toast.AnimOut:Play()
	
	if NF.db.noSound ~= true then
		PlaySound(18019, "Master")
	end
end

function NF:RefreshToasts()
	for i = 1, #activeToasts do
		local activeToast = activeToasts[i]
		local YOffset, _ = 0
		if activeToast.AnimIn.AnimMove:IsPlaying() then
			_, YOffset = activeToast.AnimIn.AnimMove:GetOffset()
		end
		if activeToast.AnimOut.AnimMove:IsPlaying() then
			_, YOffset = activeToast.AnimOut.AnimMove:GetOffset()
		end

		activeToast:ClearAllPoints()

		if i == 1 then
			activeToast:SetPoint("TOP", anchorFrame, "TOP", 0, 1 - YOffset)
		else
			if E:GetScreenQuadrant(anchorFrame):find("TOP") then
				activeToast:SetPoint("TOP", activeToasts[i - 1], "BOTTOM", 0, -4 - YOffset)
			else
				activeToast:SetPoint("BOTTOM", activeToasts[i - 1], "TOP", 0, 4 - YOffset)
			end
		end
	end

	local queuedToast = tremove(queuedToasts, 1)

	if queuedToast then
		self:SpawnToast(queuedToast)
	end
end

function NF:HideToast(toast)
	for i, activeToast in pairs(activeToasts) do
		if toast == activeToast then
			tremove(activeToasts, i)
		end
	end
	tinsert(toasts, toast)
	toast:Hide()
	C_Timer.After(0.1, function() self:RefreshToasts() end)
end

local function ToastButtonAnimOut_OnFinished(self)
	NF:HideToast(self:GetParent())
end

function NF:CreateToast()
	local toast = tremove(toasts, 1)

	toast = CreateFrame("Frame", nil, E.UIParent)
	toast:SetFrameStrata("HIGH")
	toast:SetSize(bannerWidth, bannerHeight)
	toast:SetPoint("TOP", E.UIParent, "TOP")
	toast:Hide()
	KS:CreateBD(toast, .45)
	toast:Styling()
	toast:CreateCloseButton(10)

	local icon = toast:CreateTexture(nil, "OVERLAY")
	icon:SetSize(32, 32)
	icon:SetPoint("LEFT", toast, "LEFT", 9, 0)
	KS:CreateBG(icon)
	toast.icon = icon

	local sep = toast:CreateTexture(nil, "BACKGROUND")
	sep:SetSize(2, bannerHeight)
	sep:SetPoint("LEFT", icon, "RIGHT", 9, 0)
	sep:SetColorTexture(unpack(E["media"].rgbvaluecolor))

	local title = KUI:CreateText(toast, "OVERLAY", 11, "OUTLINE")
	title:SetShadowOffset(1, -1)
	title:SetPoint("TOPLEFT", sep, "TOPRIGHT", 3, -6)
	title:SetPoint("TOP", toast, "TOP", 0, 0)
	title:SetJustifyH("LEFT")
	title:SetNonSpaceWrap(true)
	toast.title = title

	local text = KUI:CreateText(toast, "OVERLAY", 10, nil)
	text:SetShadowOffset(1, -1)
	text:SetPoint("BOTTOMLEFT", sep, "BOTTOMRIGHT", 3, 9)
	text:SetPoint("RIGHT", toast, -9, 0)
	text:SetJustifyH("LEFT")
	text:SetWidth(toast:GetRight() - sep:GetLeft() - 5)
	toast.text = text

	toast.AnimIn = CreateAnimationGroup(toast)

	local animInAlpha = toast.AnimIn:CreateAnimation("Fade")
	animInAlpha:SetOrder(1)
	animInAlpha:SetChange(1)
	animInAlpha:SetDuration(0.5)
	toast.AnimIn.AnimAlpha = animInAlpha

	local animInMove = toast.AnimIn:CreateAnimation("Move")
	animInMove:SetOrder(1)
	animInMove:SetDuration(0.5)
	animInMove:SetSmoothing("Out")
	animInMove:SetOffset(-bannerWidth, 0)
	toast.AnimIn.AnimMove = animInMove

	toast.AnimOut = CreateAnimationGroup(toast)

	local animOutSleep = toast.AnimOut:CreateAnimation("Sleep")
	animOutSleep:SetOrder(1)
	animOutSleep:SetDuration(fadeout_delay)
	toast.AnimOut.AnimSleep = animOutSleep

	local animOutAlpha = toast.AnimOut:CreateAnimation("Fade")
	animOutAlpha:SetOrder(2)
	animOutAlpha:SetChange(0)
	animOutAlpha:SetDuration(0.5)
	toast.AnimOut.AnimAlpha = animOutAlpha

	local animOutMove = toast.AnimOut:CreateAnimation("Move")
	animOutMove:SetOrder(2)
	animOutMove:SetDuration(0.5)
	animOutMove:SetSmoothing("In")
	animOutMove:SetOffset(bannerWidth, 0)
	toast.AnimOut.AnimMove = animOutMove

	toast.AnimOut.AnimAlpha:SetScript("OnFinished", ToastButtonAnimOut_OnFinished)

	toast:SetScript("OnEnter", function(self)
		self.AnimOut:Stop()
	end)

	toast:SetScript("OnLeave", function(self)
		self.AnimOut:Play()
	end)

	toast:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and self.clickFunc then
			self.clickFunc()
		end
	end)

	return toast
end

function NF:DisplayToast(name, message, clickFunc, texture, ...)
	local toast = self:CreateToast()

	if type(clickFunc) == "function" then
		toast.clickFunc = clickFunc
	else
		toast.clickFunc = nil
	end

	if texture then
		if GetAtlasInfo(texture) then
			toast.icon:SetAtlas(texture)
		else
			toast.icon:SetTexture(texture)

			if ... then
				toast.icon:SetTexCoord(...)
			else
				toast.icon:SetTexCoord(unpack(E.TexCoords))
			end
		end
	else
		toast.icon:SetTexture("Interface\\Icons\\achievement_general")
		toast.icon:SetTexCoord(unpack(E.TexCoords))
	end

	toast.title:SetText(name)
	toast.text:SetText(message)

	self:SpawnToast(toast)
end

function NF:PLAYER_FLAGS_CHANGED(event)
	self:UnregisterEvent(event)
	for i = 1, max_active_toasts - #activeToasts do
		self:RefreshToasts()
	end
end

function NF:PLAYER_REGEN_ENABLED()
	for i = 1, max_active_toasts - #activeToasts do
		self:RefreshToasts()
	end
end

-- Test function
local function testCallback()
	KUI:Print("Banner clicked!")
end

SlashCmdList.TESTNOTIFICATION = function(b)
	NF:DisplayToast(KUI:cOption("KlixUI:"), L["This is an example of a notification."], testCallback, b == "true" and "INTERFACE\\ICONS\\SPELL_FROST_ARCTICWINDS" or nil, .08, .92, .08, .92)
end
SLASH_TESTNOTIFICATION1 = "/testnotification"

local hasMail = false
function NF:UPDATE_PENDING_MAIL()
	if NF.db.enable ~= true or NF.db.mail ~= true then return end
	local newMail = HasNewMail()
	if hasMail ~= newMail then
		hasMail = newMail
		if hasMail then
			self:DisplayToast(format("|cfff9ba22%s|r", MAIL_LABEL), HAVE_MAIL, nil, "Interface\\Icons\\inv_letter_15", .08, .92, .08, .92)
			if NF.db.noSound ~= true then
				PlaySoundFile([[Interface\AddOns\ElvUI_KlixUI\media\sounds\mail.mp3]])
			end
			if NF.db.message then 
				KUI:Print(L["You have a new mail!"])
			end
		end
	end
end

local showRepair = true

local Slots = {
	[1] = {1, INVTYPE_HEAD, 1000},
	[2] = {3, INVTYPE_SHOULDER, 1000},
	[3] = {5, INVTYPE_ROBE, 1000},
	[4] = {6, INVTYPE_WAIST, 1000},
	[5] = {9, INVTYPE_WRIST, 1000},
	[6] = {10, INVTYPE_HAND, 1000},
	[7] = {7, INVTYPE_LEGS, 1000},
	[8] = {8, INVTYPE_FEET, 1000},
	[9] = {16, INVTYPE_WEAPONMAINHAND, 1000},
	[10] = {17, INVTYPE_WEAPONOFFHAND, 1000},
	[11] = {18, INVTYPE_RANGED, 1000}
}

local function ResetRepairNotification()
	showRepair = true
end

function NF:UPDATE_INVENTORY_DURABILITY()
	local current, max

	for i = 1, 11 do
		if GetInventoryItemLink("player", Slots[i][1]) ~= nil then
			current, max = GetInventoryItemDurability(Slots[i][1])
			if current then
				Slots[i][3] = current/max
			end
		end
	end
	table.sort(Slots, function(a, b) return a[3] < b[3] end)
	local value = floor(Slots[1][3]*100)

	if showRepair and value < 20 then
		showRepair = false
		E:Delay(30, ResetRepairNotification)
		self:DisplayToast(MINIMAP_TRACKING_REPAIR, format(L["%s slot needs to repair, current durability is %d."],Slots[1][2],value))
		if NF.db.message then 
			KUI:Print((L["%s slot needs to repair, current durability is %d."]):format(Slots[1][2],value))
		end
	end
end

local numInvites = 0
local function GetGuildInvites()
    local numGuildInvites = 0
    local date = C_Calendar.GetDate()
    for index = 1, C_Calendar.GetNumGuildEvents() do
        local info = C_Calendar.GetGuildEventInfo(index)
        local monthOffset = info.month - date.month
        local numDayEvents = C_Calendar.GetNumDayEvents(monthOffset, info.monthDay)

        for i = 1, numDayEvents do
            local event = C_Calendar.GetDayEvent(monthOffset, info.monthDay, i)
            if event.inviteStatus == CALENDAR_INVITESTATUS_NOT_SIGNEDUP then
                numGuildInvites = numGuildInvites + 1
            end
        end
    end

    return numGuildInvites
end

local function toggleCalendar()
	if not CalendarFrame then LoadAddOn("Blizzard_Calendar") end
	Calendar_Toggle()
end

local function alertEvents()
	if NF.db.enable ~= true or NF.db.invites ~= true then return end
	if CalendarFrame and CalendarFrame:IsShown() then return end
	local num = C_Calendar_GetNumPendingInvites()
	if num ~= numInvites then
		if num > 0 then
			NF:DisplayToast(CALENDAR, L["You have %s pending calendar |4invite:invites;."]:format(num), toggleCalendar)
			if NF.db.message then 
				KUI:Print((L["You have %s pending calendar |4invite:invites;."]):format((num), toggleCalendar))
			end
		end
		numInvites = num
	end

	--[[
	if num ~= numInvites then
		if num > 1 then
			NF:DisplayToast(CALENDAR, format(L["You have %s pending calendar invite(s)."], num), toggleCalendar)
		elseif num > 0 then
			NF:DisplayToast(CALENDAR, format(L["You have %s pending calendar invite(s)."], 1), toggleCalendar)
		end
		numInvites = num
	end
	]]
end

local function alertGuildEvents()
	if NF.db.enable ~= true or NF.db.guildEvents ~= true then return end
	if CalendarFrame and CalendarFrame:IsShown() then return end
	local num = GetGuildInvites()
	if num > 0 then
		NF:DisplayToast(CALENDAR, L["You have %s pending guild |4event:events;."]:format(num), toggleCalendar)
		if NF.db.message then 
			KUI:Print((L["You have %s pending guild |4event:events;."]):format((num), toggleCalendar))
		end
	end

	--[[
	if num > 1 then
		NF:DisplayToast(CALENDAR, format(L["You have %s pending guild event(s)."], num), toggleCalendar)
	elseif num > 0 then
		NF:DisplayToast(CALENDAR, format(L["You have %s pending guild event(s)."], 1), toggleCalendar)
	end
	]]
end

function NF:CALENDAR_UPDATE_PENDING_INVITES()
	alertEvents()
	alertGuildEvents()
end

function NF:CALENDAR_UPDATE_GUILD_EVENTS()
	alertGuildEvents()
end

local function LoginCheck()
	alertEvents()
	alertGuildEvents()
end

function NF:PLAYER_ENTERING_WORLD()
	C_Timer.After(7, LoginCheck)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

local SOUND_TIMEOUT = 20
function NF:VIGNETTE_MINIMAP_UPDATED(event, vignetteGUID, onMinimap)
	if not NF.db.vignette or InCombatLockdown() or VignetteExclusionMapIDs[C_Map_GetBestMapForUnit("player")] then return end

	local scenarioName, currentStage, numStages, flags, _, _, _, xp, money, scenarioType, _, textureKitID = C_Scenario_GetInfo()
	local inChallengeMode = (scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE)
	local inProvingGrounds = (scenarioType == LE_SCENARIO_TYPE_PROVING_GROUNDS)
	local dungeonDisplay = (scenarioType == LE_SCENARIO_TYPE_USE_DUNGEON_DISPLAY)
	local inWarfront = (scenarioType == LE_SCENARIO_TYPE_WARFRONT)

	if inChallengeMode or inProvingGrounds or dungeonDisplay or inWarfront then
		return;
	end

	if onMinimap then
		if vignetteGUID ~= self.lastMinimapRare.id then
			local vignetteInfo = C_VignetteInfo_GetVignetteInfo(vignetteGUID)
			if vignetteInfo then
				vignetteInfo.name = format("|cff00c0fa%s|r", vignetteInfo.name:sub(1, 28))
				self:DisplayToast(vignetteInfo.name, L["has appeared on the MiniMap!"], nil, vignetteInfo.atlasName)
				
				if NF.db.message then 
					KUI:Print(vignetteInfo.name, L["has appeared on the MiniMap!"])
				end

				if (GetTime() > self.lastMinimapRare.time + SOUND_TIMEOUT) then
					if NF.db.noSound ~= true then
						PlaySoundFile([[Sound\Interface\UI_Legendary_Item_Toast.ogg]])
						PlaySoundFile([[Sound\Event Sounds\Event_wardrum_ogre.ogg]])
					end
				end
			end
		end
	end

	--Set last Vignette data
	self.lastMinimapRare.time = GetTime()
	self.lastMinimapRare.id = vignetteGUID
end

function NF:RESURRECT_REQUEST(name)
	if NF.db.noSound ~= true then
		PlaySound(46893, "Master")
	end
end

local socialQueueCache = {}
local function RecentSocialQueue(TIME, MSG)
	local previousMessage = false
	if next(socialQueueCache) then
		for guid, tbl in pairs(socialQueueCache) do
			-- !dont break this loop! its used to keep the cache updated
			if TIME and (difftime(TIME, tbl[1]) >= 300) then
				socialQueueCache[guid] = nil --remove any older than 5m
			elseif MSG and (MSG == tbl[2]) then
				previousMessage = true --dont show any of the same message within 5m
			end
		end
	end
	return previousMessage
end

--[[function NF:SocialQueueEvent(event, guid, numAddedItems)
	if not NF.db.quickJoin or InCombatLockdown() then return end
	if not (guid) then return end

	if ( numAddedItems == 0 or C_SocialQueueGetGroupMembers(guid) == nil) then
		return
	end

	local coloredName, players = UNKNOWN, C_SocialQueueGetGroupMembers(guid)
	local members = players and SocialQueueUtil_SortGroupMembers(players)
	local playerName, nameColor
	if members then
		local firstMember, numMembers, extraCount = members[1], #members, ''
		playerName, nameColor = SocialQueueUtil_GetRelationshipInfo(firstMember.guid, nil, firstMember.clubId)
		if numMembers > 1 then
			extraCount = format(" +%s", numMembers - 1)
		end
		if playerName then
			coloredName = format("%s%s|r%s", nameColor, playerName, extraCount)
		else
			coloredName = format("{%s%s}", UNKNOWN, extraCount)
		end
	end

	local isLFGList, firstQueue
	local queues = C_SocialQueueGetGroupQueues(guid)
	firstQueue = queues and queues[1]
	isLFGList = firstQueue and firstQueue.queueData and firstQueue.queueData.queueType == "lfglist"

	if isLFGList and firstQueue and firstQueue.eligible then
		local activityID, name, comment, leaderName, fullName, isLeader, _

		if firstQueue.queueData.lfgListID then
			_, activityID, name, comment, _, _, _, _, _, _, _, _, leaderName = C_LFGListGetSearchResultInfo(firstQueue.queueData.lfgListID)
			isLeader = CH:SocialQueueIsLeader(playerName, leaderName)
		end

		-- ignore groups created by the addon World Quest Group Finder/World Quest Tracker/World Quest Assistant/HandyNotes_Argus to reduce spam
		if comment and (find(comment, "World Quest Group Finder") or find(comment, "World Quest Tracker") or find(comment, "World Quest Assistant") or find(comment, "HandyNotes_Argus")) then return end
		-- prevent duplicate messages within 5 minutes
		local TIME = time()
		if RecentSocialQueue(TIME, name) then return end
		socialQueueCache[guid] = {TIME, name}

		if activityID or firstQueue.queueData.activityID then
			fullName = C_LFGListGetActivityInfo(activityID or firstQueue.queueData.activityID)
		end

		fullName = format("|cff00ff00%s|r", fullName)
		name = format("|cff00c0fa%s|r", name:sub(1,100))
		if name then
			self:DisplayToast(coloredName, ((isLeader and L["is looking for members"] or L["joined a group"]).."\n".."["..fullName or UNKNOWN).."]: "..name, _G["ToggleQuickJoinPanel"], "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend", .08, .92, .08, .92)
			if NF.db.message and not E.db.chat.socialQueueMessages then 
				KUI:Print(coloredName, ((isLeader and L["is looking for members"] or L["joined a group "]).."["..fullName or UNKNOWN).."]: "..name)
			end
		else
			self:DisplayToast(coloredName, ((isLeader and L["is looking for members"] or L["joined a group"]).."\n".."["..fullName or UNKNOWN).."]: ", _G["ToggleQuickJoinPanel"], "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend", .08, .92, .08, .92)
			if NF.db.message and not E.db.chat.socialQueueMessages then 
				KUI:Print(coloredName, ((isLeader and L["is looking for members"] or L["joined a group "]).."["..fullName or UNKNOWN).."]: ")
			end
		end
	elseif firstQueue then
		local output, outputCount, queueCount, queueName = '', '', 0
		for _, queue in pairs(queues) do
			if type(queue) == "table" and queue.eligible then
				queueName = (queue.queueData and SocialQueueUtil_GetQueueName(queue.queueData)) or ""
				if queueName ~= "" then
					if output == "" then
						output = queueName:gsub("\n.+","") -- grab only the first queue name
						queueCount = queueCount + select(2, queueName:gsub("\n","")) -- collect additional on single queue
					else
						queueCount = queueCount + 1 + select(2, queueName:gsub("\n","")) -- collect additional on additional queues
					end
				end
			end
		end
		if output ~= "" then
			output = format("|cff00c0fa%s |r", output)
			if queueCount > 0 then
				outputCount = format(LFG_LIST_AND_MORE, queueCount)
			end
			self:DisplayToast(coloredName, SOCIAL_QUEUE_QUEUED_FOR.. ": "..output..outputCount, _G["ToggleQuickJoinPanel"], "Interface\\Icons\\Achievement_GuildPerk_EverybodysFriend", .08, .92, .08, .92)
			if NF.db.message and not E.db.chat.socialQueueMessages then 
				KUI:Print(coloredName, SOCIAL_QUEUE_QUEUED_FOR.. ": "..output..outputCount)
			end
		end
	end
end]]

function NF:Initialize()
	NF.db = E.db.KlixUI.notification
	if NF.db.enable ~= true or (IsInRaid() and NF.db.raid) then return end

	KUI:RegisterDB(self, "notification")

	anchorFrame = CreateFrame("Frame", nil, E.UIParent)
	anchorFrame:SetSize(bannerWidth, 50)
	anchorFrame:SetPoint("TOP", 0, -185)
	E:CreateMover(anchorFrame, "Notification Mover", L["Notification Mover"], nil, nil, nil, "ALL,SOLO,KLIXUI", nil, "KlixUI,modules,notification")

	self:RegisterEvent("UPDATE_PENDING_MAIL")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
	self:RegisterEvent("CALENDAR_UPDATE_GUILD_EVENTS")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
	self:RegisterEvent("RESURRECT_REQUEST")
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	--self:RegisterEvent("SOCIAL_QUEUE_UPDATE", "SocialQueueEvent")

	self.lastMinimapRare = {time = 0, id = nil}
end

local function InitializeCallback()
	NF:Initialize()
end

KUI:RegisterModule(NF:GetName(), InitializeCallback)