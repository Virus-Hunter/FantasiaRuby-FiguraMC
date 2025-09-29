-- Auto generated script file --
--API Docs
--https://applejuiceyy.github.io/figs/latest/

--hide vanilla model
vanilla_model.PLAYER:setVisible(false)

--hide vanilla armor model
vanilla_model.ARMOR:setVisible(false)
--re-enable the helmet item
vanilla_model.HELMET_ITEM:setVisible(true)

--hide vanilla cape model
vanilla_model.CAPE:setVisible(false)

--hide vanilla elytra model
vanilla_model.ELYTRA:setVisible(false)

--API stuff
local squapi = require("SquAPI")
require("GSAnimBlend")
local anims = require("EZAnims")

--Variable to point to the animations. In this case the animations are in the main character file
charAnim = animations["models.ruby"]

--animation blend settings
anims.autoBlend = false
anims:setOneJump(true)
animModel = anims:addBBModel(charAnim)
--sets all default blend times to 0
animModel:setBlendTimes(0.001)
--individual animation blend times
charAnim.idle:setBlendTime(0.001,0.001)
charAnim.jumpup:setBlendTime(0.001,3)
charAnim.jumpdown:setBlendTime(3,0)
charAnim.walkjumpup:setBlendTime(0.001,3)
charAnim.walkjumpdown:setBlendTime(3,0)
charAnim.walk:setBlendTime(4,3)
charAnim.FP_No_Bob:setBlendTime(4,3)
charAnim.walkback:setBlendTime(2,2)
charAnim.sprintjumpup:setBlendTime(0.001,3)
charAnim.sprintjumpdown:setBlendTime(3,0)
charAnim.sprint:setBlendTime(4,2)
charAnim.crouch:setBlendTime(2,2)
charAnim.water:setBlendTime(0.001,0.001)
charAnim.waterwalk:setBlendTime(4,3)
charAnim.waterwalkback:setBlendTime(4,3)
charAnim.waterup:setBlendTime(4,3)
charAnim.swim:setBlendTime(4,4)
charAnim.idle_sword:setBlendTime(4,3)
charAnim.walk_sword:setBlendTime(4,3)
charAnim.jumpup_sword:setBlendTime(0.001,3)
charAnim.walkjumpup_sword:setBlendTime(0.001,3)
charAnim.sprint_sword:setBlendTime(4,3)
charAnim.sprintjumpup_sword:setBlendTime(0.001,3)
--charAnim.water_sword:setBlendTime(0.001,0.001)
charAnim.waterwalk_sword:setBlendTime(4,3)
--charAnim.waterwalkback_sword:setBlendTime(4,3)
charAnim.waterup_sword:setBlendTime(4,3)
charAnim.swim_sword:setBlendTime(4,4)
charAnim.attackR:setBlendTime(1,0)
charAnim.mineR:setBlendTime(1,0)
charAnim.elytra:setBlendTime(3,3)
charAnim.elytradown:setBlendTime(3,3)
charAnim.fly:setBlendTime(3,3)


charAnim.FP_No_Bob:setOverride(true)
charAnim.jumpdown:setOverride(true)
charAnim.walkjumpdown:setOverride(true)
charAnim.sprintjumpdown:setOverride(true)
charAnim.idle:setOverride(true)
charAnim.idle_sword:setOverride(true)
charAnim.walk_sword:setOverride(true)
charAnim.jumpup_sword:setOverride(true)
charAnim.walkjumpup_sword:setOverride(true)
charAnim.sprintjumpup_sword:setOverride(true)
charAnim.attackR:setOverride(true)
charAnim.mineR:setOverride(true)
charAnim.sit:setOverride(true)
charAnim.elytra:setOverride(true)
charAnim.elytradown:setOverride(true)
charAnim.fly:setOverride(true)

charAnim.attackR:setPriority(2)
charAnim.mineR:setPriority(3)

local function itemStateCheck(str, words)
    for _, word in ipairs(words) do
        if string.find(str, word, 1, true) then
            return true
        end
    end
    return false
end

local function isHoldingSword()
    local keyWordResult = false
    local heldItem = player:getHeldItem()
    --check to see if item's ID is a sword or spear
    keywordList = {"sword", "knife", "dagger", "blade", "katana", "rapier", "kunai", "sabre", "saber", "scimitar", "shamshir", "estoc", "spear", "lance", "polearm", "trident", "falchion", "javelin", "machete", "pike", "glaive", "halberd", "sickle", "scythe", "knives"}
    if itemStateCheck(heldItem.id, keywordList) == true then
        keyWordResult = true
    end
    --check to see if it's a non-weapon item that might contain one of the above words
    keywordList = {"book", "template", "plan", "blueprint", "recipe", "raw", "cooked"}
    if itemStateCheck(heldItem.id, keywordList) == true then
        keyWordResult = false
    end
    return keyWordResult
        
    
end


--fix crouching offset
crouchOffset = 0.0
crouchTargetTransition = 0.8
crouchTargetOffset = 0.0


