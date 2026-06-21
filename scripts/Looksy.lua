--[[ Looksy - Dynamic Eye Tracking - Free to use, no credit needed ]]--

local Looksy = {}

local C = { yaw=60, pitch=120, smooth=0.3, strength=1.0, hori=nil, vert=nil }
local S = { yaw=0, pitch=0 }

function Looksy:setEyeAnims(hori, vert) C.hori = hori; C.vert = vert end
function Looksy:setStrength(v) C.strength = v end
function Looksy:getStrength() return C.strength end
function Looksy:setMaxYaw(v) C.yaw = v end
function Looksy:setMaxPitch(v) C.pitch = v end
function Looksy:setSmoothness(v) C.smooth = math.clamp(v, 0, 0.95) end

function Looksy:tick()
    if not player:isLoaded() then return end
    local bYaw = player:getBodyYaw() % 360
    local hYaw, hPitch = player:getRot().y % 360, player:getRot().x
    local dYaw = (hYaw - bYaw + 180) % 360 - 180
    local ok = C.strength > 0 and math.abs(dYaw) <= C.yaw
    local yT = ok and dYaw or 0
    local pT = ok and math.clamp(hPitch, -C.pitch, C.pitch) or 0
    S.yaw = math.lerp(S.yaw, yT, 1 - C.smooth)
    S.pitch = math.lerp(S.pitch, pT, 1 - C.smooth)
    local function apply(a, t)
        if not a then return end
        a:play(); a:setSpeed(0); a:setTime(t * a:getLength())
    end
    apply(C.hori, 0.5 + (S.yaw / C.yaw) * 0.5 * C.strength)
    apply(C.vert, 0.5 + (S.pitch / C.pitch) * 0.5 * C.strength)
end

return Looksy
