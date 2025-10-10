-- Auto generated script file --
--API Docs
--https://applejuiceyy.github.io/figs/latest/

--hide vanilla model
vanilla_model.PLAYER:setVisible(false)

vanilla_model.ARMOR:setVisible(false)
--re-enable the helmet item
vanilla_model.HELMET_ITEM:setVisible(true)

--hide vanilla cape model
vanilla_model.CAPE:setVisible(false)

vanilla_model.ELYTRA:setVisible(false)

local squapi = require("SquAPI")
local anims = require("EZAnims")

--Variable to point to the animations. In this case the animations are in the main character file
charAnim = animations["models.ruby"]
itemAnim = animations["models.items"]


-- Animation blend settings
anims:setOneJump(true)
anims:setFallVel(-1.5)
local animModel = anims:addBBModel(charAnim)

-- Set blend times for character animations
local blendSettings = {
    {charAnim.idle, 2, 2},
    {charAnim.jumpup, 0.001, 2},
    {charAnim.jumpdown, 2, 0.001},
    {charAnim.fall, 2, 0.001},
    {charAnim.walkjumpup, 0.001, 2},
    {charAnim.walkjumpdown, 2, 0.001},
    {charAnim.FP_No_Bob, 4, 3},
    {charAnim.walkback, 1, 1},
    {charAnim.sprintjumpup, 0.001, 2},
    {charAnim.sprintjumpdown, 2, 0.001},
    {charAnim.sprint, 2, 2},
    {charAnim.crouch, 2, 2},
    {charAnim.water, 0.001, 0.001},
    {charAnim.waterwalk, 4, 3},
    {charAnim.waterwalkback, 4, 3},
    {charAnim.waterup, 4, 3},
    {charAnim.swim, 4, 4},
    {charAnim.idle_sword, 2, 2},
    {charAnim.walk_sword, 2, 2},
    {charAnim.jumpup_sword, 0.001, 2},
    {charAnim.jumpdown_sword, 2, 0.001},
    {charAnim.jumpup_tool, 1, 2},
    {charAnim.jumpdown_tool, 2, 2},
    {charAnim.walkjumpup_tool, 1, 2},
    {charAnim.walkjumpdown_tool, 2, 2},
    {charAnim.sprintjumpup_tool, 1, 2},
    {charAnim.sprintjumpdown_tool, 2, 2},
    {charAnim.walkjumpup_sword, 2 , 2},
    {charAnim.walkjumpdown_sword, 2, 0.001},
    {charAnim.sprint_sword, 2, 2},
    {charAnim.sprintjumpup_sword, 0.001, 2},
    {charAnim.sprintjumpdown_sword, 2, 0.001},
    {charAnim.waterwalk_sword, 4, 3},
    {charAnim.waterup_sword, 4, 3},
    {charAnim.swim_sword, 4, 4},
    {charAnim.attackR, 1, 0},
    {charAnim.attackR_tool, 1, 0},
    {charAnim.mineR, 1, 0},
    {charAnim.elytra, 4, 4},
    {charAnim.fly, 3, 3},
    {charAnim.idle_tool, 2, 2},
    {charAnim.walk_tool, 2, 2},
    {charAnim.sprint_tool, 2, 2},
    {charAnim.crouch_tool, 2, 2},
    {charAnim.crouch_sword, 2, 2},
    {charAnim.crouchjumpdown, 1, 1},
    {charAnim.watercrouch, 1, 1},
    {charAnim.blockR, 2, 2},
    {charAnim.blockL, 2, 2},
    {charAnim.crouch_toolblockL, 1.5, 1.5},
    {charAnim.spearR, 8, 1},
}
for _, v in ipairs(blendSettings) do
    v[1]:setBlendTime(v[2], v[3])
end



