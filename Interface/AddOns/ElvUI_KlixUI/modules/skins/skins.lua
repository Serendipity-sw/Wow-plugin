local KUI, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:NewModule("KuiSkins", "AceHook-3.0", "AceEvent-3.0")
local S = E:GetModule("Skins")
local LSM = LibStub("LibSharedMedia-3.0")
KS.modName = L["Skins & AddOns"]

-- Credits: Mertahilis, give that man a cookie!

-- Cache global variables
-- Lua functions
local _G = _G
local assert, pairs, select, unpack, type = assert, pairs, select, unpack, type
local find, lower = string.find, string.lower
-- WoW API / Variables
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local hooksecurefunc = hooksecurefunc
--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: AddOnSkins, stripes

local flat = [[Interface\AddOns\ElvUI_KlixUI\media\textures\Klix]]
local alpha
local backdropcolorr, backdropcolorg, backdropcolorb
local backdropfadecolorr, backdropfadecolorg, backdropfadecolorb
local unitFrameColorR, unitFrameColorG, unitFrameColorB
local rgbValueColorR, rgbValueColorG, rgbValueColorB
local bordercolorr, bordercolorg, bordercolorb

local r, g, b = unpack(E["media"].rgbvaluecolor)

local buttons = {
	"UI-Panel-MinimizeButton-Disabled",
	"UI-Panel-MinimizeButton-Up",
	"UI-Panel-SmallerButton-Up",
	"UI-Panel-BiggerButton-Up",
}

KS.ArrowRotation = {
	['UP'] = 3.14,
	['DOWN'] = 0,
	['LEFT'] = -1.57,
	['RIGHT'] = 1.57,
}

KS.BlizzardRegions = {
	'Left',
	'Middle',
	'Right',
	'Mid',
	'LeftDisabled',
	'MiddleDisabled',
	'RightDisabled',
	'TopLeft',
	'TopRight',
	'BottomLeft',
	'BottomRight',
	'TopMiddle',
	'MiddleLeft',
	'MiddleRight',
	'BottomMiddle',
	'MiddleMiddle',
	'TabSpacer',
	'TabSpacer1',
	'TabSpacer2',
	'_RightSeparator',
	'_LeftSeparator',
	'Cover',
	'Border',
	'Background',
}

function S:HandleCloseButton(f, point, text)
if not E.private.KlixUI.skins.closeButton then return end
	assert(f, "does not exist.")

	f:StripTextures()

	-- Create backdrop for the few close buttons that do not use original close button
	if not f.backdrop then
		f:CreateBackdrop()
		f.backdrop:Point("TOPLEFT", 7, -8)
		f.backdrop:Point("BOTTOMRIGHT", -8, 8)
		f.backdrop:SetTemplate("NoBackdrop")
		f:SetHitRectInsets(6, 6, 7, 7)
	end

	-- Create an own close button texture on the backdrop
	if not f.backdrop.img then
		f.backdrop.img = f.backdrop:CreateTexture(nil, "OVERLAY")
		f.backdrop.img:SetSize(12, 12)
		f.backdrop.img:Point("CENTER")
		f.backdrop.img:SetTexture("Interface\\AddOns\\ElvUI\\media\\textures\\close.tga")
		f.backdrop.img:SetVertexColor(1, 1, 1)
	end

	-- ElvUI code expects the element to be there. It won't show up for original close buttons.
	if not f.text then
		f.text = f:CreateFontString(nil, "OVERLAY")
		f.text:SetFont([[Interface\AddOns\ElvUI\media\fonts\PT_Sans_Narrow.ttf]], 16, 'OUTLINE')
		f.text:SetText(text)
		f.text:SetJustifyH("CENTER")
		f.text:Point("CENTER", f, "CENTER")
	end

	-- Otherwise we have an additional white texture
	f:SetPushedTexture("")

	f:HookScript("OnEnter", function(self)
		self.backdrop.img:SetVertexColor(unpack(E["media"].rgbvaluecolor))
		self.backdrop:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor))
	end)

	f:HookScript("OnLeave", function(self)
		self.backdrop.img:SetVertexColor(1, 1, 1)
		self.backdrop:SetBackdropBorderColor(unpack(E["media"].bordercolor))
	end)

	-- Hide text if button is using original skin
	if f.text and f.noBackdrop then
		f.text:SetAlpha(0)
	end

	if point then
		f:Point("TOPRIGHT", point, "TOPRIGHT", 2, 2)
	end
end

function KS:ReskinMaxMinFrame(frame)
	assert(frame, "does not exist.")

	frame:StripTextures()

	for name, direction in pairs ({ ["MaximizeButton"] = 'UP', ["MinimizeButton"] = 'DOWN'}) do
		local button = frame[name]

		if button then
			local normal = button:GetNormalTexture()

			button:SetSize(18, 18)
			button:ClearAllPoints()
			button:SetPoint("CENTER")
			button:SetHitRectInsets(1, 1, 1, 1)

			button:SetNormalTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\arrow")
			button:GetNormalTexture():SetRotation(KS.ArrowRotation[direction])
			button:GetNormalTexture():SetInside(button, 2, 2)

			button:SetPushedTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\arrow")
			button:GetPushedTexture():SetRotation(KS.ArrowRotation[direction])
			button:GetPushedTexture():SetInside(button)

			button:SetTemplate("NoBackdrop")

			button:HookScript('OnEnter', function(self) self:SetBackdropBorderColor(unpack(E["media"].rgbvaluecolor)) normal:SetVertexColor(unpack(E["media"].rgbvaluecolor)) end)
			button:HookScript('OnLeave', function(self) self:SetBackdropBorderColor(unpack(E["media"].bordercolor)) normal:SetVertexColor(1, 1, 1) end)
			
			KS:Reskin(button, false, false)
		end
	end
end

function KS:ReskinEditBox(frame)
	-- Hide ElvUI's backdrop
	if frame.backdrop then
		frame.backdrop:Hide()
	end

	-- Reaply transparent backdrop
	frame:CreateBackdrop("Transparent")
	KS:CreateGradient(frame.backdrop)
end

