-- English localization file for enUS and enGB.
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");
local L = AceLocale:NewLocale("ElvUI", "enUS");
if not L then return end

-- General Options / Core
L["A plugin for |cff1784d1ElvUI|r by Klix (EU-Twisting Nether)"] = true
L['by Klix (EU-Twisting Nether)'] = true
L["KUI_DESC"] = [=[|cfff960d9KlixUI|r is an extension of ElvUI. It adds:

- Alot of new features.
- A transparent look.
- A decorative texture on alot of frames.
- Support both DPS and Healer specialization.
- compatible with most of other ElvUI plugins.

|cfff960d9Note:|r Some more available options can be found in the ElvUI options marked with |cfff960d9pink color|r.  

|cffff8000Newest additions are marked with:|r]=]

L['Install'] = true
L['Run the installation process.'] = true
L["Reload"] = true
L['Reaload the UI'] = true
L["Changelog"] = true
L['Open the changelog window.'] = true
L["Modules"] = true
L["Media"] = true
L["Skins & AddOns"] = true
L["AFK Screen"] = true
L["Enable/Disable the |cfff960d9KlixUI|r AFK Screen.\nCredit: |cff00c0faBenikUI|r"] = true
L["Game Menu Screen"] = true
L["Enable/Disable the |cfff960d9KlixUI|r Game Menu Screen.\nCredit: |cffff7d0aMerathilisUI|r"] = true
L['Splash Screen'] = true
L["Enable/Disable the |cfff960d9KlixUI|r Splash Screen.\nCredit: |cff00c0faBenikUI|r"] = true
L['Login Message'] = true
L["Enable/Disable the Login Message in Chat."] = true
L["Game Menu Button"] = true
L["Show/Hide the |cfff960d9KlixUI|r Game Menu button"] = true
L['Tweaks'] = true
L["Speedy Loot"] = true
L["Enable/Disable faster corpse looting."] = true
L["Easy Delete"] = true
L['Enable/Disable the ability to delete an item without the need of typing: "delete".'] = true --WIP
L["Cinematic"] = true
L["Skip Cut Scenes"] = true
L["Enable/Disable cut scenes."] = true
L["Cut Scenes Sound"] = true
L["Enable/Disable sounds when a cut scene pops.\n|cffff8000Note: This will only enable if you have your sound disabled.|r"] = true
L["Talkinghead Sound"] = true
L["Enable/Disable sounds when the talkingheadframe pops.\n|cffff8000Note: This will only enable if you have your sound disabled."] = true
L["Here you find the options for all the different |cfff960d9KlixUI|r modules.\nPlease use the dropdown to navigate through the modules."] = true
L['Information'] = true
L['Support & Downloads'] = true
L['KlixUI Discord Server'] = true
L["Tukui.org Discord Server"] = true
L['Git Ticket Tracker'] = true
L['Tukui.org'] = true
L['Curseforge.com'] = true
L['Development Version'] = true
L['Here you can download the latest development version.'] = true
L["Coding"] = true
L["Testing & Inspiration"] = true
L['Donations'] = true
L["My other Addons"] = true
L["|cfffb4f4fSkullflowers UI C.A|r"] = true
L["A continuation of the popular and highly demanded Skullflower UI."] = true
L["|cfffb4f4fSkullflowers UI Texture Pack|r"] = true
L["Texture pack for all the Skullflower textures."] = true
L["ElvUI Fog Remover"] = true
L["Removes the fog from the World map, thus displaying the artwork for all the undiscovered zones, optionally with a color overlay on undiscovered areas."] = true
L["ElvUI Chat Tweaks Continued"] = true
L["Chat Tweaks adds various enhancements to the default ElvUI chat."] = true
L["ElvUI Enhanced Currency"] = true
L["A simple yet enhanced currency datatext."] = true
L["ElvUI Compass Points"] = true
L["Adds cardinal points to the elvui minimap."] = true
L["|cfff2f251Cool Glow|r"] = true
L["Changes the actionbar proc glow to something cool!"] = true
L["Masque: |cfff960d9KlixUI|r"] = true
L["My masque skin to match the UI."] = true
L["Version"] = true

-- Actionbars
L["Credits"] = true
L['ActionBars'] = true
L["General"] = true
L['Transparent Backdrops'] = true
L['Applies transparency in all actionbar backdrops and actionbar buttons.'] = true
L['Clean Button'] = true
L['Removes the textures around the Bossbutton and the Zoneability button.'] = true
L["Glow"] = true
L["Color"] = true
L["Num Lines"] = true
L["Defines the number of lines the glow will spawn."] = true
L["Frequency"] = true
L["Sets the animation speed of the glow. Negative values will rotate the glow anti-clockwise."] = true
L["Length"] = true
L["Defines the lenght of each individual glow lines."] = true
L["Thickness"] = true
L["Defines the thickness of the glow lines."] = true
L["X-Offset"] = true
L["Y-Offset"] = true
L["Specialization & Equipment Bar"] = true
L["Enable"] = true
L['Show/Hide the |cfff960d9KlixUI|r Spec & EquipBar.'] = true
L["Mouseover"] = true
L["Alpha"] = true -- doesnt work
L["Change the alpha level of the frame."] = true
L["Hide In Combat"] = true
L['Show/Hide the |cfff960d9KlixUI|r Spec & EquipBar in combat.'] = true
L["Hide In Orderhall"] = true
L['Show/Hide the |cfff960d9KlixUI|r Spec & Equip Bar in the class hall.'] = true
L["Micro Bar"] = true
L['Show/Hide the |cfff960d9KlixUI|r MicroBar.'] = true
L["Microbar Scale"] = true
L['Show/Hide the |cfff960d9KlixUI|r MicroBar in combat.'] = true
L['Show/Hide the |cfff960d9KlixUI|r MicroBar in the class hall.'] = true
L["Highlight"] = true
L['Show/Hide the highlight when hovering over the |cfff960d9KlixUI|r MicroBar buttons.'] = true
L["Buttons"] = true
L['Only show the highlight of the buttons when hovering over the |cfff960d9KlixUI|r MicroBar buttons.'] = true
L["Text"] = true
L["Position"] = true
L["Top"] = true
L["Bottom"] = true
L['Show/Hide the friend text on |cfff960d9KlixUI|r MicroBar.'] = true
L['Show/Hide the guild text on |cfff960d9KlixUI|r MicroBar.'] = true

