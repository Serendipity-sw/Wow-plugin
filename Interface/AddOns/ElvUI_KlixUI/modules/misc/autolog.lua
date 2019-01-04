local KUI, E, L, V, P, G = unpack(select(2, ...))
local AL = KUI:NewModule("AutoLog", "AceEvent-3.0", "AceTimer-3.0")

local LoggingCombat = LoggingCombat
local pairs, string, select, print, format = pairs, string, select, print, format
local GetBindingKey, SetBinding, IsInInstance = GetBindingKey, SetBinding, IsInInstance
local GetRaidDifficultyID, IsInRaid, IsPartyLFG = GetRaidDifficultyID, IsInRaid, IsPartyLFG
local IsInLFGDungeon, GetDungeonDifficultyID = IsInLFGDungeon, GetDungeonDifficultyID
local UIFrameFade = UIFrameFade

--map IDs
local map_id_list = {
	["42BWD"] = 285, ["45BTW"] = 294, ["46TFW"] = 328, ["41BAH"] = 282, ["44FIR"] = 367, ["43DGS"] = 409, ["52MGS"] = 471, 
	["53TES"] = 456, ["51HOF"] = 474, ["54TOT"] = 508, ["55SOO"] = 556, ["61BRF"] = 596, ["62HGM"] = 610, ["63HFC"] = 661,
	["71TEN"] = 777, ["72TNH"] = 764, ["73TOV"] = 806, ["74TOS"] = 850, ["75ABT"] = 909, ["81UDI"] = 1148
}

function AL:MakeList(raids)
	local list = {}
	local colours = {["4"] = "ff778899", ["5"] = "ff996633", ["6"] = "ff6e8b3d", ["7"] = "ffffd700", ["8"] = "ff80528C"}
	for _, r in pairs(raids) do 
		local exp = string.sub(r,1,1)
		--if not expsettings[exp] then
			local c = colours[exp]
			local tMap = C_Map.GetMapInfo(map_id_list[r])
			list[r] = "|c" .. c .. tMap["name"]
		--end
	end
	return list
end

function AL:getMythicLevelsList()
	local list = {}
	for l = 1, 11 do
		list[l] = l
	end
	return list
end

function AL:PLAYER_ENTERING_WORLD()
	if not AL.scheduled then AL:CheckLog() end
end

function AL:ZONE_CHANGED_NEW_AREA()
	if not AL.scheduled then AL:CheckLog() end
end

function AL:PLAYER_ALIVE()
	if not AL.scheduled then AL:CheckLog() end
end

function AL:PLAYER_UNGHOST()
	if not AL.scheduled then AL:CheckLog() end
end

function AL:ENCOUNTER_START()
	if not AL.scheduled then AL:CheckLog() end
end

function AL:RAID_INSTANCE_WELCOME()
	if not AL.scheduled then AL:CheckLog() end
end

function AL:ZONE_CHANGED_INDOORS()
	if not AL.scheduled then AL:CheckLog() end
end

function AL:ZONE_CHANGED()
	if not AL.scheduled then AL:CheckLog() end
end

function AL:GetKey()
	local k, v
	local rk = false
	local mid = 0
	local vMap = 0
	local midMap = 0
	
	if UnitIsVisible("player") then
		mid = C_Map.GetBestMapForUnit("player")
		if mid ~= nil then
			for k, v in pairs (map_id_list) do
				-- Check if map names match, as each level of a dungeon/raid has its own mapID but share same map name.
				vMap = C_Map.GetMapInfo(v)
				midMap = C_Map.GetMapInfo(mid)
				if v == mid then
					rk = k
					break
				elseif vMap["name"] == midMap["name"] then
					rk = k
					break
				end
			end
		end
	end
	return rk
end

function AL:IsInRaid()
	local isInstance, instanceType = IsInInstance()
	if isInstance and instanceType == "raid" then return true end
end

function AL:GetDifficulty() 
	local rd = GetRaidDifficultyID()
	if IsInRaid() then 
		if IsPartyLFG() and IsInLFGDungeon() then rd = 99 end
	else
		rd = GetDungeonDifficultyID()
		if rd ~= nil then rd = rd + 20 end		
	end
	return rd
end

function AL:CheckLog()
	if not AL.db.enable or AL.scheduled then return end
	AL.scheduled = true
	AL:ScheduleTimer(function() AL:SetLogging() end, 5)
end

function AL:SetLogging(override)
	local currentState = LoggingCombat()
	local difficulty = AL:GetDifficulty()
	if not difficulty and not override then return end
	local inInstance, instanceType = IsInInstance()
	local isDungeon = (instanceType == "party") and not C_Garrison:IsOnGarrisonMap()
	local raidKey, raidType
	local goLog = false
	local isMythicDungeon = (isDungeon and (difficulty == 43))
	raidKey = AL:GetKey()
	if raidKey then
		if difficulty == 14 then raidType = "normal"
		elseif difficulty == 15 then raidType = "heroic"
		elseif difficulty == 16 then raidType = "mythic"
		elseif difficulty == 8 then raidType = "challenge"
		elseif difficulty == 99 then raidType = "lfr" end
		--elseif difficulty == 7 then raidType = "lfr"
		raidType = raidType or "normal"
		if not inInstance then goLog = false
		elseif raidKey then goLog = AL.db[raidType][raidKey] end
	end
	if AL.db.allraids and AL:IsInRaid() then goLog = true end
	if AL.db.dungeons and isDungeon and (not isMythicDungeon) then goLog = true end
	if AL.db.mythicdungeons and isMythicDungeon then goLog = true end
	if AL.db.challenge and isDungeon and difficulty == 28 then
		local level = C_ChallengeMode.GetActiveKeystoneInfo()
		if level >= AL.db.mythiclevel then goLog = true end
	end
	if AL.db.challenge and isDungeon and difficulty == 28 then goLog = true end
	if override then goLog = not currentState end
	goLog = goLog or false
	if currentState ~= goLog then
		if goLog then
			AL.db.curLogging = LoggingCombat(true)
			if AL.db.curLogging then
				if AL.db.chatwarning then KUI:Print("|cff20ff20Combat logging turned on|r") end
			end
		elseif not goLog then
			AL.db.curLogging = LoggingCombat(false)
			if not AL.db.curLogging then
				if AL.db.chatwarning then KUI:Print("|cffff2020Combat logging turned off|r") end
			end
		end
	end
	AL.scheduled = false
end

function AL:GetSetting(settingtype, raid) return E.db.KlixUI.misc.autolog[settingtype][raid] end
function AL:SetSetting(settingtype, raid, settingvalue) E.db.KlixUI.misc.autolog[settingtype][raid] = settingvalue; AL:CheckLog() end

function AL:Initialize()
	if not E.db.KlixUI.misc.autolog.enable then return end
	AL.db = E.db.KlixUI.misc.autolog
	
	function AL:ForUpdateAll()
	end
	
	AL:RegisterEvent("PLAYER_ENTERING_WORLD")
	AL:RegisterEvent("PLAYER_ALIVE")
	AL:RegisterEvent("PLAYER_UNGHOST")
	AL:RegisterEvent("ENCOUNTER_START")
	AL:RegisterEvent("RAID_INSTANCE_WELCOME")
	AL:RegisterEvent("ZONE_CHANGED_INDOORS")
	AL:RegisterEvent("ZONE_CHANGED")
end

KUI:RegisterModule(AL:GetName())