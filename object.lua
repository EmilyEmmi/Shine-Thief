-- This file handles the shine, pipes, and deleted objects

define_custom_obj_fields({
    oShineOwner = "s32", -- The global index of the player with the shine (-1 is no owner)
    oShineDistFromHome = "f32", -- oStarSpawnDisFromHome screws up for some reason
})

-- The shine is built off the star, obviously
--- @param o Object
function bhv_shine_init(o)
    local shine = obj_get_first_with_behavior_id_and_field_s32(bhvShine, 0x40, o.oBehParams)
    if shine == o then obj_get_next_with_same_behavior_id_and_field_s32(shine, 0x40, o.oBehParams) end
    
    if shine and shine ~= o then -- don't want a second shine
        obj_mark_for_deletion(shine)
    end
    local hitbox = get_temp_object_hitbox()
    hitbox.interactType = INTERACT_WATER_RING -- Don't want to have INTERACT_STAR because it has hard-coded behavior
    hitbox.radius = 80
    hitbox.height = 50
    obj_set_hitbox(o, hitbox)

    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oGravity = 2
    o.oBounciness = 20
    o.oBuoyancy = 1
    o.oFriction = 0.8
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oAnimState = -1

    -- The shine works much better if we send packets manually
    network_init_object(o, false, {
        'oPosX',
        'oPosY',
        'oPosZ',
        'oVelY',
        'oForwardVel',
        'oMoveAngleYaw',
        'oTimer',
        'oAction',
        'oShineOwner',
        'oStarSpawnUnkFC', -- might not be necessary?
        'oHomeX', -- same for all home stuff
        'oHomeY',
        'oHomeZ',
    })
end

