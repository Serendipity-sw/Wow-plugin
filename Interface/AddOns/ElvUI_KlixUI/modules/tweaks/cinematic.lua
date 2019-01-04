local KUI, E, L, V, P, G = unpack(select(2, ...))

--Cache global variables
--Lua functions
local _G = _G
local match = match
local tonumber = tonumber
--WoW API / Variables
local IsModifierKeyDown = IsModifierKeyDown

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS:

local f = CreateFrame("frame");
local moviePlayed = false;

CinematicFrame:HookScript("OnShow", function(self, ...)
  if IsModifierKeyDown() or E.global.KlixUI.cinematic.kill == false or IsAddOnLoaded("CinematicCanceler") then return end
  KUI:Print("Cinematic Canceled.")
  CinematicFrame_CancelCinematic()
end)

local omfpf = _G["MovieFrame_PlayMovie"]
_G["MovieFrame_PlayMovie"] = function(...)
  if IsModifierKeyDown() or E.global.KlixUI.cinematic.kill == false or IsAddOnLoaded("CinematicCanceler") then return omfpf(...) end
  KUI:Print("Movie Canceled.")
  GameMovieFinished()
  return true
end


local function eventhandler(self,event)
if E.global.KlixUI.cinematic.kill then return end
	
	if not GetCVarBool("Sound_EnableAllSound") then
		if (event=="CINEMATIC_START") and E.global.KlixUI.cinematic.enableSound then
			SetCVar("Sound_EnableAllSound", 1)
		elseif (event=="PLAY_MOVIE") and E.global.KlixUI.cinematic.enableSound then
			moviePlayed = true;
			SetCVar("Sound_EnableAllSound", 1)
		elseif(event=="CINEMATIC_STOP") and E.global.KlixUI.cinematic.enableSound then
			SetCVar("Sound_EnableAllSound", 0)
		elseif(event=="QUEST_COMPLETE") and E.global.KlixUI.cinematic.enableSound or E.global.KlixUI.cinematic.talkingheadSound then
			SetCVar("Sound_EnableAllSound", 0)
		elseif(event=="TALKINGHEAD_CLOSE") and E.global.KlixUI.cinematic.talkingheadSound and not E.db.KlixUI.misc.talkingHead then
			SetCVar("Sound_EnableAllSound", 0)
		elseif (event=="TALKINGHEAD_REQUESTED") and E.global.KlixUI.cinematic.talkingheadSound and not E.db.KlixUI.misc.talkingHead then
			SetCVar("Sound_EnableAllSound", 1)
		end
		
		hooksecurefunc(_G, "GameMovieFinished", function() if moviePlayed then SetCVar("Sound_EnableAllSound", 0) end moviePlayed = false end);
	end
end

f:RegisterEvent("CINEMATIC_START");
f:RegisterEvent("CINEMATIC_STOP");
f:RegisterEvent("PLAY_MOVIE");
f:RegisterEvent("QUEST_COMPLETE");
f:RegisterEvent("TALKINGHEAD_REQUESTED");
f:RegisterEvent("TALKINGHEAD_CLOSE");
f:SetScript("OnEvent",eventhandler);