-- Set overrides for key character animations
local overrideAnims = {
    charAnim.FP_No_Bob, charAnim.jumpdown, charAnim.walkjumpdown, charAnim.sprintjumpup, charAnim.sprintjumpdown,
    charAnim.idle, charAnim.idle_sword, charAnim.walk_sword, charAnim.jumpup_sword,
    charAnim.walkjumpup_sword, charAnim.walkjumpdown_sword, charAnim.sprintjumpup_sword, charAnim.fall,
    charAnim.attackR, charAnim.attackR_tool, charAnim.mineR,
    charAnim.sit, charAnim.elytra, charAnim.elytradown, charAnim.fly,
    charAnim.idle_tool, charAnim.walk_tool, charAnim.sprint_tool, charAnim.crouch_tool,
    charAnim.bowR, charAnim.attackR_betterCombat, charAnim.jumpup_sword, charAnim.jumpdown_sword, charAnim.blockR, charAnim.blockL, charAnim.crouch_toolblockL, charAnim.sprintjumpdown_sword,
    charAnim.jumpup_tool, charAnim.jumpdown_tool, charAnim.walkjumpup_tool, charAnim.walkjumpdown_tool, charAnim.sprintjumpup_tool, charAnim.sprintjumpdown_tool, charAnim.crouch_sword, charAnim.crouchjumpdown, charAnim.watercrouch,
    charAnim.spearR
}
for _, anim in ipairs(overrideAnims) do
    anim:setOverride(true)
end

-- Set priorities for attack/mine animations
charAnim.attackR:setPriority(3)
charAnim.attackR_tool:setPriority(2)
charAnim.spearR:setPriority(3)
charAnim.mineR:setPriority(2)
charAnim.attackR_betterCombat:setPriority(3)






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
    local throwableKeywords = {"egg", "ender_pearl", "snowball", "throwing_axe", "shuriken", "dart", "splash", "grenade"}
    local nonThrowableKeywords = {"book", "template", "plan", "blueprint", "recipe", "raw", "cooked", "trident"}
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



-- Crouch offset variables
local crouchOffset = 0.0
local crouchTargetTransition = 0.8
local crouchTargetOffset = 0.0

-- State variables
local clothesOn = true
local isFlying = false
local shieldRightOn = false
local shieldLeftOn = false
local timerTarget = 0

-- Initial Part Hiding
models.models.ruby.root.Body.LeftArm.LeftForearm.ShieldL:setVisible(false)
models.models.ruby.root.Body.RightArm.RightForearm.ShieldR:setVisible(false)

local useKeyHeldDown = false

-- Figura automatically provides the pings and events tables. Only one definition per event/ping is allowed.
function pings.usePing(state)
    useKeyHeldDown = state
end

local attackKey = keybinds:fromVanilla("key.attack"):onPress(function()
    if betterCombatToggle == true and not player:isBlocking() and not charAnim.mineR:isPlaying()  then
        betterCombatAttack()
    end
end)

local useKeyChange = keybinds:fromVanilla("key.use")
    useKeyChange.press = function()
        pings.usePing(true)
end

useKeyChange.release = function()
    pings.usePing(false)
