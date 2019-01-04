local KUI, E, L, V, P, G = unpack(select(2, ...))
local KM = KUI:NewModule("KuiMail", "AceEvent-3.0", "AceTimer-3.0")

local FakeEvent, NewMails, AtInbox
local LastAlert, StartDelay = 0
local AUCTION_OUTBID = ERR_AUCTION_OUTBID_S:gsub('%%s', '%.+')
local AUCTION_WON = ERR_AUCTION_WON_S:gsub('%%s', '%.+')
local GetTime = GetTime
local GetInboxNumItems = GetInboxNumItems
local HasNewMail = HasNewMail
local GetLatestThreeSenders = GetLatestThreeSenders
local GetInboxHeaderInfo = GetInboxHeaderInfo

function KM:UPDATE_PENDING_MAIL()
	StartDelay = GetTime() + 5
	GetLatestThreeSenders() -- Query the server
	MiniMapMailFrame:SetShown(HasNewMail()) -- Query the server

	KM:SetScript('OnUpdate', KM.Initialize)
	KM:SetNumMails()
end

function KM:MAIL_INBOX_UPDATE()
	local newMails = 0
	for i = 1, GetInboxNumItems() do
		if not select(9, GetInboxHeaderInfo(i)) then
			newMails = newMails + 1
		end
	end
	KM:SetNumMails(newMails)
	
	if not AtInbox then
		NewMails = KM:GetNumMails()
		AtInbox = true
	elseif KM:GetNumMails() ~= NewMails then
		FakeEvent = true
	end
end

function KM:MAIL_CLOSED()
	AtInbox = nil
end

function KM:PLAYER_ENTERING_WORLD()
	FakeEvent = true
end

function KM:CHAT_MSG_SYSTEM(message)
	if strmatch(message, AUCTION_OUTBID) then
		KM:UPDATE_PENDING_MAIL()
	elseif message == ERR_AUCTION_REMOVED or strmatch(message, AUCTION_WON) then
		FakeEvent = true
	end
end  

function KM:PLAYER_LOGOUT()
	local s1, s2, s3 = GetLatestThreeSenders()
	Mail_Senders = {
		[s1 or ''] = 1,
		[s2 or ''] = 2,
		[s3 or ''] = 3,
	}
end

function KM:AddNewMail(new)
	local time = GetTime()
	if new > 0 and time > LastAlert then
		if E.db.KlixUI.maps.minimap.mail.sound and not (E.db.KlixUI.notification.enable or not E.db.KlixUI.notification.mail or E.db.KlixUI.notification.noSound) then
			PlaySoundFile('Interface\\AddOns\\ElvUI_KlixUI\\media\\sounds\\yoda_message.mp3')
		end
		
		LastAlert = time + 15
	end

	KM:SetNumMails(KM:GetNumMails() + new)
end

function KM:SetNumMails(value)
	Mail_Count = max(value or Mail_Count or 0, HasNewMail() and 1 or 0 , select('#', GetLatestThreeSenders()))

	if GameTooltip:IsOwned(MiniMapMailFrame) then
		KM:UpdateTip()
	end
end

function KM:GetNumMails()
	return Mail_Count
end

function KM:OnEnter()
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
	KM:UpdateTip()
end

function KM:UpdateTip()
	local numMails = KM:GetNumMails()
	local senders = {GetLatestThreeSenders()}
	local title
	
	if numMails ~= 1 then
		title = L['You have about %s unread mails']
	else
		title = L['You have about %s unread mail']
	end
			
	if #senders > 0 then
		title = title .. L[' from:']
	end
	
	GameTooltip:SetText(format(title, numMails))
	
	for i,sender in pairs(senders) do
		GameTooltip:AddLine(' - ' .. sender, 1, 1, 1)
	end
	
	GameTooltip:Show()
end

-- Hide the mail icon from minimap
function KM:ToggleMailFrame()
	if E.db.KlixUI.maps.minimap.mail.hide then
		MiniMapMailFrame.Show = MiniMapMailFrame.Hide;
		MiniMapMailFrame:Hide();
	end
end

function KM:Initialize()
	if not E.db.KlixUI.maps.minimap.mail.enhanced then return end
	local StartDelay = 0
	local time = GetTime()
	if time > StartDelay then
		if HasNewMail() and not AtInbox then
			local newMails = 0
			for newI, sender in pairs({GetLatestThreeSenders()}) do
				local oldI, off = Mail_Senders[sender] or 0
				if newI >= oldI then
					off = newI - oldI
				else
					off = 3 - oldI + newI
				end
					
				newMails = max(newMails, off)
			end
			
			KM:AddNewMail(newMails)
		else
			KM:SetNumMails()
		end
		
	MiniMapMailFrame:SetScript('OnEnter', KM.OnEnter)
	
	Mail_Senders = Mail_Senders or {}
	Mail_Count = Mail_Count or 0
	
	KM:ToggleMailFrame()
	
	KM:RegisterEvent('UPDATE_PENDING_MAIL')
	KM:RegisterEvent('PLAYER_LOGOUT')
	KM:RegisterEvent('PLAYER_ENTERING_WORLD')
	KM:RegisterEvent('MAIL_INBOX_UPDATE')
	KM:RegisterEvent('CHAT_MSG_SYSTEM')
	KM:RegisterEvent('MAIL_CLOSED')
		
		function KM:UPDATE_PENDING_MAIL()
			MiniMapMailFrame:SetShown(HasNewMail())

			if FakeEvent or AtInbox then
				FakeEvent = nil
			elseif HasNewMail() then
				KM:AddNewMail(1)
			end
		end
	end
end

KUI:RegisterModule(KM:GetName())