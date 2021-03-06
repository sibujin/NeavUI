
local _, ns = ...
local config = ns.Config

local oUF = ns.oUF or oUF

oUF.colors.power['MANA'] = {0, 0.55, 1}

local playerClass = select(2, UnitClass('player'))

    -- oUF_AuraWatch
    -- Class buffs { spell ID, position [, {r, g, b, a}][, anyUnit][, hideCount] }

local indicatorList
do
    indicatorList = {
        DRUID = {
            {774, 'BOTTOMRIGHT', {1, 0.2, 1}}, -- Rejuvenation
            {155777, 'RIGHT', {0.4, 0.9, 0.4}}, -- Rejuvenation (Germination)
            {33763, 'BOTTOM', {0.5, 1, 0.5}}, -- Lifebloom
            {48438, 'BOTTOMLEFT', {0.7, 1, 0}}, -- Wild Growth
        },
        MONK = {
            {119611, 'BOTTOMRIGHT', {0, 1, 0}}, -- Renewing Mist
            {124682, 'BOTTOMLEFT', {0.15, 0.98, 0.64}}, -- Enveloping Mist
            {116849, 'TOPLEFT', {1, 1, 0}}, -- Life Cocoon
            {115175, 'BOTTOMLEFT', {0.7, 0.8, 1}}, -- Soothing Mist
        },
        PALADIN = {
            {53563, 'BOTTOMRIGHT', {0, 1, 0}}, -- Beacon of Light
            {156910, 'BOTTOMRIGHT', {0, 1, 0}}, -- Beacon of Faith
            {200025, 'BOTTOMRIGHT', {0, 1, 0}}, -- Beacon of Virtue
        },
        PRIEST = {
            {17, 'BOTTOMRIGHT', {1, 1, 0}}, -- Power Word: Shield
            {41635, 'TOPRIGHT', {1, 0.6, 0.6}}, -- Prayer of Mending
            {139, 'BOTTOMLEFT', {0, 1, 0}}, -- Renew
            {194384, 'TOPLEFT', {1, 0, 0}}, -- Atonement
            {47788, 'TOPLEFT', {0, 1,0 }}, -- Guardian Spirit
        },
        SHAMAN = {
            {61295, 'TOPLEFT', {0.7, 0.3, 0.7}}, -- Riptide
            {204288, 'BOTTOMRIGHT', {0.7, 0.4, 0}}, -- Earth Shield (PvP Only)
        },
        WARLOCK = {
            {20707, 'BOTTOMRIGHT', {0.7, 0, 1}, true}, -- Soulstone
        },
        ALL = {
            {23333, 'TOPLEFT', {1, 0, 0}, true}, -- Warsong flag, Horde
            {23335, 'TOPLEFT', {0, 0, 1}, true}, -- Warsong flag, Alliance
            {34976, 'TOPLEFT', {1, 0, 1}, true}, -- Netherstorm Flag
        },
    }
end

--[[

    -- W    I   P

local inlist
do
    inlist = {
        DRUID = {
            [1] = {
                spellid = 774,  -- Rejuvenation
                pos = 'BOTTOMRIGHT',
                color = {1, 0.2, 1}, -- custom color, set to nil if the spellicon should be shown
                anyCaster = false,
                hideCD = false,
                hideCount = false,
                priority = 'HIGH', -- to overlap other icons on this position
            },

            [2] = {
                spellid = 33763,  -- Lifebloom
                pos = 'BOTTOM',
                color = {0.5, 1, 0.5},
                anyCaster = false,
                hideCD = false,
                hideCount = true,
            },

            [3] = {
                spellid = 48438,  -- Wild Growth
                pos = 'BOTTOMLEFT',
                color = {0.7, 1, 0},
                anyCaster = false,
                hideCD = false,
                hideCount = true,
            },
        }
    }

        MAGE = {
            {54648, 'BOTTOMRIGHT', {0.7, 0, 1}, true, true}, -- Focus Magic
        },
        PALADIN = {
            {53563, 'BOTTOMRIGHT', {0, 1, 0}}, -- Beacon of Light
        },
        PRIEST = {
            {6788, 'BOTTOMRIGHT', {0.6, 0, 0}, true}, -- Weakened Soul
            {17, 'BOTTOMRIGHT', {1, 1, 0}, true}, -- Power Word: Shield
            {33076, 'TOPRIGHT', {1, 0.6, 0.6}, true, true}, -- Prayer of Mending
            {139, 'BOTTOMLEFT', {0, 1, 0}}, -- Renew
        },
        SHAMAN = {
            {61295, 'TOPLEFT', {0.7, 0.3, 0.7}}, -- Riptide
            {16177, 'BOTTOMLEFT', {0.4, 0.7, 0.2}}, -- Ancestral Fortitude
            {974, 'BOTTOMRIGHT', {0.7, 0.4, 0}, false, true}, -- Earth Shield
        },
        WARLOCK = {
            {20707, 'BOTTOMRIGHT', {0.7, 0, 1}, true, true}, -- Soulstone
            {85767, 'BOTTOMLEFT', {0.7, 0.5, 1}, true, true, true}, -- Dark Intent
        },
        ALL = {
            {23333, 'TOPLEFT', {1, 0, 0}}, -- Warsong flag, Horde
            {23335, 'TOPLEFT', {0, 0, 1}}, -- Warsong flag, Alliance
        },
end
]]