end
local rotAdd = 0
function events.tick()
    
    if (player:getPose() == "CROUCHING") then 
        if (((charAnim["crouch_tool"]:isPlaying())  or (charAnim["crouch_sword"]:isPlaying()) or ((charAnim["crouch"]) and not customShieldToggle)) and (shieldLeftOn == true)) then
            if (useKeyHeldDown == true) then
                    
                    
                    charAnim.crouch_toolblockL:setOverride(true)
                    charAnim.crouch_toolblockL:setPriority(3)
                    charAnim.blockL:stop()
                    
                    charAnim.crouch_toolblockL:play()
            else
                charAnim.crouch_toolblockL:stop()
                
            end
        end     
    end


    if player:getPose() == "CROUCHING" then
        
        crouchTargetOffset = 2.0
        if crouchOffset <= crouchTargetOffset then
            repeat
                crouchOffset = crouchOffset + crouchTargetTransition
                if crouchOffset > crouchTargetOffset then
                    crouchOffset = crouchTargetOffset
                end
                models.models.ruby.root.Body:setPos(0,crouchOffset,0)
                if charAnim["attackR"]:isPlaying() then
                    models.models.ruby.root:setPos(0,crouchOffset,0)
                end
            until ((crouchOffset >= crouchTargetOffset) or (player:getPose() == not "CROUCHING"))
            models.models.ruby.root:setPos(0,crouchOffset,0)
            if (((charAnim["attackR"]:isPlaying()) or (charAnim["mineR"]:isPlaying())) and ((isHoldingTool() == false) and (isHoldingAxe() == false))) then
                models.models.ruby.root.Body:setRot(-10,0,-20)
                models.models.ruby.root.Body:setPos(0,-crouchOffset-1,-1)
                models.models.ruby.root.Body.Neck:setPos(0,0,-1)
                models.models.ruby.root.Body.Neck.Head:setPos(0,0,-1)
            elseif charAnim["attackR_tool"]:isPlaying() then    
                models.models.ruby.root.Body:setPos(0,0.5,1.5)
            elseif charAnim["crouch_toolblockL"]:isPlaying() then
                models.models.ruby.root.Body:setPos(0,0.5,0)
            

                
            else
                models.models.ruby.root.Body:setRot(0,0,0)
                models.models.ruby.root.Body.Neck:setPos(0,0,0)
                models.models.ruby.root.Body.Neck.Head:setPos(0,0,0)
                models.models.ruby.root.Body:setPos(0,0,0)
            end
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

    local flightSpeed = (player:getVelocity():length()/1.5)
    
    if flightSpeed >= 1.0 then
        flightSpeed = 1.0
    end
    if charAnim["fly"]:isPlaying() and flightSpeed <= 0.01 then
        flightSpeed = 0.01
    end

    local sprintSpeed = (player:getVelocity():length()/0.28061)
    local walkSpeed = (player:getVelocity():length()/0.21585)
    

    charAnim.elytra:setSpeed(flightSpeed)
    charAnim.elytradown:setSpeed(flightSpeed)
    charAnim.fly:setSpeed(flightSpeed)

    --log(charAnim["fly"]:isPlaying())
    if ((player:getPose() == "FALL_FLYING") or (charAnim["fly"]:isPlaying())) then
        isFlying = true
        models.models.ruby.root.Body.Glider:setVisible(true)
        if renderer:isFirstPerson() == true then
            vanilla_model.HELD_ITEMS:setVisible(true)
        else
            vanilla_model.HELD_ITEMS:setVisible(false)
        end
    else
        isFlying = false
        models.models.ruby.root.Body.Glider:setVisible(false)
            vanilla_model.HELD_ITEMS:setVisible(true)
    end

    if player:isSprinting() and not player:isUnderwater() then
        charAnim.sprint:setSpeed(sprintSpeed)
        charAnim.sprint_sword:setSpeed(sprintSpeed)
        charAnim.sprint_tool:setSpeed(sprintSpeed)
    
    elseif player:getVelocity():length() > 0.01 and not player:isSprinting() and not player:isUnderwater() then
        charAnim.walk:setSpeed(walkSpeed)
        charAnim.walk_sword:setSpeed(walkSpeed)
        charAnim.walk_tool:setSpeed(walkSpeed)
        charAnim.walkback:setSpeed(walkSpeed)
    end

    if player:getPose() == "SLEEPING" then
        animations:stopAll()
        models.models.ruby.root:setPos(0,0,-7)
        vanilla_model.HELD_ITEMS:setVisible(false)
    elseif isFlying == false then
        --models.models.ruby.root:setPos(0,0,0)
        vanilla_model.HELD_ITEMS:setVisible(true)
    end

    --State machine
    if timerTarget == 0 then
        if isHoldingSword() == true then
            animModel:setState("sword")
        elseif ((isHoldingTool() == true) or (isHoldingAxe() == true)) then
            --log("ding")
            animModel:setState("tool")
        else
            timerTarget = 0
            animModel:setState()
        end
    end
    
    time = world.getTime()
    
    if ((isHoldingTool() == true) or(betterCombatToggle == false)) then
        timerTarget = 0
    elseif timerTarget > 0 and time >= timerTarget then
            
            timerTarget = 0
            animModel:setState(sword)

    elseif timerTarget > 0 then
        
        models.models.ruby.root.Body.RightArm.RightForearm.RightForearmBare.RightHandBare.RightItemPivotBare:setParentType("NONE")
        models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed.RightHand.RightItemPivot:setParentType("NONE")
        animations:stopAll()
    else
        timerTarget = 0
            
    
            
    end


    if player:isLoaded() == true then
        if timerTarget == 0 then
            if player:getItem(1).id:find("shield") and not ((isFlying == true) and firstPersonOn == false) then
                shieldRightOn = (true)
                models.models.ruby.root.Body.RightArm.RightForearm.RightVanillaShield:setParentType("RIGHT_ITEM_PIVOT")
                models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed.RightHand.RightItemPivot:setParentType("NONE")
                models.models.ruby.root.Body.RightArm.RightForearm.RightForearmBare.RightHandBare.RightItemPivotBare:setParentType("NONE")
                
            else
                shieldRightOn = (false)
                models.models.ruby.root.Body.RightArm.RightForearm.RightVanillaShield:setParentType("NONE")
                if clothesOn == true then
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
                models.models.ruby.root.Body.LeftArm.LeftForearm.LeftVanillaShield:setParentType("LEFT_ITEM_PIVOT")
            else
                shieldLeftOn = (false)
                --log(shieldLeftOn)
                models.models.ruby.root.Body.LeftArm.LeftForearm.ShieldL:setVisible(false)
                models.models.ruby.root.Body.LeftArm.LeftForearm.LeftVanillaShield:setParentType("NONE")
                if clothesOn == true then
                    models.models.ruby.root.Body.LeftArm.LeftForearm.LeftForearmClothed.LeftHand.LeftItemPivot:setParentType("LEFT_ITEM_PIVOT")
                    models.models.ruby.root.Body.LeftArm.LeftForearm.LeftForearmBare.LeftHandBare.LeftItemPivotBare:setParentType("NONE")
                else
                    models.models.ruby.root.Body.LeftArm.LeftForearm.LeftForearmClothed.LeftHand.LeftItemPivot:setParentType("NONE")
                    models.models.ruby.root.Body.LeftArm.LeftForearm.LeftForearmBare.LeftHandBare.LeftItemPivotBare:setParentType("LEFT_ITEM_PIVOT")
                end
                
            end
        end
    end
    
    -- anim override section
    if (
         (player:getItem(1).id:find("hoe")) or
         (player:getItem(1).id:find("trident"))
    ) then
        overrideAttackHoriSwing()
        overrideMineVertSwing()
    elseif (
        ((isHoldingAxe() == true) and (betterCombatToggle == false)) 
    ) then
        overrideAttackHoriSwing()
        overrideMineHoriSwing()
    elseif (
            (isHoldingThrowable() == true)
    ) then
        overrideAttackVertSwing()
    elseif betterCombatToggle == false then
        clearAttackOverrides()
    end
    
