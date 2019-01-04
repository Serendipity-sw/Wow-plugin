local KUI, E, L, V, P, G = unpack(select(2, ...))
local KBL = KUI:NewModule("KuiBloodLust", "AceEvent-3.0")

-- Cache global variables
-- Lua functions

-- Global variables that we don"t cache, list them here for the mikk"s Find Globals script
-- GLOBALS:

local Faction = {
	["HORDE"] = "Horde",
	["ALLIANCE"] = "Alliance",
	["ILLIDAN"] = "Illidan",
	["CUSTOM"] = CUSTOM,
}

local Drums = {
	[146555] = true, 	-- Drums of Rage (MoP)
	[178207] = true, 	-- Drums of Fury (WoD)
	[230935] = true, 	-- Drums of the Mountain (Legion)
	[256740] = true, 	-- Drums of the Maelstrom (BfA)
}

local Bloodlust = {
	[2825] = true, 		-- Bloodlust (Horde Shaman)
	[32182] = true, 	-- Heroism (Alliance Shaman)
	[80353] = true, 	-- Time Warp (Mage)
	[272678] = true, 	-- Primal Rage (Hunter, cast by command pet)
}

local PetBL = {
	[264667] = true, 	-- Primal Rage (Hunter, cast from pet spellbook)
}

local scanTool = CreateFrame( "GameTooltip", "ScanTooltip", nil, "GameTooltipTemplate" )
scanTool:SetOwner( WorldFrame, "ANCHOR_NONE" )
local scanText = _G["ScanTooltipTextLeft2"]

local function getPetOwner(sourceName)
	scanTool:ClearLines()
	scanTool:SetUnit(sourceName)
	local ownerText = scanText:GetText()
	if not ownerText then return sourceName end
	local owner, _ = string.split("-'",ownerText)
	return owner
end

function KBL:PLAYER_REGEN_DISABLED()
    KBL:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function KBL:COMBAT_LOG_EVENT_UNFILTERED()
if not E.db.KlixUI.misc.bloodlust.enable then return end
    local _, event, _, _, sourceName, _, _, _, destName, _, _, spellID, _ = CombatLogGetCurrentEventInfo()
    if KBL.db.sound and event == "SPELL_AURA_APPLIED" and (destName == UnitName("player")) and (Drums[spellID] or Bloodlust[spellID] or PetBL[spellID]) then
        if Drums[spellID] then
            KBL:PlayCustomSound()
        elseif Bloodlust[spellID] then
            KBL:PlayCustomSound()
        elseif PetBL[spellID] then
            KBL:PlayCustomSound()
        end
	end
	
	if KBL.db.text and event == "SPELL_CAST_SUCCESS" and GetNumGroupMembers() > 0 and (Drums[spellID] or Bloodlust[spellID] or PetBL[spellID]) and (UnitPlayerOrPetInParty(sourceName) or UnitPlayerOrPetInRaid(sourceName)) then
		local chatType = "PARTY"
		local isInstance, instanceType = IsInInstance()
		if isInstance and IsInGroup(LE_PARTY_CATEGORY_INSTANCE) or instanceType == "pvp" then
			chatType = "INSTANCE_CHAT"
		elseif IsInRaid() then
			chatType = "RAID"
		end
		if Drums[spellID] then
			SendChatMessage("BL/Hero used by: " .. UnitName(sourceName) .. " " .. GetSpellLink(spellID) .. " (25% haste)",chatType)
		elseif Bloodlust[spellID] then
			SendChatMessage("BL/Hero used by: " .. UnitName(sourceName) .. " " .. GetSpellLink(spellID) .. " (30% haste)",chatType)
		elseif PetBL[spellID] then
			SendChatMessage("BL/Hero used by: " .. getPetOwner(sourceName) .. " " .. GetSpellLink(spellID) .. " (30% haste)",chatType)
		end
	end
end

function KBL:PLAYER_REGEN_ENABLED()
	KBL:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
end

function KBL:PlayCustomSound()
	local channelVar;
	if KBL.db.SoundOverride then
		channelVar = "Master"
	else
		channelVar = "SFX"
	end
	if KBL.db.UseCustomVolume then
		if KBL.db.CustomVolume then
			local cvar = "Sound_"..channelVar.."Volume"
			local origVolume = GetCVar(cvar);
			SetCVar(cvar, KBL.db.CustomVolume/100)
			if KBL.db.faction == "HORDE" then
				PlaySoundFile("Interface\\AddOns\\ElvUI_KlixUI\\media\\sounds\\bloodlust.mp3", channelVar);
			elseif KBL.db.faction == "ALLIANCE" then
				PlaySoundFile("Interface\\AddOns\\ElvUI_KlixUI\\media\\sounds\\heroism.mp3", channelVar);
			elseif KBL.db.faction == "ILLIDAN" then
				PlaySoundFile("Interface\\AddOns\\ElvUI_KlixUI\\media\\sounds\\illidan.mp3", channelVar);
			elseif KBL.db.faction == "CUSTOM" and KBL.db.customSound then
				PlaySoundFile(KBL.db.customSound, channelVar);
			end
			-- A bit of a hack. There doesn't appear to be an event indicating the end of a sound, so
			-- this might not work well for all sounds.
			C_Timer.After(3.5, function() SetCVar(cvar,origVolume) end);
		else
			if KBL.db.faction == "HORDE" then
				PlaySoundFile("Interface\\AddOns\\ElvUI_KlixUI\\media\\sounds\\bloodlust.mp3", channelVar);
			elseif KBL.db.faction == "ALLIANCE" then
				PlaySoundFile("Interface\\AddOns\\ElvUI_KlixUI\\media\\sounds\\heroism.mp3", channelVar);
			elseif KBL.db.faction == "ILLIDAN" then
				PlaySoundFile("Interface\\AddOns\\ElvUI_KlixUI\\media\\sounds\\illidan.mp3", channelVar);
			elseif KBL.db.faction == "CUSTOM" and KBL.db.customSound then
				PlaySoundFile(KBL.db.customSound, channelVar);
			end
		end
	else
		if KBL.db.faction == "HORDE" then
			PlaySoundFile("Interface\\AddOns\\ElvUI_KlixUI\\media\\sounds\\bloodlust.mp3", channelVar);
		elseif KBL.db.faction == "ALLIANCE" then
			PlaySoundFile("Interface\\AddOns\\ElvUI_KlixUI\\media\\sounds\\heroism.mp3", channelVar);
		elseif KBL.db.faction == "ILLIDAN" then
			PlaySoundFile("Interface\\AddOns\\ElvUI_KlixUI\\media\\sounds\\illidan.mp3", channelVar);
		elseif KBL.db.faction == "CUSTOM" and KBL.db.customSound then
			PlaySoundFile(KBL.db.customSound, channelVar);
		end
	end
end

function KBL:Initialize()
if not E.db.KlixUI.misc.bloodlust.enable then return end
	KBL.db = E.db.KlixUI.misc.bloodlust
	
	KBL:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	KBL:RegisterEvent("PLAYER_REGEN_DISABLED")
    KBL:RegisterEvent("PLAYER_REGEN_ENABLED")
	
	function KBL:ForUpdateAll()
		KBL.db = E.db.KlixUI.misc.bloodlust
	end
end

KUI:RegisterModule(KBL:GetName())