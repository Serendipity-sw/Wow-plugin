local E, L, V, P, G = unpack(ElvUI);
local LSM = LibStub('LibSharedMedia-3.0')
local EP = LibStub('LibElvUIPlugin-1.0')
local addon, Engine = ...

local KUI = LibStub('AceAddon-3.0'):NewAddon(addon, 'AceConsole-3.0', 'AceHook-3.0', 'AceEvent-3.0', 'AceTimer-3.0');
KUI.callbacks = KUI.callbacks or LibStub("CallbackHandler-1.0"):New(KUI)

Engine[1] = KUI
Engine[2] = E
Engine[3] = L
Engine[4] = V
Engine[5] = P
Engine[6] = G
_G[addon] = Engine;

-- Lua functions
local _G = _G
local assert, pairs, print, select = assert, pairs, print, select
local getmetatable = getmetatable
local pcall = pcall
-- WoW API / Variables
local format = string.format
local CreateFrame = CreateFrame
local GetAddOnMetadata = GetAddOnMetadata
local IsAddOnLoaded = IsAddOnLoaded
local C_TimerAfter = C_Timer.After

--Global variables that we don't cache, list them here for the mikk's Find Globals script
KUI.dummy = function() return end
KUI.Config = {}
KUI["softGlow"] = {}
KUI["styling"] = {}
KUI.Title = format('|cfff960d9%s |r', 'KlixUI')
KUI.Version = GetAddOnMetadata('ElvUI_KlixUI', 'Version')
KUI.Logo = [[Interface\AddOns\ElvUI_KlixUI\media\textures\KlixUILogo.tga]]
KUI.ElvUIV = tonumber(E.version)
KUI.ElvUIX = tonumber(GetAddOnMetadata("ElvUI_KlixUI", "X-ElvVersion"))
--KUI.ClassColor = E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
--KUI.resolution = ({GetScreenResolutions()})[GetCurrentResolution()] or GetCVar("gxWindowedResolution"); --only used for now in our install.lua line 779
--KUI.screenwidth, KUI.screenheight = GetPhysicalScreenSize();
BINDING_HEADER_KLIXUI = KUI.Title
KUI.WoWPatch, KUI.WoWBuild, KUI.WoWPatchReleaseDate, KUI.TocVersion = GetBuildInfo()
KUI.WoWBuild = select(2, GetBuildInfo()) KUI.WoWBuild = tonumber(KUI.WoWBuild)
KUI.Discord = "https://discord.gg/GbQbDRX"

KUI_NORMAL_QUEST_DISPLAY = "|cffffffff%s|r"
KUI_TRIVIAL_QUEST_DISPLAY = TRIVIAL_QUEST_DISPLAY:gsub("000000", "ffffff")

KUI.IsDev = {
	["Klix"] = true,
	["Klixi"] = true,
	["Klixx"] = true,
}

function KUI:IsDeveloper()
	return KUI.IsDev[E.myname] or false
end

-- AP
function KUI:IsAddOnEnabled(addon, character)
	if (type(character) == 'boolean' and character == true) then
		character = nil
	end
	return GetAddOnEnableState(character, addon) == 2
end

function KUI:IsAddOnPartiallyEnabled(addon, character)
	if (type(character) == 'boolean' and character == true) then
		character = nil
	end
	return GetAddOnEnableState(character, addon) == 1
end

function KUI:PairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do tinsert(a, n) end
	sort(a, f)
	local i = 0
	local iter = function()
		i = i + 1
		if a[i] == nil then return nil
			else return a[i], t[a[i]]
		end
	end
	return iter
end

function KUI:MismatchText()
	local text = format(L["MSG_KUI_ELV_OUTDATED"], KUI.ElvUIV, KUI.ElvUIX)
	return text
end

-- Inform us of the patch info we play on.
_G["SLASH_WOWVERSION1"], _G["SLASH_WOWVERSION2"] = "/patch", "/version"
SlashCmdList["WOWVERSION"] = function()
	KUI:Print("Patch:", KUI.WoWPatch..", ".. "Build:", KUI.WoWBuild..", ".. "Released", KUI.WoWPatchReleaseDate..", ".. "Interface:", KUI.TocVersion)
end

function KUI:cOption(name)
	local color = '|cfff960d9%s |r'
	return (color):format(name)
end

function KUI:Print(...)
	print("|cfff960d9".."KlixUI:|r", ...)
end

function KUI:PrintURL(url) -- Credit: Azilroka
	return format("|cfff960d9[|Hurl:%s|h%s|h]|r", url, url)
end

function KUI:ErrorPrint(msg)
	print("|cffFF0000KlixUI Error:|r", msg)
end

local color = { r = 1, g = 1, b = 1, a = 1 }
function KUI:unpackColor(color)
	return color.r, color.g, color.b, color.a
end

-- Class Color stuff
KUI.ClassColor = E.myclass == "PRIEST" and E.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass] or RAID_CLASS_COLORS[E.myclass])
KUI.ClassColors = {}
local BC = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
	BC[v] = k
end

for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
	BC[v] = k
end

