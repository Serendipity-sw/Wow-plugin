local KUI, E, L, V, P, G = unpack(select(2, ...))
local KGM = KUI:NewModule("KuiGameMenu")
local KS = KUI:GetModule("KuiSkins")
local S = E:GetModule("Skins")

-- Cache global variables
-- Lua functions
local _G = _G
local format, random, lower, tonumber, date, floor = string.format, random, string.lower, tonumber, date, floor
-- WoW API / Variables
local GameMenuFrame = _G["GameMenuFrame"]
local CreateFrame = CreateFrame
local CreateAnimationGroup = CreateAnimationGroup
local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight
local UIFrameFadeIn = UIFrameFadeIn
local IsAddOnLoaded = IsAddOnLoaded

-- Global variables that we don"t cache, list them here for the mikk"s Find Globals script
-- GLOBALS: button, modelHolder, playerModel, npcHolder, npcModel, LibStub

-- Credit for the Class logos: ADDOriN @DevianArt
-- http://addorin.deviantart.com/gallery/43689290/World-of-Warcraft-Class-Logos

local logo = "Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\KlixUILogo.tga"

KUI.PEPE = {
	--[0] = "World/expansion05/doodads/ORC/DOODADS/6hu_garrison_orangebird.m2" -- Original Pepe
	[1] = "World/expansion05/doodads/ORC/DOODADS/6HU_GARRISON_ORANGEBIRD_VAR_HALLOWEEN.m2", -- Pepe (Halloween)
	[2] = "World/expansion05/doodads/ORC/DOODADS/6HU_GARRISON_ORANGEBIRD_VAR1.m2", -- Knight Pepe
	[3] = "World/expansion05/doodads/ORC/DOODADS/6HU_GARRISON_ORANGEBIRD_VAR2.m2", -- Pirate Pepe
	[4] = "World/expansion05/doodads/ORC/DOODADS/6HU_GARRISON_ORANGEBIRD_VAR3.m2", -- Ninja Pepe
	[5] = "World/expansion05/doodads/ORC/DOODADS/6HU_GARRISON_ORANGEBIRD_VAR4.m2", -- Viking Pepe
	[6] = "World/Expansion05/Doodads/Human/Doodads/6HU_Garrison_OrangeBird_VAR5.M2", -- Illidan Pepe
	[7] = "World/Expansion06/Doodads/Dalaran/7DL_DALARAN_ORANGEBIRD.m2", -- Traveller Pepe
	[8] = "world/expansion07/doodads/human/8hu_kultiras_orangebird01.m2", -- Underwater Pepe
	[9] = "world/expansion07/doodads/zandalaritroll/8tr_zandalari_orangebird01.m2", -- Troll Pepe
	--[10] = "World/Expansion06/Doodads/7XP_FISHING_ORANGEBIRDBOBBER.m2" -- Bobber Pepe
}

