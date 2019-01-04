local KUI, E, L, V, P, G = unpack(select(2, ...))
local THF = KUI:NewModule("TalkingHeadFrame", "AceEvent-3.0")

function THF:TALKINGHEAD_REQUESTED()
	local SFXCVar = GetCVar("Sound_EnableDialog")
	if SFXCVar == "1" then
		SetCVar("Sound_EnableDialog", 0);
	end

	if TalkingHeadFrame and TalkingHeadFrame:IsShown() then
		THF_TalkingHeadFrame_CloseImmediately()
		KUI:Print("TalkingHeadFrame closed.")
	else
		if TalkingHeadFrame then
			if not TalkingHeadFrame:IsShown() then
				if TalkingHeadFrame then
					if TalkingHeadFrame.voHandle then
						StopSound(TalkingHeadFrame.voHandle);
						TalkingHeadFrame.voHandle = nil;
					end
				end
				C_Timer.After(0.1, THF_TalkingHeadFrame_CloseImmediately)
			end
		end
	end
end

function THF_TalkingHeadFrame_CloseImmediately()
	local frame = TalkingHeadFrame;
	if ( frame and frame:IsShown() ) then
		if (frame.finishTimer) then
			frame.finishTimer:Cancel();
			frame.finishTimer = nil;
		end
		C_TalkingHead.IgnoreCurrentTalkingHead();
		frame:Hide();
		if ( frame.voHandle ) then
			StopSound(frame.voHandle);
			frame.voHandle = nil;
		end
		local SFXCVar = GetCVar("Sound_EnableDialog")
		if SFXCVar == "0" then
			C_Timer.After(3, function()
				SetCVar("Sound_EnableDialog", 1)
			end)
		end
	else
		C_Timer.After(0.1, function() THF_TalkingHeadFrame_CloseImmediately() end)
	end
end

function THF:Initialize()
	if not E.db.KlixUI.misc.talkingHead then return end
	
	THF:RegisterEvent("TALKINGHEAD_REQUESTED")
end

KUI:RegisterModule(THF:GetName())