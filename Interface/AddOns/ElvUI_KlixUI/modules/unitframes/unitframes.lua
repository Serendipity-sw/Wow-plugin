local KUI, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:NewModule("KUIUnits", 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
local UF = E:GetModule('UnitFrames');
KUF.modName = L["UnitFrames"]

--Cache global variables
--Lua functions
--WoW API / Variables
local IsAddOnLoaded = IsAddOnLoaded

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: UF

function KUF:UpdateUF()
	if E.db.unitframe.units.player.enable then
		KUF:ArrangePlayer()
	end

	if E.db.unitframe.units.target.enable then
		KUF:ArrangeTarget()
	end

	if E.db.unitframe.units.party.enable then
		UF:CreateAndUpdateHeaderGroup("party")
	end
end

function KUF:Configure_ReadyCheckIcon(frame)
	local tex = frame.ReadyCheckIndicator

	if E.db.KlixUI.unitframes.icons.rdy == "Default" then
	tex.readyTexture = [[Interface\RaidFrame\ReadyCheck-Ready]]
	tex.notReadyTexture = [[Interface\RaidFrame\ReadyCheck-NotReady]]
	tex.waitingTexture = [[Interface\RaidFrame\ReadyCheck-Waiting]]
	elseif E.db.KlixUI.unitframes.icons.rdy == "BenikUI" then
    tex.readyTexture = [[Interface\AddOns\ElvUI_KlixUI\media\textures\readycheckIcons\bui-ready]]
	tex.notReadyTexture = [[Interface\AddOns\ElvUI_KlixUI\media\textures\readycheckIcons\bui-notready]]
	tex.waitingTexture = [[Interface\AddOns\ElvUI_KlixUI\media\textures\readycheckIcons\bui-waiting]]
	elseif E.db.KlixUI.unitframes.icons.rdy == "Smiley" then
	tex.readyTexture = [[Interface\AddOns\ElvUI_KlixUI\media\textures\readycheckIcons\smiley-ready]]
	tex.notReadyTexture = [[Interface\AddOns\ElvUI_KlixUI\media\textures\readycheckIcons\smiley-notready]]
	tex.waitingTexture = [[Interface\AddOns\ElvUI_KlixUI\media\textures\readycheckIcons\smiley-waiting]]
	end
end

--Credits: Darth Predator
function KUF:Configure_RaidIcon(frame)
    if E.db.KlixUI.unitframes.icons.klixri == false then return end
    local tex = frame.RaidTargetIndicator
    if tex.KlixReplace then return end
    tex.SetTexture = SetTexture

	if E.db.KlixUI.raidmarkers.raidicons == "Classic" then
	tex:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
	elseif E.db.KlixUI.raidmarkers.raidicons == "Anime" then
    tex:SetTexture([[Interface\AddOns\ElvUI_KlixUI\media\textures\raidmarkers\anime\UI-RaidTargetingIcons]])
	elseif E.db.KlixUI.raidmarkers.raidicons == "Myth" then
	tex:SetTexture([[Interface\AddOns\ElvUI_KlixUI\media\textures\raidmarkers\myth\UI-RaidTargetingIcons]])
	end
    tex.KlixReplace = true
    tex.SetTexture = E.noop
end

function KUF:ADDON_LOADED(event, addon)
	if addon ~= "ElvUI_Config" then return end

	KUF:UnregisterEvent(event)
end

function KUF:Initialize()
	if E.private.unitframe.enable ~= true then return end

	self:InitPlayer()
	self:InitTarget()
	self:InitPet()
	
	self:ChangePowerBarTexture()
	self:ChangeHealthBarTexture()
	
	hooksecurefunc(UF, "Configure_ReadyCheckIcon", KUF.Configure_ReadyCheckIcon)
	hooksecurefunc(UF, "Configure_RaidIcon", KUF.Configure_RaidIcon)
	self:RegisterEvent("ADDON_LOADED")
end

local function InitializeCallback()
	KUF:Initialize()
end

KUI:RegisterModule(KUF:GetName(), InitializeCallback)