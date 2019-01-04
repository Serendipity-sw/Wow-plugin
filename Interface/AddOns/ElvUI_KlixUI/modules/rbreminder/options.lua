local KUI, E, L, V, P, G = unpack(select(2, ...))
local RB = KUI:GetModule("KuiRaidBuffs")

--Cache global variables

--WoW API / Variables
local AGGRO_WARNING_IN_PARTY = AGGRO_WARNING_IN_PARTY
local CUSTOM, DEFAULT = CUSTOM, DEFAULT
--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS:

local function RaidBuffs()
	E.Options.args.KlixUI.args.modules.args.raidBuffs = {
		type = "group",
		name = RB.modName,
		order = 27,
		get = function(info) return E.db.KlixUI.raidBuffs[ info[#info] ] end,
		args = {
			name = {
				order = 1,
				type = "header",
				name = KUI:cOption(RB.modName),
			},
			rbreminder = {
				order = 2,
				type = "group",
				name = RB.modName,
				guiInline = true,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc = L["Shows a frame with flask/food/rune."],
						set = function(info, value) E.db.KlixUI.raidBuffs.enable = value; RB:Visibility() end,
					},
					space1 = {
						order = 2,
						type = 'description',
						name = "",
						hidden = function() return not E.db.KlixUI.raidBuffs.enable end,
					},
					space2 = {
						order = 3,
						type = 'description',
						name = "",
						hidden = function() return not E.db.KlixUI.raidBuffs.enable end,
					},
					backdrop = {
						type = 'toggle',
						order = 4,
						name = L["Backdrop"],
						desc = L["Toggles the display of the raidbuffs backdrop."],
						disabled = function() return not E.db.KlixUI.raidBuffs.enable end,
						hidden = function() return not E.db.KlixUI.raidBuffs.enable end,
						set = function(info, value) E.db.KlixUI.raidBuffs.backdrop = value; RB:Backdrop() end,
					},
					size = {
						order = 5,
						type = 'range',
						name = L["Size"],
						desc = L["Changes the size of the icons."],
						min = 10, max = 50, step = 1,
						disabled = function() return not E.db.KlixUI.raidBuffs.enable end,
						hidden = function() return not E.db.KlixUI.raidBuffs.enable end,
						set = function(info, value) E.db.KlixUI.raidBuffs.size = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					},
					alpha = {
						order = 6,
						type = "range",
						name = L["Alpha"],
						desc = L["Change the alpha level of the icons."],
						min = 0, max = 1, step = 0.1,
						disabled = function() return not E.db.KlixUI.raidBuffs.enable end,
						hidden = function() return not E.db.KlixUI.raidBuffs.enable end,
						set = function(info, value) E.db.KlixUI.raidBuffs.alpha = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					},
					class = {
						order = 7,
						type = "toggle",
						name = L["Class Specific Buffs"],
						desc = L["Shows all the class specific raidbuffs."],
						disabled = function() return not E.db.KlixUI.raidBuffs.enable end,
						hidden = function() return not E.db.KlixUI.raidBuffs.enable end,
						set = function(info, value) E.db.KlixUI.raidBuffs.class = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					},
					glow = {
						order = 8,
						type = "toggle",
						name = L["Glow"]..E.NewSign,
						desc = L["Shows the pixel glow on missing raidbuffs."],
						disabled = function() return not E.db.KlixUI.raidBuffs.enable end,
						hidden = function() return not E.db.KlixUI.raidBuffs.enable end,
						set = function(info, value) E.db.KlixUI.raidBuffs.glow = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					},
					visibility = {
						type = 'select',
						order = 9,
						name = L["Visibility"],
						disabled = function() return not E.db.KlixUI.raidBuffs.enable end,
						hidden = function() return not E.db.KlixUI.raidBuffs.enable end,
						set = function(info, value) E.db.KlixUI.raidBuffs.visibility = value; RB:Visibility() end,
						values = {
							["DEFAULT"] = DEFAULT,
							["INPARTY"] = AGGRO_WARNING_IN_PARTY,
							["ALWAYS"] = L["Always Display"],
							["CUSTOM"] = CUSTOM,
						},
					},
					customVisibility = {
						order = 15,
						type = 'input',
						width = 'full',
						name = L["Visibility State"],
						disabled = function() return E.db.KlixUI.raidBuffs.visibility ~= "CUSTOM" or not E.db.KlixUI.raidBuffs.enable end,
						hidden = function() return not E.db.KlixUI.raidBuffs.enable end,
						set = function(info, value) E.db.KlixUI.raidBuffs.customVisibility = value; RB:Visibility() end,
					},
				},
			},
		},
	}
end
tinsert(KUI.Config, RaidBuffs)