function KS:ReskinDropDownBox(frame, width)
	local button = _G[frame:GetName().."Button"]
	if not button then return end

	if not width then width = 155 end

	-- Hide ElvUI's backdrop
	if frame.backdrop then
		frame.backdrop:Hide()
	end

	if not frame.bg then
		local bg = KS:CreateBDFrame(frame)
		bg:Point("TOPLEFT", 20, -2)
		bg:Point("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
		bg:Width(width)
		bg:SetFrameLevel(frame:GetFrameLevel())
		KS:CreateGradient(bg)

		frame.bg = bg
	end
end

function S:HandleDropDownFrame(frame, width)
	if not width then width = 155 end

	local left = frame.Left
	local middle = frame.Middle
	local right = frame.Right
	if left then
		left:SetAlpha(0)
		left:SetSize(25, 64)
		left:SetPoint("TOPLEFT", 0, 17)
	end
	if middle then
		middle:SetAlpha(0)
		middle:SetHeight(64)
	end
	if right then
		right:SetAlpha(0)
		right:SetSize(25, 64)
	end

	local button = frame.Button
	if button then
		button:SetSize(24, 24)
		button:ClearAllPoints()
		button:Point("RIGHT", right, "RIGHT", -20, 1)

		button.NormalTexture:SetTexture("")
		button.PushedTexture:SetTexture("")
		button.HighlightTexture:SetTexture("")

		hooksecurefunc(button, "SetPoint", function(btn, _, _, _, _, _, noReset)
			if not noReset then
				btn:ClearAllPoints()
				btn:SetPoint("RIGHT", frame, "RIGHT", E:Scale(-20), E:Scale(1), true)
			end
		end)

		self:HandleNextPrevButton(button, true)
	end

	local disabled = button and button.DisabledTexture
	if disabled then
		disabled:SetAllPoints(button)
		disabled:SetColorTexture(0, 0, 0, .3)
		disabled:SetDrawLayer("OVERLAY")
	end

	if middle and (not frame.noResize) then
		frame:SetWidth(40)
		middle:SetWidth(width)
	end

	if right and frame.Text then
		frame.Text:SetSize(0, 10)
		frame.Text:SetPoint("RIGHT", right, -43, 2)
	end

	-- Hide ElvUI's backdrop
	if frame.backdrop then
		frame.backdrop:Hide()
	end

	if not frame.bg then
		local bg = KS:CreateBDFrame(frame)
		bg:SetPoint("TOPLEFT", left, 20, -21)
		bg:SetPoint("BOTTOMRIGHT", right, -19, 23)
		bg:SetFrameLevel(frame:GetFrameLevel())
		bg:Width(width)
		KS:CreateGradient(bg)

		frame.bg = bg
	end
end

-- External CloseButtons
function KS:ReskinClose(f, a1, p, a2, x, y)
	assert(f, "doesn't exist!")
	f:Size(17, 17)

	if not a1 then
		f:Point("TOPRIGHT", -4, -4)
	else
		f:ClearAllPoints()
		f:Point(a1, p, a2, x, y)
	end

	f:SetNormalTexture("")
	f:SetHighlightTexture("")
	f:SetPushedTexture("")
	f:SetDisabledTexture("")

	KS:CreateBD(f, 0)
	KS:CreateBackdropTexture(f)

	f:SetDisabledTexture(E["media"].normTex)
	local dis = f:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .4)
	dis:SetDrawLayer("OVERLAY")
	dis:SetAllPoints()

	local icon = f:CreateFontString(nil, "OVERLAY")
	icon:Point("CENTER", 2, 0)
	icon:FontTemplate(nil, 12, "OUTLINE")
	icon:SetText("X")

	f:HookScript("OnEnter", function() icon:SetTextColor(r, g, b) end)
	f:HookScript("OnLeave", function() icon:SetTextColor(1, 1, 1) end)
end

-- Underlines
function KS:Underline(frame, shadow, height)
	local line = CreateFrame("Frame", nil, frame)
	if line then
		line:SetPoint("BOTTOM", frame, -1, 1)
		line:SetSize(frame:GetWidth(), height or 1)
		line.Texture = line:CreateTexture(nil, "OVERLAY")
		line.Texture:SetTexture(flat)
		line.Texture:SetVertexColor(r, g, b)
		if shadow then
			if shadow == "backdrop" then
				line:CreateShadow()
			else
				line:CreateBackdrop()
			end
		end
		line.Texture:SetAllPoints(line)
	end
	return line
end

-- Create shadow for textures
function KS:CreateSD(parent, size, r, g, b, alpha, offset)
	local sd = CreateFrame("Frame", nil, parent)
	sd.size = size or 5
	sd.offset = offset or 0
	sd:SetBackdrop({
		bgFile =  E.LSM:Fetch("background", "ElvUI Blank"),
		edgeFile = E.LSM:Fetch("border", "ElvUI GlowBorder"),
		edgeSize = sd.size,
	})
	sd:SetPoint("TOPLEFT", parent, -sd.size - 1 - sd.offset, sd.size + 1 + sd.offset)
	sd:SetPoint("BOTTOMRIGHT", parent, sd.size + 1 + sd.offset, -sd.size - 1 - sd.offset)
	sd:SetBackdropBorderColor(r or 0, g or 0, b or 0)
	sd:SetBackdropColor(r or 0, g or 0, b or 0, alpha or 0)

	return sd
end

function KS:CreateBG(frame)
	assert(frame, "doesn't exist!")
	local f = frame
	if frame:GetObjectType() == "Texture" then f = frame:GetParent() end

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:Point("TOPLEFT", frame, -1, 1)
	bg:Point("BOTTOMRIGHT", frame, 1, -1)
	bg:SetTexture(E["media"].blankTex)
	bg:SetVertexColor(0, 0, 0)

	return bg
end

-- frame text
function KS:CreateFS(f, size, text, classcolor, anchor, x, y)
	local fs = f:CreateFontString(nil, "OVERLAY")
	fs:FontTemplate(nil, nil, 'OUTLINE')
	fs:SetText(text)
	fs:SetWordWrap(false)
	if classcolor then
		fs:SetTextColor(r, g, b)
	end
	if (anchor and x and y) then
		fs:SetPoint(anchor, x, y)
	else
		fs:SetPoint("CENTER", 1, 0)
	end
	return fs
end

-- Gradient Frame
function KS:CreateGF(f, w, h, o, r, g, b, a1, a2)
	assert(f, "doesn't exist!")
	f:SetSize(w, h)
	f:SetFrameStrata("BACKGROUND")
	local gf = f:CreateTexture(nil, "BACKGROUND")
	gf:SetPoint("TOPLEFT", f, -1, 1)
	gf:SetPoint("BOTTOMRIGHT", f, 1, -1)
	gf:SetTexture(E['media'].Klix)
	gf:SetVertexColor(r, g, b)
	gf:SetGradientAlpha(o, r, g, b, a1, r, g, b, a2)
