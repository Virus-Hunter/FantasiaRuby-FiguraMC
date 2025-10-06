--[[--------------------------------------------------------------------------------------
███████╗ ██████╗ ██╗   ██╗██╗███████╗██╗  ██╗██╗   ██╗     █████╗ ██████╗ ██╗
██╔════╝██╔═══██╗██║   ██║██║██╔════╝██║  ██║╚██╗ ██╔╝    ██╔══██╗██╔══██╗██║
███████╗██║   ██║██║   ██║██║███████╗███████║ ╚████╔╝     ███████║██████╔╝██║
╚════██║██║▄▄ ██║██║   ██║██║╚════██║██╔══██║  ╚██╔╝      ██╔══██║██╔═══╝ ██║
███████║╚██████╔╝╚██████╔╝██║███████║██║  ██║   ██║       ██║  ██║██║     ██║
╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚═╝╚══════╝╚═╝  ╚═╝   ╚═╝       ╚═╝  ╚═╝╚═╝     ╚═╝
--]] --------------------------------------------------------------------------------------ANSI Shadow

-- Author: Squishy
-- Discord tag: @mrsirsquishy

-- Version: 1.1.0
-- Legal: ARR

-- Special Thanks to
-- @jimmyhelp for errors and just generally helping me get things working.
-- FOX (@bitslayn) for overhauling annotations and clarity, and for fleshing out some functionality(fr big thanks)

-- IMPORTANT FOR NEW USERS!!! READ THIS!!!

-- Thank you for using SquAPI! Unless you're experienced and wish to actually modify the functionality
-- of this script, I wouldn't recommend snooping around.
-- Don't know exactly what you're doing? this site contains a guide on how to use!(also linked on github):
-- https://mrsirsquishy.notion.site/Squishy-API-Guide-3e72692e93a248b5bd88353c96d8e6c5

-- this SquAPI file does have some mini-documentation on paramaters if you need like a quick reference, but
-- do not modify, and do not copy-paste code from this file unless you are an avid scripter who knows what they are doing.


-- Don't be afraid to ask me for help, just make sure to provide as much info as possible so I or someone can help you faster.






--setup stuff

-- Locates SquAssets, if it exists
-- Written by FOX
---@class SquAssets
local squassets
for _, path in ipairs(listFiles("/", true)) do
  if string.find(path, "SquAssets") then squassets = require(path) end
end
assert(squassets,
  "§4Missing SquAssets file! Make sure to download that from the GitHub too!§c")

---@class SquAPI
local squapi = {}


-- SQUAPI CONTROL VARIABLES AND CONFIG ----------------------------------------------------------
-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- these variables can be changed to control certain features of squapi.


--when true it will automatically tick and update all the functions, when false it won't do that.<br>
--if false, you can run each objects respective tick/update functions on your own - better control.
squapi.autoFunctionUpdates = true


-- FUNCTIONS --------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------






---Contains all registered tails
---@type SquAPI.Tail[]
squapi.tails = {}
squapi.tail = {}
squapi.tail.__index = squapi.tail