local function AuraIcon(self, icon)
    if (icon.cd) then
        icon.cd:SetReverse(true)
        icon.cd:SetDrawEdge(true)
        icon.cd:SetAllPoints(icon.icon)
        icon.cd:SetHideCountdownNumbers(true)
    end
end

local offsets
do
    local space = 2

    offsets = {
        TOPLEFT = {
            icon = {space, -space},
            count = {'TOP', icon, 'BOTTOM', 0, 0},
        },

        TOPRIGHT = {
            icon = {-space, -space},
            count = {'TOP', icon, 'BOTTOM', 0, 0},
        },

        BOTTOMLEFT = {
            icon = {space, space},
            count = {'LEFT', icon, 'RIGHT', 1, 0},
        },

        BOTTOMRIGHT = {
            icon = {-space, space},
            count = {'RIGHT', icon, 'LEFT', -1, 0},
        },

        LEFT = {
            icon = {space, 0},
            count = {'LEFT', icon, 'RIGHT', 1, 0},
        },

        RIGHT = {
            icon = {-space, 0},
            count = {'RIGHT', icon, 'LEFT', -1, 0},
        },

        TOP = {
            icon = {0, -space},
            count = {'CENTER', icon, 0, 0},
        },

        BOTTOM = {
            icon = {0, space},
            count = {'CENTER', icon, 0, 0},
        },
    }
end

local function CreateIndicators(self, unit)

    self.AuraWatch = CreateFrame('Frame', nil, self)

    local Auras = {}
    Auras.icons = {}
    Auras.customIcons = true
    Auras.presentAlpha = 1
    Auras.missingAlpha = 0
    Auras.PostCreateIcon = AuraIcon

    local buffs = {}

    if (indicatorList['ALL']) then
        for key, value in pairs(indicatorList['ALL']) do
            tinsert(buffs, value)
        end
    end

    if (indicatorList[playerClass]) then
        for key, value in pairs(indicatorList[playerClass]) do
            tinsert(buffs, value)
        end
    end

    if (buffs) then
        for key, spell in pairs(buffs) do

            local icon = CreateFrame('Frame', nil, self.AuraWatch)
            icon:SetWidth(config.units.raid.indicatorSize)
            icon:SetHeight(config.units.raid.indicatorSize)
            icon:SetPoint(spell[2], self.Health, unpack(offsets[spell[2]].icon))

            icon.spellID = spell[1]
            icon.anyUnit = spell[4]
            icon.hideCount = spell[5]

            local cd = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
            cd:SetAllPoints(icon)
            icon.cd = cd

                -- Indicator

            local tex = icon:CreateTexture(nil, 'OVERLAY')
            tex:SetAllPoints(icon)
            tex:SetTexture('Interface\\AddOns\\oUF_NeavRaid\\media\\borderIndicator')
            icon.icon = tex

                -- Color Overlay

            if (spell[3]) then
                icon.icon:SetVertexColor(unpack(spell[3]))
            else
                icon.icon:SetVertexColor(0.8, 0.8, 0.8)
            end

            if (not icon.hideCount) then
                local count = icon:CreateFontString(nil, 'OVERLAY')
                count:SetShadowColor(0, 0, 0)
                count:SetShadowOffset(1, -1)
                count:SetPoint(unpack(offsets[spell[2]].count))
                count:SetFont('Interface\\AddOns\\oUF_NeavRaid\\media\\fontVisitor.ttf', 13)
                icon.count = count
            end

             Auras.icons[spell[1]] = icon
        end
    end
    self.AuraWatch = Auras