end

function overrideAttackHoriSwing()
    animModel:setOverrideAnim("attackR", "attackR")
    animModel:useOverrideAnim("attackR", true)
end

function overrideAttackVertSwing()
    animModel:setOverrideAnim("attackR", "mineR")
    animModel:useOverrideAnim("attackR", true)
end

function overrideMineHoriSwing()
    animModel:setOverrideAnim("mineR", "attackR")
    animModel:useOverrideAnim("mineR", true)
end

function overrideMineVertSwing()
    animModel:setOverrideAnim("mineR", "mineR")
    animModel:useOverrideAnim("mineR", true)
end

function clearAttackOverrides()
    animModel:clearOverrideAnim("attackR")
    animModel:clearOverrideAnim("mineR")
end

animModel:setOverrideAnim("trident", "attackR")


function betterCombatAttack()
    if betterCombatToggle == true then
    
        if ((isHoldingSword() == true) or ((isHoldingAxe() == true))) then
            

            models.models.ruby.root.Body.RightArm.RightForearm.RightForearmBare.RightHandBare.RightItemPivotBare:setParentType("NONE")
            models.models.ruby.root.Body.RightArm.RightForearm.RightForearmClothed.RightHand.RightItemPivot:setParentType("NONE")
            setTimer(1)
        end
    end