local function Pepe_Model(self)
	local npc = KUI.PEPE
	local mod = random(1, #npc)
	local id = npc[mod]

	self:ClearModel()
	self:SetModel(id)
	self:SetSize(200, 200)
	self:SetCamDistanceScale(1)
	self:SetFacing(6)
	self:SetAlpha(1)
	UIFrameFadeIn(self, 1, self:GetAlpha(), 1)
end

function KGM:GameMenu()
	-- GameMenu Frame
	if not GameMenuFrame.KuibottomPanel then
		GameMenuFrame.KuibottomPanel = CreateFrame("Frame", nil, GameMenuFrame)
		local bottomPanel = GameMenuFrame.KuibottomPanel
		bottomPanel:SetFrameLevel(0)
		bottomPanel:SetPoint("BOTTOM", E.UIParent, "BOTTOM", 0, -E.Border)
		bottomPanel:SetWidth(GetScreenWidth() + (E.Border*2))
		KS:CreateBD(bottomPanel, .5)
		bottomPanel:Styling()

		bottomPanel.ignoreFrameTemplates = true
		bottomPanel.ignoreBackdropColors = true
		E["frames"][bottomPanel] = true

		bottomPanel.anim = CreateAnimationGroup(bottomPanel)
		bottomPanel.anim.height = bottomPanel.anim:CreateAnimation("Height")
		bottomPanel.anim.height:SetChange(GetScreenHeight() * (1 / 5))
		bottomPanel.anim.height:SetDuration(1.4)
		bottomPanel.anim.height:SetSmoothing("Bounce")

		bottomPanel:SetScript("OnShow", function(self)
			self:SetHeight(0)
			self.anim.height:Play()
		end)
		
		bottomPanel.Logo = bottomPanel:CreateTexture(nil, "ARTWORK")
		bottomPanel.Logo:SetSize(150, 150)
		bottomPanel.Logo:SetPoint("CENTER", bottomPanel, "CENTER", 0, 0)
		bottomPanel.Logo:SetTexture(logo)

		bottomPanel.Version = KUI:CreateText(bottomPanel, "OVERLAY", 18, "OUTLINE")
		bottomPanel.Version:SetText("v"..KUI.Version)
		bottomPanel.Version:SetPoint("TOP", bottomPanel.Logo, "BOTTOM")
		bottomPanel.Version:SetTextColor(unpack(E["media"].rgbvaluecolor))
		
		--bottomPanel.Text = bottomPanel:CreateFontString(nil, 'OVERLAY')
		--bottomPanel.Text:FontTemplate(nil, 20)
		--bottomPanel.Text:SetPoint("CENTER", bottomPanel, "CENTER")
		--bottomPanel.Text:SetJustifyH("CENTER")
		--bottomPanel.Text:SetText(TIME_PLAYED_MSG)
		--bottomPanel.Text:SetFormattedText(L["Session:"], SessionDay > 0 and format(PlayedTimeFormatFull, SessionDay, SessionHour, SessionMinute, SessionSecond) or format(PlayedTimeFormatNoDay, SessionHour, SessionMinute, SessionSecond), 1, 1, 1, 1, 1, 1)
		--if LastLevelSecond > 0 then
			--bottomPanel.Text:SetFormattedText(L["Previous Level:"], LastLevelDay > 0 and format(PlayedTimeFormatFull, LastLevelDay, LastLevelHour, LastLevelMinute, LastLevelSecond) or format(PlayedTimeFormatNoDay, LastLevelHour, LastLevelMinute, LastLevelSecond), 1, 1, 1, 1, 1, 1)
		--end
		--bottomPanel.Text:SetFormattedText(LEVEL..':', LevelDay > 0 and format(PlayedTimeFormatFull, LevelDay, LevelHour, LevelMinute, LevelSecond) or format(PlayedTimeFormatNoDay, LevelHour, LevelMinute, LevelSecond), 1, 1, 1, 1, 1, 1)
		--bottomPanel.Text:SetFormattedText(TOTAL..':', TotalDay > 0 and format(PlayedTimeFormatFull, TotalDay, TotalHour, TotalMinute, TotalSecond) or format(PlayedTimeFormatNoDay, TotalHour, TotalMinute, TotalSecond), 1, 1, 1, 1, 1, 1)
		--bottomPanel.Text:SetTextColor(KUI.ClassColor.r, KUI.ClassColor.g, KUI.ClassColor.b)
	end

	if not GameMenuFrame.KuitopPanel then
		GameMenuFrame.KuitopPanel = CreateFrame("Frame", nil, GameMenuFrame)
		local topPanel = GameMenuFrame.KuitopPanel
		topPanel:SetFrameLevel(0)
		topPanel:SetPoint("TOP", E.UIParent, "TOP", 0, 0)
		topPanel:SetWidth(GetScreenWidth() + (E.Border*2))
		KS:CreateBD(topPanel, .5)
		topPanel:Styling()

		topPanel.ignoreFrameTemplates = true
		topPanel.ignoreBackdropColors = true
		E["frames"][topPanel] = true

		topPanel.anim = CreateAnimationGroup(topPanel)
		topPanel.anim.height = topPanel.anim:CreateAnimation("Height")
		topPanel.anim.height:SetChange(GetScreenHeight() * (1 / 5))
		topPanel.anim.height:SetDuration(1.4)
		topPanel.anim.height:SetSmoothing("Bounce")

		topPanel:SetScript("OnShow", function(self)
			self:SetHeight(0)
			self.anim.height:Play()
		end)

		topPanel.factionLogo = topPanel:CreateTexture(nil, "ARTWORK")
		topPanel.factionLogo:SetPoint("CENTER", topPanel, "CENTER", 0, 0)
		topPanel.factionLogo:SetSize(156, 150)
		topPanel.factionLogo:SetTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\classIcons\\CLASS-"..E.myclass)
	end
	
	if not pepeHolder then
		local pepeHolder = CreateFrame("Frame", nil, GameMenuFrame)
		pepeHolder:SetSize(175, 175)
		pepeHolder:SetPoint("BOTTOM", GameMenuFrame, "TOP", 0, -50)

		pepeModel = CreateFrame("PlayerModel", nil, pepeHolder)
		pepeModel:SetPoint("CENTER", pepeHolder, "CENTER")
		pepeModel:SetScript("OnShow", Pepe_Model)
		pepeModel.isIdle = nil
		pepeModel:Show()
	end
end

function KGM:Initialize()
	if E.db.KlixUI.general.GameMenuScreen then
		self:GameMenu()
		E:UpdateBorderColors()
	end
end

local function InitializeCallback()
	KGM:Initialize()
end

KUI:RegisterModule(KGM:GetName(), InitializeCallback)
