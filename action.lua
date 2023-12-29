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
end

-- I had originally reimplemented the entire water shell action, but this doesn't work for attacking, so all this time was wasted
--[[
-- custom water shell action so it works as an attack (derived from the original, obviously)
--- @param m MarioState
function act_water_shell_swimming_custom(m)
    if not m then return 0 end

    if (m.marioObj.oInteractStatus & INT_STATUS_MARIO_DROP_OBJECT) ~= 0 then
        return drop_and_set_mario_action(m, ACT_WATER_IDLE, 0);
    end

    if (m.input & INPUT_B_PRESSED) ~= 0 then -- instead of throwing the shell, it transitions into punch
        if (m.heldObj ~= nil and m.playerIndex == 0) then
            m.heldObj.oInteractStatus = INT_STATUS_STOP_RIDING;
            m.heldObj = nil
        end
        if (m.playerIndex == 0) then stop_shell_music() end
        return set_mario_action(m, ACT_WATER_PUNCH, 0);
    end

    -- removed timer because it's dumb

    m.forwardVel = approach_f32(m.forwardVel, 40, 2, 1); -- 30 changed to 40

    play_swimming_noise(m)
    set_mario_animation(m, MARIO_ANIM_FLUTTERKICK_WITH_OBJ)
    common_swimming_step(m, 0x012C)

    return false
end
ACT_WATER_SHELL_SWIMMING_CUSTOM = allocate_mario_action(ACT_FLAG_WATER_OR_TEXT | ACT_FLAG_SWIMMING | ACT_FLAG_SWIMMING_OR_FLYING | ACT_FLAG_ATTACKING | ACT_FLAG_MOVING)
hook_mario_action(ACT_WATER_SHELL_SWIMMING_CUSTOM, act_water_shell_swimming_custom, INT_FAST_ATTACK_OR_SHELL)

-- some unexposed functions yay
--- @param m MarioState
function play_swimming_noise(m)
    if not m then return end
    local animFrame = m.marioObj.header.gfx.animInfo.animFrame;

    -- this was originally one line to "match up on -O2", whatever that means
    -- hopefully nothing breaks
    if (animFrame == 0 or animFrame == 12) then
        play_sound(SOUND_ACTION_UNKNOWN434, m.marioObj.header.gfx.cameraToObject)
    end
end
--- @param m MarioState
function common_swimming_step(m, swimStrength)
    if not m then return end
    local floorPitch

    -- a bunch of unexposed functions I swear this is like a russian doll
    update_swimming_yaw(m);
    update_swimming_pitch(m);
    update_swimming_speed(m, swimStrength / 10);

    local result = perform_water_step(m)
    if result == WATER_STEP_HIT_FLOOR then
        floorPitch = -find_floor_slope(m, -0x8000);
        if (m.faceAngle.x < floorPitch) then
            m.faceAngle.x = floorPitch
        end
    elseif result == WATER_STEP_HIT_CEILING then
        if (m.faceAngle.x > -0x3000) then
            m.faceAngle.x = m.faceAngle.x - 0x100;
        end
    elseif result == WATER_STEP_HIT_WALL then
        if (m.controller.stickY == 0) then
            if (m.faceAngle.x > 0) then
                m.faceAngle.x = m.faceAngle.x + 0x200;
                if (m.faceAngle.x > 0x3F00) then
                    m.faceAngle.x = 0x3F00;
                end
            else
                m.faceAngle.x = m.faceAngle.x - 0x200;
                if (m.faceAngle.x < -0x3F00) then
                    m.faceAngle.x = -0x3F00;
                end
            end
        end
    end

    update_water_pitch(m);
    m.marioBodyState.headAngle.x = approach_s32(m.marioBodyState.headAngle.x, 0, 0x200, 0x200);

    float_surface_gfx(m);
    set_swimming_at_surface_particles(m, PARTICLE_WAVE_TRAIL);
end
--- @param m MarioState
function update_swimming_yaw(m)
    if not m then return end
    local targetYawVel = -(10 * m.controller.stickX)

    if (targetYawVel > 0) then
        if (m.angleVel.y < 0) then
            m.angleVel.y = m.angleVel.y + 0x40;
            if (m.angleVel.y > 0x10) then
                m.angleVel.y = 0x10;
            end
        else
            m.angleVel.y = approach_s32(m.angleVel.y, targetYawVel, 0x10, 0x20);
        end
    elseif (targetYawVel < 0) then
        if (m.angleVel.y > 0) then
            m.angleVel.y = m.angleVel.y - 0x40;
            if (m.angleVel.y < -0x10) then
                m.angleVel.y = -0x10;
            end
        else
            m.angleVel.y = approach_s32(m.angleVel.y, targetYawVel, 0x20, 0x10);
        end
    else
        m.angleVel.y = approach_s32(m.angleVel.y, 0, 0x40, 0x40);
    end

    m.faceAngle.y = m.faceAngle.y + m.angleVel.y;
    m.faceAngle.z = -m.angleVel.y * 8;
end
--- @param m MarioState
function update_swimming_pitch(m)
    if not m then return end
    local targetPitch = -(252 * m.controller.stickY);

    local pitchVel;
    if (m.faceAngle.x < 0) then
        pitchVel = 0x100;
    else
        pitchVel = 0x200;
    end

    if (m.faceAngle.x < targetPitch) then
        m.faceAngle.x = m.faceAngle.x + pitchVel
        if ((m.faceAngle.x) > targetPitch) then
            m.faceAngle.x = targetPitch;
        end
    elseif (m.faceAngle.x > targetPitch) then
        m.faceAngle.x = m.faceAngle.x - pitchVel
        if ((m.faceAngle.x) < targetPitch) then
            m.faceAngle.x = targetPitch;
        end
    end
end
--- @param m MarioState
function update_swimming_speed(m, decelThreshold)
    if not m then return end
    local buoyancy = get_buoyancy(m); -- yay another undefined
    local maxSpeed = 40 -- changed this from 28 to 40

    if (m.action & ACT_FLAG_STATIONARY) ~= 0 then
        m.forwardVel = m.forwardVel - 2
    end

    if (m.forwardVel < 0) then
        m.forwardVel = 0
    end

    if (m.forwardVel > maxSpeed) then
        m.forwardVel = maxSpeed;
    end

    if (m.forwardVel > decelThreshold) then
        m.forwardVel = m.forwardVel - 0.5
    end

    m.vel.x = m.forwardVel * coss(m.faceAngle.x) * sins(m.faceAngle.y);
    m.vel.y = m.forwardVel * sins(m.faceAngle.x) + buoyancy;
    m.vel.z = m.forwardVel * coss(m.faceAngle.x) * coss(m.faceAngle.y);
end
--- @param m MarioState
function get_buoyancy(m)
    if not m then return 0 end
    local buoyancy = 0

    if (m.flags & MARIO_METAL_CAP) ~= 0 then
        if (m.action & ACT_FLAG_INVULNERABLE) ~= 0 then
            buoyancy = -2
        else
            buoyancy = -18
        end
    elseif (swimming_near_surface(m)) then -- are you kidding me
        buoyancy = 1.25
    elseif ((m.action & ACT_FLAG_MOVING) == 0) then
        buoyancy = -2
    end

    return buoyancy;
end
--- @param m MarioState
function update_water_pitch(m)
    if not m then return end
    local marioObj = m.marioObj;

    if (marioObj.header.gfx.angle.x > 0) then
        marioObj.header.gfx.pos.y = marioObj.header.gfx.pos.y +
            60 * sins(marioObj.header.gfx.angle.x) * sins(marioObj.header.gfx.angle.x);
    end

    if (marioObj.header.gfx.angle.x < 0) then
        marioObj.header.gfx.angle.x = marioObj.header.gfx.angle.x * 6 / 10;
    end

    if (marioObj.header.gfx.angle.x > 0) then
        marioObj.header.gfx.angle.x = marioObj.header.gfx.angle.x * 10 / 8;
    end
end
--- @param m MarioState
function swimming_near_surface(m)
    if not m then return 0 end
    if (m.flags & MARIO_METAL_CAP) ~= 0 then
        return false
    end

    return (m.waterLevel - m.pos.y) < 480
end]]

