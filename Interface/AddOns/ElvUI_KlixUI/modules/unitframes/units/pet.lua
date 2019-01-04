local KUI, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KUIUnits")
local UF = E:GetModule("UnitFrames")

-- Cache global variables
-- Lua functions
local _G = _G

-- WoW API / Variables

-- Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS:

function KUF:Construct_PetFrame()
	local frame = _G["ElvUF_Pet"]

	self:ArrangePet()
end

function KUF:ArrangePet()
	local frame = _G["ElvUF_Pet"]
	
    frame:UpdateAllElements("KUI_UpdateAllElements")
end

function KUF:InitPet()
	if not E.db.unitframe.units.pet.enable then return end

	self:Construct_PetFrame()
end