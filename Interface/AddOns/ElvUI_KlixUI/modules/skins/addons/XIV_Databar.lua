local KUI, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule("KuiSkins")
local S = E:GetModule("Skins")
if not IsAddOnLoaded("XIV_Databar") then return end

-- Cache global variables
-- Lua functions
local _G = _G
-- WoW API / Variables
-- GLOBALS:

local function styleXIV_Databar()
	if E.private.KlixUI.skins.addonSkins.xiv ~= true then return end

	_G["XIV_Databar"]:StripTextures()
	KS:CreateBD(_G["XIV_Databar"], .5)
	_G["XIV_Databar"]:Styling()
	_G["XIV_Databar"]:SetParent(E.UIParent)
	_G["SpecPopup"]:SetTemplate("Transparent")
	_G["LootPopup"]:SetTemplate("Transparent")
	_G["portPopup"]:SetTemplate("Transparent")
end

S:AddCallbackForAddon("XIV_Databar", "KuiXIV_Databar", styleXIV_Databar)