end

-- Gradient Texture
function KS:CreateGradient(f)
	assert(f, "doesn't exist!")
	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT", 1, -1)
	tex:SetPoint("BOTTOMRIGHT", -1, 1)
	tex:SetTexture([[Interface\AddOns\ElvUI_KlixUI\media\textures\gradient.tga]])
	tex:SetVertexColor(.3, .3, .3, .15)

	return tex
end

function KS:CreateBackdrop(frame)
	if frame.backdrop then return end

	local parent = frame.IsObjectType and frame:IsObjectType("Texture") and frame:GetParent() or frame

	local backdrop = CreateFrame("Frame", nil, parent)
	backdrop:SetOutside(frame)
	backdrop:SetTemplate("Transparent")

	if (parent:GetFrameLevel() - 1) >= 0 then
		backdrop:SetFrameLevel(parent:GetFrameLevel() - 1)
	else
		backdrop:SetFrameLevel(0)
	end

	frame.backdrop = backdrop
end

function KS:CreateBDFrame(f, a, left, right, top, bottom)
	assert(f, "doesn't exist!")
	local frame
	if f:GetObjectType() == "Texture" then
		frame = f:GetParent()
	else
		frame = f
	end

	local lvl = frame:GetFrameLevel()

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetPoint("TOPLEFT", f, left or -1, top or 1)
	bg:SetPoint("BOTTOMRIGHT", f, right or 1, bottom or -1)
	bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)

	KS:CreateBD(bg, a or .5)

	return bg
end

function KS:CreateBD(f, a)
	assert(f, "doesn't exist!")

	f:SetBackdrop({
		bgFile = E["media"].normTex,
		edgeFile = E["media"].normTex,
		edgeSize = E.mult,
	})

	f:SetBackdropColor(backdropfadecolorr, backdropfadecolorg, backdropfadecolorb, a or alpha)
	f:SetBackdropBorderColor(bordercolorr, bordercolorg, bordercolorb)
end

function S:HandleNextPrevButton(btn, useVertical, inverseDirection)
	inverseDirection = inverseDirection or btn:GetName() and (find(btn:GetName():lower(), 'left') or find(btn:GetName():lower(), 'prev') or find(btn:GetName():lower(), 'decrement') or find(btn:GetName():lower(), 'back'))

	btn:StripTextures()

	if not btn.img then
		btn.img = btn:CreateTexture(nil, 'ARTWORK')
		btn.img:SetTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\arrow")
		btn.img:SetSize(12, 12)
		btn.img:Point('CENTER')
		btn.img:SetVertexColor(1, 1, 1)

		btn:SetNormalTexture(E["media"].normTex)
		btn:SetPushedTexture(E["media"].normTex)
		btn:SetDisabledTexture(E["media"].normTex)
		
		btn:HookScript('OnMouseDown', function(btn)
			if btn:IsEnabled() then
				btn.img:Point("CENTER", -1, -1)
				btn.img:SetVertexColor(r, g, b)
			end
		end)

		btn:HookScript('OnMouseUp', function(btn)
			btn.img:Point("CENTER", 0, 0)
			btn.img:SetVertexColor(1, 1, 1)
		end)

		btn:HookScript('OnDisable', function(btn)
			SetDesaturation(btn.img, true)
			btn.img:SetAlpha(0.3)
		end)

		btn:HookScript('OnEnable', function(btn)
			SetDesaturation(btn.img, false)
			btn.img:SetAlpha(1.0)
		end)

		if not btn:IsEnabled() then
			btn:GetScript('OnDisable')(btn)
		end
	end

	if useVertical then
		if inverseDirection then
			btn.img:SetRotation(KS.ArrowRotation['UP'])
		else
			btn.img:SetRotation(KS.ArrowRotation['DOWN'])
		end
	else
		if inverseDirection then
			btn.img:SetRotation(KS.ArrowRotation['LEFT'])
		else
			btn.img:SetRotation(KS.ArrowRotation['RIGHT'])
		end
	end

	S:HandleButton(btn)
	btn:Size(btn:GetWidth() - 7, btn:GetHeight() - 7)
end

function KS:SetBD(x, y, x2, y2)
	local bg = CreateFrame("Frame", nil, self)
	if not x then
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT")
	else
		bg:SetPoint("TOPLEFT", x, y)
		bg:SetPoint("BOTTOMRIGHT", x2, y2)
	end
	bg:SetFrameLevel(self:GetFrameLevel() - 1)
	KS:CreateBD(bg)
	KS:CreateSD(bg)
end

function KS:SkinBackdropFrame(frame, template, override, kill, setpoints)
	if not override then KS:StripTextures(frame, kill) end
	KS:CreateBackdrop(frame, template)
	if setpoints then
		frame.Backdrop:SetAllPoints()
	end
end

function KS:StripTextures(Object, Kill, Alpha)
	for i = 1, Object:GetNumRegions() do
		local Region = select(i, Object:GetRegions())
		if Region and Region:GetObjectType() == "Texture" then
			if Kill then
				Region:Hide()
				Region.Show = KUI.dummy
			elseif Alpha then
				Region:SetAlpha(0)
			else
				Region:SetTexture(nil)
			end
		end
	end
end

-- ClassColored ScrollBars
function KS:ReskinScrollBar(frame, thumbTrim)
	if frame:GetName() then
		if frame.trackbg and frame.trackbg.SetTemplate then
			frame.trackbg:SetTemplate("Transparent", true, true)
		end

		if _G[frame:GetName().."ScrollUpButton"] and _G[frame:GetName().."ScrollDownButton"] then
			if frame.thumbbg and frame.thumbbg.backdropTexture then
				frame.thumbbg.backdropTexture.SetVertexColor = nil
				frame.thumbbg.backdropTexture:SetVertexColor(rgbValueColorR, rgbValueColorG, rgbValueColorB)
				frame.thumbbg.backdropTexture.SetVertexColor = E.noop
			end
		end
	else
		if frame.trackbg and frame.trackbg.SetTemplate then
			frame.trackbg:SetTemplate("Transparent", true, true)
		end

		if frame.ScrollUpButton and frame.ScrollDownButton then
			if frame.thumbbg and frame.thumbbg.backdropTexture then
				frame.thumbbg.backdropTexture.SetVertexColor = nil
				frame.thumbbg.backdropTexture:SetVertexColor(rgbValueColorR, rgbValueColorG, rgbValueColorB)
				frame.thumbbg.backdropTexture.SetVertexColor = E.noop
			end
		end
	end
