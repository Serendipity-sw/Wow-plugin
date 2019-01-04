local KUI, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule("KuiSkins")
local S = E:GetModule("Skins")

--Cache global variables
--Lua functions
local _G = _G

--WoW API / Variables

--Global variables that we don't cache, list them here for the mikk's Find Globals script

local function styleMinimap()
	if E.private.skins.blizzard.enable ~= true or E.private.KlixUI.skins.blizzard.minimap ~= true or E.private.general.minimap.enable ~= true then return end

	_G["Minimap"]:Styling(true, true, false, 180, 180, .75)
end

S:AddCallback("KuiSkinMinimap", styleMinimap)
