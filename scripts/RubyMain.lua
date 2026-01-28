-- Fantasia Ruby Main Script

--hide vanilla model
vanilla_model.PLAYER:setVisible(false)

vanilla_model.ARMOR:setVisible(false)
--hide vanilla helmet
vanilla_model.HELMET_ITEM:setVisible(false)

--hide vanilla cape model
vanilla_model.CAPE:setVisible(false)

vanilla_model.ELYTRA:setVisible(false)

--Load config
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


--Variable to point to the animations. In this case the animations are in the main character file

charAnim = animations["models.ruby"]
itemAnim = animations["models.items"]


-- Localize root model parts to reduce indexing instructions
local root = models.models.ruby.root
local hips = root.Hips
local body = root.Body

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
    {"jumpfull", 1, 1, 2},
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
 Animazer.jumpsy:setRange(-jumpVelocityRange, jumpVelocityRange) -- Min velocity (end of anim), Max velocity (start of anim)
 Animazer.jumpsy:setSmoothness(1)   -- Lower is more responsive, higher is smoother

-- State variables
local clothesOn = true
local isFlying = false
local shieldRightOn = false
local shieldLeftOn = false
local currentSmoothieState = ""
local useKeyHeldDown = false
local forwardKeyHeldDown = false
local leftKeyHeldDown = false
local rightKeyHeldDown = false
local backKeyHeldDown = false
local shieldActivationTimer = 0
local isCrawling = false

-- Track previous grounded state to stop jump animations immediately on landing
local prevOnGround = true

-- Crouch offset variables
local crouchOffset = 0.0
local crouchTargetTransition = 0.8
local crouchTargetOffset = 0.0


-- Smoothie smoothHead Script
local smoothHead = smoothie:newSmoothHead(body.Neck.Head)
local smoothNeck = smoothie:newSmoothHead(body.Neck)
local smoothBody = smoothie:newSmoothHead(body)
local smoothCrossbowAim = smoothie:newSmoothHead(body.RightArm)

-- Configure base settings
for _, part in ipairs({smoothHead, smoothNeck, smoothBody, smoothCrossbowAim}) do
    part:setSpeed(1)
    --part:setRealignSpeed(0.7)
    part:setKeepVanillaPosition(false)
end

-- Preset Constants
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
        head = {0.2, 0.2, 2},
        neck = {0.1, 0.2, 1},
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
    
    -- If tracking is disabled, force all strengths to 0
    local mult = not eyeLookConfig and 1 or 0
    
    smoothHead:setHorizontalStrength(preset.head[1] * mult)
    smoothHead:setVerticalStrength(preset.head[2] * mult)
    smoothHead:setTiltMultiplier(preset.head[3] * mult)
    
    smoothNeck:setHorizontalStrength(preset.neck[1] * mult)
    smoothNeck:setVerticalStrength(preset.neck[2] * mult)
    smoothNeck:setTiltMultiplier(preset.neck[3] * mult)
    
    smoothBody:setHorizontalStrength(preset.body[1] * mult)
    smoothBody:setVerticalStrength(preset.body[2] * mult)
    smoothBody:setTiltMultiplier(preset.body[3] * mult)

end

local currentCrossbowSmoothieState = false

function setSmoothieCrossbow()
    -- If tracking is disabled, force all strengths to 0
    local mult = not eyeLookConfig and 1 or 0
    
    if (charAnim.crossR:isPlaying()) and not isFlying then
        charAnim.crossR:setPriority(2)
        smoothCrossbowAim:setHorizontalStrength(SMOOTHIE_PRESETS["yesCrossbowAim"].crossbowAim[1] * mult)
        smoothCrossbowAim:setVerticalStrength(SMOOTHIE_PRESETS["yesCrossbowAim"].crossbowAim[2] * mult)
        smoothCrossbowAim:setTiltMultiplier(SMOOTHIE_PRESETS["yesCrossbowAim"].crossbowAim[3] * mult)
        currentCrossbowSmoothieState = true
        if  charAnim.crouchwalk:isPlaying() or charAnim.crouchwalkback:isPlaying() then
            smoothCrossbowAim:setOffset(vec(70, 0, 0))
        elseif player:getPose() == "CROUCHING" then
            smoothCrossbowAim:setOffset(vec(40, 0, 0))
        elseif charAnim.sprint:isPlaying() then
            smoothCrossbowAim:setOffset(vec(30, 0, 0))
        else
            
            smoothCrossbowAim:setOffset(vec(0, 0, 0))
        end
    else
        charAnim.crossR:setPriority(0)
        smoothCrossbowAim:setHorizontalStrength(SMOOTHIE_PRESETS["noCrossbowAim"].crossbowAim[1] * mult)
        smoothCrossbowAim:setVerticalStrength(SMOOTHIE_PRESETS["noCrossbowAim"].crossbowAim[2] * mult)
        smoothCrossbowAim:setTiltMultiplier(SMOOTHIE_PRESETS["noCrossbowAim"].crossbowAim[3] * mult)
        currentCrossbowSmoothieState = false
        
        smoothCrossbowAim:setOffset(vec(0, 0, 0))
    end
end

setSmoothieState("default")

-- Random Animation System
Animazer.randomatic:register({ 
    anim = charAnim.blink, 
    interval = 200, 
    minSpeed = 0.75, 
    maxSpeed = 1.25,
    repeatChance = 0.25, 
    repeatMax = 1
})

Animazer.randomatic:register({ 
    anim = charAnim.earFlick_L, 
    interval = 800, 
    minSpeed = 0.8, 
    maxSpeed = 1.2
})

Animazer.randomatic:register({ 
    anim = charAnim.earFlick_R,
    interval = 800, 
    minSpeed = 0.8, 
    maxSpeed = 1.2
})

-- TailFX Properties
function TailFXDefault()
    TailFX:setStiffness(0.2)
    TailFX:setDrag(0.8)
    TailFX:setSwaySpeed(0.03)
    TailFX:setSwayMagnitude(15)
    TailFX:setOffset(1.5)
end

function TailFXFlying()
    TailFX:setStiffness(0.0)
    TailFX:setDrag(0.0)
    TailFX:setSwaySpeed(0)
    TailFX:setSwayMagnitude(0)
    TailFX:setOffset(0)
end

function TailFXSleeping()
    TailFX:setStiffness(0.0)
    TailFX:setDrag(0.0)
    TailFX:setSwayMagnitude(0)
end



-- Utility: Check if a string contains any word from a list
local function itemStateCheck(words)
    for _, word in ipairs(words) do
        if string.find(player:getItem(1).id, word, 1, true) then
            return true
        end
    end
    return false
