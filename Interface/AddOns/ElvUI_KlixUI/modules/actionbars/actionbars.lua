local KUI, E, L, V, P, G = unpack(select(2, ...))
local KAB = KUI:NewModule('KUIActionbars', 'AceEvent-3.0', "AceHook-3.0")
local LCG = LibStub('LibCustomGlow-1.0')
KAB.modName = L["ActionBars"]

if E.private.actionbar.enable ~= true then return; end

local _G = _G
local pairs = pairs
local IsAddOnLoaded = IsAddOnLoaded
local C_TimerAfter = C_Timer.After

-- GLOBALS: NUM_PET_ACTION_SLOTS, DisableAddOn
-- GLOBALS: ElvUI_BarPet, ElvUI_StanceBar

local classColor = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
local availableActionbars = availableActionbars or 6

local styleOtherBacks = {ElvUI_BarPet, ElvUI_StanceBar}

local function CheckExtraAB()
	if IsAddOnLoaded('ElvUI_ExtraActionBars') then
		availableActionbars = 10
	else
		availableActionbars = 6
	end
end

local r, g, b = 0, 0, 0

-- from ElvUI_TrasparentBackdrops plugin
function KAB:TransparentBackdrops()
	-- Actionbar backdrops
	local db = E.db.KlixUI.actionbars
	for i = 1, availableActionbars do
		local transBars = {_G['ElvUI_Bar'..i]}
		for _, frame in pairs(transBars) do
			if frame.backdrop then
				if db.transparent then
					frame.backdrop:SetTemplate('Transparent')
				else
					frame.backdrop:SetTemplate('Default')
				end
			end
		end

		-- Buttons
		for k = 1, 12 do
			local buttonBars = {_G["ElvUI_Bar"..i.."Button"..k]}
			for _, button in pairs(buttonBars) do
				if button.backdrop then
					button.backdrop:Styling()
					if db.transparent then
						button.backdrop:SetTemplate("Transparent")
					else
						button.backdrop:SetTemplate("Default", true)
					end
				end
			end
		end
	end

	-- Other bar backdrops
	for _, frame in pairs(styleOtherBacks) do
		if frame.backdrop then
			if db.transparent then
				frame.backdrop:SetTemplate('Transparent')
			else
				frame.backdrop:SetTemplate('Default')
			end
		end
	end

	-- Pet Buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		local petButtons = {_G['PetActionButton'..i]}
		for _, button in pairs(petButtons) do
			if button.backdrop then
				if db.transparent then
					button.backdrop:SetTemplate('Transparent')
				else
					button.backdrop:SetTemplate('Default', true)
				end
			end
		end
	end
end

function KAB:StyleBackdrops()
	-- Actionbar backdrops
	for i = 1, availableActionbars do
		local styleBacks = {_G['ElvUI_Bar'..i]}
		for _, frame in pairs(styleBacks) do
			if frame.backdrop then
				frame.backdrop:Styling()
			end
		end
	end

	-- Other bar backdrops
	for _, frame in pairs(styleOtherBacks) do
		if frame.backdrop then
			frame.backdrop:Styling()
		end
	end
	
	-- Pet Buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		local petButtons = {_G['PetActionButton'..i]}
		for _, button in pairs(petButtons) do
			if button.backdrop then
				button.backdrop:Styling()
			end
		end
	end
end

-- Code taken from CleanBossButton, thanks Blazeflack.
local function RemoveTexture(self, texture, stopLoop)
	if not E.db.KlixUI.actionbars.cleanButton then return end
	if stopLoop then return end

	self:SetTexture("", true) --2nd argument is to stop endless loop
end

function KAB:AzeriteGlow()
	if not E.db.KlixUI.actionbars.glow.enable or IsAddOnLoaded("CoolGlow") then return end
	C_Timer.After(0,function()
		if LibStub then
			local lib = LibStub:GetLibrary("LibButtonGlow-1.0",4)
			if lib then
				function lib.ShowOverlayGlow(button)
					if button:GetAttribute("type") == "action" then
						local actionType,actionID = GetActionInfo(button:GetAttribute("action"))
						local color = {E.db.KlixUI.actionbars.glow.color.r, E.db.KlixUI.actionbars.glow.color.g, E.db.KlixUI.actionbars.glow.color.b, E.db.KlixUI.actionbars.glow.color.a or 1}
						LCG.PixelGlow_Start(button, color, E.db.KlixUI.actionbars.glow.number, E.db.KlixUI.actionbars.glow.frequency, E.db.KlixUI.actionbars.glow.lenght, E.db.KlixUI.actionbars.glow.thickness, E.db.KlixUI.actionbars.glow.xOffset, E.db.KlixUI.actionbars.glow.yOffset, nil)
					end
					function lib.HideOverlayGlow(button)
						LCG.PixelGlow_Stop(button)
					end
				end
			end
		end
	end)
end

function KAB:Initialize()
	CheckExtraAB()
	C_TimerAfter(1, KAB.StyleBackdrops)
	C_TimerAfter(1, KAB.TransparentBackdrops)
	if IsAddOnLoaded('ElvUI_TB') then DisableAddOn('ElvUI_TB') end
	
	hooksecurefunc(_G["ZoneAbilityFrame"].SpellButton.Style, "SetTexture", RemoveTexture)
	hooksecurefunc(_G["ExtraActionButton1"].style, "SetTexture", RemoveTexture)
	
	KAB:AzeriteGlow()
end

local function InitializeCallback()
	KAB:Initialize()
end

KUI:RegisterModule(KAB:GetName(), InitializeCallback)