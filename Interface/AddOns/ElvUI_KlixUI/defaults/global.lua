local KUI, E, L, V, P, G = unpack(select(2, ...))

if G["KlixUI"] == nil then G["KlixUI"] = {} end

G["KlixUI"] = {
	-- General
	["gameMenu"] = true,
	["speedyLoot"] = true,
	["easyDelete"] = true,
	["cinematic"] = {
		["kill"] = false,
		["enableSound"] = true,
		["talkingheadSound"] = true,
	},
}