-- Addon Panel
L["Addon Control Panel"] = true
L['# Shown AddOns'] = true
L['Frame Width'] = true
L['Button Height'] = true
L['Button Width'] = true
L['Font'] = true
L['Font Outline'] = true
L["Value Color"] = true
L["Font Color"] = true
L['Texture'] = true
L['Class Color Check Texture'] = true

-- Armory
L["Armory"] = true
L["Enable/Disable the |cfff960d9KlixUI|r Armory Mode."] = true
L["Azerite Buttons"] = true
L["Enable/Disable the Azerite Buttons on the character window."] = true
L["Naked Button"] = true
L["Enable/Disable the Naked Button on the character window."] = true
L["Durability"] = true
L["Enable/Disable the display of durability information on the character window."] = true
L["Damaged Only"] = true
L["Only show durability information for items that are damaged."] = true
L["Itemlevel"] = true -- doesnt work
L["Enable/Disable the display of item levels on the character window."] = true
L["Level"] = true
L["Full Item Level"] = true
L["Show both equipped and average item levels."] = true
L["Item Level Coloring"] = true
L["Color code item levels values. Equipped will be gradient, average - selected color."] = true
L["Color of Average"] = true
L["Sets the color of average item level."] = true
L["Only Relevant Stats"] = true
L["Show only those primary stats relevant to your spec."] = true
L["Item Level"] = true
L["Categories"] = true

-- Bags
L["Transparent Slots"] = true
L["Apply transparent template on bag and bank slots."] = true
L["Bag Filter"] = true
L["Enable/disable the bagfilter button."] = true
L["Auto Open Containers"] = true
L["Enable/disable the auto opening of container, treasure etc."] = true

-- Chat
L['Chat'] = true
L["Voice Menu"] = true
L["Enables the Voice Menu Bar.\n|cffff8000Note: The Voice Menu Bar is by default hidden and needs to be toggled through the chat button 'v'.|r"] = true
L["Social Button"] = true
L["Enables the Social Button at the Voice Menu Bar.\n|cffff8000Note: The Social Button is tied to the Voice Menu Bar which is by default hidden and needs to be toggled through the chat button 'v'.|r"] = true
L['Chat Tabs'] = true
L["Selected Indicator"] = true
L["Shows you which of your docked chat tabs which is currently selected."] = true
L["Style"] = true
L['Fade Chat Tabs'] = true
L['Fade out chat tabs except the currently selected chat tab.'] = true
L['Chat Tab Alpha'] = true
L['Alpha of faded chat tabs.'] = true
L['Force to Show'] = true
L['Force a tab to show when it is flashing. This works both for when chat panel backdrop is hidden and when chat tab is faded.'] = true
L['Force Show Threshold'] = true
L['Threshold before a faded chat tab is forced to show. If a faded chat tab alpha is less than or equal to this value then it will be forced to show.'] = true
L['Force Show Alpha'] = true
L['Alpha of a chat tab when it is forced to show.'] = true

-- Cooldowns
L["Cooldown Flash"] = true
L["Icon Size"] = true
L["Fadein duration"] = true
L["Fadeout duration"] = true
L["Transparency"] = true
L["Duration time"] = true
L["Animation size"] = true
L["Display spell name"] = true
L["Watch on pet spell"] = true
L["Test"] = true

-- Databars
L["DataBars"] = true
L["Enable/Disable the |cfff960d9KlixUI|r DataBar color mod."] = true
L["|cfff960d9KlixUI|r Style"] = true
L["Capped"] = true
L["Replace XP text with the word 'Capped' at max level."] = true
L["Blend Progress"] = true
L["Progressively blend the bar as you gain XP."] = true
L["XP Color"] = true
L["Select your preferred XP color."] = true
L["Rested Color"] = true
L["Select your preferred rested color."] = true
L["Reputation Bar"] = true
L["Replace rep text with the word 'Capped' or 'Paragon' at max."] = true
L["Progressively blend the bar as you gain reputation."] = true
L["Auto Track Reputation"] = true
L["Automatically change your watched faction on the reputation bar to the faction you got reputation points for."] = true
L["'Paragon' Format"] = true
L["If 'Capped' is toggled and watched faction is a Paragon then choose short or long."] = true
L["P"] = true
L["Paragon"] = true
L["Progress Colour"] = true
L["Change rep bar colour by standing."] = true
L["Reputation Colors"] = true
L["Honor Bar"] = true
L["Progressively blend the bar as you gain honor."] = true
L["Honor Color"] = true
L["Change the honor bar color."] = true
L["Azerite Bar"] = true
L["Progressively blend the bar as you gain Azerite Power"] = true
L["Azerite Color"] = true
L["Change the Azerite bar color"] = true