end

local function UpdateThreat(self, _, unit)
    if (self.unit ~= unit) then
        return
    end

    local threatStatus = UnitThreatSituation(unit) or 0
    if (threatStatus == 3) then
        if (self.ThreatText) then
            self.ThreatText:Show()
        end
    end

    if (threatStatus and threatStatus >= 2) then
        local r, g, b = GetThreatStatusColor(threatStatus)
        self.ThreatIndicator:SetBackdropBorderColor(r, g, b, 1)
    else
        self.ThreatIndicator:SetBackdropBorderColor(0, 0, 0, 0)

        if (self.ThreatText) then
            self.ThreatText:Hide()
        end
    end
end

local function UpdatePower(self, _, unit)
    if (self.unit ~= unit) then
        return
    end

    local _, powerToken = UnitPowerType(unit)

    if (powerToken == 'MANA' and UnitHasMana(unit)) then
        if (not self.Power:IsVisible()) then
            self.Health:ClearAllPoints()
            if (config.units.raid.manabar.horizontalOrientation) then
                self.Health:SetPoint('BOTTOMLEFT', self, 0, 3)
                self.Health:SetPoint('TOPRIGHT', self)
            else
                self.Health:SetPoint('BOTTOMLEFT', self)
                self.Health:SetPoint('TOPRIGHT', self, -3.5, 0)
            end

            self.Power:Show()
        end
    else
        if (self.Power:IsVisible()) then
            self.Health:ClearAllPoints()
            self.Health:SetAllPoints(self)
            self.Power:Hide()
        end
    end
end

local function DeficitValue(self)
    if (self >= 1000) then
        return format('-%.1f', self/1000)
    else
        return self
    end
end

local function GetUnitStatus(unit)
    if (UnitIsDead(unit)) then
        return DEAD
    elseif (UnitIsGhost(unit)) then
        return 'Ghost'
    elseif (not UnitIsConnected(unit)) then
        return PLAYER_OFFLINE
    else
        return ''
    end
end

local function GetHealthText(unit, cur, max)
    local healthString
    if (UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit)) then
        healthString = GetUnitStatus(unit)
    else
        if ((cur/max) < config.units.raid.deficitThreshold) then
            healthString = format('|cff%02x%02x%02x%s|r', 0.9*255, 0*255, 0*255, DeficitValue(max-cur))
        else
            healthString = ''
        end
    end

    return healthString
end

local function UpdateHealth(Health, unit, cur, max)
    if (not UnitIsPlayer(unit)) then
        local r, g, b = 0, 0.82, 1
        Health:SetStatusBarColor(r, g, b)
        Health.bg:SetVertexColor(r * 0.25, g * 0.25, b * 0.25)
    end

    Health.Value:SetText(GetHealthText(unit, cur, max))
end

