local KUI, E, L, V, P, G = unpack(select(2, ...))

if E.db.KlixUI == nil then E.db.KlixUI = {} end
local select, pairs = select, pairs
local format = string.format
local tinsert, tsort, tconcat = table.insert, table.sort, table.concat

local CLASS_COLORS, CUSTOM, DEFAULT = CLASS_COLORS, CUSTOM, DEFAULT
local COLORS, COLOR_PICKER = COLORS, COLOR_PICKER
local StaticPopup_Show = StaticPopup_Show
local ReloadUI = ReloadUI

local DONATORS = {
	"Akiao",
	"Enii",
	"He Min",
}
tsort(DONATORS, function(a, b) return a < b end)
local DONATOR_STRING = tconcat(DONATORS, ", ")

--This function holds the options table which will be inserted into the ElvUI config
local function Core()
	local name = "|cfffe7b2cElvUI|r"..format(": |cff99ff33%s|r",E.version).." + |cfff960d9KlixUI|r"..format(": |cff99ff33%s|r", KUI.Version)
	E.Options.args.ElvUI_Header.name = name;
	local ACD = LibStub("AceConfigDialog-3.0-ElvUI")
	
	local function CreateButton(number, text, ...)
		local path = {}
		local num = select("#", ...)
		for i = 1, num do
			local name = select(i, ...)
			tinsert(path, #(path)+1, name)
		end
		local config = {
			order = number,
			type = 'execute',
			name = text,
			func = function() ACD:SelectGroup("ElvUI", "KlixUI", unpack(path)) end,
		}
		return config
	end
	
	E.Options.args.KlixUI = {
		order = 216,
		type = 'group',
		name = KUI.Title,
		desc = L["A plugin for |cff1784d1ElvUI|r by Klix (EU-Twisting Nether)"],
		args = {
			name = {
				order = 1,
				type = 'header',
				name = KUI.Title..L['v.']..KUI:cOption(KUI.Version)..L['by Klix (EU-Twisting Nether)'],
			},
			logo = {
				order = 2,
				type = 'description',
				name = L["KUI_DESC"]..E.NewSign,
				fontSize = 'medium',
				image = function() return 'Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\KlixUILogo.tga', 160, 160 end,
			},
			install = {
				order = 3,
				type = 'execute',
				name = L['Install'],
				desc = L['Run the installation process.'],
				func = function() E:GetModule('PluginInstaller'):Queue(KUI.installTable); E:ToggleConfig(); end,
			},
			reloadui = {
				order = 4,
				type = "execute",
				name = L["Reload"],
				desc = L['Reaload the UI'],
				func = function() ReloadUI() end,
			},
			changelog = {
				order = 5,
				type = "execute",
				name = L["Changelog"],
				desc = L['Open the changelog window.'],
				func = function() KUI:ToggleChangeLog(); E:ToggleConfig() end,
			},
			modulesButton = CreateButton(6, L["Modules"], "modules"),
			mediaButtonKlix = {
				order = 7,
				type = "execute",
				name = L["Media"],
				func = function() LibStub("AceConfigDialog-3.0-ElvUI"):SelectGroup("ElvUI", "KlixUI", "media") end,
				disabled = function() return IsAddOnLoaded("ElvUI_SLE") end,
				hidden = function() return IsAddOnLoaded("ElvUI_SLE") end,
			},
			mediaButtonSLE = {
				order = 7,
				type = "execute",
				name = L["Media"],
				func = function() LibStub("AceConfigDialog-3.0-ElvUI"):SelectGroup("ElvUI", "sle", "media") end,
				disabled = function() return not IsAddOnLoaded("ElvUI_SLE") end,
				hidden = function() return not IsAddOnLoaded("ElvUI_SLE") end,
			},
			skinsButton = CreateButton(8, L["Skins & AddOns"], "skins"),
			spacer2 = {
				order = 9,
				type = 'header',
				name = '',
			},
			general = {
				order = 10,
				type = 'group',
				name = KUI:cOption(L['General']),
				guiInline = true,
				get = function(info) return E.db.KlixUI.general[ info[#info] ] end,
				set = function(info, value) E.db.KlixUI.general[ info[#info] ] = value; E:StaticPopup_Show("PRIVATE_RL") end,
				args = {
					AFK = {
						order = 1,
						type = "toggle",
						name = L["AFK Screen"],
						desc = L["Enable/Disable the |cfff960d9KlixUI|r AFK Screen.\nCredit: |cff00c0faBenikUI|r"],
					},
					GameMenuScreen = {
						order = 2,
						type = "toggle",
						name = L["Game Menu Screen"],
						desc = L["Enable/Disable the |cfff960d9KlixUI|r Game Menu Screen.\nCredit: |cffff7d0aMerathilisUI|r"],
					},
					splashScreen = {
						order = 3,
						type = 'toggle',
						name = L['Splash Screen'],
						desc = L["Enable/Disable the |cfff960d9KlixUI|r Splash Screen.\nCredit: |cff00c0faBenikUI|r"],
					},
					loginMessage = {
						order = 4,
						type = 'toggle',
						name = L['Login Message'],
						desc = L["Enable/Disable the Login Message in Chat."],
					},
					gameMenuButton = {
						order = 5,
						type = "toggle",
						name = L["Game Menu Button"],
						desc = L["Show/Hide the |cfff960d9KlixUI|r Game Menu button"],
					},
				},
			},
			tweaks = {
				order = 15,
				type = 'group',
				name = KUI:cOption(L['Tweaks']),
				guiInline = true,
				args = {
					speedyLoot = {
						order = 1,
						type = "toggle",
						name = L["Speedy Loot"],
						desc = L["Enable/Disable faster corpse looting."],
						get = function(info) return E.global.KlixUI.speedyLoot end,
						set = function(info, value) E.global.KlixUI.speedyLoot = value; E:StaticPopup_Show("GLOBAL_RL") end,
					},
					easyDelete = {
						order = 2,
						type = "toggle",
						name = L["Easy Delete"],
						desc = L['Enable/Disable the ability to delete an item without the need of typing: "delete".'],
						get = function(info) return E.global.KlixUI.easyDelete end,
						set = function(info, value) E.global.KlixUI.easyDelete = value; E:StaticPopup_Show("GLOBAL_RL") end,
					},
					cinematic = {
						order = 10,
						type = "group",
						name = KUI:cOption(L["Cinematic"]),
						guiInline = true,
						get = function(info) return E.global.KlixUI.cinematic[ info[#info] ] end,
						set = function(info, value) E.global.KlixUI.cinematic[ info[#info] ] = value; E:StaticPopup_Show("GLOBAL_RL") end,
						args = {
							kill = {
								order = 1,
								type = "toggle",
								name = L["Skip Cut Scenes"],
								desc = L["Enable/Disable cut scenes."],
							},
							enableSound = {
								order = 2,
								type = "toggle",
								name = L["Cut Scenes Sound"],
								desc = L["Enable/Disable sounds when a cut scene pops.\n|cffff8000Note: This will only enable if you have your sound disabled.|r"],
								disabled = function() return E.global.KlixUI.cinematic.kill end,
							},
							talkingheadSound = {
								order = 3,
								type = "toggle",
								name = L["Talkinghead Sound"],
								desc = L["Enable/Disable sounds when the talkingheadframe pops.\n|cffff8000Note: This will only enable if you have your sound disabled."],
								disabled = function() return E.global.KlixUI.cinematic.kill or E.db.KlixUI.misc.talkingHead end,
							},
						},
					},
				},
			},
			modules = {
				order = 20,
				type = "group",
				childGroups = "select",
				name = L["Modules"],
				args = {
					info = {
						type = "description",
						order = 1,
						name = L["Here you find the options for all the different |cfff960d9KlixUI|r modules.\nPlease use the dropdown to navigate through the modules."],
					},
				},
			},
			info = {
				order = 2000,
				type = 'group',
				name = L['Information'],
				args = {
					name = {
						order = 1,
						type = "header",
						name = KUI.Title,
					},
					support = {
						order = 2,
						type = 'group',
						name = KUI:cOption(L['Support & Downloads']),
						guiInline = true,
						args = {
							kuidiscord = {
								order = 1,
								type = 'execute',
								name = L['KlixUI Discord Server'],
								func = function() E:StaticPopup_Show("DISCORD", nil, nil, "https://discord.gg/GbQbDRX") end,
							},
							tukuidiscord = {
								order = 2,
								type = "execute",
								name = L["Tukui.org Discord Server"],
								func = function() E:StaticPopup_Show("KLIXUI_CREDITS", nil, nil, "https://discord.gg/xFWcfgE") end,
							},
							git = {
								order = 3,
								type = 'execute',
								name = L['Git Ticket Tracker'],
								func = function() E:StaticPopup_Show("KLIXUI_CREDITS", nil, nil, "https://git.tukui.org/Klix/KlixUI/issues") end,
							},
							tukui = {
								order = 4,
								type = 'execute',
								name = L['Tukui.org'],
								func = function() E:StaticPopup_Show("KLIXUI_CREDITS", nil, nil, "https://www.tukui.org/addons.php?id=89") end,
							},
							curse = {
								order = 5,
								type = 'execute',
								name = L['Curseforge.com'],
								func = function() E:StaticPopup_Show("KLIXUI_CREDITS", nil, nil, "https://www.curseforge.com/wow/addons/elvui_klixui-2-0") end,
							},
							space1 = {
								order = 6,
								type = "description",
								name = "",
							},
							development = {
								order = 7,
								type = 'execute',
								name = L['Development Version'],
								desc = L['Here you can download the latest development version.'],
								func = function() E:StaticPopup_Show("KLIXUI_CREDITS", nil, nil, "https://git.tukui.org/Klix/KlixUI/repository/archive.zip?ref=development") end,
							},
							--beta = {
								--order = 8,
								--type = 'execute',
								--name = L['Beta Version'],
								--desc = L['Here you can download the Battle for Azeroth beta version.'],
								--func = function() E:StaticPopup_Show("KLIXUI_CREDITS", nil, nil, "https://git.tukui.org/Klix/KlixUI/repository/archive.zip?ref=beta") end,
							--},
						},
					},
					coding = {
						order = 3,
						type = "group",
						name = KUI:cOption(L["Coding"]),
						guiInline = true,
						args = {
							tukui = {
								order = 1,
								type = "description",
								fontSize = "medium",
								name = format("|cffffd200%s|r", "Blazeflack, Benik, Merathilis, Darth Predator and Simpy |cffff000a<3|r"),
							},
						},
					},
					testing = {
						order = 4,
						type = "group",
						name = KUI:cOption(L["Testing & Inspiration"]),
						guiInline = true,
						args = {
							tukui = {
								order = 1,
								type = "description",
								fontSize = "medium",
								name = format("|cffffd200%s|r", "Obscurrium, Akiao, Benik, Merathilis, Darth Predator, Skullflower & ElvUI community"),
							},
						},
					},
					donors = {
						order = 5,
						type = 'group',
						name = KUI:cOption(L['Donations']),
						guiInline = true,
						args = {
							tukui = {
								order = 1,
								type = 'description',
								fontSize = 'medium',
								name = format('|cffffd200%s|r', DONATOR_STRING)
							},
						},
					},
					locales = {
						order = 6,
						type = 'group',
						name = KUI:cOption(L['Localization']),
						guiInline = true,
						args = {
							tukui = {
								order = 1,
								type = 'description',
								fontSize = 'medium',
								name = format('|cffffd200%s|r', "Kringel - deDE")
							},
						},
					},
					addons = {
						order = 7,
						type = "group",
						name = KUI:cOption(L["My other Addons"]),
						guiInline = true,
						args = {
							sfui = {
								order = 1,
								type = "execute",
								name = L["|cfffb4f4fSkullflowers UI C.A|r"],
								desc = L["A continuation of the popular and highly demanded Skullflower UI."],
								func = function() E:StaticPopup_Show("KLIXUI_CREDITS", nil, nil, "https://www.tukui.org/addons.php?id=63") end,
							},
							sfuitp = {
								order = 2,
								type = "execute",
								name = L["|cfffb4f4fSkullflowers UI Texture Pack|r"],
								desc = L["Texture pack for all the Skullflower textures."],
								func = function() E:StaticPopup_Show("KLIXUI_CREDITS", nil, nil, "https://www.tukui.org/addons.php?id=97") end,
							},
							fow = {
								order = 3,
								type = "execute",
								name = L["ElvUI Fog Remover"],
								desc = L["Removes the fog from the World map, thus displaying the artwork for all the undiscovered zones, optionally with a color overlay on undiscovered areas."],
								func = function() E:StaticPopup_Show("KLIXUI_CREDITS", nil, nil, "https://www.tukui.org/addons.php?id=116") end,
							},
							ctc = {
								order = 4,
								type = "execute",
								name = L["ElvUI Chat Tweaks Continued"],
								desc = L["Chat Tweaks adds various enhancements to the default ElvUI chat."],
								func = function() E:StaticPopup_Show("KLIXUI_CREDITS", nil, nil, "https://www.tukui.org/addons.php?id=118") end,
							},
							curr = {
								order = 5,
								type = "execute",
								name = L["ElvUI Enhanced Currency"],
								desc = L["A simple yet enhanced currency datatext."],
								func = function() E:StaticPopup_Show("KLIXUI_CREDITS", nil, nil, "https://www.tukui.org/addons.php?id=125") end,
							},
							cp = {
								order = 6,
								type = "execute",
								name = L["ElvUI Compass Points"],
								desc = L["Adds cardinal points to the elvui minimap."],
								func = function() E:StaticPopup_Show("KLIXUI_CREDITS", nil, nil, "https://www.tukui.org/addons.php?id=123") end,
							},
							cg = {
								order = 7,
								type = "execute",
								name = L["|cfff2f251Cool Glow|r"],
								desc = L["Changes the actionbar proc glow to something cool!"],
								func = function() E:StaticPopup_Show("KLIXUI_CREDITS", nil, nil, "https://wow.curseforge.com/projects/cool-glow") end,
							},
							mqk = {
								order = 8,
								type = "execute",
								name = L["Masque: |cfff960d9KlixUI|r"],
								desc = L["My masque skin to match the UI."],
								func = function() E:StaticPopup_Show("KLIXUI_CREDITS", nil, nil, "https://wow.curseforge.com/projects/masque-klixui") end,
							},
						},
					},
					--[[version = {
						order = 8,
						type = "group",
						name = KUI:cOption(L["Version"]),
						guiInline = true,
						args = {
							version = {
								order = 1,
								type = "description",
								fontSize = "medium",
								name = KUI.Title..KUI.Version,
							},
						},
					},]]
				},
			},
		},
	}
end
tinsert(KUI.Config, Core)