end

-- Check if player is holding a sword-like item
local function isHoldingSword()
    local swordKeywords = {
        "sword", "knife", "dagger", "blade", "katana", "rapier", "kunai", "sabre", "saber", "scimitar", "shamshir", "estoc", "spear", "lance", "polearm", "trident", "falchion", "javelin", "machete", "pike", "glaive", "halberd", "sickle", "scythe", "knives"
    }
    local nonWeaponKeywords = {"book", "template", "plan", "blueprint", "recipe", "raw", "cooked"}
    if itemStateCheck(swordKeywords) and not itemStateCheck(nonWeaponKeywords) then
        return true
    end
    return false
end

-- Check if player is holding a tool-like item
local function isHoldingTool()
    local toolKeywords = {"pickaxe", "shovel", "hoe", "hammer", "saw", "wrench", "crowbar"}
    local nonToolKeywords = {"book", "template", "plan", "blueprint", "recipe", "raw", "cooked"}
    if itemStateCheck(toolKeywords) and not itemStateCheck(nonToolKeywords) then
            return true
    end
    return false
end
-- Check if the player is throwing a throwable item
local function isHoldingThrowable()
    local throwableKeywords = {"egg", "ender_pearl", "wind_charge", "snowball", "throwing_axe", "shuriken", "dart", "splash_potion", "experience_bottle", "fishing_rod","lingering_potion", "grenade"}
    local nonThrowableKeywords = {"book", "template", "plan", "blueprint", "recipe", "raw", "cooked"}
    if itemStateCheck(throwableKeywords) and not itemStateCheck(nonThrowableKeywords) then
            return true
    end
    return false
end

-- Check if player is holding an axe or hoe, but not a pickaxe
local function isHoldingAxe()
    local axeKeywords = {"axe"}
    local nonAxeKeywords = {"book", "template", "plan", "blueprint", "recipe", "raw", "cooked", "pickaxe"}
    if itemStateCheck(axeKeywords) and not itemStateCheck(nonAxeKeywords) then
            return true
    end
    
    return false
end



-- Initial Part Hiding
models.models.ruby.root.Body.LeftArm.LeftForearm.ShieldL:setVisible(false)
models.models.ruby.root.Body.RightArm.RightForearm.ShieldR:setVisible(false)

function quickItemPivotRefresh()
    models.models.ruby.root.Body.Neck.Head.ItemMouthTarget:setParentType("NONE")
    if not clothesConfig then
        models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed.RightHand.RightItemPivot:setParentType("RIGHT_ITEM_PIVOT")
        models.models.ruby.root.Body.RightArm.RightForearm.RightForearmBare.RightHandBare.RightItemPivotBare:setParentType("NONE")
    else
        models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed.RightHand.RightItemPivot:setParentType("NONE")
        models.models.ruby.root.Body.RightArm.RightForearm.RightForearmBare.RightHandBare.RightItemPivotBare:setParentType("RIGHT_ITEM_PIVOT")
    end
end

function pings.usePing(state)
    if state and not useKeyHeldDown then
        shieldActivationTimer = 2 -- Delay for 2 ticks (approx 100ms) to prevent visual pop
    end
    useKeyHeldDown = state
end

local forwardKeyChange = keybinds:fromVanilla("key.forward")
    forwardKeyChange.press = function()
        forwardKeyHeldDown = true
    end
    forwardKeyChange.release = function()
        forwardKeyHeldDown = false
    end

local leftKeyChange = keybinds:fromVanilla("key.left")
    leftKeyChange.press = function()
        leftKeyHeldDown = true
    end
    leftKeyChange.release = function()
        leftKeyHeldDown = false
    end

local rightKeyChange = keybinds:fromVanilla("key.right")
    rightKeyChange.press = function()
        rightKeyHeldDown = true
    end
    rightKeyChange.release = function()
        rightKeyHeldDown = false
    end

local backKeyChange = keybinds:fromVanilla("key.back")
    backKeyChange.press = function()
        backKeyHeldDown = true
    end
    backKeyChange.release = function()
        backKeyHeldDown = false
    end


local useKeyChange = keybinds:fromVanilla("key.use")
useKeyChange.press = function()
    pings.usePing(true)
end

useKeyChange.release = function()
    pings.usePing(false)
end


local wasLoadingCrouching = false
local isUsingBowOrLoad = false
firstPersonOn = false
firstPersonCheck = 0
local vanillaRightArmRot = vec(0,0,0)
local isBlocking = false
local isAttacking = false
local isMining = false
local isAimingSpear = false