--- @param o Object
function bhv_shine_loop(o)
    local send = false
    local m = nearest_mario_state_to_object(o)
    local sMario = gPlayerSyncTable[m.playerIndex]

    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x800 -- spin

    if o.oShineOwner and o.oShineOwner ~= -1 then -- go above owner's head
        local np = network_player_from_global_index(o.oShineOwner)
        o.oAction = 0
        if np and np.connected and is_player_active(gMarioStates[np.localIndex]) then
            local ownerSMario = gPlayerSyncTable[np.localIndex]
            
            if (ownerSMario.hasShine ~= o.oBehParams) then -- fix "fake shine" bug
                if o.oTimer > 10 then -- ten frames to prevent instant loss
                    print("False shine owner detected, fixing issue")
                    o.oShineOwner = -1
                    if o.oAction == 0 then
                        cur_obj_change_action(1)
                    end
                    send = true
                end
            else
                local ownerM = gMarioStates[np.localIndex]
                o.oTimer = 0
                o.oPosX = ownerM.pos.x
                o.oPosY = ownerM.pos.y + 250
                o.oPosZ = ownerM.pos.z
                if np.localIndex == 0 then
                    --gPlayerSyncTable[0].hasShine = o.oBehParams
                    send = true
                end
            end
        else
            print("Shine owner is not active, fixing issue")
            o.oShineOwner = -1
            if o.oAction == 0 then
                cur_obj_change_action(1)
            end
            send = true
        end
    elseif gPlayerSyncTable[0].hasShine == o.oBehParams and o.oTimer > 10 then -- prevent "false owner" bug
        print("I don't actually have the shine! Fixing issue...")
        gPlayerSyncTable[0].hasShine = 0
    elseif m and sMario.hasShine == 0 and (not sMario.spectator) and (o.oInteractStatus & INT_STATUS_INTERACTED) ~= 0 and (o.oAction == 0 or o.oTimer > 30) then -- interaction (only if shine has not been dropped recently)
        local np = gNetworkPlayers[m.playerIndex]
        o.oShineOwner = np.globalIndex
        cur_obj_change_action(0)
        
        sMario.hasShine = o.oBehParams
        if m.playerIndex == 0 then -- the player who grabbed the shine sends a global message, to keep things synced
            sentShineMessage = false
            
            m.invincTimer = 90 -- 1.5 seconds (this gets halved)
            send = true
        end

        cur_obj_become_intangible()
    end

    -- for passing, setting the timer directly doesn't work for some reason- so we use action 3
    if o.oAction == 3 then
        cur_obj_change_action(1)
        o.oTimer = 30
    end

    -- handles bouncing and returning
    if o.oAction == 0 and o.oShineOwner == -1 then
        o.oInteractStatus = 0
        cur_obj_become_tangible()
    elseif o.oAction == 1 then -- bouncing on ground
        local stepResult = object_step()
        cur_obj_update_floor()
        o.oFaceAngleYaw = o.oFaceAngleYaw + 0x1000 -- spin faster

        if o.oTimer >= 10 then
            o.oInteractStatus = 0
            cur_obj_become_tangible()
        end

        if o.oFloorType == SURFACE_DEATH_PLANE and (o.oPosY - o.oFloorHeight < 2048) then -- return if fallen
            shine_return(o)
            cur_obj_become_intangible()
            cur_obj_play_sound_1(SOUND_GENERAL_GRAND_STAR_JUMP)
        elseif is_hazard_floor(o.oFloorType)
        and stepResult == OBJ_MOVE_LANDED then -- return if in quicksand or lava
            shine_return(o)
            cur_obj_become_intangible()
            cur_obj_play_sound_1(SOUND_GENERAL_GRAND_STAR_JUMP)
        elseif (o.oForwardVel < 2 and o.oVelY < 1) or (stepResult == OBJ_MOVE_LANDED and o.oTimer > 300) then -- sometimes the shine gets stuck on slopes, so stop automatically after 10 seconds
            cur_obj_play_sound_1(SOUND_GENERAL_GRAND_STAR_JUMP)
            if is_hazard_floor(o.oFloorType) then
                -- prevent shine from getting stuck on these floors
                shine_return(o)
                cur_obj_become_intangible()
            elseif thisLevel and thisLevel.shineDefaultHeight then -- for fire sea
                o.oForwardVel = 0
                o.oPosY = thisLevel.shineDefaultHeight
                cur_obj_change_action(0)
            elseif find_water_level(o.oPosX, o.oPosZ) > o.oFloorHeight then -- stay in place in water
                o.oForwardVel = 0
                cur_obj_change_action(0)
            else
                o.oForwardVel = 0
                o.oPosY = o.oFloorHeight + 160 -- Mario is 161 units tall; thus Mario is just barely able to pick this up without jumping
                cur_obj_change_action(0)
            end
        elseif stepResult == OBJ_MOVE_LANDED then
            cur_obj_play_sound_1(SOUND_GENERAL_GRAND_STAR_JUMP)
        end

        if m.playerIndex == 0 then send = true end
    elseif o.oAction == 2 then -- return to home if off stage (from star code)
        obj_move_xyz_using_fvel_and_yaw(o)
        o.oStarSpawnUnkFC = o.oStarSpawnUnkFC + o.oVelY -- why?
        o.oPosY = o.oStarSpawnUnkFC + sins((o.oTimer * 0x8000) / 30) * 400 -- why?
        o.oFaceAngleYaw = o.oFaceAngleYaw + 0x1000 -- spin faster
        if (o.oTimer == 30) then -- always returns after 1 second
            o.oPosX = o.oHomeX
            o.oPosY = o.oHomeY
            o.oPosZ = o.oHomeZ

            cur_obj_change_action(0)
            o.oInteractStatus = 0
            cur_obj_become_tangible()
            o.oForwardVel = 0
        end

        if m.playerIndex == 0 then send = true end
    end

    -- send data if we're holding the shine, or if we're the closest if no one is holding it
    if send then
        network_send_object(o, true)
    end
end
bhvShine = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_shine_init, bhv_shine_loop, "bhvShine")

-- uses the same formula as stars
function shine_return(shine)
    shine.oMoveAngleYaw = atan2s(shine.oHomeZ - shine.oPosZ, shine.oHomeX - shine.oPosX)
    shine.oShineDistFromHome = math.sqrt(sqrf(shine.oHomeX - shine.oPosX) + sqrf(shine.oHomeZ - shine.oPosZ))
    shine.oVelY = (shine.oHomeY - shine.oPosY) / 30
    shine.oForwardVel = shine.oShineDistFromHome / 30
    shine.oStarSpawnUnkFC = shine.oPosY
    shine.oTimer = 0
    shine.oAction = 2
    shine.oInteractStatus = 0
end

