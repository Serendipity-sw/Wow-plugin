local KUI, E, L, V, P, G = unpack(select(2, ...))
local MI = KUI:NewModule("KuiMisc", "AceHook-3.0", "AceEvent-3.0")
local COMP = KUI:GetModule("KuiCompatibility")
MI.modName = L["Misc"]

E.KuiMisc = MI;

-- Cache global variables
-- Lua functions
local _G = _G
local select = select
local collectgarbage = collectgarbage
local find = string.find
-- WoW API / Variables
local CreateFrame = CreateFrame
local C_PetJournalSetFilterChecked = C_PetJournal.SetFilterChecked
local C_PetJournalSetAllPetTypesChecked = C_PetJournal.SetAllPetTypesChecked
local C_PetJournalSetAllPetSourcesChecked = C_PetJournal.SetAllPetSourcesChecked
local GetBattlefieldStatus = GetBattlefieldStatus
local GetCurrentMapDungeonLevel = GetCurrentMapDungeonLevel
local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetLFGDungeonInfo = GetLFGDungeonInfo
local GetLFGDungeonRewards = GetLFGDungeonRewards
local GetLFGRandomDungeonInfo = GetLFGRandomDungeonInfo
local GetMapInfo = GetMapInfo
local GetMaxBattlefieldID = GetMaxBattlefieldID
local GetNumRandomDungeons = GetNumRandomDungeons
local GetNumGroupMembers = GetNumGroupMembers
local GetSpecialization = GetSpecialization
local SetMapByID = SetMapByID
local UnitLevel = UnitLevel
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitSetRole = UnitSetRole
local InCombatLockdown = InCombatLockdown
local PlaySound, PlaySoundFile = PlaySound, PlaySoundFile
local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemLink = GetContainerItemLink

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: LFDQueueFrame_SetType, IDLE_MESSAGE, ForceQuit, SOUNDKIT, hooksecurefunc, PVPReadyDialog
-- GLOBALS: LFRBrowseFrame, RolePollPopup, StaticPopupDialogs, LE_PET_JOURNAL_FILTER_COLLECTED
-- GLOBALS: LE_PET_JOURNAL_FILTER_NOT_COLLECTED, WorldMapZoomOutButton_OnClick, UnitPowerBarAltStatus_UpdateText
-- GLOBALS: StaticPopupSpecial_Hide