function events.tick()
    if shieldActivationTimer > 0 then shieldActivationTimer = shieldActivationTimer - 1 end

    -- Landing detection: stop jump-related animations immediately when we hit the ground
    local nowGrounded = player:isOnGround()
    if prevOnGround == nil then prevOnGround = nowGrounded end
    if (not prevOnGround) and nowGrounded then
        local stopList = {
            "jumpfull",
            "jumpfull_sword",
            "jumpfull_tool",
            "crouchjumpfull",
            "jumpup",
            "jumpdown",
            "walkjumpup",
            "walkjumpdown",
            "sprintjumpup",
            "sprintjumpdown",
            "crouchjumpup",
            "crouchjumpdown",
            "fall"
        }
        for _, name in ipairs(stopList) do
            local a = charAnim[name]
            if a and a.stop then pcall(a.stop, a) end
        end
        -- Also clear any locked overrides on the Animazer for safety
        if Animazer.lockedAnims then
            for k,_ in pairs(Animazer.lockedAnims) do
                Animazer.lockedAnims[k] = nil
                if k and k.stop then pcall(k.stop, k) end
            end
        end
    end
    prevOnGround = nowGrounded

    --Looksy Logic
    
    if not eyeLookConfig then
        Looksy:tick()
    else
        Looksy:setStrength(0)
        Looksy:tick()-- Call once to center
    end

    -- Smoothie State Machine
    
    local isCrouching = player:getPose() == "CROUCHING"
    if (charAnim.loadR:isPlaying() or charAnim.bowR:isPlaying() or isAimingSpear) and useKeyHeldDown then
        isUsingBowOrLoad = true
    end

    if isUsingBowOrLoad then
        if not useKeyHeldDown or not itemStateCheck({"crossbow", "bow", "trident"}) then
            isUsingBowOrLoad = false
        end
    end

    if isCrouching and isUsingBowOrLoad then
        if not wasLoadingCrouching then
            wasLoadingCrouching = true
            models.models.ruby.root.Body.LeftArm:setOffsetRot(-60, 70, 0)
        end
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
            models.models.ruby.root.Body.LeftArm:setOffsetRot(0, 0, 0)
            wasLoadingCrouching = false
            -- If we are no longer crouching, make sure the manual crouch animation is stopped.
            -- If we ARE still crouching, don't stop it here to avoid a frame of standing pose.
            if not isCrouching then
                charAnim.crouch:stop()
            end
        end
    end

    if player:getPose() == "CROUCHING" and player:getVelocity():length() > 0.01 then
        setSmoothieState("crouchWalk")
    elseif player:getPose() == "CROUCHING" and isHoldingTool() then
        setSmoothieState("crouchTool")
    elseif player:getPose() == "CROUCHING" then
        setSmoothieState("crouch")
    elseif ((isFlying) and not (player:getPose() == "FALL_FLYING")) then
        setSmoothieState("flying")
    elseif player:getPose() == "FALL_FLYING" then
        setSmoothieState("elytra")
    elseif player:isSprinting() and forwardKeyHeldDown then
        setSmoothieState("runForward")
    elseif charAnim.sprint:isPlaying() and not useKeyHeldDown then
        setSmoothieState("runForward")
    elseif (player:getVelocity():length()/0.21585) > 0.3 and forwardKeyHeldDown then
        setSmoothieState("walkForward")
    elseif (player:getVelocity():length()/0.21585) > 0.3 and useKeyHeldDown then
        setSmoothieState("walkForward")
    elseif (player:getVelocity():length()/0.21585) > 0.3 and not useKeyHeldDown then
        setSmoothieState("walkForward")
    elseif (player:getVelocity():length()/0.21585) > 0.3 and useKeyHeldDown then
        setSmoothieState("walkForward")
    else
        setSmoothieState("default")
    end

    -- EyeTracker alt values
    if player:getPose() == "FALL_FLYING" then
        Looksy:setStrength(0.6)
    elseif currentSmoothieState == "run" or currentSmoothieState == "walk" then
        Looksy:setStrength(0.0)
    else
        Looksy:setStrength(1.0)
    end

    -- TailFX Logic
    if (player:getPose() == "FALL_FLYING") then
        TailFXFlying()
    elseif player:getPose() == "SLEEPING" then
        TailFXSleeping()
    else
        TailFXDefault()
    end

    

    local flightSpeed = (player:getVelocity():length()/1.5)
    
    if flightSpeed >= 1.0 then
        flightSpeed = 1.0
    end
    if charAnim["fly"]:isPlaying() and flightSpeed <= 0.01 then
        flightSpeed = 0.01
    end
    local sprintSpeed = (player:getVelocity():length()/0.28061) -- average sprint speed
    local walkSpeed = (player:getVelocity():length()/0.215859) -- average walk speed
    local crawlSpeed = (player:getVelocity():length()/0.06475) -- average crawl speed
    local wadeSpeed = (player:getVelocity():length()/0.1) -- average wade speed
    local fallSpeed = (player:getVelocity():length()/1.5) -- just a fall speed guess
    
    if fallSpeed >= 1.5 then
        fallSpeed = 1.5
    end
    if wadeSpeed <= 0.4 then
        wadeSpeed = 0.4
    end
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
    if player:getPose() == "FALL_FLYING" then
        local angle = player:getRot().x
        local blendFactor = math.clamp((angle + 45) / 90, 0, 1)
        
        -- Apply blends
        charAnim.elytra:setBlend(1 - blendFactor)
        charAnim.elytradown:setBlend(blendFactor)
        
        if charAnim.elytra:isPlaying() then charAnim.elytradown:play() end
        if charAnim.elytradown:isPlaying() then charAnim.elytra:play() end
        
    else
        charAnim.elytra:stop()
        charAnim.elytradown:stop()
        -- Reset blends so elytra anims stop as soon as you land
        charAnim.elytra:setBlend(0.001) -- That value makes the transition instant
        charAnim.elytradown:setBlend(0.001)
    end
    
    -- Elytra Leg Banking (Turning)
    

    -- Flight State Tracking & Visuals
    isFlying = (player:getPose() == "FALL_FLYING") or (charAnim["fly"]:isPlaying()) or anims:isFlying()
    isCrawling = ((player:getPose() == "CROUCHING") and (charAnim.crouchwalk:isPlaying() or charAnim.crouchwalkback:isPlaying())) or (player:getPose() == "SWIMMING")
    
    if isFlying then
        
        models.models.ruby.root.Body.Glider:setVisible(true)
        
        if renderer:isFirstPerson() == true then
            vanilla_model.HELD_ITEMS:setVisible(true)
        else
            vanilla_model.HELD_ITEMS:setVisible(false)
        end
        if player:getPose() ~= "FALL_FLYING" then
            
            charAnim.elytra:stop()
            charAnim.elytradown:stop()
        end
    else
        charAnim.elytra:stop()
        charAnim.elytradown:stop()
        models.models.ruby.root.Body.Glider:setVisible(false)
        vanilla_model.HELD_ITEMS:setVisible(true)
    end

    -- Crossbow Animation & Smoothie Logic
    if isFlying then
        charAnim.crossR:stop()
        charAnim.crossR:setPriority(0)
    end
    setSmoothieCrossbow()

    if player:isSprinting() and not player:isUnderwater() then
        charAnim.sprint:setSpeed(sprintSpeed)
        charAnim.sprint_sword:setSpeed(sprintSpeed)
        charAnim.sprint_tool:setSpeed(sprintSpeed)
    
    elseif player:getVelocity():length() > 0.01 and not player:isSprinting() and not player:isUnderwater() and not player:isCrouching() then
        charAnim.walk:setSpeed(walkSpeed)
        charAnim.walk_sword:setSpeed(walkSpeed)
        charAnim.walk_tool:setSpeed(walkSpeed)
        charAnim.walkback:setSpeed(walkSpeed)

    elseif player:isCrouching() then
        charAnim.crouchwalk:setSpeed(crawlSpeed)
        charAnim.crouchwalkback:setSpeed(crawlSpeed)
    end

    if player:getPose() == "SLEEPING" then
        vanilla_model.HELD_ITEMS:setVisible(false)
    elseif isFlying == false then
        vanilla_model.HELD_ITEMS:setVisible(true)
    end

    -- State machine variables
    local isCrouched = (player:getPose() == "CROUCHING")
    local itemState = ""
    if isHoldingSword() then itemState = "sword"
    elseif isHoldingTool() or isHoldingAxe() then itemState = "tool" end

    -- State machine
    if betterCombatToggle == true then
        return
    elseif isFlying then
    elseif itemState == "sword" then Animazer:setState("sword")
    elseif itemState == "tool" then Animazer:setState("tool")
    else Animazer:setState("") end

    if player:isLoaded() == true then
        if player:getItem(1).id:find("shield") and not ((isFlying == true) and firstPersonOn == false) then
            shieldRightOn = (true)
            models.models.ruby.root.Body.RightArm.RightForearm.RightVanillaShield:setParentType("RIGHT_ITEM_PIVOT")
            models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed.RightHand.RightItemPivot:setParentType("NONE")
            models.models.ruby.root.Body.RightArm.RightForearm.RightForearmBare.RightHandBare.RightItemPivotBare:setParentType("NONE")
            models.models.ruby.root.Body.RightArm.RightForearm.RightVanillaShield:setScale(0.75,0.75,0.75)
        else
            shieldRightOn = (false)
            models.models.ruby.root.Body.RightArm.RightForearm.RightVanillaShield:setParentType("NONE")
            if not clothesConfig then
                models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed.RightHand.RightItemPivot:setParentType("RIGHT_ITEM_PIVOT")
                models.models.ruby.root.Body.RightArm.RightForearm.RightForearmBare.RightHandBare.RightItemPivotBare:setParentType("NONE")
            else
                models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed.RightHand.RightItemPivot:setParentType("NONE")

                models.models.ruby.root.Body.RightArm.RightForearm.RightForearmBare.RightHandBare.RightItemPivotBare:setParentType("RIGHT_ITEM_PIVOT")
            end
            models.models.ruby.root.Body.RightArm.RightForearm.ShieldR:setVisible(false)
        end
        if player:getItem(2).id:find("shield") and not ((isFlying == true) and firstPersonOn == false) then
            shieldLeftOn = true
            models.models.ruby.root.Body.LeftArm.LeftForearm.LeftForearmClothed.LeftHand.LeftItemPivot:setParentType("NONE")
            models.models.ruby.root.Body.LeftArm.LeftForearm.LeftForearmBare.LeftHandBare.LeftItemPivotBare:setParentType("NONE")
            models.models.ruby.root.Body.LeftArm.LeftForearm.LeftVanillaShield:setParentType
            ("LEFT_ITEM_PIVOT")
            models.models.ruby.root.Body.LeftArm.LeftForearm.LeftVanillaShield:setScale(0.75,0.75,0.75)
        else
            shieldLeftOn = (false)
            models.models.ruby.root.Body.LeftArm.LeftForearm.ShieldL:setVisible(false)
            models.models.ruby.root.Body.LeftArm.LeftForearm.LeftVanillaShield:setParentType("NONE")
            if not clothesConfig then
                models.models.ruby.root.Body.LeftArm.LeftForearm.LeftForearmClothed.LeftHand.LeftItemPivot:setParentType("LEFT_ITEM_PIVOT")
                models.models.ruby.root.Body.LeftArm.LeftForearm.LeftForearmBare.LeftHandBare.LeftItemPivotBare:setParentType("NONE")
            else
                models.models.ruby.root.Body.LeftArm.LeftForearm.LeftForearmClothed.LeftHand.LeftItemPivot:setParentType("NONE")
                models.models.ruby.root.Body.LeftArm.LeftForearm.LeftForearmBare.LeftHandBare.LeftItemPivotBare:setParentType("LEFT_ITEM_PIVOT")
            end
            
        end
    end
    
    -- Animation override logic
    if betterCombatToggle == true then
        --return
    elseif isFlying then
        Animazer:setSlotOverride("attackR", "attackR_fly")
        Animazer:useOverrideAnim("attackR", true)
        Animazer:clearSlotOverride("blockL")
            Animazer:setSlotOverride("blockL", "blockL")
            Animazer:useOverrideAnim("blockL", true)
    elseif isCrawling then
        Animazer:setSlotOverride("attackR", "attackR_crouchwalk")
        Animazer:useOverrideAnim("attackR", true)
        Animazer:setSlotOverride("mineR", "attackR_crouchwalk")
        Animazer:useOverrideAnim("mineR", true)
        
        -- Crouch-specific blocking
        Animazer:clearSlotOverride("blockL")
        Animazer:setSlotOverride("blockL", "blockL_crouchwalk")
        Animazer:useOverrideAnim("blockL", true)
    elseif itemState == "tool" and player:getItem(1).id:find("hoe") then
        Animazer:setSlotOverride("attackR", "attackR")
        Animazer:useOverrideAnim("attackR", true)
        Animazer:setSlotOverride("mineR", "mineR")
        Animazer:useOverrideAnim("mineR", true)
        if isCrouched then 
            Animazer:clearSlotOverride("blockL")
            Animazer:setSlotOverride("blockL", "crouch_toolblockL")
            Animazer:useOverrideAnim("blockL", true)
        else 
            AAnimazer:clearSlotOverride("blockL")
            Animazer:setSlotOverride("blockL", "blockL")
            Animazer:useOverrideAnim("blockL", true)
        end
    elseif isHoldingAxe() then
        Animazer:setSlotOverride("attackR", "attackR")
        Animazer:useOverrideAnim("attackR", true)
        Animazer:setSlotOverride("mineR", "attackR")
        Animazer:useOverrideAnim("mineR", true)
        if isCrouched then 
            Animazer:clearSlotOverride("blockL")
            Animazer:setSlotOverride("blockL", "crouch_toolblockL")
            Animazer:useOverrideAnim("blockL", true)
        else 
            Animazer:clearSlotOverride("blockL")
            Animazer:setSlotOverride("blockL", "blockL")
            Animazer:useOverrideAnim("blockL", true) 
        end
    elseif isHoldingThrowable() then
        Animazer:setSlotOverride("attackR", "mineR")
        Animazer:useOverrideAnim("attackR", true)
        if isCrouched then 
            Animazer:clearSlotOverride("blockL")
            Animazer:setSlotOverride("blockL", "blockL")
            Animazer:useOverrideAnim("blockL", true)
        else 
            Animazer:clearSlotOverride("blockL")
            Animazer:setSlotOverride("blockL", "blockL")
            Animazer:useOverrideAnim("blockL", true)
        end
    elseif itemState == "sword" then
        Animazer:setSlotOverride("attackR", "attackR")
        Animazer:useOverrideAnim("attackR", true)
        Animazer:setSlotOverride("mineR", "mineR")
        Animazer:useOverrideAnim("mineR", true)
        if isCrouched then 
            Animazer:clearSlotOverride("blockL")
            Animazer:setSlotOverride("blockL", "blockL")
            Animazer:useOverrideAnim("blockL", true)
        else 
            Animazer:clearSlotOverride("blockL")
            Animazer:setSlotOverride("blockL", "blockL")
            Animazer:useOverrideAnim("blockL", true)
        end
    elseif itemState == "tool" then
        Animazer:setSlotOverride("attackR", "attackR")
        Animazer:useOverrideAnim("attackR", true)
        Animazer:setSlotOverride("mineR", "mineR")
        Animazer:useOverrideAnim("mineR", true)
        if isCrouched then 
            Animazer:clearSlotOverride("blockL")
            Animazer:setSlotOverride("blockL", "crouch_toolblockL")
            Animazer:useOverrideAnim("blockL", true)
        else 
            Animazer:clearSlotOverride("blockL")
            Animazer:setSlotOverride("blockL", "blockL")
            Animazer:useOverrideAnim("blockL", true) 
        end
    elseif isCrouched then
        Animazer:clearSlotOverride("attackR")
        Animazer:clearSlotOverride("mineR")
        Animazer:clearSlotOverride("blockL")
        Animazer:setSlotOverride("blockL", "blockL")
        Animazer:useOverrideAnim("blockL", true)
    else
        Animazer:clearSlotOverride("attackR")
        Animazer:clearSlotOverride("mineR")
        Animazer:clearSlotOverride("blockL")
        Animazer:setSlotOverride("blockL", "blockL")
        Animazer:useOverrideAnim("blockL", true)
    end
    

    local isInAir = not player:isOnGround() and not isFlying and not player:getVehicle() and not player:isUnderwater() and not player:isInWater() and not (player:getPose() == "SWIMMING") and not betterCombatToggle
    if isInAir then
        if player:getVelocity().y < -1.5 then
            charAnim.fall:play()
        else
            charAnim.fall:stop()
        end

        local state = Animazer.currentState
        local desiredName = "jumpfull"
        if player:getPose() == "CROUCHING" then desiredName = "crouchjumpfull"
        elseif state == "sword" then desiredName = "jumpfull_sword"
        elseif state == "tool" then desiredName = "jumpfull_tool" end
        if charAnim[desiredName] then charAnim[desiredName]:play() end
    end

    Animazer:tick()

    if charAnim.spearR:isPlaying() then
        isAimingSpear = true
    end
    if not useKeyHeldDown and not charAnim.spearR:isPlaying() then
        isAimingSpear = false
    end

