﻿local KUI, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KUIUnits")
local UF = E:GetModule("UnitFrames")

--Cache global variables
--Lua functions
--WoW API / Variables

function KUF:Update_PartyFrames(frame, db)
	frame.db = db

	do

	end

	frame:UpdateAllElements("KUI_UpdateAllElements")
end

function KUF:InitParty()
	if not E.db.unitframe.units.party.enable then return end
	--hooksecurefunc(UF, "Update_PartyFrames", KUF.Update_PartyFrames)
end
