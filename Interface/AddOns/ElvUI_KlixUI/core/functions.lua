local KUI, E, L, V, P, G = unpack(select(2, ...))
local LSM = LibStub('LibSharedMedia-3.0')

local CreateFrame = CreateFrame
local assert, pairs, print, select = assert, pairs, print, select
local getmetatable = getmetatable
local find, format, match, split = string.find, string.format, string.match, string.split
local tconcat = table.concat

local classColor = E.myclass == 'PRIEST' and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])

local function CreateWideShadow(f)
	local borderr, borderg, borderb = 0, 0, 0
	local backdropr, backdropg, backdropb = 0, 0, 0

	local wideshadow = f.wideshadow or CreateFrame('Frame', nil, f) -- This way you can replace current shadows.
	wideshadow:SetFrameLevel(1)
	wideshadow:SetFrameStrata('BACKGROUND')
	wideshadow:SetOutside(f, 6, 6)
	wideshadow:SetBackdrop( { 
		edgeFile = LSM:Fetch('border', 'ElvUI GlowBorder'), edgeSize = E:Scale(6),
		insets = {left = E:Scale(8), right = E:Scale(8), top = E:Scale(8), bottom = E:Scale(8)},
	})
	wideshadow:SetBackdropColor(backdropr, backdropg, backdropb, 0)
	wideshadow:SetBackdropBorderColor(borderr, borderg, borderb, 0.5)
	f.wideshadow = wideshadow
end

local function CreateSoftShadow(f)
	local borderr, borderg, borderb = 0, 0, 0
	local backdropr, backdropg, backdropb = 0, 0, 0

	local softshadow = f.softshadow or CreateFrame('Frame', nil, f) -- This way you can replace current shadows.
	softshadow:SetFrameLevel(1)
	softshadow:SetFrameStrata('BACKGROUND')
	softshadow:SetOutside(f, 2, 2)
	softshadow:SetBackdrop( { 
		edgeFile = LSM:Fetch('border', 'ElvUI GlowBorder'), edgeSize = E:Scale(2),
		insets = {left = E:Scale(5), right = E:Scale(5), top = E:Scale(5), bottom = E:Scale(5)},
	})
	softshadow:SetBackdropColor(backdropr, backdropg, backdropb, 0)
	softshadow:SetBackdropBorderColor(borderr, borderg, borderb, 0.4)
	f.softshadow = softshadow
end

local function CreateSoftGlow(f)
	if f.sglow then return end

	local r, g, b = KUI:unpackColor(E.db.general.valuecolor)
	local sglow = CreateFrame('Frame', nil, f)

	sglow:SetFrameLevel(1)
	sglow:SetFrameStrata(f:GetFrameStrata())
	sglow:SetOutside(f, 3, 3)
	sglow:SetBackdrop( { 
		edgeFile = LSM:Fetch('border', 'ElvUI GlowBorder'), edgeSize = E:Scale(3),
		insets = {left = E:Scale(5), right = E:Scale(5), top = E:Scale(5), bottom = E:Scale(5)},
	})

	sglow:SetBackdropBorderColor(r, g, b, 0.6)

	f.sglow = sglow
	KUI["softGlow"][sglow] = true
end

local r, g, b = 0, 0, 0


function KUI:GetIconFromID(type, id)
    local path
    if type == "item" then
        path = select(10, GetItemInfo(id))
    elseif type == "spell" then
        path = select(3, GetSpellInfo(id))
    elseif type == "achiev" then
        path = select(10, GetAchievementInfo(id))
    end
    return path or nil
end

function KUI:GetSpell(id)
    local name = GetSpellInfo(id)
    return name
end

function KUI:BagSearch(itemId)
    for container = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(container) do
            if itemId == GetContainerItemID(container, slot) then
                return container, slot
            end
        end
    end
end

function KUI:CreateText(f, layer, fontsize, flag, justifyh)
	local text = f:CreateFontString(nil, layer)
	text:SetFont(E.media.normFont, fontsize, flag)
	text:SetJustifyH(justifyh or "CENTER")
	return text
end

--Movable buttons config (Credits: Shadow&Light)
local function MovableButton_Value(value)
	return gsub(value,'([%(%)%.%%%+%-%*%?%[%^%$])','%%%1')
end
local function MovableButton_Match(s,v)
	local m1, m2, m3, m4 = "^"..v.."$", "^"..v..",", ","..v.."$", ","..v..","
	return (match(s, m1) and m1) or (match(s, m2) and m2) or (match(s, m3) and m3) or (match(s, m4) and v..",")
end
function KUI:MovableButtonSettings(db, key, value, remove, movehere)
	local str = db[key]
	if not db or not str or not value then return end
	local found = MovableButton_Match(str, MovableButton_Value(value))
	if found and movehere then
		local tbl, sv, sm = {split(",", str)}
		for i in ipairs(tbl) do
			if tbl[i] == value then sv = i elseif tbl[i] == movehere then sm = i end
			if sv and sm then break end
		end
		tremove(tbl, sm);
		tinsert(tbl, sv, movehere);

		db[key] = tconcat(tbl,',')

	elseif found and remove then
		db[key] = gsub(str, found, "")
	elseif not found and not remove then
		db[key] = (str == '' and value) or (str..","..value)
	end