end

function KS:ReskinScrollSlider(Slider, thumbTrim)
	local parent = Slider:GetParent()
	
	if Slider.trackbg and Slider.trackbg.SetTemplate then
		Slider.trackbg:SetTemplate("Transparent", true, true)
	end
	
	if Slider.thumbbg then
		Slider.thumbbg.backdropTexture.SetVertexColor = nil
		Slider.thumbbg.backdropTexture:SetVertexColor(rgbValueColorR, rgbValueColorG, rgbValueColorB)
		Slider.thumbbg.backdropTexture.SetVertexColor = E.noop
	end
end

-- Overwrite ElvUI Tabs function to be transparent
function KS:ReskinTab(tab)
	if not tab then return end

	if tab.backdrop then
		tab.backdrop:SetTemplate("Transparent")
		tab.backdrop:Styling()
	end
end

function KS:CreateBackdropTexture(f)
	assert(f, "doesn't exist!")
	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:SetDrawLayer("BACKGROUND", 1)
	tex:SetInside(f, 1, 1)
	tex:SetTexture(E["media"].normTex)
	tex:SetVertexColor(backdropcolorr, backdropcolorg, backdropcolorb)
	tex:SetAlpha(0.8)
	f.backdropTexture = tex
end

function KS:ColorButton()
	if self.backdrop then self = self.backdrop end

	self:SetBackdropColor(r, g, b, .3)
	self:SetBackdropBorderColor(r, g, b)
end

function KS:ClearButton()
	if self.backdrop then self = self.backdrop end

	self:SetBackdropColor(0, 0, 0, 0)

	if self.isUnitFrameElement then
		self:SetBackdropBorderColor(unitFrameColorR, unitFrameColorG, unitFrameColorB)
	else
		self:SetBackdropBorderColor(bordercolorr, bordercolorg, bordercolorb)
	end
end

function KS:SkinFrame(frame, template, override, kill)
	if not template then template = "Transparent" end
	if not override then KS:StripTextures(frame, kill) end
	KS:SetTemplate(frame, template)
end

local function StartGlow(f)
	if not f:IsEnabled() then return end
	f:SetBackdropBorderColor(r, g ,b)
	f.glow:SetAlpha(1)
	KUI:CreatePulse(f.glow)
end

local function StopGlow(f)
	f.glow:SetScript("OnUpdate", nil)
	f:SetBackdropBorderColor(bordercolorr, bordercolorg, bordercolorb)
	f.glow:SetAlpha(0)
end

-- Buttons
function KS:Reskin(button, strip, noGlow)
	assert(button, "doesn't exist!")

	if strip then button:StripTextures() end

	if button.template then
		button:SetTemplate("Transparent", true)
	end

	KS:CreateGradient(button)
	
	if button.Icon then
		local Texture = button.Icon:GetTexture()
		if Texture and strfind(Texture, [[Interface\ChatFrame\ChatFrameExpandArrow]]) then
			button.Icon:SetTexture([[Interface\AddOns\ElvUI_KlixUI\media\textures\Arrow]])
			button.Icon:SetVertexColor(1, 1, 1)
			button.Icon:SetRotation(KS.ArrowRotation['RIGHT'])
		end
	end
	
	if not noGlow then
		button.glow = CreateFrame("Frame", nil, button)
		button.glow:SetBackdrop({
			edgeFile = E.LSM:Fetch("statusbar", "Klix"), edgeSize = E:Scale(2),
			insets = {left = E:Scale(2), right = E:Scale(2), top = E:Scale(2), bottom = E:Scale(2)},
		})
		button.glow:SetPoint("TOPLEFT", -1, 1)
		button.glow:SetPoint("BOTTOMRIGHT", 1, -1)
		button.glow:SetBackdropBorderColor(r, g, b)
		button.glow:SetAlpha(0)

		button:HookScript("OnEnter", StartGlow)
		button:HookScript("OnLeave", StopGlow)
	end
end

function KS:ReskinCheckBox(frame, noBackdrop, noReplaceTextures)
	assert(frame, "does not exist.")

	frame:StripTextures()

	if noBackdrop then
		frame:SetTemplate("Default")
		frame:Size(16)
	else
		KS:CreateBackdrop(frame)
		frame.backdrop:SetInside(nil, 4, 4)
	end

	if not noReplaceTextures then
		if frame.SetCheckedTexture then
			frame:SetCheckedTexture(E.LSM:Fetch("statusbar", "Klix"))
			frame:GetCheckedTexture():SetVertexColor(r, g, b)
			frame:GetCheckedTexture():SetInside(frame.backdrop)
		end

		if frame.SetDisabledTexture then
			frame:SetDisabledTexture(E.LSM:Fetch("statusbar", "Klix"))
			frame:GetDisabledTexture():SetVertexColor(r, g, b, 0.5)
			frame:GetDisabledTexture():SetInside(frame.backdrop)
		end

		frame:HookScript('OnDisable', function(checkbox)
			if not checkbox.SetDisabledTexture then return; end
			if checkbox:GetChecked() then
				checkbox:SetDisabledTexture(E.LSM:Fetch("statusbar", "Klix"))
				checkbox:GetDisabledTexture():SetVertexColor(r, g, b, 0.5)
				checkbox:GetDisabledTexture():SetInside(frame.backdrop)
			else
				checkbox:SetDisabledTexture("")
			end
		end)
	end
end

function KS:StyleButton(button)
	if button.isStyled then return end

	if button.SetHighlightTexture then
		button:SetHighlightTexture(E["media"].blankTex)
		button:GetHighlightTexture():SetVertexColor(1, 1, 1, .2)
		button:GetHighlightTexture():SetInside()
		button.SetHighlightTexture = E.noop
	end

	if button.SetPushedTexture then
		button:SetPushedTexture(E["media"].blankTex)
		button:GetPushedTexture():SetVertexColor(.9, .8, .1, .5)
		button:GetPushedTexture():SetInside()
		button.SetPushedTexture = E.noop
	end

	if button.GetCheckedTexture then
		button:SetPushedTexture(E["media"].blankTex)
		button:GetCheckedTexture():SetVertexColor(0, 1, 0, .5)
		button:GetCheckedTexture():SetInside()
		button.GetCheckedTexture = E.noop
	end

	local Cooldown = button:GetName() and _G[button:GetName()..'Cooldown'] or button.Cooldown or button.cooldown or nil

	if Cooldown then
		Cooldown:SetInside()
		if Cooldown.SetSwipeColor then
			Cooldown:SetSwipeColor(0, 0, 0, 1)
		end
	end

	button.isStyled = true
