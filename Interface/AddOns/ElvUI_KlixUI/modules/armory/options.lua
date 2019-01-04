local KUI, E, L, V, P, G = unpack(select(2, ...))
local KA = KUI:GetModule("KuiArmory")

--Cache global variables
local format = string.format
--WoW API / Variables

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: 

local FontStyleList = {
	["NONE"] = NONE,
	["OUTLINE"] = 'OUTLINE',
	["MONOCHROMEOUTLINE"] = 'MONOCROMEOUTLINE',
	["THICKOUTLINE"] = 'THICKOUTLINE'
}

local function ArmoryTable()
	E.Options.args.KlixUI.args.modules.args.armory = {
		type = "group",
		order = 3,
		name = KA.modName,
		childGroups = 'tab',
		disabled = function() return IsAddOnLoaded("ElvUI_SLE") end,
		hidden = function() return IsAddOnLoaded("ElvUI_SLE") end,
		get = function(info) return E.db.KlixUI.armory[ info[#info] ] end,
		set = function(info, value) E.db.KlixUI.armory[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL"); end,
		args = {
			name = {
				order = 1,
				type = "header",
				name = KUI:cOption(KA.modName),
			},
			enable = {
				type = "toggle",
				order = 2,
				name = L["Enable"],
				desc = L["Enable/Disable the |cfff960d9KlixUI|r Armory Mode."],
				get = function(info) return E.db.KlixUI.armory.enable end,
				set = function(info, value) E.db.KlixUI.armory.enable = value; E:StaticPopup_Show("PRIVATE_RL"); end,
			},
			azeritebtn = {
				type = "toggle",
				order = 3,
				name = L["Azerite Buttons"]..E.NewSign,
				desc = L["Enable/Disable the Azerite Buttons on the character window."],
				set = function(info, value) E.db.KlixUI.armory.azeritebtn = value; E:StaticPopup_Show("PRIVATE_RL") end,
			},
			naked = {
				type = "toggle",
				order = 4,
				name = L["Naked Button"],
				desc = L["Enable/Disable the Naked Button on the character window."],
				set = function(info, value) E.db.KlixUI.armory.naked = value; E:StaticPopup_Show("PRIVATE_RL") end,
			},
			durability = {
				order = 5,
				type = "group",
				name = L["Durability"],
				disabled = function() return not E.db.KlixUI.armory.enable end,
				get = function(info) return E.db.KlixUI.armory.durability[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.armory.durability[ info[#info] ] = value; KA:UpdatePaperDoll() end,
				args = {
					enable = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
						desc = L["Enable/Disable the display of durability information on the character window."],
					},
					onlydamaged = {
						type = "toggle",
						order = 2,
						name = L["Damaged Only"],
						desc = L["Only show durability information for items that are damaged."],
						disabled = function() return not E.db.KlixUI.armory.enable or not E.db.KlixUI.armory.durability.enable end,
					},
					font = {
						order = 3,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Font"],
						values = AceGUIWidgetLSMlists.font,
						disabled = function() return not E.db.KlixUI.armory.enable or not E.db.KlixUI.armory.durability.enable end,
						set = function(info, value) E.db.KlixUI.armory.durability[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL")  end, 
					},
					textSize = {
						order = 4,
						name = FONT_SIZE,
						type = "range",
						min = 6, max = 22, step = 1,
						disabled = function() return not E.db.KlixUI.armory.enable or not E.db.KlixUI.armory.durability.enable end,
						set = function(info, value) E.db.KlixUI.armory.durability[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL")  end, 
					},
					fontOutline = {
						order = 5,
						type = "select",
						name = L["Font Outline"],
						values = {
							["NONE"] = NONE,
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE",
						},
						disabled = function() return not E.db.KlixUI.armory.enable or not E.db.KlixUI.armory.durability.enable end,
						set = function(info, value) E.db.KlixUI.armory.durability[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL")  end, 
					},
				},
			},
			itemlevel = {
				order = 6,
				type = "group",
				name = L["Itemlevel"],
				disabled = function() return not E.db.KlixUI.armory.enable end,
				get = function(info) return E.db.KlixUI.armory.ilvl[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.armory.ilvl[ info[#info] ] = value; KA:UpdatePaperDoll() end,
				args = {
					enable = {
						type = "toggle",
						order = 1,
						name = L["Enable"],
						desc = L["Enable/Disable the display of item levels on the character window."],
					},
					font = {
						order = 2,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Font"],
						values = AceGUIWidgetLSMlists.font,
						disabled = function() return not E.db.KlixUI.armory.enable or not E.db.KlixUI.armory.ilvl.enable end,
						set = function(info, value) E.db.KlixUI.armory.ilvl[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL")  end, 
					},
					textSize = {
						order = 3,
						name = FONT_SIZE,
						type = "range",
						min = 6, max = 22, step = 1,
						disabled = function() return not E.db.KlixUI.armory.enable or not E.db.KlixUI.armory.ilvl.enable end,
						set = function(info, value) E.db.KlixUI.armory.ilvl[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL")  end, 
					},
					fontOutline = {
						order = 4,
						type = "select",
						name = L["Font Outline"],
						values = {
							["NONE"] = NONE,
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE",
						},
						disabled = function() return not E.db.KlixUI.armory.enable or not E.db.KlixUI.armory.ilvl.enable end,
								set = function(info, value) E.db.KlixUI.armory.ilvl[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL")  end, 
					},
					colorStyle = {
						order = 5,
						type = "select",
						name = COLOR..E.NewSign,
						values = {
							["RARITY"] = RARITY,
							["LEVEL"] = L["Level"],
							["CUSTOM"] = CUSTOM,
						},
						disabled = function() return not E.db.KlixUI.armory.enable or not E.db.KlixUI.armory.ilvl.enable end,
					},
					color = {
						order = 6,
						type = "color",
						name = COLOR_PICKER..E.NewSign,
						disabled = function() return E.db.KlixUI.armory.ilvl.colorStyle == "RARITY" or E.db.KlixUI.armory.ilvl.colorStyle == "LEVEL" or not E.db.KlixUI.armory.enable or not E.db.KlixUI.armory.ilvl.enable end,
						get = function(info)
							local t = E.db.KlixUI.armory.ilvl[ info[#info] ]
							local d = P.KlixUI.armory.ilvl[info[#info]]
							return t.r, t.g, t.b, t.a, d.r, d.g, d.b
						end,
						set = function(info, r, g, b)
							E.db.KlixUI.armory.ilvl[ info[#info] ] = {}
							local t = E.db.KlixUI.armory.ilvl[ info[#info] ]
							t.r, t.g, t.b, t.a = r, g, b, a
							E:StaticPopup_Show("PRIVATE_RL")
						end,
					},
				},
			},
			stats = {
				type = 'group',
				name = STAT_CATEGORY_ATTRIBUTES..E.NewSign,
				order = 7,
				disabled = function() return KUI._Compatibility["DejaCharacterStats"] or not E.db.KlixUI.armory.enable end,
				get = function(info) return E.db.KlixUI.armory.stats[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.armory.stats[ info[#info] ] = value; PaperDollFrame_UpdateStats() end,
				args = {
					IlvlFull = {
						order = 1,
						type = "toggle",
						name = L["Full Item Level"],
						desc = L["Show both equipped and average item levels."],
					},
					IlvlColor = {
						order = 2,
						type = "toggle",
						name = L["Item Level Coloring"],
						desc = L["Color code item levels values. Equipped will be gradient, average - selected color."],
						disabled = function() return KUI._Compatibility["DejaCharacterStats"] or not E.db.KlixUI.armory.enable or not E.db.KlixUI.armory.stats.IlvlFull end,
					},
					AverageColor = {
						type = 'color',
						order = 3,
						name = L["Color of Average"],
						desc = L["Sets the color of average item level."],
						hasAlpha = false,
						disabled = function() return KUI._Compatibility["DejaCharacterStats"] or not E.db.KlixUI.armory.enable or not E.db.KlixUI.armory.stats.IlvlFull or not E.db.KlixUI.armory.stats.IlvlColor end,
						get = function(info)
							local t = E.db.KlixUI.armory.stats[ info[#info] ]
							local d = E.db.KlixUI.armory.stats[info[#info]]
							return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
						end,
						set = function(info, r, g, b, a)
							E.db.KlixUI.armory.stats[ info[#info] ] = {}
							local t = E.db.KlixUI.armory.stats[ info[#info] ]
							t.r, t.g, t.b, t.a = r, g, b, a
							PaperDollFrame_UpdateStats()
						end,
					},
					OnlyPrimary = {
						order = 4,
						type = "toggle",
						name = L["Only Relevant Stats"],
						desc = L["Show only those primary stats relevant to your spec."],
					},
					Stats = {
						type = 'group',
						name = STAT_CATEGORY_ATTRIBUTES,
						order = 7,
						guiInline = true,
						get = function(info) return E.db.KlixUI.armory.stats.List[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.armory.stats.List[ info[#info] ] = value; KA:ToggleStats() end,
						args = {
							HEALTH = { order = 1,type = "toggle",name = HEALTH,},
							POWER = { order = 2,type = "toggle",name = _G[select(2, UnitPowerType("player"))],},
							ALTERNATEMANA = { order = 3,type = "toggle",name = ALTERNATE_RESOURCE_TEXT,},
							ATTACK_DAMAGE = { order = 4,type = "toggle",name = DAMAGE,},
							ATTACK_AP = { order = 5,type = "toggle",name = ATTACK_POWER,},
							ATTACK_ATTACKSPEED = { order = 6,type = "toggle",name = ATTACK_SPEED,},
							SPELLPOWER = { order = 7,type = "toggle",name = STAT_SPELLPOWER,},
							ENERGY_REGEN = { order = 8,type = "toggle",name = STAT_ENERGY_REGEN,},
							RUNE_REGEN = { order = 9,type = "toggle",name = STAT_RUNE_REGEN,},
							FOCUS_REGEN = { order = 10,type = "toggle",name = STAT_FOCUS_REGEN,},
							MOVESPEED = { order = 11,type = "toggle",name = STAT_SPEED,},
						},
					},
				},
			},
			Fonts = {
				type = "group",
				name = STAT_CATEGORY_ATTRIBUTES..": "..L["Fonts"]..E.NewSign,
				-- guiInline = true,
				order = 8,
				args = {
					IlvlFont = {
						type = 'group',
						name = STAT_AVERAGE_ITEM_LEVEL,
						order = 1,
						guiInline = true,
						get = function(info) return E.db.KlixUI.armory.stats.ItemLevel[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.armory.stats.ItemLevel[ info[#info] ] = value; KA:UpdateIlvlFont() end,
						args = {
							font = {
								type = 'select', dialogControl = 'LSM30_Font',
								name = L["Font"],
								order = 1,
								values = function()
									return AceGUIWidgetLSMlists and AceGUIWidgetLSMlists.font or {}
								end,
							},
							size = {
								type = 'range',
								name = L["Font Size"],
								order = 2,
								min = 6, max = 30, step = 1,
							},
							outline = {
								type = 'select',
								name = L["Font Outline"],
								order = 3,
								values = FontStyleList,
							},
						},
					},
					statFonts = {
						type = 'group',
						name = STAT_CATEGORY_ATTRIBUTES,
						order = 2,
						guiInline = true,
						get = function(info) return E.db.KlixUI.armory.stats.statFonts[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.armory.stats.statFonts[ info[#info] ] = value; KA:PaperDollFrame_UpdateStats() end,
						args = {
							font = {
								type = 'select', dialogControl = 'LSM30_Font',
								name = L["Font"],
								order = 1,
								values = function()
									return AceGUIWidgetLSMlists and AceGUIWidgetLSMlists.font or {}
								end,
							},
							size = {
								type = 'range',
								name = L["Font Size"],
								order = 2,
								min = 6,max = 22,step = 1,
							},
							outline = {
								type = 'select',
								name = L["Font Outline"],
								order = 3,
								values = FontStyleList,
							},
						},
					},
					catFonts = {
						type = 'group',
						name = L["Categories"],
						order = 3,
						guiInline = true,
						get = function(info) return E.db.KlixUI.armory.stats.catFonts[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.armory.stats.catFonts[ info[#info] ] = value; KA:PaperDollFrame_UpdateStats() end,
						args = {
							font = {
								type = 'select', dialogControl = 'LSM30_Font',
								name = L["Font"],
								order = 1,
								values = function()
									return AceGUIWidgetLSMlists and AceGUIWidgetLSMlists.font or {}
								end,
							},
							size = {
								type = 'range',
								name = L["Font Size"],
								order = 2,
								min = 6,max = 22,step = 1,
							},
							outline = {
								type = 'select',
								name = L["Font Outline"],
								order = 3,
								values = FontStyleList,
							},
						},
					},
				},
			},
		},
	}
end
tinsert(KUI.Config, ArmoryTable)