-- Removed backup: original Overrider implementation cleared.
-- File intentionally blank. Use scripts/Animazer.lua instead.
        if active then
            pcall(function()
                if active.setPriority then active:setPriority(6) end
                if active.play then active:play() end
                if active.setSpeed then active:setSpeed(0) end
            end)
            if animazerModel and animazerModel.lockedAnims then animazerModel.lockedAnims[active] = nil end
        end
    end

    -- Deactivate EZAnims jump slots to prevent them from also trying to play and blending into the scrubbed anim
    if animazerModel and animazerModel.aList then
        for _, slot in ipairs(jumpSlots) do
            if animazerModel.aList[slot] then
                animazerModel.aList[slot].active = false
            end
            -- clear any configured slot swaps and unlock related anims
            local swap = animazerModel.animSwaps and animazerModel.animSwaps[slot]
            if swap and swap.anim then
                if animazerModel.lockedAnims then animazerModel.lockedAnims[swap.anim] = nil end
                pcall(function() if swap.anim.stop then swap.anim:stop() end end)
            end
            if animazerModel.animSwaps then animazerModel.animSwaps[slot] = nil end
        end
        -- force a refresh so EZAnims re-evaluates without jump slots active
        animazerModel.toggleDiff = true
    end
end

--- Returns the current Overrider state name (e.g., "sword", "tool", or "").
function Overrider:getState()
    return currentState
end

return Overrider
