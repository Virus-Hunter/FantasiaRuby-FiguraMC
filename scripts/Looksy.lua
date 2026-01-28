--[[
    Looksy - Dynamic Eye Tracking
    
    HOW TO IMPLEMENT:
    1.  Place 'Looksy.lua' in your avatar folder.
    2.  In your main script (e.g., script.lua), require the module:
        local Looksy = require("Looksy")
    3.  Ensure your Blockbench model has two animations:
        - One where character's eyes move from (character's) Left (0%) to (character's) Right (100%).
        - One where character's eyes move from Up (0%) to Down (100%).
    4.  In your events.tick function, call:
        Looksy:tick()
    5.  (Optional) Adjust tracking strength dynamically (e.g., disable for certain states):
        Looksy:setStrength(0.0) -- Disable tracking
        Looksy:setStrength(1.0) -- Full tracking
    
    Feel free to use this in your avatars, no credit needed
    But don't expect any support
]]--

local Looksy = {}

-- CONFIGURATION
local MAX_LOOK_YAW = 60     -- Max degrees the eyes track horizontally
local MAX_LOOK_PITCH = 120   -- Max degrees the eyes track vertically
local SMOOTHNESS = 0.3      -- 0.0 = instant, 0.9 = very smooth (simple lerp)
local LOOK_STRENGTH = 1.0    -- 1.0 = full movement, 0.5 = half movement, 0.0 = no movement

-- STATE
local current_yaw = 0
local current_pitch = 0
local horiLookAnim = nil    -- Horizontal look animation
local vertLookAnim = nil    -- Vertical look animation

--- Call this in the main file to set the eye animations. 
function Looksy:setEyeAnims(horiLook, vertLook) -- First parameter: horizontal look animation, Second parameter: vertical look animation
    horiLookAnim = horiLook
    vertLookAnim = vertLook
end



--- Sets the tracking strength of the eyes.
-- @param strength number: 0.0 (off) to 1.0 (full strength).
function Looksy:setStrength(strength)
    LOOK_STRENGTH = strength
end

--- Returns current tracking strength.
function Looksy:getStrength()
    return LOOK_STRENGTH
end

--- Sets the maximum horizontal degrees the eyes can track.
function Looksy:setMaxYaw(value)
    MAX_LOOK_YAW = value
end

--- Sets the maximum vertical degrees the eyes can track.
function Looksy:setMaxPitch(value)
    MAX_LOOK_PITCH = value
end

--- Sets the smoothness of the eye movement (0.0 to 0.95).
function Looksy:setSmoothness(value)
    SMOOTHNESS = math.clamp(value, 0, 0.95)
end

--- Processes the eye tracking logic. Call this in events.tick().
function Looksy:tick()
    if not player:isLoaded() then return end
    
    local playerRot = player:getRot()
    local bodyYaw = player:getBodyYaw() % 360
    local headYaw = playerRot.y % 360
    local headPitch = playerRot.x -- Pitch is usually -90 (up) to 90 (down)

    -- Calculate shortest difference between head and body
    local yawDelta = (headYaw - bodyYaw + 180) % 360 - 180
    
    -- DETECTION & SMOOTHING
    local yawTarget = current_yaw
    local pitchTarget = current_pitch

    -- If strength is 0, return to center. 
    -- If camera is out of range, hold last valid position (prevents edge-snapping).
    if LOOK_STRENGTH <= 0 then
        yawTarget = 0
        pitchTarget = 0
    elseif math.abs(yawDelta) <= MAX_LOOK_YAW then
        yawTarget = yawDelta
        pitchTarget = math.clamp(headPitch, -MAX_LOOK_PITCH, MAX_LOOK_PITCH)
    end

    current_yaw = math.lerp(current_yaw, yawTarget, 1 - SMOOTHNESS)
    current_pitch = math.lerp(current_pitch, pitchTarget, 1 - SMOOTHNESS)

    -- ANIMATION MAPPING
    -- Map ranges [-MAX, MAX] to [0, 1] for animation time (0.5 is centered)
    local horizontalTime = 0.5 + ((current_yaw / MAX_LOOK_YAW) * 0.5 * LOOK_STRENGTH)
    local verticalTime = 0.5 + ((current_pitch / MAX_LOOK_PITCH) * 0.5 * LOOK_STRENGTH)

    -- APPLY TO ANIMATIONS
    -- Assuming animations are available in the global table 'charAnim' 
    if horiLookAnim then
        horiLookAnim:play()
        horiLookAnim:setSpeed(0) -- Freeze playback to use setTime
        horiLookAnim:setTime(horizontalTime * horiLookAnim:getLength())
    end
    
    if vertLookAnim then
        vertLookAnim:play()
        vertLookAnim:setSpeed(0) 
        vertLookAnim:setTime(verticalTime * vertLookAnim:getLength())
    end
end

return Looksy