end

function KS:ReskinIcon(icon, backdrop)
	assert(icon, "doesn't exist!")

	icon:SetTexCoord(unpack(E.TexCoords))
	if backdrop then
		KS:CreateBackdrop(icon)
	end
end

function KS:ReskinItemFrame(frame)
	assert(frame, "doesn't exist!")

	local icon = frame.Icon
	frame._KuiIconBorder = KS:ReskinIcon(icon)

	local nameFrame = frame.NameFrame
	nameFrame:SetAlpha(0)

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetPoint("TOP", icon, 0, 1)
	bg:SetPoint("BOTTOM", icon, 0, -1)
	bg:SetPoint("LEFT", icon, "RIGHT", 2, 0)
	bg:SetPoint("RIGHT", nameFrame, -4, 0)
	KS:CreateBD(bg, .2)
	frame._KuiNameBG = bg
end

function KS:ItemButtonTemplate(button)
	assert(button, "doesn't exist!")

	button:SetNormalTexture("")
	button:SetHighlightTexture("")
	button:SetPushedTexture("")
	button._KuiIconBorder = KS:ReskinIcon(button.icon)
end

function KS:SimplePopupButtonTemplate(checkbutton)
	select(2, checkbutton:GetRegions()):Hide()
end

function KS:PopupButtonTemplate(checkbutton)
	KS:SimplePopupButtonTemplate(checkbutton)
end

function KS:LargeItemButtonTemplate(button)
	assert(button, "doesn't exist!")

	local iconBG = CreateFrame("Frame", nil, button)
	iconBG:SetFrameLevel(button:GetFrameLevel() - 1)
	iconBG:SetPoint("TOPLEFT", button.Icon, -1, 1)
	iconBG:SetPoint("BOTTOMRIGHT", button.Icon, 1, -1)
	button._KuiIconBorder = iconBG

	button.NameFrame:SetAlpha(0)

	local nameBG = CreateFrame("Frame", nil, button)
	nameBG:SetPoint("TOPLEFT", iconBG, "TOPRIGHT", 1, 0)
	nameBG:SetPoint("BOTTOMRIGHT", -3, 1)
	KS:CreateBD(nameBG, .2)
	button._KuiNameBG = nameBG
end

function KS:SmallItemButtonTemplate(button)
	assert(button, "doesn't exist!")

	button.Icon:SetSize(29, 29)

	local iconBG = CreateFrame("Frame", nil, button)
	iconBG:SetFrameLevel(button:GetFrameLevel() - 1)
	iconBG:SetPoint("TOPLEFT", button.Icon, -1, 1)
	iconBG:SetPoint("BOTTOMRIGHT", button.Icon, 1, -1)
	button._KuiIconBorder = iconBG

	button.NameFrame:SetAlpha(0)

	local nameBG = CreateFrame("Frame", nil, button)
	nameBG:SetPoint("TOPLEFT", iconBG, "TOPRIGHT", 1, 0)
	nameBG:SetPoint("BOTTOMRIGHT", button.NameFrame, 0, -1)
	KS:CreateBD(nameBG, .2)
	button._KuiINameBG = nameBG
end

function KS:SkinPanel(panel)
	panel.tex = panel:CreateTexture(nil, "ARTWORK")
	panel.tex:SetAllPoints()
	panel.tex:SetTexture(E.LSM:Fetch("statusbar", "Klix"))
	panel.tex:SetGradient("VERTICAL", unpack(E["media"].rgbvaluecolor))
	KS:CreateSD(panel, 2, 0, 0, 0, 0, -1)
end

function KS:ReskinGarrisonPortrait(self)
	self.Portrait:ClearAllPoints()
	self.Portrait:SetPoint("TOPLEFT", 4, -4)
	self.PortraitRing:Hide()
	self.PortraitRingQuality:SetTexture("")
	if self.Highlight then self.Highlight:Hide() end

	self.LevelBorder:SetScale(.0001)
	self.Level:ClearAllPoints()
	self.Level:SetPoint("BOTTOM", self, 0, 12)

	self.squareBG = KS:CreateBDFrame(self, 1)
	self.squareBG:SetFrameLevel(self:GetFrameLevel())
	self.squareBG:SetPoint("TOPLEFT", 3, -3)
	self.squareBG:SetPoint("BOTTOMRIGHT", -3, 11)

	if self.PortraitRingCover then
		self.PortraitRingCover:SetColorTexture(0, 0, 0)
		self.PortraitRingCover:SetAllPoints(self.squareBG)
	end

	if self.Empty then
		self.Empty:SetColorTexture(0, 0, 0)
		self.Empty:SetAllPoints(self.Portrait)
	end
end

function KS:SkinRadioButton(button)
	if button.IsSkinned then return; end

	button:SetCheckedTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\RadioCircleChecked")
	button:GetCheckedTexture():SetVertexColor(unpack(E["media"].rgbvaluecolor))
	button:GetCheckedTexture():SetTexCoord(0, 1, 0, 1)

	button:SetHighlightTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\RadioCircleChecked")
	button:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
	button:GetHighlightTexture():SetVertexColor(0, 192, 250, 1)

	button:SetNormalTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\Textures\\RadioCircle")
	button:GetNormalTexture():SetOutside()
	button:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
	button:GetNormalTexture():SetVertexColor(unpack(E["media"].bordercolor))

	button:HookScript("OnDisable", function(self)
		if not self.SetDisabledTexture then return end

		if self:GetChecked() then
			self:SetDisabledTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\Textures\\RadioCircle")
			self:GetDisabledTexture():SetVertexColor(0, 192, 250, 1)
		else
			self:SetDisabledTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\Textures\\RadioCircle")
			self:GetDisabledTexture():SetVertexColor(unpack(E["media"].bordercolor))
		end
	end)

	button.SetNormalTexture = KUI.dummy
	button.SetPushedTexture = KUI.dummy
	button.SetHighlightTexture = KUI.dummy
	button.isSkinned = true
end

