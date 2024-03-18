-- This file handles the shine, pipes, and deleted objects

define_custom_obj_fields({
    oObjectOwner = "s32",       -- The global index of the player who owns this item. This used to be used for the shine too
    oShineDistFromHome = "f32", -- oStarSpawnDisFromHome screws up for some reason
})

-- The shine is built off the star, obviously
--- @param o Object
function bhv_shine_init(o)
    local shine = obj_get_first_with_behavior_id_and_field_s32(id_bhvShine, 0x40, o.oBehParams)
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
    o.oInteractStatus = 0

    -- By sending packets manually, we can only send packets when necessary
    network_init_object(o, false, {
        'oPosX',
        'oPosY',
        'oPosZ',
        'oVelY',
        'oForwardVel',
        'oMoveAngleYaw',
        'oTimer',
        'oAction',
        'oHomeX',
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
    local shineOwner = get_shine_owner(o.oBehParams)

    if shineOwner ~= -1 then -- go above owner's head
        local np = network_player_from_global_index(shineOwner)
        if network_is_server() then o.oAction = 0 end
        if np and np.connected and is_player_active(gMarioStates[np.localIndex]) then
            local ownerM = gMarioStates[np.localIndex]
            o.oTimer = 0
            o.oPosX = ownerM.pos.x
            o.oPosY = ownerM.pos.y + 250
            o.oPosZ = ownerM.pos.z
            if network_is_server() then
                send = true
            end
        elseif network_is_server() then
            print("Shine owner is not active, fixing issue")
            shineOwner = set_player_owned_shine(-1, o.oBehParams)
            if o.oAction == 0 then
                cur_obj_change_action(1)
            end
            send = true
        end
    elseif m and get_player_owned_shine(m.playerIndex) == 0
        and network_is_server() and gGlobalSyncTable.gameState ~= 1
        and not sMario.spectator
        and dist_between_objects(o, m.marioObj) <= 275
        and (o.oAction == 0 or o.oTimer > 30) then -- interaction (only if shine has not been dropped recently) handled by the server
        -- set shine owner to the collecter
        shineOwner = set_player_owned_shine(m.playerIndex, o.oBehParams)
        cur_obj_change_action(0)
        cur_obj_become_intangible()
        -- create popup + sound
        network_send_include_self(true, {
            id = PACKET_GRAB_SHINE,
            grabbed = gNetworkPlayers[m.playerIndex].globalIndex,
        })
        -- send object
        send = true
    end

    -- passing action
    if o.oAction == 3 and network_is_server() then
        cur_obj_change_action(1)
        o.oTimer = 15
    end

    -- handles bouncing and returning
    if o.oAction == 0 and shineOwner == -1 and network_is_server() then
        cur_obj_become_tangible()
        cur_obj_update_floor()
        if is_hazard_floor(o.oFloorType) and cur_obj_lateral_dist_to_home() > 1 and (o.oFloorType == SURFACE_DEATH_PLANE or o.oFloorType == SURFACE_VERTICAL_WIND or gGlobalSyncTable.variant ~= 3 or thisLevel.badLava) then
            shine_return(o)
            cur_obj_become_intangible()
        end
    elseif o.oAction == 1 and network_is_server() then -- bouncing on ground
        local prevY = o.oPosY
        local stepResult = object_step_without_floor_orient()
        cur_obj_update_floor()

        -- prevent ceiling clip
        if o.oFloorHeight > prevY and o.oVelY > 0 then
            o.oPosY = prevY
            o.oVelY = 0
        end

        o.oFaceAngleYaw = o.oFaceAngleYaw + 0x1000 -- spin faster

        if o.oTimer >= 10 then
            cur_obj_become_tangible()
        end

        if o.oFloorType == SURFACE_DEATH_PLANE or o.oFloorType == SURFACE_VERTICAL_WIND and (o.oPosY - o.oFloorHeight < 2048) then -- return if fallen
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
                o.oPosY = o.oFloorHeight +
                160                            -- Mario is 161 units tall; thus Mario is just barely able to pick this up without jumping
                cur_obj_change_action(0)
            end
        elseif stepResult == OBJ_MOVE_LANDED then
            cur_obj_play_sound_1(SOUND_GENERAL_GRAND_STAR_JUMP)
        end

        send = true
    elseif o.oAction == 2 and network_is_server() then                     -- return to home if off stage (from star code)
        obj_move_xyz_using_fvel_and_yaw(o)
        o.oStarSpawnUnkFC = o.oStarSpawnUnkFC + o.oVelY                    -- why?
        o.oPosY = o.oStarSpawnUnkFC + sins((o.oTimer * 0x8000) / 30) * 400 -- why?
        o.oFaceAngleYaw = o.oFaceAngleYaw + 0x1000                         -- spin faster
        if (o.oTimer == 30) then                                           -- always returns after 1 second
            o.oPosX = o.oHomeX
            o.oPosY = o.oHomeY
            o.oPosZ = o.oHomeZ

            cur_obj_change_action(0)
            cur_obj_become_tangible()
            o.oForwardVel = 0
        end

        send = true
    end

    o.oInteractStatus = 0

    -- send object data to clients
    if send then
        network_send_object(o, true)
    end
end

id_bhvShine = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_shine_init, bhv_shine_loop, "bhvShine")

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

function lose_shine(index, dropType, attacker)
    local ownedShine = get_player_owned_shine(index)
    if ownedShine == 0 then return nil end

    local m = gMarioStates[index]
    local np = gNetworkPlayers[index]

    if dropType ~= 2 and dropType ~= 3 then
        local playerColor = network_get_player_text_color_string(index)
        if attacker == nil then
            djui_popup_create_global(
            string.format("%s\\#ffffff\\ dropped the \\#ffff40\\Shine\\#ffffff\\!", playerColor .. np.name), 1)
        else
            local aPlayerColor = network_get_player_text_color_string(attacker)
            local aNP = gNetworkPlayers[attacker]
            local aName = aNP.name
            if aNP.connected then
                djui_popup_create_global(
                string.format("%s\\#ffffff\\ made %s\\#ffffff\\\ndrop the \\#ffff40\\Shine\\#ffffff\\!",
                    aPlayerColor .. aName, playerColor .. np.name), 1)
            else
                djui_popup_create_global(
                string.format("%s\\#ffffff\\ dropped the \\#ffff40\\Shine\\#ffffff\\!", playerColor .. np.name), 1)
            end
        end
    elseif dropType == 3 then
        network_send_include_self(true, {
            id = PACKET_GRAB_SHINE,
            grabbed = np.globalIndex,
            stealer = gNetworkPlayers[attacker].globalIndex,
        })
    end

    local shine = obj_get_first_with_behavior_id_and_field_s32(id_bhvShine, 0x40, ownedShine)

    if shine and network_is_server() then
        shine.oTimer = 0
        if dropType == 1 then     -- fell off stage
            shine_return(shine)
        elseif dropType == 2 then -- pass
            shine.oVelY = 0
            shine.oAction = 3

            -- pass to closest teammate
            local vel = 50
            local angle = m.intendedYaw
            local yDist = 0
            local team = gPlayerSyncTable[m.playerIndex].team
            local minDist = 3000
            for i = 0, MAX_PLAYERS - 1 do
                if m.playerIndex ~= i and gPlayerSyncTable[i].team == team then
                    local player = gMarioStates[i].marioObj
                    local dist = dist_between_objects(m.marioObj, player)
                    if minDist > dist then
                        minDist = dist
                        angle = obj_angle_to_object(shine, player)
                        yDist = shine.oPosY - gMarioStates[i].pos.y
                    end
                end
            end

            -- calculate velocity for perfect shot
            if yDist > 0 then
                vel = math.min((minDist / math.sqrt(0.8 * yDist)), vel)
            end

            shine.oForwardVel = vel
            shine.oMoveAngleYaw = angle
            shine.oTimer = 15
            shine.oInteractStatus = 0
            obj_become_tangible(shine)
        elseif dropType == 3 then -- steal
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

        if dropType ~= 3 then
            set_player_owned_shine(-1, ownedShine)
        else
            set_player_owned_shine(attacker, ownedShine)
        end
        network_send_object(shine, true)
    end
    return shine
end

function drop_shine(index, dropType, attacker)
    if not network_is_server() then
        -- send drop packet to server
        local owner = nil
        if index ~= nil then owner = network_global_index_from_local(index) end
        local globalAttacker = nil
        if attacker ~= nil then globalAttacker = network_global_index_from_local(attacker) end
        network_send_to(1, true, {
            id = PACKET_DROP_SHINE,
            owner = owner,
            dropType = dropType,
            attacker = globalAttacker,
        })
    else
        -- drop shine
        lose_shine(index, dropType, attacker)
    end
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

hook_chat_command("reset", "- Resets the shine", reset_shine_command)

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

hook_chat_command("move", " - Moves the shine to where you are standing", move_shine_command)

-- pipes
--- @param o Object
function st_pipe_init(o)
    local hitbox = get_temp_object_hitbox()
    hitbox.interactType = INTERACT_WATER_RING -- we already disable INTERACT_WARP
    hitbox.radius = 100
    hitbox.height = 220                       -- a lot easier to enter than a normal pipe
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
        local pair = obj_get_first_with_behavior_id_and_field_s32(id_bhvSTPipe, 0x40, o.oBehParams2ndByte) -- 0x40 is "oBehParams"
        if pair then
            if pair.oFaceAnglePitch >= 0 then
                drop_and_set_mario_action(m, ACT_TRIPLE_JUMP, 1)
                m.pos.y = pair.oPosY + 160
                m.vel.y = 65
            else
                drop_and_set_mario_action(m, ACT_FREEFALL, 1)
                mario_set_forward_vel(m, 0)
                m.pos.y = pair.oPosY - 320
                m.vel.y = math.min(0, m.vel.y)
                m.marioObj.oPosY = m.pos.y -- fix weird issue where the player bounces and ends up in the void
            end

            m.pos.x = pair.oPosX
            m.peakHeight = m.pos.y
            m.pos.z = pair.oPosZ
            m.faceAngle.y = pair.oFaceAngleYaw
            --m.actionTimer = 11
            cur_obj_play_sound_1(SOUND_MENU_ENTER_PIPE)
            if m.playerIndex == 0 then
                -- TODO: Set camera yaw to behind mario
                soft_reset_camera(m.area.camera)
                center_rom_hack_camera()
            end
        end
        o.oInteractStatus = 0
    end
    load_object_collision_model()
end

id_bhvSTPipe = hook_behavior(nil, OBJ_LIST_SURFACE, true, st_pipe_init, st_pipe_loop, "bhvSTPipe")
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
    if not o.parentObj then return end
    o.oPosX = o.parentObj.oHomeX
    o.oPosY = o.parentObj.oHomeY - 120
    o.oPosZ = o.parentObj.oHomeZ
end

id_bhvShineMarker = hook_behavior(nil, OBJ_LIST_DEFAULT, true, shine_marker_init, shine_marker_loop, "bhvShineMarker")

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

id_bhvThrownBobomb = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, thrown_bomb_init, thrown_bomb_loop, "bhvThrownBobomb")