function lose_shine(index,dropType)
    local m = gMarioStates[index]
    local sMario = gPlayerSyncTable[index]
    local np = gNetworkPlayers[index]

    if index == 0 and sentShineMessage and dropType ~= 2 and dropType ~= 3 then
        local playerColor = network_get_player_text_color_string(0)
        if lastAttacker == 0 then
            djui_popup_create_global(string.format("%s\\#ffffff\\ dropped the \\#ffff40\\Shine\\#ffffff\\!",playerColor..np.name), 1)
        else
            local aPlayerColor = network_get_player_text_color_string(lastAttacker)
            local aNP = gNetworkPlayers[lastAttacker]
            local aName = aNP.name
            if aNP.connected then
                djui_popup_create_global(string.format("%s\\#ffffff\\ made %s\\#ffffff\\\ndrop the \\#ffff40\\Shine\\#ffffff\\!",aPlayerColor..aName,playerColor..np.name), 1)
            else
                djui_popup_create_global(string.format("%s\\#ffffff\\ dropped the \\#ffff40\\Shine\\#ffffff\\!",playerColor..np.name), 1)
            end
            lastAttacker = 0
        end
    elseif dropType == 1 then
        djui_popup_create("The \\#ffff40\\Shine\\#ffffff\\ was dropped!",1) -- on disconnect, don't use name
    end

    
    local shine = obj_get_first_with_behavior_id_and_field_s32(bhvShine, 0x40, (sMario.hasShine or 0))
    sMario.hasShine = 0
    if shine and (dropType == 3 or shine.oShineOwner == np.globalIndex) then
        shine.oShineOwner = -1
        shine.oTimer = 0
        if dropType == 1 then -- fell off stage
            shine_return(shine)
        elseif dropType == 2 then -- pass
            shine.oVelY = 0
            shine.oAction = 3
            shine.oForwardVel = m.forwardVel + 25
            shine.oMoveAngleYaw = m.intendedYaw
            shine.oTimer = 30
            shine.oInteractStatus = 0
            obj_become_tangible(shine)
        elseif dropType == 3 then -- steal/start game (owner is set outside of this)
            shine.oVelY = 0
            shine.oAction = 0
            shine.oForwardVel = 0
            shine.oInteractStatus = 0
        else -- standard interaction
            shine.oVelY = 50
            shine.oAction = 1
            shine.oForwardVel = 20
            shine.oMoveAngleYaw = math.random(0, 0xFFFF) -- random; any direction
        end
    else
        return nil
    end
    
    return shine
end

-- command to reset shine
function reset_shine_command(msg)
    if not (network_is_server() or network_is_moderator()) then
        djui_chat_message_create("You lack the power, young one.")
        return true
    end

    network_send_include_self(true, {
        id = PACKET_RESET_SHINE,
    })
    return true
end
hook_chat_command("reset","- Resets the shine",reset_shine_command)

-- command to move shine
function move_shine_command(msg)
    if not (network_is_server() or network_is_moderator()) then
        djui_chat_message_create("You lack the power, young one.")
        return true
    end

    network_send_include_self(true, {
        id = PACKET_MOVE_SHINE,
        mover = gNetworkPlayers[0].globalIndex,
    })
    return true
end
hook_chat_command("move"," - Moves the shine to where you are standing",move_shine_command)

-- pipes
--- @param o Object
function st_pipe_init(o)
    local hitbox = get_temp_object_hitbox()
    hitbox.interactType = INTERACT_WATER_RING -- we already disable INTERACT_WARP
    hitbox.radius = 100
    hitbox.height = 220 -- a lot easier to enter than a normal pipe
    obj_set_hitbox(o, hitbox)

    o.collisionData = smlua_collision_util_get("warp_pipe_seg3_collision_03009AC8")
    load_object_collision_model()
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)
    --network_init_object(o, false, {})
