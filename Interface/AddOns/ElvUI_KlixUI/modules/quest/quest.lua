local KUI, E, L, V, P, G = unpack(select(2, ...))
local KQ = KUI:NewModule("KuiQuest", "AceEvent-3.0")
KQ.modName = L["Quest"]

-- Cache global variables
local _G = _G
local select, type, tostring, tonumber = select, type, tostring, tonumber
local find, gsub = string.find, gsub
-- WoW API / Variables
local QuestFlagsPVP = QuestFlagsPVP
local GetNumActiveQuests = GetNumActiveQuests
local GetNumAvailableQuests = GetNumAvailableQuests
local GetGossipAvailableQuests = GetGossipAvailableQuests
local AcceptQuest = AcceptQuest
local ConfirmAcceptQuest = ConfirmAcceptQuest
local CompleteQuest = CompleteQuest
local GetNumQuestChoices = GetNumQuestChoices
local IsModifierKeyDown = IsModifierKeyDown
local UnitGUID = UnitGUID

-- Global variables that we don"t cache, list them here for the mikk"s Find Globals script
-- GLOBALS: QuestInfo_GetRewardButton, QuestInfoItemHighlight

function KQ:CheckConfigs()
    if UnitInRaid("player") and ( not KQ.db.inraid ) then return end

	if IsModifierKeyDown() then
		if ( KQ.db.diskey == 1 ) and IsAltKeyDown() then return
        elseif ( KQ.db.diskey == 2 ) and IsControlKeyDown() then return
        elseif ( KQ.db.diskey == 3 ) and IsShiftKeyDown() then return end
    end
	
	if (UnitGUID("target") and string.find(UnitGUID("target"), "(.*)-(.*)")) then
		local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-",UnitGUID("target"))
		if (npc_id and ((tonumber(npc_id) == 141584) or (tonumber(npc_id) == 142063)) -- Seal of Wartron (BfA)
			or (tonumber(npc_id) == 111243) -- Seal of Broken Fate (Legion)
			or ((tonumber(npc_id) == 87391) or (tonumber(npc_id) == 88570) or (tonumber(npc_id) == 96130)) -- Seal of Inevitable Fate + Seal of Tempered Fate (WoD)
			or ((tonumber(npc_id) == 64029) or (tonumber(npc_id) == 63996)) -- Warforged Seals (MoP)
			or (tonumber(npc_id) == 73305)) -- Mogu Rune of Fate (MoP)
		then
			return
		end
	end
	
    return true
end

function KQ:CheckQuestData()
    if KQ.db.dailiesonly then return end
    if QuestFlagsPVP() and ( not KQ.db.pvp ) then return end

    return true
end

function KQ:QUEST_GREETING()
    if KQ:CheckConfigs() and KQ.db.greeting then
        local numact,numava = GetNumActiveQuests(), GetNumAvailableQuests()
        if numact+numava == 0 then return end

        if numava > 0 then
            SelectAvailableQuest(1)
        end
        if numact > 0 then
            SelectActiveQuest(1)
        end
    end
end

function KQ:GOSSIP_SHOW()
    if KQ:CheckConfigs() and KQ.db.greeting then
        if GetGossipAvailableQuests() then
            SelectGossipAvailableQuest(1)
        elseif GetGossipActiveQuests() then
            SelectGossipActiveQuest(1)
        end
    end
end

function KQ:QUEST_DETAIL()
    --if IsQuestIgnored() then
        --return
    --end

    if KQ:CheckConfigs() and KQ:CheckQuestData() and KQ.db.accept then
        AcceptQuest()
    end
end

function KQ:QUEST_ACCEPT_CONFIRM()
    if KQ:CheckConfigs() and KQ.db.escort then
        ConfirmAcceptQuest()
    end
end

function KQ:QUEST_PROGRESS()
    if KQ:CheckConfigs() and KQ.db.complete then
        CompleteQuest()
    end
end

local dbg = 0;
function KQ:SelectQuestReward(index)
	local frame = QuestInfoFrame.rewardsFrame;
	
	if dbg == 1 then
		KUI:Print("index: "..index)
	end

	local button = QuestInfo_GetRewardButton(frame, index)
	if (button.type == "choice") then
		QuestInfoItemHighlight:ClearAllPoints()
		QuestInfoItemHighlight:SetOutside(button.Icon)

		if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.quest ~= true then
			QuestInfoItemHighlight:SetPoint("TOPLEFT", button, "TOPLEFT", -8, 7);
		else
			button.Name:SetTextColor(1, 1, 0)
		end
		QuestInfoItemHighlight:Show()

		-- set choice
		QuestInfoFrame.itemChoice = button:GetID()
	end
end

function KQ:QUEST_COMPLETE()
    if KQ:CheckConfigs() and KQ.db.complete then
        if GetNumQuestChoices() == 0 then
            GetQuestReward(QuestFrameRewardPanel.itemChoice)
        elseif GetNumQuestChoices() == 1 and QuestFrameRewardPanel.itemChoice == nil then
            GetQuestReward(1)
        end
    end
	
	if KQ.db.reward then
		local choice, highest = 1, 0
		local num = GetNumQuestChoices()

		if dbg == 1 then
			KUI:Print("GetNumQuestChoices"..num)
		end
		
		if num <= 0 then return end -- no choices

		for index = 1, num do
			local link = GetQuestItemLink("choice", index);
			if link then
				local price = select(11, GetItemInfo(link))
				if price and price > highest then
					highest = price
					choice = index
				end
			end
		end
		if dbg == 1 then
			KUI:Print("Choice: "..choice)
		end
		KQ:SelectQuestReward(choice)
	end
