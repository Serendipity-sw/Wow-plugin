local KUI, E, L, V, P, G = unpack(select(2, ...))
local KB = KUI:NewModule("KuiBags", 'AceHook-3.0', 'AceEvent-3.0');
local KS = KUI:GetModule("KuiSkins")
local S = E:GetModule("Skins")
local B = E:GetModule('Bags')
KB.modName = L["Bags"]

--GLOBALS: hooksecurefunc
local _G = _G
local pairs, ipairs = pairs, ipairs
local floor = math.floor
local GetContainerNumSlots = GetContainerNumSlots

-- Styling
function KB:SkinBags()
	if ElvUI_ContainerFrame then
		ElvUI_ContainerFrame:Styling()
		ElvUI_ContainerFrameContainerHolder:Styling()
	end

	if ElvUIBags then
		ElvUIBags.backdrop:Styling()
	end
end

function KB:SkinBank()
	if ElvUI_BankContainerFrame then
		ElvUI_BankContainerFrame:Styling()
		ElvUI_BankContainerFrameContainerHolder:Styling()
	end
end

function KB:AllInOneBags()
	self:SkinBags()
	self:RegisterEvent('BANKFRAME_OPENED', 'SkinBank')
end

function KB:SkinBlizzBags()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bags ~= true or E.private.bags.enable then return end

	for i = 1, NUM_CONTAINER_FRAMES, 1 do
		local container = _G['ContainerFrame'..i]
		if container.backdrop then
			container.backdrop:Styling()
		end
	end
	if BankFrame then
		BankFrame:Styling()
	end
end

function KB:GUILDBANKFRAME_OPENED()
	OpenAllBags()
end

function KB:GUILDBANKFRAME_CLOSED()
	ContainerFrame1.backpackWasOpen = nil
	CloseAllBags()
end

function KB:AUCTION_HOUSE_SHOW()
	OpenAllBags()
end

function KB:AUCTION_HOUSE_CLOSED()
	ContainerFrame1.backpackWasOpen = nil
	CloseAllBags()
end

function KB:TRADE_SHOW()
	OpenAllBags()
end

function KB:TRADE_CLOSED()
	ContainerFrame1.backpackWasOpen = nil
	CloseAllBags()
end

function KB:OBLITERUM_FORGE_SHOW()
	OpenAllBags()
end

function KB:OBLITERUM_FORGE_CLOSE()
	ContainerFrame1.backpackWasOpen = nil
	CloseAllBags()
end

function KB:HookBags(isBank)
	local slot
	for _, bagFrame in pairs(B.BagFrames) do
		--Applying transparent template for all current slots
		for _, bagID in pairs(bagFrame.BagIDs) do
			for slotID = 1, GetContainerNumSlots(bagID) do
				if bagFrame.Bags[bagID] then
					slot = bagFrame.Bags[bagID][slotID];
					if E.private.KlixUI.bags.transparentSlots and slot.template ~= "Transparent" then slot:SetTemplate('Transparent') end
				end
			end
		end
	end
	--Applying transparent template for reagent bank
	if E.private.KlixUI.bags.transparentSlots and _G["ElvUIReagentBankFrameItem1"] and _G["ElvUIReagentBankFrameItem1"].template ~= "Transparent" then
		for slotID = 1, 98 do
			local slot = _G["ElvUIReagentBankFrameItem"..slotID];
			if slot.template ~= "Transparent" then slot:SetTemplate('Transparent') end
		end
	end
end

-- Add Scrap junk icon on bag slot
local function UpdateSlot(self, bagID, slotID)
	if IsAddOnLoaded("Scrap") and E.private.bags.enable then
		if (self.Bags[bagID] and self.Bags[bagID].numSlots ~= GetContainerNumSlots(bagID)) or not self.Bags[bagID] or not self.Bags[bagID][slotID] then
			return;
		end
			
		local slot = self.Bags[bagID][slotID]
		local link = GetContainerItemLink(bagID, slotID);
		local id
		if link then
			id = tonumber(strmatch(link, 'item:(%d+)'))
		end
			
		if slot.JunkIcon then
			if id and Scrap:IsJunk(id, bagID, slotID) then
				slot.JunkIcon:SetShown(Scrap_Icons)
			else
				slot.JunkIcon:Hide()
			end
		end
	end
