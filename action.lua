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
        if newAction == ACT_ITEM_THROW_GROUND or newAction & ACT_GROUP_MASK ~= ACT_GROUP_MOVING then
            newAction = ACT_WALKING
        end
        set_mario_action(m, newAction, 0)
    end
end

ACT_ITEM_THROW_GROUND = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING | ACT_FLAG_ALLOW_FIRST_PERSON)
hook_mario_action(ACT_ITEM_THROW_GROUND, act_item_throw_ground)

function act_item_throw_air(m)
    if using_omm_moveset(m.playerIndex) then
        if m.controller.buttonPressed & B_BUTTON ~= 0 then
            set_mario_action(m, ACT_JUMP_KICK, 0)
            return true
        elseif m.vel.y <= 0 and m.controller.buttonDown & Y_BUTTON ~= 0 then
            set_mario_action(m, _G.OmmApi.ACT_OMM_SPIN_AIR, 0)
            return true
        end
    elseif (check_kick_or_dive_in_air(m) ~= 0) then
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

ACT_ITEM_THROW_AIR = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION)
hook_mario_action(ACT_ITEM_THROW_AIR, act_item_throw_air)

function act_cape_jump(m)
    if m.flags & MARIO_MARIO_SOUND_PLAYED == 0 then
        m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
        play_sound(SOUND_ACTION_FLYING_FAST, m.marioObj.header.gfx.cameraToObject)
    end
    if using_omm_moveset(m.playerIndex) then
        if m.controller.buttonPressed & B_BUTTON ~= 0 then
            set_mario_action(m, ACT_JUMP_KICK, 0)
            return true
        elseif m.vel.y <= 0 and m.controller.buttonDown & Y_BUTTON ~= 0 then
            set_mario_action(m, _G.OmmApi.ACT_OMM_SPIN_AIR, 0)
            return true
        end
    elseif (check_kick_or_dive_in_air(m) ~= 0) then
        return true
    end

    if (m.input & INPUT_Z_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_GROUND_POUND, 0);
    end

    play_character_sound_if_no_flag(m, CHAR_SOUND_YAHOO_WAHA_YIPPEE, MARIO_MARIO_SOUND_PLAYED)
    common_air_action_step(m, ACT_JUMP_LAND, MARIO_ANIM_FORWARD_SPINNING,
        AIR_STEP_CHECK_LEDGE_GRAB | AIR_STEP_CHECK_HANG)
end

ACT_CAPE_JUMP = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION |
    ACT_FLAG_ATTACKING)
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

ACT_CAPE_JUMP_SHELL = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_RIDING_SHELL |
    ACT_FLAG_ATTACKING)
hook_mario_action(ACT_CAPE_JUMP_SHELL, act_cape_jump_shell, INT_FAST_ATTACK_OR_SHELL)

-- Custom ceiling stuff
-- Faster hangable ceiling speed "borrowed" from Ztar Attack 2