end

function events.render(delta, context)
    -- Better Combat Animation Detector
    vanillaRightArmRot = vanilla_model.RIGHT_ARM:getOriginRot()
    vanillaBodyRot = vanilla_model.HEAD:getOriginRot()
    local legRotY = vanilla_model.RIGHT_LEG:getOriginRot().y
    local vanillaRot = -0.286475
    local tolerance = 0.01  -- Increased tolerance for robustness

    if math.abs(legRotY - vanillaRot) > tolerance then
        -- Better combat animation is playing
        if betterCombatToggle == false then
            betterCombatToggle = true
            if animModel and animModel.setAllOff then animModel:setAllOff(true) end
            animations:stopAll() 
        end
        models.models.ruby.root.Body.Neck:setRot(vanillaBodyRot.x*0.5, vanillaBodyRot.y*0.5, vanillaBodyRot.z*0.5)
        models.models.ruby.root.Body.Neck.Head:setRot(vanillaBodyRot.x*0.5, vanillaBodyRot.y*0.5, vanillaBodyRot.z*0.5)
        -- Map the rotation of the right arm to the vanilla right arm
        models.models.ruby.root.Body.RightArm:setRot(vanillaRightArmRot.x, vanillaRightArmRot.y, vanillaRightArmRot.z)
        
        models.models.ruby.root.Body.RightArm.RightForearm:setOffsetRot(0,90,0)
        models.models.ruby.root.Body:setOffsetRot(0,15,0)
        models.models.ruby.root.Body.RightArm.RightForearm.RightForearmBare.RightHandBare.RightItemPivotBare:setOffsetRot(-90,180,0)
        models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed.RightHand.RightItemPivot:setOffsetRot(-90,180,0)
        models.models.ruby.root.Body.RightArm.RightForearm.RightForearmBare.RightHandBare.RightItemPivotBare:setOffsetPivot(0, 0, 0)
        models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed.RightHand.RightItemPivot:setOffsetPivot(0, 0, 0)
    else
        -- Reset to default state when better combat animation is not playing
        if betterCombatToggle == true then
            betterCombatToggle = false
            -- Re-enable EZAnims once
            if animModel and animModel.setAllOff then animModel:setAllOff(false) end
            Animazer:setState("dummy")
            
            -- Reset right arm rotation and offsets
            models.models.ruby.root.Body.RightArm:setRot(0, 0, 30)
            models.models.ruby.root.Body.RightArm.RightForearm:setOffsetRot(0, 0, 0)
            models.models.ruby.root.Body:setOffsetRot(0,0,0)
            models.models.ruby.root.Body.RightArm.RightForearm.RightForearmBare.RightHandBare.RightItemPivotBare:setOffsetRot(0, 0, 0)
            models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed.RightHand.RightItemPivot:setOffsetRot(0, 0, 0)
            models.models.ruby.root.Body.RightArm.RightForearm.RightForearmBare.RightHandBare.RightItemPivotBare:setOffsetPivot(0, 0, 0)
            models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed.RightHand.RightItemPivot:setOffsetPivot(0, 0, 0)

        end
    end
    -- Hiding item when crouch walking logic
    if charAnim.crouchwalk:isPlaying() or charAnim.crouchwalkback:isPlaying() then
        models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed.RightHand.RightItemPivot:setParentType("NONE")
        models.models.ruby.root.Body.RightArm.RightForearm.RightForearmBare.RightHandBare.RightItemPivotBare:setParentType("NONE")

        if ((isHoldingSword() or isHoldingAxe() or isHoldingTool()) and not charAnim.attackR_crouchwalk:isPlaying() and not useKeyHeldDown) then -- if Ruby has a tool or weapon, hold it in her mouth
            models.models.ruby.root.Body.Neck.Head.ItemMouthTarget:setParentType("RIGHT_ITEM_PIVOT")
            models.models.ruby.root.Body.Neck.Head.Jaw:setOffsetRot(-30,0,0)
            vanilla_model.RIGHT_ITEM:setVisible(true)
        elseif (charAnim.attackR_crouchwalk:isPlaying() or charAnim.attackR:isPlaying() or charAnim.mineR:isPlaying()) then -- if Ruby is attacking, hold item normally
            models.models.ruby.root.Body.Neck.Head.Jaw:setOffsetRot(0,0,0)
            vanilla_model.RIGHT_ITEM:setVisible(true)
            quickItemPivotRefresh()
        elseif ((not shieldRightOn) and (not currentCrossbowSmoothieState)) then -- if ruby has a left shield or a loaded crossbow, show on the arm. Otherwise, hide the right item
            vanilla_model.RIGHT_ITEM:setVisible(false)
            models.models.ruby.root.Body.Neck.Head.Jaw:setOffsetRot(0,0,0)
        else
            quickItemPivotRefresh()
        end
        if not shieldLeftOn then -- if ruby has no left shield, hide the left item too
            vanilla_model.LEFT_ITEM:setVisible(false)
        end
        
    else
        quickItemPivotRefresh()
        
        models.models.ruby.root.Body.Neck.Head.Jaw:setOffsetRot(0,0,0)
        if not isFlying then
            vanilla_model.RIGHT_ITEM:setVisible(true)
            vanilla_model.LEFT_ITEM:setVisible(true)
        end
    end
    


    -- Crouch offset logic
    if player:getPose() == "CROUCHING" then
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
                models.models.ruby.root.Body:setPos(0,crouchOffset,0)
                
                -- Check for any attack animation variant to prevent position stuttering
                local isAttackingCurrent = charAnim["attackR"]:isPlaying() or charAnim["attackR_crouchwalk"]:isPlaying() or charAnim["attackR_fly"]:isPlaying() or (isAimingSpear)
                if isAttackingCurrent then
                    models.models.ruby.root:setPos(0,crouchOffset,0)
                end
            until ((crouchOffset >= crouchTargetOffset) or (player:getPose() ~= "CROUCHING"))
            models.models.ruby.root:setPos(0,crouchTargetOffset,0)
        end
            
        isAttacking = charAnim["attackR"]:isPlaying() or charAnim["attackR_crouchwalk"]:isPlaying() or charAnim["attackR_fly"]:isPlaying() or isAimingSpear
        isMining = charAnim.mineR:isPlaying()
        
        isBlocking = (((shieldRightOn or shieldLeftOn) and useKeyHeldDown)
        or (charAnim.crouch_toolblockL:isPlaying() 
        or charAnim.blockL_crouchwalk:isPlaying() 
        or charAnim.blockL:isPlaying() 
        or charAnim.blockR:isPlaying() 
        or player:isBlocking())
        )
        if charAnim.attackR_crouchwalk:isPlaying() then
            models.models.ruby.root.Body:setRot(-5,0,0)
            models.models.ruby.root.Body:setPos(0,0,0)
            models.models.ruby.root.Body.Neck:setPos(0,0,0)
            models.models.ruby.root.Body.Neck.Head:setPos(0,0,0)
        elseif ((isAttacking or isMining) and ((isHoldingTool() == false) and (isHoldingAxe() == false) and ((charAnim.crouchjumpfull:isPlaying() == false) and (charAnim.watercrouch:isPlaying() == false)))) then
            if isAimingSpear then
                models.models.ruby.root.Body:setRot(-15,0,0)
                models.models.ruby.root.Body.Neck:setOffsetRot(20,0,10)
                models.models.ruby.root.Body:setPos(0,-crouchTargetOffset+2.25,0)
            else
                models.models.ruby.root.Body:setRot(-15,0,0)
                models.models.ruby.root.Body:setPos(0,-crouchTargetOffset-1,-1)
                models.models.ruby.root.Body.Neck:setPos(0,0,-1)
                models.models.ruby.root.Body.Neck.Head:setPos(0,0,-1)
            end
        elseif ((isAttacking or isMining) and (((isHoldingTool() == true) or (isHoldingAxe() == true)) or ((isHoldingSword() == true) and ((charAnim.crouchjumpfull:isPlaying() == true) or (charAnim.watercrouch:isPlaying() == true))))) then
            
                models.models.ruby.root.Body:setRot(-10,0,0)
                models.models.ruby.root.Body:setPos(0,0,1.5)
                models.models.ruby.root.Body.Neck:setPos(0,0,0)
                models.models.ruby.root.Body.Neck.Head:setPos(0,0,-1)
            
        elseif isMining then    
            models.models.ruby.root.Body:setPos(0,0.5,1.5)
        
        elseif isBlocking and player:getPose() == "CROUCHING" then
            if (isHoldingTool() or isHoldingAxe()) then
                models.models.ruby.root.Body:setPos(0,0.5,0)
                models.models.ruby.root.Body:setOffsetRot(0,0,0)

            elseif not isCrawling then
                models.models.ruby.root.Body:setOffsetRot(-30,0,0)
                models.models.ruby.root.Body:setPos(0,0.5,0)
            end
            
                
        elseif isBlocking then
            
            models.models.ruby.root.Body:setPos(0,0.5,0)
        else
            models.models.ruby.root.Body:setRot(0,0,0)
            models.models.ruby.root.Body.Neck:setPos(0,0,0)
            models.models.ruby.root.Body.Neck.Head:setPos(0,0,0)
            models.models.ruby.root.Body:setPos(0,0,0)
            models.models.ruby.root.Body:setOffsetRot(0,0,0)
            models.models.ruby.root.Body.Neck:setOffsetRot(0,0,0)
        end

        

    else
        crouchTargetOffset = 0.0
        if crouchOffset >= crouchTargetOffset then
            repeat
                crouchOffset = crouchOffset - crouchTargetTransition
                if crouchOffset < crouchTargetOffset then
                    crouchOffset = crouchTargetOffset
                end
                models.models.ruby.root:setPos(0,crouchOffset,0)
            until ((crouchOffset <= crouchTargetOffset) or (player:getPose() == "CROUCHING"))
            models.models.ruby.root.Body:setRot(0,0,0)
            models.models.ruby.root.Body.Neck:setPos(0,0,0)
            models.models.ruby.root.Body.Neck.Head:setPos(0,0,0)
            models.models.ruby.root.Body:setPos(0,0,0)
        end
    end

    TailFX:update(delta, context)

    -- Jumpsy logic
    local isInAir = not player:isOnGround() and not isFlying and not player:getVehicle() and not player:isUnderwater() and not player:isInWater() and not (player:getPose() == "SWIMMING") and not (player:getPose() == "SLEEPING") and not betterCombatToggle
    
    if not isInAir then
        -- Stop all jumpfull animations when on ground
        for _, name in ipairs({"jumpfull", "jumpfull_sword", "jumpfull_tool", "crouchjumpfull"}) do
            if charAnim[name] and charAnim[name].stop then charAnim[name]:stop() end
        end
        charAnim.fall:stop()
    else
        local state = Animazer.currentState
        local desiredName = "jumpfull"
        if player:getPose() == "CROUCHING" then desiredName = "crouchjumpfull"
        elseif state == "sword" then desiredName = "jumpfull_sword"
        elseif state == "tool" then desiredName = "jumpfull_tool" end

        local desired = charAnim[desiredName]
        if desired then

            if desired.setPriority then desired:setPriority(1) end
            if desired.setOverride then desired:setOverride(true) end
            Animazer.jumpsy:render(desired)
        end
        
        for _, name in ipairs({"jumpfull", "jumpfull_sword", "jumpfull_tool", "crouchjumpfull"}) do
            if name ~= desiredName and charAnim[name] and charAnim[name].stop then
                charAnim[name]:stop()
            end
        end
    end

    local leftLeg = models.models.ruby.root.LeftLeg
    local rightLeg = models.models.ruby.root.RightLeg
    
    if isFlying then

        local headYaw = player:getRot().y % 360
        local bodyYaw = player:getBodyYaw() % 360
        local yawDelta = (headYaw - bodyYaw + 180) % 360 - 180
        
        
        local bankAngle = math.clamp(yawDelta, -60, 60) * 0.3 -- 0.5 multiplier for sensitivity
        
        leftLeg:setOffsetRot(-bankAngle, 0, 0)
        rightLeg:setOffsetRot(bankAngle, 0, 0)
    else
        leftLeg:setOffsetRot(0, 0, 0)
        rightLeg:setOffsetRot(0, 0, 0)

    end

    firstPersonOn = ((renderer:isFirstPerson() and not (context == "OTHER" or context=="RENDER")))
        models.models.ruby.root.FPArms:setVisible(firstPersonOn)
        
        if firstPersonOn == true then
            firstPersonCheck = firstPersonCheck + 1
        else
            firstPersonCheck = firstPersonCheck - 1
        end
        if firstPersonCheck >= 2 then
            firstPersonCheck = 2
        elseif firstPersonCheck <= 0 then
            firstPersonCheck = 0
        end

        if firstPersonCheck >= 1 then
            
            models.models.ruby.root.Body:setVisible(false)
            models.models.ruby.root.Body.RightArm:setVisible(false)
            models.models.ruby.root.Body.LeftArm:setVisible(false)
            if betterCombatToggle == true then
                models.models.ruby.root.Hips:setVisible(false)
            else
                models.models.ruby.root.Hips:setVisible(true)
            end

        else
            models.models.ruby.root.Hips:setVisible(true)
            models.models.ruby.root.Body:setVisible(true)
            models.models.ruby.root.Body.RightArm:setVisible(true)
            models.models.ruby.root.Body.LeftArm:setVisible(true)
        end
    
    

