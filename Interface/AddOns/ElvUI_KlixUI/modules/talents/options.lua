local KUI, E, L, V, P, G = unpack(select(2, ...))
local KBT = KUI:GetModule("KuiBetterTalents")

local function BetterTalentsTable()
	E.Options.args.KlixUI.args.modules.args.talents = {
		type = "group",
		name = L["Talents"]..E.NewSign,
		order = 28,
		args = {
			name = {
				order = 1,
				type = "header",
				name = KUI:cOption(L["Talents"]),
			},
			credits = {
				order = 2,
				type = "group",
				name = L["Credits"],
				guiInline = true,
				args = {
					tukui = {
						order = 1,
						type = "description",
						fontSize = "medium",
						name = format("|cfffe7b2cElvUI_BetterTalentsFrame (by Arwic)|r"),
					},
				},
			},
			gototalents = {
				order = 3,
				type = "execute",
				name = L["Toggle Talent Frame"],
				func = function() ToggleTalentFrame(); E:ToggleConfig() end,
			},
			space1 = {
				order = 4,
				type = "description",
				name = "",
			},
			space2 = {
				order = 5,
				type = "description",
				name = "",
			},
			enable = {
				order = 6,
				type = "toggle",
				name = L["Enable"],
				desc = L["Enable/disable the |cfff960d9KlixUI|r Better Talents Frame."],
				get = function(info) return E.db.KlixUI.talents.enable end,
				set = function(info, value) E.db.KlixUI.talents.enable = value; E:StaticPopup_Show("PRIVATE_RL"); end,
			},
			DefaultToTalentsTab = {
				order = 7,
				type = "toggle",
				name = L["Default to Talents Tab"],
				desc = L["Defaults to the talents tab of the talent frame on login. By default WoW shows you the specialization tab."],
				disabled = function() return not E.db.KlixUI.talents.enable end,
				get = function(info)
					return E.db.KlixUI.talents.DefaultToTalentsTab
				end,
				set = function(info, value)
					E.db.KlixUI.talents.DefaultToTalentsTab = value
				end,
			},
			AutoHidePvPTalents = {
				order = 8,
				type = "toggle",
				name = L["Auto Hide PvP Talents"],
				desc = L["Closes the PvP talents flyout on login. PvP talents and warmode flag are still accessible by manually opening the PvP talents flyout."],
				disabled = function() return not E.db.KlixUI.talents.enable end,
				get = function(info)
					return E.db.KlixUI.talents.AutoHidePvPTalents
				end,
				set = function(info, value)
					E.db.KlixUI.talents.AutoHidePvPTalents = value
				end,
			},
		},
	}
end
tinsert(KUI.Config, BetterTalentsTable)