-- disable some actions, and other stuff
--- @param m MarioState
function before_set_mario_action(m, action)
    local noAction = {
        [ACT_READING_SIGN] = 1,
        [ACT_READING_AUTOMATIC_DIALOG] = 1,
        [ACT_READING_NPC_DIALOG] = 1,
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
    if type == INTERACT_WARP and o ~= bhvSTPipe then return false end
    if type == INTERACT_WARP_DOOR then return false end
    if type == INTERACT_STAR_OR_KEY then return false end
    if type == INTERACT_TEXT then return false end
    if type == INTERACT_CAP then return false end
    if type == INTERACT_BBH_ENTRANCE then return false end
    if type == INTERACT_DAMAGE and get_id_from_behavior(o.behavior) == bhvThrownBobomb then
        local np = network_player_from_global_index(o.oShineOwner or 0)
        return (np.localIndex ~= 0 and allow_pvp_attack(gMarioStates[np.localIndex], gMarioStates[0]))
    end
end
hook_event(HOOK_ALLOW_INTERACT, allow_interact)
-- set attacker on bomb interaction
--- @param m MarioState
--- @param o Object
function on_interact(m,o,type,value)
    if type == INTERACT_DAMAGE and get_id_from_behavior(o.behavior) == bhvThrownBobomb then
        local np = network_player_from_global_index(o.oShineOwner or 0)
        lastAttacker = np.localIndex
        attackCooldown = 60
        network_send_object(o, true)
    end
end
hook_event(HOOK_ON_INTERACT, on_interact)