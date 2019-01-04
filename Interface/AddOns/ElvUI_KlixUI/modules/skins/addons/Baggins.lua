local KUI, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule("KuiSkins")
local S = E:GetModule("Skins")

local function styleBaggins()
	if E.private.KlixUI.skins.addonSkins.ba ~= true or not AddOnSkins then return end
	
	local AS = unpack(AddOnSkins)
	local IUI = LibStub("LibItemUpgradeInfo-1.0")
	
	local KUI_BagginsSkin = {
	   BagLeftPadding = 10,
	   BagRightPadding = 10,
	   BagTopPadding = 32,
	   BagBottomPadding = 10,
	   TitlePadding = 32 + 48,
	   SectionTitleHeight = 13,
	   EmptySlotTexture = "",
	}

	function KUI_BagginsSkin:SkinBag(frame)
		if not frame.Backdrop then
			AS:SkinBackdropFrame(frame)
			frame.Backdrop:SetInside()
		end
		
	   	frame:SetTemplate("Transparent")
		frame:Styling()
	   
		S:HandleCloseButton(frame.closebutton)
	   
		frame.closebutton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
	   
		frame.compressbutton:ClearAllPoints()
		frame.compressbutton:SetPoint("TOPRIGHT", frame.closebutton, "TOPLEFT", -4, -2)
	   
		frame.title:SetVertexColor(1, 1, 1, 1)
		frame.title:ClearAllPoints()
		frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
		frame.title:SetPoint("RIGHT", frame.closebutton, "LEFT", 0, 0)
		frame.title:SetHeight(12)
		frame.title:SetJustifyH("LEFT")
	end

	function KUI_BagginsSkin:SkinSection(frame)
	   frame.title:SetVertexColor(1, 1, 1, 1)
	   frame.title:SetText("")
	   frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 2)
	   frame.title:SetHeight(13)
	end

	function KUI_BagginsSkin:SkinItem(button)
		if button.IsSkinned then return end
   
		button:SetNormalTexture("")
		button:SetPushedTexture("")
	   
		AS:SetTemplate(button)
		AS:StyleButton(button)
	   
		AS:SkinTexture(button.icon)
		button.icon:SetInside()
	   
		button.IconBorder:SetAlpha(0)
	   
		button.Count:SetFont("Interface\\AddOns\\ElvUI\\media\\fonts\\Expressway.ttf", 12, "OUTLINE")
	   
		button.ILevel = button:CreateFontString()
		button.ILevel:SetFont("Interface\\AddOns\\ElvUI\\media\\fonts\\Expressway.ttf", 12, "OUTLINE")
		button.ILevel:SetPoint("TOPLEFT", button, "TOPLEFT", 2, 0)
	   
		ElvUI[1]:RegisterCooldown(_G[button:GetName().."Cooldown"])
	   
		if CanIMogIt then
			CIMI_AddToFrame(button, ContainerFrameItemButton_CIMIUpdateIcon)
		end
	   
		button.UpgradeIcon:ClearAllPoints()
		button.UpgradeIcon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT")
	   
		button.Azerite = button:CreateTexture(nil, "ARTWORK")
		button.Azerite:SetAtlas("AzeriteIconFrame")
		button.Azerite:SetTexCoord(0, 1, 0, 1)
		button.Azerite:SetInside()
		button.Azerite:Hide()
	   
		button.IsSkinned = true   
	end

	function KUI_BagginsSkin:SetBankVisual(frame, isBank)
	   local color = isBank and {0, .5, 1} or AS.BorderColor
	   frame.Backdrop:SetBackdropBorderColor(unpack(color))
	end

	hooksecurefunc(Baggins, "CreateMoneyFrame", function()
		  BagginsCopperText:ClearAllPoints()
		  BagginsGoldText:ClearAllPoints()
		  BagginsSilverText:ClearAllPoints()
		  BagginsCopperText:SetPoint("RIGHT", BagginsCopperIcon, "LEFT")
		  BagginsSilverText:SetPoint("RIGHT", BagginsSilverIcon, "LEFT")
		  BagginsGoldText:SetPoint("RIGHT", BagginsGoldIcon, "LEFT")
	end)

	hooksecurefunc(Baggins, "UpdateItemButton", function(self, _, button, bag, slot)
		local p = self.db.profile
		local texture, _, _, quality = GetContainerItemInfo(bag, slot)
		local link = GetContainerItemLink(bag, slot)
		if link then
			local itemLevel = IUI:GetUpgradedItemLevel(link)
			quality = select(3, GetItemInfo(link)) or quality
			if itemLevel and itemLevel >= 300 then
				button.ILevel:SetText(itemLevel)
			else
				button.ILevel:SetText("")
			end
		else
			button.ILevel:SetText("")
		end
		if p.qualitycolor and texture and quality >= p.qualitycolormin then
			local r, g, b = GetItemQualityColor(quality)
			local glowTexture = button.glow:GetTexture()
			if glowTexture ~= TEXTURE_ITEM_QUEST_BANG then
				button.glow:Hide()
			end
			if glowTexture == TEXTURE_ITEM_QUEST_BORDER or glowTexture == TEXTURE_ITEM_QUEST_BANG then
				button:SetBackdropBorderColor(0.80, 0.6, 0, 1)
			else
				button:SetBackdropBorderColor(r, g, b, 1)
			end
		else
			button:SetBackdropBorderColor(unpack(AS.BorderColor))
		end
		  
		button.Count:ClearAllPoints()
		button.Count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 3)
		  
		button.UpgradeIcon:SetShown(IsContainerItemAnUpgrade(bag, slot))
		  
		if link then
			button.Azerite:SetShown(C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID(link))
		else
			button.Azerite:Hide()
		end
		  
		if CanIMogIt then
			ContainerFrameItemButton_CIMIUpdateIcon(button.CanIMogItOverlay)        
		end
		  
		if C_NewItems.IsNewItem(bag, slot) and quality then
			button.NewItemTexture:SetAtlas(NEW_ITEM_ATLAS_BY_QUALITY[quality])
			button.flashAnim:Play()
			button.newitemglowAnim:Play()
		else
			button.flashAnim:Stop()
			button.newitemglowAnim:Stop()
		end
	end)

	hooksecurefunc(Baggins, "CloseAllBags", function()
		  C_NewItems.ClearAll()
	end)
	
	Baggins.opts.args.General.args.NewItemDuration.disabled = true
	Baggins.opts.args.Items.args.HighlightNew.disabled = true
	Baggins.opts.args.Layout.args.SortNewFirst.disabled = true
	Baggins.db.profile.newitemduration = 0
	Baggins.db.profile.highlightnew = false
	Baggins.db.profile.sortnewfirst = false
	
	Baggins:RegisterSkin(KUI.Title, KUI_BagginsSkin)
	Baggins:ApplySkin(KUI.Title)
end

S:AddCallbackForAddon("Baggins", "KuiBaggins", styleBaggins)