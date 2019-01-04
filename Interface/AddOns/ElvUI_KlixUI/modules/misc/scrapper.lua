local KUI, E, L, V, P, G = unpack(select(2, ...))
local SCRAP = KUI:NewModule("Scrapper", "AceEvent-3.0")
local S = E:GetModule("Skins")
local itemLocation = itemLocation or ItemLocation:CreateEmpty()

--[[local function ItemPrint(text, ...)
	if E.db.KlixUI.misc.scrapper.Itemprint then
		print(string.format("|c%sScrap:|r: Inserting %s (%s)", ns.Config.color, text, ...))
	end
end]]

local function PositionScrapButton(self)
	if E.db.KlixUI.misc.scrapper.position == "BOTTOM" then
		self:ClearAllPoints()
		self:SetPoint("CENTER", ScrappingMachineFrame, "BOTTOM", 0, 42)
	elseif E.db.KlixUI.misc.scrapper.position == "TOP" then
		self:ClearAllPoints()
		self:SetPoint("CENTER", ScrappingMachineFrame, "TOP", 0, -45)
	end
end

--amazing tooltip function from Personal Loot Helper
local function CreateEmptyTooltip()
    local tip = CreateFrame('GameTooltip')
	local leftside = {}
	local rightside = {}
	local L, R
	-- 50 is max tooltip length atm (might need change)
	for i = 1, 50 do
		L, R = tip:CreateFontString(), tip:CreateFontString()
		L:SetFontObject(GameFontNormal)
		R:SetFontObject(GameFontNormal)
		tip:AddFontStrings(L, R)
		leftside[i] = L
		rightside[i] = R
	end
	tip.leftside = leftside
	tip.rightside = rightside
	return tip
end

local function GetItemLvl(item)
	if (not E.db.KlixUI.misc.scrapper.Itemlvl and not E.db.KlixUI.misc.scrapper.specificilvl) then
		return true
	end

	local itemlvl = nil
	local PLH_ITEM_LEVEL_PATTERN = _G.ITEM_LEVEL:gsub('%%d', '(%%d+)')
	if item ~= nil then
		tooltip = tooltip or CreateEmptyTooltip()
		tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
		tooltip:ClearLines()
		tooltip:SetHyperlink(item)
		local t = tooltip.leftside[2]:GetText()
		if t ~= nil then
			itemlvl = t:match(PLH_ITEM_LEVEL_PATTERN)
		end
		if itemlvl == nil then
			t = tooltip.leftside[3]:GetText()
			if t ~= nil then
				itemlvl = t:match(PLH_ITEM_LEVEL_PATTERN)
			end
		end
		tooltip:Hide()
		
		if itemlvl == nil then
			itemlvl = select(4, GetItemInfo(item))
		end
	end
	
	if itemlvl == nil then
		itemlvl = 0
	end

	itemlvl = tonumber(itemlvl)
 
	return itemlvl
end

local function ItemLvlComparison(equipped, itemlvl)
	if (not E.db.KlixUI.misc.scrapper.Itemlvl and not E.db.KlixUI.misc.scrapper.specificilvl) then
		return true
	end

	local ItemLvlLessThanEquip = false
	local ItemLvlNotHigherThanSpecific = false
	
	if E.db.KlixUI.misc.scrapper.specificilvl then
		if type(E.db.KlixUI.misc.scrapper.specificilvlbox) == "number" then
			--DebugPrint("Comparing that " .. tostring(itemlvl) .. " is less than " .. tostring(E.db.KlixUI.misc.scrapper.specificilvlbox) .. " = " .. tostring(itemlvl < E.db.KlixUI.misc.scrapper.specificilvlbox))
			ItemLvlNotHigherThanSpecific = itemlvl < E.db.KlixUI.misc.scrapper.specificilvlbox
		end
	end

	if E.db.KlixUI.misc.scrapper.Itemlvl then
		--DebugPrint("Comparing that " .. tostring(itemlvl) .. " is less than " .. tostring(equipped) .. " = " .. tostring(itemlvl < equipped))
		ItemLvlLessThanEquip = itemlvl < equipped
	end
	
	--returns
	if E.db.KlixUI.misc.scrapper.Itemlvl and E.db.KlixUI.misc.scrapper.specificilvl then
		if ItemLvlLessThanEquip and ItemLvlNotHigherThanSpecific then
			return true
		else
			return false
		end
	elseif E.db.KlixUI.misc.scrapper.Itemlvl then
		return ItemLvlLessThanEquip
	elseif E.db.KlixUI.misc.scrapper.specificilvl then
		return ItemLvlNotHigherThanSpecific
	end
