local KUI, E, L, V, P, G = unpack(select(2, ...))
local KS = KUI:GetModule("KuiSkins")
local S = E:GetModule("Skins")

--Cache global variables
local _G = _G
--WoW API / Variables

--Global variables that we don't cache, list them here for the mikk's Find Globals script
-- GLOBALS:

local function styleMapCanvas()
	if E.private.skins.blizzard.enable ~= true then return end

	--[[ AddOns\Blizzard_MapCanvasDetailLayer.lua ]]
	function KS.MapCanvasDetailLayerMixin_RefreshDetailTiles(self)
		local layers = C_Map.GetMapArtLayers(self.mapID)
		local layerInfo = layers[self.layerIndex]

		for detailTile in self.detailTilePool:EnumerateActive() do
			if not detailTile.isSkinned then
				detailTile:SetSize(layerInfo.tileWidth, layerInfo.tileHeight)
				detailTile.isSkinned = true
			end
		end
	end

	--[[ AddOns\Blizzard_MapCanvas.lua ]]

	--[[ AddOns\Blizzard_MapCanvas.xml ]]
	function KS:MapCanvasFrameScrollContainerTemplate(ScrollFrame)
	end

	function KS:MapCanvasFrameTemplate(Frame)
	end

	hooksecurefunc(MapCanvasDetailLayerMixin, "RefreshDetailTiles", KS.MapCanvasDetailLayerMixin_RefreshDetailTiles)
end

S:AddCallbackForAddon("Blizzard_MapCancas", "KuiMapCanvas", styleMapCanvas)