---TAIL PHYSICS - this will add physics to your tails when you spin, move, jump, etc. Has the option to have an idle tail movement, and can work with a tail with any number of segments.
---@param tailSegmentList table<ModelPart> The list of each individual tail segment of your tail.
---@param idleXMovement? number Defaults to `15`, how much the tail should sway side to side.
---@param idleYMovement? number Defaults to `5`, how much the tail should sway up and down.
---@param idleXSpeed? number Defaults to `1.2`, how fast the tail should sway side to side.
---@param idleYSpeed? number Defaults to `2`, how fast the tail should sway up and down.
---@param bendStrength? number Defaults to `2`, how strongly the tail moves when you move.
---@param velocityPush? number Defaults to `0`, this will cause the tail to bend when you move forward/backward, good if your tail is bent downward or upward.
---@param initialMovementOffset? number Defaults to `0`, this will offset the tails initial sway, this is good for when you have multiple tails and you want to desync them.
---@param offsetBetweenSegments? number Defaults to `1`, how much each tail segment should be offset from the previous one.
---@param stiffness? number Defaults to `0.005`, how stiff the tail should be.
---@param bounce? number Defaults to `0.9`, how bouncy the tail should be.
---@param flyingOffset? number Defaults to `90`, when flying, riptiding, or swimming, it may look strange to have the tail stick out, so instead it will rotate to this value(so use this to flatten your tail during these movements).
---@param downLimit? number Defaults to `-90`, the lowest each tail segment can rotate.
---@param upLimit? number Defaults to `45`, the highest each tail segment can rotate.
---@return SquAPI.Tail
function squapi.tail:new(tailSegmentList, idleXMovement, idleYMovement, idleXSpeed, idleYSpeed,
                         bendStrength, velocityPush, initialMovementOffset, offsetBetweenSegments,
                         stiffness, bounce, flyingOffset, downLimit, upLimit)
  ---@class SquAPI.Tail
  local self = setmetatable({}, squapi.tail)

  -- INIT -------------------------------------------------------------------------
  --error checker
  self.tailSegmentList = tailSegmentList
	if type(self.tailSegmentList) == "ModelPart" then
		self.tailSegmentList = {self.tailSegmentList}
	end
	assert(type(self.tailSegmentList) == "table", 
	"your tailSegmentList table seems to to be incorrect")
	
  self.berps = {}
  self.targets = {}
  self.stiffness = stiffness or .005
  self.bounce = bounce or .9
  self.downLimit = downLimit or -90
  self.upLimit = upLimit or 45
  if type(self.tailSegmentList[2]) == "number" then --ah I see you stumbled across my custom tail list creator, if you curious ask me. tail must be >= 3 segments. Naming: tail, tailseg, tailseg2, tailseg3..., tailtip
      local range = self.tailSegmentList[2]
      local str = ""
      if self.tailSegmentList[3] then
        str = self.tailSegmentList[3]
      end

      self.tailSegmentList[2] = self.tailSegmentList[1][str .. "tailseg"]
      for i = 2, range - 2 do
        self.tailSegmentList[i + 1] = self.tailSegmentList[i][str .. "tailseg" .. i]
      end
      self.tailSegmentList[range] = self.tailSegmentList[range - 1][str .. "tailtip"]
  end

  for i = 1, #self.tailSegmentList do
      assert(self.tailSegmentList[i]:getType() == "GROUP",
      "§4The tail segment at position "..i.." of the table is not a group. The tail segments need to be groups that are nested inside the previous segment.§c")
      self.berps[i] = {squassets.BERP:new(self.stiffness, self.bounce), squassets.BERP:new(self.stiffness, self.bounce, self.downLimit, self.upLimit)}
      self.targets[i] = {0, 0}
  end

  self.tailSegmentList = tailSegmentList
  self.idleXMovement = idleXMovement or 15
  self.idleYMovement = idleYMovement or 5
  self.idleXSpeed = idleXSpeed or 1.2
  self.idleYSpeed = idleYSpeed or 2
  self.bendStrength = bendStrength or 2
  self.velocityPush = velocityPush or 0
  self.initialMovementOffset = initialMovementOffset or 0
  self.flyingOffset = flyingOffset or 90
  self.offsetBetweenSegments = offsetBetweenSegments or 1


  -- CONTROL -------------------------------------------------------------------------

  self.enabled = true
  function self:toggle()
    self.enabled = not self.enabled
  end
  function self:disable()
      self.enabled = false
  end
  function self:enable()
      self.enabled = true
  end
  function self:zero()
    for _, v in pairs(self.tailSegmentList) do
      v:setOffsetRot(0, 0, 0)
    end
  end

  -- UPDATES -------------------------------------------------------------------------

self.currentBodyRot = 0
self.oldBodyRot = 0
self.bodyRotSpeed = 0

  function self:tick()
      if self.enabled then
          self.oldBodyRot = self.currentBodyRot
          self.currentBodyRot = player:getBodyYaw()
          self.bodyRotSpeed = math.max(math.min(self.currentBodyRot-self.oldBodyRot, 20), -20)

          local time = world.getTime()
          local vel = squassets.forwardVel()
          local yvel = squassets.verticalVel()
          local svel = squassets.sideVel()
          local bendStrength = self.bendStrength/(math.abs((yvel*30))+vel*30 + 1)
          local pose = player:getPose()
      
          for i = 1, #self.tailSegmentList do
              self.targets[i][1] = math.sin((time * self.idleXSpeed)/10 - (i * self.offsetBetweenSegments)) * self.idleXMovement
              self.targets[i][2] = math.sin((time * self.idleYSpeed)/10 - (i * self.offsetBetweenSegments) + self.initialMovementOffset) * self.idleYMovement

              self.targets[i][1] = self.targets[i][1] + self.bodyRotSpeed*self.bendStrength + svel*self.bendStrength*40
              self.targets[i][2] = self.targets[i][2] + yvel * 15 * self.bendStrength - vel*self.bendStrength*15*self.velocityPush

              if i == 1 then
                  if pose == "FALL_FLYING" or pose == "SWIMMING" or player:riptideSpinning() then
                      self.targets[i][2] = self.flyingOffset
                  end	
              end  
          end
      end
  end

  ---Run render function on tail
  ---@param dt number Tick delta
  function self:render(dt, _)
    if self.enabled then
      local pose = player:getPose()
      if pose ~= "SLEEPING" then
        for i, tail in ipairs(self.tailSegmentList) do
          tail:setOffsetRot(
            self.berps[i][2]:berp(self.targets[i][2], dt),
            self.berps[i][1]:berp(self.targets[i][1], dt),
            0
          )
        end  
      end
    end
  end


  table.insert(squapi.tails, self)
  return self
