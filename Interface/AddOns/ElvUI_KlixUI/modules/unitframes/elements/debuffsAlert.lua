local KUI, E, L, V, P, G = unpack(select(2, ...))
local DA = KUI:NewModule("DebuffsAlert", 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
local UF = E:GetModule('UnitFrames');

local pairs = pairs

function DA:filter_update()
	if DA.db.DA_filter then
		for spellID, values in pairs(DA.db.DA_filter) do 
			if values.use_color == false or nil then 
				values.color.r = DA.db["default_color"].r
				values.color.g = DA.db["default_color"].g
				values.color.b = DA.db["default_color"].b
			end
		end
	end
end

function DA:Construct_DebuffHighlight(frame)
	if not E.db.KlixUI.unitframes.debuffsAlert.enable then return end
	local dbh = frame.Health
	frame.DebuffHighlightFilter = true
	frame.DebuffHighlightAlpha = 0
	frame.DebuffHighlightFilterTable = DA.db.DA_filter
	return dbh
end

function DA:Configure_DebuffHighlight(frame)
	if not E.db.KlixUI.unitframes.debuffsAlert.enable then return end
	if E.db.unitframe.debuffHighlighting ~= "NONE" then
		frame:EnableElement("DebuffHighlight")
		frame.DebuffHighlightFilterTable = DA.db.DA_filter
		frame.DebuffHighlightBackdrop = false
	else
		frame:DisableElement("DebuffHighlight")
	end
end

hooksecurefunc(UF, "Construct_DebuffHighlight", DA.Construct_DebuffHighlight)
hooksecurefunc(UF, "Configure_DebuffHighlight", DA.Configure_DebuffHighlight)

function DA:Initialize()
	DA.db = E.db.KlixUI.unitframes.debuffsAlert
end

KUI:RegisterModule(DA:GetName())