-- Fantasia Ruby Main Script
for _, part in ipairs({"PLAYER", "ARMOR", "HELMET_ITEM", "CAPE", "ELYTRA"}) do
    vanilla_model[part]:setVisible(false)
end

config:setName("Fantasia Ruby")
local customSwordConfig = config:load("customSwordConfig") or false
local customShieldConfig = config:load("customShieldConfig") or false
local clothesConfig = config:load("clothesConfig") or false
local firstPersonConfig = config:load("firstPersonConfig") or false
local eyeLookConfig = config:load("eyeLookConfig") or false

local smoothie = require("scripts.Smoothie")
local anims = require("scripts.EZAnims")
local Looksy = require("scripts.Looksy")
local Animazer = require("scripts.Animazer")
local TailFX = require("scripts.TailFX")

charAnim = animations["models.ruby"]
itemAnim = animations["models.items"]

-- Localize model parts to reduce indexing instructions
local root = models.models.ruby.root
local hips = root.Hips
local body = root.Body
local neck = body.Neck
local head = neck.Head
local lArm, rArm = body.LeftArm, body.RightArm
local lFore, rFore = lArm.LeftForearm, rArm.RightForearm
local lLeg, rLeg = root.LeftLeg, root.RightLeg
local fpArms = root.FPArms
local itemModels = models.models.items
local rPivotClothed = rFore.RightForearmClothed.RightHand.RightItemPivot
local rPivotBare = rFore.RightForearmBare.RightHandBare.RightItemPivotBare
local lPivotClothed = lFore.LeftForearmClothed.LeftHand.LeftItemPivot
local lPivotBare = lFore.LeftForearmBare.LeftHandBare.LeftItemPivotBare
local rVanillaShield, lVanillaShield = rFore.RightVanillaShield, lFore.LeftVanillaShield
local shieldR, shieldL = rFore.ShieldR, lFore.ShieldL
local itemMouth, jaw, glider = head.ItemMouthTarget, head.Jaw, body.Glider
local bareHips = hips.BareHips
local JUMP_ANIMS = {"jumpfull", "jumpfull_sword", "jumpfull_tool", "crouchjumpfull"}
local LANDING_STOP_ANIMS = {
    "jumpfull", "jumpfull_sword", "jumpfull_tool", "crouchjumpfull",
    "jumpup", "jumpdown", "walkjumpup", "walkjumpdown",
    "sprintjumpup", "sprintjumpdown", "crouchjumpup", "crouchjumpdown", "fall"
}

-- Animation blend settings
anims:setOneJump(true)
anims:setFallVel(-1.5)
local animModel = anims:addBBModel(charAnim)
Animazer:init(animModel, charAnim)

-- Register jump animations as overriders to suppress EZAnims walk/sprint cycles
animModel:addExcluOverrider(charAnim.jumpfull, charAnim.jumpfull_sword, charAnim.jumpfull_tool, charAnim.crouchjumpfull)

-- Consolidated Animation Setup (Use strings to defer indexing and reduce instructions)
local animSetup = {
    -- {name, blendIn, blendOut, priority}
    {"idle", 2, 2},
    {"idle_sword", 2, 2},
    {"idle_tool", 2, 2},
    {"walk"},
    {"walk_sword", 2, 2},
    {"walk_tool", 2, 2},
    {"walkback", 1, 1},
    {"sprint", 2, 2},
    {"sprint_sword", 2, 2},
    {"sprint_tool", 2, 2},
    {"crouch", 2, 2},
    {"crouch_sword", 2, 2},
    {"crouch_tool", 2, 2},
    {"crouchwalk", 2, 2},
    {"crouchwalkback", 2, 2},
    {"fall", 1, 1, 4},
    {"FP_No_Bob", 4, 3},
    {"water", 1, 1},
    {"waterwalk", 4, 3},
    {"waterwalkback", 4, 3},
    {"waterup", 4, 3},
    {"swim", 4, 4},
    {"waterwalk_sword", 4, 3},
    {"waterup_sword", 4, 3},
    {"swim_sword", 4, 4},
    {"attackR", 0, 0, 2},
    {"attackR_fly", 0, 0, 6},
    {"attackR_crouchwalk", 0, 0, 2},
    {"mineR", 0, 0, 2},
    {"elytra", 4, 4},
    {"fly", 3, 3},
    {"watercrouch", 1, 1},
    {"blockR", 2, 2, 2},
    {"blockL", 2, 2, 2},
    {"crouch_toolblockL", 2, 2, 2},
    {"blockL_crouchwalk", 1, 1, 2},
    {"spearR", 9, 1, 2},
    {"sleep", 1, 1, 6},
    {"crossR", 2, 2},
    {"loadR", 4, 4},
    {"jumpfull", 1, 1, 3},
    {"jumpfull_sword", 1, 1, 3},
    {"jumpfull_tool", 1, 1, 3},
    {"crouchjumpfull", 1, 1, 2}
}

for _, cfg in ipairs(animSetup) do
    local a = charAnim[cfg[1]]
    if a then
        if cfg[2] then a:setBlendTime(cfg[2], cfg[3]) end
        if cfg[4] then a:setPriority(cfg[4]) end
        if a.setOverride then a:setOverride(true) end
    end
end
Looksy:setEyeAnims(charAnim.look_horizontal, charAnim.look_vertical)

-- Programmatic Overrides for variants that don't need unique blends
for _, name in ipairs({"jumpup", "jumpdown", "walkjumpup", "walkjumpdown", "sprintjumpup", "sprintjumpdown", "crouchjumpup", "crouchjumpdown", "sit", "elytradown", "bowR"}) do
    for _, suffix in ipairs({"", "_sword", "_tool"}) do
        local a = charAnim[name .. suffix]
        if a and a.setOverride then a:setOverride(true) end
    end
