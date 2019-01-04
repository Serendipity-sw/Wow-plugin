local KUI, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule("KuiSkins")
local S = E:GetModule("Skins")

--Cache global variables
--Lua functions
local _G = _G

--WoW API / Variables
local CreateFrame = CreateFrame
--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS:


local function styleAdventureMap()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.orderhall ~= true or E.private.skins.blizzard.garrison ~= true or E.private.KlixUI.skins.blizzard.garrison ~= true then return end

	--[[ AddOns\Blizzard_AdventureMap.xml ]]
	function KS.AdventureMapQuestRewardTemplate(Button)
		S:HandleTexture(Button.Icon, Button)

		Button.ItemNameBG:SetAlpha(0)

		local nameBG = CreateFrame("Frame", nil, Button)
		nameBG:SetPoint("TOPLEFT", Button.Icon, "TOPRIGHT", 2, 1)
		nameBG:SetPoint("BOTTOMRIGHT")
	end

	local AdventureMapQuestChoiceDialog = _G["AdventureMapQuestChoiceDialog"]
	AdventureMapQuestChoiceDialog.Rewards:SetAlpha(0)
	AdventureMapQuestChoiceDialog.Background:Hide()

	AdventureMapQuestChoiceDialog.CloseButton:SetPoint("TOPRIGHT", -5, -5)
	AdventureMapQuestChoiceDialog.DeclineButton:SetPoint("BOTTOMRIGHT", -5, 5)
	AdventureMapQuestChoiceDialog.AcceptButton:SetPoint("BOTTOMLEFT", 5, 5)
end

S:AddCallbackForAddon("Blizzard_AdventureMap", "KuiAdventureMap", styleAdventureMap)