end





--set Ruby's outfit-specific parts
local clothes = {
    models.models.ruby.root.Hips.Pants,
    models.models.ruby.root.Hips.Belt,
    models.models.ruby.root.LeftLeg.LeftPantLeg,
    models.models.ruby.root.RightLeg.RightPantLeg,
    models.models.ruby.root.Body.LeftArm.LeftForearm.LeftForearmClothed,
    models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed,
    models.models.ruby.root.FPArms.RightArmFP.RightForearmFP.RightForearmClothedFP,
    models.models.ruby.root.FPArms.LeftArmFP.LeftForearmFP.LeftForearmClothedFP,
}

--set Ruby's skivvy-specific parts
--Ruby's thighs and hips are hidden when in her default outfit so that they don't clip through her pants. The gloveless forearms are separate parts as well.
NoClothesParts = {
    models.models.ruby.root.LeftLeg.LeftThigh,
    models.models.ruby.root.RightLeg.RightThigh,
    models.models.ruby.root.Body.LeftArm.LeftForearm.LeftForearmBare,
    models.models.ruby.root.Body.RightArm.RightForearm.RightForearmBare,
    models.models.ruby.root.FPArms.RightArmFP.RightForearmFP.RightForearmBareFP,
    models.models.ruby.root.FPArms.LeftArmFP.LeftForearmFP.LeftForearmBareFP,
    models.models.ruby.root.Hips.BareHips
}