-- Credit: Merathilis for this!
function MI:LoadMisc()
	-- Force readycheck warning
	local ShowReadyCheckHook = function(_, initiator)
		if initiator ~= "player" then
			PlaySound(SOUNDKIT.READY_CHECK or 8960)
		end
	end
	hooksecurefunc("ShowReadyCheck", ShowReadyCheckHook)

	-- Force other warning
	local ForceWarning = CreateFrame("Frame")
	ForceWarning:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	ForceWarning:RegisterEvent("PET_BATTLE_QUEUE_PROPOSE_MATCH")
	ForceWarning:RegisterEvent("LFG_PROPOSAL_SHOW")
	ForceWarning:SetScript("OnEvent", function(_, event)
		if event == "UPDATE_BATTLEFIELD_STATUS" then
			for i = 1, GetMaxBattlefieldID() do
				local status = GetBattlefieldStatus(i)
				if status == "confirm" then
					PlaySound(SOUNDKIT.UI_PET_BATTLES_PVP_THROUGH_QUEUE or 36609)
					break
				end
				i = i + 1
			end
		elseif event == "PET_BATTLE_QUEUE_PROPOSE_MATCH" then
			PlaySound(SOUNDKIT.UI_PET_BATTLES_PVP_THROUGH_QUEUE or 36609)
		elseif event == "LFG_PROPOSAL_SHOW" then
			PlaySound(SOUNDKIT.READY_CHECK or 8960)
		end
	end)

	-- Misclicks for some popups
	StaticPopupDialogs.RESURRECT.hideOnEscape = nil
	StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
	StaticPopupDialogs.PARTY_INVITE.hideOnEscape = nil
	StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil
	StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
	StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil
	_G["PetBattleQueueReadyFrame"].hideOnEscape = nil
	if (PVPReadyDialog) then
		PVPReadyDialog.leaveButton:Hide()
		PVPReadyDialog.enterButton:ClearAllPoints()
		PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)
		PVPReadyDialog.label:SetPoint("TOP", 0, -22)
	end

	-- Auto select current event boss from LFD tool(EventBossAutoSelect by Nathanyel)
	local firstLFD
	_G["LFDParentFrame"]:HookScript("OnShow", function()
		if not firstLFD then
			firstLFD = 1
			for i = 1, GetNumRandomDungeons() do
				local id = GetLFGRandomDungeonInfo(i)
				local isHoliday = select(15, GetLFGDungeonInfo(id))
				if isHoliday and not GetLFGDungeonRewards(id) then
					LFDQueueFrame_SetType(id)
				end
			end
		end
	end)

	-- Always show the Text on the PlayerPowerBarAlt
	_G["PlayerPowerBarAlt"]:HookScript("OnShow", function()
		local statusFrame = _G["PlayerPowerBarAlt"].statusFrame
		if statusFrame.enabled then
			statusFrame:Show()
			UnitPowerBarAltStatus_UpdateText(statusFrame)
		end
	end)

	-- Try to fix JoinBattleField taint
	CreateFrame("Frame"):SetScript("OnUpdate", function(self, elapsed)
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)

	-- Pet Journal Fix
	C_PetJournalSetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, true)
	C_PetJournalSetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, true)
	C_PetJournalSetAllPetTypesChecked(true)
	C_PetJournalSetAllPetSourcesChecked(true)

	-- FixOrderHallMap(by Ketho)
	local locations = {
		[23] = function() return select(4, GetMapInfo()) and 1007 end, -- Paladin, Sanctum of Light; Eastern Plaguelands
		[1040] = function() return 1007 end, -- Priest, Netherlight Temple; Azeroth
		[1044] = function() return 1007 end, -- Monk, Temple of Five Dawns; none
		[1048] = function() return 1007 end, -- Druid, Emerald Dreamway; none
		[1052] = function() return GetCurrentMapDungeonLevel() > 1 and 1007 end, -- Demon Hunter, Fel Hammer; Mardum
		[1088] = function() return GetCurrentMapDungeonLevel() == 3 and 1033 end, -- Nighthold -> Suramar
	}

	-- WorldMapFrame Zoom Bug
	local WorldMapFrame = _G.WorldMapFrame
	local WorldMapFrame_OnHide = _G.WorldMapFrame_OnHide
	local WorldMapLevelButton_OnClick = _G.WorldMapLevelButton_OnClick

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:RegisterEvent("PLAYER_REGEN_ENABLED") 
	frame:RegisterEvent("PLAYER_REGEN_DISABLED")
	frame:SetScript("OnEvent", function(self)
		if event == "PLAYER_REGEN_DISABLED" then
			WorldMapFrame:UnregisterEvent("WORLD_MAP_UPDATE")
			WorldMapFrame:SetScript("OnHide", nil)
			WorldMapLevelButton:SetScript("OnClick", nil)
		elseif event == "PLAYER_REGEN_ENABLED" then
			WorldMapFrame:RegisterEvent("WORLD_MAP_UPDATE")
			WorldMapFrame:SetScript("OnHide", WorldMapFrame_OnHide)
			WorldMapLevelButton:SetScript("OnClick", WorldMapLevelButton_OnClick)
		end
	end)

	-- Garbage collection is being overused and misused,
	-- and it's causing lag and performance drops.
	do
		local oldcollectgarbage = collectgarbage
		oldcollectgarbage("setpause", 110)
		oldcollectgarbage("setstepmul", 200)

		collectgarbage = function(opt, arg)
			if (opt == "collect") or (opt == nil) then
			elseif (opt == "count") then
				return oldcollectgarbage(opt, arg)
			elseif (opt == "setpause") then
				return oldcollectgarbage("setpause", 110)
			elseif opt == "setstepmul" then
				return oldcollectgarbage("setstepmul", 200)
			elseif (opt == "stop") then
			elseif (opt == "restart") then
			elseif (opt == "step") then
				if (arg ~= nil) then
					if (arg <= 10000) then
						return oldcollectgarbage(opt, arg)
					end
				else
					return oldcollectgarbage(opt, arg)
				end
			else
				return oldcollectgarbage(opt, arg)
			end
		end

		-- Memory usage is unrelated to performance, and tracking memory usage does not track "bad" addons.
		-- Developers can uncomment this line to enable the functionality when looking for memory leaks,
		-- but for the average end-user this is a completely pointless thing to track.
		UpdateAddOnMemoryUsage = KUI.dummy
	end

	-- Auto collapse ObjectiveTracker in Raid
	local f = CreateFrame("Frame", nil, UIParent)
	f:RegisterEvent("ENCOUNTER_START")
	f:RegisterEvent("ENCOUNTER_END")
	f:RegisterEvent("LOADING_SCREEN_DISABLED")

	f:SetScript("OnEvent", function(self, event, arg1)
		if (not IsInRaid()) then
			ObjectiveTracker_Expand()
			return
		end

		if (event == "ENCOUNTER_START" or (event == "LOADING_SCREEN_DISABLED" and UnitExists("boss1"))) then
			ObjectiveTracker_Collapse()
		else
			ObjectiveTracker_Expand()
		end
	end)
