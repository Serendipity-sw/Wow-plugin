local KUI, E, L, V, P, G = unpack(select(2, ...))
local WM = KUI:NewModule("WhistleMaster", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")
local HBD = LibStub("HereBeDragons-2.0")
local HBDPins = LibStub("HereBeDragons-Pins-2.0")

-- Cache global variables
-- Lua functions
local format, next, tonumber, tconcat, tsort = format, next, tonumber, table.concat, table.sort
-- WoW API / Variables
local CreateFrame = CreateFrame
local BACKPACK_CONTAINER, NUM_BAG_SLOTS = BACKPACK_CONTAINER, NUM_BAG_SLOTS
local GetContainerNumSlots, GetContainerItemID = GetContainerNumSlots, GetContainerItemID
local C_Map, C_TaxiMap, Enum = C_Map, C_TaxiMap, Enum
local WorldMapFrame, WorldMapTooltip = WorldMapFrame, WorldMapTooltip
local FlightPointDataProviderMixin = FlightPointDataProviderMixin
local IsIndoors, UnitFactionGroup, UnitLevel = IsIndoors, UnitFactionGroup, UnitLevel
-- Global variables that we don"t cache, list them here for the mikk"s Find Globals script
-- GLOBALS:

-- Consts
local FMW_ID = 141605 -- Flight Master's Whistle Item ID
local PLAYER_FACTION_GROUP = nil
local TAXI_NODES = {}

-- Continents where the FMW can be used
local WHISTLE_CONTINENTS = {
  -- [uiMapID] = level to use FMW
  [619] = 110, -- Broken Isles
  [905] = 110, -- Argus
  [876] = 120, -- Kul'tiras
  [875] = 120, -- Zandalar
}

-- Variables
local currentMapID = -1     -- map where the player is, such as Boralus
local currentZoneMapID = -1 -- map of the actual zone, such as Tiragarde Sound
local minWhistleLevel = nil
local playerHasWhistle = false
local pinsNeedUpdate = false
local nearestTaxis = {}

local whistleMaster = CreateFrame("Frame", KUI.Title.."WhistleMaster")

local function colorText(s)
  return format("|cfff960d9%s|r", s)
end

-- Returns true if the player can use the flight master's whistle.
local function whistleCanBeUsed()
  return
    playerHasWhistle and
    minWhistleLevel and
    (UnitLevel("PLAYER") >= minWhistleLevel) and
    not IsIndoors()
end

local timer = 0
local function OnUpdateHandler(whistleMaster, elapsed)
    timer = timer + elapsed
    if (timer >= 1) then
      WM:UpdateTaxis()
      timer = 0
    end
    WM:UpdatePins()
end
whistleMaster:SetScript("OnUpdate", OnUpdateHandler)

function WM:BAG_UPDATE()
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
          local itemID = GetContainerItemID(bag, slot)
          if itemID and (itemID == FMW_ID) then
            playerHasWhistle = true
            return
          end
        end
	end
	playerHasWhistle = false
end

function WM:HereBeDragonsCall()
  -- Ignore nodes with these textureKitPrefix entries
  local TEXTURE_KIT_PREFIX_IGNORE = {
    FlightMaster_Ferry = true
  }

  -- HBD Callback
  HBD.RegisterCallback(WM, "PlayerZoneChanged", function(_, mapID)
    minWhistleLevel = nil

    if not mapID then return end
    currentMapID = mapID
    currentZoneMapID = mapID

    local mapInfo = C_Map.GetMapInfo(mapID)
    if not mapInfo or (mapInfo.mapType > Enum.UIMapType.Zone) then return end
    local currentZoneMapName = mapInfo.name

    -- Update data based on current zone and continent
    while mapInfo.mapType and (mapInfo.mapType > Enum.UIMapType.Continent) do
      if (mapInfo.mapType == Enum.UIMapType.Zone) then
        currentZoneMapName = mapInfo.name
        currentZoneMapID = mapInfo.mapID
      end
      mapInfo = C_Map.GetMapInfo(mapInfo.parentMapID)
      if not mapInfo then return end
    end

    if (mapInfo.mapType ~= Enum.UIMapType.Continent) then return end
    minWhistleLevel = WHISTLE_CONTINENTS[mapInfo.mapID]
    if not minWhistleLevel then return end

    -- Update taxi data for current zone
    local taxiNodes = C_TaxiMap.GetTaxiNodesForMap(mapID)
    if not taxiNodes or (#taxiNodes == 0) then
      taxiNodes = C_TaxiMap.GetTaxiNodesForMap(currentZoneMapID)
      if not taxiNodes or (#taxiNodes == 0) then minWhistleLevel = nil return end
    else
      currentZoneMapID = mapID
    end
    
    local factionGroup = UnitFactionGroup("PLAYER")
    for k in next, TAXI_NODES do TAXI_NODES[k] = nil end

    for _, node in next, taxiNodes do
      if FlightPointDataProviderMixin:ShouldShowTaxiNode(factionGroup, node) then
        if
          -- Only add nodes in the current zone
          node.name:find(currentZoneMapName, 1, true) and
          -- Ignore nodes with certain textureKitPrefix entries
          not TEXTURE_KIT_PREFIX_IGNORE[node.textureKitPrefix]
        then
          TAXI_NODES[#TAXI_NODES+1] = node
        end
      end
    end
  end)
end

-- ============================================================================
-- Pin Pool
-- ============================================================================

local getPin, clearPins, hidePins do
  local TITLE = colorText(KUI.Title)
  local FMW_TEXTURE_ID = "Interface\\AddOns\\ElvUI_KlixUI\\media\\textures\\whistle"
  local pins = {}
  local pool = {}
  local count = 0

  local function onEnter(self)
	--[[if E.db.KlixUI.maps.worldmap.flightQ then
		self:EnableMouse(false)
	else]]
		-- Show highlight
		self.highlight:SetAlpha(0.4)
		-- Show tooltip
		WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT")
		WorldMapTooltip:SetText(TITLE)
		WorldMapTooltip:AddLine(self.name, 1, 1, 1)
		WorldMapTooltip:Show()
	--end
  end

  local function onLeave(self)
    self.highlight:SetAlpha(0)
    WorldMapTooltip:Hide()
  end

  getPin = function(name)
    local pin = next(pool)
    
    if pin then
      pool[pin] = nil
    else
      count = count + 1
      pin = CreateFrame("Button", KUI.Title.."Pin"..count, WorldMapFrame)
      pin:SetSize(25, 25)
	  
	  --[[if E.db.KlixUI.maps.worldmap.flightQ then
		pin:SetFrameStrata("HIGH")
	  end]]

      pin.texture = pin:CreateTexture(KUI.Title.."PinTexture"..count, "BACKGROUND")
      pin.texture:SetTexture(FMW_TEXTURE_ID)
      pin.texture:SetAllPoints()

      pin.highlight = pin:CreateTexture(pin:GetName().."Hightlight", "HIGHLIGHT")
      pin.highlight:SetTexture(FMW_TEXTURE_ID)
      pin.highlight:SetBlendMode("ADD")
      pin.highlight:SetAlpha(0)
      pin.highlight:SetAllPoints(pin.texture)

      pin:SetScript("OnEnter", onEnter)
      pin:SetScript("OnLeave", onLeave)

      pins[#pins+1] = pin
    end

    pin.name = name
    pin:Show()
    return pin
  end

  clearPins = function()
    for _, pin in next, pins do
      pin:Hide()
      pool[pin] = true
    end
    HBDPins:RemoveAllWorldMapIcons(WM)
  end

  hidePins = function()
    for _, pin in next, pins do pin:Hide() end
  end
end

-- ============================================================================
-- General Functions
-- ============================================================================

function WM:UpdateTaxis()
  local THRESHOLD = 40 -- yards
  local last_x, last_y = -1, -1
  
	if not whistleCanBeUsed() then
		for k in next, nearestTaxis do nearestTaxis[k] = nil end
	return
	end

    local x, y, mapID = HBD:GetPlayerZonePosition()
    if not (x and y and mapID) then return end

    -- Return if player hasn't moved
    if (last_x == x) and (last_y == y) then return end
    last_x, last_y = x, y

    -- Clear data
    for k in next, nearestTaxis do nearestTaxis[k] = nil end

    -- If no taxis, return
    if (#TAXI_NODES == 0) then return end

    -- Calculate nearest taxis
    local currentNearest = TAXI_NODES[1]
    local currentDistance = HBD:GetZoneDistance(currentMapID, x, y, currentZoneMapID, currentNearest.position.x, currentNearest.position.y)
    nearestTaxis[1] = currentNearest

    for i=2, #TAXI_NODES do
      local taxi = TAXI_NODES[i]
      local distance = HBD:GetZoneDistance(currentMapID, x, y, currentZoneMapID, taxi.position.x, taxi.position.y)
      -- If closer outside threshold
      if (distance <= (currentDistance - THRESHOLD)) then -- wipe and add
        for k in next, nearestTaxis do nearestTaxis[k] = nil end
        nearestTaxis[#nearestTaxis+1] = taxi
        currentDistance = distance
      -- If within threshold
      elseif (distance <= (currentDistance + THRESHOLD)) then -- add
        nearestTaxis[#nearestTaxis+1] = taxi
      end
    end

    clearPins()
    pinsNeedUpdate = true
end

function WM:UpdatePins()
  if not whistleCanBeUsed() then clearPins() return end
  if not WorldMapFrame:IsVisible() then hidePins() return end
  if not pinsNeedUpdate then return end
  pinsNeedUpdate = false

  -- Add pins to map
  for _, taxi in next, nearestTaxis do
    HBDPins:AddWorldMapIconMap(
      WM,
      getPin(taxi.name),
      currentZoneMapID,
      taxi.position.x,
      taxi.position.y
    )
  end
end

-- ============================================================================
-- Tooltip Hook
-- ============================================================================

local LEFT = colorText("|cfff960d9KlixUI:|r")
local DELIMITER = colorText(" | ")
local buffer = {}

local function sortFunc(a, b) return a.name < b.name end

  -- "Tradewinds Market, Tiragarde Sound" -> "Tradewinds Market"
local function getTaxiName(taxi)
	local name = taxi.name:match("(.+),")
    return name or taxi.name
end

local function getTaxiNames()
    if (#nearestTaxis == 1) then return getTaxiName(nearestTaxis[1]) end
    tsort(nearestTaxis, sortFunc)
    for k in next, buffer do buffer[k] = nil end
    for i=1, (#nearestTaxis - 1) do
      buffer[#buffer+1] = getTaxiName(nearestTaxis[i])..DELIMITER
    end
    buffer[#buffer+1] = getTaxiName(nearestTaxis[#nearestTaxis])
    return tconcat(buffer)
end

local function onTooltipSetItem(self)
	if not whistleCanBeUsed() or (#nearestTaxis == 0) then return end

    -- Verify the item is the Flight Master's Whistle
    local _, link = self:GetItem()
    if not link then return end
    local id = tonumber(link:match("item:(%d+)") or "")
    if not id or (id ~= FMW_ID) then return end
    
    self:AddLine(" ") -- Blank Line
    self:AddDoubleLine(LEFT, getTaxiNames(), nil, nil, nil, 1, 1, 1)
end
GameTooltip:HookScript("OnTooltipSetItem", onTooltipSetItem)

function WM:Initialize()
	if not E.db.KlixUI.misc.whistleLocation or IsAddOnLoaded("WhistledAway") then return end
	
	WM:BAG_UPDATE()
	WM:HereBeDragonsCall()
	WM:UpdateTaxis()
	WM:UpdatePins()
	
	WM:RegisterEvent("BAG_UPDATE")
end

KUI:RegisterModule(WM:GetName())