local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
for class in pairs(colors) do
	KUI.ClassColors[class] = {}
	KUI.ClassColors[class].r = colors[class].r
	KUI.ClassColors[class].g = colors[class].g
	KUI.ClassColors[class].b = colors[class].b
	KUI.ClassColors[class].colorStr = colors[class].colorStr
end
KUI.r, KUI.g, KUI.b = KUI.ClassColors[E.myclass].r, KUI.ClassColors[E.myclass].g, KUI.ClassColors[E.myclass].b

function KUI:ClassColor(class)
	local color = KUI.ClassColors[class]
	if not color then return 1, 1, 1 end
	return color.r, color.g, color.b
end

function KUI:GetClassColorString(class)
	local color = KUI.colors.class[BC[class] or class]
	return E:RGBToHex(color.r, color.g, color.b)
end

KUI.colors = {
	class = {},
}

KUI.colors.class = {
	["DEATHKNIGHT"]	= { 0.77,	0.12,	0.23 },
	["DEMONHUNTER"]	= { 0.64,	0.19,	0.79 },
	["DRUID"]		= { 1,		0.49,	0.04 },
	["HUNTER"]		= { 0.58,	0.86,	0.49 },
	["MAGE"]		= { 0.2,	0.76,	1 },
	["MONK"]		= { 0,		1,		0.59 },
	["PALADIN"]		= { 0.96,	0.55,	0.73 },
	["PRIEST"]		= { 0.99,	0.99,	0.99 },
	["ROGUE"]		= { 1,		0.96,	0.41 },
	["SHAMAN"]		= { 0,		0.44,	0.87 },
	["WARLOCK"]		= { 0.6,	0.47,	0.85 },
	["WARRIOR"]		= { 0.9,	0.65,	0.45 },
}

for class, color in pairs(KUI.colors.class) do
	KUI.colors.class[class] = { r = color[1], g = color[2], b = color[3] }
end

function KUI:RegisterKuiMedia()
	--Fonts
	E['media'].CGB = LSM:Fetch('font', 'Century Gothic Bold')
	E['media'].Days = LSM:Fetch('font', 'Days')
	E['media'].Expressway = LSM:Fetch('font', 'Expressway')

	--Textures
	E['media'].Empty = LSM:Fetch('statusbar', 'Empty')
	E['media'].Klix = LSM:Fetch('statusbar', 'Klix')
	E['media'].Klix1 = LSM:Fetch('statusbar', 'Klix1')
	E['media'].Klix2 = LSM:Fetch('statusbar', 'Klix2')
	E['media'].Klix3 = LSM:Fetch('statusbar', 'Klix3')
	E["media"].KlixGradient = LSM:Fetch("statusbar", "KlixGradient")
	E['media'].KuiOnePixel = LSM:Fetch('statusbar', 'KuiOnePixel')
	E['media'].KlixBlank = LSM:Fetch('statusbar', 'KlixBlank')
	
	-- Custom Textures
	E["media"].roleIcons = [[Interface\AddOns\ElvUI_KlixUI\media\textures\UI-LFG-ICON-ROLES]]
end

local r, g, b = 0, 0, 0

function KUI:UpdateSoftGlowColor()
	if KUI["softGlow"] == nil then KUI["softGlow"] = {} end

	local sr, sg, sb = KUI:unpackColor(E.db.general.valuecolor)

	for glow, _ in pairs(KUI["softGlow"]) do
		if glow then
			glow:SetBackdropBorderColor(sr, sg, sb, 0.6)
		else
			KUI["softGlow"][glow] = nil;
		end
	end
end

function KUI:AddOptions()
	for _, func in pairs(KUI.Config) do
		func()
	end
end

function KUI:DasOptions()
	E:ToggleConfig(); LibStub("AceConfigDialog-3.0-ElvUI"):SelectGroup("ElvUI", "KlixUI")
end

function KUI:LoadCommands()
	self:RegisterChatCommand("kui", "DasOptions")
end

function KUI:SetMoverPosition(mover, point, anchor, secondaryPoint, x, y)
	if not _G[mover] then return end
	local frame = _G[mover]

	frame:ClearAllPoints()
	frame:SetPoint(point, anchor, secondaryPoint, x, y)
	E:SaveMoverPosition(mover)
end

function KUI:Reset(group)
	if not group then print("U wot m8?") end

	if group == "marks" or group == "all" then
		E:CopyTable(E.db.KlixUI.raidmarkers, P.KlixUI.raidmarkers)
		E:ResetMovers(L["Raid Marker Bar"])
	end
	E:UpdateAll()
end

function KUI:GetMapInfo(id, arg)
	if not arg then return end
	local MapInfo = C_Map.GetMapInfo(id)
	if not MapInfo then return UNKNOWN end
	-- for k,v in pairs(MapInfo) do print(k,v) end
	if arg == "all" then return MapInfo["name"], MapInfo["mapID"], MapInfo["parentMapID"], MapInfo["mapType"] end
	return MapInfo[arg]
end

GetSpell = function(id)
	local name = GetSpellInfo(id)
	return name
end

SafeHookScript = function (frame, handlername, newscript)
	local oldValue = frame:GetScript(handlername);
	frame:SetScript(handlername, newscript);
	return oldValue;
