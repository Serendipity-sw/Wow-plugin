--All credtis go to Darth Predator for this code
local KUI, E, L, V, P, G = unpack(select(2, ...))
local lib = LibStub("LibElv-GameMenu-1.0")
local _G = _G
local HideUIPanel = HideUIPanel
local ReloadUI = ReloadUI

function KUI:BuildGameMenu()
	if not E.global.KlixUI.gameMenu then return end
	local buttons = {
		[1] = {
			["name"] = "GameMenu_KUIConfig",
			["text"] = KUI.Title,
			["func"] = function() E:ToggleConfig(); LibStub("AceConfigDialog-3.0-ElvUI"):SelectGroup("ElvUI", "KlixUI"); HideUIPanel(_G["GameMenuFrame"]) end,
		},
	}
	for i = 1, #buttons do
		lib:AddMenuButton(buttons[i])
	end

	lib:UpdateHolder()
end