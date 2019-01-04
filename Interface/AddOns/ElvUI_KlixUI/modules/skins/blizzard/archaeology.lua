local KUI, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

--Cache global variables
local _G = _G
--WoW API / Variables

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS:

local function styleArchaeology()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.archaeology ~= true or E.private.KlixUI.skins.blizzard.archaeology ~= true then return end

	_G["ArchaeologyFrame"]:Styling()
end

S:AddCallbackForAddon("Blizzard_ArchaeologyUI", "KuiArchaeology", styleArchaeology)