--[[
    TailFX - Procedural Physics Module
    Adds procedural swaying and physics-based momentum to model parts (tails, ears, etc.).
    Designed to emulate SquAPI's tail features
    
    HOW TO IMPLEMENT:
    1.  Place 'TailFX.lua' in your avatar folder.
    2.  In your main script, require the module:
        local TailFX = require("TailFX")
    3.  Initialize it with your model parts (as many as you want):
        TailFX:init(part1, part2, part3, ...)
    4.  In your events.render function, call the update:
        TailFX:update(delta, context)

    Feel free to use this in your avatars, no credit needed
    But adon't expect any support
]]--

local TailFX = {}

-- State Variables
local parts = {} -- List of {api = PartAPI, rot = Vector3, vel = Vector3}
local lastBodyYaw = 0
local timer = 0
local initialized = false

-- Physics Constants
local STIFFNESS = 0.2
local DRAG = 0.8
local SWAY_SPEED = 0.03
local SWAY_MAGNITUDE = 15
local OFFSET = 1.5

--- Initializes the TailFX module with as many model parts as you like.
function TailFX:init(...)
    parts = {}
    local input = {...}
    for i, p in ipairs(input) do
        parts[i] = {
            api = p,
            rot = vec(0, 0, 0),
            vel = vec(0, 0, 0)
        }
    end
end

--- Sets the stiffness of the physics.
function TailFX:setStiffness(value)
    STIFFNESS = value
end

--- Sets the drag (friction) of the movement.
function TailFX:setDrag(value)
    DRAG = value
end

--- Sets the speed of the natural sway.
function TailFX:setSwaySpeed(value)
    SWAY_SPEED = value
end

--- Sets the magnitude (width) of the sway.
function TailFX:setSwayMagnitude(value)
    SWAY_MAGNITUDE = value
end

--- Sets the offset between segments.
function TailFX:setOffset(value)
    OFFSET = value
end

--- Internal physics applier
local function applyPhysics(currentRot, currentVel, targetRot, dt)
    -- Wrap yaw difference
    local diffYaw = (targetRot.y - currentRot.y + 180) % 360 - 180
    local diffPitch = targetRot.x - currentRot.x
    
    -- Apply force (stiffness)
    currentVel.y = currentVel.y + diffYaw * STIFFNESS * dt
    currentVel.x = currentVel.x + diffPitch * STIFFNESS * dt
    
    -- Apply drag using stable exponential decay
    local dragFactor = math.exp(-DRAG * dt)
    currentVel.y = currentVel.y * dragFactor
    currentVel.x = currentVel.x * dragFactor
    
    -- Apply velocity to position
    currentRot.y = currentRot.y + currentVel.y * dt
    currentRot.x = currentRot.x + currentVel.x * dt
    
    return currentRot, currentVel
end

--- Processes physics. Call this in events.render().
function TailFX:update(delta, context)
    if #parts == 0 or not player:isLoaded() then return end

    -- Physics speed scale
    local rawDt = 20 / math.max(client:getFPS(), 1)
    local dt = math.min(rawDt, 1.2)
    
    local bodyYaw = player:getBodyYaw()
    
    if not initialized then
        lastBodyYaw = bodyYaw
        initialized = true
        return 
    end

    -- If stiffness is 0, reset
    if STIFFNESS <= 0 then
        for _, p in ipairs(parts) do
            p.rot = vec(0, 0, 0)
            p.vel = vec(0, 0, 0)
            p.api:setOffsetRot(0, 0, 0)
        end
        lastBodyYaw = bodyYaw
        return
    end

    timer = timer + SWAY_SPEED * dt
    
    if rawDt > 1.5 then
        lastBodyYaw = bodyYaw
    end

    local yawSpeed = (bodyYaw - lastBodyYaw + 180) % 360 - 180
    lastBodyYaw = bodyYaw

    if math.abs(yawSpeed) > 100 then yawSpeed = 0 end

    local pVel = player:getVelocity()
    local lookDir = player:getLookDir()
    local forwardVel = pVel:dot(vec(lookDir.x, 0, lookDir.z):normalize())
    local sideVel = pVel:dot(vec(-lookDir.z, 0, lookDir.x):normalize())

    for i, p in ipairs(parts) do
        local segmentOffset = (i - 1) * OFFSET
        local momentumFactor = 1 / (2 ^ (i - 1)) -- 1, 0.5, 0.25...
        
        -- Target Calc
        local targetYaw = (math.sin(timer - segmentOffset) * SWAY_MAGNITUDE) 
                        - (yawSpeed * 2.0 * momentumFactor) 
                        - (sideVel * 40 * momentumFactor)
        
        local targetPitch = (math.sin((timer - segmentOffset) * 0.5) * (5 * momentumFactor)) 
                          - (forwardVel * 20 * momentumFactor) 
                          + (pVel.y * 15 * momentumFactor)

        -- Apply physics
        p.rot, p.vel = applyPhysics(p.rot, p.vel, vec(targetPitch, targetYaw, 0), dt)

        -- Error catcher
        if p.rot.x ~= p.rot.x or p.vel.x ~= p.vel.x then
            p.rot = vec(0,0,0) p.vel = vec(0,0,0)
        end

        -- Apply rotations
        p.api:setOffsetRot(p.rot.x, p.rot.y, 0)
    end
end

return TailFX