end

-- Default Initial Override (Tridents use the Sword attack animation by default)
Animazer:setSlotOverride("trident", "attackR")

-- TailFX Setup
TailFX:init(hips.Tail, hips.Tail.Tail2)

-- Jumpsy Configuration
local jumpVelocityRange = 0.15
Animazer.jumpsy:setRange(-jumpVelocityRange, jumpVelocityRange)
Animazer.jumpsy:setSmoothness(1)

-- State variables
local isFlying, shieldRightOn, shieldLeftOn = false, false, false
local currentSmoothieState = ""
local useKeyHeldDown, forwardKeyHeldDown = false, false
local leftKeyHeldDown, rightKeyHeldDown, backKeyHeldDown = false, false, false
local shieldActivationTimer, isCrawling = 0, false
local prevOnGround = true
local crouchOffset, crouchTargetTransition, crouchTargetOffset = 0.0, 0.8, 0.0

local smoothHead = smoothie:newSmoothHead(head)
local smoothNeck = smoothie:newSmoothHead(neck)
local smoothBody = smoothie:newSmoothHead(body)
local smoothCrossbowAim = smoothie:newSmoothHead(rArm)
local smoothieParts = {head = smoothHead, neck = smoothNeck, body = smoothBody}

for _, part in ipairs({smoothHead, smoothNeck, smoothBody, smoothCrossbowAim}) do
    part:setSpeed(1)
    part:setKeepVanillaPosition(false)
end

local function applySmoothiePreset(obj, values, mult)
    obj:setHorizontalStrength(values[1] * mult)
    obj:setVerticalStrength(values[2] * mult)
    obj:setTiltMultiplier(values[3] * mult)
end

-- Preset Constants (smoothie states)
local SMOOTHIE_PRESETS = {
    default = {
        head = {0.2, 0.2, -1}, -- {strength, tiltMultiplier}
        neck = {0.2, 0.2, -1},
        body = {0.4, 0.2, 0}
    },
    walkForward = {
        head = {0.3, 0.2, 1}, -- {strength, tiltMultiplier}
        neck = {0.3, 0.2, 1},
        body = {0.2, 0.2, 1}
    },
    walk = {
        head = {0.2, 0.1, 0}, -- {strength, tiltMultiplier}
        neck = {0.1, 0.1, 0},
        body = {0.1, 0.1, 0}
    },
    runForward = { --fix to only work when holding forward
        head = {0.3, 0.2, 3}, -- {strength, tiltMultiplier}
        neck = {0.3, 0.2, 1},
        body = {0.2, 0.2, 4}
    },
    run = { --fix to only work when holding forward
        head = {0.2, 0.1, 0}, -- {strength, tiltMultiplier}
        neck = {0.1, 0.1, 0},
        body = {0.1, 0.1, 0}
    },
    crouch = {
        head = {0.4, 0.2, 3},
        neck = {0.3, 0.2, 3},
        body = {0.2, 0.0, 1}
    },
    flying = { -- Creative Flight
        head = {0.5, 0.3, 3},
        neck = {0.5, 0.1, 1},
        body = {0.2, 0.2, 0}
    },
    elytra = { -- Fall Flying
        head = {0.5, 0.1, 1},
        neck = {0.5, 0.1, 1},
        body = {0.4, 0.2, 5}
    },
    crouchWalk = { -- Fall Flying
        head = {0.2, 0.4, 2},
        neck = {0.1, 0.4, 1},
        body = {0.0, 0.0, 0}
    },
    crouchTool = { -- Fall Flying
        head = {0.5, 0.2, 1},
        neck = {0.4, 0.2, 0},
        body = {0.2, 0.1, 1}
    },
    yesCrossbowAim = {
        crossbowAim = {1,1,0}
    },
    noCrossbowAim = {
        crossbowAim = {0,0,0}
    }
}

function setSmoothieState(state)
    if currentSmoothieState == state then return end
    currentSmoothieState = state
    local preset = SMOOTHIE_PRESETS[state] or SMOOTHIE_PRESETS.default
    local mult = not eyeLookConfig and 1 or 0
    for part, obj in pairs(smoothieParts) do
        applySmoothiePreset(obj, preset[part], mult)
    end
end

local currentCrossbowSmoothieState = false

function setSmoothieCrossbow()
    local mult = not eyeLookConfig and 1 or 0
    if charAnim.crossR:isPlaying() and not isFlying then
        charAnim.crossR:setPriority(2)
        applySmoothiePreset(smoothCrossbowAim, SMOOTHIE_PRESETS.yesCrossbowAim.crossbowAim, mult)
        currentCrossbowSmoothieState = true
        local offset = vec(0, 0, 0)
        if charAnim.crouchwalk:isPlaying() or charAnim.crouchwalkback:isPlaying() then
            offset = vec(70, 0, 0)
        elseif player:getPose() == "CROUCHING" then
            offset = vec(40, 0, 0)
        elseif charAnim.sprint:isPlaying() then
            offset = vec(30, 0, 0)
        end
        smoothCrossbowAim:setOffset(offset)
    else
        charAnim.crossR:setPriority(0)
        applySmoothiePreset(smoothCrossbowAim, SMOOTHIE_PRESETS.noCrossbowAim.crossbowAim, mult)
        currentCrossbowSmoothieState = false
        smoothCrossbowAim:setOffset(vec(0, 0, 0))
    end
end

setSmoothieState("default")

