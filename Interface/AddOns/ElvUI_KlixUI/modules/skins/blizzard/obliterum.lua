local KUI, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

--Cache global variables
local _G = _G
--WoW API / Variables

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS:

local function styleObliterum()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.Obliterum ~= true or E.private.KlixUI.skins.blizzard.Obliterum ~= true then return end

	_G["ObliterumForgeFrame"]:Styling()
end

S:AddCallbackForAddon("Blizzard_ObliterumUI", "KuiObliterum", styleObliterum)