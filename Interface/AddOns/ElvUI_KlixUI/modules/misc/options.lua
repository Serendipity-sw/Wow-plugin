local KUI, E, L, V, P, G = unpack(select(2, ...))
local MI = KUI:GetModule("KuiMisc")
local COMP = KUI:GetModule("KuiCompatibility")
local KZ = KUI:GetModule('KuiZoom')
local KAN = KUI:GetModule("KuiAnnounce")
local KBL = KUI:GetModule("KuiBloodLust")
local KEC = KUI:GetModule("KuiEasyCurve")
local THF = KUI:GetModule("TalkingHeadFrame")
local AL = KUI:GetModule("AutoLog")
local CSP = KUI:GetModule("ConfirmStaticPopups")
local SCRAP = KUI:GetModule("Scrapper")

--Cache global variables
local format = string.format
local match = string.match
local tinsert = table.insert
--WoW API / Variables
local CUSTOM = CUSTOM

local base = 15
local maxfactor = 2.6

local raid_lfr = {"43DGS", "52MGS", "53TES", "51HOF", "54TOT", "55SOO", "61BRF", "62HGM", "63HFC", "71TEN", "72TNH", "73TOV", "74TOS", "75ABT", "81UDI"}
local raid_normal = {"41BAH", "42BWD", "45BTW", "46TFW", "44FIR", "43DGS", "52MGS", "53TES", "51HOF", "54TOT", "55SOO", "61BRF", "62HGM", "63HFC", "71TEN", "72TNH", "73TOV", "74TOS", "75ABT", "81UDI"}
local raid_heroic = {"42BWD", "45BTW", "46TFW", "44FIR", "43DGS", "52MGS", "53TES", "51HOF", "54TOT", "55SOO", "61BRF", "62HGM", "63HFC", "71TEN", "72TNH", "73TOV", "74TOS", "75ABT", "81UDI"}
local raid_mythic = {"55SOO", "61BRF", "62HGM", "63HFC", "71TEN", "72TNH", "73TOV", "74TOS", "75ABT", "81UDI"}