-- Toggle Ruby's outfit and skivvies visibility
local function setClothesVisibility(state)
    clothesConfig = state
    -- Show/hide outfit pieces
    for _, clothesPiece in pairs(clothes) do
        clothesPiece:setVisible(not state)
    end
    -- Show/hide skivvy-specific body parts
    for _, bodyPiece in pairs(NoClothesParts) do
        bodyPiece:setVisible(state)
    end
    -- Adjust item pivots and hips visibility based on state
    if not clothesConfig then
        if not shieldRightOn and not isFlying then
            models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed.RightHand.RightItemPivot:setParentType("RIGHT_ITEM_PIVOT")
        end
        if not shieldLeftOn and not isFlying then
            models.models.ruby.root.Body.LeftArm.LeftForearm.LeftForearmClothed.LeftHand.LeftItemPivot:setParentType("LEFT_ITEM_PIVOT")
            models.models.ruby.root.Body.LeftArm.LeftForearm.LeftForearmBare.LeftHandBare.LeftItemPivotBare:setParentType("NONE")
        end
        models.models.ruby.root.Hips.BareHips:setVisible(false)
    else
        if not shieldRightOn and not isFlying then
            models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed.RightHand.RightItemPivot:setParentType("NONE")
            models.models.ruby.root.Body.RightArm.RightForearm.RightForearmBare.RightHandBare.RightItemPivotBare:setParentType("RIGHT_ITEM_PIVOT")
        end
        if not shieldLeftOn and not isFlying then
            models.models.ruby.root.Body.LeftArm.LeftForearm.LeftForearmBare.LeftHandBare.LeftItemPivotBare:setParentType("LEFT_ITEM_PIVOT")
        end
        models.models.ruby.root.Hips.BareHips:setVisible(true)
    end
    pings.toggleClothes(state)