local buttons = {
	"ElvUIMoverNudgeWindowUpButton",
	"ElvUIMoverNudgeWindowDownButton",
	"ElvUIMoverNudgeWindowLeftButton",
	"ElvUIMoverNudgeWindowRightButton",
}

local function replaceConfigArrows(button)
	-- remove the default icons
	local tex = _G[button:GetName().."Icon"]
	if tex then
		tex:SetTexture(nil)
	end

	-- add the new icon
	if not button.img then
		button.img = button:CreateTexture(nil, 'ARTWORK')
		button.img:SetTexture('Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\arrow')
		button.img:SetSize(12, 12)
		button.img:Point('CENTER')
		button.img:SetVertexColor(1, 1, 1)

		button:HookScript('OnMouseDown', function(btn)
			if btn:IsEnabled() then
				btn.img:Point("CENTER", -1, -1);
			end
		end)

		button:HookScript('OnMouseUp', function(btn)
			btn.img:Point("CENTER", 0, 0);
		end)
	end
end

function KS:ApplyConfigArrows()
	for _, btn in pairs(buttons) do
		replaceConfigArrows(_G[btn])
	end

	-- Apply the rotation
	_G["ElvUIMoverNudgeWindowUpButton"].img:SetRotation(KS.ArrowRotation['UP'])
	_G["ElvUIMoverNudgeWindowDownButton"].img:SetRotation(KS.ArrowRotation['DOWN'])
	_G["ElvUIMoverNudgeWindowLeftButton"].img:SetRotation(KS.ArrowRotation['LEFT'])
	_G["ElvUIMoverNudgeWindowRightButton"].img:SetRotation(KS.ArrowRotation['RIGHT'])

end
hooksecurefunc(E, "CreateMoverPopup", KS.ApplyConfigArrows)

function KS:ReskinAS(AS)
	-- Reskin AddOnSkins
	function AS:SkinTab(Tab, Strip)
		if Tab.isSkinned then return end
		local TabName = Tab:GetName()

		if TabName then
			for _, Region in pairs(KS.BlizzardRegions) do
				if _G[TabName..Region] then
					_G[TabName..Region]:SetTexture(nil)
				end
			end
		end

		for _, Region in pairs(KS.BlizzardRegions) do
			if Tab[Region] then
				Tab[Region]:SetAlpha(0)
			end
		end

		if Tab.GetHighlightTexture and Tab:GetHighlightTexture() then
			Tab:GetHighlightTexture():SetTexture(nil)
		else
			Strip = true
		end

		if Strip then
			AS:StripTextures(Tab)
		end

		AS:CreateBackdrop(Tab)

		if AS:CheckAddOn("ElvUI") and AS:CheckOption("ElvUISkinModule") then
			-- Check if ElvUI already provides the backdrop. Otherwise we have two backdrops (e.g. Auctionhouse)
			if Tab.backdrop then
				Tab.Backdrop:Hide()
			else
				AS:SetTemplate(Tab.Backdrop, "Transparent") -- Set it to transparent
				Tab.Backdrop:Styling()
			end
		end

		Tab.Backdrop:Point("TOPLEFT", 10, AS.PixelPerfect and -1 or -3)
		Tab.Backdrop:Point("BOTTOMRIGHT", -10, 3)

		Tab.isSkinned = true
	end
end

-- Replace the Recap button script re-set function
function S:UpdateRecapButton()
	if self and self.button4 and self.button4:IsEnabled() then
		self.button4:SetScript("OnEnter", KS.ColorButton)
		self.button4:SetScript("OnLeave", KS.ClearButton)
	end
end

--[[ HOOK TO THE UIWIDGET TYPES ]]
function KS:ReskinSkinTextWithStateWidget(widgetFrame)
	local text = widgetFrame.Text;
	if text then
		text:SetTextColor(1, 1, 1)
	end
end

-- hook the skin functions
hooksecurefunc(S, "HandleEditBox", KS.ReskinEditBox)
hooksecurefunc(S, "HandleDropDownBox", KS.ReskinDropDownBox)
hooksecurefunc(S, "HandleTab", KS.ReskinTab)
hooksecurefunc(S, "HandleButton", KS.Reskin)
hooksecurefunc(S, "HandleCheckBox", KS.ReskinCheckBox)
hooksecurefunc(S, "HandleScrollBar", KS.ReskinScrollBar)
hooksecurefunc(S, "HandleScrollSlider", KS.ReskinScrollSlider)
-- New Widget Types
hooksecurefunc(S, "SkinTextWithStateWidget", KS.ReskinSkinTextWithStateWidget)

local function ReskinVehicleExit()
	if not E.private.KlixUI.skins.vehicleButton then return end
	local f = _G["LeaveVehicleButton"]
	if f then
		f:SetNormalTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\arrow")
		f:SetPushedTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\arrow")
		f:SetHighlightTexture("Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\arrow")
	end
end

-- keep the colors updated
local function updateMedia()
	rgbValueColorR, rgbValueColorG, rgbValueColorB = unpack(E["media"].rgbvaluecolor)
	unitFrameColorR, unitFrameColorG, unitFrameColorB = unpack(E["media"].unitframeBorderColor)
	backdropfadecolorr, backdropfadecolorg, backdropfadecolorb, alpha = unpack(E["media"].backdropfadecolor)
	backdropcolorr, backdropcolorg, backdropcolorb = unpack(E["media"].backdropcolor)
	bordercolorr, bordercolorg, bordercolorb = unpack(E["media"].bordercolor)
end
hooksecurefunc(E, "UpdateMedia", updateMedia)



------------------ SharedXML -----------------
--[[ SharedXML\HybridScrollFrame.xml ]]
function KS:HybridScrollBarTemplate(Slider)
	local parent = Slider:GetParent()
	Slider:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, -17)
	Slider:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 0, 17)

	Slider.trackBG:SetAlpha(0)

	Slider.ScrollBarTop:Hide()
	Slider.ScrollBarMiddle:Hide()
	Slider.ScrollBarBottom:Hide()

	parent.scrollUp:SetPoint("BOTTOM", Slider, "TOP")
	KS:UIPanelScrollUpButtonTemplate(parent.scrollUp)

	parent.scrollDown:SetPoint("TOP", Slider, "BOTTOM")
	KS:UIPanelScrollDownButtonTemplate(parent.scrollDown)

	Slider.thumbTexture:SetAlpha(0)
	Slider.thumbTexture:SetSize(17, 24)

	local thumb = _G.CreateFrame("Frame", nil, Slider)
	thumb:SetPoint("TOPLEFT", Slider.thumbTexture, 0, -2)
	thumb:SetPoint("BOTTOMRIGHT", Slider.thumbTexture, 0, 2)
	Slider._KuiThumb = thumb

	Slider:SetSize(Slider:GetSize())