end
--- @param o Object
function st_pipe_loop(o)
    local m = nearest_mario_state_to_object(o)
    if m and (o.oInteractStatus & INT_STATUS_INTERACTED) ~= 0 then
        local pair = obj_get_first_with_behavior_id_and_field_s32(bhvSTPipe, 0x40, o.oBehParams2ndByte) -- 0x40 is "oBehParams"
        if pair then
            drop_and_set_mario_action(m, ACT_TRIPLE_JUMP, 1)
            m.pos.x = pair.oPosX
            m.pos.y = pair.oPosY + 160
            m.peakHeight = m.pos.y
            m.pos.z = pair.oPosZ
            m.vel.y = 65
            m.faceAngle.y = pair.oFaceAngleYaw
            --m.actionTimer = 11
            cur_obj_play_sound_1(SOUND_MENU_ENTER_PIPE)
            if m.playerIndex == 0 then
                soft_reset_camera(m.area.camera)
            end
        end
        o.oInteractStatus = 0
    end
    load_object_collision_model()
end
bhvSTPipe = hook_behavior(nil, OBJ_LIST_SURFACE, true, st_pipe_init, st_pipe_loop, "bhvSTPipe")

-- very similar to the red coin one, but doesn't drop to floor
--- @param o Object
function shine_marker_init(o)
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)
    cur_obj_scale(1.5)
    o.header.gfx.scale.z = 0.75
    network_init_object(o, false, nil)
end
--- @param o Object
function shine_marker_loop(o)
    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x100
    o.oFaceAnglePitch = 0x4000
end
bhvShineMarker = hook_behavior(nil, OBJ_LIST_DEFAULT, true, shine_marker_init, shine_marker_loop)

-- somewhat based on the arena bob-omb
--- @param o Object
function thrown_bomb_init(o)
    o.oFlags = (OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)
    o.oAnimations = gObjectAnimations.bobomb_seg8_anims_0802396C
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oHeldState = HELD_THROWN
    o.oAction = 0
    o.oGravity = 2.5
    o.oVelY = 20
    o.oBuoyancy = 1.5
    o.oAnimState = 0

    local hitbox = get_temp_object_hitbox()
    hitbox.damageOrCoinValue = 2
    hitbox.radius = 200
    hitbox.height = 200
    hitbox.hurtboxRadius = 200
    hitbox.hurtboxHeight = 200
    hitbox.downOffset = 200
    hitbox.interactType = INTERACT_DAMAGE
    obj_set_hitbox(o, hitbox)

    cur_obj_init_animation(1)
    network_init_object(o, false, {
        'oAnimState', -- explode on contact
    })
end
--- @param o Object
function thrown_bomb_loop(o)
    if o.oAction ~= 1 then
        local collisionFlags = object_step();
        if o.oAnimState == -1 or (o.oInteractStatus & INT_STATUS_INTERACTED) ~= 0 or ((collisionFlags & OBJ_COL_FLAG_GROUNDED) ~= 0) or o.oTimer > 300 then
            cur_obj_change_action(1)
            obj_set_model_extended(o, E_MODEL_EXPLOSION)
            obj_set_billboard(o)
            bhv_explosion_init()

            o.oAnimState = -1
            if (o.oInteractStatus & INT_STATUS_INTERACTED) ~= 0 then
                network_send_object(o, true)
            end
        end
    else 
        bhv_explosion_loop()
        o.oAnimState = o.oAnimState + 1
    end
end
bhvThrownBobomb = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, thrown_bomb_init, thrown_bomb_loop)

-- delete shells if their action is not riding
function delete_shell_if_not_ride(o)
    if o.oAction ~= 1 then
        o.activeFlags = ACTIVE_FLAG_DEACTIVATED
    end
end
id_bhvKoopaShell = hook_behavior(id_bhvKoopaShell, OBJ_LIST_LEVEL, false, delete_shell_if_not_ride, nil)

-- fix bowser
function custom_bowser_loop(o)
    if gGlobalSyncTable.gameState == 1 then
        cur_obj_change_action(14)
        o.oForwardVel = 0
    end
end
hook_behavior(id_bhvBowser, OBJ_LIST_GENACTOR, false, nil, custom_bowser_loop, "id_bhvBowser")

