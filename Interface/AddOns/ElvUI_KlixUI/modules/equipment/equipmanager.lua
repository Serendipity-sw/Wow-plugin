local KUI, E, L, V, P, G = unpack(select(2, ...))
local EM = KUI:NewModule('EquipManager', 'AceHook-3.0', 'AceEvent-3.0')
EM.Processing = false
EM.ErrorShown = false

-- Cache global variables
-- Lua functions
local C_EquipmentSet = C_EquipmentSet
local _G = _G
local gsub = gsub
local match = string.match
local format = string.format
local find = string.find
local tinsert, twipe = table.insert, table.wipe
local pairs, ipairs, select, tonumber, unpack = pairs, ipairs, select, tonumber, unpack
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local InCombatLockdown = InCombatLockdown
local GetNumGroupMembers = GetNumGroupMembers
local GetSpecialization = GetSpecialization
local GetTalentInfo = GetTalentInfo
local GetInstanceInfo = GetInstanceInfo
local IsInInstance = IsInInstance
local GetNumWorldPVPAreas = GetNumWorldPVPAreas
local GetWorldPVPAreaInfo = GetWorldPVPAreaInfo
local GetRealZoneText = GetRealZoneText

EM.SetData = {}

local Difficulties = {
	[1] = 'normal', --5ppl normal
	[2] = 'heroic', --5ppl heroic
	[3] = 'normal', --10ppl raid
	[4] = 'normal', --25ppl raid
	[5] = 'heroic', --10ppl heroic raid
	[6] = 'heroic', --25ppl heroic raid
	[7] = 'lfr', --25ppl LFR
	[8] = 'challenge', --5ppl challenge
	[9] = 'normal', --40ppl raid
	[11] = 'heroic', --Heroic scenario
	[12] = 'normal', --Normal scenario
	[14] = 'normal', --10-30ppl normal
	[15] = 'heroic', --13-30ppl heroic
	[16] = 'mythic', --20ppl mythic
	[17] = 'lfr', --10-30 LFR
	[23] = 'mythic', --5ppl mythic
	[24] = 'timewalking', --Timewalking
}

EM.TagsTable = {
	["solo"] = function() if IsInGroup() then return false; else return true; end end,
	["party"] = function(size)
		size = tonumber(size)
		if IsInGroup() then
			if size then
				if size == GetNumGroupMembers() then return true; else return false; end
			else
				return true
			end
		else
			return false
		end
	end,
	["raid"] = function(size)
		size = tonumber(size)
		if IsInRaid() then
			if size then
				if size == GetNumGroupMembers() then return true; else return false; end
			else
				return true
			end
		else
			return false
		end
	end,
	["spec"] = function(index)
		local index = tonumber(index)
		if not index then return false end
		if index == GetSpecialization() then return true; else return false; end
	end,
	["talent"] = function(tier, column)
		local tier, column = tonumber(tier), tonumber(column)
		if not (tier or column) then return false end
		if tier < 0 or tier > 7 then KUI:ErrorPrint(format(L["KUI_EM_TAG_INVALID_TALENT_TIER"], tier)) return false end
		if column < 0 or column > 3 then KUI:ErrorPrint(format(L["KUI_EM_TAG_INVALID_TALENT_COLUMN"], column)) return false end
		local _, _, _, selected = GetTalentInfo(tier, column, 1)
		if selected then
			return true
		else
			return false
		end
	end,
	["instance"] = function(dungeonType)
		local inInstance, InstanceType = IsInInstance()
		if inInstance then
			if dungeonType then
				if InstanceType == dungeonType then return true; else return false; end
			else
				if InstanceType == "pvp" or InstanceType == "arena" then return false; else return true; end
			end
		else
			return false
		end
	end,
	["pvp"] = function(pvpType)
		local inInstance, InstanceType = IsInInstance()
		if inInstance then
			if pvpType and (InstanceType == "pvp" or InstanceType == "arena") then
				if InstanceType == pvpType then return true; else return false; end
			else
				if InstanceType == "pvp" or InstanceType == "arena" then return true; else return false; end
			end
		else
			for i = 1, GetNumWorldPVPAreas() do
				local _, localizedName, isActive, canQueue = GetWorldPVPAreaInfo(i)
				if (GetRealZoneText() == localizedName and isActive) or (GetRealZoneText() == localizedName and canQueue) then return true end
			end
			return false
		end
	end,
	["difficulty"] = function(difficulty)
		if not IsInInstance() then return false end
		if not difficulty then return false end
		local difID = select(3, GetInstanceInfo())
		if difficulty == Difficulties[difID] then
			return true;
		else
			return false;
		end
	end,
	["NoCondition"] = function()
		return true	
	end,
}

function EM:ConditionTable(option)
	if not option then return end
	local pattern = "%[(.-)%]([^;]+)"
	local Conditions = {
		["options"] = {},
		["set"] = "",
	}
	local condition
	while option:match(pattern) do
		condition, option = option:match(pattern)
		if not(condition and option) then return end
		tinsert(Conditions.options, condition)
	end
	Conditions.set = option:gsub("^%s*", "")
	tinsert(EM.SetData, Conditions)
end

