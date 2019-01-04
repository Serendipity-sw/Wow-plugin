local KUI, E, L, V, P, G = unpack(select(2, ...))
local KT = KUI:NewModule('KuiThreat', 'AceHook-3.0');
local THREAT = E:GetModule('Threat');
local LO = E:GetModule('Layout');

-- GLOBALS: hooksecurefunc, ElvUI_ThreatBar, RightChatDataPanel, LeftChatDataPanel, BuiDummyChat, BuiDummyThreat

function KT:UpdateThreatPosition()
	local bar = ElvUI_ThreatBar
	bar:SetStatusBarTexture(E['media'].Klix)
	if E.db.general.threat.position == 'RIGHTCHAT' then
		if E.db.datatexts.rightChatPanel then
			bar:SetInside(RightChatDataPanel)
			bar:SetParent(RightChatDataPanel)
		else
			bar:SetInside(KuiDummyThreat)
			bar:SetParent(KuiDummyThreat)
		end
	else
		if E.db.datatexts.leftChatPanel then
			bar:SetInside(LeftChatDataPanel)
			bar:SetParent(LeftChatDataPanel)
		else
			bar:SetInside(KuiDummyChat)
			bar:SetParent(KuiDummyChat)
		end
	end
	bar:SetFrameStrata('MEDIUM')
end

function KT:Initialize()
	self:UpdateThreatPosition()
	hooksecurefunc(LO, 'ToggleChatPanels', KT.UpdateThreatPosition)
	hooksecurefunc(THREAT, 'UpdatePosition', KT.UpdateThreatPosition)
end

local function InitializeCallback()
	KT:Initialize()
end

KUI:RegisterModule(KT:GetName(), InitializeCallback)