-- Datatext
L["DataTexts"] = true
L["DT_DESC"] = [[This module provides alot of different new features for the datatexts.
|cffff8000You can change all datatexts on the fly by 'CTRL + ALT + Right click' on a visible datatext. This will bring up an option menu with all the current available datatexts to choose from.|r]]
L["Left ChatTab Panel"] = true
L["Show/Hide the left ChatTab DataTexts"] = true
L["Right ChatTab Panel"] = true
L["Show/Hide the right ChatTab DataTexts"] = true
L["Time Size"] = true
L["Change the size of the Time DataText."] = true
L["Panels"] = true
L["Chat Datatext Panel"] = true
L['Panel Transparency'] = true
L['Chat EditBox Position'] = true
L['Position of the Chat EditBox, if datatexts are disabled this will be forced to be above chat.'] = true
L['Below Chat'] = true
L['Above Chat'] = true
L["Frame Strata"] = true
L['Backdrop'] = true
L['Game Menu Dropdown Color'] = true
L["Middle Datatext Panel"] = true
L['Show/Hide the Middle DataText Panel.'] = true
L["Width"] = true
L["Height"] = true
L["Other DataTexts"] = true
L["System Datatext"] = true
L["Max Addons"] = true
L["Maximum number of addons to show in the tooltip."] = true
L["Announce Freed"] = true
L["Announce how much memory was freed by the garbage collection."] = true
L["Show FPS"] = true
L["Show FPS on the datatext."] = true
L["Show Memory"] = true
L["Show total addon memory on the datatext."] = true
L["Show Latency"] = true
L["Show latency on the datatext."] = true
L["Latency Type"] = true
L["Display world or home latency on the datatext. Home latency refers to your realm server. World latency refers to the current world server."] = true
L["Home"] = true
L["World"] = true
L["Titles Datatext"] = true
L["Use Character Name"] = true
L["Use your character's class color and name in the tooltip."] = true
L["ElvUI DataTexts"] = true
L["Order of each toon. Smaller numbers will go first"] = true
L["Currency"] = true
L["Show Archaeology Fragments"] = true
L["Show Jewelcrafting Tokens"] = true
L["Show Player vs Player Currency"] = true
L["Show Dungeon and Raid Currency"] = true
L["Show Cooking Awards"] = true
L["Show Miscellaneous Currency"] = true
L["Show Zero Currency"] = true -- ??
L["Show Icons"] = true
L["Show Faction Totals"] = true
L["Show Unused Currencies"] = true
L["Delete character info"] = true
L["Remove selected character from the stored gold values"] = true
L["Are you sure you want to remove |cff1784d1%s|r from currency datatexts?"] = true
L["Gold Sorting"] = true
L["Sort Direction"] = true
L["Normal"] = true
L["Reversed"] = true
L["Sort Method"] = true
L["Amount"] = true
L["Currency Sorting"] = true
L["Direction"] = true
L["Tracked"] = true
L["KlixUI DataTexts"] = true

-- Enhanced Friendslist
L["Enhanced Friends List"] = true
L["Name Font"] = true
L["Info Font"] = true
L["Game Icon Pack"] = true
L["Status Icon Pack"] = true
L["Game Icon Preview"] = true
L["Diablo 3"] = true
L["Hearthstone"] = true
L["Starcraft"] = true
L["Starcraft 2"] = true
L["App"] = true
L["Mobile"] = true
L["Hero of the Storm"] = true
L["Overwatch"] = true
L["Destiny 2"] = true
L["Call of Duty 4"] = true
L["Status Icon Preview"] = true

-- Equip Manager
L["Timewalking"] = true
L["No Change"] = true
L["Equip this set when switching to specialization %s."] = true
L["Equip this set for open world/general use."] = true
L["Equip this set after entering dungeons or raids."] = true
L["Equip this set after enetering a timewalking dungeon."] = true
L["Equip this set after entering battlegrounds or arens."] = true
L["Equipment Manager"] = true
L["EM_DESC"] = [[This module provides different options to automatically change your equipment sets on spec change or entering certain locations.
|cffff8000All options are character based.|r]]
L["Enable/Disable the Equipment Manager and the all character window texts."] = true
L["Equipment Set Overlay"] = true
L["Show the associated equipment sets for the items in your bags (or bank)."] = true
L["Block button"] = true
L["Create a button in the character window to allow temporary blocking of auto set swap."] = true
L["Ignore zone change"] = true
L["Swap sets only on specialization change ignoring location change when. Does not influence entering/leaving instances and bg/arena."] = true
L["Equipment conditions"] = true

-- Equip Manager unfinished/unknown
L["KUI_EM_CONDITIONS_DESC"] = [[Determines conditions under which specified sets are equipped.
This works as macros and controlled by a set of tags as seen below.]]
L["Impossible to switch to appropriate equipment set in combat. Will switch after combat ends."] = true
L["KUI_EM_LOCK_TITLE"] = [[|cfff960d9KlixUI|r]]
L["KUI_EM_LOCK_TOOLTIP"] = [[This button is designed for temporary disable
Equip Manager's auto switch gear sets.
While locked (red colored state) it will disable auto swap.]]