end

--[[ SharedXML\SecureUIPanelTemplate.xml ]]
function KS:UIPanelScrollBarButton(Button)
	Button:SetSize(17, 17)
	Button:SetNormalTexture("")
	Button:SetPushedTexture("")
	Button:SetHighlightTexture("")
end

function KS:UIPanelScrollUpButtonTemplate(Button)
	KS:UIPanelScrollBarButton(Button)

	local arrow = Button:CreateTexture(nil, "ARTWORK")
	arrow:SetPoint("TOPLEFT", 4, -6)
	arrow:SetPoint("BOTTOMRIGHT", -5, 7)

	Button._KuiHighlight = {arrow}
end

function KS:UIPanelScrollDownButtonTemplate(Button)
	KS:UIPanelScrollBarButton(Button)

	local arrow = Button:CreateTexture(nil, "ARTWORK")
	arrow:SetPoint("TOPLEFT", 4, -7)
	arrow:SetPoint("BOTTOMRIGHT", -5, 6)

	Button._KuiHighlight = {arrow}
end

function KS:UIPanelScrollBarTemplate(Slider)
	KS:UIPanelScrollUpButtonTemplate(Slider.ScrollUpButton)
	KS:UIPanelScrollDownButtonTemplate(Slider.ScrollDownButton)

	Slider.ThumbTexture:SetAlpha(0)
	Slider.ThumbTexture:SetSize(17, 24)

	local thumb = _G.CreateFrame("Frame", nil, Slider)
	thumb:SetPoint("TOPLEFT", Slider.ThumbTexture, 0, -2)
	thumb:SetPoint("BOTTOMRIGHT", Slider.ThumbTexture, 0, 2)
	Slider._KuiThumb = thumb

	Slider:SetWidth(Slider:GetWidth())
end

function KS:NumericInputSpinnerTemplate(EditBox)
	EditBox:DisableDrawLayer("BACKGROUND")
end

function KS:UIPanelStretchableArtScrollBarTemplate(Slider)
	KS:UIPanelScrollBarTemplate(Slider)

	Slider.Top:Hide()
	Slider.Bottom:Hide()
	Slider.Middle:Hide()

	Slider.Background:Hide()
end

function KS:PortraitFrameTemplateNoCloseButton(Frame)
	local name = Frame:GetName()

	Frame.Bg:Hide()
	_G[name.."TitleBg"]:Hide()
	Frame.portrait:SetAlpha(0)
	Frame.PortraitFrame:SetTexture("")
	Frame.TopRightCorner:Hide()
	Frame.TopLeftCorner:SetTexture("")
	Frame.TopBorder:SetTexture("")

	Frame.TopTileStreaks:SetTexture("")
	Frame.BotLeftCorner:Hide()
	Frame.BotRightCorner:Hide()
	Frame.BottomBorder:Hide()
	Frame.LeftBorder:Hide()
	Frame.RightBorder:Hide()

	Frame:SetSize(Frame:GetSize())
end

function KS:PortraitFrameTemplate(Frame)
	KS:PortraitFrameTemplateNoCloseButton(Frame)
	Frame.CloseButton:SetPoint("TOPRIGHT", -5, -5)
end

--[[function KS:InsetFrameTemplate(Frame)
	Frame.Bg:Hide()

	Frame.InsetBorderTopLeft:Hide()
	Frame.InsetBorderTopRight:Hide()

	Frame.InsetBorderBottomLeft:Hide()
	Frame.InsetBorderBottomRight:Hide()

	Frame.InsetBorderTop:Hide()
	Frame.InsetBorderBottom:Hide()
	Frame.InsetBorderLeft:Hide()
	Frame.InsetBorderRight:Hide()
end]]

function KS:ButtonFrameTemplate(Frame)
	KS:PortraitFrameTemplate(Frame)
	local name = Frame:GetName()

	_G[name.."BtnCornerLeft"]:SetTexture("")
	_G[name.."BtnCornerRight"]:SetTexture("")
	_G[name.."ButtonBottomBorder"]:SetTexture("")
	--KS:InsetFrameTemplate(Frame.Inset)

	--[[ Scale ]]--
	Frame.Inset:SetPoint("TOPLEFT", 4, -60)
	Frame.Inset:SetPoint("BOTTOMRIGHT", -6, 26)
end

------------------------------------------------------------

------------------ Garrison Base Utilities -----------------

do --[[ FrameXML\GarrisonBaseUtils.lua ]]
	function KS.GarrisonFollowerPortraitMixin_SetNoLevel(self)
		if not self._auroraLvlBG then return end
		self._KuiLvlBG:Hide()
	end

	function KS.GarrisonFollowerPortraitMixin_SetLevel(self)
		if not self._auroraLvlBG then return end
		self._KuiLvlBG:Show()
	end

	function KS.GarrisonFollowerPortraitMixin_SetILevel(self)
		if not self._auroraLvlBG then return end
		self._KuiLvlBG:Show()
	end
end

do --[[ FrameXML\GarrisonBaseUtils.xml ]]
	function KS:PositionGarrisonAbiltyBorder(border, icon)
		border:ClearAllPoints()
		border:SetPoint("TOPLEFT", icon, -8, 8)
		border:SetPoint("BOTTOMRIGHT", icon, 8, -8)
	end

	function KS:GarrisonFollowerPortraitTemplate(Frame)
		Frame.PortraitRing:Hide()
		Frame.Portrait:SetPoint("CENTER", 0, 4)
		Frame.PortraitRingQuality:SetTexture("")

		local portraitBG = CreateFrame("Frame", nil, Frame)
		portraitBG:SetFrameLevel(Frame:GetFrameLevel())
		portraitBG:SetPoint("TOPLEFT", Frame.Portrait, -1, 1)
		portraitBG:SetPoint("BOTTOMRIGHT", Frame.Portrait, 1, -1)
		Frame._KuiPortraitBG = portraitBG

		Frame.LevelBorder:SetAlpha(0)
		local lvlBG = CreateFrame("Frame", nil, Frame)
		lvlBG:SetPoint("TOPLEFT", portraitBG, "BOTTOMLEFT", 0, 6)
		lvlBG:SetPoint("BOTTOMRIGHT", portraitBG, 0, -10)
		Frame._KuiLvlBG = lvlBG

		Frame.Level:SetParent(lvlBG)
		Frame.Level:SetPoint("CENTER", lvlBG)

		Frame.PortraitRingCover:SetTexture("")
	end
