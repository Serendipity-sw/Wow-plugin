local KUI, E, L, V, P, G = unpack(select(2, ...))
local KDB = KUI:GetModule("KuiDatabars")
local EDB = E:GetModule("DataBars")

local function UpdateAzerite(self)
    local bar = self.azeriteBar
    local color = E.db.KlixUI.databars.azeriteBar.color
    bar.statusBar:SetStatusBarColor(color.r, color.g, color.b)

    local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()

    if E.db.KlixUI.databars.azeriteBar.progress and azeriteItemLocation then
        local xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
        local currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)

        local avg = xp / totalLevelXP
        avg = KDB:Round(avg, 2)
        bar.statusBar:SetAlpha(avg)
    else
        bar.statusBar:SetAlpha(0.8)
    end
end

function KDB:HookAzeriteBar()
    if E.db.KlixUI.databars.enable and EDB.azeriteBar then
        if not KDB:IsHooked(EDB, "UpdateAzerite") then
            KDB:SecureHook(EDB, "UpdateAzerite", UpdateAzerite)
        end
    elseif not E.db.KlixUI.databars.enable or not EDB.azeriteBar then
        if KDB:IsHooked(EDB, "UpdateAzerite") then
            KDB:Unhook(EDB, "UpdateAzerite")
        end
        KDB:RestoreAzeriteBar()
    end
    EDB:UpdateAzerite()
end

function KDB:RestoreAzeriteBar()
    local bar = EDB.azeriteBar
    if bar then
        bar.statusBar:SetStatusBarColor(.901, .8, .601, 0.8)
    end
end
