local KUI, E, L, V, P, G = unpack(select(2, ...))
local KB = KUI:GetModule("KuiBags")
local B = E:GetModule("Bags")

local function BagTable()
	E.Options.args.KlixUI.args.modules.args.bags = {
		order = 5,
		type = 'group',
		name = KB.modName,
		childGroups = "tab",
		args = {
			name = {
				order = 1,
				type = "header",
				name = KUI:cOption(KB.modName),
			},
			general = {
				order = 2,
				type = "group",
				name = L["General"],
				get = function(info) return E.private.KlixUI.bags[ info[#info] ] end,
				set = function(info, value)	E.private.KlixUI.bags[ info[#info] ] = value; E:StaticPopup_Show('PRIVATE_RL') end,
				args = {
					transparentSlots = {
						order = 1,
						type = "toggle",
						name = L["Transparent Slots"],
						desc = L["Apply transparent template on bag and bank slots."],
						disabled = function() return not E.private.bags.enable end,
					},
					bagFilter = {
						order = 2,
						type = "toggle",
						name = L["Bag Filter"],
						desc = L["Enable/disable the bagfilter button."],
						disabled = function() return not E.private.bags.enable end,
					},
					autoOpen = {
						order = 3,
						type = "toggle",
						name = L["Auto Open Containers"],
						desc = L["Enable/disable the auto opening of container, treasure etc."],
					},
				},
			},
		},
	}
end
tinsert(KUI.Config, BagTable)