end

hooksecurefunc(GarrisonFollowerPortraitMixin, "SetNoLevel", KS.GarrisonFollowerPortraitMixin_SetNoLevel)
hooksecurefunc(GarrisonFollowerPortraitMixin, "SetLevel", KS.GarrisonFollowerPortraitMixin_SetLevel)
hooksecurefunc(GarrisonFollowerPortraitMixin, "SetILevel", KS.GarrisonFollowerPortraitMixin_SetILevel)

------------------------------------------------------------

-------------------- ItemButtonTemplate --------------------

do --[[ FrameXML\ItemButtonTemplate.lua ]]
	local size = 6
	local vertexOffsets = {
		{"TOPLEFT", 4, -size},
		{"BOTTOMLEFT", 3, -size},
		{"TOPRIGHT", 2, size},
		{"BOTTOMRIGHT", 1, size},
	}

	local function SetRelic(button, isRelic, color)
		if isRelic then
			if not button._auroraRelicTex then
				local relic = CreateFrame("Frame", nil, button)
				relic:SetAllPoints(button._auroraIconBorder)

				for i = 1, 4 do
					local tex = relic:CreateTexture(nil, "OVERLAY")
					tex:SetSize(size, size)

					local vertexInfo = vertexOffsets[i]
					tex:SetPoint(vertexInfo[1])
					tex:SetVertexOffset(vertexInfo[2], vertexInfo[3], 0)
					relic[i] = tex
				end

				button._auroraRelicTex = relic
			end

			for i = 1, #button._auroraRelicTex do
				local tex = button._auroraRelicTex[i]
				tex:SetColorTexture(color.r, color.g, color.b)
			end
			button._auroraRelicTex:Show()
		elseif button._auroraRelicTex then
			button._auroraRelicTex:Hide()
		end
	end

	function KS.SetItemButtonQuality(button, quality, itemIDOrLink)
		if button._auroraIconBorder then
			local isRelic = (itemIDOrLink and _G.IsArtifactRelicItem(itemIDOrLink))

			if quality then
				local color = _G.type(quality) == "table" and quality or _G.BAG_ITEM_QUALITY_COLORS[quality]
				if color and color == quality or quality >= _G.LE_ITEM_QUALITY_COMMON then
					SetRelic(button, isRelic, color)
					button._auroraIconBorder:SetBackdropBorderColor(color.r, color.g, color.b)
					button.IconBorder:Hide()
				else
					SetRelic(button, false)
					button._auroraIconBorder:SetBackdropBorderColor(0, 0, 0)
				end
			else
				SetRelic(button, false)
				button._auroraIconBorder:SetBackdropBorderColor(0, 0, 0)
			end
		end
	end
end
hooksecurefunc("SetItemButtonQuality", KS.SetItemButtonQuality)

------------------------------------------------------------

local function pluginInstaller()
	local PluginInstallFrame = _G["PluginInstallFrame"]
	if PluginInstallFrame then
		PluginInstallFrame:Styling()
		PluginInstallTitleFrame:Styling()
		PluginInstallStatus.backdrop:Styling()
	end
end

local function styleAddons()
	-- Shadow & Light
	if IsAddOnLoaded('ElvUI_SLE') and E.private.KlixUI.skins.addonSkins.sle then
		local sleFrames = {_G["SLE_BG_1"], _G["SLE_BG_2"], _G["SLE_BG_3"], _G["SLE_BG_4"], _G["SLE_DataPanel_1"], _G["SLE_DataPanel_2"], _G["SLE_DataPanel_3"], _G["SLE_DataPanel_4"], _G["SLE_DataPanel_5"], _G["SLE_DataPanel_6"], _G["SLE_DataPanel_7"], _G["SLE_DataPanel_8"], _G["SLE_RaidMarkerBar"].backdrop, _G["SLE_SquareMinimapButtonBar"], _G["SLE_LocationPanel"], _G["SLE_LocationPanel_X"], _G["SLE_LocationPanel_Y"], _G["SLE_LocationPanel_RightClickMenu1"], _G["SLE_LocationPanel_RightClickMenu2"], _G["InspectArmory"]}
		for _, frame in pairs(sleFrames) do
			if frame then
				frame:Styling()
				frame:SetTemplate("Transparent")
			end
		end
	end

	-- ElvUI_DTBars2
	if IsAddOnLoaded('ElvUI_DTBars2') and E.private.KlixUI.skins.addonSkins.dtb then
		for panelname, data in pairs(E.global.dtbars) do
			if panelname then
				_G[panelname]:Styling()
				if not E.db.dtbars[panelname].transparent then
					_G[panelname]:SetTemplate("Transparent")
				end
			end
		end
	end
	
	-- CoolGlow
	if IsAddOnLoaded("CoolGlow") then
		if CoolGlowTestFrame then
			_G["CoolGlowTestFrame"]:Styling()
		end
	end
	
	-- Simulationcraft
	if IsAddOnLoaded("Simulationcraft") then
		if SimcCopyFrame then
			_G["SimcCopyFrame"]:Styling()
		end
	end
end

local function StyleDBM_Options()
	if not E.private.KlixUI.skins.addonSkins.dbm or not IsAddOnLoaded("AddOnSkins") then return end

	DBM_GUI_OptionsFrame:HookScript('OnShow', function()
		DBM_GUI_OptionsFrame:Styling()
	end)
end

function KS:LoD_AddOns(_, addon)
	if addon == "DBM-GUI" then
		StyleDBM_Options()
	end
end

function KS:PLAYER_ENTERING_WORLD(...)
	styleAddons()

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function KS:Initialize()
	self.db = E.private.KlixUI.skins

	ReskinVehicleExit()
	updateMedia()
	pluginInstaller()
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	
	if IsAddOnLoaded("AddOnSkins") then
		if AddOnSkins then
			KS:ReskinAS(unpack(AddOnSkins))
		end
	end
end

local function InitializeCallback()
	KS:Initialize()
end

KUI:RegisterModule(KS:GetName(), InitializeCallback)