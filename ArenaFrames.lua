-- Reposition arena accessories and hide casting bar to clean up arena frames

local ACCESSORY_SIZE = 40
local DIMINISH_ICON_SIZE = 26

-- Reposition and resize all accessories on a member frame to override default Blizzard layout
local function AdjustMemberAccessories(memberFrame)
    -- Hide casting bar to reduce visual clutter because cast info is available on nameplates
    if memberFrame.CastingBarFrame then
        memberFrame.CastingBarFrame:SetAlpha(0)
        memberFrame.CastingBarFrame:Hide()
    end

    -- Anchor CC remover to right of frame because default top-right position overlaps health text
    if memberFrame.CcRemoverFrame then
        memberFrame.CcRemoverFrame:SetSize(ACCESSORY_SIZE, ACCESSORY_SIZE)
        memberFrame.CcRemoverFrame:ClearAllPoints()
        memberFrame.CcRemoverFrame:SetPoint("LEFT", memberFrame, "RIGHT", 2, 0)
    end

    -- Anchor debuff to left of frame because default position overlaps casting bar and diminish tray
    if memberFrame.DebuffFrame then
        memberFrame.DebuffFrame:SetSize(ACCESSORY_SIZE, ACCESSORY_SIZE)
        memberFrame.DebuffFrame:ClearAllPoints()
        memberFrame.DebuffFrame:SetPoint("RIGHT", memberFrame, "LEFT", -2, 0)
    end

    -- Scale diminish tray to match accessory height because SetSize on pooled children fights ResizeLayoutFrame
    local diminishTray = memberFrame.SpellDiminishStatusTray
    if diminishTray then
        diminishTray:ClearAllPoints()
        diminishTray:SetPoint("RIGHT", memberFrame.DebuffFrame, "LEFT", -2, 0)
        diminishTray:SetScale(ACCESSORY_SIZE / DIMINISH_ICON_SIZE)
    end
end

-- Hook CompactArenaFrame layout and diminish trays to reapply adjustments after Blizzard updates
local function SetupArenaFrameHooks()
    local arenaFrame = CompactArenaFrame
    if not arenaFrame or arenaFrame._cleanArenaHooked then return end
    arenaFrame._cleanArenaHooked = true

    -- Hook UpdateLayout to reapply accessory positions after Blizzard recalculates its layout
    hooksecurefunc(arenaFrame, "UpdateLayout", function(self)
        for _, memberFrame in ipairs(self.memberUnitFrames) do
            AdjustMemberAccessories(memberFrame)
        end
    end)

    -- Apply initial adjustments to catch frames that already exist at hook time
    for _, memberFrame in ipairs(arenaFrame.memberUnitFrames) do
        AdjustMemberAccessories(memberFrame)
    end
end

-- Apply arena hooks immediately to catch frames already created at load time
SetupArenaFrameHooks()

-- Hook frame generation to apply hooks on new frames because arena frames are created lazily on demand
if CompactArenaFrame_Generate then
    hooksecurefunc("CompactArenaFrame_Generate", SetupArenaFrameHooks)
end

-- Enable diminish tracking CVars on entering world because they must be set per session
local diminishCvarFrame = CreateFrame("Frame")
diminishCvarFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
diminishCvarFrame:SetScript("OnEvent", function()
    SetCVar("spellDiminishPVPEnemiesEnabled", "1")
    SetCVar("spellDiminishPVPOnlyTriggerableByMe", "1")
end)