end

local function IsPartOfEquipmentSet(bag, slot)
	if E.db.KlixUI.misc.scrapper.equipmentsets then
		local isInSet, _ = GetContainerItemEquipmentSetInfo(bag, slot)
		return isInSet
	else
		return false
	end
end

local function IsAzeriteItem(itemLocation)
	if E.db.KlixUI.misc.scrapper.azerite then
		local isAzerite = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation)
		return isAzerite
	end
	return false
end

---------------------------------------------------
-- SCRAPPING FUNCTIONS
---------------------------------------------------
local function IsScrappable(itemString)
	local tooltipReader = tooltipReader or CreateEmptyTooltip()
	tooltipReader:SetOwner(WorldFrame, "ANCHOR_NONE")
	tooltipReader:ClearLines()
	local scrappable = false
	local boe = false

	if (itemString ~= nil) then
		tooltipReader:SetHyperlink(itemString)
		--DebugPrint(itemString .. " has lines: " .. tooltipReader:NumLines())
		for i = tooltipReader:NumLines(), 1, -1 do
			local line = tooltipReader.leftside[i]:GetText()
			if line ~= nil then
				if line == "Scrappable" then
					scrappable = true
				end
			end
		end

		if (E.db.KlixUI.misc.scrapper.boe) then
			local boe = false
			for i = 2, 4 do
				local t = tooltipReader.leftside[i]:GetText()
				if t and t == "Binds when equipped" then
					--DebugPrint("Found BoE: " .. itemString)
					boe = true
				end
			end
			return scrappable, boe
		end
	end
	
	return scrappable, false
end

local function InsertScrapItems()
	if not E.db.KlixUI.misc.scrapper.enable then return end
	local _, equipped = GetAverageItemLevel()
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local item = GetContainerItemLink(bag, slot)
			if item ~= nil then
				itemLocation:SetBagAndSlot(bag, slot)
				local azerite_item = IsAzeriteItem(itemLocation)
				local scrappable, boe = IsScrappable(item)
				local itemlvl = GetItemLvl(item)
				local PartOfSet = IsPartOfEquipmentSet(bag, slot)
				if (scrappable and not boe and not PartOfSet and not azerite_item and ItemLvlComparison(equipped, itemlvl)) then
					--ItemPrint(item, itemlvl)
					UseContainerItem(bag, slot)
				end
			end
		end
	end
end

function SCRAP:CreateScrapButton()
	LoadAddOn("Blizzard_ScrappingMachineUI")
	local scrapButton = CreateFrame("Button", "KUI_ScrapButton", ScrappingMachineFrame, "UIPanelButtonTemplate")
	scrapButton:SetSize(150, 23)
	PositionScrapButton(scrapButton)
	scrapButton:SetText("Insert Scrap")
	S:HandleButton(scrapButton)
	
	local scrapCooldown = CreateFrame("Cooldown", "scrapButtonAntiSpam", scrapButton, "CooldownFrameTemplate")
	scrapCooldown:SetAllPoints()

	scrapButton:SetScript("OnClick", function() 
		--local duration = scrapCooldown:GetCooldownDuration()
		--if duration ~= 0 then return end

		if (UnitCastingInfo("player") ~= nil) then
			KUI:Print("You cannot insert items while actively scrapping, cancel your cast to refill.")
			return
		end

		--scrapCooldown:SetCooldown(GetTime(), 0.5)
		PlaySound(73919) -- UI_PROFESSIONS_NEW_RECIPE_LEARNED_TOAST
		InsertScrapItems()
		collectgarbage()
	end)
end

function SCRAP:Initialize()
	if not E.db.KlixUI.misc.scrapper.enable then return end
	self:CreateScrapButton()
end

KUI:RegisterModule(SCRAP:GetName())