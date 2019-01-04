local KUI, E, L, V, P, G = unpack(select(2, ...))
local RMA = KUI:GetModule("RaidMarkers")
local texPathAn = [[Interface\AddOns\ElvUI_KlixUI\media\textures\raidmarkers\anime\]]
local texPathAu = [[Interface\AddOns\ElvUI_KlixUI\media\textures\raidmarkers\aurora\]]
local texPathM = [[Interface\AddOns\ElvUI_KlixUI\media\textures\raidmarkers\myth\]]
local texPathC = [[Interface\TargetingFrame\]]

--Cache global variables
local _G = _G
local format = string.format
--WoW API / Variables
local CreateFrame = CreateFrame
local SHIFT_KEY, CTRL_KEY, ALT_KEY = SHIFT_KEY, CTRL_KEY, ALT_KEY
local AGGRO_WARNING_IN_PARTY = AGGRO_WARNING_IN_PARTY
local CUSTOM, DEFAULT = CUSTOM, DEFAULT
--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS:

local function RaidMarkers()
	E.Options.args.KlixUI.args.modules.args.raidmarkers = {
		type = "group",
		name = RMA.modName,
		order = 25,
		get = function(info) return E.db.KlixUI.raidmarkers[ info[#info] ] end,
		args = {
			name = {
				order = 1,
				type = "header",
				name = KUI:cOption(RMA.modName),
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
						name = format("|cffff7d0a MerathilisUI - Merathilis|r & |cff9482c9Shadow&Light - Darth Predator|r"),
					},
				},
			},
			marksheader = {
				order = 3,
				type = "group",
				name = RMA.modName or RMA:GetName(),
				guiInline = true,
				args = {
					info = {
						order = 1,
						type = "description",
						name = L["Options for panels providing fast access to raid markers and flares."],
						},
					enable = {
						order = 2,
						type = "toggle",
						name = L["Enable"],
						desc = L["Show/Hide raid marks."],
						set = function(info, value) E.db.KlixUI.raidmarkers.enable = value; RMA:Visibility() end,
					},
					reset = {
						order = 3,
						type = 'execute',
						name = L["Restore Defaults"],
						desc = L["Reset these options to defaults"],
						disabled = function() return not E.db.KlixUI.raidmarkers.enable end,
						hidden = function() return not E.db.KlixUI.raidmarkers.enable end,
						func = function() KUI:Reset("marks") end,
					},
					space1 = {
						order = 4,
						type = "description",
						name = "",
					},
					backdrop = {
						type = 'toggle',
						order = 5,
						name = L["Backdrop"],
						disabled = function() return not E.db.KlixUI.raidmarkers.enable end,
						hidden = function() return not E.db.KlixUI.raidmarkers.enable end,
						set = function(info, value) E.db.KlixUI.raidmarkers.backdrop = value; RMA:Backdrop() end,
					},
					buttonSize = {
						order = 6,
						type = 'range',
						name = L["Button Size"],
						min = 16, max = 40, step = 1,
						disabled = function() return not E.db.KlixUI.raidmarkers.enable end,
						hidden = function() return not E.db.KlixUI.raidmarkers.enable end,
						set = function(info, value) E.db.KlixUI.raidmarkers.buttonSize = value; RMA:UpdateBar() end,
					},
					spacing = {
						order = 7,
						type = 'range',
						name = L["Button Spacing"],
						min = -4, max = 10, step = 1,
						disabled = function() return not E.db.KlixUI.raidmarkers.enable end,
						hidden = function() return not E.db.KlixUI.raidmarkers.enable end,
						set = function(info, value) E.db.KlixUI.raidmarkers.spacing = value; RMA:UpdateBar() end,
					},
					orientation = {
						order = 8,
						type = 'select',
						name = L["Orientation"],
						disabled = function() return not E.db.KlixUI.raidmarkers.enable end,
						hidden = function() return not E.db.KlixUI.raidmarkers.enable end,
						set = function(info, value) E.db.KlixUI.raidmarkers.orientation = value; RMA:UpdateBar() end,
						values = {
							["HORIZONTAL"] = L["Horizontal"],
							["VERTICAL"] = L["Vertical"],
						},
					},
					reverse = {
						type = 'toggle',
						order = 9,
						name = L["Reverse"],
						disabled = function() return not E.db.KlixUI.raidmarkers.enable end,
						hidden = function() return not E.db.KlixUI.raidmarkers.enable end,
						set = function(info, value) E.db.KlixUI.raidmarkers.reverse = value; RMA:UpdateBar() end,
					},
					modifier = {
						order = 10,
						type = 'select',
						name = L["Modifier Key"],
						desc = L["Set the modifier key for placing world markers."],
						disabled = function() return not E.db.KlixUI.raidmarkers.enable end,
						hidden = function() return not E.db.KlixUI.raidmarkers.enable end,
						set = function(info, value) E.db.KlixUI.raidmarkers.modifier = value; RMA:UpdateWorldMarkersAndTooltips() end,
						values = {
							["shift-"] = SHIFT_KEY,
							["ctrl-"] = CTRL_KEY,
							["alt-"] = ALT_KEY,
						},
					},
					mouseover = {
						order = 11,
						type = "toggle",
						name = L["Mouseover"],
						disabled = function() return not E.db.KlixUI.raidmarkers.enable end,
						hidden = function() return not E.db.KlixUI.raidmarkers.enable end,
						set = function(info, value) E.db.KlixUI.raidmarkers.mouseover = value; RMA:UpdateMouseover() end,
					},
					notooltip = {
						order = 12,
						type = "toggle",
						name = L["No tooltips"],
						disabled = function() return not E.db.KlixUI.raidmarkers.enable end,
						hidden = function() return not E.db.KlixUI.raidmarkers.enable end,
						set = function(info, value) E.db.KlixUI.raidmarkers.notooltip = value; end,
					},
					raidicons = {
						order = 13,
						type = "select",
						name = L["Raid Marker Icons"],
						desc = L["Choose what Raid Marker Icon Set the bar will display."],
						get = function(info) return E.db.KlixUI.raidmarkers.raidicons end,
						set = function(info, value) E.db.KlixUI.raidmarkers.raidicons = value; E:StaticPopup_Show('PRIVATE_RL'); end,
						values = {
							["Classic"] = "Classic:  ".."|T"..texPathC.."UI-RaidTargetingIcon_8:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathC.."UI-RaidTargetingIcon_7:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathC.."UI-RaidTargetingIcon_6:15:15:0:0:64:64:2:56:2:56|t ",
							["Anime"] = "Anime:  ".."|T"..texPathAn.."UI-RaidTargetingIcon_8:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathAn.."UI-RaidTargetingIcon_7:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathAn.."UI-RaidTargetingIcon_6:15:15:0:0:64:64:2:56:2:56|t ",
							["Aurora"] = "Aurora:  ".."|T"..texPathAu.."UI-RaidTargetingIcon_8:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathAu.."UI-RaidTargetingIcon_7:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathAu.."UI-RaidTargetingIcon_6:15:15:0:0:64:64:2:56:2:56|t ",
							["Myth"] = "Myth:  ".."|T"..texPathM.."UI-RaidTargetingIcon_8:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathM.."UI-RaidTargetingIcon_7:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathM.."UI-RaidTargetingIcon_6:15:15:0:0:64:64:2:56:2:56|t ",
						},
					},
					visibility = {
						type = 'select',
						order = 14,
						name = L["Visibility"],
						disabled = function() return not E.db.KlixUI.raidmarkers.enable end,
						hidden = function() return not E.db.KlixUI.raidmarkers.enable end,
						set = function(info, value) E.db.KlixUI.raidmarkers.visibility = value; RMA:Visibility() end,
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
						disabled = function() return E.db.KlixUI.raidmarkers.visibility ~= "CUSTOM" or not E.db.KlixUI.raidmarkers.enable end,
						hidden = function() return not E.db.KlixUI.raidmarkers.enable end,
						set = function(info, value) E.db.KlixUI.raidmarkers.customVisibility = value; RMA:Visibility() end,
					},
				},
			},
			AutoMark = {
				order = 4,
				type = "group",
				name = L["Auto Mark"],
				guiInline = true,
				args = {
					automark = {
						order = 1,
						type = "toggle",
						name = L["Auto Mark"],
						desc = L["Enable/Disable auto mark of tanks and healers in dungeons."],
						disabled = function() return KUI._Compatibility["DejaAutoMark"] end,
						hidden = function() return KUI._Compatibility["DejaAutoMark"] end,
						set = function(info, value) E.db.KlixUI.raidmarkers.automark = value; RMA:AutoMark() end,
					},
					tankMark = {
						order = 2,
						type = "select",
						name = L["Tank Mark"],
						disabled = function() return KUI._Compatibility["DejaAutoMark"] or not E.db.KlixUI.raidmarkers.automark end,
						hidden = function() return KUI._Compatibility["DejaAutoMark"] end,
						set = function(info, value) E.db.KlixUI.raidmarkers.tankMark = value; RMA:AutoMark() end,
						values = {
							[1] = L["Star"],
							[2] = L["Circle"],
							[3] = L["Diamond"],
							[4] = L["Triangle"],
							[5] = L["Moon"],
							[6] = L["Square"],
							[7] = L["Cross"],
							[8] = L["Skull"],
						},
					},
					healerMark = {
						order = 3,
						type = "select",
						name = L["Healer Mark"],
						disabled = function() return KUI._Compatibility["DejaAutoMark"] or not E.db.KlixUI.raidmarkers.automark end,
						hidden = function() return KUI._Compatibility["DejaAutoMark"] end,
						set = function(info, value) E.db.KlixUI.raidmarkers.healerMark = value; RMA:AutoMark() end,
						values = {
							[1] = L["Star"],
							[2] = L["Circle"],
							[3] = L["Diamond"],
							[4] = L["Triangle"],
							[5] = L["Moon"],
							[6] = L["Square"],
							[7] = L["Cross"],
							[8] = L["Skull"],
						},
					},
				},
			},
		},
	}
end
tinsert(KUI.Config, RaidMarkers)