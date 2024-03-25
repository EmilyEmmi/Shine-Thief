-- this contains some custom actions, and disables some too
-- also does interactions

-- like walking
--- @param m MarioState
function act_item_throw_ground(m)
    play_character_sound_if_no_flag(m, CHAR_SOUND_PUNCH_YAH, MARIO_MARIO_SOUND_PLAYED)
    set_mario_animation(m, MARIO_ANIM_THROW_LIGHT_OBJECT)

    if m.heldObj then
        m.prevAction = ACT_WALKING
        mario_drop_held_object(m)
    end

    if (should_begin_sliding(m) ~= 0) then
        return set_mario_action(m, ACT_BEGIN_SLIDING, 0)
    end

    --[[if (m.input & INPUT_FIRST_PERSON) ~= 0 then
        return begin_braking_action(m)
    end]]

    if (m.input & INPUT_A_PRESSED) ~= 0 then
        return set_jump_from_landing(m)
    end

    --[[if (check_ground_dive_or_punch(m)) ~= 0 then
        return true
    end]]

    if (m.input & INPUT_ZERO_MOVEMENT) ~= 0 then
        m.forwardVel = approach_s32(m.forwardVel, 0, 2, 2)
        if is_anim_past_end(m) ~= 0 then
            return set_mario_action(m, ACT_WALKING, 0)
        end
    end

    if (analog_stick_held_back(m) ~= 0 and m.forwardVel >= 16) then
        return set_mario_action(m, ACT_TURNING_AROUND, 0)
    end

    if (m.input & INPUT_Z_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_CROUCH_SLIDE, 0)
    end

    m.actionState = 0

    update_walking_speed(m)

    local result = perform_ground_step(m)
    m.marioObj.header.gfx.angle.y = m.faceAngle.y + (m.actionArg - 1) * 0x4000
    if result == GROUND_STEP_LEFT_GROUND then
        set_mario_action(m, ACT_FREEFALL, 0)
        set_mario_animation(m, MARIO_ANIM_GENERAL_FALL);
    elseif result == GROUND_STEP_NONE then
        --anim_and_audio_for_walk(m)
        if (m.intendedMag - m.forwardVel > 16) then
            set_mario_particle_flags(m, PARTICLE_DUST, 0)
        end
    end

    check_ledge_climb_down(m)
    if is_anim_past_end(m) ~= 0 then
        local newAction = m.prevAction
        if newAction == ACT_ITEM_THROW_GROUND then
            newAction = ACT_WALKING
        end
        set_mario_action(m, newAction, 0)
    end
end

ACT_ITEM_THROW_GROUND = allocate_mario_action(ACT_FLAG_MOVING | ACT_FLAG_ALLOW_FIRST_PERSON)
hook_mario_action(ACT_ITEM_THROW_GROUND, act_item_throw_ground)

function act_item_throw_air(m)
    if (check_kick_or_dive_in_air(m) ~= 0) then
        return true
    end

    if (m.input & INPUT_Z_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_GROUND_POUND, 0);
    end

    play_character_sound_if_no_flag(m, CHAR_SOUND_PUNCH_YAH, MARIO_MARIO_SOUND_PLAYED)
    common_air_action_step(m, ACT_JUMP_LAND, MARIO_ANIM_THROW_LIGHT_OBJECT,
        AIR_STEP_CHECK_LEDGE_GRAB | AIR_STEP_CHECK_HANG)
    m.marioObj.header.gfx.angle.y = m.faceAngle.y + (m.actionArg - 1) * 0x4000
    if is_anim_past_end(m) ~= 0 then
        set_mario_action(m, ACT_FREEFALL, 0)
    end
end

