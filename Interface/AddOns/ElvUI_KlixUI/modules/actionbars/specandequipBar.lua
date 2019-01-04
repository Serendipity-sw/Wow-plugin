local KUI, E, L, V, P, G = unpack(select(2, ...))
local SEB = KUI:NewModule("SpecEquipBar", "AceEvent-3.0");

--Cache global variables
--Lua functions
local _G = _G
local pairs, unpack, select = pairs, unpack, select
local tinsert = table.insert
--WoW API / Variables
local CreateFrame = CreateFrame
local GetNumSpecializations = GetNumSpecializations
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecialization = GetSpecialization
local SetSpecialization = SetSpecialization
local GetLootSpecialization = GetLootSpecialization
local SetLootSpecialization = SetLootSpecialization
local C_EquipmentSet = C_EquipmentSet
local InCombatLockdown = InCombatLockdown
local ShowUIPanel = ShowUIPanel
local UIErrorsFrame = UIErrorsFrame
local C_GarrisonIsPlayerInGarrison = C_Garrison.IsPlayerInGarrison
--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: GameTooltip, GameTooltip_Hide, PAPERDOLL_EQUIPMENTMANAGER, ERR_NOT_IN_COMBAT, PaperDollFrame_SetSidebar
-- GLOBALS: SAVE_CHANGES

function SEB:CreateSpecBar()
	if SEB.db.enable ~= true then return end

	local Spacing, Mult = 4, 1
	local Size = 24

	local specBar = CreateFrame("Frame", "SpecializationBar", E.UIParent)
	specBar:SetFrameStrata("BACKGROUND")
	specBar:SetFrameLevel(0)
	specBar:SetSize(40, 40)
	specBar:SetTemplate("Transparent")
	specBar:SetPoint("BOTTOMLEFT", E.UIParent, "BOTTOMLEFT", 43, 194)
	specBar:Styling()
	specBar:Hide()
	E.FrameLocks[specBar] = true

	specBar.Button = {}
	E:CreateMover(specBar, "SpecializationBarMover", L["SpecializationBarMover"], nil, nil, nil, 'ALL,ACTIONBARS,KLIXUI', nil, "KlixUI,modules,actionbars,SEBar")

	specBar:SetScript('OnEnter', function(self) UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1) end)
	specBar:SetScript('OnLeave', function(self)
		if SEB.db.mouseover then
			UIFrameFadeOut(self, 0.2, self:GetAlpha(), SEB.db.malpha)
		end
	end)

	local Specs = GetNumSpecializations()

	for i = 1, Specs do
		local SpecID, SpecName, Description, Icon = GetSpecializationInfo(i)
		local Button = CreateFrame("Button", nil, specBar)
		Button:SetSize(Size, Size)
		Button:SetID(i)
		Button:SetTemplate()
		Button:StyleButton()
		Button:SetNormalTexture(Icon)
		Button:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		Button:GetNormalTexture():SetInside()
		Button:SetPushedTexture(Icon)
		Button:GetPushedTexture():SetInside()
		Button:RegisterForClicks('AnyDown')
		Button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(SpecName)
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(Description, true)
			GameTooltip:Show()
		end)
		Button:SetScript("OnLeave", GameTooltip_Hide)
		Button:SetScript("OnClick", function(self, button)
			if button == "LeftButton" then
				if self:GetID() ~= GetSpecialization() then
					SetSpecialization(self:GetID())
				end
			end
		end)
		Button:SetScript("OnEvent", function(self)
			local Spec = GetSpecialization()
			if Spec == self:GetID() then
				self:SetBackdropBorderColor(0, 0.44, .87)
			else
				self:SetTemplate()
			end
		end)

		Button:HookScript('OnEnter', function(self)
			if specBar:IsShown() then
				UIFrameFadeIn(specBar, 0.2, specBar:GetAlpha(), 1)
			end
		end)
		Button:HookScript('OnLeave', function(self)
			if specBar:IsShown() and SEB.db.mouseover then
				UIFrameFadeOut(specBar, 0.2, specBar:GetAlpha(), SEB.db.malpha)
			end
		end)

		Button:SetPoint("LEFT", i == 1 and specBar or specBar.Button[i - 1], i == 1 and "LEFT" or "RIGHT", Spacing, 0)

		specBar.Button[i] = Button
	end

	local BarWidth = (Spacing + ((Size * (Specs * Mult)) + ((Spacing * (Specs - 1)) * Mult) + (Spacing * Mult)))
	local BarHeight = (Spacing + (Size * Mult) + (Spacing * Mult))

	specBar:SetSize(BarWidth, BarHeight)

	for _, Button in pairs(specBar.Button) do
		Button:HookScript("OnClick", function(self, button)
			if button == "RightButton" then
				local SpecID = GetSpecializationInfo(self:GetID())
				if (GetLootSpecialization() == SpecID) then
					SpecID = 0
				end
				SetLootSpecialization(SpecID)
			end
		end)
		Button:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
		Button:RegisterEvent("PLAYER_ENTERING_WORLD")
		Button:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
		Button:HookScript("OnEvent", function(self)
			if (GetLootSpecialization() == GetSpecializationInfo(self:GetID())) then
				self:SetBackdropBorderColor(1, 0.44, .4)
			end
		end)
	end
	
	if SEB.db.mouseover then
		UIFrameFadeOut(specBar, 0.2, specBar:GetAlpha(), SEB.db.malpha)
	else
		UIFrameFadeIn(specBar, 0.2, specBar:GetAlpha(), 1)
	end