---@param m MarioState
function act_custom_hanging(m)
    if not m then return 0 end
    if (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
        return set_mario_action(m, ACT_HANG_MOVING, m.actionArg);
    end

    if (m.input & INPUT_A_DOWN) == 0 then
        return set_mario_action(m, ACT_FREEFALL, 0);
    end

    if (m.input & INPUT_Z_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_GROUND_POUND, 0);
    elseif m.input & INPUT_B_PRESSED ~= 0 then
        return set_mario_action(m, ACT_HANGING_KICK, m.actionArg)
    end

    if (m.ceil == nil or m.ceil.type ~= SURFACE_HANGABLE) then
        return set_mario_action(m, ACT_FREEFALL, 0);
    end

    if (m.actionArg & 1) ~= 0 then
        set_character_animation(m, CHAR_ANIM_HANDSTAND_LEFT);
    else
        set_character_animation(m, CHAR_ANIM_HANDSTAND_RIGHT);
    end

    update_hang_stationary(m);

    return 0
end

hook_mario_action(ACT_HANGING, act_custom_hanging)

---@param m MarioState
function act_hanging_kick(m)
    if not m then return 0 end
    if (m.input & INPUT_A_DOWN) == 0 then
        return set_mario_action(m, ACT_FREEFALL, 0);
    end

    if (m.input & INPUT_Z_PRESSED) ~= 0 then
        return set_mario_action(m, ACT_GROUND_POUND, 0);
    end

    if (m.ceil == nil or m.ceil.type ~= SURFACE_HANGABLE) then
        return set_mario_action(m, ACT_FREEFALL, 0);
    end

    play_character_sound_if_no_flag(m, CHAR_SOUND_PUNCH_HOO, MARIO_ACTION_SOUND_PLAYED);
    set_mario_anim_with_accel(m, MARIO_ANIM_HANG_ON_CEILING, 30 * 0x2000)
    local animFrame = m.marioObj.header.gfx.animInfo.animFrame;
    if (animFrame == 0) then
        m.marioBodyState.punchState = (2 << 6) | 6;
    elseif (animFrame >= 0 and animFrame < 8) then
        m.flags = m.flags | MARIO_KICKING;
    end
    if is_anim_at_end(m) ~= 0 then
        set_mario_action(m, ACT_HANGING, 0);
        return
    end

    update_hang_stationary(m);

    return 0
end

ACT_HANGING_KICK = allocate_mario_action(ACT_GROUP_AUTOMATIC | ACT_FLAG_STATIONARY | ACT_FLAG_ATTACKING | ACT_FLAG_HANGING)
hook_mario_action(ACT_HANGING_KICK, act_hanging_kick, INT_KICK)

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
    elseif m.input & INPUT_B_PRESSED ~= 0 then
        return set_mario_action(m, ACT_HANGING_KICK, m.actionArg)
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

-- custom shock actions that you can be hurt during
function act_shocked_hurtable(m)
    if not m then return 0 end
    play_character_sound_if_no_flag(m, CHAR_SOUND_WAAAOOOW, MARIO_MARIO_SOUND_PLAYED);
    play_sound(SOUND_MOVING_SHOCKED, m.marioObj.header.gfx.cameraToObject);
    if (m.playerIndex == 0) then set_camera_shake_from_hit(SHAKE_SHOCK) end

    if (set_character_animation(m, CHAR_ANIM_SHOCKED) == 0) then
        m.actionTimer = m.actionTimer + 1
        m.flags = m.flags | MARIO_METAL_SHOCK;
    end

    if (m.actionArg == 0) then
        mario_set_forward_vel(m, 0);
        if (perform_air_step(m, 1) == AIR_STEP_LANDED) then
            play_mario_landing_sound(m, SOUND_ACTION_TERRAIN_LANDING)
            m.actionArg = 1
        end
    else
        if (m.actionTimer >= 12) then
            --m.invincTimer = 30;
            set_mario_action(m, ACT_IDLE, 0)
        end
        stop_and_set_height_to_floor(m);
    end

    return 0
end

ACT_SHOCKED_HURTABLE = allocate_mario_action(ACT_GROUP_AUTOMATIC | ACT_FLAG_STATIONARY)
hook_mario_action(ACT_SHOCKED_HURTABLE, act_shocked_hurtable)

function act_water_shocked_hurtable(m)
    if not m then return 0 end
    play_character_sound_if_no_flag(m, CHAR_SOUND_WAAAOOOW, MARIO_MARIO_SOUND_PLAYED);
    play_sound(SOUND_MOVING_SHOCKED, m.marioObj.header.gfx.cameraToObject);
    if (m.playerIndex == 0) then set_camera_shake_from_hit(SHAKE_SHOCK) end

    if (set_character_animation(m, CHAR_ANIM_SHOCKED) == 0) then
        m.actionTimer = m.actionTimer + 1
        m.flags = m.flags | MARIO_METAL_SHOCK;
    end

    if (m.actionTimer >= 12) then
        --m.invincTimer = 30;
        set_mario_action(m, ACT_WATER_IDLE, 0);
    end

    --stationary_slow_down(m); -- no lua equivalent
    mario_set_forward_vel(m, 0) -- run this instead
    perform_water_step(m);
    m.marioBodyState.headAngle.x = 0;
    return 0
end

ACT_WATER_SHOCKED_HURTABLE = allocate_mario_action(ACT_GROUP_SUBMERGED | ACT_FLAG_STATIONARY | ACT_FLAG_SWIMMING | ACT_FLAG_SWIMMING_OR_FLYING | ACT_FLAG_WATER_OR_TEXT)
hook_mario_action(ACT_WATER_SHOCKED_HURTABLE, act_water_shocked_hurtable)

-- win animation
local win_timings = {
    {56, 110, 120}, -- slow down until frame 56, peace sign at 110, "yahoo" at 120
    {40, 100, 115},
    {64, 110, 110},
    {35, 85, 125},
    {45, 105, 150},
    {45, 110, 110},
}
--- @param m MarioState
function act_game_win(m)
    if not m then return 0 end

    if DEBUG_MODE and m.playerIndex == 0 and m.controller.buttonPressed & A_BUTTON ~= 0 then
        djui_chat_message_create(tostring(m.actionTimer))
    end

    m.faceAngle.x = 0
    m.faceAngle.z = 0
    if (m.playerIndex == 0) then
        m.faceAngle.y = m.area.camera.yaw
    end
    set_mario_animation(m, MARIO_ANIM_WATER_STAR_DANCE)
    disable_background_sound()
    stop_cap_music()
    stop_secondary_music(1)
    vec3f_copy(m.marioObj.header.gfx.pos, m.pos);
    vec3s_set(m.marioObj.header.gfx.angle, 0, m.faceAngle.y, 0)
    local timing = win_timings[gGlobalSyncTable.gameMode + 1] or win_timings[1]
    if m.actionTimer == timing[3] then -- 4 seconds
        play_character_sound(m, CHAR_SOUND_YAHOO)
    end
    if (m.actionTimer < timing[1]) then
        set_anim_to_frame(m, m.actionTimer // 4)
    elseif (m.actionTimer >= timing[2]) then
        m.marioBodyState.handState = MARIO_HAND_PEACE_SIGN
        if m.playerIndex == 0 and m.actionTimer == 180 then
            if (get_current_background_music() ~= 0 and get_current_background_music_target_volume() ~= 0) or gNetworkPlayers[0].currLevelNum < LEVEL_COUNT then -- assume that custom maps with no music have custom music
                set_background_music(100, SEQ_WON, 15)
            end
            showGameResults = true
            inMenu = false
        end
    end
    m.actionTimer = m.actionTimer + 1
    return false
end

ACT_GAME_WIN = allocate_mario_action(ACT_FLAG_INTANGIBLE | ACT_GROUP_CUTSCENE)
hook_mario_action(ACT_GAME_WIN, act_game_win)

-- lose animation
--- @param m MarioState
function act_game_lose(m)
    if not m then return 0 end

    m.faceAngle.x = 0
    m.faceAngle.z = 0
    if (m.playerIndex == 0) then
        m.faceAngle.y = m.area.camera.yaw
    end
    set_mario_animation(m, MARIO_ANIM_DYING_FALL_OVER)
    disable_background_sound()
    stop_cap_music()
    stop_secondary_music(1)
    vec3f_copy(m.marioObj.header.gfx.pos, m.pos);
    vec3s_set(m.marioObj.header.gfx.angle, 0, m.faceAngle.y, 0)
    if m.playerIndex == 0 and m.actionTimer == 180 then
        if (get_current_background_music() ~= 0 and get_current_background_music_target_volume() ~= 0) or gNetworkPlayers[0].currLevelNum < LEVEL_COUNT then -- assume that custom maps with no music have custom music
            set_background_music(100, SEQ_WON, 15)
        end
        showGameResults = true
        inMenu = false
    end
    m.actionTimer = m.actionTimer + 1
    return false
end

ACT_GAME_LOSE = allocate_mario_action(ACT_FLAG_INTANGIBLE | ACT_GROUP_CUTSCENE)
hook_mario_action(ACT_GAME_LOSE, act_game_lose)

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
        drop_and_set_mario_action(gMarioStates[0], ACT_GAME_WIN, 0)
    elseif np2 and (np2.localIndex == 0 or (sMario2.team ~= 0 and sMario2.team == gPlayerSyncTable[0].team)) then
        drop_and_set_mario_action(gMarioStates[0], ACT_GAME_WIN, 0)
    else
        drop_and_set_mario_action(gMarioStates[0], ACT_GAME_LOSE, 0)
    end
    if gMarioStates[0].area.camera then
        set_camera_mode(gMarioStates[0].area.camera, gMarioStates[0].area.camera.defMode, 0)
    end
end

-- captured action (renegade roundup)
function act_captured(m)
    m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
    local sMario = gPlayerSyncTable[m.playerIndex]
    if sMario.eliminated == 0 then
        m.forwardVel = 0
        m.vel.y = 0
        m.flags = m.flags & ~(MARIO_WING_CAP | MARIO_VANISH_CAP)
        if m.waterLevel < m.pos.y then
            set_mario_action(m, ACT_TRIPLE_JUMP, 1)
        else
            set_mario_action(m, ACT_BREASTSTROKE, 0)
        end
        spawn_triangle_break_particles(4, 0x8B, 0.25, 0) -- MODEL_CARTOON_STAR
        m.invincTimer = 120                              -- reduced by 1 sec
        return
    end

    if m.playerIndex ~= 0 and not network_is_server() then return end -- run server for action handling

    local cage = obj_get_first_with_behavior_id(id_bhvRRCage)
    local defCage
    while cage do
        if cage.oBehParams == sMario.eliminated then break end
        if cage.oBehParams == 1 then defCage = cage end
        cage = obj_get_next_with_same_behavior_id(cage)
    end
    if not cage then
        cage = defCage
        if not cage then return end
        if m.playerIndex == 0 then
            sMario.eliminated = 1
        end
    end

    if m.playerIndex == 0 then
        m.pos.x, m.pos.y, m.pos.z = cage.oPosX, cage.oPosY, cage.oPosZ
        vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
        lastCage = sMario.eliminated

        if m.actionArg == 0 then
            m.actionArg = 1
            if thisLevel.romhack_cam then
                m.area.camera.defMode = CAMERA_MODE_ROM_HACK
            end
            set_camera_mode(m.area.camera, m.area.camera.defMode, 0)
            soft_reset_camera_fix_bug(m.area.camera)
        end
    end

    if network_is_server() and m.controller.buttonPressed & A_BUTTON ~= 0 and cage.oAction ~= 1 and cage.oAction ~= 2 then
        cage.oAction = 1
        cage.oTimer = 1
    end
end

ACT_CAPTURED = allocate_mario_action(ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE | ACT_GROUP_CUTSCENE)
hook_mario_action(ACT_CAPTURED, act_captured)

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

    if (action == ACT_BURNING_JUMP or action == ACT_BURNING_FALL or action == ACT_BURNING_GROUND) and m.marioObj.oMarioBurnTimer == 0 then
        m.hurtCounter = m.hurtCounter + 0xB -- regular damage
    elseif action == ACT_DISAPPEARED then   -- hurt on painting warp
        if m.playerIndex == 0 then
            handle_hit(0, 5)
        end
    elseif action == ACT_SHOCKWAVE_BOUNCE then
        if gPlayerSyncTable[m.playerIndex].star then return ACT_JUMP end
    elseif action == ACT_QUICKSAND_DEATH then
        m.hurtCounter = m.hurtCounter + 0xB
        return ACT_LAVA_BOOST
    elseif action == ACT_LAVA_BOOST and thisLevel and thisLevel.badLava then
        m.hurtCounter = 0
        if m.playerIndex == 0 then
            on_death(m)
        end
        return 1
    elseif action == ACT_WATER_THROW and m.action == ACT_WATER_SHELL_SWIMMING then                                                                                                                                 -- transition into punch from water shell
        return ACT_WATER_PUNCH
    elseif action == ACT_WATER_ACTION_END and m.action == ACT_WATER_PUNCH and m.prevAction == ACT_WATER_SHELL_SWIMMING then                                                                                        -- transition from punch back into water shell
        return ACT_WATER_SHELL_SWIMMING
    elseif action == ACT_DIVE and (not using_omm_moveset(m.playerIndex)) and (m.action ~= ACT_WALL_KICK_AIR or m.vel.y < 50) and (m.intendedMag < 2 or abs_angle_diff(m.intendedYaw, m.faceAngle.y) > 0x4000) then -- make kicking easier
        if m.action == ACT_WALKING then
            return ACT_MOVE_PUNCHING
        end
        return ACT_JUMP_KICK
    end
end

hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_set_mario_action)

function allow_hazard_surface(m, type)
    if (thisLevel and thisLevel.badLava) then return true end
    if gGlobalSyncTable.godMode then return false end
    if gPlayerSyncTable[m.playerIndex].star then return false end
    if m.floor and type == HAZARD_TYPE_QUICKSAND and m.floor.type ~= SURFACE_INSTANT_QUICKSAND and m.floor.type ~= SURFACE_INSTANT_MOVING_QUICKSAND then return false end -- disable slow quicksand
end

hook_event(HOOK_ALLOW_HAZARD_SURFACE, allow_hazard_surface)

-- disable some interactions (warps, stars); also handle item interaction
--- @param m MarioState
--- @param o Object
function allow_interact(m, o, type)
    if is_spectator(m.playerIndex) then return (type == INTERACT_POLE or obj_has_behavior_id(o, id_bhvSTPipe) ~= 0) end
    if is_dead(m.playerIndex) and obj_has_behavior_id(o, id_bhvSTPipe) == 0 and (type == INTERACT_WATER_RING or type == INTERACT_COIN) then return false end
    if type == INTERACT_WARP then return false end
    if type == INTERACT_WARP_DOOR then return false end
    if type == INTERACT_STAR_OR_KEY then return false end
    if type == INTERACT_TEXT then return false end
    if type == INTERACT_CAP then return false end
    if type == INTERACT_BBH_ENTRANCE then return false end
    if type == INTERACT_CANNON_BASE then return false end
    if (type == INTERACT_BOUNCE_TOP or type == INTERACT_BOUNCE_TOP2 or type == INTERACT_SNUFIT_BULLET or type == INTERACT_UNKNOWN_08 or type == INTERACT_KOOPA or type == INTERACT_HIT_FROM_BELOW) and is_invincible(m.playerIndex) then
        m.flags = m.flags | MARIO_METAL_CAP
        return true
    elseif (type == INTERACT_DAMAGE or type == INTERACT_CLAM_OR_BUBBA or type == INTERACT_FLAME or type == INTERACT_SHOCK or type == INTERACT_MR_BLIZZARD) then
        local o_id = get_id_from_behavior(o.behavior)
        local itemType = is_item(o_id)
        if itemType and o.oObjectOwner and o.oObjectOwner ~= -1 then
            local sMario = gPlayerSyncTable[m.playerIndex]
            local np = network_player_from_global_index(o.oObjectOwner)
            local valid = (np and np.localIndex ~= 0 and allow_pvp_attack(gMarioStates[np.localIndex], m, 0, true))
            local isBlueShell = false
            if get_id_from_behavior(o.behavior) == id_bhvBlueShell and o.oAction == 3 then -- blue shell dodging (also handles hitting self)
                isBlueShell = true
                if sMario.mushroomTime > 50 then                                           -- 10 frame window (you have to move too)
                    valid = false
                elseif np.localIndex == 0 then
                    valid = true
                end
            end

            if not valid then return false end

            if is_invincible(m.playerIndex) then
                o.oInteractStatus = o.oInteractStatus | ATTACK_PUNCH | INT_STATUS_WAS_ATTACKED |
                    INT_STATUS_INTERACTED | INT_STATUS_TOUCHED_BOB_OMB
                return false
            elseif sMario.item and sMario.item ~= 0 then -- some items can block red shells
                local data = item_data[sMario.item]
                if itemType == 3 and data.protect then
                    sMario.item = data.protect
                    sMario.itemUses = 0
                    o.oInteractStatus = o.oInteractStatus | ATTACK_PUNCH | INT_STATUS_WAS_ATTACKED |
                        INT_STATUS_INTERACTED | INT_STATUS_TOUCHED_BOB_OMB
                    return false
                end
            end
            -- ignore invulnerability for blue shell
            if isBlueShell then
                if m.action & ACT_FLAG_INVULNERABLE ~= 0 and m.invincTimer == 0 then
                    m.action = ACT_FREEFALL
                elseif m.invincTimer < 2 then -- only ignore once; use invinc timer to mark that we've been hit already
                    m.invincTimer = 2
                    if gGlobalSyncTable.gameMode == 4 then m.invincTimer = 32 end
                end
            end
            return true
        elseif is_invincible(m.playerIndex) then
            o.oInteractStatus = o.oInteractStatus | ATTACK_PUNCH | INT_STATUS_WAS_ATTACKED | INT_STATUS_INTERACTED |
                INT_STATUS_TOUCHED_BOB_OMB
            return false
        end
    end
end

hook_event(HOOK_ALLOW_INTERACT, allow_interact)
-- do pvp interaction for thrown bob-ombs
--- @param m MarioState
--- @param o Object
function on_interact(m, o, type, value)
    local o_id = get_id_from_behavior(o.behavior)
    if type == INTERACT_COIN then
        if m.playerIndex == 0 then
            local sMario = gPlayerSyncTable[m.playerIndex]
            sMario.points = sMario.points + o.oDamageOrCoinValue
        end
    elseif type == INTERACT_BOUNCE_TOP or type == INTERACT_BOUNCE_TOP2 or type == INTERACT_SNUFIT_BULLET or type == INTERACT_UNKNOWN_08 or type == INTERACT_KOOPA or type == INTERACT_HIT_FROM_BELOW then
        if is_invincible(m.playerIndex) then
            m.flags = m.flags & ~MARIO_METAL_CAP
        end
    elseif m.playerIndex == 0 and (type == INTERACT_DAMAGE or type == INTERACT_FLAME) and is_item(o_id) and o.oObjectOwner and o.oObjectOwner ~= -1 then
        if (m.invincTimer > 0 and o_id ~= id_bhvBlueShell) or m.flags & MARIO_VANISH_CAP ~= 0 or m.hurtCounter == 0 or o.oInteractStatus & INT_STATUS_INTERACTED == 0 or (type ~= INTERACT_FLAME and o.oInteractStatus & INT_STATUS_ATTACKED_MARIO == 0) then return end
        local np = network_player_from_global_index(o.oObjectOwner or 0)
        if np.localIndex == 0 then return end
        local itemType = is_item(o_id)
        on_pvp_attack(gMarioStates[np.localIndex], m, 0, (itemType == 4), (itemType ~= 4))
        m.hurtCounter = 0
    elseif m.playerIndex == 0 and type == INTERACT_PLAYER and m.invincTimer == 0 and m.flags & MARIO_VANISH_CAP == 0 then
        local sMario = gPlayerSyncTable[m.playerIndex]
        if sMario.bulletTimer and sMario.bulletTimer ~= 0 then
            return set_mario_action(m, ACT_FREEFALL, 0) -- explode on other players
        end

        if sMario.isBomb or is_invincible(m.playerIndex) then return end

        if m.action & (ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE) ~= 0 then
            -- when in an invulnerable action, get captured by law on any interaction
            if gGlobalSyncTable.gameMode == 4 and (gGlobalSyncTable.gameState == 0 or gGlobalSyncTable.gameState == 2) and sMario.team == 1 then
                local m2
                for i = 0, MAX_PLAYERS - 1 do
                    if o == gMarioStates[i].marioObj then
                        m2 = gMarioStates[i]
                        if is_player_active(m2) == 0 then return end
                        break
                    end
                end
                if not m2 then return end
                local sMario2 = gPlayerSyncTable[m2.playerIndex]
                if sMario2.team ~= 2 then return end
                if m2.invincTimer ~= 0 or m2.flags & MARIO_VANISH_CAP ~= 0 then return end
                on_pvp_attack(m2, m, 0)
            end
            return
        end

        -- hurt when trying to attack star or bomb players
        local m2
        for i = 0, MAX_PLAYERS - 1 do
            if o == gMarioStates[i].marioObj then
                m2 = gMarioStates[i]
                if is_player_active(m2) == 0 then return end
                break
            end
        end
        if not m2 then return end
        local sMario2 = gPlayerSyncTable[m2.playerIndex]
        if sMario.team ~= 0 and sMario2.team ~= 0 and sMario2.team == sMario.team then return end
        if m2.action & (ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE) ~= 0 or m2.invincTimer ~= 0 or m2.flags & MARIO_VANISH_CAP ~= 0 then return end
        if is_invincible(m2.playerIndex) then
            o.oDamageOrCoinValue = (sMario2.star and 1) or 2
            m.interactObj = o
            if is_vulnerable(m) and take_damage_and_knock_back(m, o) ~= 0 then
                on_pvp_attack(m2, m)
                m.hurtCounter = 0
            end
            return
        elseif sMario2.isBomb and m2.knockbackTimer == 0 and m2.action ~= ACT_SPAWN_SPIN_AIRBORNE then
            o.oDamageOrCoinValue = 2
            m.interactObj = o
            if is_vulnerable(m) and take_damage_and_knock_back(m, o) ~= 0 then
                on_pvp_attack(m2, m)
                m.hurtCounter = 0
                network_send_to(m2.playerIndex, true, {
                    id = PACKET_BOMB_HIT
                })
            end
            return
        end
    end
end

hook_event(HOOK_ON_INTERACT, on_interact)

-- true if a star or bullet bill is active
function is_invincible(index)
    local sMario = gPlayerSyncTable[index]
    local m = gMarioStates[index]
    return sMario.star or (sMario.bulletTimer ~= 0 and (m.action & ACT_FLAG_SWIMMING == 0 and m.action & ACT_FLAG_SWIMMING_OR_FLYING ~= 0))
end

-- true if invinc timer isn't active and we're not in an invulnerable action
function is_vulnerable(m)
    return (m.action & ACT_FLAG_INVULNERABLE == 0) and m.invincTimer == 0
end