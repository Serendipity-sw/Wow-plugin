local KUI, E, L, V, P, G = unpack(select(2, ...))
local UF = E.UnitFrames
local PlayerFrame --This will be set on PEW event

local function Reposition(classbar)
	if not E.db.unitframe.units.player.power.detachFromFrame then return end
	if E.db.KlixUI.unitframes.powerBar ~= true or E.db.unitframe.units.player.enable ~= true or E.db.unitframe.units.player.power.enable ~= true then return end
	
	if not PlayerFrame.CLASSBAR_DETACHED then
		return --No need to reposition
	end
	
	local height = (PlayerFrame.CLASSBAR_SHOWN and 20 or 31)
	if IsAddOnLoaded("Masque") and IsAddOnLoaded("Masque_KlixUI") then
		ElvUF_Player.Power:Size(244, height)
	else
		ElvUF_Player.Power:Size(245, height)
	end
end

-- Credit: Blazeflack
local function PostUpdatePower(self, unit, _, _, max)
	if not E.db.KlixUI.unitframes.powerBarBackdrop == true then return end
	local parent = self.origParent or self:GetParent()

	if parent.isForced then
		local pType = random(0, 4)
		local color = ElvUF['colors'].power[tokens[pType]]
		local min = random(1, max)
		self:SetValue(min)

		if not self.colorClass then
			self:SetStatusBarColor(color[1], color[2], color[3])
			local mu = self.bg.multiplier or 1
			self.bg:SetVertexColor(color[1] * mu, color[2] * mu, color[3] * mu)
		end
	end

	local db = parent.db
	if db and db.power and db.power.hideonnpc then
		UF:PostNamePosition(parent, unit)
	end

	--Force update to AdditionalPower in order to reposition text if necessary
	if parent:IsElementEnabled("AdditionalPower") then
		E:Delay(0.01, parent.AdditionalPower.ForceUpdate, parent.AdditionalPower) --Delay it slightly so Power text has a chance to clear itself first
	end
	
	--Custom Edit To Color Below
	self.bg:SetVertexColor(18/256,18/256,18/256)
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent(event)

	--Set modified PostUpdate
	ElvUF_Focus.Power.PostUpdate = PostUpdatePower
	ElvUF_Target.Power.PostUpdate = PostUpdatePower
	ElvUF_Player.Power.PostUpdate = PostUpdatePower

	--Set black backdrop
	ElvUF_Focus.Power.backdrop:SetBackdropColor(18/256, 18/256, 18/256)
	ElvUF_Target.Power.backdrop:SetBackdropColor(18/256, 18/256, 18/256)
	ElvUF_Player.Power.backdrop:SetBackdropColor(18/256, 18/256, 18/256)
end)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UNIT_ENTERED_VEHICLE")
f:RegisterEvent("UNIT_ENTERING_VEHICLE")
f:RegisterEvent("UNIT_EXITED_VEHICLE")
f:RegisterEvent("UNIT_EXITING_VEHICLE")
f:RegisterEvent("PLAYER_GAINS_VEHICLE_DATA")
f:RegisterEvent("PLAYER_LOSES_VEHICLE_DATA")
f:RegisterEvent("UNIT_MODEL_CHANGED")
f:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent(event)
		PlayerFrame = ElvUF_Player --Set reference now that ElvUF_Player has been created
		hooksecurefunc(UF, "ToggleResourceBar", Reposition) --Add hook
		UF.ToggleResourceBar(ElvUF_Player.ClassPower) --Force update
	elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
		UF.ToggleResourceBar(ElvUF_Player.ClassPower) --Force update
	elseif event == "UPDATE_SHAPESHIFT_FORM" then
		UF.ToggleResourceBar(ElvUF_Player.ClassPower) --Force update
	elseif event == "PLAYER_LOGIN" then
		UF.ToggleResourceBar(ElvUF_Player.ClassPower) --Force update
	elseif event == "UNIT_ENTERED_VEHICLE" or "UNIT_ENTERING_VEHICLE" or "UNIT_EXITED_VEHICLE" or "UNIT_EXITING_VEHICLE" then
		UF.ToggleResourceBar(ElvUF_Player.ClassPower) --Force update
	elseif event == "PLAYER_GAINS_VEHICLE_DATA" or "PLAYER_LOSES_VEHICLE_DATA" then
		UF.ToggleResourceBar(ElvUF_Player.ClassPower) --Force update
	elseif event == "UNIT_MODEL_CHANGED" or "UNIT_PORTRAIT_CHANGED" then
		UF.ToggleResourceBar(ElvUF_Player.ClassPower) --Force update
	end
end)