for _, cfg in ipairs({
    {anim = charAnim.blink, interval = 200, minSpeed = 0.75, maxSpeed = 1.25, repeatChance = 0.25, repeatMax = 1},
    {anim = charAnim.earFlick_L, interval = 800, minSpeed = 0.8, maxSpeed = 1.2},
    {anim = charAnim.earFlick_R, interval = 800, minSpeed = 0.8, maxSpeed = 1.2},
}) do
    Animazer.randomatic:register(cfg)
end

local TAIL_PRESETS = {
    default = {stiffness = 0.2, drag = 0.8, swaySpeed = 0.03, swayMagnitude = 15, offset = 1.5},
    flying = {stiffness = 0, drag = 0, swaySpeed = 0, swayMagnitude = 0, offset = 0},
    sleeping = {stiffness = 0, drag = 0, swayMagnitude = 0},
}
local function setTailFX(name)
    local p = TAIL_PRESETS[name]
    TailFX:setStiffness(p.stiffness)
    TailFX:setDrag(p.drag)
    if p.swaySpeed then TailFX:setSwaySpeed(p.swaySpeed) end
    TailFX:setSwayMagnitude(p.swayMagnitude)
    if p.offset then TailFX:setOffset(p.offset) end
end
local ITEM_EXCLUDE = {"book", "template", "plan", "blueprint", "recipe", "raw", "cooked"}
local function itemStateCheck(words)
    local id = player:getItem(1).id
    for _, word in ipairs(words) do
        if string.find(id, word, 1, true) then return true end
    end
    return false
end
local function holdsAny(words, extraExclude)
    return itemStateCheck(words) and not itemStateCheck(extraExclude or ITEM_EXCLUDE)
end
local function isHoldingSword()
    return holdsAny({"sword", "knife", "dagger", "blade", "katana", "rapier", "kunai", "sabre", "saber", "scimitar", "shamshir", "estoc", "spear", "lance", "polearm", "trident", "falchion", "javelin", "machete", "pike", "glaive", "halberd", "sickle", "scythe", "knives"})
end
local function isHoldingTool()
    return holdsAny({"pickaxe", "shovel", "hoe", "hammer", "saw", "wrench", "crowbar"})
end
local function isHoldingThrowable()
    return holdsAny({"egg", "ender_pearl", "wind_charge", "snowball", "throwing_axe", "shuriken", "dart", "splash_potion", "experience_bottle", "fishing_rod", "lingering_potion", "grenade"})
end
local function isHoldingAxe()
    return holdsAny({"axe"}, {"book", "template", "plan", "blueprint", "recipe", "raw", "cooked", "pickaxe"})
end

local function setRightItemPivot(clothed)
    if clothed then
        rPivotClothed:setParentType("RIGHT_ITEM_PIVOT")
        rPivotBare:setParentType("NONE")
    else
        rPivotClothed:setParentType("NONE")
        rPivotBare:setParentType("RIGHT_ITEM_PIVOT")
    end
end
local function setLeftItemPivot(clothed)
    if clothed then
        lPivotClothed:setParentType("LEFT_ITEM_PIVOT")
        lPivotBare:setParentType("NONE")
    else
        lPivotClothed:setParentType("NONE")
        lPivotBare:setParentType("LEFT_ITEM_PIVOT")
    end
end
local function getJumpAnimName()
    if player:getPose() == "CROUCHING" then return "crouchjumpfull" end
    local state = Animazer.currentState
    if state == "sword" then return "jumpfull_sword" end
    if state == "tool" then return "jumpfull_tool" end
    return "jumpfull"
end
local function setOverrides(slots)
    for slot, anim in pairs(slots) do
        if anim then
            Animazer:setSlotOverride(slot, anim)
            Animazer:useOverrideAnim(slot, true)
        else
            Animazer:clearSlotOverride(slot)
        end
    end
end
local function blockLForCrouch(isCrouched, useToolBlock)
    return (isCrouched and useToolBlock) and "crouch_toolblockL" or "blockL"
end

shieldL:setVisible(false)
shieldR:setVisible(false)

function quickItemPivotRefresh()
    itemMouth:setParentType("NONE")
    setRightItemPivot(not clothesConfig)
end

function pings.usePing(state)
    if state and not useKeyHeldDown then
        shieldActivationTimer = 2 -- Delay for 2 ticks (approx 100ms) to prevent visual pop
    end
    useKeyHeldDown = state
end

local function bindDir(key, setter)
    local kb = keybinds:fromVanilla(key)
    kb.press = function() setter(true) end
    kb.release = function() setter(false) end
end
bindDir("key.forward", function(v) forwardKeyHeldDown = v end)
bindDir("key.left", function(v) leftKeyHeldDown = v end)
bindDir("key.right", function(v) rightKeyHeldDown = v end)
bindDir("key.back", function(v) backKeyHeldDown = v end)

local useKeyChange = keybinds:fromVanilla("key.use")
useKeyChange.press = function() pings.usePing(true) end
useKeyChange.release = function() pings.usePing(false) end

local wasLoadingCrouching, isUsingBowOrLoad = false, false
firstPersonOn = false
firstPersonCheck = 0
local vanillaRightArmRot = vec(0,0,0)
local isBlocking = false
local isAttacking = false
local isMining = false
local isAimingSpear = false

