--All credits belong to Merathilis for this changelog window, not taking any credits myself whatsoever.
local KUI, E, L, V, P, G = unpack(select(2, ...))
local S = E:GetModule("Skins")

-- Cache global variables
-- Lua functions
local format, gmatch, gsub, find, sub = string.format, string.gmatch, string.gsub, string.find, string.sub
local tinsert = table.insert
local pairs, tostring = pairs, tostring
-- WoW API / Variables
local CreateFrame = CreateFrame
local SOUNDKIT = SOUNDKIT
local PlaySound = PlaySound
local CLOSE = CLOSE

-- Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: KUIDataDB, UISpecialFrames, KlixUIChangeLog, DISABLED_FONT_COLOR

local ChangeLogData = {
	"Changes:",
		"• Added Scrap Button and some option to auto pull items from bags.",
		"• Added Masque support, for my Masque_KlixUI skin.",
		"• Added an option to change the rested xp color of the databar.",
		"• Added auto gossip feature for the ships, so the workorder start instant.",
		"• Added styling support for simulationcraft addon.",
		"• Added pixel glow border to missing raidbuffs.",
		"• Added an option to change the fonts of the category and statspane in the armory.",
		"• Added seal currency check for the auto pilot feature.",
		"• Updated Talent profile module to work on PvP talents aswell.",
		"• Fixed some errors with different modules.",
		"• Skin updates and fixes.",
		-- "• ",
		
	"Notes:",
		--"• 'PlEASE DELETE THE OLD KLIXUI FOLDER BEFORE EXTRACTING THE NEW ONE'",
		--"• 'Typing /kui will navigate you to the KlixUI configurations.'",
		-- "• ",
}

local function ModifiedString(string)
	local count = find(string, ":")
	local newString = string

	if count then
		local prefix = sub(string, 0, count)
		local suffix = sub(string, count + 1)
		local subHeader = find(string, "•")

		if subHeader then newString = tostring("|cFFFFFF00".. prefix .. "|r" .. suffix) else newString = tostring("|cfff960d9" .. prefix .. "|r" .. suffix) end
	end

	for pattern in gmatch(string, "('.*')") do newString = newString:gsub(pattern, "|cFFFF8800" .. pattern:gsub("'", "") .. "|r") end
	return newString
end

local function GetChangeLogInfo(i)
	for line, info in pairs(ChangeLogData) do
		if line == i then return info end
	end
end

function KUI:CreateChangelog()
	local frame = CreateFrame("Frame", "KlixUIChangeLog", E.UIParent)
	frame:SetPoint("CENTER")
	frame:SetSize(445, 300)
	frame:SetTemplate("Transparent")
	frame:Styling()
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetClampedToScreen(true)

	local icon = CreateFrame("Frame", nil, frame)
	icon:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 3)
	icon:SetSize(20, 20)
	icon:SetTemplate("Transparent")
	icon:Styling()
	icon.bg = icon:CreateTexture(nil, "ARTWORK")
	icon.bg:Point("TOPLEFT", 2, -2)
	icon.bg:Point("BOTTOMRIGHT", -2, 2)
	icon.bg:SetTexture(KUI.Logo)
	icon.bg:SetBlendMode("ADD")
	
	local title = CreateFrame("Frame", nil, frame)
	title:SetPoint("LEFT", icon, "RIGHT", 3, 0)
	title:SetSize(422, 20)
	title:SetTemplate("Transparent")
	title:Styling()
	title.text = title:CreateFontString(nil, "OVERLAY")
	title.text:SetPoint("CENTER", title, 0, -1)
	title.text:SetFont(E["media"].normFont, 15)
	title.text:SetText("|cfff960d9KlixUI|r - ChangeLog " .. KUI.Version)

	local close = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	close:Point("BOTTOM", frame, "BOTTOM", 0, 10)
	close:SetText(CLOSE)
	close:SetSize(80, 20)
	close:SetScript("OnClick", function() frame:Hide() end)
	S:HandleButton(close)
	close:Disable()
	frame.close = close

	local countdown = KUI:CreateText(close, "OVERLAY", 12, nil, "CENTER")
	countdown:SetPoint("LEFT", close.Text, "RIGHT", 3, 0)
	countdown:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
	frame.countdown = countdown

	local offset = 4
	for i = 1, #ChangeLogData do
		local button = CreateFrame("Frame", "Button"..i, frame)
		button:SetSize(375, 16)
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -offset)

		if i <= #ChangeLogData then
			local string = ModifiedString(GetChangeLogInfo(i))

			button.Text = button:CreateFontString(nil, "OVERLAY")
			button.Text:SetFont(E["media"].normFont, 11)
			button.Text:SetText(string)
			button.Text:SetPoint("LEFT", 0, 0)
		end
		offset = offset + 16
	end
end

function KUI:CountDown()
	self.time = self.time - 1
	if self.time == 0 then
		KlixUIChangeLog.countdown:SetText("")
		KlixUIChangeLog.close:Enable()
		self:CancelAllTimers()
	else
		KlixUIChangeLog.countdown:SetText(format("(%s)", self.time))
	end
end

function KUI:ToggleChangeLog()
	if not KlixUIChangeLog then
		self:CreateChangelog()
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF or 857)
	
	local fadeInfo = {}
	fadeInfo.mode = "IN"
	fadeInfo.timeToFade = 0.5
	fadeInfo.startAlpha = 0
	fadeInfo.endAlpha = 1
	E:UIFrameFade(KlixUIChangeLog, fadeInfo)
	
	self.time = 6
	self:CancelAllTimers()
	KUI:CountDown()
	self:ScheduleRepeatingTimer("CountDown", 1)
end

function KUI:CheckVersion(self)
	-- Don't show the frame if my install isn't finished
	--if E.db.KlixUI.installed == nil then return; end
	if not KUIDataDB["Version"] or (KUIDataDB["Version"] and KUIDataDB["Version"] ~= KUI.Version) then
		KUIDataDB["Version"] = KUI.Version
		KUI:ToggleChangeLog()
	end
end