local function PopupOptions()
	local args, index = {}, 1
	for key, val in CSP:orderedPairs(E.db.KlixUI.misc.popups) do -- put options sorted order by pop-up constant name
		args[key] = {
			order = index,
			type = "toggle",
			width = 1.5, 
			name = key,
			desc = _G[key],
			get = function(info) return E.db.KlixUI.misc.popups[ info[#info] ] end,
			set = function(info, value) E.db.KlixUI.misc.popups[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
		}
		index = index + 1
	end
	return args
end

local function Misc()
	E.Options.args.KlixUI.args.modules.args.misc = {
		order = 19,
		type = "group",
		name = L['Miscellaneous'],
		childGroups = 'tab',
		get = function(info) return E.db.KlixUI.misc[ info[#info] ] end,
		set = function(info, value) E.db.KlixUI.misc[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = KUI:cOption(L["Miscellaneous"]),
			},
			general = {
				order = 2,
				type = "group",
				name = L["General"],
				args = {
					gmotd = {
						order = 1,
						type = "toggle",
						name = GUILD_MOTD_LABEL2,
						desc = L["Display the Guild Message of the Day in an extra window, if updated.\nCredit: |cffff7d0aMerathilisUI|r"],
					},
					Movertransparancy = {
						order = 2,
						type = "range",
						name = L["Mover Transparency"],
						desc = L["Changes the transparency of all the movers."],
						isPercent = true,
						min = 0, max = 1, step = 0.01,
						get = function(info) return E.db.KlixUI.general.Movertransparancy end,
						set = function(info, value) E.db.KlixUI.general.Movertransparancy = value MI:UpdateMoverTransparancy() end,
					},
					combatState = {
						order = 3,
						type = "toggle",
						name = L["Announce Combat Status"],
						desc = L["Announce combat status in a textfield in the middle of the screen.\nCredit: |cffff7d0aMerathilisUI|r"],
					},
					announce = {
						order = 4,
						type = "toggle",
						name = L["Announce Skill Gains"],
						desc = L["Announce skill gains in a textfield in the middle of the screen.\nCredit: |cffff7d0aMerathilisUI|r"],
					},
					buyall = {
						order = 5,
						type = "toggle",
						name = L["Buy Max Stack"],
						desc = L["Alt-Click on an item, sold buy a merchant, to buy a full stack."],
					},
					keystones = {
						order = 6,
						type = "toggle",
						name = L["Auto Keystones"],
						desc = L["Automatically insert keystones when you open the keystonewindow in a dungeon."],
					},
					talkingHead = {
						order = 7,
						type = "toggle",
						name = L["Hide TalkingHeadFrame"]..E.NewSign,
					},
					whistleLocation = {
						order = 8,
						type = "toggle",
						name = L["Flight Master's Whistle Location"]..E.NewSign,
						desc = L["Show the nearest Flight Master's Whistle Location on the minimap and in the tooltip."],
						disabled = function() return IsAddOnLoaded("WhistledAway") end,
						hidden = function() return IsAddOnLoaded("WhistledAway") end,
					},
					whistleSound = {
						order = 9,
						type = "toggle",
						name = L["Flight Master's Whistle Sound"]..E.NewSign,
						desc = L["Plays a sound when you use the Flight Master's Whistle."],
					},
					lootSound = {
						order = 10,
						type = "toggle",
						name = L["Loot container opening sound"]..E.NewSign,
						desc = L["Plays a sound when you open a container, chest etc."],
					},
					transmog = {
						type = "toggle",
						order = 11,
						name = L["Transmog Remover Button"]..E.NewSign,
						desc = L["Enable/Disable the transmog remover button in the transmogrify window."],
					},
					rumouseover = {
						order = 20,
						type = "toggle",
						name = L["Raid Utility Mouse Over"],
						desc = L["Enabling mouse over will make ElvUI's raid utility show on mouse over instead of always showing."],
						disabled = function() return IsAddOnLoaded("ElvUI_SLE") end,
						hidden = function() return IsAddOnLoaded("ElvUI_SLE") end,
						get = function(info) return E.db.KlixUI.misc.rumouseover end,
						set = function(info, value) E.db.KlixUI.misc.rumouseover = value; MI:RUReset() end,
					},
					space = {
						order = 25,
						type = "description",
						name = "",
					},
					workorder = {
						order = 30,
						type = "group",
						name = L["Work Orders"]..E.NewSign,
						guiInline = true,
						get = function(info) return E.db.KlixUI.misc.workorder[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.misc.workorder[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
						args = {
							intro = {
								order = 1,
								type = "description",
								name = L["WO_DESC"],
							},
							orderhall = {
								order = 2,
								type = "toggle",
								name = L["OrderHall/Ship"],
								desc = L["Auto start orderhall/ship workorders when visiting the npc."],
								disabled = function() return COMP.SLE and (E.db.sle.legacy.warwampaign.autoOrder.enable or E.db.sle.legacy.orderhall.autoOrder.enable) end,
								hidden = function() return COMP.SLE and (E.db.sle.legacy.warwampaign.autoOrder.enable or E.db.sle.legacy.orderhall.autoOrder.enable) end,
							},
							nomi = {
								order = 3,
								type = "toggle",
								name = L["Nomi"],
								desc = L["Auto start workorders when visiting Nomi."],
							},
						},
					},
				},
			},
			merchant = {
				order = 3,
				type = "group",
				name = L["Merchant"],
				get = function(info) return E.db.KlixUI.misc.merchant[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.misc.merchant[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
				args = {
					credits = {
						order = 1,
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
					style = {
						order = 2,
						type = "toggle",
						name = L["Style"],
						desc = L["Display the MerchantFrame in one window instead of a small one with variouse amount of pages."],
						disabled = function() return not E.private.KlixUI.skins.blizzard.merchant end,
					},
					subpages = {
						order = 3,
						type = 'range',
						name = L["Subpages"],
						desc = L["Subpages are blocks of 10 items. This option set how many of subpages will be shown on a single page."],
						min = 2, max = 5, step = 1,
						disabled = function() return not E.private.KlixUI.skins.blizzard.merchant or E.db.KlixUI.misc.merchant.style ~= true end,
					},
					itemlevel = {
						order = 4,
						type = "toggle",
						name = L["ItemLevel"],
						desc = L["Display the item level on the MerchantFrame, to change the font you have to set it in ElvUI - Bags - ItemLevel"],
					},
				},
			},
			bloodlust = {
				order = 4,
				type = "group",
				name = L["Bloodlust"],
				get = function(info) return E.db.KlixUI.misc.bloodlust[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.misc.bloodlust[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
				args = {
					enable = {
						order = 1,
						type = 'toggle',
						name = L["Enable"],
					},
					spacer1 = {
						order = 2,
						type = "description",
						name = "",
					},
					spacer2 = {
						order = 3,
						type = "description",
						name = "",
					},
					sound = {
						order = 4,
						type = "toggle",
						name = L["Sound"],
						desc =  L["Play a sound when bloodlust/heroism is popped."],
						disabled = function() return not E.db.KlixUI.misc.bloodlust.enable end,
					},
					text = {
						order = 5,
						type = "toggle",
						name = L["Text"],
						desc =  L["Print a chat message of whom who popped bloodlust/heroism."],
						disabled = function() return not E.db.KlixUI.misc.bloodlust.enable end,
					},
					faction = {
						type = 'select',
						order = 6,
						name = L["Sound Type"],
						disabled = function() return not E.db.KlixUI.misc.bloodlust.enable or not E.db.KlixUI.misc.bloodlust.sound end,
						values = {
							["HORDE"] = L["Horde"],
							["ALLIANCE"] = L["Alliance"],
							["ILLIDAN"] = L["Illidan"],
							["CUSTOM"] = CUSTOM,
						},
					},
					SoundOverride = {
						order = 7,
						type = "toggle",
						name = L["Sound Override"],
						desc =  L["Force to play even when other sounds are disabled."],
						disabled = function() return not E.db.KlixUI.misc.bloodlust.enable or not E.db.KlixUI.misc.bloodlust.sound end,
					},
					UseCustomVolume = {
						order = 8,
						type = "toggle",
						name = L["Use Custom Volume"],
						desc =  L["Use custom volume.\n|cffff8000Note: This will only work if 'Sound Override' is enabled.|r"],
						disabled = function() return not E.db.KlixUI.misc.bloodlust.enable or not E.db.KlixUI.misc.bloodlust.sound or not E.db.KlixUI.misc.bloodlust.SoundOverride end,
					},
					CustomVolume = {
						order = 9,
						type = "range",
						name = L["Volume"],
						min = 1, max = 100, step = 1,
						disabled = function() return not E.db.KlixUI.misc.bloodlust.enable or not E.db.KlixUI.misc.bloodlust.sound or not E.db.KlixUI.misc.bloodlust.SoundOverride or not E.db.KlixUI.misc.bloodlust.UseCustomVolume end,
					},
					customSound = {
						type = 'input',
						order = 40,
						customWidth = 300,
						name = L["Custom Sound Path"]..E.NewSign,
						desc = L["Example of a path string: path\\path\\path\\sound.mp3"],
						hidden = function() return E.db.KlixUI.misc.bloodlust.faction ~= "CUSTOM" end,
						disabled = function() return not E.db.KlixUI.misc.bloodlust.enable or not E.db.KlixUI.misc.bloodlust.sound or E.db.KlixUI.misc.bloodlust.faction ~= "CUSTOM" end,
						set = function(_, value) E.db.KlixUI.misc.bloodlust.customSound = (value and (not value:match("^%s-$")) and value) or nil end,
					},
				},
			},
			easyCurve = {
				order = 5,
				type = "group",
				name = L["Easy Curve"],
				get = function(info) return E.db.KlixUI.misc.easyCurve[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.misc.easyCurve[ info[#info] ] = value; end,
				args = {	
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc =  L["Enable/disable the Easy Curve popup frame."],
						get = function(info) return E.db.KlixUI.misc.easyCurve.enable end,
						set = function(info, value) E.db.KlixUI.misc.easyCurve.enable = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					},
					override = {
						order = 2,
						name = L["Enable Override"],
						desc = L["Overrides the default achievements found and will always send the selected achievement from the dropdown."],
						type = "toggle",
						width = "full",
						disabled = function() return not E.db.KlixUI.misc.easyCurve.enable end,
						get = function() return E.db.KlixUI.misc.easyCurve.override end,
						set = function(info, value) E.db.KlixUI.misc.easyCurve.override = value; end
					},
					search = {
						order = 3,
						name = L["Search Achievements"],
						desc = L["Search term must be greater than 3 characters."],
						type = "input",
						width = "full",
						disabled = function() return not E.db.KlixUI.misc.easyCurve.override or not E.db.KlixUI.misc.easyCurve.enable end,
						set = function(info, value) 
							SetAchievementSearchString(value) 
							newSearch = true 
						end,
						validate = function(info, value) 
							if string.len(value) < 3 then 
								return L["Error: Search term must be greater than 3 characters"]
							else 
								return true 
							end 
						end
					},
					results = {
						order = 4,
						name = function()
							if newSearch then 
								return string.format("Select Override Achievement: %s Results Returned", tostring(KEC:TableLength(KEC.achievementSearchList)))
							else
								return L["Select Override Achievement"]
							end
						end,
						desc = L["Results are limited to 500 and only completed achievemnts. Please try a more specific search term if you cannot find the achievement listed."],
						type = "select",
						values = KEC.achievementSearchList,
						width = "full",
						disabled = function() 
							return not E.db.KlixUI.misc.easyCurve.override 
								   or not E.db.KlixUI.misc.easyCurve.enable 
								   or (not E.db.KlixUI.misc.easyCurve.overrideAchievement and not newSearch) 
						end,
						get = function() 
							if E.db.KlixUI.misc.easyCurve.overrideAchievement then
								return E.db.KlixUI.misc.easyCurve.overrideAchievement
							else
								return 1
							end
						end,
						set = function(info, value) E.db.KlixUI.misc.easyCurve.overrideAchievement = value end,
						validate = function(info, value) 
							if value == 1 then 
								return L["Error: Please select an achievement"] 
							else 
								return true 
							end 
						end
					},
					whispersAchievement = {
						order = 5,
						name = L["Always Check Achievement Whisper Dialog Checkbox"],
						desc = L["This will always check the achievement whisper dialog checkbox when signing up for a group by default."],
						type = "toggle",
						width = "double",
						disabled = function() return not E.db.KlixUI.misc.easyCurve.enable  end,
						get = function() return E.db.KlixUI.misc.easyCurve.whispersAchievement end,
						set = function(info, value) 
							E.db.KlixUI.misc.easyCurve.whispersAchievement = value 
							KEC.checkButtonAchievement:SetChecked(value) 
						end,
					},
					whispersKeystone = {
						order = 6,
						name = L["Always Check Keystone Whisper Dialog Checkbox"],
						desc = L["This will always check the keystone whisper dialog checkbox when signing up for a mythic plus group by default."],
						type = "toggle",
						width = "double",
						disabled = function() return not E.db.KlixUI.misc.easyCurve.enable end,
						get = function() return E.db.KlixUI.misc.easyCurve.whispersKeystone end,
						set = function(info, value) 
							E.db.KlixUI.misc.easyCurve.whispersKeystone = value 
							KEC.checkButtonKeystone:SetChecked(value)  
						end,
					},
				},
			},
			rolecheck = {
				order = 6,
				type = "group",
				name = L["Role Check"],
				get = function(info) return E.db.KlixUI.misc.rolecheck[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.misc.rolecheck[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc =  L["Automatically accept all role check popups."],
					},
					confirm = {
						order = 2,
						type = "toggle",
						name = L["Confirm Role Checks"],
						desc =  L["After you join a custom group finder raid a box pops up telling you your role and won't dissapear until clicked, this gets rid of it."],
					},
					spacer1 = {
						order = 3,
						type = "description",
						name = "",
					},
					timewalking = {
						order = 4,
						type = "toggle",
						name = L["Timewalking"],
						desc =  L["Automatically accept timewalking role check popups."],
						disabled = function() return E.db.KlixUI.misc.rolecheck.enable end,
					},
					love = {
						order = 5,
						type = "toggle",
						name = L["Love is in the Air"],
						desc =  L["Automatically accept Love is in the Air dungeon role check popups."],
						disabled = function() return E.db.KlixUI.misc.rolecheck.enable end,
					},
					halloween = {
						order = 6,
						type = "toggle",
						name = L["Halloween"],
						desc =  L["Automatically accept Halloween dungeon role check popups."],
						disabled = function() return E.db.KlixUI.misc.rolecheck.enable end,
					},
				},
			},
			panels = {
				order = 7,
				type = "group",
				name = L["Panels"],
				args = {
					top = {
						order = 1,
						type = 'group',
						guiInline = true,
						name = L['Top Panel'],
						get = function(info) return E.db.KlixUI.misc.panels.top[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.misc.panels.top[ info[#info] ] = value; KUI:GetModule('KuiLayout'):TopPanelLayout() end,
						args = {
							show = {
								order = 1,
								type = 'toggle',
								name = SHOW..E.NewSign,
								desc = L["Display a panel across the top of the screen. This is for cosmetic only."],
								get = function(info) return E.db.general.topPanel end,
								set = function(info, value) E.db.general.topPanel = value; E:GetModule('Layout'):TopPanelVisibility() end
							},
							spacer1 = {
								order = 2,
								type = "description",
								name = "",
							},
							spacer2 = {
								order = 3,
								type = "description",
								name = "",
							},
							style = {
								order = 4,
								type = 'toggle',
								name = L["|cfff960d9KlixUI|r Style"],
								disabled = function() return not E.db.KlixUI.general.style end,
							},
							transparency = {
								order = 5,
								type = 'toggle',
								name = L['Panel Transparency'],
							},
							height = {
								order = 6,
								type = "range",
								name = L["Height"],
								min = 8, max = 60, step = 1,
							},
						},
					},
					bottom = {
						order = 2,
						type = 'group',
						guiInline = true,
						name = L['Bottom Panel'],
						get = function(info) return E.db.KlixUI.misc.panels.bottom[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.misc.panels.bottom[ info[#info] ] = value; KUI:GetModule('KuiLayout'):BottomPanelLayout() end,
						args = {
							show = {
								order = 1,
								type = 'toggle',
								name = SHOW..E.NewSign,
								desc = L["Display a panel across the bottom of the screen. This is for cosmetic only."],
								get = function(info) return E.db.general.bottomPanel end,
								set = function(info, value) E.db.general.bottomPanel = value; E:GetModule('Layout'):BottomPanelVisibility() end
							},
							spacer1 = {
								order = 2,
								type = "description",
								name = "",
							},
							spacer2 = {
								order = 3,
								type = "description",
								name = "",
							},
							style = {
								order = 4,
								type = 'toggle',
								name = L["|cfff960d9KlixUI|r Style"],
								disabled = function() return not E.db.KlixUI.general.style end,
							},
							transparency = {
								order = 5,
								type = 'toggle',
								name = L['Panel Transparency'],
							},
							height = {
								order = 6,
								type = "range",
								name = L["Height"],
								min = 8, max = 60, step = 1,
							},
						},
					},
					--[[gotogeneral = {
						order = 3,
						type = "execute",
						name = L["ElvUI Panels"],
						func = function() LibStub("AceConfigDialog-3.0-ElvUI"):SelectGroup("ElvUI", "general") end,
					},]]
				},
			},
			scrapper = {
				order = 8,
				type = "group",
				name = L["Scrap Machine"]..E.NewSign,
				get = function(info) return E.db.KlixUI.misc.scrapper[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.misc.scrapper[ info[#info] ] = value end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc = L["Show the scrapbutton at the scrappingmachineUI."],
						set = function(info, value) E.db.KlixUI.misc.scrapper[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					},
					position = {
						order = 2,
						type = "select",
						name = L["Position"],
						desc = L["Place scrap button at the top or the bottom of the scrappingmachineUI."],
						disabled = function() return not E.db.KlixUI.misc.scrapper.enable end,
						set = function(info, value) E.db.KlixUI.misc.scrapper[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
						values = {
							["TOP"] = L["Top"],
							["BOTTOM"] = L["Bottom"],
						},
					},
					autoOpen = {
						order = 3,
						type = "toggle",
						name = L["Auto Open Bags"],
						desc = L["Auto open bags when visiting the scrapping machine."],
						disabled = function() return not E.private.bags.enable end,
					},
					equipmentsets = {
						order = 4,
						type = "toggle",
						name = L["Equipment Sets"],
						desc = L["Ignore items in equipment sets."],
						disabled = function() return not E.db.KlixUI.misc.scrapper.enable end,
					},
					azerite = {
						order = 5,
						type = "toggle",
						name = L["Azerite"],
						desc = L["Ignore azerite items."],
						disabled = function() return not E.db.KlixUI.misc.scrapper.enable end,
					},
					boe = {
						order = 6,
						type = "toggle",
						name = L["Bind-on-Equipped"],
						desc = L["Ignore bind-on-equipped items."],
						disabled = function() return not E.db.KlixUI.misc.scrapper.enable end,
					},
					Itemlvl = {
						order = 7,
						type = "toggle",
						name = L["Equipped Item Level"],
						desc = L["Don't insert items above equipped iLvl."],
						disabled = function() return not E.db.KlixUI.misc.scrapper.enable end,
					},
					specificilvl = {
						order = 8,
						type = "toggle",
						name = L["Specific Item Level"],
						desc = L["Ignore items above specific item level."],
						disabled = function() return not E.db.KlixUI.misc.scrapper.enable end,
					},
					specificilvlbox = {
						order = 9,
						type = "input",
						width = 0.75,
						name = L["Item Level"],
						disabled = function() return not E.db.KlixUI.misc.scrapper.enable or not E.db.KlixUI.misc.scrapper.specificilvl end,
					},
				},
			},
			zoom = {
				order = 9,
				type = "group",
				name = L["Character Zoom"],
				get = function(info) return E.db.KlixUI.misc.zoom[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.misc.zoom[ info[#info] ] = value end,
				args = {
					increment = {
						order = 1,
						type = "range",
						desc = "Adjust the increment the camera will follow behind you.",
						name = L.ZOOM_INCREMENT,
						get = function(info) return E.db.KlixUI.misc.zoom.increment end,
						set = function(info, value) E.db.KlixUI.misc.zoom.increment = value end,
						min = 1, max = 10, softMax = 5, step = .5,
					},
					speed = {
						order = 2,
						type = "range",
						desc = "Adjust the zoom speed the camera will follow behind you.",
						name = L.ZOOM_SPEED,
						get = function(info) return tonumber(GetCVar("cameraZoomSpeed")) end,
						set = function(info, value)  E.db.KlixUI.misc.zoom.speed = value; SetCVar("cameraZoomSpeed", value) end,
						min = 1, max = 50, step = 1,
					},
					distance = {
						order = 3,
						type = "range",
						desc = OPTION_TOOLTIP_MAX_FOLLOW_DIST,
						name = MAX_FOLLOW_DIST,
						get = function(info) return GetCVar("cameraDistanceMaxZoomFactor") * base end,
						set = function(info, value) E.db.KlixUI.misc.zoom.distance = value / base; SetCVar("cameraDistanceMaxZoomFactor", value / base) end,
						min = base, max = base * maxfactor, step = 1.5, -- cvar gets rounded to 1 decimal
					},
				},
			},
			autolog = {
				order = 10,
				type = "group",
				name = L["AutoLog"]..E.NewSign,
				get = function(info) return E.db.KlixUI.misc.autolog[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.misc.autolog[ info[#info] ] = value; AL:CheckLog() end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc = L["Enable/disable automatically combat logging"],
						set = function(info, value) E.db.KlixUI.misc.autolog[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end
					},
					allraids = {
						order = 2,
						type = "toggle",
						name = L["All raids"],
						desc = L["Combat log all raids regardless of individual raid settings"],
						disabled = function() return not E.db.KlixUI.misc.autolog.enable end,
					},
					chatwarning = {
						order = 3,
						type = "toggle",
						name = L["Display in chat"],
						desc = L["Display the combat log status in the chat window"],
						disabled = function() return not E.db.KlixUI.misc.autolog.enable end,
					},
					dungeons = {
						order = 4,
						type = "toggle",
						name = L["5 player heroic instances"],
						desc = L["Combat log 5 player heroic instances"],
						disabled = function() return not E.db.KlixUI.misc.autolog.enable end,
					},
					challenge = {
						order = 5,
						type = "toggle",
						name = L["5 player challenge mode instances"],
						desc = L["Combat log 5 player challenge mode instances"],
						disabled = function() return not E.db.KlixUI.misc.autolog.enable end,
					},
					mythicdungeons = {
						order = 6,
						type = "toggle",
						name = L["5 player mythic instances"],
						desc = L["Combat log 5 player mythic instances"],
						disabled = function() return not E.db.KlixUI.misc.autolog.enable end,
					},
					mythiclevel = {
						order = 7,
						type = "select",
						width = 0.45,
						name = L["Minimum level"],
						desc = L["Logging will not be enabled for mythic levels lower than this"],
						disabled = function() return not E.db.KlixUI.misc.autolog.enable or not E.db.KlixUI.misc.autolog.mythicdungeons end,
						values = AL:getMythicLevelsList(),
					},
					lfr = {
						order = 10,
						type = "multiselect",
						name = L["LFR Raids"],
						desc = L["Raid finder instances where you want to log combat"],
						values = AL:MakeList(raid_lfr),
						tristate = false,
						disabled = function() return not E.db.KlixUI.misc.autolog.enable end,
						get = function(info, raid) return AL:GetSetting("lfr", raid) end,
						set = function(info, raid, value) AL:SetSetting("lfr", raid, value) end,
					},
					raidsn = {
						order = 11,
						type = "multiselect",
						name = L["Normal Raids"],
						desc = L["Raid instances where you want to log combat"],
						values = AL:MakeList(raid_normal),
						tristate = false,
						disabled = function() return not E.db.KlixUI.misc.autolog.enable end,
						get = function(info, raid) return AL:GetSetting("normal", raid) end,
						set = function(info, raid, value) AL:SetSetting("normal", raid, value) end,
					},
					raidsh = {
						order = 12,
						type = "multiselect",
						name = L["Heroic Raids"],
						desc = L["Raid instances where you want to log combat"],
						values = AL:MakeList(raid_heroic),
						tristate = false,
						disabled = function() return not E.db.KlixUI.misc.autolog.enable end,
						get = function(info, raid) return AL:GetSetting("heroic", raid) end,
						set = function(info, raid, value) AL:SetSetting("heroic", raid, value) end,
					},
					mythic = {
						order = 13,
						type = "multiselect",
						name = L["Mythic Raids"],
						desc = L["Raid instances where you want to log combat"],
						values = AL:MakeList(raid_mythic),
						tristate = false,
						disabled = function() return not E.db.KlixUI.misc.autolog.enable end,
						get = function(info, raid) return AL:GetSetting("mythic", raid) end,
						set = function(info, raid, value) AL:SetSetting("mythic", raid, value) end,
					},
				},
			},
			popups = {
				order = 11,
				type = "group",
				name = L["Confirm Static Popups"]..E.NewSign,
				get = function(info) return E.db.KlixUI.misc.popups[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.misc.popups[ info[#info] ] = value; end,
				args = {
					toggle = {
						order = 1,
						type = "group",
						name = L["Auto Answer"],
						guiInline = true,
						args = PopupOptions(),
					},
				},
			},
			CA = {
				order = 50,
				type = "group",
				name = L["Corrupted Ashbringer"],
				hidden = function() return not KUI:IsDeveloper() end,
				disabled = function() return not KUI:IsDeveloper() end,
				get = function(info) return E.db.KlixUI.misc.CA[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.misc.CA[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc =  L["Display the MerchantFrame in one window instead of a small one with variouse amount of pages."],
					},
					nextSound = {
						order = 2,
						type = "range",
						name = L["Sound Number"],
						desc =  L["Changes which of the corrupted ashbringer sounds it should play in a numeric order."],
						min = 1, max = 12, step = 1,
						disabled = function() return not E.db.KlixUI.misc.CA.enable end,
					},
					soundProbabilityPercent = {
						order = 3,
						type = "range",
						name = L["Sound Probability"],
						desc = L["Changes the probability value, in percent, how often the sounds will play."],
						min = 0, max = 100, step = 1,
						disabled = function() return not E.db.KlixUI.misc.CA.enable end,
					},
				},
			},
		},
	}
end
tinsert(KUI.Config, Misc)

--[[local function injectElvUIDataTextsOptions()
	E.Options.args.general.args.general.args.spacer1 = {
		order = 28,
		type = 'description',
		name = '',
	}

	E.Options.args.general.args.general.args.spacer2 = {
		order = 29,
		type = 'header',
		name = '',
	}
	
	E.Options.args.general.args.general.args.gotoklixui = {
		order = 30,
		type = "execute",
		name = KUI:cOption(L["KlixUI Panels"]),
		func = function() LibStub("AceConfigDialog-3.0-ElvUI"):SelectGroup("ElvUI", "KlixUI", "modules", "misc", "panels") end,
	}
end
tinsert(KUI.Config, injectElvUIDataTextsOptions)]]