function events.tick()
    if shieldActivationTimer > 0 then shieldActivationTimer = shieldActivationTimer - 1 end

    local nowGrounded = player:isOnGround()
    if prevOnGround == nil then prevOnGround = nowGrounded end
    if (not prevOnGround) and nowGrounded then
        for _, name in ipairs(LANDING_STOP_ANIMS) do
            local a = charAnim[name]
            if a and a.stop then pcall(a.stop, a) end
        end
        if Animazer.lockedAnims then
            for k, _ in pairs(Animazer.lockedAnims) do
                Animazer.lockedAnims[k] = nil
                if k and k.stop then pcall(k.stop, k) end
            end
        end
    end
    prevOnGround = nowGrounded

    if not eyeLookConfig then Looksy:tick() else Looksy:setStrength(0); Looksy:tick() end

    local pose = player:getPose()
    local isCrouching = pose == "CROUCHING"
    local velLen = player:getVelocity():length()
    if (charAnim.loadR:isPlaying() or charAnim.bowR:isPlaying() or isAimingSpear) and useKeyHeldDown then
        isUsingBowOrLoad = true
    end

    if isUsingBowOrLoad then
        if not useKeyHeldDown or not itemStateCheck({"crossbow", "bow", "trident"}) then
            isUsingBowOrLoad = false
        end
    end

    if isCrouching and isUsingBowOrLoad and not wasLoadingCrouching then
        wasLoadingCrouching = true
        lArm:setOffsetRot(-60, 70, 0)
    end

    if wasLoadingCrouching then
        local crouchLoadDelay = 1
        
        if isCrouching then

            local isMoving = (forwardKeyHeldDown or backKeyHeldDown or leftKeyHeldDown or rightKeyHeldDown)

            if isUsingBowOrLoad then
                -- During the active drawing/loading phase, block walking and force idle crouch
                charAnim.crouchwalk:stop()
                charAnim.crouchwalkback:stop()
                if ((not charAnim.crouch:isPlaying()) and (not charAnim.crouch_sword:isPlaying())) then
                    if Animazer.currentState == "sword" then
                        charAnim.crouch_sword:play()
                    else
                        charAnim.crouch:play()
                    end
                end
            elseif isMoving then
                -- Animation has reached the end frame (held) and player is moving.
                -- Stop forced idle crouch and manually trigger the correct walking animation.
                if Animazer.currentState == "sword" then
                        charAnim.crouch_sword:stop()
                    else
                        charAnim.crouch:stop()
                    end
                if backKeyHeldDown and not forwardKeyHeldDown then
                    if not charAnim.crouchwalkback:isPlaying() then
                        charAnim.crouchwalkback:play()
                    end
                    charAnim.crouchwalk:stop()
                else
                    if not charAnim.crouchwalk:isPlaying() then
                        charAnim.crouchwalk:play()
                    end
                    charAnim.crouchwalkback:stop()
                end
            else
                charAnim.crouchwalk:stop()
                charAnim.crouchwalkback:stop()
                if ((not charAnim.crouch:isPlaying()) and (not charAnim.crouch_sword:isPlaying())) then
                    if Animazer.currentState == "sword" then
                        charAnim.crouch_sword:play()
                    else
                        charAnim.crouch:play()
                    end
                end
            end

            -- Maintain override state if actively using bow/load or holding use key
            if isUsingBowOrLoad or (useKeyHeldDown and itemStateCheck({"crossbow", "bow", "trident"})) then
                shieldActivationTimer = crouchLoadDelay
            end
        else
            -- Standing up: kill timer immediately to allow normal standing animations to take over
            shieldActivationTimer = 0
            charAnim.crouch:stop() -- Force stop so it doesn't overlap standing animations
        end

        if shieldActivationTimer <= 0 or not itemStateCheck({"crossbow", "bow", "trident"}) then
            lArm:setOffsetRot(0, 0, 0)
            wasLoadingCrouching = false
            if not isCrouching then charAnim.crouch:stop() end
        end
    end

    local walkNorm = velLen / 0.21585
    if isCrouching and velLen > 0.01 then setSmoothieState("crouchWalk")
    elseif isCrouching and isHoldingTool() then setSmoothieState("crouchTool")
    elseif isCrouching then setSmoothieState("crouch")
    elseif isFlying and pose ~= "FALL_FLYING" then setSmoothieState("flying")
    elseif pose == "FALL_FLYING" then setSmoothieState("elytra")
    elseif player:isSprinting() and forwardKeyHeldDown then setSmoothieState("runForward")
    elseif charAnim.sprint:isPlaying() and not useKeyHeldDown then setSmoothieState("runForward")
    elseif walkNorm > 0.3 then setSmoothieState("walkForward")
    else setSmoothieState("default") end

    if pose == "FALL_FLYING" then Looksy:setStrength(0.6)
    elseif currentSmoothieState == "run" or currentSmoothieState == "walk" then Looksy:setStrength(0.0)
    else Looksy:setStrength(1.0) end

    if pose == "FALL_FLYING" then setTailFX("flying")
    elseif pose == "SLEEPING" then setTailFX("sleeping")
    else setTailFX("default") end

    local flightSpeed = math.min(velLen / 1.5, 1.0)
    if charAnim.fly:isPlaying() and flightSpeed <= 0.01 then flightSpeed = 0.01 end
    local sprintSpeed = velLen / 0.28061
    local walkSpeed = velLen / 0.215859
    local crawlSpeed = velLen / 0.06475
    local wadeSpeed = math.max(velLen / 0.1, 0.4)
    local fallSpeed = math.min(velLen / 1.5, 1.5)
    charAnim.fall:setSpeed(fallSpeed)
    charAnim.elytra:setSpeed(flightSpeed)
    charAnim.elytradown:setSpeed(flightSpeed)
    charAnim.fly:setSpeed(flightSpeed)
    charAnim.water:setSpeed(wadeSpeed)
    charAnim.waterwalk_sword:setSpeed(wadeSpeed)
    charAnim.waterwalk:setSpeed(wadeSpeed)
    charAnim.waterwalkback:setSpeed(wadeSpeed)
    charAnim.waterup:setSpeed(wadeSpeed/2)
    charAnim.waterup_sword:setSpeed(wadeSpeed/2)

    -- Elytra Pitch Blending
    if pose == "FALL_FLYING" then
        local blendFactor = math.clamp((player:getRot().x + 45) / 90, 0, 1)
        charAnim.elytra:setBlend(1 - blendFactor)
        charAnim.elytradown:setBlend(blendFactor)
        if charAnim.elytra:isPlaying() then charAnim.elytradown:play() end
        if charAnim.elytradown:isPlaying() then charAnim.elytra:play() end
    else
        charAnim.elytra:stop()
        charAnim.elytradown:stop()
        charAnim.elytra:setBlend(0.001)
        charAnim.elytradown:setBlend(0.001)
    end

    isFlying = pose == "FALL_FLYING" or charAnim.fly:isPlaying() or anims:isFlying()
    isCrawling = (isCrouching and (charAnim.crouchwalk:isPlaying() or charAnim.crouchwalkback:isPlaying())) or pose == "SWIMMING"

    -- Crossbow Animation & Smoothie Logic
    if isFlying then
        charAnim.crossR:stop()
        charAnim.crossR:setPriority(0)
    end
    setSmoothieCrossbow()

    if player:isSprinting() and not player:isUnderwater() then
        for _, name in ipairs({"sprint", "sprint_sword", "sprint_tool"}) do charAnim[name]:setSpeed(sprintSpeed) end
    elseif velLen > 0.01 and not player:isSprinting() and not player:isUnderwater() and not player:isCrouching() then
        charAnim.walk:setSpeed(walkSpeed)
        charAnim.walk_sword:setSpeed(walkSpeed)
        charAnim.walk_tool:setSpeed(walkSpeed)
        charAnim.walkback:setSpeed(walkSpeed)
    elseif player:isCrouching() then
        charAnim.crouchwalk:setSpeed(crawlSpeed)
        charAnim.crouchwalkback:setSpeed(crawlSpeed)
    end

    if pose == "SLEEPING" then vanilla_model.HELD_ITEMS:setVisible(false)
    elseif not isFlying then vanilla_model.HELD_ITEMS:setVisible(true) end

    local itemState = isHoldingSword() and "sword" or ((isHoldingTool() or isHoldingAxe()) and "tool" or "")

    if betterCombatToggle then return
    elseif not isFlying then
        if itemState == "sword" then Animazer:setState("sword")
        elseif itemState == "tool" then Animazer:setState("tool")
        else Animazer:setState("") end
    end

    if player:isLoaded() then
        if player:getItem(1).id:find("shield") and not (isFlying and not firstPersonOn) then
            shieldRightOn = true
            rVanillaShield:setParentType("RIGHT_ITEM_PIVOT")
            rPivotClothed:setParentType("NONE")
            rPivotBare:setParentType("NONE")
            rVanillaShield:setScale(0.75, 0.75, 0.75)
        else
            shieldRightOn = false
            rVanillaShield:setParentType("NONE")
            setRightItemPivot(not clothesConfig)
            shieldR:setVisible(false)
        end
        if player:getItem(2).id:find("shield") and (not (isFlying and not firstPersonOn) or isBlocking) then
            shieldLeftOn = true
            lPivotClothed:setParentType("NONE")
            lPivotBare:setParentType("NONE")
            lVanillaShield:setParentType("LEFT_ITEM_PIVOT")
            lVanillaShield:setScale(0.75, 0.75, 0.75)
        else
            shieldLeftOn = false
            shieldL:setVisible(false)
            lVanillaShield:setParentType("NONE")
            setLeftItemPivot(not clothesConfig)
        end
    end

    -- Animation override logic
    if not betterCombatToggle then
        if isFlying then
            setOverrides({attackR = "attackR_fly", blockL = "blockL"})
        elseif isCrawling then
            setOverrides({attackR = "attackR_crouchwalk", mineR = "attackR_crouchwalk", blockL = "blockL_crouchwalk"})
        elseif itemState == "tool" and player:getItem(1).id:find("hoe") then
            setOverrides({attackR = "attackR", mineR = "mineR", blockL = blockLForCrouch(isCrouching, true)})
        elseif isHoldingAxe() then
            setOverrides({attackR = "attackR", mineR = "attackR", blockL = blockLForCrouch(isCrouching, true)})
        elseif isHoldingThrowable() then
            setOverrides({attackR = "mineR", blockL = "blockL"})
        elseif itemState == "sword" then
            setOverrides({attackR = "attackR", mineR = "mineR", blockL = "blockL"})
        elseif itemState == "tool" then
            setOverrides({attackR = "attackR", mineR = "mineR", blockL = blockLForCrouch(isCrouching, true)})
        elseif isCrouching then
            setOverrides({attackR = false, mineR = false, blockL = "blockL"})
        else
            setOverrides({attackR = false, mineR = false, blockL = "blockL"})
        end
    end

    local isInAir = not nowGrounded and not isFlying and not player:getVehicle() and not player:isUnderwater() and not player:isInWater() and pose ~= "SWIMMING" and not betterCombatToggle
    if isInAir then
        if player:getVelocity().y < -1.5 then charAnim.fall:play() else charAnim.fall:stop() end
        local desiredName = getJumpAnimName()
        if charAnim[desiredName] then charAnim[desiredName]:play() end
    end

    Animazer:tick()
    if charAnim.spearR:isPlaying() then isAimingSpear = true end
    if not useKeyHeldDown and not charAnim.spearR:isPlaying() then isAimingSpear = false end
