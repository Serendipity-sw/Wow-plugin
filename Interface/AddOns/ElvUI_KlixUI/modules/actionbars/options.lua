local KUI, E, L, V, P, G = unpack(select(2, ...))
local KAB = KUI:GetModule('KUIActionbars');
local MB = KUI:GetModule("MicroBar");
local SEB = KUI:GetModule("SpecEquipBar");

--Cache global variables
local format = string.format
local tinsert = table.insert
--WoW API / Variables

local function abTable()
	E.Options.args.KlixUI.args.modules.args.actionbars = {
		order = 1,
		type = 'group',
		name = L['ActionBars'],
		childGroups = 'tab',
		args = {
			name = {
				order = 1,
				type = 'header',
				name = KUI:cOption(L['ActionBars']),
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
						name = format("|cff00c0faBenikUI - Benik|r & |cffff7d0aMerathilisUI - Merathilis|r"),
					},
				},
			},
			general = {
				order = 3,
				type = "group",
				name = L["General"],
				args = {
					transparent = {
						order = 1,
						type = 'toggle',
						name = L['Transparent Backdrops'],
						desc = L['Applies transparency in all actionbar backdrops and actionbar buttons.'],
						disabled = function() return not E.private.actionbar.enable end,
						get = function(info) return E.db.KlixUI.actionbars[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.actionbars[ info[#info] ] = value; KAB:TransparentBackdrops() end,	
					},
					cleanButton = {
						order = 2,
						type = 'toggle',
						name = L['Clean Button'],
						desc = L['Removes the textures around the Bossbutton and the Zoneability button.'],
						disabled = function() return not E.private.actionbar.enable end,
						get = function(info) return E.db.KlixUI.actionbars[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.actionbars[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					},
				},
			},
			glow = {
				order = 4,
				type = "group",
				name = L["Glow"]..E.NewSign,
				hidden = function() return IsAddOnLoaded("CoolGlow") end,
				disabled = function() return IsAddOnLoaded("CoolGlow") end,
				get = function(info) return E.db.KlixUI.actionbars.glow[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.actionbars.glow[ info[#info] ] = value; KAB:AzeriteGlow(); end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						set = function(info, value) E.db.KlixUI.actionbars.glow[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					},
					color = {
						order = 2,
						type = "color",
						name = L["Color"],
						hasAlpha = true,
						disabled = function() return not E.db.KlixUI.actionbars.glow.enable end,
						get = function(info)
							local t = E.db.KlixUI.actionbars.glow.color
							return t.r, t.g, t.b, t.a
						end,
						set = function(info, r, g, b, a)
							local t = E.db.KlixUI.actionbars.glow.color
							t.r, t.g, t.b, t.a = r, g, b, a
							KAB:AzeriteGlow()
						end,
					},
					space1 = {
						order = 3,
						type = "description",
						name = "",
					},
					number = {
						order = 4,
						type = "range",
						name = L["Num Lines"],
						desc = L["Defines the number of lines the glow will spawn."],
						min = 4, max = 16, step = 1,
						disabled = function() return not E.db.KlixUI.actionbars.glow.enable end,
					},
					frequency = {
						order = 5,
						type = "range",
						name = L["Frequency"],
						desc = L["Sets the animation speed of the glow. Negative values will rotate the glow anti-clockwise."],
						min = -2, max = 2, step = 0.01,
						disabled = function() return not E.db.KlixUI.actionbars.glow.enable end,
					},
					lenght = {
						order = 6,
						type = "range",
						name = L["Length"],
						desc = L["Defines the lenght of each individual glow lines."],
						min = 2, max = 16, step = 1,
						disabled = function() return not E.db.KlixUI.actionbars.glow.enable end,
					},
					thickness = {
						order = 7,
						type = "range",
						name = L["Thickness"],
						desc = L["Defines the thickness of the glow lines."],
						min = 1, max = 6, step = 1,
						disabled = function() return not E.db.KlixUI.actionbars.glow.enable end,
					},
					xOffset = {
						order = 8,
						type = "range",
						name = L["X-Offset"],
						min = -5, max = 5, step = 1,
						disabled = function() return not E.db.KlixUI.actionbars.glow.enable end,
					},
					yOffset = {
						order = 9,
						type = "range",
						name = L["Y-Offset"],
						min = -5, max = 5, step = 1,
						disabled = function() return not E.db.KlixUI.actionbars.glow.enable end,
					},
				},
			},
			SEBar = {
				order = 5,
				type = "group",
				name = L["Specialization & Equipment Bar"],
				disabled = function() return not E.private.actionbar.enable end,
				get = function(info) return E.db.KlixUI.actionbars.SEBar[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.actionbars.SEBar[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc = L['Show/Hide the |cfff960d9KlixUI|r Spec & EquipBar.'],
						disabled = function() return not E.private.actionbar.enable end,
					},
					space1 = {
						order = 2,
						type = "description",
						name = "",
					},
					space2 = {
						order = 3,
						type = "description",
						name = "",
					},
					mouseover = {
						order = 4,
						type = "toggle",
						name = L["Mouseover"],
						disabled = function() return not E.private.actionbar.enable end,
					},
					malpha = {
						order = 5,
						type = "range",
						name = L["Alpha"],
						desc = L["Change the alpha level of the frame."],
						min = 0, max = 1, step = 0.1,
						disabled = function() return not E.db.KlixUI.actionbars.SEBar.mouseover or not E.db.KlixUI.actionbars.SEBar.enable end,
					},
					hideInCombat = {
						order = 6,
						type = "toggle",
						name = L["Hide In Combat"],
						desc = L['Show/Hide the |cfff960d9KlixUI|r Spec & EquipBar in combat.'],
						disabled = function() return not E.db.KlixUI.actionbars.SEBar.enable end,
					},
					hideInOrderHall = {
						order = 7,
						type = "toggle",
						name = L["Hide In Orderhall"],
						desc = L['Show/Hide the |cfff960d9KlixUI|r Spec & Equip Bar in the class hall.'],
						disabled = function() return not E.db.KlixUI.actionbars.SEBar.enable end,
					},
				},
			},
			microBar = {
				order = 6,
				type = "group",
				name = L["Micro Bar"],
				get = function(info) return E.db.KlixUI.microBar[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.microBar[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						desc = L['Show/Hide the |cfff960d9KlixUI|r MicroBar.'],
						disabled = function() return not E.private.actionbar.enable end,
					},
					space1 = {
						order = 2,
						type = "description",
						name = "",
					},
					space2 = {
						order = 3,
						type = "description",
						name = "",
					},
					scale = {
						order = 4,
						type = "range",
						name = L["Microbar Scale"],
						isPercent = true,
						min = 0.5, max = 1.0, step = 0.01,
						disabled = function() return not E.db.KlixUI.microBar.enable end,
						hidden = function() return not E.db.KlixUI.microBar.enable end,
					},
					hideInCombat = {
						order = 5,
						type = "toggle",
						name = L["Hide In Combat"],
						desc = L['Show/Hide the |cfff960d9KlixUI|r MicroBar in combat.'],
						disabled = function() return not E.db.KlixUI.microBar.enable end,
						hidden = function() return not E.db.KlixUI.microBar.enable end,
					},
					hideInOrderHall = {
						order = 6,
						type = "toggle",
						name = L["Hide In Orderhall"],
						desc = L['Show/Hide the |cfff960d9KlixUI|r MicroBar in the class hall.'],
						disabled = function() return not E.db.KlixUI.microBar.enable end,
						hidden = function() return not E.db.KlixUI.microBar.enable end,
					},
					highlight = {
						order = 7,
						type = "group",
						name = KUI:cOption(L["Highlight"]),
						guiInline = true,
						hidden = function() return not E.db.KlixUI.microBar.enable end,
						args = {
							enable = {		
								order = 1,
								type = "toggle",
								name = L["Enable"],
								desc = L['Show/Hide the highlight when hovering over the |cfff960d9KlixUI|r MicroBar buttons.'],
								disabled = function() return not E.private.actionbar.enable end,
								hidden = function() return not E.db.KlixUI.microBar.enable end,
								get = function(info) return E.db.KlixUI.microBar.highlight.enable end,
								set = function(info, value) E.db.KlixUI.microBar.highlight.enable = value; E:StaticPopup_Show("PRIVATE_RL"); end,
							},
							buttons = {		
								order = 2,
								type = "toggle",
								name = L["Buttons"],
								desc = L['Only show the highlight of the buttons when hovering over the |cfff960d9KlixUI|r MicroBar buttons.'],
								disabled = function() return not E.private.actionbar.enable or E.db.KlixUI.microBar.highlight.enable == false end,
								hidden = function() return not E.db.KlixUI.microBar.enable end,
								get = function(info) return E.db.KlixUI.microBar.highlight.buttons end,
								set = function(info, value) E.db.KlixUI.microBar.highlight.buttons = value; E:StaticPopup_Show("PRIVATE_RL"); end,
							},
						},
					},
					text = {
						order = 8,
						type = "group",
						name = KUI:cOption(L["Text"]),
						guiInline = true,
						hidden = function() return not E.db.KlixUI.microBar.enable end,
						args = {
							buttons = {
								order = 1,
								type = "group",
								name = KUI:cOption(L["Buttons"]),
								guiInline = true,
								args = {			
									position = {
										order = 1,
										type = "select",
										name = L["Position"],
										values = {
											["TOP"] = L["Top"],
											["BOTTOM"] = L["Bottom"],
										},
										get = function(info) return E.db.KlixUI.microBar.text.buttons.position end,
										set = function(info, value) E.db.KlixUI.microBar.text.buttons.position = value; E:StaticPopup_Show("PRIVATE_RL"); end,
										disabled = function() return not E.db.KlixUI.microBar.enable end,
									},
								},
							},
							friends = {
								order = 2,
								type = "group",
								name = KUI:cOption(FRIENDS),
								guiInline = true,
								args = {
									enable = {
										order = 1,
										type = "toggle",
										name = L["Enable"],
										desc = L['Show/Hide the friend text on |cfff960d9KlixUI|r MicroBar.'],
										disabled = function() return not E.db.KlixUI.microBar.enable end,
										get = function(info) return E.db.KlixUI.microBar.text.friends.enable  end,
										set = function(info, value) E.db.KlixUI.microBar.text.friends.enable = value; E:StaticPopup_Show("PRIVATE_RL"); end,
									},
									space1 = {
										order = 2,
										type = "description",
										name = "",
									},
									space2 = {
										order = 3,
										type = "description",
										name = "",
									},
									textSize = {
										order = 4,
										name = FONT_SIZE,
										type = "range",
										min = 6, max = 20, step = 1,
										disabled = function() return not E.db.KlixUI.microBar.enable or not E.db.KlixUI.microBar.text.friends.enable end,
										get = function(info) return E.db.KlixUI.microBar.text.friends.textSize  end,
										set = function(info, value) E.db.KlixUI.microBar.text.friends.textSize = value; E:StaticPopup_Show("PRIVATE_RL"); end,
									},
									xOffset = {
										order = 5,
										type = "range",
										name = L["X-Offset"],
										min = -30, max = 30, step = 1,
										disabled = function() return not E.db.KlixUI.microBar.enable or not E.db.KlixUI.microBar.text.friends.enable end,
										get = function(info) return E.db.KlixUI.microBar.text.friends.xOffset  end,
										set = function(info, value) E.db.KlixUI.microBar.text.friends.xOffset = value; E:StaticPopup_Show("PRIVATE_RL"); end,
									},
									yOffset = {
										order = 6,
										type = "range",
										name = L["Y-Offset"],
										min = -30, max = 30, step = 1,
										disabled = function() return not E.db.KlixUI.microBar.enable or not E.db.KlixUI.microBar.text.friends.enable end,
										get = function(info) return E.db.KlixUI.microBar.text.friends.yOffset  end,
										set = function(info, value) E.db.KlixUI.microBar.text.friends.yOffset = value; E:StaticPopup_Show("PRIVATE_RL"); end,
									},
								},
							},
							guild = {
								order = 3,
								type = "group",
								name = KUI:cOption(GUILD),
								guiInline = true,
								hidden = function() return not E.db.KlixUI.microBar.enable end,
								args = {
									enable = {
										order = 1,
										type = "toggle",
										name = L["Enable"],
										desc = L['Show/Hide the guild text on |cfff960d9KlixUI|r MicroBar.'],
										disabled = function() return not E.db.KlixUI.microBar.enable end,
										get = function(info) return E.db.KlixUI.microBar.text.guild.enable  end,
										set = function(info, value) E.db.KlixUI.microBar.text.guild.enable = value; E:StaticPopup_Show("PRIVATE_RL"); end,
									},
									space1 = {
										order = 2,
										type = "description",
										name = "",
									},
									space2 = {
										order = 3,
										type = "description",
										name = "",
									},
									textSize = {
										order = 4,
										name = FONT_SIZE,
										type = "range",
										min = 6, max = 20, step = 1,
										disabled = function() return not E.db.KlixUI.microBar.enable or not E.db.KlixUI.microBar.text.guild.enable end,
										get = function(info) return E.db.KlixUI.microBar.text.guild.textSize  end,
										set = function(info, value) E.db.KlixUI.microBar.text.guild.textSize = value; E:StaticPopup_Show("PRIVATE_RL"); end,
									},
									xOffset = {
										order = 5,
										type = "range",
										name = L["X-Offset"],
										min = -30, max = 30, step = 1,
										disabled = function() return not E.db.KlixUI.microBar.enable or not E.db.KlixUI.microBar.text.guild.enable end,
										get = function(info) return E.db.KlixUI.microBar.text.guild.xOffset  end,
										set = function(info, value) E.db.KlixUI.microBar.text.guild.xOffset = value; E:StaticPopup_Show("PRIVATE_RL"); end,
									},
									yOffset = {
										order = 6,
										type = "range",
										name = L["Y-Offset"],
										min = -30, max = 30, step = 1,
										disabled = function() return not E.db.KlixUI.microBar.enable or not 	E.db.KlixUI.microBar.text.guild.enable end,
										get = function(info) return E.db.KlixUI.microBar.text.guild.yOffset  end,
										set = function(info, value) E.db.KlixUI.microBar.text.guild.yOffset = value; E:StaticPopup_Show("PRIVATE_RL"); end,
									},
								},
							},
							colors = {
								order = 4,
								type = 'group',
								name = KUI:cOption(L["Color"]),
								guiInline = true,
								disabled = function() return not E.db.KlixUI.microBar.enable end,
								hidden = function() return not E.db.KlixUI.microBar.enable end,
								args = {
									customColor = {
										order = 1,
										type = "select",
										name = COLOR,
											values = {
												[1] = CLASS_COLORS,
												[2] = CUSTOM,
												[3] = L["Value Color"],
											},
											get = function(info) return E.db.KlixUI.microBar.text.colors[ info[#info] ] end,
											set = function(info, value) E.db.KlixUI.microBar.text.colors[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
										},
										userColor = {
											order = 2,
											type = "color",
											name = COLOR_PICKER,
											disabled = function() return E.db.KlixUI.microBar.text.colors.customColor == 1 or E.db.KlixUI.microBar.text.colors.customColor == 3 end,
										get = function(info)
											local t = E.db.KlixUI.microBar.text.colors[ info[#info] ]
											return t.r, t.g, t.b, t.a
											end,
										set = function(info, r, g, b)
											local t = E.db.KlixUI.microBar.text.colors[ info[#info] ]
											t.r, t.g, t.b = r, g, b
											E:StaticPopup_Show("PRIVATE_RL");
											end,
									},
								},
							},
						},
					},
				},
			},
		},
	}
	
	local available = available or 6

	if IsAddOnLoaded('ElvUI_ExtraActionBars') then
		available = 10
	else
		available = 6
	end
end
tinsert(KUI.Config, abTable)