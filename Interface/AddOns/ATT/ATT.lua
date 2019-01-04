-- Arena Team Tracker by Izy

local name, SPELLDB = ...
local lower = string.lower
local match = string.match
local remove = table.remove
local GetSpellInfo = GetSpellInfo
local UnitClass = UnitClass
local UnitGUID = UnitGUID
local UnitName = UnitName
local IsInInstance = IsInInstance
local GetNumSubgroupMembers = GetNumSubgroupMembers
local CooldownFrame_Set = CooldownFrame_Set

local CommPrefix  = "ATTop31ms337x" -- Receive ability and cooldown
local CommPrefix2 = "ATTm4d4f4k4l0" -- Send GUID for syncing
local CommPrefix3 = "ATTl0lz3r1n4h" -- Receive GUID for syncing

local db
local pGUID
local pName

local ATT = CreateFrame("Frame","ATT",UIParent)
local ATTIcons = CreateFrame("Frame",nil,UIParent)
local ATTAnchor = CreateFrame("Frame",nil,UIParent)
local ATTTooltip = CreateFrame("GameTooltip", "ATTGameTooltip", nil, "GameTooltipTemplate")

local iconlist = {}
local anchors = {}
local syncGUIDS = {}
local activeGUIDS = {}
local InArena = function() return (select(2,IsInInstance()) == "arena") end

local function print(...)
	for i=1,select('#',...) do
		ChatFrame1:AddMessage("|cff33ff99ATT|r: " .. select(i,...))
	end
end

local validUnits = {
	["player"] = true,
	["party1"] = true,
	["party2"] = true,
	["party3"] = true,
	["party4"] = true,
}

local defaultAbilities = {
	["DRUID"] = {
		["ALL"] = {	-- All specs
			{5211, 50}, -- Mighty Bash
		},
		[102] = {	-- Balance
			{78675, 60}, -- Solar Beam
			{22812, 60},    -- Barkskin
		},
		[103] = {	-- Feral
			{106839, 15}, -- Skull Bash
			{61336, 180, 2}, -- Survival Instincts

		},
		[104] = {	-- Guardian
		},
		[105] = {	-- Restoration
			{22812, 60},    -- Barkskin
			{102342, 60}, -- Ironbark
		},
	},
	["HUNTER"] = {
		["ALL"] = {	-- All specs
			{186265, 180}, 	-- Aspect of the Turtle
			{187650, 30}, -- Freezing Trap
			{53480, 60},  -- Roar of Sacrifice
		},
		[253] = {	-- Beast Mastery
		},
		[254] = {	-- Marksmanship
		},
		[255] = {	-- Survival
		},
	},
	["MAGE"] = 	{
		["ALL"] = {	-- All specs
			{198111, 45}, -- Temporal Shield
			{2139, 24}, 	-- Counterspell
			{45438, 240},   -- Ice Block
			{113724, 45}, -- Ring of Frost
		},
		[62] = {	-- Arcane
		},
		[63] = {	-- Fire
			{31661, 20}, -- Dragon's Breath
		},
		[64] = {	-- Frost

		},
	},
	["PALADIN"] = {
		["ALL"] = {	-- All specs
			{853, 60}, 	-- Hammer of Justice
		},
		[65] = {	-- Holy
			{6940, 120, 2}, -- Blessing of Sacrifice
			{642, 300}, -- Divine Shield
			{216331, 120}, -- Avenging Crusader
			{1022, 300, 2}, -- Blessing of Protection
			{1044, 25, 2}, -- Blessing of Freedom
		},
		[66] = {	-- Protection
			{96231, 15}, -- Rebuke
		},
		[70] = {	-- Retribution
			{642, 300}, -- Divine Shield
			{96231, 15},  -- Rebuke
			{1022, 300}, -- Blessing of Protection
			{1044, 25}, -- Blessing of Freedom
			{210256, 45}, -- Blessing of Sanctuary
			{205191, 60}, -- Eye for an Eye	
		},

	},
	["PRIEST"] = {
		["ALL"] = {	-- All specs
			
		},
		[256] = {	-- Discipline		
			{8122, 60}, 	-- Psychic Scream
			{33206, 180},	-- Pain Suppression
			{62618, 180}, -- Power Word: Barrier
		},
		[257] = {	-- Holy
			{213602, 45}, -- Greater Fade
			{197268, 60}, -- Ray of Hope
			{47788, 180}, -- Guardian Spirit
		},
		[258] = {	-- Shadow
			{47585, 120},  	-- Dispersion
			{8122, 60}, 	-- Psychic Scream
			{15487, 45},   	-- Silence
		},
	},
	["ROGUE"] = {
		["ALL"] = {	-- All specs
			{1766, 15}, 	-- Kick
			{31224, 120},   -- Cloak of Shadows
		},
		[259] = {	-- Assassination
			{5277, 120}, -- Evasion
			{2094, 120},  -- Blind
			{212182, 180},  -- Smoke Bomb

		},
		[260] = {	-- Combat
		},
		[261] = {	-- Subtlety
			{5277, 120}, -- Evasion
			{212182, 180},  -- Smoke Bomb
		},
	},
	["SHAMAN"] = {
		["ALL"] = {	-- All specs
			{108271, 90}, -- Astral Shift
			{57994, 12}, 	-- Wind Shear
			{114052, 180},   -- Ascendance

		},
		[262] = {	-- Elemental

		},
		[263] = {	-- Enhancement
		
		},
		[264] = {	-- Restoration
			{98008, 180},   -- Spirit Link Totem
			{198838, 60},   -- Earthen Wall Totem
		},
	},
	["WARLOCK"] = {
		["ALL"] = {	-- All specs
			{19647, 24}, 	-- Spell Lock
			{104773, 180}, -- Unending Resolve
			{108416, 60}, -- Dark Pact
			{212295, 45}, -- Nether Ward
		},
		[265] = {	-- Affliction
		},
		[266] = {	-- Demonology
		},
		[267] = {	-- Destruction
		},
	},
	["WARRIOR"] = {
		["ALL"] = {	-- All specs
			{6552, 15}, 	-- Pummel
			{236077, 45}, -- Disarm
			{107570, 30}, -- Storm Bolt
		},
		[71] = {	-- Arms
			{5246, 90}, 	-- Intimidating Shout
			{118038, 180}, -- Die by the Sword
		},
		[72] = {	-- Fury
			{5246, 90}, 	-- Intimidating Shout
		},
		[73] = {	-- Protection
		},
	},
	["DEATHKNIGHT"] = {
		["ALL"] = {	-- All specs
			{47528, 15}, 	-- Mind Freeze
			{48707, 60},   	-- Anti-Magic Shell
			{48792, 180}, -- Icebound Fortitude
		},
		[250] = {	-- Blood
		},
		[251] = {	-- Frost
			{212552, 60}, -- Wraith Walk
		},
		[252] = {	-- Unholy
			{108194, 45}, -- Asphyxiate
			{47482, 30}, -- Leap (Interrupt pet)
		},
	},
	["MONK"] = {
		["ALL"] = {	-- All specs
			{119381, 60}, -- Leg Sweep
		},
		[268] = {	-- Brewmaster
		},
		[269] = {	-- Windwalker
			{116705, 15}, -- Spear Hand Strike
			{122470, 90}, -- Touch of Karma
			{201318 , 90}, -- Fortifying Brew
		},
		[270] = {	-- Mistweaver
			{116849, 120}, 	-- Life Cocoon
		},
	},
	["DEMONHUNTER"] = {
		["ALL"] = {
			{198589, 60}, -- Blur
			{183752, 10}, -- Consume Magic
			{217832, 45}, -- Imprison
		},
		[577] = { -- Havoc
            {196718, 180}, -- Darkness
		},
		[581] = { -- Vengeance

		},
	}
}