end

function events.render(delta, context)
    vanillaRightArmRot = vanilla_model.RIGHT_ARM:getOriginRot()
    vanillaBodyRot = vanilla_model.HEAD:getOriginRot()
    local legRotY = vanilla_model.RIGHT_LEG:getOriginRot().y
    local betterCombatPlaying = math.abs(legRotY - (-0.286475)) > 0.01

    if betterCombatPlaying then
        if not betterCombatToggle then
            betterCombatToggle = true
            if animModel and animModel.setAllOff then animModel:setAllOff(true) end
            animations:stopAll()
        end
        if player:getVehicle() then
            neck:setRot(0, vanillaBodyRot.y * 0.1, 0)
            head:setRot(0, vanillaBodyRot.y * 0.1, 0)
        else
            neck:setRot(vanillaBodyRot.x * 0.5, vanillaBodyRot.y * 0.5, vanillaBodyRot.z * 0.5)
            head:setRot(vanillaBodyRot.x * 0.5, vanillaBodyRot.y * 0.5, vanillaBodyRot.z * 0.5)
        end
        rArm:setRot(vanillaRightArmRot.x, vanillaRightArmRot.y, vanillaRightArmRot.z)
        rFore:setOffsetRot(0, 90, 0)
        body:setOffsetRot(0, 15, 0)
        for _, pivot in ipairs({rPivotBare, rPivotClothed}) do
            pivot:setOffsetRot(-90, 180, 0)
            pivot:setOffsetPivot(0, 0, 0)
        end
    else
        neck:setRot(0, 0, 0)
        head:setRot(0, 0, 0)
        if betterCombatToggle then
            betterCombatToggle = false
            if animModel and animModel.setAllOff then animModel:setAllOff(false) end
            Animazer:setState("dummy")
            rArm:setRot(0, 0, 30)
            rFore:setOffsetRot(0, 0, 0)
            body:setOffsetRot(0, 0, 0)
            for _, pivot in ipairs({rPivotBare, rPivotClothed}) do
                pivot:setOffsetRot(0, 0, 0)
                pivot:setOffsetPivot(0, 0, 0)
            end
        end
    end

    if (not renderer:isFirstPerson() and not root:getVisible())
        or (renderer:isFirstPerson() and not root:getVisible() and not betterCombatToggle) then
        root:setVisible(true)
    end
    -- Hiding item when crouch walking logic
    if charAnim.crouchwalk:isPlaying() or charAnim.crouchwalkback:isPlaying() then
        rPivotClothed:setParentType("NONE")
        rPivotBare:setParentType("NONE")

        if ((isHoldingSword() or isHoldingAxe() or isHoldingTool()) and not charAnim.attackR_crouchwalk:isPlaying() and not useKeyHeldDown) then -- if Ruby has a tool or weapon, hold it in her mouth
            itemMouth:setParentType("RIGHT_ITEM_PIVOT")
            jaw:setOffsetRot(-30, 0, 0)
            vanilla_model.RIGHT_ITEM:setVisible(true)
        elseif (charAnim.attackR_crouchwalk:isPlaying() or charAnim.attackR:isPlaying() or charAnim.mineR:isPlaying()) then -- if Ruby is attacking, hold item normally
            jaw:setOffsetRot(0, 0, 0)
            vanilla_model.RIGHT_ITEM:setVisible(true)
            quickItemPivotRefresh()
        elseif ((not shieldRightOn) and (not currentCrossbowSmoothieState)) then
            quickItemPivotRefresh()
            -- if ruby has a left shield or a loaded crossbow, show on the arm. Otherwise, hide the right item
            vanilla_model.RIGHT_ITEM:setVisible(false)
            jaw:setOffsetRot(0, 0, 0)
            
        else
            quickItemPivotRefresh()
        end
        if not shieldLeftOn then -- if ruby has no left shield, hide the left item too
            vanilla_model.LEFT_ITEM:setVisible(false)
        end
        
    else
        quickItemPivotRefresh()
        
        jaw:setOffsetRot(0, 0, 0)
        if not isFlying then
            vanilla_model.RIGHT_ITEM:setVisible(true)
            vanilla_model.LEFT_ITEM:setVisible(true)
        end
    end
    
    isAttacking = charAnim.attackR:isPlaying() or charAnim.attackR_crouchwalk:isPlaying() or charAnim.attackR_fly:isPlaying() or isAimingSpear
    isMining = charAnim.mineR:isPlaying()
    isBlocking = ((shieldRightOn or shieldLeftOn) and useKeyHeldDown)
        or charAnim.crouch_toolblockL:isPlaying()
        or charAnim.blockL_crouchwalk:isPlaying()
        or charAnim.blockL:isPlaying()
        or charAnim.blockR:isPlaying()
        or player:isBlocking()

    local pose = player:getPose()
    if pose == "CROUCHING" then
        if charAnim.crouchwalk:isPlaying() or charAnim.crouchwalkback:isPlaying() then
            crouchTargetOffset = 2.0
        elseif charAnim.crouch_tool:isPlaying() then
            crouchTargetOffset = 3.0
        else
            crouchTargetOffset = 2.5
        end
        if crouchOffset ~= crouchTargetOffset then
            repeat
                crouchOffset = crouchOffset + crouchTargetTransition
                if crouchOffset > crouchTargetOffset then
                    crouchOffset = crouchTargetOffset
                end
                body:setPos(0,crouchOffset,0)
                
                -- Check for any attack animation variant to prevent position stuttering
                local isAttackingCurrent = isAttacking or charAnim.attackR_fly:isPlaying()
                if isAttackingCurrent then
                    root:setPos(0,crouchOffset,0)
                end
            until crouchOffset >= crouchTargetOffset or pose ~= "CROUCHING"
            root:setPos(0,crouchTargetOffset,0)
        end
            
        
        if charAnim.attackR_crouchwalk:isPlaying() then
            body:setRot(-5,0,0)
            body:setPos(0,0,0)
            neck:setPos(0,0,0)
            head:setPos(0,0,0)
        elseif ((isAttacking or isMining) and ((isHoldingTool() == false) and (isHoldingAxe() == false) and ((charAnim.crouchjumpfull:isPlaying() == false) and (charAnim.watercrouch:isPlaying() == false)))) then
            if isAimingSpear then
                body:setRot(-15,0,0)
                neck:setOffsetRot(20,0,10)
                body:setPos(0,-crouchTargetOffset+2.25,0)
            else
                body:setRot(-15,0,0)
                body:setPos(0,-crouchTargetOffset-1,-1)
                neck:setPos(0,0,-1)
                head:setPos(0,0,-1)
            end
        elseif ((isAttacking or isMining) and (((isHoldingTool() == true) or (isHoldingAxe() == true)) or ((isHoldingSword() == true) and ((charAnim.crouchjumpfull:isPlaying() == true) or (charAnim.watercrouch:isPlaying() == true))))) then
            
                body:setRot(-10,0,0)
                body:setPos(0,0,1.5)
                neck:setPos(0,0,0)
                head:setPos(0,0,-1)
            
        elseif isMining then    
            body:setPos(0,0.5,1.5)
        
        elseif isBlocking and pose == "CROUCHING" then
            if (isHoldingTool() or isHoldingAxe()) then
                body:setPos(0,0.5,0)
                body:setOffsetRot(0,0,0)

            elseif not isCrawling then
                body:setOffsetRot(-30,0,0)
                body:setPos(0,0.5,0)
            end
            
                
        elseif isBlocking then
            
            body:setPos(0,0.5,0)
        else
            body:setRot(0,0,0)
            neck:setPos(0,0,0)
            head:setPos(0,0,0)
            body:setPos(0,0,0)
            body:setOffsetRot(0,0,0)
            neck:setOffsetRot(0,0,0)
        end

        

    else
        crouchTargetOffset = 0.0
        if crouchOffset >= crouchTargetOffset then
            repeat
                crouchOffset = crouchOffset - crouchTargetTransition
                if crouchOffset < crouchTargetOffset then
                    crouchOffset = crouchTargetOffset
                end
                root:setPos(0,crouchOffset,0)
            until crouchOffset <= crouchTargetOffset or pose == "CROUCHING"
            body:setRot(0,0,0)
            neck:setPos(0,0,0)
            head:setPos(0,0,0)
            body:setPos(0,0,0)
        end
    end

    TailFX:update(delta, context)

    local isInAir = not player:isOnGround() and not isFlying and not player:getVehicle() and not player:isUnderwater() and not player:isInWater() and pose ~= "SWIMMING" and pose ~= "SLEEPING" and not betterCombatToggle
    if not isInAir then
        for _, name in ipairs(JUMP_ANIMS) do
            if charAnim[name] and charAnim[name].stop then charAnim[name]:stop() end
        end
        charAnim.fall:stop()
    else
        local desiredName = getJumpAnimName()
        local desired = charAnim[desiredName]
        if desired then
            if desired.setPriority then desired:setPriority(1) end
            if desired.setOverride then desired:setOverride(true) end
            Animazer.jumpsy:render(desired)
        end
        for _, name in ipairs(JUMP_ANIMS) do
            if name ~= desiredName and charAnim[name] and charAnim[name].stop then charAnim[name]:stop() end
        end
    end

    if isFlying then
        local yawDelta = (player:getRot().y % 360 - player:getBodyYaw() % 360 + 180) % 360 - 180
        local bankAngle = math.clamp(yawDelta, -60, 60) * 0.3
        lLeg:setOffsetRot(-bankAngle, 0, 0)
        rLeg:setOffsetRot(bankAngle, 0, 0)
    else
        lLeg:setOffsetRot(0, 0, 0)
        rLeg:setOffsetRot(0, 0, 0)
    end

    firstPersonOn = renderer:isFirstPerson() and not (context == "OTHER" or context == "RENDER" or context == "MINECRAFT_GUI" or context == "PAPERDOLL" or context == "FIGURA_GUI")
    fpArms:setVisible(firstPersonOn)
    firstPersonCheck = math.max(0, math.min(2, firstPersonCheck + (context == "FIRST_PERSON" and 1 or -1)))

    local hideBody = renderer:isFirstPerson() and betterCombatToggle and context == "RENDER"
    for _, part in ipairs({hips, body, rArm, lArm, lLeg, rLeg}) do part:setVisible(not hideBody) end

    if isFlying then
        glider:setVisible(true)
        if (renderer:isFirstPerson() and context == "FIRST_PERSON")
            or charAnim.attackR_fly:isPlaying() or charAnim.attackR:isPlaying() or charAnim.mineR:isPlaying() or betterCombatToggle
            or charAnim.spearR:isPlaying() or charAnim.loadR:isPlaying() or useKeyHeldDown then
            vanilla_model.RIGHT_ITEM:setVisible(true)
        elseif player:getItem(2).id:find("shield") then
            vanilla_model.LEFT_ITEM:setVisible(true)
            vanilla_model.RIGHT_ITEM:setVisible(false)
        elseif not betterCombatToggle then
            vanilla_model.RIGHT_ITEM:setVisible(false)
            vanilla_model.LEFT_ITEM:setVisible(false)
        end
        if pose ~= "FALL_FLYING" then
            charAnim.elytra:stop()
            charAnim.elytradown:stop()
        end
    else
        charAnim.elytra:stop()
        charAnim.elytradown:stop()
        glider:setVisible(false)
        if not isCrawling or context == "FIRST_PERSON" then vanilla_model.HELD_ITEMS:setVisible(true) end
    end