function EM:TagsProcess(msg)
	if msg == "" then return end
	twipe(EM.SetData)
	local split_msg = { (";"):split(msg) }

	for i, v in ipairs(split_msg) do
		local split = split_msg[i]
		EM:ConditionTable(split)
	end
	for i = 1, #EM.SetData do
		local Conditions = EM.SetData[i]
		if #Conditions.options == 0 then
			Conditions.options[1] = {cmds = {{cmd = "NoCondition", arg = {}}}}
		else
			for index = 1, #Conditions.options do
				local condition = Conditions.options[index]
				local cnd_table = { (","):split(condition) }
				local parsed_cmds = {};
				for j = 1, #cnd_table do
					local cnd = cnd_table[j];
					if cnd then
						local command, argument = (":"):split(cnd)
						local argTable = {}
						if argument and find(argument, "%.") then
							KUI:ErrorPrint(L["KUI_EM_TAG_DOT_WARNING"])
						else
							if argument and ("/"):split(argument) then
								local put
								while argument and ("/"):split(argument) do
									put, argument = ("/"):split(argument)
									tinsert(argTable, put)
								end
							else
								tinsert(argTable, argument)
							end
							
							local tag = command:match("^%s*(.+)%s*$")
							if EM.TagsTable[tag] then
								tinsert(parsed_cmds, { cmd = command:match("^%s*(.+)%s*$"), arg = argTable })
							else
								KUI:ErrorPrint(format(L["KUI_EM_TAG_INVALID"], tag))
								twipe(EM.SetData)
								return
							end
						end
					end
				end
				Conditions.options[index] = {cmds = parsed_cmds}
			end
		end
	end
end

function EM:TagsConditionsCheck(data)
	for index,tagInfo in ipairs(data) do 
		local ok = true
		for _, option in ipairs(tagInfo.options) do
			if not option.cmds then return end
			local matches = 0
			for conditionIndex,conditionInfo in ipairs(option.cmds) do
				local func = conditionInfo["cmd"]
				if not EM.TagsTable[func] then
					KUI:ErrorPrint(format(L["KUI_EM_TAG_INVALID"], func))
					return nil
				end
				local arg = conditionInfo["arg"]
				local result = EM.TagsTable[func](unpack(arg))
				if result then 
					matches = matches + 1
				else
					matches = 0
					break 
				end
				if matches == #option.cmds then return tagInfo.set end
			end
		end
	end
end

local function Equip(event)
	if EM.Processing or EM.lock then return end
	if event == "PLAYER_ENTERING_WORLD" then EM:UnregisterEvent(event) end
	if event == "ZONE_CHANGED" and EM.db.onlyTalent then return end
	EM.Processing = true
	local inCombat = false
	E:Delay(1, function() EM.Processing = false end)
	if InCombatLockdown() then
		EM:RegisterEvent("PLAYER_REGEN_ENABLED", Equip)
		inCombat = true
	end
	if event == "PLAYER_REGEN_ENABLED" then
		EM:UnregisterEvent(event)
		EM.ErrorShown = false
	end

	local equippedSet
	local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs()
	for index = 1, C_EquipmentSet.GetNumEquipmentSets() do
		local name, _, _, isEquipped = C_EquipmentSet.GetEquipmentSetInfo(equipmentSetIDs[index]);
		if isEquipped then
			equippedSet = name
			break
		end
	end
	local trueSet = EM:TagsConditionsCheck(EM.SetData)
	-- print("trueSet:", trueSet)
	if trueSet then
		local SetID = C_EquipmentSet.GetEquipmentSetID(trueSet)
		if SetID then
			if not equippedSet or (equippedSet and trueSet ~= equippedSet) then
				C_EquipmentSet.UseEquipmentSet(SetID)
			end
		else
			KUI:ErrorPrint(format(L["KUI_EM_SET_NOT_EXIST"], trueSet))
		end
	end
end

function EM:CreateLock()
	if _G["KUI_Equip_Lock_Button"] or not EM.db.lockbutton then return end
	local button = CreateFrame("Button", "KUI_Equip_Lock_Button", _G["PaperDollFrame"], "UIPanelButtonTemplate")
	button:Size(20, 20)
	button:Point("BOTTOMLEFT", _G["CharacterFrame"], "BOTTOMLEFT", 4, 4)
	button:SetFrameLevel(_G["CharacterModelFrame"]:GetFrameLevel() + 2)
	button:SetScript("OnEnter", function(self)
		_G["GameTooltip"]:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 4)
		_G["GameTooltip"]:AddLine(L["KUI_EM_LOCK_TOOLTIP"])
		_G["GameTooltip"]:Show()
	end)
	button:SetScript("OnLeave", function(self)
		_G["GameTooltip"]:Hide() 
	end)
	E:GetModule("Skins"):HandleButton(button)

	button.Icon = button:CreateTexture(nil, "OVERLAY")
	button.Icon:SetAllPoints()
	button.Icon:SetTexture([[Interface\AddOns\ElvUI_KlixUI\media\textures\lock]])
	button.Icon:SetVertexColor(0, 1, 0)

	button:SetScript("OnClick", function()
		EM.lock = not EM.lock
		button.Icon:SetVertexColor(EM.lock and 1 or 0, EM.lock and 0 or 1, 0)
	end)
end

function EM:UpdateTags()
	EM:TagsProcess(EM.db.conditions)
	Equip()
end

function EM:Initialize()
	EM.db = E.private.KlixUI.equip
	EM.lock = false
	if not EM.db.enable then return end
	self:RegisterEvent("PLAYER_ENTERING_WORLD", Equip)
	self:RegisterEvent("LOADING_SCREEN_DISABLED", Equip)
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", Equip)
	self:RegisterEvent("ZONE_CHANGED", Equip)

	EM:TagsProcess(EM.db.conditions)

	self:CreateLock()
end

local function InitializeCallback()
	EM:Initialize()
end

KUI:RegisterModule(EM:GetName(), InitializeCallback)