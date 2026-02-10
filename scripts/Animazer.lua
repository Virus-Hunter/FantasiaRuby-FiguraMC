-- Animazer
-- Module for doing a lot of extra animation stuff

local Animazer = {}

-- Internal state
Animazer.currentState = ""
Animazer.lockedAnims = {}   -- External locks
Animazer.slotOverrides = {} -- Internal slot mapping { anim, enabled, savedList }
Animazer.lastActiveState = {} -- Track state transitions to prevent stutter

local animModel = nil
local charAnim = nil

-- Helpers
local function pcallSafe(fn, ...)
    if not fn then return end
    local ok, res = pcall(fn, ... )
    if not ok then return nil end
    return res
end

local function resolveAnimRef(ref)
    if not ref then return nil end
    if type(ref) == "string" then
        return charAnim and charAnim[ref] or nil
    elseif type(ref) == "table" then
        return ref
    else
        return nil
    end
end

local function unlockAnimation(anim)
    if not anim then return end
    Animazer.lockedAnims[anim] = nil
end

-- Initialization
function Animazer:init(model, animationsTable, options)
    animModel = model
    charAnim = animationsTable
    return self
end

-- Priority and basic overrides
function Animazer:setPriority(anims, priority)
    if not charAnim then return end
    if type(anims) ~= "table" then anims = {anims} end
    for _, name in ipairs(anims) do
        local a = resolveAnimRef(name)
        if a then pcallSafe(function() if a.setPriority then a:setPriority(priority) end end) end
    end
end

function Animazer:setOverride(anims, state)
    if not charAnim then return end
    if type(anims) ~= "table" then anims = {anims} end
    for _, name in ipairs(anims) do
        local a = resolveAnimRef(name)
        if a then pcallSafe(function() if a.setOverride then a:setOverride(state) end end) end
    end
end

-- Slot-based overrides
function Animazer:setSlotOverride(slot, animRef)
    local a = resolveAnimRef(animRef)
    local cfg = self.slotOverrides[slot]
    if not cfg then
        self.slotOverrides[slot] = { anim = a, enabled = false, savedList = nil }
    else
        if cfg.anim ~= a then
            -- Stop the OLD animation if it's being swapped while enabled
            if cfg.enabled and cfg.anim and cfg.anim:isPlaying() then 
                pcallSafe(function() cfg.anim:stop() end) 
            end
            cfg.anim = a
            -- Reset lastActiveState so tick() picks up the new animation immediately
            if self.lastActiveState then self.lastActiveState[slot] = false end
        end
    end
    return self
end

function Animazer:useOverrideAnim(slot, state)
    local cfg = self.slotOverrides[slot]
    if cfg then
        cfg.enabled = (state ~= false)
        if cfg.enabled then
            -- Early suppression: Empty the list so EZAnims can't start animations next tick
            if animModel and animModel.aList[slot] then
                local base = animModel.aList[slot]
                if not cfg.savedList and #base.list > 0 then
                    cfg.savedList = base.list
                    -- Stop the original animations so they don't get "orphaned" while the list is hijacked
                    for _, a in ipairs(cfg.savedList) do
                        pcallSafe(function() if a.stop then a:stop() end end)
                    end
                    base.list = {}
                end
            end
        else
            -- Immediate cleanup if disabled
            if cfg.savedList and animModel and animModel.aList[slot] then
                animModel.aList[slot].list = cfg.savedList
                cfg.savedList = nil
            end
            if cfg.anim then pcallSafe(function() cfg.anim:stop() end) end
            if self.lastActiveState then self.lastActiveState[slot] = nil end
        end
    end
    return self
end

function Animazer:clearSlotOverride(slot)
    local cfg = self.slotOverrides[slot]
    if cfg then
        if cfg.savedList and animModel and animModel.aList[slot] then
            animModel.aList[slot].list = cfg.savedList
        end
        -- Stop the animation regardless of type when clearing the override
        if cfg.anim then pcallSafe(function() cfg.anim:stop() end) end
        self.slotOverrides[slot] = nil
        if self.lastActiveState then self.lastActiveState[slot] = nil end
    end
    return self
end

-- Helper for clearing groups
function Animazer:clearAnims(locksToClear)
    if not charAnim or not locksToClear then return end
    if type(locksToClear) ~= "table" then locksToClear = {locksToClear} end
    for _, v in ipairs(locksToClear) do
        local a = resolveAnimRef(v)
        if a then
            unlockAnimation(a)
            pcallSafe(function() if a.stop then a:stop() end end)
        end
    end
end