local function CreateRaidLayout(self, unit)
    self:RegisterForClicks('AnyUp')

    self:SetScript('OnEnter', function(self)
        UnitFrame_OnEnter(self)

        if (self.Mouseover) then
            self.Mouseover:SetAlpha(0.175)
        end
    end)

    self:SetScript('OnLeave', function(self)
        UnitFrame_OnLeave(self)

        if (self.Mouseover) then
            self.Mouseover:SetAlpha(0)
        end
    end)

    self:SetBackdrop({
          bgFile = 'Interface\\Buttons\\WHITE8x8',
          insets = {
            left = -1.5,
            right = -1.5,
            top = -1.5,
            bottom = -1.5
        }
    })

    self:SetBackdropColor(0, 0, 0, 1)

        -- Health bar

    self.Health = CreateFrame('StatusBar', nil, self)
    self.Health:SetStatusBarTexture(config.media.statusbar, 'ARTWORK')
    self.Health:SetAllPoints(self)
    self.Health:SetOrientation(config.units.raid.horizontalHealthBars and 'HORIZONTAL' or 'VERTICAL')

    self.Health.PostUpdate = UpdateHealth
    self.Health.frequentUpdates = true

    self.Health.colorClass = true
    self.Health.colorDisconnected = true

    if (config.units.raid.smoothUpdates) then
        self.Health.Smooth = true
    end

        -- Health background

    self.Health.bg = self.Health:CreateTexture(nil, 'BORDER')
    self.Health.bg:SetAllPoints(self.Health)
    self.Health.bg:SetTexture(config.media.statusbar)

    self.Health.bg.multiplier = 0.3

        -- Health text

    self.Health.Value = self.Health:CreateFontString(nil, 'OVERLAY')
    self.Health.Value:SetPoint('TOP', self.Health, 'CENTER', 0, 2)
    self.Health.Value:SetFont(config.font.fontSmall, config.font.fontSmallSize)
    self.Health.Value:SetShadowOffset(1, -1)

        -- Name text

    self.Name = self.Health:CreateFontString(nil, 'OVERLAY')
    self.Name:SetPoint('BOTTOM', self.Health, 'CENTER', 0, 3)
    self.Name:SetFont(config.font.fontBig,config.font.fontBigSize)
    self.Name:SetShadowOffset(1, -1)
    self.Name:SetTextColor(1, 1, 1)
    self:Tag(self.Name, '[name:raid]')

        -- Power bar

    if (config.units.raid.manabar.show) then
        self.Power = CreateFrame('StatusBar', nil, self)
        self.Power:SetStatusBarTexture(config.media.statusbar, 'ARTWORK')

        if (config.units.raid.manabar.horizontalOrientation) then
            self.Power:SetPoint('TOPLEFT', self.Health, 'BOTTOMLEFT', 0, -1)
            self.Power:SetPoint('TOPRIGHT', self.Health, 'BOTTOMRIGHT', 0, -1)
            self.Power:SetOrientation('HORIZONTAL')
            self.Power:SetHeight(2.5)
        else
            self.Power:SetPoint('TOPLEFT', self.Health, 'TOPRIGHT', 1, 0)
            self.Power:SetPoint('BOTTOMLEFT', self.Health, 'BOTTOMRIGHT', 1, 0)
            self.Power:SetOrientation('VERTICAL')
            self.Power:SetWidth(2.5)
        end

        self.Power.colorPower = true
        self.Power.Smooth = true

        self.Power.bg = self.Power:CreateTexture(nil, 'BORDER')
        self.Power.bg:SetAllPoints(self.Power)
        self.Power.bg:SetColorTexture(1, 1, 1)

        self.Power.bg.multiplier = 0.3

        table.insert(self.__elements, UpdatePower)
        self:RegisterEvent('UNIT_DISPLAYPOWER', UpdatePower)
        UpdatePower(self, _, unit)
    end

        -- Heal prediction

    local myBar = CreateFrame('StatusBar', '$parentMyHealthPredictionBar', self)
    myBar:SetStatusBarTexture(config.media.statusbar, 'OVERLAY')
    myBar:SetStatusBarColor(0, 0.827, 0.765, 1)

    if (config.units.raid.smoothUpdates) then
        myBar.Smooth = true
    end

    if (config.units.raid.horizontalHealthBars) then
        myBar:SetOrientation('HORIZONTAL')
        myBar:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT')
        myBar:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT')
        myBar:SetWidth(self:GetWidth())
    else
        myBar:SetOrientation('VERTICAL')
        myBar:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'TOPLEFT')
        myBar:SetPoint('BOTTOMRIGHT', self.Health:GetStatusBarTexture(), 'TOPRIGHT')
        myBar:SetHeight(self:GetHeight())
    end

    local otherBar = CreateFrame('StatusBar', '$parentOtherHealthPredictionBar', self)
    otherBar:SetStatusBarTexture(config.media.statusbar, 'OVERLAY')
    otherBar:SetStatusBarColor(0.0, 0.631, 0.557, 1)

    if (config.units.raid.smoothUpdates) then
        otherBar.Smooth = true
    end

    if (config.units.raid.horizontalHealthBars) then
        otherBar:SetOrientation('HORIZONTAL')
        otherBar:SetPoint('TOPLEFT', myBar:GetStatusBarTexture(), 'TOPRIGHT')
        otherBar:SetPoint('BOTTOMLEFT', myBar:GetStatusBarTexture(), 'BOTTOMRIGHT')
        otherBar:SetWidth(self:GetWidth())
    else
        otherBar:SetOrientation('VERTICAL')
        otherBar:SetPoint('BOTTOMLEFT', myBar:GetStatusBarTexture(), 'TOPLEFT')
        otherBar:SetPoint('BOTTOMRIGHT', myBar:GetStatusBarTexture(), 'TOPRIGHT')
        otherBar:SetHeight(self:GetHeight())
    end

    local absorbBar = CreateFrame('StatusBar', '$parentTotalAbsorbBar', self)
    absorbBar:SetStatusBarTexture('Interface\\Buttons\\WHITE8x8')
    absorbBar:SetStatusBarColor(0.85, 0.85, 0.9, 1)

    if (config.units.raid.smoothUpdates) then
        absorbBar.Smooth = true
    end

    if (config.units.raid.horizontalHealthBars) then
        absorbBar:SetOrientation('HORIZONTAL')
        absorbBar:SetPoint('TOPLEFT', otherBar:GetStatusBarTexture(), 'TOPRIGHT')
        absorbBar:SetPoint('BOTTOMLEFT', otherBar:GetStatusBarTexture(), 'BOTTOMRIGHT')
        absorbBar:SetWidth(self:GetWidth())
    else
        absorbBar:SetOrientation('VERTICAL')
        absorbBar:SetPoint('BOTTOMLEFT', otherBar:GetStatusBarTexture(), 'TOPLEFT')
        absorbBar:SetPoint('BOTTOMRIGHT', otherBar:GetStatusBarTexture(), 'TOPRIGHT')
        absorbBar:SetHeight(self:GetHeight())
    end

    absorbBar.Overlay = absorbBar:CreateTexture('$parentOverlay', 'OVERLAY', 'TotalAbsorbBarOverlayTemplate', 1)
    absorbBar.Overlay:SetAllPoints(absorbBar:GetStatusBarTexture())

    local healAbsorbBar = CreateFrame('StatusBar', '$parentHealAbsorbBar', self)
    healAbsorbBar:SetStatusBarTexture('Interface\\Buttons\\WHITE8x8')
    healAbsorbBar:SetStatusBarColor(0.9, 0.1, 0.3, 1)
    healAbsorbBar:SetReverseFill(true)

    if (config.units.raid.smoothUpdates) then
        healAbsorbBar.Smooth = true
    end

    if (config.units.raid.horizontalHealthBars) then
        healAbsorbBar:SetOrientation('HORIZONTAL')
        healAbsorbBar:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT')
        healAbsorbBar:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT')
        healAbsorbBar:SetWidth(self.Health:GetWidth())
    else
        healAbsorbBar:SetOrientation('VERTICAL')
        healAbsorbBar:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'TOPLEFT')
        healAbsorbBar:SetPoint('BOTTOMRIGHT', self.Health:GetStatusBarTexture(), 'TOPRIGHT')
        healAbsorbBar:SetHeight(self.Health:GetHeight())
    end

    local overAbsorb = self.Health:CreateTexture(nil, 'OVERLAY')

    if (config.units.raid.horizontalHealthBars) then
        overAbsorb:SetPoint('TOPLEFT', self.Health, 'TOPRIGHT')
        overAbsorb:SetPoint('BOTTOMLEFT', self.Health, 'BOTTOMRIGHT')
        overAbsorb:SetWidth(3)
    else
        overAbsorb:SetPoint('BOTTOMLEFT', self.Health, 'TOPLEFT')
        overAbsorb:SetPoint('BOTTOMRIGHT', self.Health, 'TOPRIGHT')
        overAbsorb:SetHeight(3)
    end

    local overHealAbsorb = self.Health:CreateTexture(nil, 'OVERLAY')

    if (config.units.raid.horizontalHealthBars) then
        overHealAbsorb:SetPoint('TOPLEFT', self.Health, 'TOPRIGHT')
        overHealAbsorb:SetPoint('BOTTOMLEFT', self.Health, 'BOTTOMRIGHT')
        overHealAbsorb:SetWidth(3)
    else
        overHealAbsorb:SetPoint('BOTTOMLEFT', self.Health, 'TOPLEFT')
        overHealAbsorb:SetPoint('BOTTOMRIGHT', self.Health, 'TOPRIGHT')
        overHealAbsorb:SetHeight(3)
    end

    self.HealthPrediction = {
        myBar = myBar,
        otherBar = otherBar,
        healAbsorbBar = healAbsorbBar,
        absorbBar = absorbBar,
        overAbsorb = overAbsorb,
        overHealAbsorb = overHealAbsorb,
        maxOverflow = 1.05,
        frequentUpdates = true
    }

        -- Afk /offline timer, using frequentUpdates function from oUF tags

    if (config.units.raid.showNotHereTimer) then
        self.NotHere = self.Health:CreateFontString(nil, 'OVERLAY')
        self.NotHere:SetPoint('CENTER', self, 'BOTTOM')
        -- self.NotHere:SetFont(config.font.fontSmall, 11)
        self.NotHere:SetFont(config.font.fontSmall, 11, 'THINOUTLINE')
        self.NotHere:SetShadowOffset(0, 0)
        self.NotHere:SetTextColor(0, 1, 0)
        self.NotHere.frequentUpdates = 1
        self:Tag(self.NotHere, '[status:raid]')
    end

        -- Mouseover darklight

    if (config.units.raid.showMouseoverHighlight) then
        self.Mouseover = self.Health:CreateTexture(nil, 'OVERLAY')
        self.Mouseover:SetAllPoints(self.Health)
        self.Mouseover:SetTexture(config.media.statusbar)
        self.Mouseover:SetVertexColor(0, 0, 0)
        self.Mouseover:SetAlpha(0)
    end

        -- Threat glow

    self.ThreatIndicator = CreateFrame('Frame', nil, self)
    self.ThreatIndicator:SetPoint('TOPLEFT', self, 'TOPLEFT', -4, 4)
    self.ThreatIndicator:SetPoint('BOTTOMRIGHT', self, 'BOTTOMRIGHT', 4, -4)
    self.ThreatIndicator:SetBackdrop({edgeFile = 'Interface\\AddOns\\oUF_NeavRaid\\media\\textureGlow', edgeSize = 3})
    self.ThreatIndicator:SetBackdropBorderColor(0, 0, 0, 0)
    self.ThreatIndicator:SetFrameLevel(self:GetFrameLevel() - 1)

        -- Threat text

    if (config.units.raid.showThreatText) then
        self.ThreatText = self.Health:CreateFontString(nil, 'OVERLAY')
        self.ThreatText:SetPoint('CENTER', self, 'BOTTOM')
        self.ThreatText:SetFont(config.font.fontSmall, 11, 'THINOUTLINE')
        self.ThreatText:SetShadowOffset(0, 0)
        self.ThreatText:SetTextColor(1, 0, 0)
        self.ThreatText:SetText('AGGRO')
    end

    table.insert(self.__elements, UpdateThreat)
    self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', UpdateThreat)
    self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', UpdateThreat)

        -- Masterlooter icons

    self.MasterLooterIndicator = self.Health:CreateTexture(nil, 'OVERLAY', self)
    self.MasterLooterIndicator:SetSize(11, 11)
    self.MasterLooterIndicator:SetPoint('RIGHT', self, 'TOPRIGHT', -1, 1)

        -- Leader icons

    self.LeaderIndicator = self.Health:CreateTexture(nil, 'OVERLAY', self)
    self.LeaderIndicator:SetSize(12, 12)
    self.LeaderIndicator:SetPoint('LEFT', self.Health, 'TOPLEFT', 1, 2)

        -- Raid target indicator

    self.RaidTargetIndicator = self.Health:CreateTexture(nil, 'OVERLAY')
    self.RaidTargetIndicator:SetSize(16, 16)
    self.RaidTargetIndicator:SetPoint('CENTER', self, 'TOP')

        -- Readycheck icons

    self.ReadyCheckIndicator = self.Health:CreateTexture(nil, 'OVERLAY')
    self.ReadyCheckIndicator:SetPoint('CENTER')
    self.ReadyCheckIndicator:SetSize(20, 20)
    self.ReadyCheckIndicator.delayTime = 2
    self.ReadyCheckIndicator.fadeTime = 1

        -- Debuff icons, using freebAuras from oUF_Freebgrid

    self.FreebAuras = CreateFrame('Frame', nil, self)
    self.FreebAuras:SetSize(config.units.raid.iconSize, config.units.raid.iconSize)
    self.FreebAuras:SetPoint('CENTER', self.Health)

        -- Create indicators

    CreateIndicators(self, unit)

        -- Role indicator

    if (config.units.raid.showRolePrefix) then
        self.LFDRoleText = self.Health:CreateFontString(nil, 'ARTWORK')
        self.LFDRoleText:SetPoint('TOPLEFT', self.Health, 0, 4)
        self.LFDRoleText:SetFont(config.font.fontSmall, 15)
        self.LFDRoleText:SetShadowOffset(0.5, -0.5)
        self.LFDRoleText:SetTextColor(1, 0, 1)
        self:Tag(self.LFDRoleText, '[role:raid]')
    end

        -- Resurrect indicator

    if (config.units.raid.showResurrectText) then
        self.ResurrectIndicator = self.Health:CreateFontString(nil, 'OVERLAY')
        self.ResurrectIndicator:SetPoint('CENTER', self, 'BOTTOM', 0, 1)
        self.ResurrectIndicator:SetFont(config.font.fontSmall, 11, 'THINOUTLINE')
        self.ResurrectIndicator:SetShadowOffset(0, 0)
        self.ResurrectIndicator:SetTextColor(0.1, 1, 0.1)
        self.ResurrectIndicator:SetText('RES') -- RESURRECT

        self.ResurrectIndicator.Override = function()
            local incomingResurrect = UnitHasIncomingResurrection(self.unit)

            if (incomingResurrect) then
                self.ResurrectIndicator:Show()

                if (self.NotHere) then
                    self.NotHere:Hide()
                end
            else
                self.ResurrectIndicator:Hide()

                if (self.NotHere) then
                    self.NotHere:Show()
                end
            end
        end
    end

        -- Playertarget border

    if (config.units.raid.showTargetBorder) then
        self.TargetBorder = self.Health:CreateTexture(nil, 'OVERLAY', self)
        self.TargetBorder:SetAllPoints(self.Health)
        self.TargetBorder:SetTexture('Interface\\Addons\\oUF_NeavRaid\\media\\borderTarget')
        self.TargetBorder:SetVertexColor(unpack(config.units.raid.targetBorderColor))
        self.TargetBorder:Hide()

        self:RegisterEvent('PLAYER_TARGET_CHANGED', function()
            if (UnitIsUnit('target', self.unit)) then
                self.TargetBorder:Show()
            else
                self.TargetBorder:Hide()
            end
        end)
    end

        -- Range check

    self.Range = {
        insideAlpha = 1,
        outsideAlpha = 0.3,
    }

    self.SpellRange = {
        insideAlpha = 1,
        outsideAlpha = 0.3,
    }

    return self
