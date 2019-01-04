local KUI, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KUIUnits")
local UF = E:GetModule("UnitFrames")

--Cache global variables
--Lua functions
--WoW API / Variables

function KUF:Update_Raid40Frames(frame, db)
	frame.db = db

	do

	end

	frame:UpdateAllElements("KUI_UpdateAllElements")
end

function KUF:InitRaid40()
	if not E.db.unitframe.units.raid40.enable then return end
	--hooksecurefunc(UF, "Update_Raid40Frames", KUF.Update_Raid40Frames)
end