-- Core Tick (Processes overrides every frame)
function Animazer:tick()
    if not animModel or not charAnim then return end

    for slot, cfg in pairs(self.slotOverrides) do
        local base = animModel.aList[slot]
        if base and cfg.enabled then
            -- Suppression: Redirect list to prevent EZAnims from playing defaults
            if not cfg.savedList and #base.list > 0 then
                cfg.savedList = base.list
                base.list = {}
            end

            local wasActive = self.lastActiveState[slot] or false
            local isPulse = slot:find("attack") or slot:find("mine") or slot:find("hurt")

            if base.active then
                -- Trigger Logic:
                -- Pulses (Attack/Mine) restart on EVERY frame the trigger is active (handled by swinging logic)
                -- Others (Continuous) only start on the transition frame to avoid jitter
                if isPulse or not wasActive then
                    if cfg.anim then
                        pcallSafe(function()
                            if isPulse and cfg.anim:isPlaying() then cfg.anim:stop() end
                            cfg.anim:play()
                        end)
                    end
                end
            else
                -- Stopping Logic:
                -- Only stop animations that are meant to be held (continuous)
                -- Check for nil wasActive to handle state resets (e.g. after Better Combat)
                if wasActive ~= false then
                    local isContinuous = slot:find("block") or slot:find("hold") or slot:find("use") or slot:find("load") or slot:find("bow") or slot:find("eat") or slot:find("drink")
                    if isContinuous or base.type == "excluAnims" then
                        if cfg.anim then pcallSafe(function() cfg.anim:stop() end) end
                    end
                end
            end
            self.lastActiveState[slot] = base.active
        else
            -- Restore original anims
            if cfg.savedList and animModel and animModel.aList[slot] then
                animModel.aList[slot].list = cfg.savedList
                cfg.savedList = nil
                self.lastActiveState[slot] = nil
            end
        end
    end

    -- Update Randomatic
    self.randomatic:tick()
end

-- State Management
function Animazer:setState(stateName)
    self.currentState = stateName or ""
    if animModel and animModel.setState then
        animModel:setState(self.currentState)
    end
end

function Animazer:getState()
    return self.currentState or ""
end

function Animazer:changeState(stateName) self:setState(stateName) end

function Animazer:unlockAnimation(animRef)
    local a = resolveAnimRef(animRef)
    if a then unlockAnimation(a) end
end

-- Jumpsy logic
Animazer.jumpsy = {}
local J_MIN_VELOCITY, J_MAX_VELOCITY = -0.8, 0.5
local J_SMOOTH = 0.2
local J_ENABLED = true
local J_progress = 0.5

function Animazer.jumpsy:setRange(min, max) J_MIN_VELOCITY = min or J_MIN_VELOCITY; J_MAX_VELOCITY = max or J_MAX_VELOCITY end
function Animazer.jumpsy:setSmoothness(v) J_SMOOTH = math.max(0, math.min(0.95, v or J_SMOOTH)) end
function Animazer.jumpsy:setEnabled(b) J_ENABLED = b ~= false end

local function lerp(a,b,t) return a + (b-a)*t end
local function clamp(v,a,b) if v < a then return a elseif v > b then return b else return v end end

function Animazer.jumpsy:render(anim)
    if not player or not player:isLoaded() or not anim or not J_ENABLED then return end
    local vel = player:getVelocity().y
    local target = 0.5
    if vel > 0 then target = lerp(0.5, 0, clamp(vel / J_MAX_VELOCITY, 0, 1))
    elseif vel < 0 then target = lerp(0.5, 1, clamp(vel / J_MIN_VELOCITY, 0, 1)) end
    J_progress = lerp(J_progress, target, 1 - J_SMOOTH)
    pcallSafe(function()
        anim:play()
        if anim.setSpeed then anim:setSpeed(0) end
        if anim.setTime and anim.getLength then anim:setTime(J_progress * anim:getLength()) end
    end)
end

-- Randomatic logic
Animazer.randomatic = {}
local randList = {}
function Animazer.randomatic:register(cfg)
    cfg.timer = math.random(1, cfg.interval or 200)
    cfg.repeatCounter = 0
    table.insert(randList, cfg)
end
function Animazer.randomatic:tick()
    for _, cfg in ipairs(randList) do
        if cfg.anim then
            cfg.timer = cfg.timer - 1
            if cfg.timer <= 0 then
                pcallSafe(function() if cfg.anim.stop then cfg.anim:stop() end end)
                pcallSafe(function() if cfg.anim.play then cfg.anim:play() end end)
                local speed = (cfg.minSpeed or 1.0) + math.random() * ((cfg.maxSpeed or 1.0) - (cfg.minSpeed or 1.0))
                pcallSafe(function() if cfg.anim.setSpeed then cfg.anim:setSpeed(speed) end end)
                local shouldRepeat = false
                if cfg.repeatMax and cfg.repeatMax > 0 and cfg.repeatChance then
                    if cfg.repeatCounter < cfg.repeatMax and math.random() < cfg.repeatChance then shouldRepeat = true end
                end
                if shouldRepeat then
                    cfg.timer = (cfg.anim:getLength() / speed) * 20 + math.random(0,5)
                    cfg.repeatCounter = cfg.repeatCounter + 1
                else
                    cfg.timer = (cfg.interval or 200) + math.random(-(cfg.interval or 200)*0.5, (cfg.interval or 200)*0.5)
                    cfg.repeatCounter = 0
                end
            end
        end
    end
end

return Animazer