end





local clothes = {
    hips.Pants, hips.Belt, lLeg.LeftPantLeg, rLeg.RightPantLeg,
    lFore.LeftForearmClothed, rFore.RightForearmClothed,
    fpArms.RightArmFP.RightForearmFP.RightForearmClothedFP,
    fpArms.LeftArmFP.LeftForearmFP.LeftForearmClothedFP,
}
NoClothesParts = {
    lLeg.LeftThigh, rLeg.RightThigh, lFore.LeftForearmBare, rFore.RightForearmBare,
    fpArms.RightArmFP.RightForearmFP.RightForearmBareFP,
    fpArms.LeftArmFP.LeftForearmFP.LeftForearmBareFP, bareHips,
}

local function applyClothesParts(showSkivvy)
    for _, piece in pairs(clothes) do piece:setVisible(not showSkivvy) end
    for _, piece in pairs(NoClothesParts) do piece:setVisible(showSkivvy) end
end

local function setClothesVisibility(state)
    clothesConfig = state
    applyClothesParts(state)
    if not shieldRightOn and not isFlying then setRightItemPivot(not state) end
    if not shieldLeftOn and not isFlying then setLeftItemPivot(not state) end
    bareHips:setVisible(state)
    pings.toggleClothes(state)
end
applyClothesParts(clothesConfig)