end

function MI:RUReset()
	local a = E.db.KlixUI.misc.rumouseover and 0 or 1
	_G["RaidUtility_ShowButton"]:SetAlpha(a)
end

function MI:SetRole()
	local spec = GetSpecialization()
	if UnitLevel("player") >= 10 and not InCombatLockdown() then
		if spec == nil and UnitGroupRolesAssigned("player") ~= "NONE" then
			UnitSetRole("player", "NONE")
		elseif spec ~= nil then
			if GetNumGroupMembers() > 0 then
				if UnitGroupRolesAssigned("player") ~= E:GetPlayerRole() then
					UnitSetRole("player", E:GetPlayerRole())
				end
			end
		end
	end
end

-- Code taken from ElvUI
-- buy max number value with alt
local savedMerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
function MerchantItemButton_OnModifiedClick(self, ...)
if E.db.KlixUI.misc.buyall ~= true then return end
	if ( IsAltKeyDown() ) then
		local itemLink = GetMerchantItemLink(self:GetID())
		if not itemLink then return end
		local maxStack = select(8, GetItemInfo(itemLink))
		if ( maxStack and maxStack > 1 ) then
			BuyMerchantItem(self:GetID(), GetMerchantItemMaxStack(self:GetID()))
		end
	end
	savedMerchantItemButton_OnModifiedClick(self, ...)
end

-- Auto insert keystones when in dungeon.
function MI:insertKeystone()
	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, GetContainerNumSlots(bag) do
			local name=GetContainerItemLink(bag,slot)
			if (name and string.find(name,"Keystone:")) then
				UseContainerItem(bag,slot)
				KUI:Print("Inserting keystone: " .. name .. ".")
			end
		end
	end
end

-- Auto insert keystones
function MI:CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN()
	if E.db.KlixUI.misc.keystones then
		C_Timer.After(0.5, function()
			MI:insertKeystone()
		end)
	end
end

-- Auto close the popup window you get after joining a raid group that shows your role (custom group finder etc).
function MI:LFG_LIST_JOINED_GROUP()
	--If group leader or not in group the popup looks different (same frame name though).
	if (UnitIsGroupLeader("player") or not IsInGroup()) then
		return
	end
	if E.db.KlixUI.misc.rolecheck.confirm then
		local roleText = LFGListInviteDialog.Role:GetText()
		if (roleText and roleText ~= "") then
			KUI:Print("Joined group as role:|cffFFFF00 " .. roleText)
		end
		LFGListInviteDialog:Hide()
	end
end

-- Auto accept role check
local roleCheckMsg = true
function MI:LFG_ROLE_CHECK_SHOW()
	local queueText = LFDRoleCheckPopupDescriptionText:GetText()
	local doQueue = false
	if E.db.KlixUI.misc.rolecheck.enable then --Global setting
		doQueue = true
	elseif (string.find(queueText, "The Crown Chemical Co") and E.db.KlixUI.misc.rolecheck.love) then --Love is in the air
		doQueue = true
	elseif (string.find(queueText, "The Headless Horseman") and E.db.KlixUI.misc.rolecheck.halloween) then --Halloween
		doQueue = true	--(untested, hopefully this is the dung name)
	elseif (string.find(queueText, "Timewalking") and E.db.KlixUI.misc.rolecheck.timewalking) then --Timewalking
		doQueue = true	--(untested, hopefully timewalking is in the queue name)
	end
	leader, tank, healer, damage = GetLFGRoles()
	if (tank == true) then
		tankMsg = "Tank "
	else
		tankMsg = ""
	end
	if (healer == true) then
		healerMsg = "Healer "
	else
		healerMsg = ""
	end
	if (damage == true) then
		damageMsg = "Damage"
	else
		damageMsg = ""
	end
	if (doQueue and roleCheckMsg == true) then
		CompleteLFGRoleCheck(true)
		KUI:Print("Auto completed role check as:|cffFFFF00 " .. tankMsg .. healerMsg .. damageMsg)
		--Turn off the msg for a few seconds, LFG_ROLE_CHECK_SHOW seems to trigger when anyone in group signs up so it spams.
		--There's probably a better event to make it only trigger on myself somehow, will work it out later.
		roleCheckMsg = false
		C_Timer.After(5, function()
			resetRoleCheckMsg()
		end)
	end
end

function resetRoleCheckMsg()
	roleCheckMsg = true
