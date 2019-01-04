local KUI, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

--Cache global variables
--Lua functions

--WoW API / Variables

--Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS:

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.deathRecap ~= true or E.private.KlixUI.skins.blizzard.deathRecap ~= true then return end

	local DeathRecapFrame = _G["DeathRecapFrame"]
	DeathRecapFrame:Styling()
end

S:AddCallbackForAddon("Blizzard_DeathRecap", "KuiDeathRecap", LoadSkin)