L["KUI_EM_SET_NOT_EXIST"] = [[Equipment set |cfff960d9%s|r doesn't exist!]]
L["KUI_EM_TAG_INVALID"] = [[Invalid tag: %s]]
L["KUI_EM_TAG_INVALID_TALENT_TIER"] = [[Invalid argument for talent tag. Tier is |cfff960d9%s|r, should be from 1 to 7.]]
L["KUI_EM_TAG_INVALID_TALENT_COLUMN"] = [[Invalid argument for talent tag. Column is |cfff960d9%s|r, should be from 1 to 3.]]
L["KUI_EM_TAG_DOT_WARNING"] = [[Wrong separator for conditions detected. You need to use commas instead of dots.]]

L["KUI_EM_TAGS_HELP"] = [[Following tags and parameters are eligible for setting equip condition:
|cfff960d9solo|r - when you are solo without any group;
|cfff960d9party|r - when you are in a group of any description. Can be of specified size, e.g. [party:4] - if in a group of total size 4;
|cfff960d9raid|r - when you are in a raid group. Can be of specified size like party option;
|cfff960d9spec|r - specified spec. Usage [spec:<number>] number is the index of desired spec as seen in spec tab;
|cfff960d9talent|r - specified talent. Usage [talent:<tier>/<column>] tier is the row going from 1 on lvl 15 to 7 and lvl 100, column is the column in said row from 1 to 3;
|cfff960d9instance|r - if in instance. Can be of specified instance type - [instance:<type>]. Types are party, raid and scenario. If not specified will be true for any instance;
|cfff960d9pvp|r - if on BG, arena or world pvp area. Available arguments: pvp, arena;
|cfff960d9difficulty|r - defines the difficulty of the instance. Arguments are: normal, heroic, lfr, challenge, mythic;

Example: [solo] Set1; [party:4, spec:3] Set2; [instance:raid, difficulty:heroic] Set3
]]

-- Location Panel
L["Location Panel"] = true
L["Link Position"] = true
L["Allow pasting of your coordinates in chat editbox via holding shift and clicking on the location name."] = true
L["Template"] = true
L["Transparent"] = true
L["NoBackdrop"] = true
L["Auto Width"] = true
L["Change width based on the zone name length."] = true
L["Spacing"] = true
L["Update Throttle"] = true
L["The frequency of coordinates and zonetext updates. Check will be done more often with lower values."] = true
L["Hide In Combat"] = true
L["Hide In Orderhall"] = true
L["Hide Blizzard Zone Text"] = true
L["Mouse Over"] = true
L["The frame is not shown unless you mouse over the frame"] = true
L["Change the alpha level of the frame."] = true
L["Show additional info in the Location Panel."] = true
L['None'] = true
L['Battle Pet Level'] = true
L["Location"] = true
L["Full Location"] = true
L["Color Type"] = true
L["Reaction"] = true
L["Custom Color"] = true
L["Coordinates"] = true
L["Format"] = true
L["Hide Coords"] = true
L["Show/Hide the coord frames"] = true
L["Hide Coords in Instance"] = true
L["Fonts"] = true
L["Font Size"] = true
L["Relocation Menu"] = true
L["Right click on the location panel will bring up a menu with available options for relocating your character (e.g. Hearthstones, Portals, etc)."] = true
L["Custom Width"] = true
L["By default menu's width will be equal to the location panel width. Checking this option will allow you to set own width."] = true
L["Justify Text"] = true
L["Left"] = true
L["Middle"] = true
L["Right"] = true
L["CD format"] = true
L["Hearthstone Location"] = true
L["Show the name on location your Heathstone is bound to."] = true
L["Show hearthstones"] = true
L["Show hearthstone type items in the list."] = true
L["Hearthstone Toys Order"] = true
L["Show Toys"] = true
L["Show toys in the list. This option will affect all other display options as well."] = true
L["Show spells"] = true
L["Show relocation spells in the list."] = true
L["Show engineer gadgets"] = true
L["Show items used only by engineers when the profession is learned."] = true
L["Ignore missing info"] = true -- ??
L["Show/Hide tooltip"] = true
L["Combat Hide"] = true
L["Hide tooltip while in combat."] = true
L["Show Hints"] = true
L["Enable/Disable hints on Tooltip."] = true
L["Enable/Disable status on Tooltip."] = true
L["Enable/Disable level range on Tooltip."] = true
L["Area Fishing level"] = true
L["Enable/Disable fishing level on the area."] = true
L["Battle Pet level"] = true
L["Enable/Disable battle pet level on the area."] = true
L["Recommended Zones"] = true
L["Enable/Disable recommended zones on Tooltip."] = true
L["Zone Dungeons"] = true
L["Enable/Disable dungeons in the zone, on Tooltip."] = true
L["Recommended Dungeons"] = true
L["Enable/Disable recommended dungeons on Tooltip."] = true
L["with Entrance Coords"] = true
L["Enable/Disable the coords for area dungeons and recommended dungeon entrances, on Tooltip."] = true
L["Enable/Disable the currencies, on Tooltip."] = true
L["Enable/Disable the professions, on Tooltip."] = true
L["Hide capped"] = true
L["Hides a profession when the player reaches its highest level."] = true
L["Hide Raid"] = true
L["Show/Hide raids on recommended dungeons."] = true
L["Hide PvP"] = true
L["Show/Hide PvP zones, Arenas and BGs on recommended dungeons and zones."] = true
L["KUI_LOCPANEL_IGNOREMISSINGINFO"] = [[Due to how client functions some item info may become unavailable for a period of time. This mostly happens to toys info.
When called the menu will wait for all information being available before showing up. This may resul in menu opening after some concidarable amount of time, depends on how fast the server will answer info requests.
By enabling this option you'll make the menu ignore items with missing info, resulting in them not showing up in the list.]]

-- Maps
L["Maps"] = true
L["Garrison Button Style"] = true
L["Change the look of the Garrison/OrderHall/BfA Mission Button"] = true
L["Minimap Blink"] = true
L["Shows the minimap blinking when a mail or a calendar invite is available."] = true
L["Hide minimap while in combat."] = true
L["FadeIn Delay"] = true
L["The time to wait before fading the minimap back in after combat hide. (0 = Disabled)"] = true
L["Mail"] = true
L["Enhanced Mail"] = true
L["Shows the enhanced mail tooltip and styling (Icon, color, and blink animation)."] = true
L['You have about %s unread mails'] = true
L['You have about %s unread mail'] = true
L[' from:'] = true
L["Play Sound"] = true
L["Plays a sound when a mail is received.\n|cffff8000Note: This will be disabled by default if notifcations or notification mail module is enabled.|r"] = true
L["Hide Mail Icon"] = true
L["Hide the mail Icon on the minimap."] = true
L["Bar Backdrop"] = true
L["Button Spacing"] = true
L["Buttons Per Row"] = true
L["Blizzard"] = true
L["Move Tracker Icon"] = true
L["Move Queue Status Icon"] = true
L["Move Mail Icon"] = true
L["Hide Garrison Icon"] = true
L["Move Garrison Icon"] = true
L["Minimap Ping"] = true
L["Shows the name of the player who pinged on the Minimap."] = true
L["Center"] = true
L["Enable/Disable Square Minimap Coords."] = true
L["Coords Display"] = true
L["Change settings for the display of the coordinates that are on the minimap."] = true
L["Minimap Mouseover"] = true
L["Always Display"] = true
L["Coords Location"] = true
L["This will determine where the coords are shown on the minimap."] = true
L["Cardinal Points"] = true
L["Places cardinal points on your minimap (N, S, E, W)"] = true
L["North"] = true
L["Places the north cardinal point on your minimap."] = true
L["East"] = true
L["Places the east cardinal point on your minimap."] = true
L["South"] = true
L["Places the south cardinal point on your minimap."] = true
L["West"] = true
L["Places the west cardinal point on your minimap."] = true
L["Worldmap"] = true
L["Flight Queue"] = true
L["Location Digits"] = true
L["Change the decimals of the coords on the location bar."] = true
L["Location Text"] = true
L["Change the text on the location bar."] = true
L["Version"] = true
L["Minimap Mouseover"] = true
L["Always Display"] = true
L["Above Minimap"] = true
L["Hide"] = true

-- Misc
L['Miscellaneous'] = true
L["Display the Guild Message of the Day in an extra window, if updated.\nCredit: |cffff7d0aMerathilisUI|r"] = true
L["Mover Transparency"] = true
L["Changes the transparency of all the movers."] = true
L["Announce Combat Status"] = true
L["Announce combat status in a textfield in the middle of the screen.\nCredit: |cffff7d0aMerathilisUI|r"] = true
L["Announce Skill Gains"] = true
L["Announce skill gains in a textfield in the middle of the screen.\nCredit: |cffff7d0aMerathilisUI|r"] = true
L["Buy Max Stack"] = true
L["Alt-Click on an item, sold buy a merchant, to buy a full stack."] = true
L["Auto Keystones"] = true
L["Automatically insert keystones when you open the keystonewindow in a dungeon."] = true
L["Hide TalkingHeadFrame"] = true
L["Flight Master's Whistle Location"] = true
L["Show the nearest Flight Master's Whistle Location on the minimap and in the tooltip."] = true
L["Flight Master's Whistle Sound"] = true
L["Plays a sound when you use the Flight Master's Whistle."] = true
L["Loot container opening sound"] = true
L["Plays a sound when you open a container, chest etc."] = true
L["Transmog Remover Button"] = true
L["Enable/Disable the transmog remover button in the transmogrify window."] = true
L["Raid Utility Mouse Over"] = true
L["Enabling mouse over will make ElvUI's raid utility show on mouse over instead of always showing."] = true
L["Work Orders"] = true
L["WO_DESC"] = [[This module will auto start any workorders in any legion class order hall, alliance/horde ship in battle for azeroth and Nomi work orders.

|cffff8000Note: Holding down any modifier key before visiting/talking to the respective NPC's will briefly disable the automatization.|r
]] -- that extra section is meant to be there!
L["OrderHall/Ship"] = true
L["Auto start orderhall/ship workorders when visiting the npc."] = true
L["Nomi"] = true
L["Auto start workorders when visiting Nomi."] = true
L["Merchant"] = true
L["Display the MerchantFrame in one window instead of a small one with variouse amount of pages."] = true
L["Subpages"] = true
L["Subpages are blocks of 10 items. This option set how many of subpages will be shown on a single page."] = true
L["Display the item level on the MerchantFrame, to change the font you have to set it in ElvUI - Bags - ItemLevel"] = true
L["Bloodlust"] = true
L["Sound"] = true
L["Play a sound when bloodlust/heroism is popped."] = true
L["Print a chat message of whom who popped bloodlust/heroism."] = true
L["Sound Type"] = true
L["Horde"] = true
L["Alliance"] = true
L["Illidan"] = true
L["Sound Override"] = true
L["Force to play even when other sounds are disabled."] = true
L["Use Custom Volume"] = true
L["Use custom volume.\n|cffff8000Note: This will only work if 'Sound Override' is enabled.|r"] = true
L["Volume"] = true
L["Custom Sound Path"] = true
L["Example of a path string: path\\path\\path\\sound.mp3"] = true
L["Easy Curve"] = true
L["Enable/disable the Easy Curve popup frame."] = true
L["Default Highest Achievements Found"] = true
L["Override Defaults"] = true
L["Enable Override"] = true
L["Overrides the default achievements found and will always send the selected achievement from the dropdown."] = true
L["Search Achievements"] = true
L["Search term must be greater than 3 characters."] = true
L["Error: Search term must be greater than 3 characters"] = true
L["Select Override Achievement"] = true
L["Results are limited to 500 and only completed achievemnts. Please try a more specific search term if you cannot find the achievement listed."] = true
L["Error: Please select an achievement"] = true
L["Other Options"] = true
L["Always Check Achievement Whisper Dialog Checkbox"] = true
L["This will always check the achievement whisper dialog checkbox when signing up for a group by default."] = true
L["Always Check Keystone Whisper Dialog Checkbox"] = true
L["This will always check the keystone whisper dialog checkbox when signing up for a mythic plus group by default."] = true
L["Role Check"] = true
L["Automatically accept all role check popups."] = true
L["Confirm Role Checks"] = true
L["After you join a custom group finder raid a box pops up telling you your role and won't dissapear until clicked, this gets rid of it."] = true
L["Automatically accept timewalking role check popups."] = true
L["Love is in the Air"] = true
L["Automatically accept Love is in the Air dungeon role check popups."] = true
L["Halloween"] = true
L["Automatically accept Halloween dungeon role check popups."] = true
L['Top Panel'] = true
L["Display a panel across the top of the screen. This is for cosmetic only."] = true
L['Bottom Panel'] = true
L["Display a panel across the bottom of the screen. This is for cosmetic only."] = true
L["Scrap Machine"] = true
L["Show the scrapbutton at the scrappingmachineUI."] = true
L["Place scrap button at the top or the bottom of the scrappingmachineUI."] = true
L["Equipment Sets"] = true
L["Ignore items in equipment sets."] = true
L["Ignore azerite items."] = true
L["Bind-on-Equipped"] = true
L["Ignore bind-on-equipped items."] = true
L["Equipped Item Level"] = true
L["Don't insert items above equipped iLvl."] = true
L["Specific Item Level"] = true
L["Ignore items above specific item level."] = true
L["Auto Open Bags"] = true
L["Auto open bags when visiting the scrapping machine."] = true
L["Character Zoom"] = true
L["Enable/disable automatically combat logging."] = true
L["All raids"] = true
L["Combat log all raids regardless of individual raid settings"] = true
L["Display in chat"] = true
L["Display the combat log status in the chat window"] = true
L["5 player heroic instances"] = true
L["Combat log 5 player heroic instances"] = true
L["5 player challenge mode instances"] = true
L["Combat log 5 player challenge mode instances"] = true
L["5 player mythic instances"] = true
L["Combat log 5 player mythic instances"] = true
L["Minimum level"] = true
L["Logging will not be enabled for mythic levels lower than this"] = true
L["LFR Raids"] = true
L["Raid finder instances where you want to log combat"] = true
L["Normal Raids"] = true
L["Raid instances where you want to log combat"] = true
L["Heroic Raids"] = true
L["Raid instances where you want to log combat"] = true
L["Mythic Raids"] = true
L["Raid instances where you want to log combat"] = true
L["Confirm Static Popups"] = true
L["Auto Answer"] = true
L["REQUEST"] = [[- static popup not supported, if you want it added to the UI, please post it in my discord: ]]
L["NOTENABLED"] = [[- static popup not enabled in the options.]]
-- Character Zoom
L['DISTANCE'] = [[Distance]]
L['ZOOM_INCREMENT'] = [[Zoom Increment]]
L['ZOOM_SPEED'] = [[Zoom Speed]]

-- Misc pt.2 (DEV ONLY?)
L["Corrupted Ashbringer"] = true
L["Display the MerchantFrame in one window instead of a small one with variouse amount of pages."] = true
L["Sound Number"] = true
L["Changes which of the corrupted ashbringer sounds it should play in a numeric order."] = true
L["Sound Probability"] = true
L["Changes the probability value, in percent, how often the sounds will play."] = true

-- Notification
L["Notification"] = true
L["Here you can enable/disable the different notification types."] = true
L["Raid Disabler"] = true
L["Enable/disable the notification toasts while in a raid group."] = true
L["No Sounds"] = true
L["Enable/disable the sound effect of the notification toasts."] = true
L["Chat Message"] = true
L["Enable/disable the notification message in chat."] = true
L["Mail"] = true
L["Vignette"] = true
L["If a Rare Mob or a treasure gets spotted on the minimap."] = true
L["Invites"] = true
L["Guild Events"] = true
L["Quick Join Notification"] = true
L["This is an example of a notification."] = true
L["You have a new mail!"] = true
L["%s slot needs to repair, current durability is %d."] = true
L["You have %s pending calendar |4invite:invites;."] = true
L["You have %s pending guild |4event:events;."] = true
L["has appeared on the MiniMap!"] = true
L["is looking for members"] = true
L["joined a group"] = true
L["joined a group "] = true

--Quest
L["Auto Pilot"] = true
L["This section enables auto accepting and auto finishing various quests."] = true
L["Disable Key"] = true
L["When the specific key is down the quest automatization is disabled."] = true
L["Auto Accept Quests"] = true
L["Enable/Disable auto quest accepting"] = true
L["Auto Complete Quests"] = true
L["Enable/Disable auto quest complete"] = true
L["Dailies Only"] = true
L["Enable/Disable auto accepting for daily quests only"] = true
L["Accept PVP Quests"] = true
L["Enable/Disable auto accepting for PvP flagging quests"] = true
L["Auto Accept Escorts"] = true
L["Enable/Disable auto escort accepting"] = true
L["Enable in Raid"] = true
L["Enable/Disable auto accepting quests in raid"] = true
L["Skip Greetings"] = true
L["Enable/Disable NPC's greetings skip for one or more quests"] = true
L["Auto Select Quest Reward"] = true
L["Automatically select the quest reward with the highest vendor sell value."] = true
L["Quest Announce"] = true
L["Announce Every"] = true
L["Announce progression every x number of steps (0 will announce on quest objective completion only)"] = true
L["Enable/disable the quest announce sound."] = true
L["Debug"] = true
L["Enable/disable the debug mode, for advanced users only!"] = true
L["Test Frame Messages"] = true
L["Where do you want to make the announcements?"] = true
L["Chat Frame"] = true
L["Raid Warning Frame"] = true
L["UI Errors Frame"] = true
L["What channels do you want to make the announcements?"] = true
L["Say"] = true
L["Party"] = true
L["Instance"] = true
L["Guild"] = true
L["Officer"] = true
L["Whisper"] = true
L["Are you sure you want to announce to this channel?"] = true
L["Whisper Who"] = true
L["Smart Quest Tracker"] = true
L["This section modify the ObjectiveTracker to only display your quests available for completion in your current zone."] = true
L['Untrack quests when changing area'] = true
L["Completed quests"] = true
L["Quests from other areas"] = true
L["Keep daily and weekly quest tracked"] = true
L['Sorting of quests in tracker'] = true
L["Automatically sort quests"] = true
L["Print all quests to chat"] = true
L["Print tracked quests to chat"] = true
L["Untrack all quests"] = true
L["Force update of tracked quests"] = true
L["Quest Tracker Visibility"] = true
L["Adjust the settings for the visibility of the questtracker (questlog) to your personal preference."] = true
L["Rested"] = true
L["Class Hall"] = true

-- Raidmarkers
L["Raid Markers"] = true
L["Options for panels providing fast access to raid markers and flares."] = true
L["Show/Hide raid marks."] = true
L["Restore Defaults"] = true
L["Reset these options to defaults"] = true
L["Button Size"] = true
L["Button Spacing"] = true
L["Orientation"] = true
L["Horizontal"] = true
L["Vertical"] = true
L["Reverse"] = true
L["Modifier Key"] = true
L["No tooltips"] = true
L["Raid Marker Icons"] = true
L["Choose what Raid Marker Icon Set the bar will display."] = true
L["Visibility"] = true
L["Always Display"] = true
L["Visibility State"] = true
L["Auto Mark"] = true
L["Enable/Disable auto mark of tanks and healers in dungeons."] = true
L["Tank Mark"] = true
L["Healer Mark"] = true

-- Raidbuff Reminder
L["Raid Buff Reminder"] = true
L["Shows a frame with flask/food/rune."] = true
L["Toggles the display of the raidbuffs backdrop."] = true
L["Size"] = true
L["Changes the size of the icons."] = true
L["Change the alpha level of the icons."] = true
L["Class Specific Buffs"] = true
L["Shows all the class specific raidbuffs."] = true
L["Shows the pixel glow on missing raidbuffs."] = true

-- Skins
L["ActonBarProfiles"] = true
L["Baggins"] = true
L["BigWigs"] = true
L["BugSack"] = true
L["Deadly Boss Mods"] = true
L["ElvUI_DTBars2"] = true
L["Shadow & Light"] = true
L["ls_Toasts"] = true
L["ProjectAzilroka"] = true
L["WeakAuras"] = true
L["XIV_Databar"] = true
L['KlixUI successfully created and applied profile(s) for:'] = true 
L["|cfff960d9KlixUI|r Style |cffff8000(Beta)|r"] = true
L["Creates decorative squares, a gradient and a shadow overlay on some frames.\n|cffff8000Note: This is still in beta state, not every blizzard frames are skinned yet!|r"] = true
L["KlixUI "] = true
L["Redesign the standard close button with a custom one."] = true
L["KlixUI Shadows"] = true
L["Creates a shadow overlay around the whole screen for a more darker finish."] = true
L["Addon Skins"] = true
L["KUI_ADDONSKINS_DESC"] = [[This section is designed to modify some external addons appearance.

Please note that some of these options will be |cff636363disabled|r if the addon is not loaded in the addon control panel.]]
L["Blizzard Skins"] = true
L["KUI_SKINS_DESC"] = [[This section is designed to modify already existing ElvUI skins.

Please note that some of these options will not be available if corresponding skin is |cff636363disabled|r in the main ElvUI skins section.]]
L["ElvUI Skins"] = true
L["Character Frame"] = true
L["Gossip Frame"] = true
L["Quest Frames"] = true
L["Quest Choice"] = true
L["Orderhall"] = true
L["Archaeology Frame"] = true
L["Barber Shop"] = true
L["Contribution"] = true
L["Calendar Frame"] = true
L["Merchant Frame"] = true
L["PvP Frames"] = true
L["Item Upgrade"] = true
L["LF Guild Frame"] = true
L["TalkingHead"] = true
L["AddOn Manager"] = true
L["Mail Frame"] = true
L["Raid Frame"] = true
L["Guild Control Frame"] = true
L["Help Frame"] = true
L["Loot Frames"] = true
L["Warboard"] = true
L["Azerite"] = true
L["BFAMission"] = true
L["Island Party Pose"] = true
L["Minimap"] = true
L["Trainer Frame"] = true
L["Debug Tools"] = true
L["Inspect Frame"] = true
L["Socket Frame"] = true
L["Addon Profiles"] = true
L["KUI_PROFILE_DESC"] = [[This section creates Profiles for some AddOns.

|cffff0000WARNING:|r It will overwrite/delete existing Profiles. If you don't want to apply these Profiles please don't press the Button(s) below.]]
L['This will create and apply profile for '] = true
L["KlixUI Skins"] = true

-- Talents
L["Talents"] = true
L["Toggle Talent Frame"] = true
L["Enable/disable the |cfff960d9KlixUI|r Better Talents Frame."] = true
L["Default to Talents Tab"] = true
L["Defaults to the talents tab of the talent frame on login. By default WoW shows you the specialization tab."] = true
L["Auto Hide PvP Talents"] = true
L["Closes the PvP talents flyout on login. PvP talents and warmode flag are still accessible by manually opening the PvP talents flyout."] = true

-- Tooltip
L["Tooltip"] = true
L["Change the visual appearance of the Tooltip.\nCredit: |cffff7d0aMerathilisUI|r"] = true 
L["Adds information to the tooltip, on which character you earned an achievement.\nCredit: |cffff7d0aMerathilisUI|r"] = true
L["Keystone"] = true
L["Adds descriptions for mythic keystone properties to their tooltips."] = true
L["Enable/disable the azerite tooltip."] = true
L["Remove Blizzard"] = true
L["Replaces the blizzard azerite tooltip text."] = true
L["Specialization"] = true
L["Only show the traits for your current specialization."] = true
L["Compact"] = true
L["Only show icons in the azerite tooltip."] = true
L["Raid Progression"] = true
L["Shows raid progress of a character in the tooltip.\n|cffff8000Note: Requires holding down the shift key.|r"] = true
L["Name Style"] = true
L["Full"] = true
L["Short"] = true
L["Difficulty Style"] = true
L["Realm Info"] = true
L["Shows realm info in various tooltips."] = true
L["Tooltips"] = true
L["Show the realm info in the group finder tooltip."] = true
L["Player Tooltips"] = true
L["Show the realm info in the player tooltip."] = true
L["Friend List"] = true
L["Show the realm info in the friend list tooltip."] = true
L["Tooltip Lines"] = true
L["Realm Timezone"] = true
L["Add realm timezone to the tooltip."] = true
L["Realm Type"] = true
L["Add realm type to the tooltip."] = true
L["Realm Language"] = true
L["Add realm language to the tooltip."] = true
L["Connected Realms"] = true
L["Add the connected realms to the tooltip."] = true
L["Country Flag"] = true
L["Display the country flag without text on the left side in tooltip."] = true
L["Behind language in 'Realm language' line"] = true
L["Behind the character name"] = true
L["In own tooltip line on the left site"] = true
L["Prepend country flag on character name in group finder."] = true
L["Prepend country flag on character name in community member lists."] = true

-- Unitframes
L["UnitFrames"] = true
L['Power Bar'] = true
L['This will enable/disable the |cfff960d9KlixUI|r powerbar modification.|r'] = true
L['Power Bar Backdrop'] = true
L['This will enable/disable the |cfff960d9KlixUI|r powerbar backdrop modification.|r'] = true
L["Auras"] = true
L["Aura Icon Spacing"] = true
L["Aura Spacing"] = true
L["Sets space between individual aura icons."] = true
L["Set Aura Spacing On Following Units"] = true
L["Player"] = true
L["Target"] = true
L["TargetTarget"] = true
L["TargetTargetTarget"] = true
L["Focus"] = true
L["FocusTarget"] = true
L["Pet"] = true
L["PetTarget"] = true
L["Arena"] = true
L["Boss"] = true
L["Party"] = true
L["Raid"] = true
L["Raid40"] = true
L["RaidPet"] = true
L["Tank"] = true
L["Assist"] = true
L["Aura Icon Text"] = true
L["Duration Text"] = true
L["Hide Text"] = true
L["Hide From Others"] = true
L["Will hide duration text on auras that are not cast by you."] = true
L["Threshold"] = true
L["Duration text will be hidden until it reaches this threshold (in seconds). Set to -1 to always show duration text."] = true
L["Position of the duration text on the aura icon."] = true
L["Bottom Left"] = true
L["Bottom Right"] = true
L["Top Left"] = true
L["Top Right"] = true
L["Stack Text"] = true
L["Will hide stack text on auras that are not cast by you."] = true
L["Position of the stack count on the aura icon."] = true
L['Textures'] = true
L['Health'] = true
L['Health statusbar texture. Applies only on Group Frames'] = true
L['Ignore Transparency'] = true
L['This will ignore ElvUI Health Transparency setting on all Group Frames.'] = true
L['Power'] = true
L['Power statusbar texture.'] = true
L['Castbar'] = true
L['This applies on all available castbars.'] = true
L['Castbar Text'] = true
L['Show InfoPanel text'] = true
L['Force show any text placed on the InfoPanel, while casting.'] = true
L['Show Castbar text'] = true
L['Show on Target'] = true
L['Y Offset'] = true
L['Adjust castbar text Y Offset'] = true
L["Text Color"] = true
L['Icons'] = true
L["LFG Icons"] = true
L["Choose what icon set there will be used on unitframes and in the chat."] = true
L["ReadyCheck Icons"] = true
L['|cfff960d9KlixUI|r Raid Icons'] = true
L['Replaces the default Raid Icons with the |cfff960d9KlixUI|r ones.\n|cffff8000Note: The Raid Icons Set can be changed in the |cfff960d9KlixUI|r |cffff8000Raid Markers option.|r'] = true
L["Debuffs Alert"] = true
L["Color the unit healthbar if there is a debuff from this filter"] = true
L["Default Color"] = true
L["Filters Page"] = true
L["Add Spell ID or Name"] = true
L["Add a spell to the filter. Use spell ID if you don't want to match all auras which share the same name."] = true
L["Remove Spell ID or Name"] = true
L["Remove a spell from the filter. Use the spell ID if you see the ID as part of the spell name in the filter."] = true
L["Select Spell"] = true
L["Reset Filter"] = true
L["This will reset the contents of this filter back to default. Any spell you have added to this filter will be removed.\n|cffff8000Note: Please reloadUI after resetting the filters.|r"] = true
L["special color"] = true
L["use special color"] = true

-- Media
L["KUI_MEDIA_ZONES"] = {
	"Washington",
	"Moscow",
	"Moon Base",
	"Goblin Spa Resort",
	"Illuminaty Headquaters",
	"Elv's Closet",
	"BlizzCon",
}
L["KUI_MEDIA_PVP"] = {
	"(Horde Territory)",
	"(Alliance Territory)",
	"(Contested Territory)",
	"(Russian Territory)",
	"(Aliens Territory)",
	"(Cats Territory)",
	"(Japanese Territory)",
	"(EA Territory)",
}
L["KUI_MEDIA_SUBZONES"] = {
	"Administration",
	"Hellhole",
	"Alley of Bullshit",
	"Dr. Pepper Storage",
	"Vodka Storage",
	"Last National Bank",
}
L["KUI_MEDIA_PVPARENA"] = {
	"(PvP)",
	"No Smoking!",
	"Only 5% Taxes",
	"Free For All",
	"Self destruction is in process",
}
L["Zone Text"] = true
L["Test"] = true
L["Subzone Text"] = true
L["PvP Status Text"] = true
L["Misc Texts"] = true
L["Mail Text"] = true
L["Chat Editbox Text"] = true
L["Gossip and Quest Frames Text"] = true
L["Objective Tracker Header Text"] = true
L["Objective Tracker Text"] = true
L["Banner Big Text"] = true
L["Set the font outline."] = true

-- Profiles

-- Staticpopup
L["MSG_KUI_ELV_OUTDATED"] = [[Your version of ElvUI is older than recommended to use with |cfff960d9KlixUI|r. Your version is |cff1784d1%.2f|r (recommended is |cff1784d1%.2f|r). Please update your ElvUI to avoid errors.]]