function events.tick()
    --log(player:getPose())
    if player:getPose() == "CROUCHING" and not player:getPose() == "FALL_FLYING" then
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
            if charAnim["attackR"]:isPlaying() or charAnim["mineR"]:isPlaying() then
                models.models.ruby.root.Body:setRot(-10,0,-20)
                models.models.ruby.root.Body:setPos(0,-crouchOffset*2,-1)
                models.models.ruby.root.Body.Neck:setPos(0,0,-1)
                models.models.ruby.root.Body.Neck.Head:setPos(0,0,-1)
            elseif charAnim["mineR"]:isPlaying() then
                models.models.ruby.root.Body:setPos(0,-crouchOffset*2,-1)
                models.models.ruby.root.Body.Neck:setPos(0,0,-1)
                models.models.ruby.root.Body.Neck.Head:setPos(0,0,-1)
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

    if player:getPose() == "FALL_FLYING" or charAnim["fly"]:isPlaying() then
        models.models.ruby.root.Body.Glider:setVisible(true)
        vanilla_model.HELD_ITEMS:setVisible(false)
    else
        models.models.ruby.root.Body.Glider:setVisible(false)
        vanilla_model.HELD_ITEMS:setVisible(true)
    
    end

    --print(player:getHeldItem())

    --sword state
    if isHoldingSword() == true then
        
        animModel:setState("sword")
    else
        animModel:setState()
        
    end

    
    local flightSpeed = player:getVelocity():length()
    if flightSpeed >= 1.0 then
        flightSpeed = 1.0
    end
    if charAnim["fly"]:isPlaying() and flightSpeed <= 0.01 then
        flightSpeed = 0.01
    end

    charAnim.elytra:setSpeed(flightSpeed)
    charAnim.elytradown:setSpeed(flightSpeed)
    charAnim.fly:setSpeed(flightSpeed)
    
end

local firstPersonBobToggled = (true)
--swap ruby's animated arm with a static arm when in first person (this is only viewable for you, other players will see animated arms as usual)
function events.render(_, ctx)
    if ctx == "FIRST_PERSON" then
        models.models.ruby.root.FPArms:setVisible(true)
        models.models.ruby.root.Body.RightArm:setVisible(false)
        models.models.ruby.root.Body.LeftArm:setVisible(false)
    else
        models.models.ruby.root.FPArms:setVisible(false)
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


--this function swaps between her outfit and her skivvies for the toggle clothes action
local function setClothesVisibility(state)
    for index,clothesPiece in pairs(clothes) do
        clothesPiece:setVisible(not state)
    end
    for index,bodyPiece in pairs(NoClothesParts) do
        bodyPiece:setVisible(state)
    end
end

--this function just disables her skivvy-specific parts and makes sure her pants are on, this function runs once on startup
function SetNoClothesPartsVisibility()
    for index,clothesPiece in pairs(clothes) do
        clothesPiece:setVisible(true)
    end
    for index,bodyPiece in pairs(NoClothesParts) do
        bodyPiece:setVisible(false)
    end
end
SetNoClothesPartsVisibility()


--Toggle 1stPerson Arm Bobbing (This is separate from movement bobbing in options)
function set1stPersonBob(state)
    firstPersonBobToggled = (state)
    if firstPersonBobToggled then
        charAnim.FP_No_Bob:setOverride(true)
        charAnim.FP_No_Bob:setPriority(4)
        charAnim.FP_No_Bob:play()
    else
        charAnim.FP_No_Bob:setOverride(false)
        charAnim.FP_No_Bob:stop()
    end
end

function setCustomItemsToggle(state)
    customItemsToggle = (not state)
end


actionOffColor = vectors.hexToRGB('#305163')
actionHoverColor = vectors.hexToRGB('#4fc1ff')
actionOnColor = vectors.hexToRGB('#c3dbe8')

--Action Wheel
local mainPage = action_wheel:newPage()
action_wheel:setPage(mainPage)

--Toggle Clothes action (Switches between her default outfit and her skivvies)

    
local toggleFPBob = mainPage:newAction()
    :title("Toggle 1st Person Arm Bobbing")
    :setTexture(textures["textures.iconTex"], 0 ,0, 16, 16, 1.5)
    :setToggleTexture(textures["textures.iconTex"], 16 ,0, 16, 16, 1.5)
    :setColor(actionOnColor)
    :setHoverColor(actionHoverColor)
    :setToggleColor(actionOffColor)
    :setOnToggle(set1stPersonBob)

local toggleClothesAction = mainPage:newAction()
    :title("Toggle Clothes")
    :setTexture(textures["textures.iconTex"], 32 ,0, 16, 16, 1.5)
    :setToggleTexture(textures["textures.iconTex"], 48 ,0, 16, 16, 1.5)
    :setColor(actionOnColor)
    :setHoverColor(actionHoverColor)
    :setToggleColor(actionOffColor)
    :setOnToggle(setClothesVisibility)

local toggleCustomItems = mainPage:newAction()
    :title("Toggle Custom Items")
    :setTexture(textures["textures.iconTex"], 0 ,16, 16, 16, 1.5)
    :setToggleTexture(textures["textures.iconTex"], 16 ,16, 16, 16, 1.5)
    :setColor(actionOnColor)
    :setHoverColor(actionHoverColor)
    :setToggleColor(actionOffColor)
    :setOnToggle(setCustomItemsToggle)


customItemsToggle = (true)
function events.item_render(item)
    if item.id:find("sword") then
        if customItemsToggle == true then
            return models.models.items.ItemSword
        end
    end
end