end
hooksecurefunc(B, "UpdateSlot", UpdateSlot)

-- Function we can call to update all bag slots
local function UpdateBags()
	B:UpdateAllBagSlots()
end

-- Set Hooks
local function SetHooks()
	if IsAddOnLoaded("Scrap") and E.private.bags.enable then
		hooksecurefunc(Scrap, 'VARIABLES_LOADED', UpdateBags)
		hooksecurefunc(Scrap, 'ToggleJunk', UpdateBags)
			
		UpdateBags()

		Scrap.HasSpotlight = true
	end
end
hooksecurefunc(B, "Initialize", SetHooks)

--Re-add JunkIcon on bag slots for the ElvUI Bags skin
local function CreateIcon(slot)
	if IsAddOnLoaded("Scrap") and E.private.bags.enable then
		local icon = slot:CreateTexture(nil, 'OVERLAY', 7)
		icon:SetTexture('Interface\\Buttons\\UI-GroupLoot-Coin-Up')
		icon:SetPoint('TOPLEFT', 2, -2)
		icon:SetSize(15, 15)

		slot.scrapIcon = icon
		return icon
	end
end

local function SkinBags()
	if not IsAddOnLoaded("Scrap") or E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.bags ~= true or E.private.bags.enable then return end

	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local container = _G["ContainerFrame"..i]
		if container then
			container:HookScript("OnShow", function(self)
				if self and self.size then
					for b=1, self.size, 1 do
						local button = _G[self:GetName().."Item"..b]
						if button.scrapIcon and button.scrapIcon:GetTexture() == nil then
							button.scrapIcon:SetTexture('Interface\\Buttons\\UI-GroupLoot-Coin-Up')
						end
					end
				end
			end)
		end
	end
end
S:AddCallback("KuiSkinBags", SkinBags)

function KB:Initialize()
	if not E.private.bags.enable then return end
	
	function KB:ForUpdateAll()
		KB.db = E.db.KlixUI.bags
	end
	
	KB:ForUpdateAll()
	
	self:AllInOneBags()
	self:SkinBlizzBags()
	self:SkinBank()
	
	KB:RegisterEvent("GUILDBANKFRAME_OPENED")
	KB:RegisterEvent("GUILDBANKFRAME_CLOSED")
	KB:RegisterEvent("AUCTION_HOUSE_SHOW")
	KB:RegisterEvent("AUCTION_HOUSE_CLOSED")
	KB:RegisterEvent("TRADE_SHOW")
	KB:RegisterEvent("TRADE_CLOSED")
	KB:RegisterEvent("OBLITERUM_FORGE_SHOW")
	KB:RegisterEvent("OBLITERUM_FORGE_CLOSE")
	
	KB:RegisterEvent("BANKFRAME_OPENED")
	KB:RegisterEvent("BANKFRAME_CLOSED")
	KB:RegisterEvent("MAIL_SHOW")
	KB:RegisterEvent("MAIL_CLOSED")
	KB:RegisterEvent("MERCHANT_SHOW")
	KB:RegisterEvent("MERCHANT_CLOSED")
	KB:RegisterEvent("BAG_UPDATE_DELAYED")
	
	--Applying stuff to already existing bags
	self:HookBags();
	hooksecurefunc(B, "Layout", function(self, isBank)
		KB:HookBags(isBank)
	end);
	
	--This table is for initial update of a frame, cause applying transparent trmplate breaks color borders
	KB.InitialUpdates = {
		Bank = false,
		ReagentBank = false,
		ReagentBankButton = false,
	}

	--Fix borders for bag frames
	hooksecurefunc(B, "OpenBank", function()
		if not KB.InitialUpdates.Bank then --For bank, just update on first show
			B:Layout(true)
			KB.InitialUpdates.Bank = true
		end
		if not KB.InitialUpdates.ReagentBankButton then --For reagent bank, hook to toggle button and update layout when first clicked
			_G["ElvUI_BankContainerFrame"].reagentToggle:HookScript("OnClick", function()
				if not KB.InitialUpdates.ReagentBank then
					B:Layout(true)
					KB.InitialUpdates.ReagentBank = true
				end
			end)
			KB.InitialUpdates.ReagentBankButton = true
		end
	end)
end

KUI:RegisterModule(KB:GetName())