end

-- Ensure Ruby starts with her outfit visible
local function SetNoClothesPartsVisibility()
    for _, clothesPiece in pairs(clothes) do
        clothesPiece:setVisible(not clothesConfig)
    end
    for _, bodyPiece in pairs(NoClothesParts) do
        bodyPiece:setVisible(clothesConfig)
    end
end
SetNoClothesPartsVisibility()



-- Toggle first-person arm bobbing
local function set1stPersonBob(state)
    --When True, FP arm bob should stop
    firstPersonConfig = state
    charAnim.FP_No_Bob:setPriority(4)
    charAnim.FP_No_Bob:setOverride(firstPersonConfig)
    charAnim.FP_No_Bob:setPlaying(firstPersonConfig)
    pings.toggleFirstPerson(state)
end


-- Toggle custom items
local function setCustomSwordToggle(state)
    customSwordConfig = state
    pings.toggleSword(state)
    
end



-- Action wheel color setup
local actionOffColor   = vectors.hexToRGB('#305163')
local actionHoverColor = vectors.hexToRGB('#4fc1ff')
local actionOnColor    = vectors.hexToRGB('#c3dbe8')





-- Toggle custom shield
local function setCustomShieldToggle(state)
    customShieldConfig = state
    pings.toggleShield(state)
