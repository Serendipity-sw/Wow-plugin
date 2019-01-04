-- Credit: ElvUI Enchanced for this mod.
local KUI, E, L, V, P, G = unpack(select(2, ...))
local KBI = KUI:NewModule('KuiBagInfo', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0')
local B = E:GetModule('Bags')

local byte, format = string.byte, string.format
local tinsert, twipe = table.insert, table.wipe
local pairs, ipairs, type, unpack = pairs, ipairs, type, unpack

local updateTimer
KBI.containers = {}
KBI.infoArray = {}
KBI.equipmentMap = {}
local EquipmentManager_UnpackLocation = EquipmentManager_UnpackLocation
local C_EquipmentSet = C_EquipmentSet

local function Utf8Sub(str, start, numChars)
	local currentIndex = start
	while numChars > 0 and currentIndex <= #str do
		local char = byte(str, currentIndex)

		if char > 240 then
			currentIndex = currentIndex + 4
		elseif char > 225 then
			currentIndex = currentIndex + 3
		elseif char > 192 then
			currentIndex = currentIndex + 2
		else
			currentIndex = currentIndex + 1
		end

		numChars = numChars -1
	end

	return str:sub(start, currentIndex - 1)
end

local function MapKey(bag, slot)
	return format("%d_%d", bag, slot)
end

local quickFormat = {
	[0] = function(font, map) font:SetText() end,
	[1] = function(font, map) font:SetFormattedText("|cffffffaa%s|r", Utf8Sub(map[1], 1, 4)) end,
	[2] = function(font, map) font:SetFormattedText("|cffffffaa%s %s|r", Utf8Sub(map[1], 1, 4), Utf8Sub(map[2], 1, 4)) end,
	[3] = function(font, map) font:SetFormattedText("|cffffffaa%s %s %s|r", Utf8Sub(map[1], 1, 4), Utf8Sub(map[2], 1, 4), Utf8Sub(map[3], 1, 4)) end,
}

local function BuildEquipmentMap(clear)
	-- clear mapped names
	for k, v in pairs(KBI.equipmentMap) do
		twipe(v)
	end

	if clear then return end

	local name, player, bank, bags, slot, bag, key
	local equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs()

	for index = 1, C_EquipmentSet.GetNumEquipmentSets() do
		name = C_EquipmentSet.GetEquipmentSetInfo(equipmentSetIDs[index]);
		local equipmentSetID = C_EquipmentSet.GetEquipmentSetID(name)
		if equipmentSetID then
			local SetInfoTable = C_EquipmentSet.GetItemLocations(equipmentSetID)
			for _, location in pairs(SetInfoTable) do
				if type(location) == "number" and (location < -1 or location > 1) then
					player, bank, bags, _, slot, bag = EquipmentManager_UnpackLocation(location)
					if ((bank or bags) and slot and bag) then
						key = MapKey(bag, slot)
						KBI.equipmentMap[key] = KBI.equipmentMap[key] or {}
						tinsert(KBI.equipmentMap[key], name)
					end
				end
			end
		end
	end
end

local function UpdateContainerFrame(frame, bag, slot)
	if (not frame.equipmentinfo) then
		frame.equipmentinfo = frame:CreateFontString(nil, "OVERLAY")
		frame.equipmentinfo:FontTemplate(E.media.font, 12, "THINOUTLINE")
		frame.equipmentinfo:SetWordWrap(true)
		frame.equipmentinfo:SetJustifyH('CENTER')
		frame.equipmentinfo:SetJustifyV('MIDDLE')
	end

	if (frame.equipmentinfo) then
		frame.equipmentinfo:SetAllPoints(frame)

		local key = MapKey(bag, slot)
		if KBI.equipmentMap[key] then	
			quickFormat[#KBI.equipmentMap[key] < 4 and #KBI.equipmentMap[key] or 3](frame.equipmentinfo, KBI.equipmentMap[key])
		else
			quickFormat[0](frame.equipmentinfo, nil)
		end
	end
end

local function UpdateBagInformation(clear)
	updateTimer = nil

	BuildEquipmentMap(clear)
	for _, container in pairs(KBI.containers) do
		for _, bagID in ipairs(container.BagIDs) do
			for slotID = 1, GetContainerNumSlots(bagID) do
				UpdateContainerFrame(container.Bags[bagID][slotID], bagID, slotID)
			end
		end
	end
end

local function DelayUpdateBagInformation(event)
	-- delay to make sure multiple bag events are consolidated to one update.
	if not updateTimer then
		updateTimer = KBI:ScheduleTimer(UpdateBagInformation, .25)
	end
end

function KBI:ToggleSettings()
	if updateTimer then
		self:CancelTimer(updateTimer)
	end

	if E.private.KlixUI.equip.setoverlay then
		self:RegisterEvent("EQUIPMENT_SETS_CHANGED", DelayUpdateBagInformation)
		self:RegisterEvent("BAG_UPDATE", DelayUpdateBagInformation)
		UpdateBagInformation()
	else
		self:UnregisterEvent("EQUIPMENT_SETS_CHANGED")
		self:UnregisterEvent("BAG_UPDATE") 
		UpdateBagInformation(true)
	end
end

function KBI:Initialize()
	if not E.private.bags.enable then return end

	tinsert(KBI.containers, _G["ElvUI_ContainerFrame"])
	self:SecureHook(B, "OpenBank", function()
		self:Unhook(B, "OpenBank")
		tinsert(KBI.containers, _G["ElvUI_BankContainerFrame"])
		KBI:ToggleSettings()
	end)

	KBI:ToggleSettings()
end

KUI:RegisterModule(KBI:GetName())