ACT_ITEM_THROW_AIR = allocate_mario_action(ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
hook_mario_action(ACT_ITEM_THROW_AIR, act_item_throw_air)

function act_cape_jump(m)
    if (check_kick_or_dive_in_air(m) ~= 0) then
        return true
    end

    if (m.input & INPUT_Z_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_GROUND_POUND, 0);
    end

    if m.flags & MARIO_MARIO_SOUND_PLAYED == 0 then
        m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
        play_sound(SOUND_ACTION_FLYING_FAST, m.marioObj.header.gfx.cameraToObject)
    end
    play_character_sound_if_no_flag(m, CHAR_SOUND_YAHOO_WAHA_YIPPEE, MARIO_MARIO_SOUND_PLAYED)
    common_air_action_step(m, ACT_JUMP_LAND, MARIO_ANIM_FORWARD_SPINNING,
        AIR_STEP_CHECK_LEDGE_GRAB | AIR_STEP_CHECK_HANG)
end

ACT_CAPE_JUMP = allocate_mario_action(ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION | ACT_FLAG_ATTACKING)
hook_mario_action(ACT_CAPE_JUMP, act_cape_jump, INT_FAST_ATTACK_OR_SHELL)

function act_cape_jump_shell(m)
    if m.flags & MARIO_MARIO_SOUND_PLAYED == 0 then
        m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
        play_sound(SOUND_ACTION_FLYING_FAST, m.marioObj.header.gfx.cameraToObject)
    end
    play_character_sound_if_no_flag(m, CHAR_SOUND_YAHOO_WAHA_YIPPEE, MARIO_MARIO_SOUND_PLAYED)
    set_mario_animation(m, MARIO_ANIM_JUMP_RIDING_SHELL)

    update_air_without_turn(m)

    local result = (perform_air_step(m, 0))
    if result == AIR_STEP_LANDED then
        set_mario_action(m, ACT_RIDING_SHELL_GROUND, 1)
    elseif result == AIR_STEP_HIT_WALL then
        mario_set_forward_vel(m, 0)
    elseif result == AIR_STEP_HIT_LAVA_WALL then
        lava_boost_on_wall(m)
    end

    m.marioObj.header.gfx.pos.y = m.marioObj.header.gfx.pos.y + 42
    m.marioObj.header.gfx.angle.y = m.faceAngle.y + m.actionTimer * 4096
    m.actionTimer = m.actionTimer + 1
end

ACT_CAPE_JUMP_SHELL = allocate_mario_action(ACT_FLAG_AIR | ACT_FLAG_RIDING_SHELL | ACT_FLAG_ATTACKING)
hook_mario_action(ACT_CAPE_JUMP_SHELL, act_cape_jump_shell, INT_FAST_ATTACK_OR_SHELL)

-- Faster hangable ceiling speed, "borrowed" from Ztar Attack 2

---@param m MarioState
local function update_custom_hang_moving(m)
    local stepResult = 0
    local nextPos = {}
    local maxSpeed = 30

    local sMario = gPlayerSyncTable[m.playerIndex]

    if sMario.boostTime ~= 0 then
        maxSpeed = maxSpeed + 15
    end
    if sMario.mushroomTime ~= 0 then
        maxSpeed = maxSpeed + 15
    end
    if get_player_owned_shine(m.playerIndex) ~= 0 then
        maxSpeed = maxSpeed - 15
    end

    m.forwardVel = m.forwardVel + 1
    if m.forwardVel > maxSpeed then
        m.forwardVel = maxSpeed
    end

    m.faceAngle.y = m.intendedYaw - approach_s32(limit_angle(m.intendedYaw - m.faceAngle.y), 0, 0x800, 0x800)

    m.slideYaw = m.faceAngle.y
    m.slideVelX = m.forwardVel * sins(m.faceAngle.y)
    m.slideVelZ = m.forwardVel * coss(m.faceAngle.y)

    m.vel.x = m.slideVelX
    m.vel.y = 0.0
    m.vel.z = m.slideVelZ

    nextPos.x = m.pos.x - m.ceil.normal.y * m.vel.x
    nextPos.z = m.pos.z - m.ceil.normal.y * m.vel.z
    nextPos.y = m.pos.y

    stepResult = perform_hanging_step(m, nextPos)

    vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
    vec3s_set(m.marioObj.header.gfx.angle, 0, m.faceAngle.y, 0)
    return stepResult
end

---@param m MarioState
function act_custom_hang_moving(m)
    if m.input & INPUT_A_DOWN == 0 then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    if m.input & INPUT_Z_PRESSED ~= 0 then
        return set_mario_action(m, ACT_GROUND_POUND, 0)
    end

    if m.ceil == nil or m.ceil.type ~= SURFACE_HANGABLE then
        return set_mario_action(m, ACT_FREEFALL, 0)
    end

    if m.actionArg & 1 ~= 0 then
        set_mario_anim_with_accel(m, MARIO_ANIM_MOVE_ON_WIRE_NET_RIGHT, m.forwardVel * 0x2000)
    else
        set_mario_anim_with_accel(m, MARIO_ANIM_MOVE_ON_WIRE_NET_LEFT, m.forwardVel * 0x2000)
    end

    if is_anim_past_end(m) ~= 0 then
        play_sound(SOUND_ACTION_HANGING_STEP, m.marioObj.header.gfx.cameraToObject)
        queue_rumble_data_mario(m, 5, 30)
        m.actionArg = m.actionArg ~ 1
        if m.input & INPUT_ZERO_MOVEMENT ~= 0 then
            return set_mario_action(m, ACT_HANGING, m.actionArg)
        end
    end

    if update_custom_hang_moving(m) == 2 --[[HANG_LEFT_CEIL]] then
        set_mario_action(m, ACT_FREEFALL, 0)
    end

    return 0
end

hook_mario_action(ACT_HANG_MOVING, act_custom_hang_moving)

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

ACT_SHINE_DANCE = allocate_mario_action(ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE | ACT_GROUP_CUTSCENE)
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
    vec3f_copy(m.marioObj.header.gfx.pos, m.pos);
    vec3s_set(m.marioObj.header.gfx.angle, 0, m.faceAngle.y, 0)
    if m.playerIndex == 0 and m.actionTimer == 180 then
        set_background_music(100, SEQ_LEVEL_INSIDE_CASTLE, 15)
        showGameResults = true
        inMenu = false
    end
    m.actionTimer = m.actionTimer + 1
    return false
end

ACT_SHINE_LOSE = allocate_mario_action(ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE | ACT_GROUP_CUTSCENE)
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

    if action == ACT_QUICKSAND_DEATH then
        m.hurtCounter = m.hurtCounter + 0xB
        return ACT_LAVA_BOOST
    elseif action == ACT_LAVA_BOOST and thisLevel and thisLevel.badLava then
        if m.playerIndex == 0 then
            on_death(m)
        end
        return 1
    elseif action == ACT_WATER_THROW and m.action == ACT_WATER_SHELL_SWIMMING then                                                                                          -- transition into punch from water shell
        return ACT_WATER_PUNCH
    elseif action == ACT_WATER_ACTION_END and m.action == ACT_WATER_PUNCH and m.prevAction == ACT_WATER_SHELL_SWIMMING then                                                 -- transition from punch back into water shell
        return ACT_WATER_SHELL_SWIMMING
    elseif action == ACT_DIVE and (not _G.OmmEnabled) and m.action ~= ACT_WALL_KICK_AIR and (m.intendedMag < 2 or limit_angle(m.intendedYaw - m.faceAngle.y) > 0x4000) then -- make kicking easier
        if m.action == ACT_WALKING then
            return ACT_MOVE_PUNCHING
        end
        return ACT_JUMP_KICK
    end
end

hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_set_mario_action)

