local KUI, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule("KuiSkins")
local S = E:GetModule("Skins")

--Cache global variables
local _G = _G
local pairs, unpack = pairs, unpack
--WoW API / Variables
--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS:

local r, g, b = unpack(E["media"].rgbvaluecolor)

local function styleStyleStackSplitFrame()
	if E.private.skins.blizzard.enable ~= true then return end

	local StackSplitFrame = _G["StackSplitFrame"]
	StackSplitFrame.backdrop:Styling()

	local buttons = {StackSplitFrame.LeftButton, StackSplitFrame.RightButton}
	for _, btn in pairs(buttons) do
		S:HandleNextPrevButton(btn)
		btn:Size(14, 18)

		btn:ClearAllPoints()
		if btn == StackSplitFrame.LeftButton then
			btn:Point('LEFT', StackSplitFrame.bg1, 'LEFT', 4, 0)
			btn.img:SetRotation(KS.ArrowRotation['LEFT'])
		else
			btn:Point('RIGHT', StackSplitFrame.bg1, 'RIGHT', -4, 0)
		end
	end
end

S:AddCallback("KuiStackSplitFrame", styleStyleStackSplitFrame)