end

---Contains all registered ears
---@type SquAPI.Ear[]
squapi.ears = {}
squapi.ear = {}
squapi.ear.__index = squapi.ear

---EAR PHYSICS - this adds physics to your ear(s) when you move, and has options for different ear types.
---@param leftEar ModelPart The left ear's model path.
---@param rightEar? ModelPart The right ear's model path, if you don't have a right ear, just leave this blank or set to nil.
---@param rangeMultiplier? number Defaults to `1`, how far the ears should rotate with your head.
---@param horizontalEars? boolean Defaults to `false`, if you have elf-like ears(ears that stick out horizontally), set this to true.
---@param bendStrength? number Defaults to `2`, how much the ears should move when you move.
---@param doEarFlick? boolean Defaults to `true`, whether or not the ears should randomly flick.
---@param earFlickChance? number Defaults to `400`, how often the ears should flick in ticks, timer is random between 0 to n ticks.
---@param earStiffness? number Defaults to `0.1`, how stiff the ears should be.
---@param earBounce? number Defaults to `0.8`, how bouncy the ears should be.
---@return SquAPI.Ear
function squapi.ear:new(leftEar, rightEar, rangeMultiplier, horizontalEars, bendStrength, doEarFlick,
                        earFlickChance, earStiffness, earBounce)
  ---@class SquAPI.Ear
  local self = setmetatable({}, squapi.ear)

  -- INIT -------------------------------------------------------------------------

  assert(leftEar,
    "§4The first ear's model path is incorrect.§c")
  self.leftEar = leftEar
  self.rightEar = rightEar
  self.horizontalEars = horizontalEars
  self.rangeMultiplier = rangeMultiplier or 1
  if self.horizontalEars then self.rangeMultiplier = self.rangeMultiplier / 2 end
  self.bendStrength = bendStrength or 2
  earStiffness = earStiffness or 0.1
  earBounce = earBounce or 0.8

  if doEarFlick == nil then doEarFlick = true end
  self.doEarFlick = doEarFlick
  self.earFlickChance = earFlickChance or 400

  -- CONTROL -------------------------------------------------------------------------

  self.enabled = true
  ---Toggle this ear on or off
  function self:toggle()
    self.enabled = not self.enabled
  end

  ---Disable this ear
  function self:disable()
    self.enabled = false
  end

  ---Enable this ear
  function self:enable()
    self.enabled = true
  end

  ---Sets if this ear is enabled
  ---@param bool boolean
  function self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    self.enabled = bool
  end

  -- UPDATES -------------------------------------------------------------------------

  self.eary = squassets.BERP:new(earStiffness, earBounce)
  self.earx = squassets.BERP:new(earStiffness, earBounce)
  self.earz = squassets.BERP:new(earStiffness, earBounce)
  self.targets = { 0, 0, 0 }
  self.oldpose = "STANDING"

  ---Run tick function on ear
  function self:tick()
    if self.enabled then
      local vel = math.min(math.max(-0.75, squassets.forwardVel()), 0.75)
      local yvel = math.min(math.max(-1.5, squassets.verticalVel()), 1.5) * 5
      local svel = math.min(math.max(-0.5, squassets.sideVel()), 0.5)
      local headrot = squassets.getHeadRot()
      local bend = self.bendStrength
      if headrot[1] < -22.5 then bend = -bend end

      --gives the ears a short push when crouching/uncrouching
      local pose = player:getPose()
      if pose == "CROUCHING" and self.oldpose == "STANDING" then
        self.eary.vel = self.eary.vel + 5 * self.bendStrength
      elseif pose == "STANDING" and self.oldpose == "CROUCHING" then
        self.eary.vel = self.eary.vel - 5 * self.bendStrength
      end
      self.oldpose = pose

      --main physics
      if self.horizontalEars then
        local rot = 10 * bend * (yvel + vel * 10) + headrot[1] * self.rangeMultiplier
        local addrot = headrot[2] * self.rangeMultiplier
        self.targets[2] = rot + addrot
        self.targets[3] = -rot + addrot
      else
        self.targets[1] = headrot[1] * self.rangeMultiplier + 2 * bend * (yvel + vel * 15)
        self.targets[2] = headrot[2] * self.rangeMultiplier - svel * 100 * self.bendStrength
        self.targets[3] = self.targets[2]
      end

      --ear flicking
      if self.doEarFlick then
        if math.random(0, self.earFlickChance) == 1 then
          if math.random(0, 1) == 1 then
            self.earx.vel = self.earx.vel + 50
          else
            self.earz.vel = self.earz.vel - 50
          end
        end
      end
    else
      leftEar:setOffsetRot(0, 0, 0)
      rightEar:setOffsetRot(0, 0, 0)
    end
  end

  ---Run render function on ear
  ---@param dt number Tick delta
  function self:render(dt, _)
    if self.enabled then
      self.eary:berp(self.targets[1], dt)
      self.earx:berp(self.targets[2], dt)
      self.earz:berp(self.targets[3], dt)

      local rot3 = self.earx.pos / 4
      local rot3b = self.earz.pos / 4

      if self.horizontalEars then
        local y = self.eary.pos / 4
        self.leftEar:setOffsetRot(y, self.earx.pos / 3, rot3)
        if self.rightEar then
          self.rightEar:setOffsetRot(y, self.earz.pos / 3, rot3b)
        end
      else
        self.leftEar:setOffsetRot(self.eary.pos, rot3, rot3)
        if self.rightEar then
          self.rightEar:setOffsetRot(self.eary.pos, rot3b, rot3b)
        end
      end
    end
  end

  table.insert(squapi.ears, self)
  return self