function allow_hazard_surface(m, type)
    if gGlobalSyncTable.godMode then return false end
    if gPlayerSyncTable[m.playerIndex].star then return false end
    if m.floor and type == HAZARD_TYPE_QUICKSAND and m.floor.type ~= SURFACE_INSTANT_QUICKSAND and m.floor.type ~= SURFACE_INSTANT_MOVING_QUICKSAND then return false end -- disable slow quicksand
end

hook_event(HOOK_ALLOW_HAZARD_SURFACE, allow_hazard_surface)

-- disable some interactions (warps, stars); also prevent team attack with bob-ombs
--- @param m MarioState
--- @param o Object
function allow_interact(m, o, type)
    if gPlayerSyncTable[m.playerIndex].spectator then return (type == INTERACT_POLE) end
    if type == INTERACT_WARP and o ~= id_bhvSTPipe then return false end
    if type == INTERACT_WARP_DOOR then return false end
    if type == INTERACT_STAR_OR_KEY then return false end
    if type == INTERACT_TEXT then return false end
    if type == INTERACT_CAP then return false end
    if type == INTERACT_BBH_ENTRANCE then return false end
    if (type == INTERACT_BOUNCE_TOP or type == INTERACT_BOUNCE_TOP2 or type == INTERACT_SNUFIT_BULLET or type == INTERACT_UNKNOWN_08 or type == INTERACT_KOOPA or type == INTERACT_HIT_FROM_BELOW) and gPlayerSyncTable[m.playerIndex].star then
        m.flags = m.flags | MARIO_METAL_CAP
        return true
    elseif (type == INTERACT_DAMAGE or type == INTERACT_CLAM_OR_BUBBA or type == INTERACT_FLAME or type == INTERACT_SHOCK or type == INTERACT_MR_BLIZZARD) then
        if gPlayerSyncTable[m.playerIndex].star then
            return false
        elseif is_item(get_id_from_behavior(o.behavior)) and o.oObjectOwner then
            local np = network_player_from_global_index(o.oObjectOwner)
            return (np and np.localIndex ~= 0 and allow_pvp_attack(gMarioStates[np.localIndex], gMarioStates[0], true))
        end
    end