-- Localized names:
local PvPTrinketName = GetSpellInfo(208683)
local EveryManForHimselfName = GetSpellInfo(59752) 
local StoneformName = GetSpellInfo(20594)
local AdaptedName = GetSpellInfo(195756)
local WillOfTheForsakenName = GetSpellInfo(7744)
local PvPTrinket = { ability = PvPTrinketName, cooldown = 120, id = 208683 }

local function convertspellids(t)
	local temp = {}
	for class, table in pairs(t) do
		temp[class] = {}
		for spec, spells in pairs(table) do
			spec = tostring(spec)
			temp[class][spec] = {}
			for k, spell in pairs(spells) do
				local spellInfo = GetSpellInfo(spell[1])
				if spellInfo then temp[class][spec][#temp[class][spec]+1] = { ability = spellInfo, cooldown = spell[2], id = spell[1], maxcharges = spell[3], talent = spell.talent } end
			end
		end
	end
	return temp
end

defaultAbilities = convertspellids(defaultAbilities)

local cooldownResetters = {
	[11958] = { -- Cold Snap
		[120] = 1, 		-- Cone of Cold
		[45438] = 1,  	-- Ice Block
		[122] = 1, 		-- Frost Nova
	},
}

local temp = {}
for k, v in pairs(cooldownResetters) do
	local spellInfo = GetSpellInfo(k)
	if spellInfo then
		temp[spellInfo] = {}
		if type(v) == "table" then
			for id in pairs(v) do
				local spellInfo2 = GetSpellInfo(id)
				if spellInfo2 then temp[spellInfo][spellInfo2] = 1 end
			end
		else
			temp[GetSpellInfo(k)] = v
		end
	end
end

cooldownResetters = temp
temp = nil
convertspellids = nil

-- Inspection stuff (Based on ATTR):
local inspected = {}
local inspect_queue = {}
local nextInspectTick = 0

local supportedUnits = { "party1", "party2", "party3", "party4", "player" }
function ATT:FindUnitByGUID(guid)
	if guid then
		for i, unit in pairs(supportedUnits) do
			if UnitGUID(unit) == guid then
				return unit
			end
		end
	end
end

function ATT:GetSpecByGUID(guid)
	return inspected[guid]
end

function ATT:GetSpecByUnit(unit)
	local guid = UnitGUID(unit)
	if guid then return inspected[guid] end
end

function ATT:QueueInspect(unit)
	local guid = UnitGUID(unit)
	if guid then
		self:DequeueInspectByGUID(guid)
		inspect_queue[#inspect_queue+1] = guid
	end
end

function ATT:DequeueInspectByGUID(guid)
	for i=#inspect_queue, 1, -1 do
		if inspect_queue[i] == guid then
			table.remove(inspect_queue, i)
		end
	end
end

function ATT:InspectPlayer()
	ATT:InspectIsReady(UnitGUID("player"))
end

function ATT:InspectIsReady(guid)
	local inspectedUnit = ATT:FindUnitByGUID(guid)
	if not inspectedUnit then return end
	local isInspect = inspectedUnit ~= "player"
	self:DequeueInspectByGUID(guid)
	if isInspect then
		inspected[guid] = GetInspectSpecialization(inspectedUnit) or 0
		self:UpdateAnchors()
	else 	    
		local spec = GetSpecialization()
		if spec then 
			inspected[guid] = GetSpecializationInfo(spec) or 0
		end
	end
end

function ATT:EnqueueInspect()
	table.wipe(inspect_queue)
	for i=1, GetNumGroupMembers() do
		ATT:QueueInspect("party"..i)
	end
end

function ATT:ProcessInspectQueue()
	    if GetTime() > nextInspectTick then
	    nextInspectTick = GetTime() + 1
		--self:InspectPlayer()
		--self:InspectIsReady(guid)
		for i, guid in pairs(inspect_queue) do
			local unit = ATT:FindUnitByGUID(guid)
			if unit and CanInspect(unit) and not (InspectFrame and InspectFrame:IsShown()) then
				NotifyInspect(unit)
				break
			end
		end
	 end
end

function ATT:INSPECT_READY(guid)
	ATT:InspectIsReady(guid)
end

hooksecurefunc("NotifyInspect", function(unit) nextInspectTick = GetTime() + 3 end)

function ATT:SavePositions()
	for k,anchor in ipairs(anchors) do
		local scale = anchor:GetEffectiveScale()
		local worldscale = UIParent:GetEffectiveScale()
		local x = anchor:GetLeft() * scale
		local y = (anchor:GetTop() * scale) - (UIParent:GetTop() * worldscale)
		if not db.positions[k] then
			db.positions[k] = {}
		end	
		db.positions[k].x = x
		db.positions[k].y = y
	end
end

function ATT:FindCompactRaidFrameByUnit(unit)
	if not unit or not UnitGUID(unit) then return end
	for i=1, 5 do
		local frame = nil
		if CompactRaidFrameManager_GetSetting("KeepGroupsTogether") then 
			if UnitInRaid("player") then
			     frame = _G["CompactRaidGroup1Member"..i]
			else
				 frame = _G["CompactPartyFrameMember"..i]
			end
		else
			frame = _G["CompactRaidFrame"..i]
		end
		if frame and frame.unit and UnitGUID(frame.unit) == UnitGUID(unit) then
			return frame
		end
	end
end


function ATT:LoadPositions()
	db.positions = db.positions or {}
	for k,anchor in ipairs(anchors) do
		anchors[k]:ClearAllPoints()
		local raidFrame
		if db.attach then raidFrame = self:FindCompactRaidFrameByUnit(k==5 and "player" or "party" ..k) end	
		if raidFrame then
			anchors[k]:SetPoint(db.growLeft and "BOTTOMLEFT" or "BOTTOMRIGHT", raidFrame, db.growLeft and "TOPLEFT" or "TOPRIGHT", db.offsetX, db.offsetY)
		else
			if db.positions[k] then
				local x = db.positions[k].x
				local y = db.positions[k].y
				local scale = anchors[k]:GetEffectiveScale()
				anchors[k]:SetPoint("TOPLEFT", UIParent,"TOPLEFT", x/scale, y/scale)
			else
				anchors[k]:SetPoint("CENTER", UIParent, "CENTER")
			end
		end
	end 
end

function ATT:CreateAnchors()
    local backdrop = {bgFile="Interface\\Tooltips\\UI-Tooltip-Background", edgeFile="", tile=false,}
	for i=1,5 do
	    if i ~= nil then 
		local anchor = CreateFrame("Frame","ATTAnchor"..i ,ATTAnchor)
		anchor:SetBackdrop(backdrop)
		anchor:SetHeight(15)
		anchor:SetWidth(15)
		anchor:SetBackdropColor(1,0,0,1)
		anchor:EnableMouse(true)
		anchor:SetMovable(true)
		anchor:Show()
		anchor.icons = {}
		anchor.HideIcons = function() for k,icon in ipairs(anchor.icons) do icon:Hide(); icon.inUse = nil end end
		anchor:SetScript("OnMouseDown",function(self,button) if button == "LeftButton" and not db.attach then self:StartMoving() end end)
		anchor:SetScript("OnMouseUp",function(self,button) if button == "LeftButton" and not db.attach then self:StopMovingOrSizing(); ATT:SavePositions() end end)
		anchor:Hide() -- here
		anchors[i] = anchor
		
		local index = anchor:CreateFontString(nil,"ARTWORK","GameFontNormal")
		index:SetPoint("CENTER")
		index:SetText(i)
	end end
end

-- creates a new raw frame icon that can be used/reused to show cooldowns
local function CreateIcon(anchor)
	local icon = CreateFrame("Frame",anchor:GetName().."Icon".. (#anchor.icons+1),ATTIcons)
	icon:SetHeight(38)
	icon:SetWidth(38)
	local cd = CreateFrame("Cooldown",icon:GetName().."Cooldown",icon,"CooldownFrameTemplate")
	cd:SetHideCountdownNumbers(false)
	icon.cd = cd	
	icon.Start = function(sentCD , nextcharge)
		icon.cooldown = tonumber(sentCD)
		if icon.maxcharges then
			local charges = tonumber(icon.chargesText:GetText():match("^[0-9]+$"))
			if charges == 2 or nextcharge == icon.maxcharges then
				CooldownFrame_Set(cd,GetTime(),icon.cooldown, 1, 1, 1)
				icon.cd:SetDrawEdge(true)
				icon.cd:SetDrawSwipe(true)
				icon.starttime = GetTime()
				charges = charges - 1
				icon.chargesText:SetText(charges)

            elseif charges == 1 and nextcharge == 5 then
			    CooldownFrame_Set(cd,GetTime(),icon.cooldown, 1)
				icon.cd:SetDrawEdge(true)
				icon.cd:SetDrawSwipe(false)    
				icon.starttime = GetTime()
				icon.chargesText:SetText(charges)

			elseif  charges == 1 and nextcharge == 1 and  icon.starttime < GetTime() then
				CooldownFrame_Set(cd, icon.starttime, icon.cooldown, 1)
				icon.cd:SetDrawEdge(false)
				icon.cd:SetDrawSwipe(true)
				--icon.starttime = GetTime()
				charges = charges - 1
				icon.chargesText:SetText(charges)
			end

		else
			CooldownFrame_Set(cd,GetTime(),icon.cooldown, 1)
			icon.starttime = GetTime()
		end

		icon:Show()
		icon.active = true;

        activeGUIDS[icon.GUID] = activeGUIDS[icon.GUID] or {}
		activeGUIDS[icon.GUID][icon.ability] = activeGUIDS[icon.GUID][icon.ability] or {}
		activeGUIDS[icon.GUID][icon.ability].starttime = icon.starttime
		activeGUIDS[icon.GUID][icon.ability].cooldown =  icon.cooldown
	end

	icon.Stop = function()
		CooldownFrame_Set(cd,0,0,0);
		icon.starttime = 0
	end
	
	icon.SetTimer = function(starttime,cooldown)
		CooldownFrame_Set(cd,starttime,cooldown,1)
		icon.active = true
		icon.starttime = starttime
		icon.cooldown = cooldown
	end
	
	local texture = icon:CreateTexture(nil,"ARTWORK")
	texture:SetAllPoints(true)
	icon.texture = texture
	ATT:ApplyIconTextureBorder(icon)
    
	icon.chargesText = icon:CreateFontString(nil, "string", "GameFontNormal")
	icon.chargesText:SetTextColor(1, 1, 1)
	icon.chargesText:SetText("")
	icon.chargesText:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT")

	-- tooltip:
	icon:EnableMouse()
	icon:SetScript('OnEnter', function()
		if db.showTooltip and icon.abilityID then
			ATTTooltip:ClearLines()
			ATTTooltip:SetOwner(WorldFrame, "ANCHOR_CURSOR")
			ATTTooltip:SetSpellByID(icon.abilityID)
		end
	end)
	icon:SetScript('OnLeave', function()
		if db.showTooltip and icon.abilityID then
			ATTTooltip:ClearLines()
			ATTTooltip:Hide()
		end
	end)
	return icon
end

-- adds a new icon to icon list of anchor
function ATT:AddIcon(icons,anchor)
	local newicon = CreateIcon(anchor)
	iconlist[#iconlist+1] = newicon
	icons[#icons+1] = newicon
	return newicon
end

-- applies texture border to an icon
function ATT:ApplyIconTextureBorder(icon)
    if db.showIconBorders then
		icon.texture:SetTexCoord(0,1,0,1)
	else
		icon.texture:SetTexCoord(0.07,0.9,0.07,0.90)
	end
end

-- hides anchors currently not in use due to too few party members
function ATT:ToggleAnchorDisplay()
	-- Player (Test):
	if db.showSelf and anchors[5] then anchors[5]:Show() end
	-- Party members:
	for i=1,GetNumSubgroupMembers() do anchors[i]:Show() end

	for k=GetNumSubgroupMembers()+1,4 do
		anchors[k]:Hide()
		anchors[k].HideIcons()
	end
	if not db.showSelf and anchors[5] then
		anchors[5]:Hide()
		anchors[5]:HideIcons()
	end
end

-- shuffles raw icon frames around on group update, changed settings, etc
-- also sets attributes for each icon frame
function ATT:UpdateAnchor(unit, i)
		local _,class = UnitClass(unit)
        local guid = UnitGUID(unit)
		if not class or not guid then return end

		local anchor = anchors[i]
		anchor.GUID = guid
		anchor.class = class
		local icons = anchor.icons 
		local numIcons = 1
		-- PvP Trinket:
		if db.showTrinket then
			local ability, id, cooldown = PvPTrinket.ability, PvPTrinket.id, PvPTrinket.cooldown
			local icon = icons[numIcons] or self:AddIcon(icons,anchor)
			icon.texture:SetTexture(self:FindAbilityIcon(ability, id))
			icon.GUID = anchor.GUID
			icon.ability = ability
			icon.abilityID = id
			icon.cooldown = cooldown
			icon.showing = true
			icon.inUse = true
            icon.spec = nil

			ATT:ApplyIconTextureBorder(icon)

			activeGUIDS[icon.GUID] = activeGUIDS[icon.GUID] or {}
			if activeGUIDS[icon.GUID][icon.ability] then
				icon.SetTimer(activeGUIDS[icon.GUID][ability].starttime,activeGUIDS[icon.GUID][ability].cooldown)
			else
				icon.Stop()
			end
			numIcons = numIcons + 1
		elseif icons[1] and icons[1].ability == PvPTrinketName then
			icons[1]:Hide()
			icons[1].showing = nil
			icons[1].inUse = nil
            icons[1].spec = nil
			table.remove(icons, 1)
		end
		-- Abilities [All Specs]:
		
		for abilityIndex, abilityTable in pairs(db.abilities[class]["ALL"]) do
			local ability, id, cooldown, maxcharges, talent = abilityTable.ability, abilityTable.id, abilityTable.cooldown, abilityTable.maxcharges, abilityTable.talent
			local icon = icons[numIcons] or self:AddIcon(icons,anchor)
			icon.texture:SetTexture(self:FindAbilityIcon(ability, id))
			icon.GUID = anchor.GUID
			icon.ability = ability
			icon.abilityID = id
			icon.cooldown = cooldown
			icon.maxcharges = maxcharges
			icon.chargesText:SetText(maxcharges or "")
			icon.inUse = true
            icon.spec = talent

			ATT:ApplyIconTextureBorder(icon)

			activeGUIDS[icon.GUID] = activeGUIDS[icon.GUID] or {}
			if activeGUIDS[icon.GUID][icon.ability] then
				icon.SetTimer(activeGUIDS[icon.GUID][ability].starttime,activeGUIDS[icon.GUID][ability].cooldown)
			else
				icon.Stop()
			end
			numIcons = numIcons + 1
		end
		-- Abilities [Current Spec]:
		local unitSpec = tostring(self:GetSpecByGUID(anchor.GUID))
		if unitSpec and unitSpec ~= "0" and unitSpec ~= "ALL" and unitSpec ~= "nil" then
			for abilityIndex, abilityTable in pairs(db.abilities[class][unitSpec]) do
				local ability, id, cooldown, maxcharges, talent = abilityTable.ability, abilityTable.id, abilityTable.cooldown, abilityTable.maxcharges, abilityTable.talent
				local icon = icons[numIcons] or self:AddIcon(icons,anchor)
				icon.texture:SetTexture(self:FindAbilityIcon(ability, id))
				icon.GUID = anchor.GUID
				icon.ability = ability
				icon.abilityID = id
				icon.cooldown = cooldown
				icon.maxcharges = maxcharges
				icon.chargesText:SetText(maxcharges or "")
				icon.inUse = true
				icon.spec = talent

				ATT:ApplyIconTextureBorder(icon)

				activeGUIDS[icon.GUID] = activeGUIDS[icon.GUID] or {}
				if activeGUIDS[icon.GUID][icon.ability] then
					icon.SetTimer(activeGUIDS[icon.GUID][ability].starttime,activeGUIDS[icon.GUID][ability].cooldown)
				else
					icon.Stop()
				end
				numIcons = numIcons + 1
			end
		end

		-- clean leftover icons
		for j=numIcons,#icons do
			icons[j].spec = nil
			icons[j].seen = nil
			icons[j].active = nil
			icons[j].inUse = nil
			icons[j].showing = nil
		end

	--	self:ToggleIconDisplay(i)	
end

-- responsible for actual anchoring of icons
function ATT:ToggleIconDisplay(i)
	local anchor = anchors[i]
	local icons = anchor.icons
	local count = 1
	local lastActiveIndex = 0;
	-- hiding all icons before anchoring and deciding whether to show them
	for k, icon in pairs(icons) do
		if icon and icon.ability and icon.inUse then
			if icon.spec then
				icon.showing = (not db.hidden and icon.seen) or (db.hidden and activeGUIDS[icon.GUID][icon.ability] and icon.active)
			else
				icon.showing = (activeGUIDS[icon.GUID] and activeGUIDS[icon.GUID][icon.ability] and icon.active) or (not db.hidden)
			end
		end
		icon:ClearAllPoints()
		icon:Hide()
	end

	for k, icon in pairs(icons) do
		if icon and icon.ability and icon.showing then
		    if db.iconOffsetX == nil then
                db.iconOffsetX = "5"
            end
         if  not db.tworows then
			if count == 1  then
				icon:SetPoint(db.growLeft and "TOPRIGHT" or "TOPLEFT", anchor, db.growLeft and "BOTTOMLEFT" or "BOTTOMRIGHT", db.growLeft and -1 * db.iconOffsetX or db.iconOffsetX, 0)
			else
				icon:SetPoint(db.growLeft and "RIGHT" or "LEFT", icons[lastActiveIndex], db.growLeft and "LEFT" or "RIGHT", db.growLeft and -1 * db.iconOffsetX or db.iconOffsetX, 0)
			end
			 else 
			 if count == 1 then
				icon:SetPoint(db.growLeft and "TOPRIGHT" or "TOPLEFT", anchor, db.growLeft and "BOTTOMLEFT" or "BOTTOMRIGHT", db.growLeft and -1 * db.iconOffsetX or db.iconOffsetX, 0)
			else if   (count % 2 == 0 ) then 			
				icon:SetPoint(db.growLeft and "TOP" or "TOP", icons[lastActiveIndex], db.growLeft and "BOTTOM" or "BOTTOM", db.growLeft )			 
			else	
                icon:SetPoint(db.growLeft and "BOTTOMRIGHT" or "BOTTOMLEFT", icons[lastActiveIndex], db.growLeft and "TOPLEFT" or "TOPRIGHT", db.growLeft and -1 * db.iconOffsetX or db.iconOffsetX, 0)
			 end
			 
			end 
		end
			lastActiveIndex = k
			count = count + 1
			icon:Show()
		end
	end
	 -- self:ToggleAnchorDisplay() 
end

function ATT:UpdateAnchors()
	-- Player (Test):
	if db.showSelf and anchors[5] then self:UpdateAnchor("player", 5) end
	-- Party members:
	for i=1, GetNumSubgroupMembers() do
		local _,class = UnitClass("party"..i)
		if not class then break end
		if not anchors[i] then break end
		local unit = "party"..i
		self:UpdateAnchor(unit, i)
	end
    self:LoadPositions()
	self:ToggleAnchorDisplay()
	self:ApplyAnchorSettings()
	
end

function ATT:UpdateIcons()
	-- Player (Test):
	if db.showSelf and anchors[5] then self:ToggleIconDisplay(5) end
	-- Party members:
	for i=1, GetNumSubgroupMembers() do
		self:ToggleIconDisplay(i)
	end
end

function ATT:ApplyAnchorSettings()
    local _, instanceType = IsInInstance()
	ATTIcons:SetScale(db.scale or 1)
	
	if db.arena then
		if instanceType == "arena" then
			ATTIcons:Show()
			self:Show()
		else
			ATTIcons:Hide()
			self:Hide()
		end
	else
		ATTIcons:Show()
		self:Show()
	end
	    
	if db.lock then ATTAnchor:Hide() else ATTAnchor:Show() end
	self:UpdateIcons()

	if db.arenanumber then
	self:Fnumbers()
    end
    
	if instanceType == "arena" and db.dampening then
	 self:RegisterUnitEvent("UNIT_AURA", "player")
	else	
	 self:UnregisterEvent("UNIT_AURA")
	end
end

function ATT:Fnumbers()    
	local ATTU=UnitIsUnit 
    hooksecurefunc("CompactUnitFrame_UpdateName",function(Fnumbers)
    if IsActiveBattlefieldArena() and Fnumbers.unit:find("nameplate") and db.arenanumber then 
    for i=1,3 do if ATTU(Fnumbers.unit,"arena"..i) then Fnumbers.name:SetText(i)Fnumbers.name:SetTextColor(1,1,0)break end end end end)
end

function ATT:GroupUpdate()
--	self:EnqueueInspect()
	self:InspectPlayer()
	ATT:EnqueueInspect()
	if not pGUID then pGUID = UnitGUID("player") end
	if not pName then pName = UnitName("player") end
	--if not pName then pName = UnitName("player") .. "-" .. GetRealmName() end
	self:RequestSync()
	self:LoadPositions()
	self:UpdateAnchors()
end

local FindAuraByName = AuraUtil.FindAuraByName
local dampeningtext = GetSpellInfo(110310)

function ATT:UNIT_AURA(unit)
	local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, nameplateShowAll, noIdea, timeMod , percentage = FindAuraByName(dampeningtext, unit, "HARMFUL")
  	if percentage then
		if self.dampening ~= percentage then
			self.dampening = percentage
			self.text:SetText(dampeningtext..": "..percentage.."%")
		end

	elseif self:IsShown() then
		--self:IsHide()
		self.text:SetText("")
	end
end

function ATT:PLAYER_ENTERING_WORLD()
--	self:EnqueueInspect()
	self:InspectPlayer()
	ATT:EnqueueInspect()	
	local inInstance, instanceType = IsInInstance()
    if instanceType == "arena" then self:StopAllIcons() end -- Cooldowns reset when joining arena FIX
	if not pGUID then pGUID = UnitGUID("player") end
	--if not pName then pName = UnitName("player") .. "-" .. GetRealmName() end
    if not pName then pName = UnitName("player") end    
    self:RequestSync()
    self:LoadPositions()
    self:UpdateAnchors()
end

function ATT:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, auraType = CombatLogGetCurrentEventInfo()       
		if(event == "SPELL_CAST_SUCCESS" ) or (event == "SPELL_AURA_APPLIED" ) then
		 self:StartCooldown(spellName, self:GetUnitByGUID(sourceGUID))
	end
end

function ATT:FindAbilityByName(abilities, name)
	if abilities then
		for i, v in pairs(abilities) do
			if v and v.ability and v.ability == name then return v, i end
		end
	end
end

function ATT:GetUnitByGUID(guid)
	for k,v in pairs(validUnits) do
		if UnitGUID(k) == guid then
			return k
		end
	end
end

function ATT:StartCooldown(spellName, unit, cooldown)
	if not unit then return end -- in case unit is bugged
	local index = match(unit, "party[pet]*([1-4])")

	if unit == "player" or unit == "pet" then
		if(not db.showSelf ) then return end
		unit = "player"
		index = 5
	elseif index then
		unit = "party"..index
	end

	local anchor = anchors[tonumber(index)]
	if not anchor or not index then return end

	local _,class = UnitClass(unit)
	local spec = tostring(self:GetSpecByUnit(unit))
	local cAbility = self:FindAbilityByName(db.abilities[class]["ALL"], spellName) or self:FindAbilityByName(db.abilities[class][spec], spellName) 
	if cooldown and cAbility then cAbility.cooldown = cooldown end
	local start, duration, enabled = GetSpellCooldown(PvPTrinketName);
    -- trinket fix 
    	if  spellName == PvPTrinketName then
		spellName = PvPTrinketName
		cAbility = {cooldown = 120}
	end
	-- 30 second trinket trigger
	if  spellName == EveryManForHimselfName then
		spellName = PvPTrinketName
		cAbility = {cooldown = 90}
	end

	if spellName == AdaptedName then
		spellName = PvPTrinketName
		cAbility = {cooldown = 60}
	end
	if (duration ) then
		if  spellName == WillOfTheForsakenName  then
 if ( start > 0 and duration > 0) then
 spellName = PvPTrinketName
  duration = start + duration - GetTime()
 cAbility = {cooldown = duration }
 else
 spellName = PvPTrinketName
 cAbility = {cooldown = 30}
 end
	end
	if  spellName == StoneformName  then
 if ( start > 0 and duration > 0) then
 spellName = PvPTrinketName
  duration = start + duration - GetTime()
 cAbility = {cooldown = duration }
else
 spellName = PvPTrinketName
 cAbility = {cooldown = 30}
end
	end
	    
end
	self:TrackCooldown(anchor, spellName, cAbility and cAbility.cooldown or nil)
end

function ATT:TrackCooldown(anchor, ability, cooldown)
	for k,icon in ipairs(anchor.icons) do
		if cooldown then
			-- Direct cooldown
			if icon.ability == ability then
				icon.seen = true
				icon.Start(cooldown , 1)
			end		
		end
		-- Cooldown resetters
		if cooldownResetters[ability] then
			if type(cooldownResetters[ability]) == "table" then
				--for k in pairs(cooldownResetters[ability]) do if k == icon.ability then icon.Stop(); break end end
				if cooldownResetters[ability][icon.ability] then icon.Stop() end
			else
				icon.Stop()
			end
		end
	end
end

function ATT:UNIT_SPELLCAST_SUCCEEDED(unit, ability)
	if (unit == "player" or unit == "pet") and ability then self:SendCooldown(ability) end
	if ability then
		self:StartCooldown(ability, unit);
	end
end

local timers, timerfuncs, timerargs = {}, {}, {}
function ATT:Schedule(duration,func,...)
	timers[#timers+1] = duration
	timerfuncs[#timerfuncs+1] = func
	timerargs[#timerargs+1] = {...}
end

local time = 0

local function ATT_OnUpdate(self,elapsed)
	time = time + elapsed
	if time > 0.05 then
		-- Inspection stuff:
		ATT:ProcessInspectQueue()
		--  Update icon activity
		--print("test onupdate" ..time)
		for k,icon in ipairs(iconlist) do
			if icon.active then
				icon.timeleft = icon.starttime + icon.cooldown - GetTime()
				if icon.timeleft <= 0 then
					if not icon.showing then icon:Hide() end
					if activeGUIDS[icon.GUID] then activeGUIDS[icon.GUID][icon.ability] = nil end -- There was error when activeGUIDS[icon.GUID] is nil
					icon.active = nil
					if icon.maxcharges then
						local charges = tonumber(icon.chargesText:GetText():match("^[0-9]+$"))
						charges = math.min(icon.maxcharges, charges+1)
						icon.chargesText:SetText(charges)
						if charges < icon.maxcharges then
							icon.Start(icon.cooldown, 5)
						end
					end
				end
			end 
		end		
		--ATT:UpdateIcons()		
		 -- Update Timers
		if #timers > 0 then
			for i=#timers,1,-1 do 
				timers[i] = timers[i] - 0.05
				if timers[i] <= 0 then
					remove(timers,i)
					remove(timerfuncs,i)(ATT,unpack(remove(timerargs,i)))
				end
			end
		end	
		time = 0
	end 
end

-- resets all icons on zone change
function ATT:StopAllIcons()
	for k,v in ipairs(iconlist) do
		v.Stop()
		v.seen = nil
	end
	wipe(activeGUIDS)
end

function ATT:RequestSync()
	wipe(syncGUIDS)
	if self.useCrossAddonCommunication then self:SendAddonMessage(CommPrefix2, pGUID .. "|" .. GetTime(), "PARTY") end
end

function ATT:CHAT_MSG_ADDON(prefix, message, dist, sender)
	if dist == "PARTY" and sender ~= pName then
		if prefix == CommPrefix then
			local GUID, ability, cooldown, spellID = match(message,"(.+)|(.+)|(.+)|(.+)")
			if syncGUIDS[GUID] then
				self:StartCooldown(GetSpellInfo(spellID), self:GetUnitByGUID(GUID), cooldown)
			end
		elseif prefix == CommPrefix2 then
			local GUID, guidTime = match(message, "(.+)|(.+)")
			self:SendAddonMessage(CommPrefix3, pGUID, "PARTY")
		elseif prefix == CommPrefix3 then
			for i=1, GetNumSubgroupMembers() do if UnitGUID("party"..i) == message then syncGUIDS[message] = anchors[i] end end
			if UnitGUID("player") == message then syncGUIDS[message] = anchors[5] end  	-- debug only
		end
	end
end

function ATT:SendAddonMessage(prefix, message, dest, target)
	local chl = strlower(dest)
	if (chl == "party" and GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) == 0) then
		return
	end
	C_ChatInfo.SendAddonMessage(prefix, message, dest, target)
end

-- sends message to your party via addon communication
function ATT:SendCooldown(ability)
	if not self.useCrossAddonCommunication then return end
	local start, duration, enabled = GetSpellCooldown(ability)
	if not start then return end
	local spellID = select(7, GetSpellInfo(ability))
	if enabled == 0 then
		self:Schedule(0.05, self.SendCooldown, ability)
		return
	elseif start > 0 and duration > 0 then
		self:SendAddonMessage(CommPrefix, pGUID .. "|" .. ability .. "|" .. (start + duration - GetTime()) .. "|" .. spellID, "PARTY")
	end
end

local function ATT_OnLoad(self)
    ATT:SetPoint("TOP", UIWidgetTopCenterContainerFrame, "BOTTOM", 0, 0)
    ATT:SetSize(200, 50.38) 
    ATT.text = ATT:CreateFontString(nil, "BACKGROUND")
    ATT.text:SetFontObject(GameFontNormal)
    ATT.text:SetAllPoints()
    if C_ChatInfo.RegisterAddonMessagePrefix(CommPrefix) and C_ChatInfo.RegisterAddonMessagePrefix(CommPrefix2) and C_ChatInfo.RegisterAddonMessagePrefix(CommPrefix3) then
		self.useCrossAddonCommunication = true end

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GROUP_JOINED")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:RegisterEvent("INSPECT_READY") 	
	
	if self.useCrossAddonCommunication then self:RegisterEvent("CHAT_MSG_ADDON") end
	self:SetScript("OnEvent",function(self,event, ...) if self[event] then self[event](self, ...) end
	if event == "GROUP_JOINED" --[[or event == "UNIT_OTHER_PARTY_CHANGED" --]] or event == "GROUP_ROSTER_UPDATE" then ATT:GroupUpdate(); end
	end);	
	ATTDB = ATTDB or { abilities = defaultAbilities, scale = 1  }
	db = ATTDB
	if not db.classSelected then db.classSelected = "WARRIOR" end
	self:CreateAnchors()
	self:LoadPositions()
	self:UpdateAnchors()
	self:CreateOptions()
	self:UpdateScrollBar()
     
	hooksecurefunc("CompactUnitFrame_UpdateAll", function(frame)
		if frame:IsForbidden() then return end	    	
		local name = frame:GetName()
		if not name or not name:match("^Compact") or not db.attach then return end
		self:LoadPositions()
		self:UpdateAnchors()
	end)
	self:SetScript("OnUpdate",ATT_OnUpdate)

	print("Arena Team Tracker by |cff33ff99Izy|r. Type |cffFF4500/att|r to open options.")
end

function ATT:FindAbilityIcon(ability, id)
	local icon;
	if id then
		icon = GetSpellTexture(id)
	else
		icon = GetSpellTexture(self:FindAbilityID(ability))
	end
	return icon
end

function ATT:FindAbilityID(ability)
	for _,S in pairs(SPELLDB) do
		for _,v in pairs(S) do
			for _,sp in pairs(v) do
				for _,SPELLID in pairs(sp) do
					local spellName, spellRank, spellIcon = GetSpellInfo(SPELLID)
					if(spellName == ability) then
						return SPELLID
					end
				end
			end
		end
	end
end

function ATT:FormatAbility(s)
--[[locale = GetLocale();
    if (GetLocale() == "enGB") or (GetLocale() == "enUS") then
	s = s:gsub("(%a)(%a*)('*)(%a*)", function (a,b,c,d) return a:upper()..b:lower()..c..d:lower() end)
	return s 
	else 
--]]return s
--	end
end

-------------------------------------------------------------
-- Options Panel
-------------------------------------------------------------

local SO = LibStub("LibSimpleOptions-1.01")

local function CreateListButton(parent,index)
	local button = CreateFrame("Button",parent:GetName()..index,parent)
	button:SetWidth(158)
	button:SetHeight(16)
	local font = CreateFont("ATTListFont")
	font:SetFont(GameFontNormal:GetFont(),12)
	font:SetJustifyH("LEFT")
	button:SetNormalFontObject(font)
	button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight","ADD")
	button:SetScript("OnClick",function(self) parent.currentButton = self:GetText(); ATT:UpdateScrollBar() end)
	return button
end

local function CreateEditBox(name,parent,width,height)
	local editbox = CreateFrame("EditBox",parent:GetName()..name,parent,"InputBoxTemplate")
	editbox:SetHeight(height)
	editbox:SetWidth(width)
	editbox:SetAutoFocus(false)	
	local label = editbox:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
	label:SetText(name)
	label:SetPoint("BOTTOMLEFT", editbox, "TOPLEFT",-3,0)
	return editbox
end

function ATT:CreateOptions()
	local panel = SO.AddOptionsPanel("ATT", function() end)
	self.panel = panel
	SO.AddSlashCommand("ATT","/att")
	local title, subText = panel:MakeTitleTextAndSubText("Arena Team Tracker","General settings")
	local scale = panel:MakeSlider(
	     'name', 'Scale',
	     'description', 'Adjust the scale of icons',
	     'minText', '0.1',
	     'maxText', '5',
	     'minValue', 0.1,
	     'maxValue', 5,
	     'step', 0.05,
	     'default', 1,
	     'current', db.scale,
	     'setFunc', function(value) db.scale = value; ATT:ApplyAnchorSettings() end,
	     'currentTextFunc', function(value) return string.format("%.2f",value) end)
	scale:SetPoint("TOPLEFT",subText,"TOPLEFT",16,-32)

	local attach = panel:MakeToggle(
	     'name', 'Attach raid frames',
	     'description', 'Attach to Blizzard raid frames',
	     'default', false,
	     'getFunc', function() return db.attach end,
	     'setFunc', function(value) db.attach = value; ATT:LoadPositions(); ATT:ApplyAnchorSettings() end)
	attach:SetPoint("TOPLEFT",scale,"TOPLEFT", 0, -32)
	
		local tworows = panel:MakeToggle(
	     'name', 'Use two rows',
	     'description', 'Show icons on 2 rows',
	     'default', false,
	     'getFunc', function() return db.tworows end,
	     'setFunc', function(value) db.tworows = value; ATT:LoadPositions();ATT:ApplyAnchorSettings() end)
	tworows:SetPoint("TOPLEFT",scale,"TOPLEFT",150,-32)
	
	local offsetX = CreateEditBox("Offset X", panel, 50, 25)
	offsetX:SetText(db.offsetX or "0")
	offsetX:SetCursorPosition(0)
	offsetX:SetPoint("TOPLEFT", attach, "TOPLEFT", 0, -40)
	offsetX:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
		local num = self:GetText():match("%-?%d+$")
		if num then
			print("Offset X changed and saved: " .. tostring(num))
			db.offsetX = num
			ATT:LoadPositions(); ATT:ApplyAnchorSettings();
		else
			print("Wrong value for Offset X/Y")
			self:SetText(db.offsetX)
		end
	end)
	panel.offsetX = offsetX

	local offsetY = CreateEditBox("Offset Y", panel, 50, 25)
	offsetY:SetText(db.offsetY or "0")
	offsetY:SetCursorPosition(0)
	offsetY:SetPoint("LEFT", offsetX, "RIGHT", 10, 0)

	offsetY:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
		local num = self:GetText():match("%-?%d+$")
		if num then
			print("Offset Y changed and saved: " .. tostring(num))
			db.offsetY = num
			ATT:LoadPositions(); ATT:ApplyAnchorSettings();
		else
			print("Wrong value for Offset X/Y")
			self:SetText(db.offsetY)
		end
	end)
	panel.offsetY = offsetY

	local iconOffsetX = CreateEditBox("Icon Offset X", panel, 50, 25)
	iconOffsetX:SetText(db.iconOffsetX or "0")
	iconOffsetX:SetCursorPosition(0)
	iconOffsetX:SetPoint("LEFT", offsetY, "RIGHT", 10, 0)
	iconOffsetX:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
		local num = self:GetText():match("%-?%d+$")
		if num then
			print("Icon Offset X changed and saved: " .. tostring(num))
			db.iconOffsetX = num
			ATT:LoadPositions(); ATT:ApplyAnchorSettings();
		else
			print("Wrong value for Icon Offset X")
			self:SetText(db.iconOffsetX)
		end
	end)
	panel.iconOffsetX = iconOffsetX

   local offsetdesc =  panel:CreateFontString(nil,nil ,"GameFontNormalSmall")
	offsetdesc:SetText("-input offset value then press ENTER");
	offsetdesc:SetJustifyH("LEFT")
	offsetdesc:SetWidth(100)
	offsetdesc:SetHeight(100)
	offsetdesc:SetPoint("TOPLEFT",scale,"BOTTOMLEFT",0,-40)
	offsetdesc:SetPoint("RIGHT", -32, 0)
	
	local lock = panel:MakeToggle(
	     'name', 'Lock',
	     'description', 'Show/hide anchors',
	     'default', false,
	     'getFunc', function() return db.lock end,
	     'setFunc', function(value) db.lock = value; ATT:ApplyAnchorSettings() end)
	lock:SetPoint("TOP",panel,"TOP",10,-38)
	
	local arena = panel:MakeToggle(
	     'name', 'Arena',
	     'description', 'Show in arena only',
	     'default', false,
	     'getFunc', function() return db.arena end,
	     'setFunc', function(value) db.arena = value;ATT:LoadPositions(); ATT:ApplyAnchorSettings() end)
	arena:SetPoint("TOP",lock,"BOTTOM",0,-5)

	local hidden = panel:MakeToggle(
	     'name', 'Hidden',
	     'description', 'Show icon only when on cooldown',
	     'default', false,
	     'getFunc', function() return db.hidden end,
	     'setFunc', function(value) db.hidden = value;ATT:LoadPositions(); ATT:ApplyAnchorSettings() end)
	hidden:SetPoint("TOP",arena,"BOTTOM",0,-5)
	
	local dampening = panel:MakeToggle(
	     'name', 'Dampening',
	     'description', 'Show dampening under the remaining time',
	     'default', false,
	     'getFunc', function() return db.dampening end,
	     'setFunc', function(value) db.dampening = value; ATT:ApplyAnchorSettings() end)
	dampening:SetPoint("TOP",arena,"BOTTOM",0,-35)
	
		local arenanumber = panel:MakeToggle(
	     'name', 'Arena Number',
	     'description', 'Show arena number over enemy nameplates',
	     'default', false,
	     'getFunc', function() return db.arenanumber end,
	     'setFunc', function(value) db.arenanumber = value; ATT:ApplyAnchorSettings() end)
	arenanumber:SetPoint("TOP",arena,"BOTTOM",0,-65)

	local growLeft = panel:MakeToggle(
	     'name', 'Grow Left',
	     'description', 'Grow ability bars to the left',
	     'default', false,
	     'getFunc', function() return db.growLeft end,
	     'setFunc', function(value) db.growLeft = value; ATT:LoadPositions(); ATT:ApplyAnchorSettings() end)
	growLeft:SetPoint("LEFT",lock,"RIGHT",90,0)

	local showTrinket = panel:MakeToggle(
	     'name', 'Show PvP Trinket',
	     'description', 'Show PvP Trinket cooldown',
	     'default', false,
	     'getFunc', function() return db.showTrinket end,
	     'setFunc', function(value) db.showTrinket = value; ATT:LoadPositions();ATT:ApplyAnchorSettings(); ATT:UpdateAnchors() end)
	showTrinket:SetPoint("TOP",growLeft,"BOTTOM",0,-5)

	local showSelf = panel:MakeToggle(
	     'name', 'Show Self',
	     'description', 'Show self cooldowns',
	     'default', false,
	     'getFunc', function() return db.showSelf end,
	     'setFunc', function(value) db.showSelf = value; ATT:LoadPositions(); ATT:ApplyAnchorSettings(); ATT:UpdateAnchors() end)
	showSelf:SetPoint("TOP",showTrinket,"BOTTOM",0,-5)

	local showTooltip = panel:MakeToggle(
	     'name', 'Show Tooltip',
	     'description', 'Show spell tooltips when possible',
	     'default', false,
	     'getFunc', function() return db.showTooltip end,
	     'setFunc', function(value) db.showTooltip = value; end)
	showTooltip:SetPoint("TOP",showSelf,"BOTTOM",0,-5)

	local showIconBorders = panel:MakeToggle(
	     'name', 'Draw borders for icons',
	     'description', 'Draw borders for cooldown icons',
	     'default', false,
	     'getFunc', function() return db.showIconBorders end,
	     'setFunc', function(value) db.showIconBorders = value; ATT:UpdateAnchors() end)
	showIconBorders:SetPoint("TOP",showTooltip,"BOTTOM",0,-5)
	
	local title2, subText2 = panel:MakeTitleTextAndSubText("Ability editor","Change what party member abilities are tracked")
	title2:ClearAllPoints()
	title2:SetPoint("LEFT",panel,"LEFT",16,80)
	subText2:ClearAllPoints()
	subText2:SetPoint("TOPLEFT",title2,"BOTTOMLEFT",0,-8)
	self:CreateAbilityEditor()
end

local function count(t) local i = 0 for k,v in pairs(t) do i = i + 1  end return i end

function ATT:UpdateScrollBar()
	local btns = self.btns
	local scrollframe = self.scrollframe
	local classSelectedSpecs = db.abilities[db.classSelected] 
	local line = 1
	
	for specID, abilities in pairs(classSelectedSpecs) do
		for abilityIndex, abilityTable in pairs(abilities) do
			local ability, id, cooldown, maxcharges, talent = abilityTable.ability, abilityTable.id, abilityTable.cooldown, abilityTable.maxcharges, abilityTable.talent
			    btns[line]:SetText(" ["..specID.."]" ..ability)
			if btns[line]:GetText() ~= scrollframe.currentButton then
				btns[line]:SetNormalTexture("")
			else 
				btns[line]:SetNormalTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
				btns[line]:GetNormalTexture():SetBlendMode("ADD") 
				scrollframe.addeditbox:SetText(ability)
				scrollframe.ideditbox:SetText(id or "")
				scrollframe.cdeditbox:SetText(cooldown or "")
		     -- scrollframe.specbox:SetText(specID or "")
				scrollframe.maxchargeseditbox:SetText(maxcharges or "")
	     		scrollframe.dropdown2.initialize()
	     		scrollframe.dropdown2:SetValue(tostring(specID))
			end 
			
			btns[line]:Show()
			line = line + 1
		end 
	end 			
	 for i=line,25 do btns[i]:Hide() end
end

function ATT:CreateAbilityEditor()
	local panel = self.panel
	local btns = {}
	self.btns = btns
	local scrollframe = CreateFrame("ScrollFrame", "ATTScrollFrame",panel,"UIPanelScrollFrameTemplate")
	    local backdrop = {
		bgFile = [=[Interface\Buttons\WHITE8X8]=],
		insets = { left = 0, right = 0, top = -5, bottom = -5 },
	}
	scrollframe:SetBackdrop(backdrop)
	scrollframe:SetBackdropColor(0,0,0,0.50)
	local child = CreateFrame("ScrollFrame" ,"ATTScrollFrame" , scrollframe )
	child:SetSize(1, 1)
	scrollframe:SetScrollChild(child)
	local button1 = CreateListButton(child,"25")
	button1:SetPoint("TOPLEFT",child,"TOPLEFT",11,0)
	btns[#btns+1] = button1
	for i=2,25 do
		local button = CreateListButton(child,tostring(i))
		button:SetPoint("TOPLEFT",btns[#btns],"BOTTOMLEFT")
		btns[#btns+1] = button
	end
	
	self.scrollframe = child
	scrollframe:SetWidth(175); 
	scrollframe:SetHeight(175)
	scrollframe:SetPoint('LEFT',16,-45)
	scrollframe.dropdown2 = nil
   
	local dropdown = panel:MakeDropDown(
       'name', ' Class',
	     'description', 'Pick a class to edit the ability list',
	     'values', {
		     		"WARRIOR", "Warrior",
					"DEATHKNIGHT", "Deathknight",
					"PALADIN", "Paladin",
					"PRIEST", "Priest",
					"SHAMAN", "Shaman",
					"DRUID", "Druid",
					"ROGUE", "Rogue",
					"MAGE", "Mage",
					"WARLOCK", "Warlock",
					"HUNTER", "Hunter",
					"MONK", "Monk",
					"DEMONHUNTER", "Demon Hunter",
	      },
	     'default', 'WARRIOR',
	     'getFunc', function() return db.classSelected end ,
	     'setFunc', function(value)
	     	db.classSelected = value; ATT:UpdateScrollBar();
	     	child.dropdown2.values = { "ALL", "All Specs" }
	     	for i=1, GetNumClasses() do
	     		local className, classTag, classID = GetClassInfo(i)
	     		if classTag == db.classSelected then
	     			for j=1, GetNumSpecializationsForClassID(classID) do
	     				local specID, specName = GetSpecializationInfoForClassID(classID, j)
	     				child.dropdown2.values[#child.dropdown2.values+1] = tostring(specID)
	     				child.dropdown2.values[#child.dropdown2.values+1] = specName
	     			end
	     			break
	     		end
	     	end
	     	child.dropdown2.initialize()
	     	child.dropdown2:SetValue("ALL")
	     end)
	dropdown:SetPoint("TOPLEFT",scrollframe,"TOPRIGHT",20,-8)
	child.dropdown = dropdown

	local dropdown2 = panel:MakeDropDown(
       'name', ' Specialization [ID]',
	     'description', 'Pick a spec',
	     'values', {
		     		"ALL", "All Specs",
					"71", "Arms",
					"72", "Fury",
					"73", "Protection",
	      },
	     'default', 'ALL',
	     'current', 'ALL',
	     'setFunc', function(value) end)
	dropdown2:SetPoint("TOPLEFT",dropdown,"BOTTOMLEFT",0,-15)
	child.dropdown2 = dropdown2
	
	local addeditbox = CreateEditBox("Ability name",scrollframe,130,25)
	child.addeditbox = addeditbox
	addeditbox:SetPoint("TOPLEFT",dropdown2,"BOTTOMLEFT",20,-15)

	local ideditbox = CreateEditBox("Spell ID",scrollframe,60,25)
	ideditbox:SetPoint("LEFT",addeditbox,"RIGHT",15,0)
	child.ideditbox = ideditbox

	local cdeditbox = CreateEditBox("CD (s)",scrollframe,40,25)
	cdeditbox:SetPoint("LEFT",ideditbox,"RIGHT",15,0)
	child.cdeditbox = cdeditbox

	local maxchargeseditbox = CreateEditBox("Charges",scrollframe,40,25)
	maxchargeseditbox:SetPoint("LEFT",cdeditbox,"RIGHT",15,0)
	child.maxchargeseditbox = maxchargeseditbox

	local addbutton = panel:MakeButton(
	     'name', 'Add/Edit',
	     'description', "Add a new ability with a specified cooldown  |cffFF4500(case sensitive)|r",
	     'func', function() 
	     		local id = ideditbox:GetText():match("^[0-9]+$")
	     		local spec = dropdown2.value
	     		local ability = ATT:FormatAbility(addeditbox:GetText())
	     		local iconfound = ATT:FindAbilityIcon(ability, id)
	     		local cdtext = cdeditbox:GetText():match("^[0-9]+$")
	     		local maxcharges = maxchargeseditbox:GetText():match("^[0-9]+$")
	     	    chargedeny = tonumber(maxcharges)
	     		if iconfound and cdtext and (not spec or db.abilities[db.classSelected] and db.abilities[db.classSelected][spec]) and (chargedeny == 2 or chargedeny == nil) then
	     			print("Added/updated "..ability)
	     			local abilities = db.abilities[db.classSelected][spec or "ALL"]
	     			local _ability, _index = self:FindAbilityByName(abilities, ability)
	     			if _ability and _index then
	     				-- editing:
	     				abilities[_index] = {ability = ability, cooldown = tonumber(cdtext), id = tonumber(id), maxcharges = maxcharges and maxcharges ~= "" and tonumber(maxcharges) or nil}
	     			else
	     				-- adding new:
	     				table.insert(abilities, {ability = ability, cooldown = tonumber(cdtext), id = tonumber(id), maxcharges = maxcharges and maxcharges ~= "" and tonumber(maxcharges) or nil})
	     			end
	     			child.currentButton = ability
	     			ATT:UpdateScrollBar()
	     			ATT:UpdateAnchors()
	     		else
	     			print("Invalid spell spec/name/cooldown or charges(can be |cff33ff99blank or 2|r)")
	     		end
	      end
	)
	addbutton:SetPoint("TOPLEFT",addeditbox,"BOTTOMLEFT",-5,0)
	
	local removebutton = panel:MakeButton(
	     'name', 'Remove',
	     'description', 'Remove the selected ability',
	     'func', function()
	     		 print("Removed " .. addeditbox:GetText())
	     		 local spec = dropdown2.value
	     		 local _ability, _index = self:FindAbilityByName(db.abilities[db.classSelected][spec or "ALL"], addeditbox:GetText())
	     		 if _ability and _index then table.remove(db.abilities[db.classSelected][spec], _index) end

	     		 addeditbox:SetText(""); 
	     		 ideditbox:SetText("");
	     		 cdeditbox:SetText(""); 
	     		 maxchargeseditbox:SetText("");
	     		 child.currentButton = nil; 
	     		 ATT:UpdateScrollBar(); 
	     		 ATT:UpdateAnchors() 
	     end
	)
	removebutton:SetPoint("TOPLEFT",addbutton,"BOTTOMLEFT",0,-5)
	
	local description =  panel:CreateFontString(nil,"ARTWORK","GameFontNormal")
    description:SetText("Add[remove] abilities that you want to track - input correct Ability name + Spell ID + CD. \r\nSpell [Charges] can |cffFF4500ONLY|r be <|cffFF4500blank|r> or <|cffFF45002|r>. More info on < curseforge > addon page.\r\n \r\n")
	description:SetJustifyH("LEFT")
    description:SetPoint("TOPLEFT",scrollframe,"BOTTOMLEFT",10,-10)
	
    local authordesc =  panel:CreateFontString(nil,"ARTWORK","GameFontDisable")
    authordesc:SetText("If you want to help with future development any support or feedback is greatly appreciated.\r\nYou can find and support me at: < |cff33ff99http://www.twitch.tv/imedia|r > or < |cff33ff99curseforge|r >.  Enjoy! \r\n  \r\n  |cffffff00Version:|r |cff33ff99v4.1|r")
   	authordesc:SetJustifyH("LEFT")
    authordesc:SetPoint("TOPLEFT",scrollframe,"BOTTOMLEFT",10,-80)
	authordesc:SetPoint("RIGHT", -12, 0)
end

ATT:RegisterEvent("VARIABLES_LOADED")
ATT:SetScript("OnEvent",ATT_OnLoad)