-- item boxes!
function item_box_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oOpacity = 100
    local hitbox = get_temp_object_hitbox()
    hitbox.interactType = INTERACT_WATER_RING -- Don't want to have INTERACT_STAR because it has hard-coded behavior
    hitbox.radius = 80
    hitbox.height = 50
    obj_set_hitbox(o, hitbox)
    
    network_init_object(o, false, {
        'oTimer',
        'oAction',
    })
end

function item_box_loop(o)
    local m = nearest_mario_state_to_object(o)

    if o.oAction == 0 then
        cur_obj_enable_rendering_and_become_tangible(o)
        cur_obj_scale(1)
    elseif o.oAction == 1 then
        if o.oTimer == 1 then
            spawn_triangle_break_particles(4, 0x8B, 0.25, 0) -- MODEL_CARTOON_STAR
        end
        cur_obj_become_intangible()
        if o.oTimer < 5 then
            cur_obj_scale_over_time(7, 5, 1, 0)
        elseif o.oTimer < 120 then
            cur_obj_disable_rendering()
        else
            cur_obj_enable_rendering()
            cur_obj_change_action(2)
        end
    elseif o.oTimer < 5 then
        cur_obj_scale_over_time(7, 5, 0, 1)
    else
        cur_obj_change_action(0)
        cur_obj_scale(1)
    end
    o.oFaceAngleYaw = o.oFaceAngleYaw + 100

    local sMario = gPlayerSyncTable[m.playerIndex]
    if o.oAction == 0 and o.oInteractStatus ~= 0 and m.playerIndex == 0 and sMario.item == 0 then
        cur_obj_change_action(1)
        o.oTimer = 0
        local item = random_item()
        sMario.item = item
        sMario.itemUses = 0
        cur_obj_play_sound_1(SOUND_GENERAL_COLLECT_1UP)
        djui_chat_message_create(tostring(item))
        network_send_object(o, true)
    end
    o.oInteractStatus = 0