end

function printTimer()
    log(world.getTime())
    log(timerTarget)
end

function setTimer(sec)
    if isHoldingSword() == true then
        timerTarget = world.getTime() + sec*16
    elseif isHoldingAxe() == true then
        timerTarget = world.getTime() + sec*20
    end
end



local firstPersonBobToggled = (true)

--swap ruby's animated arm with a static arm when in first person (this is only viewable for you, other players will see animated arms as usual)
--this little bit ensures first person works with Better Combat
firstPersonOn = false
firstPersonCheck = 0
function events.render(_, context)
    
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
            
            models.models.ruby.root.Body.RightArm:setVisible(false)
            models.models.ruby.root.Body.LeftArm:setVisible(false)
            if betterCombatToggle == true then
                models.models.ruby.root.Hips:setVisible(false)
            else
                models.models.ruby.root.Hips:setVisible(true)
            end

        else
            models.models.ruby.root.Hips:setVisible(true)
            models.models.ruby.root.Body.RightArm:setVisible(true)
            models.models.ruby.root.Body.LeftArm:setVisible(true)
        end

    --if you want to remove/disable this make sure to hide/remove the RightArmFP part in blockbench
    

end




--tail script
myTail = {
	models.models.ruby.root.Hips.Tail,
	models.models.ruby.root.Hips.Tail.Tail2
}

squapi.tail:new(myTail,
    nil,    --(15) idleXMovement
    nil,    --(5) idleYMovement
    1,    --(1.2) idleXSpeed
    nil,    --(2) idleYSpeed
    2,    --(2) bendStrength
    0.5,    --(0) velocityPush
    nil,    --(0) initialMovementOffset
    2,    --(1) offsetBetweenSegments
    nil,    --(.005) stiffness
    nil,    --(.9) bounce
    nil,    --(90) flyingOffset
    nil,    --(-90) downLimit
    nil     --(45) upLimit
)

--ear script
squapi.ear:new(
    models.models.ruby.root.Body.Neck.Head.EarL, --leftEar
    models.models.ruby.root.Body.Neck.Head.EarR, --(nil) rightEar
    0.2, --(1) rangeMultiplier
    nil, --(false) horizontalEars
    0.5, --(2) bendStrength
    true, --(true) doEarFlick
    800, --(400) earFlickChance
    nil, --(0.1) earStiffness
    nil  --(0.8) earBounce
)

--smoothHead script 
--The parts are kept in separate smoothHead objects in order to create a nice spinal curve when looking around
squapi.smoothHead:new(
    {
        models.models.ruby.root.Body.Neck.Head
    },
		0.25,    --(1) strength(you can make this a table too)
    nil,    --(0.1) tilt
    nil,    --(1) speed
    false,    --(true) keepOriginalHeadPos
    nil     --(true) fixPortrait
)

squapi.smoothHead:new(
    {
        models.models.ruby.root.Body.Neck,
        
    },
		0.25,    --(1) strength(you can make this a table too)
    nil,    --(0.1) tilt
    nil,    --(1) speed
    false,    --(true) keepOriginalHeadPos
    nil     --(true) fixPortrait
)