end



---Contains all registered smooth heads
---@type SquAPI.SmoothHead[]
squapi.smoothHeads = {}
squapi.smoothHead = {}
squapi.smoothHead.__index = squapi.smoothHead

---SMOOTH HEAD - Mimics a vanilla player head, but smoother and with some extra life. Can also do smooth Torsos and Smooth Necks!
---@param element ModelPart|table<ModelPart> The head element that you wish to effect. If you want a smooth neck or torso, instead of a single element, input a table of head elements(imagine it like {element1, element2, etc.}). this will apply the head rotations to each of these.
---@param strength? number|table<number> Defaults to `1`, the target rotation is multiplied by this factor. If you want a smooth neck or torso, instead of an single number, you can put in a table(imagine it like {strength1, strength2, etc.}). this will apply each strength to each respective element.(make sure it is the same length as your element table)
---@param tilt? number Defaults to `0.1`, for context the smooth head applies a slight tilt to the head as it's rotated toward the side, this controls the strength of that tilt.
---@param speed? number Defaults to `1`, how fast the head will rotate toward the target rotation.
---@param keepOriginalHeadPos? boolean|number Defaults to `true`, when true the heads position will follow the vanilla head position. For example when crouching the head will shift down to follow. If set to a number, changes which modelpart gets moved when doing actions such as crouching. this should normally be set to the neck modelpart.
---@param fixPortrait? boolean Defaults to `true`, sets whether or not the portrait should be applied if a group named "head" is found in the elements list
function squapi.smoothHead:new(element, strength, tilt, speed, keepOriginalHeadPos, fixPortrait)
  ---@class SquAPI.SmoothHead
  local self = setmetatable({}, squapi.smoothHead)

  -- INIT -------------------------------------------------------------------------
  if type(element) == "ModelPart" then
    assert(element, "§4Your model path for smoothHead is incorrect.§c")
    element = { element }
  end
  assert(type(element) == "table", "§4your element table seems to to be incorrect.§c")

  for i = 1, #element do
    assert(element[i]:getType() == "GROUP",
      "§4The head element at position " ..
      i ..
      " of the table is not a group. The head elements need to be groups that are nested inside one another to function properly.§c")
    assert(element[i], "§4The head segment at position " .. i .. " is incorrect.§c")
    element[i]:setParentType("NONE")
  end
  self.element = element

  self.strength = strength or 1
  if type(self.strength) == "number" then
    local strengthDiv = self.strength / #element
    self.strength = {}
    for i = 1, #element do
      self.strength[i] = strengthDiv
    end
  end

  self.tilt = tilt or 0.1
  if keepOriginalHeadPos == nil then keepOriginalHeadPos = true end
  self.keepOriginalHeadPos = keepOriginalHeadPos
  self.headRot = vec(0, 0, 0)
  self.offset = vec(0, 0, 0)
  self.speed = (speed or 1) / 2

  if fixPortrait == nil then fixPortrait = true end
  if fixPortrait then
    if type(element) == "table" then
      for _, part in ipairs(element) do
        if squassets.caseInsensitiveFind(part, "head") then
          part:copy("_squapi-portrait"):moveTo(models):setParentType("Portrait")
              :setPos(-part:getPivot())
          break
        end
      end
    elseif type(element) == "ModelPart" and element:getType() == "GROUP" then
      if squassets.caseInsensitiveFind(element, "head") then
        element:copy("_squapi-portrait"):moveTo(models):setParentType("Portrait")
            :setPos(-element:getPivot())
      end
    end
  end

  -- CONTROL -------------------------------------------------------------------------


  ---Applies an offset to the heads rotation to more easily modify it. Applies as a vector.(for multisegments it will modify the target rotation)
  ---@param xRot number X rotation
  ---@param yRot number Y rotation
  ---@param zRot number Z rotation
  function self:setOffset(xRot, yRot, zRot)
    self.offset = vec(xRot, yRot, zRot)
  end

  self.enabled = true
  ---Toggles this smooth head on or off
  function self:toggle()
    self.enabled = not self.enabled
  end

  ---Disables this smooth head
  function self:disable()
    self.enabled = false
  end

  ---Enables this smooth head
  function self:enable()
    self.enabled = true
  end

  ---Sets if this smooth head is enabled
  ---@param bool boolean
  function self:setEnabled(bool)
    assert(type(bool) == "boolean",
      "§4setEnabled must be set to a boolean.§c")
    self.enabled = bool
  end

  ---Resets this smooth head's position and rotation to their initial values
  function self:zero()
    for _, v in ipairs(self.element) do
      v:setPos(0, 0, 0)
      v:setOffsetRot(0, 0, 0)
      self.headRot = vec(0, 0, 0)
    end
  end

  -- UPDATE -------------------------------------------------------------------------

  ---Run tick function on smooth head
  function self:tick()
    if self.enabled then
      local vanillaHeadRot = squassets.getHeadRot()

      self.headRot[1] = self.headRot[1] + (vanillaHeadRot[1] - self.headRot[1]) * self.speed
      self.headRot[2] = self.headRot[2] + (vanillaHeadRot[2] - self.headRot[2]) * self.speed
      self.headRot[3] = self.headRot[2] * self.tilt
    end
  end

  ---Run render function on smooth head
  ---@param dt number Tick delta
  ---@param context Event.Render.context
  function self:render(dt, context)
    if self.enabled then
      dt = dt / 5
      for i in ipairs(self.element) do
        local c = self.element[i]:getOffsetRot()
        local target = (self.headRot * self.strength[i]) - self.offset / #self.element
        self.element[i]:setOffsetRot(
          math.lerp(c[1], target[1], dt), 
          math.lerp(c[2], target[2], dt),
          math.lerp(c[3], target[3], dt)
        )

        -- Better Combat SquAPI Compatibility created by @jimmyhelp and @foxy2526 on Discord
        if renderer:isFirstPerson() and context == "RENDER" then
          self.element[i]:setVisible(false)
        else
          self.element[i]:setVisible(true)
        end
      end

      if self.keepOriginalHeadPos then
        self.element
            [type(self.keepOriginalHeadPos) == "number" and self.keepOriginalHeadPos or #self.element]
            :setPos(-vanilla_model.HEAD:getOriginPos())
      end
    end
  end

  table.insert(squapi.smoothHeads, self)
  return self
end
-- UPDATES ALL SQUAPI FEATURES --------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------

if squapi.autoFunctionUpdates then
  function events.tick()
    for _, v in ipairs(squapi.smoothHeads) do v:tick() end
    for _, v in ipairs(squapi.ears) do v:tick() end
    for _, v in ipairs(squapi.tails) do v:tick() end
  end

  function events.render(dt, context)
    for _, v in ipairs(squapi.smoothHeads) do v:render(dt, context) end
    for _, v in ipairs(squapi.ears) do v:render(dt, context) end
    for _, v in ipairs(squapi.tails) do v:render(dt, context) end
  end
end

return squapi
