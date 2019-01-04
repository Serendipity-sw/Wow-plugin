-- Credit: ElvUI Enhanced for this mod.
local KUI, E, L, V, P, G = unpack(select(2, ...))
local PI = KUI:NewModule("ProgressInfo", "AceHook-3.0", "AceEvent-3.0")
local KTT = KUI:GetModule('KuiTooltip')
local TT = E:GetModule('Tooltip')

-- Cache global variables
-- Lua functions
local _G = _G
local find = string.find
local format = string.format
local tinsert, twipe = table.insert, table.wipe
local pairs, select, tonumber, unpack, type = pairs, select, tonumber, unpack, type
local collectgarbage = collectgarbage
-- WoW API / Variables
local GetStatistic = GetStatistic
local GetComparisonStatistic = GetComparisonStatistic
local GetTime = GetTime
local GameTooltip = GameTooltip
local ClearAchievementComparisonUnit = ClearAchievementComparisonUnit
local InCombatLockdown = InCombatLockdown
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL
local utf8sub = string.utf8sub
local SetAchievementComparisonUnit = SetAchievementComparisonUnit
local HideUIPanel = HideUIPanel
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local CanInspect = CanInspect
local IsAddOnLoaded = IsAddOnLoaded
local GetMapNameByID = GetMapNameByID

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: 

PI.Cache = {}
PI.playerGUID = UnitGUID("player")
PI.highestKill = 0

PI.bosses = {
	{ -- Uldir
		{ -- Mythic
			12789, 12793, 12797, 12801, 12805, 12811, 12816, 12820,
		},
		{ -- Heroic
			12788, 12792, 12796, 12800, 12804, 12810, 12815, 12819,
		},
		{ -- Normal
			12787, 12791, 12795, 12799, 12803, 12809, 12814, 12818,
		},
		{ -- LFR
			12786, 12790, 12794, 12798, 12802, 12808, 12813, 12817,
		},
		"uldir",
	},
}

PI.Raids = {
	["LONG"] = {
		KUI:GetMapInfo(1148 , "name"),
	},
	["SHORT"] = {
		KUI:GetMapInfo(1148, "name"),
	},
}
PI.modes = { 
	["LONG"] = {
		PLAYER_DIFFICULTY6,
		PLAYER_DIFFICULTY2, 
		PLAYER_DIFFICULTY1,
		PLAYER_DIFFICULTY3,
	},
	["SHORT"] = {
		utf8sub(PLAYER_DIFFICULTY6, 1 , 1),
		utf8sub(PLAYER_DIFFICULTY2, 1 , 1),
		utf8sub(PLAYER_DIFFICULTY1, 1 , 1),
		utf8sub(PLAYER_DIFFICULTY3, 1 , 1),
	},
}