end

id_bhvItemBox = hook_behavior(nil, OBJ_LIST_GENACTOR, true, item_box_init, item_box_loop, "bhvItemBox")

-- held items by players (wip)
function held_item_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oFaceAnglePitch = 0
    o.oFaceAngleYaw = 0
end
function held_item_loop(o)
    if o.hookRender == 0 then return end
    local sMario = gPlayerSyncTable[o.hookRender-1]
    local m = gMarioStates[o.hookRender-1]
    if sMario.item == nil or sMario.item == 0 or is_player_active(m) == 0 then
        cur_obj_disable_rendering()
        return
    end
    local data = item_data[sMario.item]

    if data.hand then
        o.oFaceAngleYaw = 0
        if o.unused1 ~= 0 then
            cur_obj_disable_rendering()
        else
            cur_obj_enable_rendering()
        end
    else -- spin around player
        cur_obj_enable_rendering()
        local dir = o.oTimer * 1024 + (o.unused1 * 21845) -- add 1/3 distance for animstate
        if o.oTimer >= 64 then
            o.oTimer = 0
        end
        local dist = 120

        -- spawn extra items for triples/doubles
        local count = data.count or 1
        if o.unused1 < count-1 and (o.parentObj == o or o.parentObj == nil) then
            local newObj = spawn_non_sync_object(id_bhvHeldItem, E_MODEL_NONE, o.oPosX, o.oPosY, o.oPosZ, nil)
            o.parentObj = newObj
            newObj.unused1 = o.unused1 + 1
            newObj.hookRender = o.hookRender
        elseif o.unused1 > count-1 then
            cur_obj_disable_rendering()
            return
        end

        o.oPosX = m.pos.x + sins(dir) * dist
        o.oPosY = m.pos.y + 40 + (data.yOffset or 0)
        o.oPosZ = m.pos.z + coss(dir) * dist

        if data.bill then
            obj_set_billboard(o)
        else
            o.header.gfx.node.flags = o.header.gfx.node.flags & ~GRAPH_RENDER_BILLBOARD
            o.oFaceAngleYaw = o.oFaceAngleYaw + 0x800
        end
    end
    cur_obj_scale(data.scale or 1)