squapi.smoothHead:new(
    {
        models.models.ruby.root.Body,
    },
		0.25,    --(1) strength(you can make this a table too)
    nil,    --(0.1) tilt
    nil,    --(1) speed
    false,    --(true) keepOriginalHeadPos
    nil     --(true) fixPortrait
)



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
    clothesOn = not state
    -- Show/hide outfit pieces
    for _, clothesPiece in pairs(clothes) do
        clothesPiece:setVisible(not state)
    end
    -- Show/hide skivvy-specific body parts
    for _, bodyPiece in pairs(NoClothesParts) do
        bodyPiece:setVisible(state)
    end
    -- Adjust item pivots and hips visibility based on state
    if clothesOn then
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
end

-- Ensure Ruby starts with her outfit visible
local function SetNoClothesPartsVisibility()
    for _, clothesPiece in pairs(clothes) do
        clothesPiece:setVisible(true)
    end
    for _, bodyPiece in pairs(NoClothesParts) do
        bodyPiece:setVisible(false)
    end
end
SetNoClothesPartsVisibility()



-- Toggle first-person arm bobbing
local function set1stPersonBob(state)
    firstPersonBobToggled = state
    if firstPersonBobToggled then
        charAnim.FP_No_Bob:setOverride(true)
        charAnim.FP_No_Bob:setPriority(4)
        charAnim.FP_No_Bob:play()
    else
        charAnim.FP_No_Bob:setOverride(false)
        charAnim.FP_No_Bob:stop()
    end
end

-- Toggle custom items
local function setCustomItemsToggle(state)
    customItemsToggle = not state
end



-- Action wheel color setup
local actionOffColor   = vectors.hexToRGB('#305163')
local actionHoverColor = vectors.hexToRGB('#4fc1ff')
local actionOnColor    = vectors.hexToRGB('#c3dbe8')




-- Toggle Better Combat compatibility
local function setBetterCombatToggle(state)
    betterCombatToggle = state
end

-- Toggle custom shield
local function setCustomShieldToggle(state)
    customShieldToggle = not state
end

-- Action Wheel setup
local mainPage = action_wheel:newPage()
action_wheel:setPage(mainPage)

-- Define actions for the action wheel
local toggleClothesAction = mainPage:newAction()
    :title("Toggle Clothes")
    :setTexture(textures["textures.rubyMain"], 32, 80, 16, 16, 1.5)
    :setToggleTexture(textures["textures.rubyMain"], 48, 80 , 16, 16, 1.5)
    :setColor(actionOnColor)
    :setHoverColor(actionHoverColor)
    :setToggleColor(actionOffColor)
    :setOnToggle(setClothesVisibility)

local toggleFPBob = mainPage:newAction()
    :title("Toggle 1st Person Arm Bobbing")
    :setTexture(textures["textures.rubyMain"], 0, 80, 16, 16, 1.5)
    :setToggleTexture(textures["textures.rubyMain"], 16, 80, 16, 16, 1.5)
    :setColor(actionOnColor)
    :setHoverColor(actionHoverColor)
    :setToggleColor(actionOffColor)
    :setOnToggle(set1stPersonBob) 

local toggleBetterCombat = mainPage:newAction()
    :title("Better Combat Compatability (Kinda janky)")
    :setTexture(textures["textures.rubyMain"], 32, 96, 16, 16, 1.5)
    :setToggleTexture(textures["textures.rubyMain"], 48, 96, 16, 16, 1.5)
    :setColor(actionOffColor)
    :setHoverColor(actionHoverColor)
    :setToggleColor(actionOnColor)
    :setOnToggle(setBetterCombatToggle)

local toggleCustomShield = mainPage:newAction()
    :title("Toggle Custom Shield")
    :setTexture(textures["textures.rubyMain"], 0, 112, 16, 16, 1.5)
    :setToggleTexture(textures["textures.rubyMain"], 16, 112, 16, 16, 1.5)
    :setColor(actionOnColor)
    :setHoverColor(actionHoverColor)
    :setToggleColor(actionOffColor)
    :setOnToggle(setCustomShieldToggle)