local function set1stPersonBob(state)
    firstPersonConfig = state
    charAnim.FP_No_Bob:setPriority(4)
    charAnim.FP_No_Bob:setOverride(state)
    charAnim.FP_No_Bob:setPlaying(state)
    pings.toggleFirstPerson(state)
end
local function setCustomSwordToggle(state) customSwordConfig = state; pings.toggleSword(state) end
local function setCustomShieldToggle(state) customShieldConfig = state; pings.toggleShield(state) end
local function setTrackingToggle(state)
    eyeLookConfig = state
    local cached = currentSmoothieState
    currentSmoothieState = ""
    setSmoothieState(cached)
    pings.toggleEyeLook(state)
end

local actionOffColor = vectors.hexToRGB('#305163')
local actionHoverColor = vectors.hexToRGB('#4fc1ff')
local actionOnColor = vectors.hexToRGB('#c3dbe8')
local mainPage = action_wheel:newPage()
action_wheel:setPage(mainPage)

local function wheelToggle(title, texX, texY, toggleX, toggleY, onToggle)
    return mainPage:newAction()
        :title(title)
        :setTexture(textures["textures.actionWheel"], texX, texY, 16, 16, 1.5)
        :setToggleTexture(textures["textures.actionWheel"], toggleX, toggleY, 16, 16, 1.5)
        :setColor(actionOnColor):setHoverColor(actionHoverColor):setToggleColor(actionOffColor)
        :setOnToggle(onToggle)