function PI:GetProgression(guid)
	local kills, complete, pos = 0, false, 0
	local statFunc = guid == PI.playerGUID and GetStatistic or GetComparisonStatistic
	
	for raid = 1, #PI.Raids["LONG"] do
		local option = PI.bosses[raid][5]
		if E.db.KlixUI.tooltip.progressInfo.raids[option] then
			PI.Cache[guid].header[raid] = {}
			PI.Cache[guid].info[raid] = {}
			for level = 1, 4 do
				PI.highestKill = 0
				for statInfo = 1, #PI.bosses[raid][level] do
					local bossTable =PI.bosses[raid][level][statInfo]
					kills = tonumber((statFunc(bossTable)))
					if kills and kills > 0 then
						PI.highestKill = PI.highestKill + 1
					end
				end
				pos = PI.highestKill
				if (PI.highestKill > 0) then
					PI.Cache[guid].header[raid][level] = format("%s [%s]:", PI.Raids[E.db.KlixUI.tooltip.progressInfo.NameStyle][raid], PI.modes[E.db.KlixUI.tooltip.progressInfo.DifStyle][level])
					PI.Cache[guid].info[raid][level] = format("%d/%d", PI.highestKill, #PI.bosses[raid][level])
					if PI.highestKill == #PI.bosses[raid][level] then
						break
					end
				end
			end
		end
	end	
end

function PI:UpdateProgression(guid)
	PI.Cache[guid] = PI.Cache[guid] or {}
	PI.Cache[guid].header = PI.Cache[guid].header or {}
	PI.Cache[guid].info =  PI.Cache[guid].info or {}
	PI.Cache[guid].timer = GetTime()

	PI:GetProgression(guid)
end

function PI:SetProgressionInfo(guid, tt)
	if PI.Cache[guid] and PI.Cache[guid].header then
		local updated = 0
		for i=1, tt:NumLines() do
			local leftTipText = _G["GameTooltipTextLeft"..i]
			for raid = 1, #PI.Raids["LONG"] do
				for level = 1, 4 do
					if (leftTipText:GetText() and leftTipText:GetText():find(PI.Raids[E.db.KlixUI.tooltip.progressInfo.NameStyle][raid]) and leftTipText:GetText():find(PI.modes[E.db.KlixUI.tooltip.progressInfo.DifStyle][level]) and (PI.Cache[guid].header[raid][level] and PI.Cache[guid].info[raid][level])) then
						-- update found tooltip text line
						local rightTipText = _G["GameTooltipTextRight"..i]
						leftTipText:SetText(PI.Cache[guid].header[raid][level])
						rightTipText:SetText(PI.Cache[guid].info[raid][level])
						updated = 1
					end
				end
			end
		end
		if updated == 1 then return end
		-- add progression tooltip line
		if PI.highestKill > 0 then tt:AddLine(" ") end
		for raid = 1, #PI.Raids["LONG"] do
			local option = PI.bosses[raid][5]
			if E.db.KlixUI.tooltip.progressInfo.raids[option] then
				for level = 1, 4 do
					tt:AddDoubleLine(PI.Cache[guid].header[raid][level], PI.Cache[guid].info[raid][level], nil, nil, nil, 1, 1, 1)
				end
			end
		end
	end
end

local function AchieveReady(event, GUID)
	if (TT.compareGUID ~= GUID) then return end
	local unit = "mouseover"
	if UnitExists(unit) then
		PI:UpdateProgression(GUID)
		_G["GameTooltip"]:SetUnit(unit)
	end
	ClearAchievementComparisonUnit()
	TT:UnregisterEvent("INSPECT_ACHIEVEMENT_READY")
end

local function OnInspectInfo(self, tt, unit, level, r, g, b, numTries)
	if InCombatLockdown() then return end
	if not E.db.KlixUI.tooltip.progressInfo.enable then return end
	if not (unit and CanInspect(unit)) then return end
	local level = UnitLevel(unit)
	if not level or level < MAX_PLAYER_LEVEL then return end
	
	local guid = UnitGUID(unit)
	if not PI.Cache[guid] or (GetTime() - PI.Cache[guid].timer) > 600 then
		if guid == PI.playerGUID then
			PI:UpdateProgression(guid)
		else
			ClearAchievementComparisonUnit()
			if not self.loadedComparison and select(2, IsAddOnLoaded("Blizzard_AchievementUI")) then
				AchievementFrame_DisplayComparison(unit)
				HideUIPanel(_G["AchievementFrame"])
				ClearAchievementComparisonUnit()
				self.loadedComparison = true
			end
			self.compareGUID = guid
			if SetAchievementComparisonUnit(unit) then
				self:RegisterEvent("INSPECT_ACHIEVEMENT_READY", AchieveReady)
			end
			return
		end
	end

	PI:SetProgressionInfo(guid, tt)
end

function PI:Initialize()
	hooksecurefunc(TT, 'ShowInspectInfo', OnInspectInfo) 
end

KUI:RegisterModule(PI:GetName())