end

local raidFrames = CreateFrame('Frame', 'oUF_Neav_Raid_Anchor', UIParent)
raidFrames:SetSize(80, 80)
raidFrames:SetPoint('CENTER')
raidFrames:SetFrameStrata('HIGH')
raidFrames:SetMovable(true)
raidFrames:SetClampedToScreen(true)
raidFrames:SetUserPlaced(true)
raidFrames:SetBackdrop({bgFile = 'Interface\\Buttons\\WHITE8x8'})
raidFrames:SetBackdropColor(0, 1, 0, 0.55)
raidFrames:EnableMouse(true)
raidFrames:RegisterForDrag('LeftButton')
raidFrames:Hide()

raidFrames.text = raidFrames:CreateFontString(nil, 'OVERLAY')
raidFrames.text:SetAllPoints(raidFrames)
raidFrames.text:SetFont('Fonts\\ARIALN.ttf', 13)
raidFrames.text:SetText('oUF_Neav Raid_Anchor "'..config.units.raid.layout.initialAnchor..'"')

raidFrames:SetScript('OnDragStart', function(self)
    self:StartMoving()
end)

raidFrames:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
end)

local tankFrames = CreateFrame('Frame', 'oUF_Neav_Assist_Anchor', UIParent)
tankFrames:SetSize(80, 80)
tankFrames:SetPoint('CENTER')
tankFrames:SetFrameStrata('HIGH')
tankFrames:SetMovable(true)
tankFrames:SetClampedToScreen(true)
tankFrames:SetUserPlaced(true)
tankFrames:SetBackdrop({bgFile = 'Interface\\Buttons\\WHITE8x8'})
tankFrames:SetBackdropColor(0, 1, 0, 0.55)
tankFrames:EnableMouse(true)
tankFrames:RegisterForDrag('LeftButton')
tankFrames:Hide()

