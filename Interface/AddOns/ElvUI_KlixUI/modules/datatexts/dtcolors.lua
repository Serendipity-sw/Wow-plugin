--Credit Benik!
local KUI, E, L, V, P, G = unpack(select(2, ...))
local DTC = KUI:NewModule('DataTextColors', 'AceEvent-3.0');
local DT = E:GetModule('DataTexts');

-- Do the job
function DTC:ColorFont()
	for panelName, panel in pairs(DT.RegisteredPanels) do
		for i = 1, panel.numPoints do
			local pointIndex = DT.PointLocation[i]
			if E.db.KlixUI.datatexts.colors.customColor == 1 then
				panel.dataPanels[pointIndex].text:SetTextColor(KUI.ClassColor.r, KUI.ClassColor.g, KUI.ClassColor.b)
			elseif E.db.KlixUI.datatexts.colors.customColor == 2 then
				panel.dataPanels[pointIndex].text:SetTextColor(KUI:unpackColor(E.db.KlixUI.datatexts.colors.userColor))
			else
				panel.dataPanels[pointIndex].text:SetTextColor(KUI:unpackColor(E.db.general.valuecolor))
			end
		end
	end
end

function DTC:PLAYER_ENTERING_WORLD(...)
	self:ColorFont()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function DTC:Initialize()
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
end

KUI:RegisterModule(DTC:GetName())