local KUI, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule("KuiSkins")
local S = E:GetModule("Skins")

-- Cache global variables
-- Lua functions
local _G = _G
local unpack = unpack
-- WoW API
local CreateFrame = CreateFrame
local GetContainerNumSlots = GetContainerNumSlots
local GetContainerItemLink = GetContainerItemLink
local PickupInventoryItem = PickupInventoryItem
local PickupContainerItem = PickupContainerItem
local IsAddOnLoaded = IsAddOnLoaded
-- Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS:

local function styleCharacter()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.character ~= true or E.private.KlixUI.skins.blizzard.character ~= true then return end

	local r, g, b = unpack(E["media"].rgbvaluecolor)

	-- Hide ElvUI Backdrop
	if _G["CharacterModelFrame"].backdrop then
		_G["CharacterModelFrame"].backdrop:Hide()
	end

	_G["CharacterFrame"]:Styling()

	if _G["CharacterModelFrame"] and _G["CharacterModelFrame"].BackgroundTopLeft and _G["CharacterModelFrame"].BackgroundTopLeft:IsShown() then
		_G["CharacterModelFrame"].BackgroundTopLeft:Hide()
		_G["CharacterModelFrame"].BackgroundTopRight:Hide()
		_G["CharacterModelFrame"].BackgroundBotLeft:Hide()
		_G["CharacterModelFrame"].BackgroundBotRight:Hide()
		_G["CharacterModelFrameBackgroundOverlay"]:Hide()
		if _G["CharacterModelFrame"].backdrop then
			_G["CharacterModelFrame"].backdrop:Hide()
		end
	end

	if E.db.KlixUI.armory.naked then
		-- Undress Button
		local function Button_OnEnter(self)
			GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 0, 4)
			GameTooltip:ClearLines()
			GameTooltip:AddLine(L["Instantly remove all your equipped gear."])
			GameTooltip:Show()
		end

		local function Button_OnLeave(self)
			GameTooltip:Hide()
		end
		
		local function UnequipItemInSlot(i)
			if InCombatLockdown() then return end
			local action = EquipmentManager_UnequipItemInSlot(i)
			EquipmentManager_RunAction(action)
		end

		local undress = CreateFrame("Button", KUI.Title.."UndressButton", _G["PaperDollFrame"], "UIPanelButtonTemplate")
		undress:SetFrameStrata("HIGH")
		undress:SetSize(50, 20)
		if E.private.KlixUI.equip.lockbutton then
			if IsAddOnLoaded("ElvUI_SLE") then
				undress:SetPoint("TOPLEFT", _G["CharacterWristSlot"], "BOTTOMLEFT", 19, -34)
			else
				undress:SetPoint("TOPLEFT", _G["CharacterWristSlot"], "BOTTOMLEFT", 19, -14)
			end
		else
			if IsAddOnLoaded("ElvUI_SLE") then
				undress:SetPoint("TOPLEFT", _G["CharacterWristSlot"], "BOTTOMLEFT", -1, -32)
			else
				undress:SetPoint("TOPLEFT", _G["CharacterWristSlot"], "BOTTOMLEFT", -1, -10)
			end
		end

		undress.text = KUI:CreateText(undress, "OVERLAY", 12, nil)
		undress.text:SetPoint("CENTER")
		undress.text:SetText(L["Naked"])

		undress:SetScript('OnEnter', Button_OnEnter)
		undress:SetScript('OnLeave', Button_OnLeave)
		undress:SetScript("OnClick", function()
			for i = 1, 17 do
				local texture = GetInventoryItemTexture('player', i)
				if texture then
					UnequipItemInSlot(i)
				end
			end
		end)
		S:HandleButton(undress)
	end
end

S:AddCallback("KuiCharacter", styleCharacter)