end

function SEB:CreateEquipBar()
	if SEB.db.enable ~= true then return end

	local GearTexture = "Interface\\WorldMap\\GEAR_64GREY"
	local EquipmentSets = CreateFrame("Frame", "EquipmentSets", E.UIParent)
	EquipmentSets:SetFrameStrata("BACKGROUND")
	EquipmentSets:SetFrameLevel(0)
	EquipmentSets:SetSize(32, 32)
	EquipmentSets:SetTemplate("Transparent")
	EquipmentSets:SetPoint("RIGHT", _G["SpecializationBar"], "LEFT", -1, 0)
	EquipmentSets:Styling()
	EquipmentSets:Hide()
	E.FrameLocks[EquipmentSets] = true

	E:CreateMover(EquipmentSets, "EquipmentSetsBarMover", L["EquipmentSetsBarMover"], nil, nil, nil, 'ALL,ACTIONBARS,KLIXUI', nil, "KlixUI,modules,actionbars")
	
	EquipmentSets:SetScript('OnEnter', function(self) UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1) end)
	EquipmentSets:SetScript('OnLeave', function(self)
		if SEB.db.mouseover then
			UIFrameFadeOut(self, 0.2, self:GetAlpha(), SEB.db.malpha)
		end
	end)

	EquipmentSets.Button = CreateFrame("Button", nil, EquipmentSets)
	EquipmentSets.Button:SetFrameStrata("BACKGROUND")
	EquipmentSets.Button:SetFrameLevel(1)
	EquipmentSets.Button:SetTemplate()
	EquipmentSets.Button:SetPoint("CENTER")
	EquipmentSets.Button:SetSize(24, 24)
	EquipmentSets.Button:SetNormalTexture("Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs")
	EquipmentSets.Button:GetNormalTexture():SetTexCoord(0.01562500, 0.53125000, 0.46875000, 0.60546875)
	EquipmentSets.Button:GetNormalTexture():SetInside()
	EquipmentSets.Button:SetPushedTexture("")
	EquipmentSets.Button:SetHighlightTexture("")
	EquipmentSets.Button:HookScript("OnEnter", function(self) self:SetBackdropBorderColor(0, 0.44, .87) end)
	EquipmentSets.Button:HookScript("OnLeave", function(self) self:SetTemplate() end)

	EquipmentSets.Button.Icon = EquipmentSets.Button:CreateTexture(nil, "OVERLAY")
	EquipmentSets.Button.Icon:SetTexCoord(.1, .9, .1, .9)
	EquipmentSets.Button.Icon:SetInside()

	EquipmentSets.Flyout = CreateFrame("Button", nil, EquipmentSets)
	EquipmentSets.Flyout:SetFrameStrata("BACKGROUND")
	EquipmentSets.Flyout:SetFrameLevel(2)
	EquipmentSets.Flyout:SetPoint("TOP", EquipmentSets, "TOP", 0, 0)
	EquipmentSets.Flyout:SetSize(23, 11)
	EquipmentSets.Flyout.Arrow = EquipmentSets.Flyout:CreateTexture(nil, "OVERLAY", "ActionBarFlyoutButton-ArrowUp")
	EquipmentSets.Flyout.Arrow:SetAllPoints()
	EquipmentSets.Flyout:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(PAPERDOLL_EQUIPMENTMANAGER)
		GameTooltip:Show()
	end)
	
	EquipmentSets.Flyout:SetScript("OnLeave", GameTooltip_Hide)
	EquipmentSets.Flyout:SetScript("OnClick", function()
		for i = 1, 10 do
			if EquipmentSets.Button[i]:IsShown() then
				EquipmentSets.Button[i]:Hide()
			else
				if EquipmentSets.Button[i]:GetNormalTexture():GetTexture() ~= GearTexture then
					EquipmentSets.Button[i]:Show()
				end
			end
		end
	end)
	
	EquipmentSets.Flyout:HookScript("OnEnter", function(self)
		if EquipmentSets:IsShown() then
			UIFrameFadeIn(EquipmentSets, 0.2, EquipmentSets:GetAlpha(), 1)
		end
	end)
	EquipmentSets.Flyout:HookScript("OnLeave", function(self)
		if EquipmentSets:IsShown() and SEB.db.mouseover then
			UIFrameFadeOut(EquipmentSets, 0.2, EquipmentSets:GetAlpha(), SEB.db.malpha)
		end
	end)
	
	for i = 1, 10 do
		local Button = CreateFrame("Button", nil, EquipmentSets.Flyout)
		Button:Hide()
		Button:SetSize(24, 24)
		Button:SetTemplate()
		Button:SetFrameStrata("TOOLTIP")
		Button:SetNormalTexture(GearTexture)
		Button:GetNormalTexture():SetTexCoord(.1, .9, .1, .9)
		Button:GetNormalTexture():SetInside()
		Button:SetPoint("BOTTOM", i == 1 and EquipmentSets.Flyout or EquipmentSets.Button[i - 1], "TOP", 0, 3)
		Button:SetScript("OnEnter", function(self)
			local Name = C_EquipmentSet.GetEquipmentSetInfo(self:GetID())
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:SetEquipmentSet(Name)
		end)
		Button:SetScript("OnClick", function(self)
			local _, Icon, Index, IsEquipped = C_EquipmentSet.GetEquipmentSetInfo(self:GetID())
			EquipmentSets.Button:SetID(Index)
			EquipmentSets.Button.Icon:SetTexture(Icon)
			if not IsEquipped then C_EquipmentSet.UseEquipmentSet(self:GetID()) end
			EquipmentSets.Flyout:Click()
		end)
		Button:SetScript("OnLeave", GameTooltip_Hide)
		Button:HookScript("OnEnter", function(self)
			if EquipmentSets:IsShown() then
				UIFrameFadeIn(EquipmentSets, 0.2, EquipmentSets:GetAlpha(), 1)
			end
		end)
		Button:HookScript("OnLeave", function(self)
			if EquipmentSets:IsShown() and SEB.db.mouseover then
				UIFrameFadeOut(EquipmentSets, 0.2, EquipmentSets:GetAlpha(), SEB.db.malpha)
			end
		end)

		EquipmentSets.Button[i] = Button
	end

	EquipmentSets.Button:SetScript("OnClick", function(self)
		if InCombatLockdown() then
			return UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT, 1.0, 0.1, 0.1, 1.0);
		end
		if not self:GetID() then
			ShowUIPanel(_G["CharacterFrame"])
			PaperDollFrame_SetSidebar(_G["CharacterFrame"], 3)
			return
		end

		if not select(4, C_EquipmentSet.GetEquipmentSetInfo(self:GetID())) then
			C_EquipmentSet.UseEquipmentSet(self:GetID())
		end
	end)

	EquipmentSets.Button:SetScript("OnEnter", function(self)
		local Name = C_EquipmentSet.GetEquipmentSetInfo(self:GetID())
		if not Name then return end
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetEquipmentSet(Name)
	end)
	EquipmentSets.Button:SetScript("OnLeave", GameTooltip_Hide)
	EquipmentSets.Button:RegisterEvent("PLAYER_ENTERING_WORLD")
	EquipmentSets.Button:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	EquipmentSets.Button:RegisterEvent("EQUIPMENT_SETS_CHANGED")
	EquipmentSets.Button:RegisterUnitEvent('UNIT_INVENTORY_CHANGED', 'player')
	EquipmentSets.Button:SetScript("OnEvent", function(self)
		local Index, SetEquipped = 1
		for i = 1, 10 do
			local _, Icon, SpecIndex, IsEquipped = C_EquipmentSet.GetEquipmentSetInfo(i - 1)
			self[i]:SetNormalTexture(GearTexture)
			self[i]:SetID(i)
			if SpecIndex then
				self[Index]:SetID(SpecIndex)
				self[Index]:SetNormalTexture(Icon)
				if IsEquipped then
					SetEquipped = IsEquipped
					self:SetID(SpecIndex)
					self.Icon:SetTexture(Icon)
				end
				Index = Index + 1
			end
		end
		if not SetEquipped then
			self.SaveButton.Icon:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")
			self.SaveButton:Enable()
			self.SaveButton:EnableMouse(true)
		else
			self.SaveButton.Icon:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
			self.SaveButton:Disable()
			self.SaveButton:EnableMouse(false)
		end
	end)

	EquipmentSets.Button:HookScript("OnEnter", function(self)
		self:SetBackdropBorderColor(0, 0.44, .87)
		if EquipmentSets:IsShown() then
			UIFrameFadeIn(EquipmentSets, 0.2, EquipmentSets:GetAlpha(), 1)
		end
	end)
	EquipmentSets.Button:HookScript("OnLeave", function(self)
		self:SetTemplate()
		if EquipmentSets:IsShown() and SEB.db.mouseover then
			UIFrameFadeOut(EquipmentSets, 0.2, EquipmentSets:GetAlpha(), SEB.db.malpha)
		end
	end)

	EquipmentSets.Button.SaveButton = CreateFrame("Button", nil, EquipmentSets.Button)
	EquipmentSets.Button.SaveButton:SetFrameLevel(2)
	EquipmentSets.Button.SaveButton:SetSize(14, 14)
	EquipmentSets.Button.SaveButton:SetPoint("BOTTOMLEFT", EquipmentSets.Button, "BOTTOMLEFT", 0, 0)
	EquipmentSets.Button.SaveButton.Icon = EquipmentSets.Button.SaveButton:CreateTexture(nil, "ARTWORK")
	EquipmentSets.Button.SaveButton.Icon:SetAllPoints()
	EquipmentSets.Button.SaveButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(SAVE_CHANGES)
	end)
	EquipmentSets.Button.SaveButton:SetScript("OnLeave", GameTooltip_Hide)
	EquipmentSets.Button.SaveButton:SetScript("OnClick", function(self, button)
		C_EquipmentSet.SaveEquipmentSet(EquipmentSets.Button:GetID())
	end)
	
	if SEB.db.mouseover then
		UIFrameFadeOut(EquipmentSets, 0.2, EquipmentSets:GetAlpha(), SEB.db.malpha)
	else
		UIFrameFadeIn(EquipmentSets, 0.2, EquipmentSets:GetAlpha(), 1)
	end
