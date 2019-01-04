local KUI, E, L, V, P, G = unpack(select(2, ...))
local KUF = KUI:GetModule("KUIUnits")
local DA = KUI:GetModule("DebuffsAlert")
local KUIC = E:GetModule('KuiCastbar')
local UF = E:GetModule("UnitFrames")

-- Cache global variables
-- Lua functions
local _G = _G
local type = type
local pairs = pairs
local tonumber = tonumber
local tostring = tostring
local match = string.match
local format = string.format
-- WoW API / Variables
local IsAddOnLoaded = IsAddOnLoaded
local GetSpellInfo = GetSpellInfo
local COLOR = COLOR

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: LibStub

local filters = {}
local enableReset = false
local selectedSpell
local isEnabled = E.private["unitframe"].enable and true or false
local texPath = [[Interface\AddOns\ElvUI_KlixUI\media\textures\roleIcons\]]
local texPathE = [[Interface\AddOns\ElvUI\media\textures\]]
local texPathR = [[Interface\RaidFrame\]]
local texPathB = [[Interface\AddOns\ElvUI_KlixUI\media\textures\readycheckIcons\]]
local texPathS = [[Interface\AddOns\ElvUI_KlixUI\media\textures\readycheckIcons\]]

local function UnitFramesTable()
	E.Options.args.KlixUI.args.modules.args.unitframes = {
		order = 31,
		type = "group",
		name = KUF.modName,
		childGroups = 'tab',
		disabled = function() return not E.private.unitframe.enable end,
		args = {
			name = {
				order = 1,
				type = "header",
				name = KUI:cOption(KUF.modName),
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
					powerBar = {
						type = 'toggle',
						order = 1,
						name = L['Power Bar'],
						desc = L['This will enable/disable the |cfff960d9KlixUI|r powerbar modification.|r'],
						get = function(info) return E.db.KlixUI.unitframes.powerBar end,
						set = function(info, value) E.db.KlixUI.unitframes.powerBar = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					},
					powerBackdrop = {
						type = 'toggle',
						order = 2,
						name = L['Power Bar Backdrop'],
						desc = L['This will enable/disable the |cfff960d9KlixUI|r powerbar backdrop modification.|r'],
						get = function(info) return E.db.KlixUI.unitframes.powerBarBackdrop end,
						set = function(info, value) E.db.KlixUI.unitframes.powerBarBackdrop = value; E:StaticPopup_Show("PRIVATE_RL"); end,
					},
				},
			},
			auras = {
				order = 4,
				type = "group",
				name = L["Auras"],
				childGroups = 'tab',
				args = {
					auraiconspacing = {
						order = 1,
						type = "group",
						name = L["Aura Icon Spacing"],
						args = {
							spacing = {
								type = 'range',
								order = 1,
								name = L["Aura Spacing"],
								desc = L["Sets space between individual aura icons."],
								get = function(info) return E.db.KlixUI.unitframes.AuraIconSpacing.spacing end,
								set = function(info, value) E.db.KlixUI.unitframes.AuraIconSpacing.spacing = value; KUF:UpdateAuraSettings(); end,
								disabled = function() return not isEnabled end,
								min = 0, max = 10, step = 1,
							},
							units = {
								type = "multiselect",
								order = 2,
								name = L["Set Aura Spacing On Following Units"],
								get = function(info, key) return E.db.KlixUI.unitframes.AuraIconSpacing.units[key] end,
								set = function(info, key, value) E.db.KlixUI.unitframes.AuraIconSpacing.units[key] = value; KUF:UpdateAuraSettings(); end,
								disabled = function() return not isEnabled end,
								values = {
									['player'] = L["Player"],
									['target'] = L["Target"],
									['targettarget'] = L["TargetTarget"],
									['targettargettarget'] = L["TargetTargetTarget"],
									['focus'] = L["Focus"],
									['focustarget'] = L["FocusTarget"],
									['pet'] = L["Pet"],
									['pettarget'] = L["PetTarget"],
									['arena'] = L["Arena"],
									['boss'] = L["Boss"],
									['party'] = L["Party"],
									['raid'] = L["Raid"],
									['raid40'] = L["Raid40"],
									['raidpet'] = L["RaidPet"],
									["tank"] = L["Tank"],
									["assist"] = L["Assist"],
								},
							},
						},
					},
					auraicontext = {
						order = 2,
						type = "group",
						name = L["Aura Icon Text"],
						get = function(info) return E.db.KlixUI.unitframes.AuraIconText[info[#info]] end,
						set = function(info, value) E.db.KlixUI.unitframes.AuraIconText[info[#info]] = value; E:StaticPopup_Show("CONFIG_RL"); end,
						args = {
							dur = {
								order = 1,
								type = "group",
								name = L["Duration Text"],
								guiInline = true,
								args = {
									hideDurationText = {
										order = 1,
										type = "toggle",
										name = L["Hide Text"],
										set = function(info, value) E.db.KlixUI.unitframes.AuraIconText.hideDurationText = value; end,
										disabled = function() return not isEnabled end,
									},
									durationFilterOwner = {
										order = 2,
										type = "toggle",
										name = L["Hide From Others"],
										desc = L["Will hide duration text on auras that are not cast by you."],
										set = function(info, value) E.db.KlixUI.unitframes.AuraIconText.durationFilterOwner = value; end,
										disabled = function() return (not isEnabled or E.db.KlixUI.unitframes.AuraIconText.hideDurationText) end,
									},
									durationThreshold = {
										order = 3,
										type = "range",
										name = L["Threshold"],
										desc = L["Duration text will be hidden until it reaches this threshold (in seconds). Set to -1 to always show duration text."],
										set = function(info, value) E.db.KlixUI.unitframes.AuraIconText.durationThreshold = value; end,
										disabled = function() return (not isEnabled or E.db.KlixUI.unitframes.AuraIconText.hideDurationText) end,
										min = -1, max = 60, step = 1,
									},
									durationTextPos = {
										order = 4,
										type = "select",
										name = L["Position"],
										desc = L["Position of the duration text on the aura icon."],
										disabled = function() return not isEnabled end,
										values = {
											["BOTTOMLEFT"] = L["Bottom Left"],
											["BOTTOMRIGHT"] = L["Bottom Right"],
											["TOPLEFT"] = L["Top Left"],
											["TOPRIGHT"] = L["Top Right"],
											["CENTER"] = L["Center"],
										},
									},
									durationTextOffsetX = {
										order = 5,
										type = "range",
										name = L["X-Offset"],
										disabled = function() return not isEnabled end,
										min = -20, max = 20, step = 1,
									},
									durationTextOffsetY = {
										order = 6,
										type = "range",
										name = L["Y-Offset"],
										disabled = function() return not isEnabled end,
										min = -20, max = 20, step = 1,
									},
								},
							},
							stack = {
								order = 2,
								type = "group",
								name = L["Stack Text"],
								guiInline = true,
								args = {
									hideStackText = {
										order = 1,
										type = "toggle",
										name = L["Hide Text"],
										set = function(info, value) E.db.KlixUI.unitframes.AuraIconText.hideStackText = value; end,
										disabled = function() return not isEnabled end,
									},
									stackFilterOwner = {
										order = 2,
										type = "toggle",
										name = L["Hide From Others"],
										desc = L["Will hide stack text on auras that are not cast by you."],
										set = function(info, value) E.db.KlixUI.unitframes.AuraIconText.stackFilterOwner = value; end,
										disabled = function() return (not isEnabled or E.db.KlixUI.unitframes.AuraIconText.hideStackText) end,
									},
									stackTextPos = {
										order = 3,
										type = "select",
										name = L["Position"],
										desc = L["Position of the stack count on the aura icon."],
										disabled = function() return not isEnabled end,
										values = {
											["BOTTOMLEFT"] = L["Bottom Left"],
											["BOTTOMRIGHT"] = L["Bottom Right"],
											["TOPLEFT"] = L["Top Left"],
											["TOPRIGHT"] = L["Top Right"],
											["CENTER"] = L["Center"],
										},
									},
									spacer = {
										order = 4,
										type = "description",
										name = "",
									},
									stackTextOffsetX = {
										order = 5,
										type = "range",
										name = L["X-Offset"],
										disabled = function() return not isEnabled end,
										min = -20, max = 20, step = 1,
									},
									stackTextOffsetY = {
										order = 6,
										type = "range",
										name = L["Y-Offset"],
										disabled = function() return not isEnabled end,
										min = -20, max = 20, step = 1,
									},
								},
							},
						},
					},
				},
			},
			textures = {
				order = 6,
				type = 'group',
				name = L['Textures'],
				args = {
					health = {
						type = 'select', dialogControl = 'LSM30_Statusbar',
						order = 1,
						name = L['Health'],
						desc = L['Health statusbar texture. Applies only on Group Frames'],
						values = AceGUIWidgetLSMlists.statusbar,
						get = function(info) return E.db.KlixUI.unitframes.textures[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.unitframes.textures[ info[#info] ] = value; KUF:ChangeHealthBarTexture() end,
					},
					ignoreTransparency = {
						type = 'toggle',
						order = 2,
						name = L['Ignore Transparency'],
						desc = L['This will ignore ElvUI Health Transparency setting on all Group Frames.'],
						get = function(info) return E.db.KlixUI.unitframes.textures[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.unitframes.textures[ info[#info] ] = value; UF:Update_AllFrames(); end,
					},
					spacer = {
						order = 3,
						type = 'header',
						name = '',
					},
					power = {
						type = 'select', dialogControl = 'LSM30_Statusbar',
						order = 4,
						name = L['Power'],
						desc = L['Power statusbar texture.'],
						values = AceGUIWidgetLSMlists.statusbar,
						get = function(info) return E.db.KlixUI.unitframes.textures[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.unitframes.textures[ info[#info] ] = value; KUF:ChangePowerBarTexture() end,
					},
					spacer1 = {
						order = 5,
						type = 'header',
						name = '',
					},
					castbar = {
						type = 'select', dialogControl = 'LSM30_Statusbar',
						order = 6,
						name = L['Castbar'],
						desc = L['This applies on all available castbars.'],
						values = AceGUIWidgetLSMlists.statusbar,
						get = function(info) return E.db.KlixUI.unitframes.textures[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.unitframes.textures[ info[#info] ] = value; KUIC:CastBarHooks(); end,
					},
				},
			},
			castbar = {
				order = 8,
				type = 'group',
				name = L['Castbar Text'].." ("..PLAYER.."/"..TARGET..")",
				get = function(info) return E.db.KlixUI.unitframes.castbar.text[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.unitframes.castbar.text[ info[#info] ] = value; KUIC:UpdateAllCastbars(); end,
				args = {
					ShowInfoText = {
						type = 'toggle',
						order = 1,
						name = L['Show InfoPanel text'],
						desc = L['Force show any text placed on the InfoPanel, while casting.'],
					},
					castText = {
						type = 'toggle',
						order = 2,
						name = L['Show Castbar text'],
					},
					forceTargetText = {
						type = 'toggle',
						order = 3,
						name = L['Show on Target'],
						disabled = function() return E.db.KlixUI.unitframes.castbar.text.castText end,
					},
					player = {
						order = 4,
						type = 'group',
						name = PLAYER,
						args = {
							yOffset = {
								order = 1,
								type = 'range',
								name = L['Y Offset'],
								desc = L['Adjust castbar text Y Offset'],
								min = -40, max = 40, step = 1,
								get = function(info) return E.db.KlixUI.unitframes.castbar.text.player[ info[#info] ] end,
								set = function(info, value) E.db.KlixUI.unitframes.castbar.text.player[ info[#info] ] = value; KUIC:UpdateAllCastbars(); end,
							},
							textColor = {
								order = 2,
								type = "color",
								name = L["Text Color"],
								hasAlpha = true,
								get = function(info)
									local t = E.db.KlixUI.unitframes.castbar.text.player[ info[#info] ]
									local d = P.KlixUI.unitframes.castbar.text.player[info[#info]]
									return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
									end,
								set = function(info, r, g, b, a)
									E.db.KlixUI.unitframes.castbar.text.player[ info[#info] ] = {}
									local t = E.db.KlixUI.unitframes.castbar.text.player[ info[#info] ]
									t.r, t.g, t.b, t.a = r, g, b, a
									KUIC:CastBarHooks();
								end,
							},
						},
					},
					target = {
						order = 5,
						type = 'group',
						name = TARGET,
						args = {
							yOffset = {
								order = 1,
								type = 'range',
								name = L['Y Offset'],
								desc = L['Adjust castbar text Y Offset'],
								min = -40, max = 40, step = 1,
								get = function(info) return E.db.KlixUI.unitframes.castbar.text.target[ info[#info] ] end,
								set = function(info, value) E.db.KlixUI.unitframes.castbar.text.target[ info[#info] ] = value; KUIC:UpdateAllCastbars(); end,
							},
							textColor = {
								order = 2,
								type = "color",
								name = L["Text Color"],
								hasAlpha = true,
								get = function(info)
									local t = E.db.KlixUI.unitframes.castbar.text.target[ info[#info] ]
									local d = P.KlixUI.unitframes.castbar.text.target[info[#info]]
									return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
									end,
								set = function(info, r, g, b, a)
									E.db.KlixUI.unitframes.castbar.text.target[ info[#info] ] = {}
									local t = E.db.KlixUI.unitframes.castbar.text.target[ info[#info] ]
									t.r, t.g, t.b, t.a = r, g, b, a
									KUIC:CastBarHooks();
								end,
							},
						},
					},
				},
			},
			icons = {
				order = 10,
				type = 'group',
				name = L['Icons'],
				args = {
					role = {
						order = 1,
						type = "select",
						name = L["LFG Icons"],
						desc = L["Choose what icon set there will be used on unitframes and in the chat."],
						disabled = function() return IsAddOnLoaded("ElvUI_SLE") end,
						hidden = function() return IsAddOnLoaded("ElvUI_SLE") end,
						get = function(info) return E.db.KlixUI.unitframes.icons.role end,
						set = function(info, value) E.db.KlixUI.unitframes.icons.role = value; E:GetModule('Chat'):CheckLFGRoles(); UF:UpdateAllHeaders() end,
						values = {
							["ElvUI"] = "ElvUI ".."|T"..texPathE.."tank:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathE.."healer:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathE.."dps:15:15:0:0:64:64:2:56:2:56|t ",
							["SupervillainUI"] = "Supervillain UI ".."|T"..texPath.."svui-tank:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPath.."svui-healer:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPath.."svui-dps:15:15:0:0:64:64:2:56:2:56|t ",
							["Blizzard"] = "Blizzard ".."|T"..texPath.."blizz-tank:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPath.."blizz-healer:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPath.."blizz-dps:15:15:0:0:64:64:2:56:2:56|t ",
							["MiirGui"] = "MiirGui ".."|T"..texPath.."mg-tank:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPath.."mg-healer:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPath.."mg-dps:15:15:0:0:64:64:2:56:2:56|t ",
							["Lyn"] = "Lyn ".."|T"..texPath.."lyn-tank:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPath.."lyn-healer:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPath.."lyn-dps:15:15:0:0:64:64:2:56:2:56|t ",
						},
					},
					rdy = {
						order = 1,
						type = "select",
						name = L["ReadyCheck Icons"],
						desc = L["Choose what icon set there will be used on unitframes and in the chat."],
						get = function(info) return E.db.KlixUI.unitframes.icons.rdy end,
						set = function(info, value) E.db.KlixUI.unitframes.icons.rdy = value; E:StaticPopup_Show("PRIVATE_RL"); end,
						values = {
							["Default"] = "Default ".."|T"..texPathR.."ReadyCheck-Ready:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathR.."ReadyCheck-NotReady:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathR.."ReadyCheck-Waiting:15:15:0:0:64:64:2:56:2:56|t ",
							["BenikUI"] = "Benik UI ".."|T"..texPathB.."bui-ready:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathB.."bui-notready:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathB.."bui-waiting:15:15:0:0:64:64:2:56:2:56|t ",
							["Smiley"] = "Smiley ".."|T"..texPathS.."smiley-ready:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathS.."smiley-notready:15:15:0:0:64:64:2:56:2:56|t ".."|T"..texPathS.."smiley-waiting:15:15:0:0:64:64:2:56:2:56|t ",
						},
					},
					klixri = {
						order = 2,
						type = 'toggle',
						name = L['|cfff960d9KlixUI|r Raid Icons'],
						desc = L['Replaces the default Raid Icons with the |cfff960d9KlixUI|r ones.\n|cffff8000Note: The Raid Icons Set can be changed in the |cfff960d9KlixUI|r |cffff8000Raid Markers option.|r'],
						get = function(info) return E.db.KlixUI.unitframes.icons[ info[#info] ] end,
						set = function(info, value) E.db.KlixUI.unitframes.icons[ info[#info] ] = value; E:StaticPopup_Show('PRIVATE_RL'); end,
					},
				},
			},
		},
	}
end
tinsert(KUI.Config, UnitFramesTable)

local function UpdateFilterGroup()
	--Prevent errors when choosing a new filter, by doing a reset of the groups
	E.Options.args.KlixUI.args.modules.args.unitframes.args.debuffsAlert.args.filterGroup = nil
	E.Options.args.KlixUI.args.modules.args.unitframes.args.debuffsAlert.args.resetGroup = nil
	
	E.Options.args.KlixUI.args.modules.args.unitframes.args.debuffsAlert = {
		order = 5,
		type = "group",
		name = L["Debuffs Alert"],
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
						name = format("|cff1783d1ElvUI_DebuffsAlert (by Lifeismystery)|r"),
					},
				},
			},
			spacer = {
				order = 2,
				type = "description",
				name = "",
			},			
			desc = {
				order = 3,
				type = 'description',
				name = L["Color the unit healthbar if there is a debuff from this filter"],
			},
			spacer = {
				order = 4,
				type = "description",
				name = "",
			},
			enable = {
				order = 5,
				type = "toggle",
				name = L["Enable"],
				get = function(info) return E.db.KlixUI.unitframes.debuffsAlert.enable end,
				set = function(info, value) E.db.KlixUI.unitframes.debuffsAlert.enable = value 
				end,
			},
			default_color = {
				order = 6,
				type = 'color',
				name = L["Default Color"],
				hasAlpha = false,
				get = function(info)
					local t = E.db.KlixUI.unitframes.debuffsAlert.default_color
					return t.r, t.g, t.b, t.a
				end,
				set = function(info, r, g, b)
					local t = E.db.KlixUI.unitframes.debuffsAlert.default_color
					t.r, t.g, t.b = r, g, b
					DA:filter_update();
					UF:Update_AllFrames();
				end,
			},
			filterGroup = {
				order = 7,
				type = 'group',
				name = L["Filters Page"],
				guiInline = true,
				disabled = function() return not E.db.KlixUI.unitframes.debuffsAlert.enable end,
				get = function(info) return E.db.KlixUI.unitframes.debuffsAlert.DA_filter[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.unitframes.debuffsAlert.DA_filter[ info[#info] ] = value end,
				args = {
					addSpell = {
						order = 1,
						name = L["Add Spell ID or Name"],
						desc = L["Add a spell to the filter. Use spell ID if you don't want to match all auras which share the same name."],
						type = 'input',
						get = function(info) return "" end,
						set = function(info, value)
							if tonumber(value) then value = tonumber(value) end
							E.db.KlixUI.unitframes.debuffsAlert.DA_filter[value] = {enable = true, use_color = true, color = {r = 0.8, g = 0, b = 0}};
							selectedSpell = value;
					end,
					},
					removeSpell = {
						order = 2,
						name = L["Remove Spell ID or Name"],
						desc = L["Remove a spell from the filter. Use the spell ID if you see the ID as part of the spell name in the filter."],
						type = 'input',
						get = function(info) return "" end,
						set = function(info, value)
							if tonumber(value) then value = tonumber(value) end
							E.db.KlixUI.unitframes.debuffsAlert.DA_filter[value] = nil;
							selectedSpell = nil;
							UF:Update_AllFrames();
					end,
					},
					selectSpell = {
						name = L["Select Spell"],
						type = 'select',
						order = 10,
						width = "double",
						get = function(info) return selectedSpell end,
						set = function(info, value) selectedSpell = value; 
						UpdateFilterGroup(); 
						end,
						values = function() 
							for filter in pairs(E.db.KlixUI.unitframes.debuffsAlert.DA_filter) do
								if tonumber(filter) then
									local spellName = GetSpellInfo(filter)
									if spellName then
										filter = format("%s (%s)", spellName, filter)
									else
										filter = tostring(filter)
									end
								end
								filters[filter] = filter
							end
							return filters
							
						end,
					},
				},	
			},	
			resetGroup = {
				type = "group",
				name = L["Reset Filter"],
				order = 25,
				guiInline = true,
				args = {
					enableReset = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						get = function(info) return enableReset end,
						set = function(info, value) enableReset = value; end,
					},
					resetFilter = {
						order = 2,
						type = "execute",
						buttonElvUI = true,
						name = L["Reset Filter"],
						desc = L["This will reset the contents of this filter back to default. Any spell you have added to this filter will be removed.\n|cffff8000Note: Please reloadUI after resetting the filters.|r"],
						disabled = function() return not enableReset end,
						func = function(info)
							E.db.KlixUI.unitframes.debuffsAlert.DA_filter = {};
							selectedSpell = nil;
							enableReset = false;
							UpdateFilterGroup();
							UF:Update_AllFrames();
						end,
					},
				},
			},
		},	
	}

	local spellID = selectedSpell and match(selectedSpell, "(%d+)")
	if spellID then spellID = tonumber(spellID) end
	
	if not selectedSpell or E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)] == nil then
		E.Options.args.KlixUI.args.modules.args.unitframes.args.debuffsAlert.args.filterGroup.args.spellGroup = nil
		return
	end

	E.Options.args.KlixUI.args.modules.args.unitframes.args.debuffsAlert.args.filterGroup.args.spellGroup = {
		order = 15,
		type = 'group',
		name = tostring(selectedSpell),
		guiInline = true,
		args = {
			enable = {
				order = 0,
				type = "toggle",
				name = L["Enable"],
				get = function(info) 
					return E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)].enable 
				end,
				set = function(info, value)
					E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)].enable = value
					UF:Update_AllFrames();
				end,
			},
			color = {
				order = 2,
				type = 'color',
				name = COLOR,
				hasAlpha = false,
				visible=false,
				disabled = function() return not E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)].use_color end,
				get = function(info)
						local t = E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)].color
						return t.r, t.g, t.b
				end,
				set = function(info, r, g, b)
					local t = E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)].color
					t.r, t.g, t.b = r, g, b
					UF:Update_AllFrames();
			end,
			},
			use_color = {
				name = L["Enable"],
				order = 1,
				type = "toggle",
				name = L["special color"],
				get = function(info) 
					return E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)].use_color 
				end,
				set = function(info, value)
					E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)].use_color = value
					DA:filter_update();
					UF:Update_AllFrames();
				end,
			},
		},
	}

	UF:Update_AllFrames();
end

local function DebuffsHighlight()
	
	E.Options.args.KlixUI.args.modules.args.unitframes.args.debuffsAlert = {
		order = 5,
		type = 'group',
		name = L["Debuffs Alert"],
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
						name = format("|cff1783d1ElvUI_DebuffsAlert (by Lifeismystery)|r"),
					},
				},
			},
			spacer = {
				order = 2,
				type = "description",
				name = "",
			},			
			desc = {
				order = 3,
				type = 'description',
				name = L["Color the unit healthbar if there is a debuff from this filter"],
			},
			spacer = {
				order = 4,
				type = "description",
				name = "",
			},
			enable = {
				order = 4,
				type = "toggle",
				name = L["Enable"],
				get = function(info) return E.db.KlixUI.unitframes.debuffsAlert.enable end,
				set = function(info, value) E.db.KlixUI.unitframes.debuffsAlert.enable = value;
				UF:Update_AllFrames();
				end,
			},
			default_color = {
				order = 6,
				type = 'color',
				name = L["Default Color"],
				hasAlpha = false,
				get = function(info)
					local t = E.db.KlixUI.unitframes.debuffsAlert.default_color
					local d = P.KlixUI.unitframes.debuffsAlert.default_color
					return t.r, t.g, t.b, t.a, d.r, d.g, d.b
				end,
				set = function(info, r, g, b)
					E.db.KlixUI.unitframes.debuffsAlert.default_color = {}
					local t = E.db.KlixUI.unitframes.debuffsAlert.default_color
					t.r, t.g, t.b = r, g, b
					DA:filter_update();
					UpdateFilterGroup();
				end,
			},
			filterGroup = {
				order = 7,
				type = 'group',
				name = L["Filters Page"],
				guiInline = true,
				disabled = function() return not E.db.KlixUI.unitframes.debuffsAlert.enable end,
				get = function(info) return E.db.KlixUI.unitframes.debuffsAlert.DA_filter[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.unitframes.debuffsAlert.DA_filter[ info[#info] ] = value end,
				args = {
					addSpell = {
						order = 1,
						name = L["Add Spell ID or Name"],
						desc = L["Add a spell to the filter. Use spell ID if you don't want to match all auras which share the same name."],
						type = 'input',
						get = function(info) return "" end,
						set = function(info, value)
							if tonumber(value) then value = tonumber(value) end
							E.db.KlixUI.unitframes.debuffsAlert.DA_filter[value] = {enable = true, use_color = false, color = {r = 0.8, g = 0, b = 0}}
							selectedSpell = value;
							UpdateFilterGroup();
					end,
					},
					removeSpell = {
						order = 2,
						name = L["Remove Spell ID or Name"],
						desc = L["Remove a spell from the filter. Use the spell ID if you see the ID as part of the spell name in the filter."],
						type = 'input',
						get = function(info) return "" end,
						set = function(info, value)
							if tonumber(value) then value = tonumber(value) end
							E.db.KlixUI.unitframes.debuffsAlert.DA_filter[value] = nil;
							selectedSpell = nil;
							UpdateFilterGroup();
					end,
					},
					selectSpell = {
						name = L["Select Spell"],
						type = 'select',
						order = 3,
						width = "double",
						get = function(info) return selectedSpell end,
						set = function(info, value) selectedSpell = value; 
						UpdateFilterGroup() 
						end,
						values = function()
							for filter in pairs(E.db.KlixUI.unitframes.debuffsAlert.DA_filter) do
								if tonumber(filter) then
									local spellName = GetSpellInfo(filter)
									if spellName then
										filter = format("%s (%s)", spellName, filter)
									else
										filter = tostring(filter)
									end
								end
								filters[filter] = filter
							end
							return filters
						end,
					},
				},	
			},
			resetGroup = {
				type = "group",
				name = L["Reset Filter"],
				order = 25,
				guiInline = true,
				args = {
					enableReset = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						get = function(info) return enableReset end,
						set = function(info, value) enableReset = value; end,
					},
					resetFilter = {
						order = 2,
						type = "execute",
						buttonElvUI = true,
						name = L["Reset Filter"],
						desc = L["This will reset the contents of this filter back to default. Any spell you have added to this filter will be removed.\n|cffff8000Note: Please reloadUI after resetting the filters.|r"],
						disabled = function() return not enableReset end,
						func = function(info)
							E.db.KlixUI.unitframes.debuffsAlert.DA_filter = {};
							selectedSpell = nil;
							enableReset = false;
							UpdateFilterGroup();
							UF:Update_AllFrames();
						end,
					},
				},
			},
		},	
	}
	
	local spellID = selectedSpell and match(selectedSpell, "(%d+)")
	if spellID then spellID = tonumber(spellID) end
	
	if not selectedSpell or E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)] == nil then
		E.Options.args.KlixUI.args.modules.args.unitframes.args.debuffsAlert.args.filterGroup.args.spellGroup = nil
		return
	end
	
	E.Options.args.KlixUI.args.modules.args.unitframes.args.debuffsAlert.args.filterGroup.args.spellGroup = {
		order = 15,
		type = 'group',
		name = tostring(selectedSpell),
		guiInline = true,
		args = {
			enable = {
				order = 0,
				type = "toggle",
				name = L["Enable"],
				get = function(info) 
					return E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)].enable 
				end,
				set = function(info, value)
					E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)].enable = value
					UpdateFilterGroup();
					UF:Update_AllFrames();
				end,
			},
			color = {
				order = 2,
				type = 'color',
				name = COLOR,
				visible=false,
				hasAlpha = false,
				disabled = function() return not E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)].use_color end,
				get = function(info)
					local t = E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)].color
					return t.r, t.g, t.b
				end,
				set = function(info, r, g, b)
					local t = E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)].color
					t.r, t.g, t.b = r, g, b
					UpdateFilterGroup();
			end,
			},
			use_color = {
				name = L["Enable"],
				order = 1,
				type = "toggle",
				name = L["use special color"],
				get = function(info) 
					return E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)].use_color 
				end,
				set = function(info, value)
					E.db.KlixUI.unitframes.debuffsAlert.DA_filter[(spellID or selectedSpell)].use_color = value
					DA:filter_update();
					UpdateFilterGroup();
				end,
			}
		}
	}
	
	if not E.db.KlixUI.unitframes.debuffsAlert.enable or not E.private.unitframe.enable then return end
end
tinsert(KUI.Config, DebuffsHighlight)