tankFrames.text = tankFrames:CreateFontString(nil, 'OVERLAY')
tankFrames.text:SetAllPoints(tankFrames)
tankFrames.text:SetFont('Fonts\\ARIALN.ttf', 13)
tankFrames.text:SetText('oUF_Neav Assit_Anchor')

tankFrames:SetScript('OnDragStart', function(self)
    self:StartMoving()
end)

tankFrames:SetScript('OnDragStop', function(self)
    self:StopMovingOrSizing()
end)

SlashCmdList['oUF_Neav_Raid_AnchorToggle'] = function()
    if (InCombatLockdown()) then
        raidFrames:Hide()
        tankFrames:Hide()
        print('oUF_NeavRaid: You cant do this in combat!')
        return
    end

    if (not raidFrames:IsShown()) then
        raidFrames:Show()
        tankFrames:Show()
    else
        raidFrames:Hide()
        tankFrames:Hide()
    end
end
SLASH_oUF_Neav_Raid_AnchorToggle1 = '/neavrt'

oUF:RegisterStyle('oUF_Neav_Raid', CreateRaidLayout)
oUF:RegisterStyle('oUF_Neav_Raid_MT', CreateRaidLayout)
oUF:Factory(function(self)
    self:SetActiveStyle('oUF_Neav_Raid')

    local rlayout = config.units.raid.layout
    local relpoint, anchpoint, xOffset, yOffset

    if (rlayout.orientation == 'HORIZONTAL') then
        if (rlayout.initialAnchor == 'TOPRIGHT' or rlayout.initialAnchor == 'TOPLEFT') then
            relpoint = 'LEFT'
            anchpoint = 'TOP'
            xOffset = rlayout.frameSpacing
            yOffset = rlayout.frameSpacing
        elseif (rlayout.initialAnchor == 'BOTTOMLEFT' or rlayout.initialAnchor == 'BOTTOMRIGHT') then
            relpoint = 'BOTTOM'
            anchpoint = 'LEFT'
            xOffset = -rlayout.frameSpacing
            yOffset = rlayout.frameSpacing
        end
    elseif (rlayout.orientation == 'VERTICAL') then
        if (rlayout.initialAnchor == 'TOPRIGHT') then
            relpoint = 'TOP'
            anchpoint = 'RIGHT'
            xOffset = -rlayout.frameSpacing
            yOffset = -rlayout.frameSpacing
        elseif (rlayout.initialAnchor == 'TOPLEFT') then
            relpoint = 'TOP'
            anchpoint = 'LEFT'
            xOffset = rlayout.frameSpacing
            yOffset = -rlayout.frameSpacing
        elseif (rlayout.initialAnchor == 'BOTTOMLEFT') then
            relpoint = 'BOTTOM'
            anchpoint = 'LEFT'
            xOffset = rlayout.frameSpacing
            yOffset = rlayout.frameSpacing
        elseif (rlayout.initialAnchor == 'BOTTOMRIGHT') then
            relpoint = 'BOTTOM'
            anchpoint = 'RIGHT'
            xOffset = -rlayout.frameSpacing
            yOffset = rlayout.frameSpacing
        end
    end

    local raid = self:SpawnHeader('oUF_Raid', nil, 'raid,party,solo',
        'showSolo', config.units.raid.showSolo,
        'showParty', config.units.raid.showParty,
        'showRaid', true,
        'showPlayer', true,
        'point', relpoint,
        'groupFilter', '1,2,3,4,5,6,7,8',
        'groupingOrder', '1,2,3,4,5,6,7,8',
        'groupBy', 'GROUP',
        'maxColumns', 8,
        'unitsPerColumn', 5,
        'columnAnchorPoint', anchpoint,
        'columnSpacing', rlayout.frameSpacing,
        'yOffset', yOffset,
        'xOffset', xOffset,
        'templateType', 'Button',
        'oUF-initialConfigFunction', ([[
            self:SetWidth(%d)
            self:SetHeight(%d)
        ]]):format(config.units.raid.width, config.units.raid.height))

    raid:SetPoint(rlayout.initialAnchor, raidFrames)
    raid:SetScale(config.units.raid.scale)
    raid:SetFrameStrata('LOW')

        -- Main Tank/Assist Frames

    if config.units.raid.showMainTankFrames then
        self:SetActiveStyle('oUF_Neav_Raid_MT')

        local offset = rlayout.frameSpacing

        local tanks = self:SpawnHeader('oUF_Neav_Raid_MT', nil, 'solo,party,raid',
            'showRaid', true,
            'showParty', false,
            'yOffset', -offset,
            'template', 'oUF_NeavRaid_MT_Target_Template',     -- Target
            'sortMethod', 'INDEX',
            'groupFilter', 'MAINTANK,MAINASSIST',
            'oUF-initialConfigFunction', ([[
                self:SetWidth(%d)
                self:SetHeight(%d)
            ]]):format(config.units.raid.width, config.units.raid.height))

        tanks:SetPoint('TOPLEFT', tankFrames, 'TOPLEFT')
        tanks:SetScale(config.units.raid.scale)
        tanks:SetFrameStrata('LOW')
    end
end)
