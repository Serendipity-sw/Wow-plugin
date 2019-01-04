local KUI, E, L, V, P, G = unpack(select(2, ...))
local NF = KUI:GetModule("Notification")

--Cache global variables
local format = string.format
--WoW API / Variables

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: 

local function NotificationTable()
	E.Options.args.KlixUI.args.modules.args.notification = {
		type = "group",
		order = 21,
		name = NF.modName,
		get = function(info) return E.db.KlixUI.notification[ info[#info] ] end,
		set = function(info, value) E.db.KlixUI.notification[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
		args = {
			name = {
				order = 1,
				type = "header",
				name = KUI:cOption(NF.modName),
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
						name = format("|cffff7d0a MerathilisUI - Merathilis|r"),
					},
				},
			},
			general = {
				order = 3,
				type = "group",
				guiInline = true,
				name = L["General"],
				args = {
					desc = {
						order = 1,
						type = "description",
						fontSize = "small",
						name = L["Here you can enable/disable the different notification types."],
						disabled = function() return not E.db.KlixUI.notification.enable end,
						hidden = function() return not E.db.KlixUI.notification.enable end,
					},
					enable = {
						order = 2,
						type = "toggle",
						width = "full",
						name = L["Enable"],
					},
					raid = {
						order = 3,
						type = "toggle",
						name = L["Raid Disabler"],
						desc = L["Enable/disable the notification toasts while in a raid group."],
						disabled = function() return not E.db.KlixUI.notification.enable end,
						hidden = function() return not E.db.KlixUI.notification.enable end,
					},
					noSound = {
						order = 4,
						type = "toggle",
						name = L["No Sounds"],
						desc = L["Enable/disable the sound effect of the notification toasts."],
						disabled = function() return not E.db.KlixUI.notification.enable end,
						hidden = function() return not E.db.KlixUI.notification.enable end,
					},
					message = {
						order = 5,
						type = "toggle",
						name = L["Chat Message"]..E.NewSign,
						desc = L["Enable/disable the notification message in chat."],
						disabled = function() return not E.db.KlixUI.notification.enable end,
						hidden = function() return not E.db.KlixUI.notification.enable end,
					},
					mail = {
						order = 6,
						type = "toggle",
						name = L["Mail"],
						disabled = function() return not E.db.KlixUI.notification.enable end,
						hidden = function() return not E.db.KlixUI.notification.enable end,
					},
					vignette = {
						order = 7,
						type = "toggle",
						name = L["Vignette"],
						desc = L["If a Rare Mob or a treasure gets spotted on the minimap."],
						disabled = function() return not E.db.KlixUI.notification.enable end,
						hidden = function() return not E.db.KlixUI.notification.enable end,
					},
					invites = {
						order = 8,
						type = "toggle",
						name = L["Invites"],
						disabled = function() return not E.db.KlixUI.notification.enable end,
						hidden = function() return not E.db.KlixUI.notification.enable end,
					},
					guildEvents = {
						order = 9,
						type = "toggle",
						name = L["Guild Events"],
						disabled = function() return not E.db.KlixUI.notification.enable end,
						hidden = function() return not E.db.KlixUI.notification.enable end,
					},
					--[[quickJoin = {
						order = 10,
						type = "toggle",
						name = L["Quick Join Notification"],
						disabled = function() return not E.db.KlixUI.notification.enable end,
						hidden = function() return not E.db.KlixUI.notification.enable end,
					},]]
				},
			},
		},
	}
end
tinsert(KUI.Config, NotificationTable)