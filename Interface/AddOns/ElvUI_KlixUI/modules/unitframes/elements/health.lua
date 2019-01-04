local KUI, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KUIUnits")
local UF = E:GetModule('UnitFrames');
local LSM = LibStub("LibSharedMedia-3.0");
UF.LSM = LSM

local _G = _G
local select = select

-- Raid
function KUF:ChangeRaidHealthBarTexture()
	local header = _G['ElvUF_Raid']
	local bar = LSM:Fetch("statusbar", E.db.KlixUI.unitframes.textures.health)
	for i = 1, header:GetNumChildren() do
		local group = select(i, header:GetChildren())

		for j = 1, group:GetNumChildren() do
			local unitbutton = select(j, group:GetChildren())
			if unitbutton.Health then
				if not unitbutton.Health.isTransparent or (unitbutton.Health.isTransparent and E.db.KlixUI.unitframes.textures.ignoreTransparency) then
					unitbutton.Health:SetStatusBarTexture(bar)
				end
			end
		end
	end
end
hooksecurefunc(UF, 'Update_RaidFrames', KUF.ChangeRaidHealthBarTexture)

-- Raid-40
function KUF:ChangeRaid40HealthBarTexture()
	local header = _G['ElvUF_Raid40']
	local bar = LSM:Fetch("statusbar", E.db.KlixUI.unitframes.textures.health)
	for i = 1, header:GetNumChildren() do
		local group = select(i, header:GetChildren())

		for j = 1, group:GetNumChildren() do
			local unitbutton = select(j, group:GetChildren())
			if unitbutton.Health then
				if not unitbutton.Health.isTransparent or (unitbutton.Health.isTransparent and E.db.KlixUI.unitframes.textures.ignoreTransparency) then
					unitbutton.Health:SetStatusBarTexture(bar)
				end
			end
		end
	end
end
hooksecurefunc(UF, 'Update_Raid40Frames', KUF.ChangeRaid40HealthBarTexture)

-- Party
function KUF:ChangePartyHealthBarTexture()
	local header = _G['ElvUF_Party']
	local bar = LSM:Fetch("statusbar", E.db.KlixUI.unitframes.textures.health)
	for i = 1, header:GetNumChildren() do
		local group = select(i, header:GetChildren())

		for j = 1, group:GetNumChildren() do
			local unitbutton = select(j, group:GetChildren())
			if unitbutton.Health then
				if not unitbutton.Health.isTransparent or (unitbutton.Health.isTransparent and E.db.KlixUI.unitframes.textures.ignoreTransparency) then
					unitbutton.Health:SetStatusBarTexture(bar)
				end
			end
		end
	end
end
hooksecurefunc(UF, 'Update_PartyFrames', KUF.ChangePartyHealthBarTexture)

function KUF:ChangeHealthBarTexture()
	KUF:ChangeRaidHealthBarTexture()
	KUF:ChangeRaid40HealthBarTexture()
	KUF:ChangePartyHealthBarTexture()
end
hooksecurefunc(UF, 'Update_StatusBars', KUF.ChangeHealthBarTexture)