end

hook_event(HOOK_ALLOW_INTERACT, allow_interact)
-- do pvp interaction for thrown bob-ombs
--- @param m MarioState
--- @param o Object
function on_interact(m, o, type, value)
    if type == INTERACT_BOUNCE_TOP or type == INTERACT_BOUNCE_TOP2 or type == INTERACT_SNUFIT_BULLET or type == INTERACT_UNKNOWN_08 or type == INTERACT_KOOPA or type == INTERACT_HIT_FROM_BELOW then
        if gPlayerSyncTable[m.playerIndex].star then
            m.flags = m.flags & ~MARIO_METAL_CAP
        end
    elseif m.playerIndex == 0 and (type == INTERACT_DAMAGE or type == INTERACT_FLAME) and is_item(get_id_from_behavior(o.behavior)) and o.oObjectOwner then
        if m.invincTimer > 0 or m.interactObj ~= o then return end
        local np = network_player_from_global_index(o.oObjectOwner or 0)
        on_pvp_attack(gMarioStates[np.localIndex], m, false, true)
        m.hurtCounter = 0
        network_send_object(o, true) -- sync interaction (sometimes causes errors, but there's nothing we can do)
    elseif m.playerIndex == 0 and type == INTERACT_PLAYER and m.action & (ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE | ACT_GROUP_CUTSCENE) == 0 and m.invincTimer == 0 then
        local sMario = gPlayerSyncTable[m.playerIndex]
        if sMario.bulletTimer and sMario.bulletTimer ~= 0 then
            return set_mario_action(m, ACT_FREEFALL, 0) -- explode on other players
        end
        -- hurt when trying to attack star players
        local m2
        for i = 0, MAX_PLAYERS - 1 do
            if o == gMarioStates[i].marioObj then
                m2 = gMarioStates[i]
                if is_player_active(m2) == 0 then return end
                break
            end
        end
        if not m2 then return end
        if m2.action & (ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE | ACT_GROUP_CUTSCENE) ~= 0 or m2.invincTimer ~= 0 then return end
        if gPlayerSyncTable[m2.playerIndex].star and not sMario.star then
            if take_damage_and_knock_back(m, o) ~= 0 then
                on_pvp_attack(m2, m)
                m.hurtCounter = 0
                m.invincTimer = math.max(m.invincTimer, 30)
            end
            return
        end
    end
end

hook_event(HOOK_ON_INTERACT, on_interact)