end

--Search in a table like {"arg1", "arg2", "arg3"}
function KUI:SimpleTable(table, item)
	for i = 1, #table do
		if table[i] == item then  
			return true 
		end
	end

	return false
end

local GetAddOnEnableState = GetAddOnEnableState
--Check if some stuff happens to be enable
KUI._Compatibility = {}
local _CompList = {
	"WorldQuestTracker",
	"TradeSkillMaster",
	"DejaCharacterStats",
	"DejaAutoMark",
}
for i = 1, #_CompList do
	if GetAddOnEnableState(E.myname, _CompList[i]) == 0 then KUI._Compatibility[_CompList[i]] = nil else KUI._Compatibility[_CompList[i]] = true end
end

function KUI:AddMoverCategories()
	tinsert(E.ConfigModeLayouts, #(E.ConfigModeLayouts) + 1, "KLIXUI")
	E.ConfigModeLocalizedStrings["KLIXUI"] = format("|cfff960d9%s |r", "KlixUI")

end

function KUI:IsAddOnEnabled(addon) -- Credit: Azilroka
	return GetAddOnEnableState(E.myname, addon) == 2
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
	SetCVar("blockTrades", 0) -- Lets set this on every login
	KUI:Initialize()
end)

KUI["RegisteredModules"] = {}
function KUI:RegisterModule(name)
	if self.initialized then
		local module = self:GetModule(name);
		if (module and module.Initialize) then
			module:Initialize();
		end
	else
		self["RegisteredModules"][#self["RegisteredModules"] + 1] = name
	end
end

function KUI:InitializeModules()
	for _, moduleName in pairs(KUI["RegisteredModules"]) do
		local module = self:GetModule(moduleName)
		if module.Initialize then
			module:Initialize();
		end
	end
end

function KUI:SetupProfileCallbacks()
	E.data.RegisterCallback(self, "OnProfileChanged", "UpdateAll")
	E.data.RegisterCallback(self, "OnProfileCopied", "UpdateAll")
	E.data.RegisterCallback(self, "OnProfileReset", "UpdateAll")
end

-- Whiro's code magic
function KUI:UpdateRegisteredDBs()
	if (not KUI["RegisteredDBs"]) then
		return
	end

	local dbs = KUI["RegisteredDBs"]

	for tbl, path in pairs(dbs) do
		self:UpdateRegisteredDB(tbl, path)
	end
end

function KUI:UpdateRegisteredDB(tbl, path)
	local path_parts = {strsplit(".", path)}
	local _db = E.db.KlixUI
	for _, path_part in ipairs(path_parts) do
		_db = _db[path_part]
	end
	tbl.db = _db
end

function KUI:RegisterDB(tbl, path)
	if (not KUI["RegisteredDBs"]) then
		KUI["RegisteredDBs"] = {}
	end
	self:UpdateRegisteredDB(tbl, path)
	KUI["RegisteredDBs"][tbl] = path
end

function KUI:UpdateAll()
	self:UpdateRegisteredDBs();
	for _, mod in pairs(self["RegisteredModules"]) do
		if mod and mod.ForUpdateAll then
			mod:ForUpdateAll();
		end	
	end
end

--This function will handle initialization of the addon
function KUI:Initialize()
	self.initialized = true
	if KUI.ElvUIV < KUI.ElvUIX then
		E:StaticPopup_Show("VERSION_MISMATCH")
		return -- If ElvUI Version is outdated stop right here. So things don't get broken.
	end
	
	self:RegisterKuiMedia()
	self:LoadCommands()
	self:SplashScreen()
	self:AddMoverCategories()
	self:InitializeModules()
	self:SetupProfileCallbacks()

	-- Create empty saved vars if they doesn't exist
	if not KUIDataDB then
		KUIDataDB = {}
	end

	if not KUIDataPerCharDB then
		KUIDataPerCharDB = {}
	end
	
	--Initiate installation process if ElvUI install is complete and our plugin install has not yet been run
	if E.private.install_complete == E.version and E.db.KlixUI.installed == nil then
		E:GetModule("PluginInstaller"):Queue(KUI.installTable)
	end
	if not E.private.KlixUI.characterGoldsSorting[E.myrealm] then E.private.KlixUI.characterGoldsSorting[E.myrealm] = {} end

	-- run the setup again when a profile gets deleted.
	local profileKey = ElvDB.profileKeys[E.myname..' - '..E.myrealm]
	if ElvDB.profileKeys and profileKey == nil then
		E:GetModule("PluginInstaller"):Queue(KUI.installTable)
	end
	
	if E.db.KlixUI.general.loginMessage then
		print(KUI.Title..format('v|cfff960d9%s|r',KUI.Version)..L[' is loaded. For any issues or suggestions, please visit ']..KUI:PrintURL('https://discord.gg/GbQbDRX'))
	end
	
	KUI:BuildGameMenu()
	
	--Insert our options table when ElvUI config is loaded
	EP:RegisterPlugin(addon, self.AddOptions)
	
	hooksecurefunc(E, "UpdateMedia", KUI.UpdateSoftGlowColor)
end