-- delete objects
local id_level_exception = {
    [id_bhvLllRotatingHexFlame] = 1,
    [id_bhvBowserFlameSpawn] = 1,
    [id_bhvFlameBowser] = 1,
    [id_bhvFlameMovingForwardGrowing] = 1,
    [id_bhvMrIParticle] = 1,
    [id_bhvFlame] = 1,
    [id_bhvWarp] = 1,
    [id_bhvFadingWarp] = 1,
    [id_bhvKoopaShell] = 1,
    [id_bhvKoopaShellUnderwater] = 1,
}
local id_delete = {
    [id_bhvBowserBomb] = 1,
    [id_bhvCannonBarrel] = 1,
    [id_bhvBlueCoinSwitch] = 1,
    [id_bhvMessagePanel] = 1,
    [id_bhvBobombBuddy] = 1,
    [id_bhvBobombBuddyOpensCannon] = 1,
    [id_bhvChuckya] = 1,
    [id_bhvWaterLevelDiamond] = 1,
    [id_bhvWarpPipe] = 1,
    [id_bhvTweester] = 1,
    [id_bhvExclamationBox] = 1,
    [id_bhvRedCoinStarMarker] = 1,
    [id_bhvTreasureChestBottom] = 1,
    [id_bhvTreasureChestTop] = 1,
    [id_bhvDoor] = 1,
    [id_bhvStarDoor] = 1,
    [id_bhvHmcElevatorPlatform] = 1,
    [id_bhvPyramidElevator] = 1,
}
for id,v in pairs(id_delete) do
    hook_behavior(id, OBJ_LIST_DEFAULT, true, obj_mark_for_deletion, nil)
end
--- @param o Object
function delete_level(o)
    local id = get_id_from_behavior(o.behavior)
    if id == id_bhvStar then
        table.insert(spawn_potential, {o.oPosX,o.oPosY,o.oPosZ})
        obj_mark_for_deletion(o)
    elseif ((get_object_list_from_behavior(o.behavior) == OBJ_LIST_LEVEL and (not id_level_exception[id]) and id ~= bhvShine)) then
        obj_mark_for_deletion(o)
    end
end
hook_event(HOOK_OBJECT_SET_MODEL, delete_level)

-- name: Remove Star Spawn Cutscenes
-- description: Created by Sunk.

function remove_timestop()
    ---@type MarioState
    local m = gMarioStates[0]
    ---@type Camera
    local c = gMarioStates[0].area.camera

    if m == nil or c == nil then
        return
    end

    if ((c.cutscene == CUTSCENE_STAR_SPAWN) or (c.cutscene == CUTSCENE_RED_COIN_STAR_SPAWN) or (c.cutscene == CUTSCENE_ENTER_BOWSER_ARENA) or (c.cutscene == CUTSCENE_GRAND_STAR)) then
        print("disabled cutscene")
        disable_time_stop_including_mario()
        m.freeze = 0
        c.cutscene = 0
    end
end
hook_event(HOOK_UPDATE, remove_timestop)

-- arena map support starts here
function replace_shine(o)
    table.insert(spawn_potential, {o.oPosX,o.oPosY,o.oPosZ})
    obj_mark_for_deletion(o)
end
id_bhvArenaFlag = hook_behavior(nil, OBJ_LIST_LEVEL, false, replace_shine, nil, "bhvArenaFlag")


function replace_spawn(o)
    if arenaSpawnLocations == nil or arenaSpawnLocations[0] == nil then
        arenaSpawnLocations = {}
        arenaSpawnLocations[0] = {o.oPosX, o.oPosY, o.oPosZ}
    else
        table.insert(arenaSpawnLocations, {o.oPosX, o.oPosY, o.oPosZ})
    end
    obj_mark_for_deletion(o)
end
id_bhvArenaSpawn = hook_behavior(nil, OBJ_LIST_LEVEL, false, replace_spawn, nil, "bhvArenaSpawn")

function replace_spring(o)
    o.oBehParams = 0x1
    o.oBehParams2ndByte = 0x1
    obj_set_model_extended(o, E_MODEL_BITS_WARP_PIPE)
    st_pipe_init(o)
end
id_bhvArenaSpring = hook_behavior(nil, OBJ_LIST_SURFACE, false, replace_spring, st_pipe_loop, "bhvArenaSpring")

-- don't use these
id_bhvArenaItem = hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaItem")
id_bhvArenaKoth = hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaKoth")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaItemHeld")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaKothActive")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaBobomb")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCannonBall")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaChildFlame")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaFlame")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaSparkle")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom001")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom002")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom003")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom004")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom005")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom006")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom007")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom008")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom009")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom010")
hook_behavior(nil, OBJ_LIST_LEVEL, false, obj_mark_for_deletion, nil, "bhvArenaCustom011")