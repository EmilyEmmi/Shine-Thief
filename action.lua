-- this contains some custom actions, and disables some too

-- win animation
--- @param m MarioState
function act_shine_dance(m)
    if not m then return 0 end

    m.faceAngle.x = 0
    m.faceAngle.z = 0
    if (m.playerIndex == 0) then
        m.faceAngle.y = m.area.camera.yaw
    end
    set_mario_animation(m, MARIO_ANIM_WATER_STAR_DANCE)
    disable_background_sound()
    vec3f_copy(m.marioObj.header.gfx.pos, m.pos);
    vec3s_set(m.marioObj.header.gfx.angle, 0, m.faceAngle.y, 0)
    if m.actionTimer == 120 then -- 4 seconds
        play_character_sound(m, CHAR_SOUND_YAHOO)
        m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
    elseif (m.actionTimer < 56) then
        set_anim_to_frame(m, m.actionTimer // 4)
    elseif (m.actionTimer >= 110) then
        m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
        if m.playerIndex == 0 and m.actionTimer == 180 then
            set_background_music(100, SEQ_LEVEL_INSIDE_CASTLE, 15)
            showGameResults = true
            inMenu = false
        end
    end
    m.actionTimer = m.actionTimer + 1
    return false
end
ACT_SHINE_DANCE = allocate_mario_action(ACT_GROUP_CUTSCENE | ACT_FLAG_INVULNERABLE | ACT_FLAG_INTANGIBLE)
hook_mario_action(ACT_SHINE_DANCE, act_shine_dance)

-- lose animation
--- @param m MarioState
function act_shine_lose(m)
    if not m then return 0 end

    m.faceAngle.x = 0
    m.faceAngle.z = 0
    if (m.playerIndex == 0) then
        m.faceAngle.y = m.area.camera.yaw
    end
    set_mario_animation(m, MARIO_ANIM_DYING_FALL_OVER)
    disable_background_sound()
    if m.playerIndex == 0 and m.actionTimer == 180 then
        set_background_music(100, SEQ_LEVEL_INSIDE_CASTLE, 15)
        showGameResults = true
        inMenu = false
    end
    m.actionTimer = m.actionTimer + 1
    return false
end
ACT_SHINE_LOSE = allocate_mario_action(ACT_GROUP_CUTSCENE | ACT_FLAG_INVULNERABLE | ACT_FLAG_INTANGIBLE)
hook_mario_action(ACT_SHINE_LOSE, act_shine_lose)

-- sets the correct action based on who won or lost
function set_dance_action()
    local np = network_player_from_global_index(localWinner)
    local np2 = nil
    if localWinner2 ~= -1 then
        np2 = network_player_from_global_index(localWinner2)
    end
    local sMario = nil
    local sMario2 = nil
    if np then sMario = gPlayerSyncTable[np.localIndex] end
    if np2 then sMario2 = gPlayerSyncTable[np2.localIndex] end
    if np and (np.localIndex == 0 or (sMario.team ~= 0 and sMario.team == gPlayerSyncTable[0].team)) then
        drop_and_set_mario_action(gMarioStates[0], ACT_SHINE_DANCE, 0)
    elseif np2 and (np2.localIndex == 0 or (sMario2.team ~= 0 and sMario2.team == gPlayerSyncTable[0].team)) then
        drop_and_set_mario_action(gMarioStates[0], ACT_SHINE_DANCE, 0)
    else
        drop_and_set_mario_action(gMarioStates[0], ACT_SHINE_LOSE, 0)
    end
    set_camera_mode(gMarioStates[0].area.camera, CAMERA_MODE_ROM_HACK, 0)
end

-- disable some actions, and other stuff
--- @param m MarioState
function before_set_mario_action(m, action)
    local noAction = {
        [ACT_READING_SIGN] = 1,
        [ACT_READING_AUTOMATIC_DIALOG] = 1,
    }
    if noAction[action] then
        return 1
    end

    if action == ACT_QUICKSAND_DEATH then -- disable quicksand
        m.hurtCounter = 0xB
        return ACT_LAVA_BOOST
    elseif action == ACT_LAVA_BOOST and thisLevel.badLava then -- for Bowser 2
        go_to_mario_start(m.playerIndex, gNetworkPlayers[m.playerIndex].globalIndex, true)
        return 1
    elseif action == ACT_WATER_THROW and m.action == ACT_WATER_SHELL_SWIMMING then -- transition into punch from water shell
        return ACT_WATER_PUNCH
    elseif action == ACT_WATER_ACTION_END and m.action == ACT_WATER_PUNCH and m.prevAction == ACT_WATER_SHELL_SWIMMING then -- transition from punch back into water shell
        return ACT_WATER_SHELL_SWIMMING
    elseif action == ACT_DIVE and (not _G.OmmEnabled) and m.action ~= ACT_WALL_KICK_AIR and (m.intendedMag < 2 or limit_angle(m.intendedYaw - m.faceAngle.y) > 0x4000) then -- make kicking easier
        if m.action == ACT_WALKING then
            return ACT_MOVE_PUNCHING
        end
        return ACT_JUMP_KICK
    end
end
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_set_mario_action)

-- disable some interactions (warps, stars); also prevent team attack with bob-ombs
--- @param m MarioState
--- @param o Object
function allow_interact(m,o,type)
    if gPlayerSyncTable[m.playerIndex].spectator then return false end
    if type == INTERACT_WARP and o ~= id_bhvSTPipe then return false end
    if type == INTERACT_WARP_DOOR then return false end
    if type == INTERACT_STAR_OR_KEY then return false end
    if type == INTERACT_TEXT then return false end
    if type == INTERACT_CAP then return false end
    if type == INTERACT_BBH_ENTRANCE then return false end
    if type == INTERACT_DAMAGE and get_id_from_behavior(o.behavior) == id_bhvThrownBobomb then
        local np = network_player_from_global_index(o.oObjectOwner or 0)
        return (np.localIndex ~= 0 and allow_pvp_attack(gMarioStates[np.localIndex], gMarioStates[0]))
    end
end
hook_event(HOOK_ALLOW_INTERACT, allow_interact)
-- do pvp interaction for thrown bob-ombs
--- @param m MarioState
--- @param o Object
function on_interact(m,o,type,value)
    if type == INTERACT_DAMAGE and get_id_from_behavior(o.behavior) == id_bhvThrownBobomb then
        local np = network_player_from_global_index(o.oObjectOwner or 0)
        on_pvp_attack(gMarioStates[np.localIndex], gMarioStates[0])
        network_send_object(o, true) -- sync explosion
    end
end
hook_event(HOOK_ON_INTERACT, on_interact)