end

local toggleClothesAction = wheelToggle("Toggle Clothes", 32, 0, 48, 0, setClothesVisibility)
local toggleFPBob = wheelToggle("Toggle 1st Person Arm Bobbing", 0, 0, 16, 0, set1stPersonBob)
local toggleTracking = wheelToggle("Toggle Head & Eye Tracking", 32, 16, 48, 16, setTrackingToggle)
local toggleCustomShield = wheelToggle("Toggle Custom Shield", 0, 32, 16, 32, setCustomShieldToggle)
local toggleCustomSword = wheelToggle("Toggle Custom Sword", 0, 16, 16, 16, setCustomSwordToggle)
betterCombatToggle = false

function pings.updateFromConfig(swordState, shieldState, clothesState, firstPersonState, eyeLookState)
    toggleCustomSword:setToggled(swordState)
    toggleCustomShield:setToggled(shieldState)
    toggleClothesAction:setToggled(clothesState)
    toggleFPBob:setToggled(firstPersonState)
    toggleTracking:setToggled(eyeLookState)
end

function events.entity_init()
    pings.updateFromConfig(customSwordConfig, customShieldConfig, clothesConfig, firstPersonConfig, eyeLookConfig)
end

for pingName, configKey in pairs({
    toggleSword = "customSwordConfig",
    toggleShield = "customShieldConfig",
    toggleClothes = "clothesConfig",
    toggleFirstPerson = "firstPersonConfig",
    toggleEyeLook = "eyeLookConfig",
}) do
    pings[pingName] = function(state)
        if host:isHost() then config:save(configKey, state) end
    end
end

set1stPersonBob(firstPersonConfig)

function events.item_render(item)
    if item.id:find("sword") and not toggleCustomSword:isToggled() then
        local scale = firstPersonCheck >= 1 and 0.70 or 1
        itemModels.ItemSword:setScale(scale, scale, scale)
        return itemModels.ItemSword
    end

    if item.id:find("shield") then
        local customOn = not toggleCustomShield:isToggled()
        shieldR:setVisible((shieldRightOn or (shieldRightOn and shieldLeftOn)) and customOn)
        shieldL:setVisible((shieldLeftOn or (shieldRightOn and shieldLeftOn)) and customOn)
        if toggleCustomShield:isToggled() then return end

        if firstPersonCheck >= 1 then
            if useKeyHeldDown and shieldActivationTimer == 0
                and not (charAnim.spearR:isPlaying() or charAnim.loadR:isPlaying() or charAnim.mineR:isPlaying() or itemStateCheck({"spear", "trident", "lance"})) then
                if shieldLeftOn and not shieldRightOn then
                    itemModels.ItemShield:setPos(5, 5, 2)
                    itemModels.ItemShield:setRot(5, 10, -15)
                else
                    itemModels.ItemShield:setPos(-5, 5, 2)
                    itemModels.ItemShield:setRot(5, 10, 15)
                end
            elseif not isBlocking then
                itemModels.ItemShield:setPos(0, 0, 0)
                itemModels.ItemShield:setRot(0, 0, 0)
            end
            return itemModels.ItemShield
        end
        return itemModels.ItemBlank
    end
end
