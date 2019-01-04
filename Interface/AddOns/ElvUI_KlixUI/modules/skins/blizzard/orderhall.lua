local KUI, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule("KuiSkins")
local S = E:GetModule("Skins");
local LSM = LibStub("LibSharedMedia-3.0")

-- Cache global variables
-- Lua functions
local _G = _G
local ipairs, select, unpack = ipairs, select, unpack
-- WoW API / Variables
local CreateFrame = CreateFrame
local C_TimerAfter = C_Timer.After
--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: hooksecurefunc

local function styleOrderhall()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.orderhall ~= true or E.private.KlixUI.skins.blizzard.orderhall ~= true then return end


	local OrderHallTalentFrame = _G["OrderHallTalentFrame"]

	OrderHallTalentFrame:HookScript("OnShow", function(self)
		if self.styled then return end
		self:Styling()
		self.styled = true
	end)
end

S:AddCallbackForAddon("Blizzard_OrderHallUI", "KuiOrderHall", styleOrderHall)