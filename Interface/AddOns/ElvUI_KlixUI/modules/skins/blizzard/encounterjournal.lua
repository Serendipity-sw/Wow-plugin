local KUI, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule("KuiSkins")
local S = E:GetModule('Skins')

-- Cache global variables
-- Lua functions
local _G = _G
local ipairs, pairs, select, unpack = ipairs, pairs, select, unpack
-- WoW API / Variables
local CreateFrame = CreateFrame
-- Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS: styleEncounterJournal, hooksecurefunc

function styleEncounterJournal()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.encounterjournal ~= true or E.private.KlixUI.skins.blizzard.encounterjournal ~= true then return end

	local r, g, b = unpack(E["media"].rgbvaluecolor)
	
	local EncounterJournal = _G["EncounterJournal"]
	EncounterJournal.backdrop:Styling()

	if EncounterJournal.navBar.backdrop then
		EncounterJournal.navBar.backdrop:Hide()
	end

	-- [[ SearchBox ]]
	local searchBox = EncounterJournal.searchBox

	searchBox.searchPreviewContainer.botLeftCorner:Hide()
	searchBox.searchPreviewContainer.botRightCorner:Hide()
	searchBox.searchPreviewContainer.bottomBorder:Hide()
	searchBox.searchPreviewContainer.leftBorder:Hide()
	searchBox.searchPreviewContainer.rightBorder:Hide()

	local function resultOnEnter(self)
		self.hl:Show()
	end

	local function resultOnLeave(self)
		self.hl:Hide()
	end

	local function styleSearchButton(result, index)
		if index == 1 then
			result:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", 0, 1)
			result:SetPoint("TOPRIGHT", searchBox, "BOTTOMRIGHT", -5, 1)
		else
			result:SetPoint("TOPLEFT", searchBox.searchPreview[index-1], "BOTTOMLEFT", 0, 1)
			result:SetPoint("TOPRIGHT", searchBox.searchPreview[index-1], "BOTTOMRIGHT", 0, 1)
		end

		result:SetNormalTexture("")
		result:SetPushedTexture("")
		result:SetHighlightTexture("")

		local hl = result:CreateTexture(nil, "BACKGROUND")
		hl:SetAllPoints()
		hl:SetTexture(E.media.normTex)
		hl:SetVertexColor(r, g, b, .2)
		hl:Hide()
		result.hl = hl

		KS:CreateBD(result)
		result:SetBackdropColor(.1, .1, .1, .9)

		if result.icon then
			result:GetRegions():Hide() -- icon frame

			result.icon:SetTexCoord(unpack(E.TexCoords))

			local bg = KS:CreateBG(result.icon)
			bg:SetDrawLayer("BACKGROUND", 1)
		end

		result:HookScript("OnEnter", resultOnEnter)
		result:HookScript("OnLeave", resultOnLeave)
	end

	for i = 1, #searchBox.searchPreview do
		styleSearchButton(searchBox.searchPreview[i], i)
	end
	styleSearchButton(searchBox.showAllResults, 6)


	-- [[ SearchResults ]]
	local searchResults = EncounterJournal.searchResults
	KS:CreateBD(searchResults)
	searchResults:SetBackdropColor(.15, .15, .15, .9)
	for i = 3, 11 do
		select(i, searchResults:GetRegions()):Hide()
	end

	_G["EncounterJournalSearchResultsBg"]:Hide()

	hooksecurefunc("EncounterJournal_SearchUpdate", function()
		local scrollFrame = searchResults.scrollFrame
		local offset = _G.HybridScrollFrame_GetOffset(scrollFrame)
		local results = scrollFrame.buttons
		local result, index

		local numResults = _G.EJ_GetNumSearchResults()

		for i = 1, #results do
			result = results[i]
			index = offset + i

			if index <= numResults then
				if not result.styled then
					result:SetNormalTexture("")
					result:SetPushedTexture("")
					result:GetRegions():Hide()

					result.resultType:SetTextColor(1, 1, 1)
					result.path:SetTextColor(1, 1, 1)

					KS:CreateBG(result.icon)

					result.styled = true
				end

				if result.icon:GetTexCoord() == 0 then
					result.icon:SetTexCoord(unpack(E.TexCoords))
				end
			end
		end
	end)

	hooksecurefunc(searchResults.scrollFrame, "update", function(self)
		for i = 1, #self.buttons do
			local result = self.buttons[i]

			if result.icon:GetTexCoord() == 0 then
				result.icon:SetTexCoord(unpack(E.TexCoords))
			end
		end
	end)

	--[[ NavBar ]]
	EncounterJournal.navBar:SetWidth(550)
	EncounterJournal.navBar:SetPoint("TOPLEFT", 20, -22)

	--[[ Inset ]]
	EncounterJournal.inset:DisableDrawLayer("BORDER")
	EncounterJournal.inset.Bg:Hide()

	--[[ InstanceSelect ]]
	local instanceSelect = EncounterJournal.instanceSelect
	instanceSelect.bg:Hide()

	local function listInstances()
		local index = 1
		while true do
			local bu = instanceSelect.scroll.child.InstanceButtons[index]
			if not bu then return end

			bu:SetNormalTexture("")
			bu:SetHighlightTexture("")
			bu:SetPushedTexture("")

			bu.bgImage:SetDrawLayer("BACKGROUND", 1)

			local bg = KS:CreateBG(bu.bgImage)
			bg:SetPoint("TOPLEFT", 3, -3)
			bg:SetPoint("BOTTOMRIGHT", -4, 2)

			index = index + 1
		end
	end
	hooksecurefunc("EncounterJournal_ListInstances", listInstances)
	listInstances()

	--[[ EncounterFrame ]]
	local encounter = EncounterJournal.encounter
	local function SkinEJButton(button)
		button.UpLeft:SetAlpha(0)
		button.UpRight:SetAlpha(0)
		button.DownLeft:SetAlpha(0)
		button.DownRight:SetAlpha(0)
		select(5, button:GetRegions()):Hide()
		select(6, button:GetRegions()):Hide()
		KS:Reskin(button)
	end

	--[[ InstanceFrame ]]
	_G.EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollChildLore:SetTextColor(1, 1, 1)

	--[[ Info ]]
	local info = encounter.info
	info:DisableDrawLayer("BACKGROUND")

	info.encounterTitle:SetTextColor(1, 1, 1)

	SkinEJButton(info.difficulty)

	KS:Reskin(info.reset)

	info.detailsScroll.child.description:SetTextColor(1, 1, 1)

	info.overviewScroll.child.loreDescription:SetTextColor(1, 1, 1)
	info.overviewScroll.child.header:Hide()
	_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetFontObject("GameFontNormalLarge")
	_G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetTextColor(1, 1, 1)
	info.overviewScroll.child.overviewDescription.Text:SetTextColor(1, 1, 1)

	SkinEJButton(info.lootScroll.filter)
	SkinEJButton(info.lootScroll.slotFilter)

	local encLoot = info.lootScroll.buttons
	for i = 1, #encLoot do
		local item = encLoot[i]

		item.boss:SetTextColor(1, 1, 1)
		item.slot:SetTextColor(1, 1, 1)
		item.armorType:SetTextColor(1, 1, 1)

		item.bossTexture:SetAlpha(0)
		item.bosslessTexture:SetAlpha(0)

		item.icon:SetTexCoord(unpack(E.TexCoords))
		item.icon:SetDrawLayer("OVERLAY")
		KS:CreateBG(item.icon)

		if item.backdrop then
			item.backdrop:Hide()
		end

		local bg = CreateFrame("Frame", nil, item)
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT", 0, 1)
		bg:SetFrameLevel(item:GetFrameLevel() - 1)
		KS:CreateBD(bg, .25)
	end

	info.model.dungeonBG:Hide()
	_G.EncounterJournalEncounterFrameInfoModelFrameShadow:Hide()
	KS:CreateBDFrame(_G.EncounterJournalEncounterFrameInfoModelFrame, .25)

	info.creatureButtons[1]:SetPoint("TOPLEFT", info.model, 0, -35)

	do
		local numBossButtons = 1
		local bossButton

		hooksecurefunc("EncounterJournal_DisplayInstance", function()
			bossButton = _G["EncounterJournalBossButton"..numBossButtons]
			while bossButton do
				KS:Reskin(bossButton)

				bossButton.text:SetTextColor(1, 1, 1)
				bossButton.text.SetTextColor = KUI.dummy

				local hl = bossButton:GetHighlightTexture()
				hl:SetColorTexture(r, g, b, .2)
				hl:SetPoint("TOPLEFT", 2, -1)
				hl:SetPoint("BOTTOMRIGHT", 0, 1)

				bossButton.creature:SetPoint("TOPLEFT", 0, -4)

				numBossButtons = numBossButtons + 1
				bossButton = _G["EncounterJournalBossButton"..numBossButtons]
			end

			-- move last tab
			local _, point = _G.EncounterJournalEncounterFrameInfoModelTab:GetPoint()
			_G.EncounterJournalEncounterFrameInfoModelTab:SetPoint("TOP", point, "BOTTOM", 0, 1)
		end)
	end

	hooksecurefunc("EncounterJournal_ToggleHeaders", function(self)
		local index = 1
		local header = _G["EncounterJournalInfoHeader"..index]
		while header do
			if not header.styled then
				header.flashAnim.Play = KUI.dummy

				header.descriptionBG:SetAlpha(0)
				header.descriptionBGBottom:SetAlpha(0)
				for i = 4, 18 do
					select(i, header.button:GetRegions()):SetTexture("")
				end

				header.description:SetTextColor(1, 1, 1)
				header.button.title:SetTextColor(1, 1, 1)
				header.button.title.SetTextColor = KUI.dummy
				header.button.expandedIcon:SetTextColor(1, 1, 1)
				header.button.expandedIcon.SetTextColor = KUI.dummy

				KS:Reskin(header.button)

				header.button.abilityIcon:SetTexCoord(unpack(E.TexCoords))
				header.button.bg = KS:CreateBG(header.button.abilityIcon)

				header.styled = true
			end

			if header.button.abilityIcon:IsShown() then
				header.button.bg:Show()
			else
				header.button.bg:Hide()
			end

			index = index + 1
			header = _G["EncounterJournalInfoHeader"..index]
		end
	end)

	hooksecurefunc("EncounterJournal_SetUpOverview", function(self, role, index)
		local header = self.overviews[index]
		if not header.styled then
			header.flashAnim.Play = KUI.dummy

			header.descriptionBG:SetAlpha(0)
			header.descriptionBGBottom:SetAlpha(0)
			for i = 4, 18 do
				select(i, header.button:GetRegions()):SetTexture("")
			end

			header.button.title:SetTextColor(1, 1, 1)
			header.button.title.SetTextColor = KUI.dummy
			header.button.expandedIcon:SetTextColor(1, 1, 1)
			header.button.expandedIcon.SetTextColor = KUI.dummy

			KS:Reskin(header.button)

			header.styled = true
		end
	end)

	hooksecurefunc("EncounterJournal_SetBullets", function(object, description)
		local parent = object:GetParent()

		if parent.Bullets then
			for _, bullet in next, parent.Bullets do
				if not bullet.styled then
					bullet.Text:SetTextColor(1, 1, 1)
					bullet.styled = true
				end
			end
		end
	end)

	-- [[ Loot ]]
	local LootJournal = _G["EncounterJournal"].LootJournal
	LootJournal:DisableDrawLayer("BACKGROUND")

	hooksecurefunc(EncounterJournal.LootJournal.ItemSetsFrame, "UpdateList", function(self)
		local buttons = self.buttons
		for i = 1, #buttons do
			local button = buttons[i]

			if not button.styled then
				button.ItemLevel:SetTextColor(1, 1, 1)
				button.Background:Hide()
				KS:CreateBD(button, .25)
				KS:CreateGradient(button)

				button.styled = true
			end
		end
	end)

	hooksecurefunc(EncounterJournal.LootJournal.ItemSetsFrame, "ConfigureItemButton", function(_, button)
		if not button.bg then
			button.Border:SetAlpha(0)
			button.Icon:SetTexCoord(unpack(E.TexCoords))
			button.bg = KS:CreateBDFrame(button.Icon)
		end

		local quality = select(3, GetItemInfo(button.itemID))
		local color = BAG_ITEM_QUALITY_COLORS[quality or 1]
		button.bg:SetBackdropBorderColor(color.r, color.g, color.b)
	end)

	-- [[ SuggestFrame ]]
	local suggestFrame = EncounterJournal.suggestFrame
	do
		-- Suggestion 1
		local suggestion = suggestFrame.Suggestion1

		suggestion.bg:Hide()

		KS:CreateBD(suggestion, .25)
		KS:CreateGradient(suggestion)

		suggestion.icon:SetPoint("TOPLEFT", 135, -15)

		local centerDisplay = suggestion.centerDisplay

		centerDisplay.title.text:SetTextColor(1, 1, 1)
		centerDisplay.description.text:SetTextColor(.9, .9, .9)

		KS:Reskin(suggestion.button)

		local reward = suggestion.reward

		reward.text:SetTextColor(.9, .9, .9)
		reward.iconRing:Hide()
		reward.iconRingHighlight:SetTexture("")

		-- Suggestion 2 and 3
		for i = 2, 3 do
			suggestion = suggestFrame["Suggestion"..i]

			suggestion.bg:Hide()

			KS:CreateBD(suggestion, .25)
			KS:CreateGradient(suggestion)

			suggestion.icon:SetPoint("TOPLEFT", 10, -10)

			centerDisplay = suggestion.centerDisplay

			centerDisplay:ClearAllPoints()
			centerDisplay:SetPoint("TOPLEFT", 85, -10)
			centerDisplay.title.text:SetTextColor(1, 1, 1)
			centerDisplay.description.text:SetTextColor(.9, .9, .9)

			reward = suggestion.reward

			reward.iconRing:Hide()
			reward.iconRingHighlight:SetTexture("")
		end
	end

	hooksecurefunc("EJSuggestFrame_RefreshDisplay", function()
		local self = suggestFrame

		if #self.suggestions > 0 then
			local suggestion = self.Suggestion1
			local data = self.suggestions[1]

			suggestion.iconRing:Hide()

			if suggestion and data then
				suggestion.icon:SetMask("")
				suggestion.icon:SetTexture(data.iconPath)
				suggestion.icon:SetTexCoord(unpack(E.TexCoords))
			end
		end

		if #self.suggestions > 1 then
			for i = 2, #self.suggestions do
				local suggestion = self["Suggestion"..i]
				if not suggestion then break end

				local data = self.suggestions[i]

				suggestion.iconRing:Hide()

				if data.iconPath then
					suggestion.icon:SetMask("")
					suggestion.icon:SetTexture(data.iconPath)
					suggestion.icon:SetTexCoord(unpack(E.TexCoords))
				end
			end
		end
	end)

	hooksecurefunc("EJSuggestFrame_UpdateRewards", function(suggestion)
		local rewardData = suggestion.reward.data
		if rewardData then
			local texture = rewardData.itemIcon or rewardData.currencyIcon or [[Interface\Icons\achievement_guildperk_mobilebanking]]
			suggestion.reward.icon:SetMask("")
			suggestion.reward.icon:SetTexture(texture)

			if not suggestion.reward.icon.backdrop then
				KS:CreateBackdrop(suggestion.reward.icon)
				suggestion.reward.icon.backdrop:SetOutside(suggestion.reward.icon)
			end

			local r, g, b = unpack(E["media"].bordercolor)
			if rewardData.itemID then
				local quality = select(3, GetItemInfo(rewardData.itemID))
				if quality and quality > 1 then
					r, g, b = GetItemQualityColor(quality)
				end
			end
			suggestion.reward.icon.backdrop:SetBackdropBorderColor(r, g, b)
		end
	end)
end

S:AddCallbackForAddon("Blizzard_EncounterJournal", "KuiEncounterJournal", styleEncounterJournal)