end

function SEB:PLAYER_REGEN_DISABLED()
	if SEB.db.hideInCombat then
	SpecializationBar:Hide()
	EquipmentSets:Hide()
	end
end

function SEB:PLAYER_REGEN_ENABLED()
	if SEB.db.enable then
	SpecializationBar:Show()
	EquipmentSets:Show()
	end
end

function SEB:UNIT_AURA(event, unit)
	if unit ~= "player" then return end
	if SEB.db.enable and SEB.db.hideInOrderHall then
		local inOrderHall = C_GarrisonIsPlayerInGarrison(LE_GARRISON_TYPE_7_0)
		SpecializationBar:SetShown(not inOrderHall)
		EquipmentSets:SetShown(not inOrderHall)
	end
end

function SEB:Initialize()
	SEB.db = E.db.KlixUI.actionbars.SEBar
	if SEB.db.enable ~= true then return end

	SEB:CreateSpecBar()
	SEB:CreateEquipBar()
	
	SEB:RegisterEvent("PLAYER_REGEN_DISABLED")
	SEB:RegisterEvent("PLAYER_REGEN_ENABLED")
	SEB:RegisterEvent("UNIT_AURA")
end

local function InitializeCallback()
	SEB:Initialize()
end

KUI:RegisterModule(SEB:GetName(), InitializeCallback)
