local KUI, E, L, V, P, G = unpack(select(2, ...))
local CA = KUI:NewModule("CorruptedAshbringer", 'AceEvent-3.0');

local ashbringerSounds = {
    {
        ["file"] = "Sound\\Creature\\Ashbringer\\ASH_SPEAK_01.ogg",
        ["text"] = "I was pure once.",
    },
    {
        ["file"] = "Sound\\Creature\\Ashbringer\\ASH_SPEAK_02.ogg",
        ["text"] = "Fought for righteousness.",
    },
    {
        ["file"] = "Sound\\Creature\\Ashbringer\\ASH_SPEAK_03.ogg",
        ["text"] = "I was called Ashbringer.",
    },
    {
        ["file"] = "Sound\\Creature\\Ashbringer\\ASH_SPEAK_04.ogg",
        ["text"] = "Betrayed by my order.",
    },
    {
        ["file"] = "Sound\\Creature\\Ashbringer\\ASH_SPEAK_05.ogg",
        ["text"] = "Destroyed by Kel'Thuzad.",
    },
    {
        ["file"] = "Sound\\Creature\\Ashbringer\\ASH_SPEAK_06.ogg",
        ["text"] = "Suffer pain to serve.",
    },
    {
        ["file"] = "Sound\\Creature\\Ashbringer\\ASH_SPEAK_07.ogg",
        ["text"] = "My son watched me die.",
    },
    {
        ["file"] = "Sound\\Creature\\Ashbringer\\ASH_SPEAK_08.ogg",
        ["text"] = "Crusades fed his rage.",
    },
    {
        ["file"] = "Sound\\Creature\\Ashbringer\\ASH_SPEAK_09.ogg",
        ["text"] = "Truth is unknown to him.",
    },
    {
        ["file"] = "Sound\\Creature\\Ashbringer\\ASH_SPEAK_10.ogg",
        ["text"] = "Scarlet Crusade is pure no longer.",
    },
    {
        ["file"] = "Sound\\Creature\\Ashbringer\\ASH_SPEAK_11.ogg",
        ["text"] = "Balnazzar's crusade corrupted my son.",
    },
    {
        ["file"] = "Sound\\Creature\\Ashbringer\\ASH_SPEAK_12.ogg",
        ["text"] = "Kill them all!",
    },
};

local function incrementSound()
    E.db.KlixUI.misc.CA.nextSound = E.db.KlixUI.misc.CA.nextSound + 1;
    if (E.db.KlixUI.misc.CA.nextSound > 12) then
        E.db.KlixUI.misc.CA.nextSound = 1;
    end
end

function CA:PlayNextSound()
    local ShouldPlaySound = math.random(100 / E.db.KlixUI.misc.CA.soundProbabilityPercent);
    local nextSound = E.db.KlixUI.misc.CA.nextSound;
    
    if (ShouldPlaySound == 1) then
        PlaySoundFile(ashbringerSounds[nextSound].file);

        if (E.db.KlixUI.misc.CA.enable) then
            print("|cFFF8B0DEAn Unknown Voice whispers:", ashbringerSounds[nextSound].text);
        end

        incrementSound();
    end
end

function CA:PLAYER_REGEN_DISABLED()
	CA:PlayNextSound()
end

function CA:Initialize()
	if not E.db.KlixUI.misc.CA.enable or not KUI:IsDeveloper() then return end
	
	CA:RegisterEvent("PLAYER_REGEN_DISABLED");
end

KUI:RegisterModule(CA:GetName())