end

function KUI:CreateMovableButtons(Order, Name, CanRemove, db, key)
	local moveItemFrom, moveItemTo
	local config = {
		order = Order,
		dragdrop = true,
		type = "multiselect",
		name = Name,
		dragOnLeave = function() end, --keep this here
		dragOnEnter = function(info)
			moveItemTo = info.obj.value
		end,
		dragOnMouseDown = function(info)
			moveItemFrom, moveItemTo = info.obj.value, nil
		end,
		dragOnMouseUp = function(info)
			KUI:MovableButtonSettings(db, key, moveItemTo, nil, moveItemFrom) --add it in the new spot
			moveItemFrom, moveItemTo = nil, nil
		end,
		stateSwitchGetText = function(info, TEXT)
			local text = GetItemInfo(tonumber(TEXT))
			info.userdata.text = text
			return text
		end,
		stateSwitchOnClick = function(info)
			KUI:MovableButtonSettings(db, key, moveItemFrom)
		end,
		values = function()
			local str = db[key]
			if str == "" then return nil end
			return {split(",",str)}
		end,
		get = function(info, value)
			local str = db[key]
			if str == "" then return nil end
			local tbl = {split(",",str)}
			return tbl[value]
		end,
		set = function(info, value) end,
	}
	if CanRemove then --This allows to remove shit
		config.dragOnClick = function(info)
			KUI:MovableButtonSettings(db, key, moveItemFrom, true)
		end
	end
	return config
end

local function Styling(f, useSquares, useGradient, useShadow, shadowOverlayWidth, shadowOverlayHeight, shadowOverlayAlpha)
	assert(f, "doesn't exist!")
	local frameName = f.GetName and f:GetName()
	if E.db.KlixUI.general == nil then E.db.KlixUI.general = {} end
	if f.styling or E.db.KlixUI.general.style ~= true then return end

	local style = CreateFrame("Frame", frameName or nil, f)

	if not(useSquares) then
		local squares = f:CreateTexture(f:GetName() and f:GetName().."Overlay" or nil, "BORDER", f)
		squares:ClearAllPoints()
		squares:SetPoint("TOPLEFT", 1, -1)
		squares:SetPoint("BOTTOMRIGHT", -1, 1)
		squares:SetTexture([[Interface\AddOns\ElvUI_KlixUI\media\textures\squares]], true, true)
		squares:SetHorizTile(true)
		squares:SetVertTile(true)
		squares:SetBlendMode("ADD")

		f.squares = squares
	end

	if not(useGradient) then
		local gradient = f:CreateTexture(f:GetName() and f:GetName().."Overlay" or nil, "BORDER", f)
		gradient:ClearAllPoints()
		gradient:SetPoint("TOPLEFT", 1, -1)
		gradient:SetPoint("BOTTOMRIGHT", -1, 1)
		gradient:SetTexture([[Interface\AddOns\ElvUI_KlixUI\media\textures\gradient.tga]])
		gradient:SetVertexColor(.3, .3, .3, .15)

		f.gradient = gradient
	end

	if not(useShadow) then
		local mshadow = f:CreateTexture(f:GetName() and f:GetName().."Overlay" or nil, "BORDER", f)
		mshadow:SetInside(f, 0, 0)
		mshadow:Width(shadowOverlayWidth or 33)
		mshadow:Height(shadowOverlayHeight or 33)
		mshadow:SetTexture([[Interface\AddOns\ElvUI_KlixUI\media\textures\overlay]])
		mshadow:SetVertexColor(1, 1, 1, shadowOverlayAlpha or 0.6)

		f.mshadow = mshadow
	end

	style:SetFrameLevel(f:GetFrameLevel() + 1)
	f.styling = style

	KUI["styling"][style] = true
end

function KUI:CreatePulse(frame, speed, alpha, mult)
	assert(frame, "doesn't exist!")
	frame.speed = .02
	frame.mult = mult or 1
	frame.alpha = alpha or 1
	frame.tslu = 0
	frame:SetScript("OnUpdate", function(self, elapsed)
		elapsed = elapsed * (speed or 5/4)
		self.tslu = self.tslu + elapsed
		if self.tslu > self.speed then
			self.tslu = 0
			self:SetAlpha(self.alpha*(alpha or 3/5))
		end
		self.alpha = self.alpha - elapsed*self.mult
		if self.alpha < 0 and self.mult > 0 then
			self.mult = self.mult*-1
			self.alpha = 0
		elseif self.alpha > 1 and self.mult < 0 then
			self.mult = self.mult*-1
		end
	end)
end

local function addapi(object)
	local mt = getmetatable(object).__index
	if not object.Styling then mt.Styling = Styling end
	if not object.CreateSoftShadow then mt.CreateSoftShadow = CreateSoftShadow end
	if not object.CreateWideShadow then mt.CreateWideShadow = CreateWideShadow end
	if not object.CreateSoftGlow then mt.CreateSoftGlow = CreateSoftGlow end
end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())

object = EnumerateFrames()
while object do
	if not object:IsForbidden() and not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end