end

function MI:FlightMasterWhistle()
	if not E.db.KlixUI.misc.whistleSound then return end

	-- plays a soundbite from DJ Alligator - Blow my Whistle B*** after Flight Master's Whistle is used.
	local flightMastersWhistle_SpellID1 = 227334
	local flightMastersWhistle_SpellID2 = 253937

	local f = CreateFrame("frame")
	f:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

	function f:UNIT_SPELLCAST_SUCCEEDED(unit, lineID, spellID)
		if (unit == "player" and (spellID == flightMastersWhistle_SpellID1 or spellID == flightMastersWhistle_SpellID2)) then
			PlaySoundFile("Interface\\AddOns\\ElvUI_KlixUI\\media\\sounds\\blowmywhistle.mp3")
		end
	end
	f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

function MI:LootOpen()
	if not E.db.KlixUI.misc.lootSound then return end
	
	local Owensounds = {}
	Owensounds[#Owensounds+1] = 'Interface\\AddOns\\ElvUI_KlixUI\\media\\sounds\\Owen\\wow1.mp3'
	Owensounds[#Owensounds+1] = 'Interface\\AddOns\\ElvUI_KlixUI\\media\\sounds\\Owen\\wow2.mp3'
	Owensounds[#Owensounds+1] = 'Interface\\AddOns\\ElvUI_KlixUI\\media\\sounds\\Owen\\Kachow.mp3'
	
	local soundLength = #Owensounds
	local lootFrame = CreateFrame("Frame")
	lootFrame:SetScript("OnEvent", function(self, event, ...) end)
	
	function lootFrame:LOOT_OPENED()
	local g = math.random(soundLength)
		PlaySoundFile(Owensounds[g], "Master")
	end
	lootFrame:RegisterEvent("LOOT_OPENED")
end

function MI:SHIPMENT_CRAFTER_OPENED()
	local startOrders = false
	local npcName = UnitName("target")
	local zoneName = GetZoneText()
	local subZoneName = GetSubZoneText()
	if E.db.KlixUI.misc.workorder.orderhall then
		if COMP.SLE and (E.db.sle.legacy.warwampaign.autoOrder.enable or E.db.sle.legacy.orderhall.autoOrder.enable) then return end
		if zoneName == "Dreadscar Rift" then -- Warlock
			startOrders = true
		elseif zoneName == "Acherus: The Ebon Hold" then -- Death Knight
			startOrders = true
		elseif zoneName == "Hall of the Guardian" then -- Mage
			startOrders = true
		elseif zoneName == "Skyhold" then -- Warrior
			startOrders = true
		elseif zoneName == "Trueshot Lodge" then -- Hunter
			startOrders = true
		elseif zoneName == "Mardum, the Shattered Abyss" then -- Demon Hunter
			startOrders = true
		elseif subZoneName == "The Hall of Shadows" or subZoneName == "Den of Thieves" then -- Rogue
			startOrders = true
		elseif zoneName == "Netherlight Temple" then -- Priest
			startOrders = true
		elseif zoneName == "The Maelstrom" then -- Shaman
			startOrders = true
		elseif zoneName == "The Wandering Isle" then -- Monk
			startOrders = true
		elseif zoneName == "Light's Hope Chapel" then -- Paladin
			startOrders = true
		elseif zoneName == "The Dreamgrove" then -- Druid
			startOrders = true
		elseif zoneName == "Wind's Redemption" then -- Boralus alliance ship.
			startOrders = true
		elseif zoneName == "The Banshee's Wail" then -- Horde ship.
			startOrders = true
		end
	end
	if E.db.KlixUI.misc.workorder.nomi and npcName == "Nomi" then
		startOrders = true
	end
	if startOrders then
		-- We need a 1 second delay before doing anything, the game client doesn't get the frame info instantly on load.
		-- On rare occasions it still doesn't get the info even with a 1 second delay.
		C_Timer.After(1, function()
			MI:StartAllWorkOrders()
		end)
	end
end

function MI:StartAllWorkOrders()
	if IsModifierKeyDown() then return end
	local buttonState = GarrisonCapacitiveDisplayFrame.CreateAllWorkOrdersButton:GetButtonState()
	if buttonState == "NORMAL" then
		local workOrderType = GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.ShipmentIconFrame.ShipmentName:GetText()
		local workOrdersAvailable = GarrisonCapacitiveDisplayFrame.CapacitiveDisplay.ShipmentIconFrame.ShipmentsAvailable:GetText()
		if workOrderType ~= nil and workOrderType ~= '' and workOrdersAvailable ~= nil and workOrdersAvailable ~= '' then
			local workOrderCount = {}
			workOrderCount[1], workOrderCount[2] = workOrdersAvailable:match("(%w+)(.+)")
			GarrisonCapacitiveDisplayFrame.CreateAllWorkOrdersButton:Click()
			KUI:Print("Started|cffFFFF00 " .. workOrderCount[1] .. " |cffffffffwork orders for|cffFFFF00 " .. 
					workOrderType .. "|cffffffff.")
		else
			GarrisonCapacitiveDisplayFrame.CreateAllWorkOrdersButton:Click()
			KUI:Print("Starting all work orders.")
		end
	end
end

function MI:Initialize()
	E.RegisterCallback(MI, "RoleChanged", "SetRole")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "SetRole")
	RolePollPopup:SetScript("OnShow", function() StaticPopupSpecial_Hide(RolePollPopup) end)

	self:LoadMisc()
	self:LoadMoverTransparancy()
	self:LoadGMOTD()
	self:FlightMasterWhistle()
	self:LootOpen()

	MI:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN")
	MI:RegisterEvent("LFG_LIST_JOINED_GROUP")
	MI:RegisterEvent("LFG_ROLE_CHECK_SHOW")
	MI:RegisterEvent("SHIPMENT_CRAFTER_OPENED")
	
	
	-- Auto gossip when visiting BfA mission ship and rogue order hall doors in legion.
	if E.db.KlixUI.misc.workorder.orderhall then
		GossipFrame:HookScript("OnShow",function()
			if (GetNumGossipOptions() > 0) then
				if (strfind(GetGossipOptions(), "Lay your insignia on the table")
					or strfind(GetGossipOptions(), "Subtlety flash your insignia")
					or strfind(GetGossipOptions(), "I would like to ride a Caravan")
					or strfind(GetGossipOptions(), "I require reinforcements"))
					and (GetMinimapZoneText() == "Glorious Goods"
					or GetMinimapZoneText() == "Tanks for Everything"
					or GetMinimapZoneText() == "One More Glass"
					or GetMinimapZoneText() == "Vulpera Hideaway"
					or GetMinimapZoneText() == "Wind's Redemption"
					or GetMinimapZoneText() == "The Banshee's Wail")
					and not IsModifierKeyDown() then
				SelectGossipOption(1)
				end
			end
		end)
	end
	
	--- Mover Creation ---
	if not IsAddOnLoaded('ElvUI_SLE') then
		E:CreateMover(_G["UIErrorsFrame"], "UIErrorsFrameMover", L["Error Frame"], nil, nil, nil, "ALL,GENERAL,KLIXUI")

		--GhostFrame Mover.
		ShowUIPanel(_G["GhostFrame"])
		E:CreateMover(_G["GhostFrame"], "GhostFrameMover", L["Ghost Frame"], nil, nil, nil, "ALL,GENERAL,KLIXUI")
		HideUIPanel(_G["GhostFrame"])

		--Raid Utility
		if _G["RaidUtility_ShowButton"] then
			E:CreateMover(_G["RaidUtility_ShowButton"], "RaidUtility_Mover", L["Raid Utility"], nil, nil, nil, "ALL,RAID,KLIXUI")
			local mover = _G["RaidUtility_Mover"]
			local frame = _G["RaidUtility_ShowButton"]
			if E.db.movers == nil then E.db.movers = {} end

			mover:HookScript("OnDragStart", function(self) 
				frame:ClearAllPoints()
				frame:SetPoint("CENTER", self)
			end)

			local function Enter(self)
				if not E.db.KlixUI.misc.rumouseover then return end
				self:SetAlpha(1)
			end

			local function Leave(self)
				if not E.db.KlixUI.misc.rumouseover then return end
				self:SetAlpha(0)
			end

			local function dropfix()
				local point, anchor, point2, x, y = mover:GetPoint()
				frame:ClearAllPoints()
				if find(point, "BOTTOM") then
					frame:SetPoint(point, anchor, point2, x, y)
				else
					frame:SetPoint(point, anchor, point2, x, y)
				end
			end

			mover:HookScript("OnDragStop", dropfix)

			if E.db.movers.RaidUtility_Mover == nil then
				frame:ClearAllPoints()
				frame:SetPoint("TOP", E.UIParent, "TOP", -400, E.Border)
			else
				dropfix()
			end
			frame:RegisterForDrag("")
			frame:HookScript("OnEnter", Enter)
			frame:HookScript("OnLeave", Leave)
			Leave(frame)
		end
	end
end

local function InitializeCallback()
	MI:Initialize()
end

KUI:RegisterModule(MI:GetName(), InitializeCallback)