local toggleCustomItems = mainPage:newAction()
    :title("Toggle Custom Items")
    :setTexture(textures["textures.rubyMain"], 0, 96, 16, 16, 1.5)
    :setToggleTexture(textures["textures.rubyMain"], 16, 96, 16, 16, 1.5)
    :setColor(actionOnColor)
    :setHoverColor(actionHoverColor)
    :setToggleColor(actionOffColor)
    :setOnToggle(setCustomItemsToggle)


-- Initial state for toggles
customItemsToggle   = true
customShieldToggle  = true
betterCombatToggle  = false
function events.item_render(item)



    -- Custom sword rendering
    if ((item.id:find("sword")) and (customItemsToggle)) then
            if firstPersonCheck >= 1 then
                models.models.items.ItemSword:setScale(0.70, 0.70, 0.70)
            else
                models.models.items.ItemSword:setScale(1, 1, 1)
            end
            return models.models.items.ItemSword
    end

    -- Custom shield rendering
    if item.id:find("shield") then
        --log(shieldLeftOn)
        if not customShieldToggle then
            models.models.ruby.root.Body.RightArm.RightForearm.ShieldR:setVisible(false)
            models.models.ruby.root.Body.LeftArm.LeftForearm.ShieldL:setVisible(false)
            return
        end
        if player:isLoaded() then
            -- Both shields equipped
            if shieldRightOn and shieldLeftOn then
                models.models.ruby.root.Body.RightArm.RightForearm.ShieldR:setVisible(true)
                models.models.ruby.root.Body.LeftArm.LeftForearm.ShieldL:setVisible(true)
                    if firstPersonCheck >= 1 and useKeyHeldDown then
                        models.models.items.ItemShield:setPos(-5, 5, 2) -- Move up and closer to camera
                        models.models.items.ItemShield:setRot(5, 10, 15) -- Tilt
                    elseif firstPersonCheck >= 1 then
                        models.models.items.ItemShield:setPos(0, 0, 0)
                        models.models.items.ItemShield:setRot(0, 0, 0)
                    end
                    if firstPersonCheck >= 1 then
                        return models.models.items.ItemShield
                    else
                        return models.models.items.ItemBlank
                    end
                return (firstPersonCheck >= 1) and models.models.items.ItemShield or models.models.items.ItemBlank
            end
            -- Only right shield equipped
            if shieldRightOn then
                models.models.ruby.root.Body.RightArm.RightForearm.ShieldR:setVisible(true)
                models.models.ruby.root.Body.LeftArm.LeftForearm.ShieldL:setVisible(false)
                    if firstPersonCheck >= 1 and useKeyHeldDown then
                        models.models.items.ItemShield:setPos(-5, 5, 2)
                        models.models.items.ItemShield:setRot(5, 10, 15)
                    elseif firstPersonCheck >= 1 then
                        models.models.items.ItemShield:setPos(0, 0, 0)
                        models.models.items.ItemShield:setRot(0, 0, 0)
                    end
                return (firstPersonCheck >= 1) and models.models.items.ItemShield or models.models.items.ItemBlank
            end
            -- Only left shield equipped
            if shieldLeftOn then
                models.models.ruby.root.Body.RightArm.RightForearm.ShieldR:setVisible(false)
                models.models.ruby.root.Body.LeftArm.LeftForearm.ShieldL:setVisible(true)
                    if firstPersonCheck >= 1 and useKeyHeldDown then
                        models.models.items.ItemShield:setPos(5, 5, 2)
                        models.models.items.ItemShield:setRot(5, 10, -15)
                    elseif firstPersonCheck >= 1 then
                        models.models.items.ItemShield:setPos(0, 0, 0)
                        models.models.items.ItemShield:setRot(0, 0, 0)
                    end
                return (firstPersonCheck >= 1) and models.models.items.ItemShield or models.models.items.ItemBlank
            end
        end
    end
end