end

function KQ:UI_INFO_MESSAGE(event, id, msg)
	if (msg ~= nil) then
		if (E.db.KlixUI.quest.announce.enable) then
			local questText = gsub(msg, "(.*):%s*([-%d]+)%s*/%s*([-%d]+)%s*$", "%1", 1)
			
			KQ:SendDebugMsg("Quest Text: "..questText)
			
			if (questText ~= msg) then
				local ii, jj, strItemName, iNumItems, iNumNeeded = string.find(msg, "(.*):%s*([-%d]+)%s*/%s*([-%d]+)%s*$")
				local stillNeeded = iNumNeeded - iNumItems
                
				KQ:SendDebugMsg("Item Name: "..strItemName.." :: Num Items: "..iNumItems.." :: Num Needed: "..iNumNeeded.." :: Still Need: "..stillNeeded)

				if(stillNeeded == 0 and KQ.db.announce.every == 0) then
					KQ:SendMsg(L["Completed: "]..msg)
				elseif(KQ.db.announce.every > 0) then
					local every = math.fmod(iNumItems, KQ.db.announce.every)
					KQ:SendDebugMsg("Every fMod: "..every)
				
					if(every == 0 and stillNeeded > 0) then
						KQ:SendMsg(L["Progress: "]..msg)
					elseif(stillNeeded == 0) then
						KQ:SendMsg(L["Completed: "]..msg)
					end
				end
			end
		end
	end
end

function KQ:SendDebugMsg(msg)
	if(msg ~= nil and E.db.KlixUI.quest.announce.debug) then
		KUI:Print("Quest Announce Debug: "..msg)
	end
end

function KQ:SendMsg(msg)	
	local announceIn = E.db.KlixUI.quest.announce.In
	local announceTo = E.db.KlixUI.quest.announce.To

	if (msg ~= nil and E.db.KlixUI.quest.announce.enable) then
		if(announceTo.chatFrame) then
			if(announceIn.say) then
				SendChatMessage(msg, "SAY")
				KQ:SendDebugMsg("KQ:SendMsg(SAY) :: "..msg)
			end
		
			if(announceIn.party) then
				if(IsInGroup() and GetNumSubgroupMembers(LE_PARTY_CATEGORY_HOME) > 0) then
					SendChatMessage(msg, "PARTY")
				end
				
				KQ:SendDebugMsg("KQ:SendMsg(PARTY) :: "..msg)
			end				
		
			if(announceIn.instance) then
				if (IsInInstance() and GetNumSubgroupMembers(LE_PARTY_CATEGORY_INSTANCE) > 0) then
					SendChatMessage(msg, "INSTANCE_CHAT")
				end
				
				KQ:SendDebugMsg("KQ:SendMsg(INSTANCE) :: "..msg)
			end				
		
			if(announceIn.guild) then
				if(IsInGuild()) then
					SendChatMessage(msg, "GUILD")
				end
				
				KQ:SendDebugMsg("KQ:SendMsg(GUILD) :: "..msg)
			end
			
			if(announceIn.officer) then
				if(IsInGuild()) then
					SendChatMessage(msg, "OFFICER")
				end
				
				KQ:SendDebugMsg("KQ:SendMsg(OFFICER) :: "..msg)
			end			
				
			if(announceIn.whisper) then
				local who = announceIn.whisperWho
				if(who ~= nil and who ~= "") then
					SendChatMessage(msg, "WHISPER", nil, who)
					KQ:SendDebugMsg("KQ:SendMsg(WHISPER) :: "..who.."-"..msg)
				end
			end
		end
		
		if(announceTo.raidWarningFrame) then
			RaidNotice_AddMessage(RaidWarningFrame, msg, ChatTypeInfo["RAID_WARNING"])
		end
		
		if(announceTo.uiErrorsFrame) then
			UIErrorsFrame:AddMessage(msg, 1.0, 1.0, 0.0, 7)
		end
		
		if(E.db.KlixUI.quest.announce.sound) then
			PlaySound(PlaySoundKitID and "RAID_WARNING" or 8959)
		end
	end
	
	KQ:SendDebugMsg("KQ:SendMsg - "..msg)
end

function KQ:Initialize()

	KQ.db = E.db.KlixUI.quest

	if E.db.KlixUI.quest.enable then
		self:CheckConfigs()
		self:CheckQuestData()
		
		self:RegisterEvent("QUEST_GREETING")
		self:RegisterEvent("GOSSIP_SHOW")
		self:RegisterEvent("QUEST_DETAIL")
		self:RegisterEvent("QUEST_ACCEPT_CONFIRM")
		self:RegisterEvent("QUEST_PROGRESS")
		self:RegisterEvent("QUEST_COMPLETE")
	end
	
	if E.db.KlixUI.quest.announce.enable then
		self:RegisterEvent("UI_INFO_MESSAGE")
	end
	
	function KQ:ForUpdateAll()
		KQ.db = E.db.KlixUI.quest
	end
end

local function InitializeCallback()
	KQ:Initialize()
end

KUI:RegisterModule(KQ:GetName(), InitializeCallback)