local KUI, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

--Cache global variables
local _G = _G
--WoW API / Variables

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS:

local function styleBarber()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.barber ~= true or E.private.KlixUI.skins.blizzard.barber ~= true then return end

	_G["BarberShopFrame"]:Styling()
	_G["BarberShopAltFormFrame"]:Styling()
end

S:AddCallbackForAddon("Blizzard_BarbershopUI", "KuiBarber", styleBarber)