end

-- Toggle Head & Eye tracking
local function setTrackingToggle(state)
    eyeLookConfig = state
    local cached = currentSmoothieState
    currentSmoothieState = "" -- Force refresh
    setSmoothieState(cached)
    pings.toggleEyeLook(state)
end

-- Action Wheel setup
local mainPage = action_wheel:newPage()
action_wheel:setPage(mainPage)

-- Define actions for the action wheel
local toggleClothesAction = mainPage:newAction()
    :title("Toggle Clothes")
    :setTexture(textures["textures.actionWheel"], 32, 0, 16, 16, 1.5)
    :setToggleTexture(textures["textures.actionWheel"], 48, 0 , 16, 16, 1.5)
    :setColor(actionOnColor)
    :setHoverColor(actionHoverColor)
    :setToggleColor(actionOffColor)
    :setOnToggle(setClothesVisibility)

local toggleFPBob = mainPage:newAction()
    :title("Toggle 1st Person Arm Bobbing")
    :setTexture(textures["textures.actionWheel"], 0, 0, 16, 16, 1.5)
    :setToggleTexture(textures["textures.actionWheel"], 16, 0, 16, 16, 1.5)
    :setColor(actionOnColor)
    :setHoverColor(actionHoverColor)
    :setToggleColor(actionOffColor)
    :setOnToggle(set1stPersonBob) 

local toggleTracking = mainPage:newAction()
    :title("Toggle Head & Eye Tracking")
    :setTexture(textures["textures.actionWheel"], 32, 16, 16, 16, 1.5) -- Using shield icon as placeholder
    :setToggleTexture(textures["textures.actionWheel"], 48, 16, 16, 16, 1.5)
    :setColor(actionOnColor)
    :setHoverColor(actionHoverColor)
    :setToggleColor(actionOffColor)
    :setOnToggle(setTrackingToggle)

local toggleCustomShield = mainPage:newAction()
    :title("Toggle Custom Shield")
    :setTexture(textures["textures.actionWheel"], 0, 32, 16, 16, 1.5)
    :setToggleTexture(textures["textures.actionWheel"], 16, 32, 16, 16, 1.5)
    :setColor(actionOnColor)
    :setHoverColor(actionHoverColor)
    :setToggleColor(actionOffColor)
    :setOnToggle(setCustomShieldToggle)

local toggleCustomSword = mainPage:newAction()
    :title("Toggle Custom Sword")
    :setTexture(textures["textures.actionWheel"], 0, 16, 16, 16, 1.5)
    :setToggleTexture(textures["textures.actionWheel"], 16, 16, 16, 16, 1.5)
    :setColor(actionOnColor)
    :setHoverColor(actionHoverColor)
    :setToggleColor(actionOffColor)
    :setOnToggle(setCustomSwordToggle)

-- Initial state for toggles
betterCombatToggle = false

--Persisting Variables


-- Update the actions
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

function pings.toggleSword(state)
    if host:isHost() then
        config:save("customSwordConfig", state)
    end
end

function pings.toggleShield(state)
    if host:isHost() then
        config:save("customShieldConfig", state)
    end
end

function pings.toggleClothes(state)
    if host:isHost() then
        config:save("clothesConfig", state)
    end
end

function pings.toggleFirstPerson(state)
    if host:isHost() then
        config:save("firstPersonConfig", state)
    end
end

function pings.toggleEyeLook(state)
    if host:isHost() then
        config:save("eyeLookConfig", state)
    end
end

set1stPersonBob(firstPersonConfig)


function events.item_render(item)
    -- Custom sword rendering
    if ((item.id:find("sword")) and (not toggleCustomSword:isToggled())) then

            if firstPersonCheck >= 1 then
                models.models.items.ItemSword:setScale(0.70, 0.70, 0.70)
            else
                models.models.items.ItemSword:setScale(1, 1, 1)
            end
            return models.models.items.ItemSword
    end

    -- Custom shield rendering
    if item.id:find("shield") then
        local rightVis = (shieldRightOn or (shieldRightOn and shieldLeftOn)) and not toggleCustomShield:isToggled()
        local leftVis = (shieldLeftOn or (shieldRightOn and shieldLeftOn)) and not toggleCustomShield:isToggled()
        
        -- Update visibility of custom shield models (Third Person)
        models.models.ruby.root.Body.RightArm.RightForearm.ShieldR:setVisible(rightVis)
        models.models.ruby.root.Body.LeftArm.LeftForearm.ShieldL:setVisible(leftVis)
        
        -- If custom shields are disabled, return early to allow vanilla rendering
        if toggleCustomShield:isToggled() then return end

        -- First Person Rendering Logic 
        if firstPersonCheck >= 1 then
            if useKeyHeldDown and shieldActivationTimer == 0 then
                 -- Apply blocking transform            
                 if shieldLeftOn and not shieldRightOn then
                     models.models.items.ItemShield:setPos(5, 5, 2)
                     models.models.items.ItemShield:setRot(5, 10, -15)
                 else 
                     -- Default/Right hand blocking transform
                     models.models.items.ItemShield:setPos(-5, 5, 2)
                     models.models.items.ItemShield:setRot(5, 10, 15)
                 end
            else
                -- Reset to default hold position
                models.models.items.ItemShield:setPos(0, 0, 0)
                models.models.items.ItemShield:setRot(0, 0, 0)
            end
            return models.models.items.ItemShield
        else
            return models.models.items.ItemBlank
        end
    end
end


