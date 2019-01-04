local KUI, E, L, V, P, G = unpack(select(2, ...))
local KQ = KUI:GetModule("KuiQuest");
local SQT = KUI:GetModule("SmartQuestTracker");
local QT = KUI:GetModule("QuestTracker");

--Cache global variables
local format = string.format
--WoW API / Variables
local DEFAULT, MINIMIZE, HIDE = DEFAULT, MINIMIZE, HIDE
local QUESTS_LABEL = QUESTS_LABEL
local GARRISON_LOCATION_TOOLTIP = GARRISON_LOCATION_TOOLTIP
local BATTLEGROUNDS = BATTLEGROUNDS
local ARENA = ARENA
local DUNGEONS = DUNGEONS
local SCENARIOS = SCENARIOS
local RAIDS = RAIDS

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: 

local settings = {
	["FULL"] = DEFAULT,
	["COLLAPSED"] = MINIMIZE,
	["HIDE"] = HIDE,
}

local function QuestTable()
	E.Options.args.KlixUI.args.modules.args.quest = {
		type = "group",
		order = 23,
		name = KQ.modName,
		childGroups = "tab",
		get = function(info) return E.db.KlixUI.quest[ info[#info] ] end,
		set = function(info, value) E.db.KlixUI.quest[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
		args = {
			name = {
				order = 1,
				type = "header",
				name = KUI:cOption(KQ.modName),
			},
			general = {
				order = 2,
				type = "group",
				name = L["Auto Pilot"],
				args = {
					intro = {
						order = 1,
						type = 'description',
						name = L["This section enables auto accepting and auto finishing various quests."],
					},
					enable = {
						order = 2,
						type = "toggle",
						name = L["Enable"],
					},
					diskey = {
						order = 3,
						type = "select",
						name = L["Disable Key"],
						desc = L["When the specific key is down the quest automatization is disabled."],
						disabled = function() return not E.db.KlixUI.quest.enable end,
						values = { "Alt", "Ctrl", "Shift" },
					},
					space1 = {
						order = 4,
						type = 'description',
						name = '',
					},
					accept = {
						order = 5,
						type = "toggle",
						name = L["Auto Accept Quests"],
						desc = L["Enable/Disable auto quest accepting"],
						disabled = function() return not E.db.KlixUI.quest.enable end,
					},
					complete = {
						order = 6,
						type = "toggle",
						name = L["Auto Complete Quests"],
						desc = L["Enable/Disable auto quest complete"],
						disabled = function() return not E.db.KlixUI.quest.enable end,
					},
					dailiesonly = {
						order = 7,
						type = "toggle",
						name = L["Dailies Only"],
						desc = L["Enable/Disable auto accepting for daily quests only"],
						disabled = function() return not E.db.KlixUI.quest.enable end,
					},
					pvp = {
						order = 8,
						type = "toggle",
						name = L["Accept PVP Quests"],
						desc = L["Enable/Disable auto accepting for PvP flagging quests"],
						disabled = function() return not E.db.KlixUI.quest.enable end,
					},
					escort = {
						order = 9,
						type = "toggle",
						name = L["Auto Accept Escorts"],
						desc = L["Enable/Disable auto escort accepting"],
						disabled = function() return not E.db.KlixUI.quest.enable end,
					},
					inraid = {
						order = 10,
						type = "toggle",
						name = L["Enable in Raid"],
						desc = L["Enable/Disable auto accepting quests in raid"],
						disabled = function() return not E.db.KlixUI.quest.enable end,
					},
					greeting = {
						order = 11,
						type = "toggle",
						name = L["Skip Greetings"],
						desc = L["Enable/Disable NPC's greetings skip for one or more quests"],
						disabled = function() return not E.db.KlixUI.quest.enable end,
					},
					reward = {
						order = 12,
						type = "toggle",
						name = L["Auto Select Quest Reward"],
						desc = L["Automatically select the quest reward with the highest vendor sell value."],
						disabled = function() return not E.db.KlixUI.quest.enable end,
					},
				},
			},
			announce = {
				order = 3,
				type = "group",
				name = L["Quest Announce"],
				get = function(info)
					local key = info.arg or info[#info]
					KQ:SendDebugMsg("getSettings: "..key.." :: "..tostring(E.db.KlixUI.quest.announce[key]))
					return E.db.KlixUI.quest.announce[key]
				end,
				set = function(info, value)
					local key = info.arg or info[#info]
					E.db.KlixUI.quest.announce[key] = value
					KQ:SendDebugMsg("setSettings: "..key.." :: "..tostring(E.db.KlixUI.quest.announce[key]))
				end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
					},
					every = {
						order = 2,
						type = "range",
						name = L["Announce Every"],
						desc = L["Announce progression every x number of steps (0 will announce on quest objective completion only)"],
						min = 0,
						max = 10,
						step = 1,
						disabled = function() return not E.db.KlixUI.quest.announce.enable end,
					},
					sound = {
						order = 3,
						type = "toggle",
						name = L["Sound"],
						desc = L["Enable/disable the quest announce sound."],
						disabled = function() return not E.db.KlixUI.quest.announce.enable end,
					},
					debug = {
						order = 101,
						type = "toggle",
						name = L["Debug"],
						desc = L["Enable/disable the debug mode, for advanced users only!"],
						disabled = function() return not E.db.KlixUI.quest.announce.enable end,
					},
					test = {
						order = 102,
						type = "execute",
						name = L["Test Frame Messages"],
						func = function() KQ:SendMsg(L["Quest Announce Test Message"]) end,
						disabled = function() return not E.db.KlixUI.quest.announce.enable end,
					},
					To = {
						order = 4,
						type = "group",
						guiInline = true,
						name = L["Where do you want to make the announcements?"],
						disabled = function() return not E.db.KlixUI.quest.announce.enable end,
						get = function(info)
							local key = info.arg or info[#info]
							KQ:SendDebugMsg("getAnnounceTo: "..key.." :: "..tostring(E.db.KlixUI.quest.announce.To[key]))
							return E.db.KlixUI.quest.announce.To[key]
						end,
						set = function(info, value)
							local key = info.arg or info[#info]
							E.db.KlixUI.quest.announce.To[key] = value
							KQ:SendDebugMsg("setAnnounceTo: "..key.." :: "..tostring(E.db.KlixUI.quest.announce.To[key]))
						end,
						args = {
							chatFrame = {
								order = 1,
								type = "toggle",
								name = L["Chat Frame"],
							},
							raidWarningFrame = {
								order = 2,
								type = "toggle",
								name = L["Raid Warning Frame"],
							},
							uiErrorsFrame = {
								order = 3,
								type = "toggle",
								name = L["UI Errors Frame"],
							},
						},
					},
					In = {
						order = 5,
						type = "group",
						guiInline = true,
						name = L["What channels do you want to make the announcements?"],
						disabled = function() return not E.db.KlixUI.quest.announce.enable end,
						get = function(info)
							local key = info.arg or info[#info]
							KQ:SendDebugMsg("getAnnounceIn: "..key.." :: "..tostring(E.db.KlixUI.quest.announce.In[key]))
							return E.db.KlixUI.quest.announce.In[key]
						end,
						set = function(info, value)
							local key = info.arg or info[#info]
							E.db.KlixUI.quest.announce.In[key] = value
							KQ:SendDebugMsg("setAnnounceIn: "..key.." :: "..tostring(E.db.KlixUI.quest.announce.In[key]))
						end,
						args = {
							say = {
								order = 1,
								type = "toggle",
								name = L["Say"],
							},
							party = {
								order = 2,
								type = "toggle",
								name = L["Party"],
							},
							instance = {
								order = 3,
								type = "toggle",
								name = L["Instance"],
								confirm = function(info, value)
									return (value and L["Are you sure you want to announce to this channel?"] or false)
								end,								
							},								
							guild = {
								order = 4,
								type = "toggle",
								name = L["Guild"],
								confirm = function(info, value)
									return (value and L["Are you sure you want to announce to this channel?"] or false)
								end,							
							},
							officer = {
								order = 5,
								type = "toggle",
								name = L["Officer"],
								confirm = function(info, value)
									return (value and L["Are you sure you want to announce to this channel?"] or false)
								end,
							},
							whisper = {
								order = 6,
								type = "toggle",
								name = L["Whisper"],
								width = 'half',
								confirm = function(info, value)
									return (value and L["Are you sure you want to announce to this channel?"] or false)
								end,
							},
							whisperWho = {
								order = 7,
								type = "input",
								width = 'half',
								name = L["Whisper Who"],
							},
						},	
					},
				},
		    },
			smart = {
				type = "group",
				order = 4,
				name = L["Smart Quest Tracker"],
				get = function(info) return E.db.KlixUI.quest.smart[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.quest.smart[ info[#info] ] = value; SQT:Update() end,
				args = {
					intro = {
						order = 1,
						type = 'description',
						name = L["This section modify the ObjectiveTracker to only display your quests available for completion in your current zone."],
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
								name = format("|cffFF6A00SmartQuestTracker (by tyra314)|r"),
							},
						},
					},
					enable = {
						order = 3,
						type = "toggle",
						name = L["Enable"],
						set = function(info, value) E.db.KlixUI.quest.smart.enable = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					},
					clear = {
						order = 4,
						type = "group",
						name = L['Untrack quests when changing area'],
						guiInline = true,
						disabled = function() return not E.db.KlixUI.quest.smart.enable end,
						args = {
							removecomplete = {
								order = 1,
								type = "toggle",
								name = L["Completed quests"],
								get = function(info)
									return E.db.KlixUI.quest.smart.RemoveComplete
								end,
								set = function(info, value)
									E.db.KlixUI.quest.smart.RemoveComplete = value
									SQT:Update()
								end,
							},
							autoremove = {
								order = 2,
								type = "toggle",
								name = L["Quests from other areas"],
								get = function(info)
									return E.db.KlixUI.quest.smart.AutoRemove
								end,
								set = function(info, value)
									E.db.KlixUI.quest.smart.AutoRemove = value
									SQT:Update()
								end,
							},
							showDailies = {
								order = 3,
								type = "toggle",
								name = L["Keep daily and weekly quest tracked"],
								get = function(info)
									return E.db.KlixUI.quest.smart.ShowDailies
								end,
								set = function(info, value)
									E.db.KlixUI.quest.smart.ShowDailies = value
									SQT:Update()
								end,
							},
						},
					},
					sort = {
						order = 5,
						type = "group",
						name = L['Sorting of quests in tracker'],
						guiInline = true,
						disabled = function() return not E.db.KlixUI.quest.smart.enable end,
						args = {
							autosort = {
								order = 1,
								type = "toggle",
								name = L["Automatically sort quests"],
								get = function(info)
									return E.db.KlixUI.quest.smart.AutoSort
								end,
								set = function(info, value)
									E.db.KlixUI.quest.smart.AutoSort = value
									SQT:Update()
								end,
							},
						},
					},
					debug = {
						order = 6,
						type = "group",
						name = L["Debug"],
						guiInline = true,
						disabled = function() return not E.db.KlixUI.quest.smart.enable end,
						args = {
							print = {
								type = 'execute',
								order = 2,
								name = L["Print all quests to chat"],
								func = function() SQT:debugPrintQuestsHelper(false) end,
							},
							printWatched = {
								type = 'execute',
								order = 3,
								name = L["Print tracked quests to chat"],
								func = function() SQT:debugPrintQuestsHelper(true) end,
							},
							untrack = {
								type = 'execute',
								order = 1,
								name = L["Untrack all quests"],
								func = function() SQT:untrackAllQuests() end,
							},
							update = {
								type = 'execute',
								order = 4,
								name = L["Force update of tracked quests"],
								func = function() SQT:run_update() end,
							},
						},
					},
				},
			},
			tracker = {
				type = "group",
				order = 5,
				name = L["Quest Tracker Visibility"],
				get = function(info) return E.db.KlixUI.quest.visibility[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.quest.visibility[ info[#info] ] = value; QT:ChangeState() end,
				args = {
					intro = {
						order = 1,
						type = 'description',
						name = L["Adjust the settings for the visibility of the questtracker (questlog) to your personal preference."],
					},
					enable = {
						order = 2,
						type = "toggle",
						name = L["Enable"],
					},
					space1 = {
						order = 3,
						type = "description",
						name = "",
					},
					rested = {
						order = 4,
						type = "select",
						name = L["Rested"],
						disabled = function() return not E.db.KlixUI.quest.visibility.enable end,
						values = settings,
					},
					garrison = {
						order = 5,
						type = "select",
						name = GARRISON_LOCATION_TOOLTIP,
						disabled = function() return not E.db.KlixUI.quest.visibility.enable end,
						values = settings,
					},
					orderhall = {
						order = 6,
						type = "select",
						name = L["Class Hall"],
						disabled = function() return not E.db.KlixUI.quest.visibility.enable end,
						values = settings,
					},
					bg = {
						order = 7,
						type = "select",
						name = BATTLEGROUNDS,
						disabled = function() return not E.db.KlixUI.quest.visibility.enable end,
						values = settings,
					},
					arena = {
						order = 8,
						type = "select",
						name = ARENA,
						disabled = function() return not E.db.KlixUI.quest.visibility.enable end,
						values = settings,
					},
					dungeon = {
						order = 9,
						type = "select",
						name = DUNGEONS,
						disabled = function() return not E.db.KlixUI.quest.visibility.enable end,
						values = settings,
					},
					scenario = {
						order = 10,
						type = "select",
						name = SCENARIOS,
						disabled = function() return not E.db.KlixUI.quest.visibility.enable end,
						values = settings,
					},
					raid = {
						order = 11,
						type = "select",
						name = RAIDS,
						disabled = function() return not E.db.KlixUI.quest.visibility.enable end,
						values = settings,
					},
					combat = {
						order = 12,
						type = "select",
						name = COMBAT,
						disabled = function() return not E.db.KlixUI.quest.visibility.enable end,
						values = {
							["FULL"] = DEFAULT,
							["COLLAPSED"] = MINIMIZE,
							["HIDE"] = HIDE,
							["NONE"] = NONE,
						},
					},
				},	
			},
		},
	}
end
tinsert(KUI.Config, QuestTable)