end
id_bhvHeldItem = hook_behavior(nil, OBJ_LIST_DEFAULT, true, held_item_init, held_item_loop, "bhvHeldItem")

-- item rendering
function on_obj_render(o)
    if get_id_from_behavior(o.behavior) ~= id_bhvHeldItem then return end
    local sMario = gPlayerSyncTable[o.hookRender-1]
    local m = gMarioStates[o.hookRender-1]
    if sMario.item == nil or sMario.item == 0 or is_player_active(m) == 0 then
        return
    end

    local data = item_data[sMario.item]
    local model = data.model or E_MODEL_GOOMBA
    obj_set_model_extended(o, model)
    if data.hand then
        o.oPosX = get_hand_foot_pos_x(m, 0)
        o.oPosY = get_hand_foot_pos_y(m, 0) + (data.yOffset or 0)
        o.oPosZ = get_hand_foot_pos_z(m, 0)
    end
end
hook_event(HOOK_ON_OBJECT_RENDER, on_obj_render)

-- custom shells that only do the ride action (slightly based on shell rush (gamemode))
function custom_shell_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE

    o.oWallHitboxRadius = 30
    o.oGravity = -4
    o.oBounciness = -0.5
    o.oDragStrength = 1
    o.oFriction = 10
    o.oBuoyancy = 2
end

function custom_shell_loop(o)
    if o.heldByPlayerIndex < MAX_PLAYERS then
        local m = gMarioStates[o.heldByPlayerIndex]

        if m.action & ACT_FLAG_RIDING_SHELL == 0 then
            obj_mark_for_deletion(o)
            return
        end

        local player = m.marioObj
        if player then
            obj_copy_pos(o, player)
        end
        local sp34 = cur_obj_update_floor_height_and_get_floor()
        if math.abs(find_water_level(o.oPosX, o.oPosZ) - o.oPosY) < 10.0 then
            koopa_shell_spawn_water_drop(o)
        elseif 5.0 > math.abs(o.oPosY - o.oFloorHeight) then
            if sp34 ~= nil and sp34.type == 1 then
                bhv_koopa_shell_flame_spawn(o)
            else
                koopa_shell_spawn_sparkles(o, 10.0)
            end
        else
            koopa_shell_spawn_sparkles(o, 10.0)
        end
        if player then
            o.oFaceAngleYaw = player.oMoveAngleYaw
        end

        if o.oInteractStatus & INT_STATUS_STOP_RIDING ~= 0 then
            spawn_mist_particles()
            o.oInteractStatus = 0
            o.heldByPlayerIndex = 0
            obj_mark_for_deletion(o)
        end
    end
