local KUI, E, L, V, P, G = unpack(select(2, ...))
local ElvUF = ElvUI.oUF
assert(ElvUF, "ElvUI was unable to locate oUF.")


--All credits belongs to Merathilis, Blazeflack and Rehok for this mod

-- Cache global variables
local abs = math.abs
local format, match, sub, gsub, len = string.format, string.match, string.sub, string.gsub, string.len
local assert, tonumber, type = assert, tonumber, type
-- WoW API / Variables
local UnitIsDead = UnitIsDead
local UnitClass = UnitClass
local UnitIsGhost = UnitIsGhost
local UnitIsConnected = UnitIsConnected
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local UnitName = UnitName
local UnitFactionGroup = UnitFactionGroup
local UnitPower = UnitPower
local IsResting = IsResting

-- GLOBALS: Hex, _COLORS

local textFormatStyles = {
	["CURRENT"] = "%.1f",
	["CURRENT_MAX"] = "%.1f - %.1f",
	["CURRENT_PERCENT"] =  "%.1f - %.1f%%",
	["CURRENT_MAX_PERCENT"] = "%.1f - %.1f | %.1f%%",
	["PERCENT"] = "%.1f%%",
	["DEFICIT"] = "-%.1f"
}

local textFormatStylesNoDecimal = {
	["CURRENT"] = "%s",
	["CURRENT_MAX"] = "%s - %s",
	["CURRENT_PERCENT"] =  "%s - %.0f%%",
	["CURRENT_MAX_PERCENT"] = "%s - %s | %.0f%%",
	["PERCENT"] = "%.0f%%",
	["DEFICIT"] = "-%s"
}

local shortenNumber = function(number)
    if type(number) ~= "number" then
        number = tonumber(number)
    end
    if not number then
        return
    end

    local affixes = {
        "",
        "k",
        "m",
        "b",
    }

    local affix = 1
    local dec = 0
    local num1 = math.abs(number)
    while num1 >= 1000 and affix < #affixes do
        num1 = num1 / 1000
        affix = affix + 1
    end
    if affix > 1 then
        dec = 2
        local num2 = num1
        while num2 >= 10 do
            num2 = num2 / 10
            dec = dec - 1
        end
    end
    if number < 0 then
        num1 = -num1
    end

    return string.format("%."..dec.."f"..affixes[affix], num1)
end


-- Displays CurrentHP | Percent --(2.04b | 100)--
_G["ElvUF"].Tags.Events['health:current-percent-kui'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
_G["ElvUF"].Tags.Methods['health:current-percent-kui'] = function(unit)
	local status = UnitIsDead(unit) and L["RIP"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
		if (status) then
			return status
		else
	local CurrentHealth = UnitHealth(unit)
	local CurrentPercent = (UnitHealth(unit)/UnitHealthMax(unit))*100
	if CurrentPercent > 99.9 then
		return shortenNumber(CurrentHealth) .. " | " .. format("%.0f%%", CurrentPercent)
	else
		return shortenNumber(CurrentHealth) .. " | " .. format("%.1f%%", CurrentPercent)
	end
	end
end

-- Displays CurrentHP | Percent --(2.04b | 100)--
_G["ElvUF"].Tags.Events['health:current-percent1-kui'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
_G["ElvUF"].Tags.Methods['health:current-percent1-kui'] = function(unit)
	local status = UnitIsDead(unit) and L["RIP"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]
		if (status) then
			return status
		else
	local CurrentHealth = UnitHealth(unit)
	local CurrentPercent = (UnitHealth(unit)/UnitHealthMax(unit))*100
	if CurrentPercent > 99.9 then
		return format("%.0f%%", CurrentPercent) .. " | " .. shortenNumber(CurrentHealth)
	else
		return format("%.1f%%", CurrentPercent) .. " | " .. shortenNumber(CurrentHealth)
	end
	end
end

-- Displays current HP --(2.04B, 2.04M, 204k, 204)--
_G["ElvUF"].Tags.Events['health:deficit-kui'] = 'UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED'
_G["ElvUF"].Tags.Methods['health:deficit-kui'] = function(unit)
	local status = UnitIsDead(unit) and L["RIP"] or UnitIsGhost(unit) and L["Ghost"] or not UnitIsConnected(unit) and L["Offline"]

	if (status) then
		return status
	else
		return E:GetFormattedText('DEFICIT', UnitHealth(unit), UnitHealthMax(unit))
	end
end

-- Displays current power and 0 when no power instead of hiding when at 0, Also formats it like HP tag
_G["ElvUF"].Tags.Events['power:current-kui'] = 'UNIT_DISPLAYPOWER UNIT_POWER_UPDATE UNIT_POWER_FREQUENT'
_G["ElvUF"].Tags.Methods['power:current-kui'] = function(unit)
	local CurrentPower = UnitPower(unit)
	return shortenNumber(CurrentPower)
end

 -- Displays Power Percent without any decimals
_G["ElvUF"].Tags.Events['power:percent-kui'] = 'UNIT_DISPLAYPOWER UNIT_POWER_UPDATE UNIT_POWER_FREQUENT'
_G["ElvUF"].Tags.Methods['power:percent-kui'] = function(unit)
local CurrentPercent = (UnitPower(unit)/UnitPowerMax(unit))*100
local min = UnitPower(unit, SPELL_POWER_MANA)
	if min == 0 then
		return nil
	else
		if CurrentPercent > 99.9 then
			return format("%.0f%%", CurrentPercent)
		else
			return format("%.0f%%", CurrentPercent)
		end
	end
end

 -- Displays long names better --(First Name Second Name Last Name = F.S Last Name)--
_G["ElvUF"].Tags.Methods['name:condensed-kui'] = function(unit)
	local name = UnitName(unit)
		name = name:gsub('(%S+) ',function(t) return t:sub(1,1)..'.' end)
    	return name
end