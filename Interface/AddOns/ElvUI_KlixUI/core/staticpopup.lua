local KUI, E, L, V, P, G = unpack(select(2, ...))

-- Bug Report
E.PopupDialogs["BUG_REPORT"] = {
	text = KUI:cOption(L["Bug Report"]),
	button1 = OKAY,
	hasEditBox = 1,
	OnShow = function(self, data)
		self.editBox:SetAutoFocus(false)
		self.editBox.width = self.editBox:GetWidth()
		self.editBox:Width(280)
		self.editBox:AddHistoryLine("text")
		self.editBox.temptxt = data
		self.editBox:SetText(data)
		self.editBox:HighlightText()
		self.editBox:SetJustifyH("CENTER")
	end,
	OnHide = function(self)
		self.editBox:Width(self.editBox.width or 50)
		self.editBox.width = nil
		self.temptxt = nil
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	EditBoxOnTextChanged = function(self)
		if(self:GetText() ~= self.temptxt) then
			self:SetText(self.temptxt)
		end
		self:HighlightText()
		self:ClearFocus()
	end,
	OnAccept = E.noop,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
	hideOnEscape = 1,
}

-- Discord
E.PopupDialogs["DISCORD"] = {
	text = KUI:cOption(L["Join Discord"]),
	button1 = OKAY,
	hasEditBox = 1,
	OnShow = function(self, data)
		self.editBox:SetAutoFocus(false)
		self.editBox.width = self.editBox:GetWidth()
		self.editBox:Width(280)
		self.editBox:AddHistoryLine("text")
		self.editBox.temptxt = data
		self.editBox:SetText(data)
		self.editBox:HighlightText()
		self.editBox:SetJustifyH("CENTER")
	end,
	OnHide = function(self)
		self.editBox:Width(self.editBox.width or 50)
		self.editBox.width = nil
		self.temptxt = nil
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	EditBoxOnTextChanged = function(self)
		if(self:GetText() ~= self.temptxt) then
			self:SetText(self.temptxt)
		end
		self:HighlightText()
		self:ClearFocus()
	end,
	OnAccept = E.noop,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
	hideOnEscape = 1,
}

-- ElvUI Versions check
E.PopupDialogs["VERSION_MISMATCH"] = {
	text = KUI:MismatchText(),
	button1 = CLOSE,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
}

-- Gold clear popup
E.PopupDialogs['KUI_CONFIRM_DELETE_CURRENCY_CHARACTER'] = {
	button1 = YES,
	button2 = NO,
	OnCancel = E.noop;
}

-- KlixUI Credits
E.PopupDialogs["KLIXUI_CREDITS"] = {
	text = KUI.Title,
	button1 = OKAY,
	hasEditBox = 1,
	OnShow = function(self, data)
		self.editBox:SetAutoFocus(false)
		self.editBox.width = self.editBox:GetWidth()
		self.editBox:Width(280)
		self.editBox:AddHistoryLine("text")
		self.editBox.temptxt = data
		self.editBox:SetText(data)
		self.editBox:HighlightText()
		self.editBox:SetJustifyH("CENTER")
	end,
	OnHide = function(self)
		self.editBox:Width(self.editBox.width or 50)
		self.editBox.width = nil
		self.temptxt = nil
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	EditBoxOnTextChanged = function(self)
		if(self:GetText() ~= self.temptxt) then
			self:SetText(self.temptxt)
		end
		self:HighlightText()
		self:ClearFocus()
	end,
	OnAccept = E.noop,
	timeout = 0,
	whileDead = 1,
	preferredIndex = 3,
	hideOnEscape = 1,
}

--Incompatibility messages
E.PopupDialogs["KUI_INCOMPATIBLE_ADDON"] = {
	text = gsub(L["INCOMPATIBLE_ADDON"], "ElvUI", "KlixUI"),
	OnAccept = function(self) DisableAddOn(E.PopupDialogs["KUI_INCOMPATIBLE_ADDON"].addon); ReloadUI(); end,
	OnCancel = function(self) E.PopupDialogs["KUI_INCOMPATIBLE_ADDON"].optiontable[E.PopupDialogs["KUI_INCOMPATIBLE_ADDON"].value] = false; ReloadUI(); end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs["LOCPLUS_KUI_INCOMPATIBLE"] = {
	text = L["You have got ElvUI Location Plus and |cfff960d9KlixUI|r both enabled at the same time. Select an addon to disable."],
	OnAccept = function() DisableAddOn("ElvUI_LocPlus"); ReloadUI() end,
	OnCancel = function() DisableAddOn("ElvUI_KlixUI"); ReloadUI() end,
	button1 = "Location Plus",
	button2 = "KlixUI",
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
}

E.PopupDialogs["LOCLITE_KUI_INCOMPATIBLE"] = {
	text = L["You have got ElvUI Location Lite and |cfff960d9KlixUI|r both enabled at the same time. Select an addon to disable."],
	OnAccept = function() DisableAddOn("ElvUI_LocLite"); ReloadUI() end,
	OnCancel = function() DisableAddOn("ElvUI_KlixUI"); ReloadUI() end,
	button1 = "Location Lite",
	button2 = "KlixUI",
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
}

-- Profile Creation
function KUI:NewProfile(new)
	if (new) then
		E.PopupDialogs["KLIXUI_CREATE_PROFILE_NEW"] = {
			text = KUI:cOption(L["Name for the new profile"]),
			button1 = OKAY,
			button2 = CANCEL,
			hasEditBox = 1,
			whileDead = 1,
			hideOnEscape = 1,
			timeout = 0,
			OnShow = function(self, data)
				self.editBox:SetAutoFocus(false)
				self.editBox.width = self.editBox:GetWidth()
				self.editBox:Width(280)
				self.editBox:AddHistoryLine("text")
				self.editBox.temptxt = data
				self.editBox:SetText("KlixUI")
				self.editBox:HighlightText()
				self.editBox:SetJustifyH("CENTER")
			end,
			OnHide = function(self)
				self.editBox:Width(self.editBox.width or 50)
				self.editBox.width = nil
				self.temptxt = nil
			end,
			OnAccept = function(self, data, data2)
				local text = self.editBox:GetText()
				ElvUI[1].data:SetProfile(text)
				PluginInstallStepComplete.message = KUI.Title.."Profile Created"
				PluginInstallStepComplete:Show()
			end
			}
		E:StaticPopup_Show("KLIXUI_CREATE_PROFILE_NEW")
	else
		E.PopupDialogs["KLIXUI_PROFILE_OVERRIDE"] = {
			text = KUI:cOption(L["Are you sure you want to override the current profile?"]),
			button1 = YES,
			button2 = NO,
			OnAccept = function()
				PluginInstallStepComplete.message = KUI.Title..L["Profile Set"]
				PluginInstallStepComplete:Show()
			end,
			timeout = 0,
			whileDead = true,
			hideOnEscape = true,
		}
		E:StaticPopup_Show("KLIXUI_PROFILE_OVERRIDE")
	end
end