end

function koopa_shell_spawn_water_drop(o)
    spawn_non_sync_object(id_bhvObjectWaveTrail, E_MODEL_WAVE_TRAIL, o.oPosX, o.oPosY, o.oPosZ, nil)
    if (o.heldByPlayerIndex < MAX_PLAYERS) then
        if (gMarioStates[o.heldByPlayerIndex].forwardVel > 10.0) then
            local drop = spawn_non_sync_object(id_bhvWaterDroplet, E_MODEL_WHITE_PARTICLE_SMALL, o.oPosX, o.oPosY,
                o.oPosZ, function(d) obj_scale(d, 1.5) end)
            if drop then
                drop.oVelY = math.random() * 30.0
                obj_translate_xz_random(drop, 110.0)
            end
        end
    end
end

function bhv_koopa_shell_flame_spawn(o)
    for i = 0, 1 do
        spawn_non_sync_object(id_bhvKoopaShellFlame, E_MODEL_RED_FLAME, o.oPosX, o.oPosY, o.oPosZ, nil)
    end
end

function koopa_shell_spawn_sparkles(o, a)
    local sp1C = spawn_non_sync_object(id_bhvSparkleSpawn, E_MODEL_NONE, o.oPosX, o.oPosY, o.oPosZ, nil)
    if not sp1C then return end
    sp1C.oPosY = sp1C.oPosY + a
end

id_bhvSTShell = hook_behavior(nil, OBJ_LIST_LEVEL, true, custom_shell_init, custom_shell_loop, nil)

-- fix bowser
function custom_bowser_loop(o)
    if gGlobalSyncTable.gameState == 1 or o.oAction == 5 then
        cur_obj_change_action(14)
        o.oForwardVel = 0
    elseif o.oAction == 2 and o.oSubAction == 1 and o.oTimer > 30 then -- fix softlock?
        o.oMoveAngleYaw = o.oBowserAngleToCentre
        o.oVelY = 150
        o.oBowserUnk1AC = 0xFF
        o.oBowserUnkF8 = 0
        o.oSubAction = 2
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
    [id_bhvKoopaShellUnderwater] = 1,
    [id_bhvSTShell] = 1,
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
    [id_bhvTuxiesMother] = 1,
    [id_bhvPenguinBaby] = 1,
    [id_bhvSmallPenguin] = 1,
}
for id, v in pairs(id_delete) do
    hook_behavior(id, OBJ_LIST_DEFAULT, true, obj_mark_for_deletion, nil)
end
--- @param o Object
function delete_level(o)
    local id = get_id_from_behavior(o.behavior)
    if id == id_bhvStar then
        table.insert(spawn_potential, { o.oPosX, o.oPosY, o.oPosZ })
        obj_mark_for_deletion(o)
    elseif ((get_object_list_from_behavior(o.behavior) == OBJ_LIST_LEVEL and (not id_level_exception[id]) and id ~= id_bhvShine)) then
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
already_spawn = {}
function replace_shine(o)
    if not already_spawn[o] then
        table.insert(spawn_potential, { o.oPosX, o.oPosY, o.oPosZ })
        already_spawn[o] = 1
    end
    obj_mark_for_deletion(o)
end

id_bhvArenaFlag = hook_behavior(nil, OBJ_LIST_LEVEL, false, replace_shine, nil, "bhvArenaFlag")

function replace_spawn(o)
    if not already_spawn[o] then
        if arenaSpawnLocations == nil or arenaSpawnLocations[0] == nil then
            arenaSpawnLocations = {}
            arenaSpawnLocations[0] = { o.oPosX, o.oPosY, o.oPosZ }
        else
            table.insert(arenaSpawnLocations, { o.oPosX, o.oPosY, o.oPosZ })
        end
        already_spawn[o] = 1
    end
    obj_mark_for_deletion(o)
end

id_bhvArenaSpawn = hook_behavior(nil, OBJ_LIST_LEVEL, false, replace_spawn, nil, "bhvArenaSpawn")

function replace_item(o)
    if not already_spawn[o] then
        table.insert(itemBoxLocations, { o.oPosX, o.oPosY, o.oPosZ })
        already_spawn[o] = 1
    end
    obj_mark_for_deletion(o)
end

id_bhvArenaItem = hook_behavior(nil, OBJ_LIST_LEVEL, false, replace_item, nil, "bhvArenaItem")

-- don't use these
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
