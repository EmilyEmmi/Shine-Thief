-- this files handles item data, including probability and function

E_MODEL_BANANA = smlua_model_util_get_id("banana_geo")
E_MODEL_MUSHROOM = smlua_model_util_get_id("red_mushroom_geo")
E_MODEL_RED_SHELL = smlua_model_util_get_id("red_shell_geo")
E_MODEL_BOOMERANG = smlua_model_util_get_id("boomerang_geo")
E_MODEL_CAPE = smlua_model_util_get_id("feather_geo")
E_MODEL_POW = smlua_model_util_get_id("pow_block_geo")
E_MODEL_BLUE_SHELL = smlua_model_util_get_id("blue_shell_geo")
E_MODEL_FIRE_FLOWER = smlua_model_util_get_id("fire_flower")
E_MODEL_LIGHTNING = smlua_model_util_get_id("bolt_geo")
E_MODEL_POISON_MUSHROOM = smlua_model_util_get_id("poison_mushroom_geo")

local ITEM_BANANA = 1
local ITEM_MUSHROOM = 2
local ITEM_TRIPLE_MUSHROOM = 3
local ITEM_DOUBLE_MUSHROOM = 4
local ITEM_RED_SHELL = 5
local ITEM_TRIPLE_REDS = 6
local ITEM_DOUBLE_REDS = 7
local ITEM_CAPE = 8
local ITEM_BOOMERANG = 9
local ITEM_STAR = 10
local ITEM_BULLET = 11
local ITEM_POW = 12
local ITEM_TRIPLE_BANANA = 13
local ITEM_DOUBLE_BANANA = 14
local ITEM_FIRE_FLOWER = 15
local ITEM_BOMB = 16
local ITEM_TRIPLE_BOMB = 17
local ITEM_DOUBLE_BOMB = 18
local ITEM_BLUE_SHELL = 19
local ITEM_GREEN_SHELL = 20
local ITEM_TRIPLE_GREENS = 21
local ITEM_DOUBLE_GREENS = 22
local ITEM_BOO = 23
local ITEM_LIGHTNING = 24
local ITEM_POISON_MUSHROOM = 25

-- get a random item (does weight and stuff)
function random_item(index, arena)
    local itemRange, weightRange, maxWeight = get_item_probabilities(index, arena)

    if maxWeight == 0 or #weightRange == 0 then return ITEM_BANANA end -- default
    local value = math.random(1, maxWeight)

    for i, weight in ipairs(weightRange) do
        if value <= weight then
            return itemRange[i] or ITEM_BANANA
        end
    end
    return ITEM_BANANA -- default (shouldn't happen but who knows)
end

-- returns table of item probabilities for the selected player
function get_item_probabilities(index, arena)
    local weightRange = {}
    local itemRange = {}
    local maxWeight = 0
    local sMario = (index ~= -1) and gPlayerSyncTable[index]

    -- after 30 seconds, item probabilities are based on average (not for renegade roundup)
    local first = false
    local scoreDist = 0
    local firstDist = 0
    if index ~= -1 and gMarioStates[index].marioObj.oTimer > 900 and gGlobalSyncTable.gameMode ~= 4 then
        if gGlobalSyncTable.gameMode == 0 and get_player_owned_shine(index) ~= 0 then
            first = true
        end
        
        local average = 0
        local myScore = 0
        local most = 0
        for i=0,MAX_PLAYERS-1 do
            if gNetworkPlayers[i].connected and not gPlayerSyncTable[i].spectator then
                local score = 0
                if gGlobalSyncTable.gameMode ~= 1 then
                    score = get_point_amount(i) or 0
                else
                    score = gPlayerSyncTable[i].balloons or 0
                    score = score * 10
                end
                if i == index then
                    myScore = score
                end
                if score > most then
                    most = score
                end
                average = average + score
            end
        end
        average = average / get_participant_count()

        scoreDist = math.floor(average - myScore)
        firstDist = math.floor(most - average)
        if most == myScore and firstDist > 4 then
            first = true
        end
    end
    if DEBUG_SCORE_DIST ~= 0.1 and DEBUG_SCORE_DIST then scoreDist = DEBUG_SCORE_DIST end
    if scoreDist < -5 then
        first = true
    end

    for item, data in ipairs(item_data) do
        local weight = data.weight
        local valid = true
        if weight == 0 then
            valid = false
        elseif (item == ITEM_BOMB or item == ITEM_TRIPLE_BOMB) and gGlobalSyncTable.variant == 6 then
            valid = false
        elseif (item == ITEM_FIRE_FLOWER) and gGlobalSyncTable.variant == 8 then
            valid = false
        elseif (item == ITEM_CAPE) and gGlobalSyncTable.variant == 9 then
            valid = false
        elseif (item == ITEM_STAR) and gGlobalSyncTable.variant == 10 then
            valid = false
        elseif (item == ITEM_BOOMERANG) and gGlobalSyncTable.variant == 11 then
            valid = false
        elseif data.count and data.count ~= 1 and arena then
            valid = false
        elseif gGlobalSyncTable.gameMode == 4 and sMario and sMario.team == 2 then
            if gGlobalSyncTable.gameTimer < 3600 and data.frantic then -- better items in endgame for law
                weight = weight * 2
            end
        elseif first then
            weight = data.firstWeight or 0
        end

        if (not first) and valid and math.abs(scoreDist) > 5 then
            if data.losingWeight and scoreDist > 0 then -- below average
                weight = weight + math.floor((data.losingWeight - weight) * (scoreDist / 20))
            elseif (not data.losingWeight) and scoreDist < 0 then -- above average
                weight = math.floor(weight * (scoreDist / -3)) -- increase based on distance from average
            end
        end

        -- frantic/skilled
        if valid and gGlobalSyncTable.items > 1 then
            local frantic = data.frantic or false
            if frantic == (gGlobalSyncTable.items == 2) then -- for frantic, frantic items have a higher chance, and vice versa
                weight = weight * 4
            end
        end

        -- increase blue shell odds based on first's distance from average
        if item == ITEM_BLUE_SHELL and firstDist >= 8 then
            weight = weight * math.floor(firstDist / 4)
        end

        if valid and weight > 0 then
            maxWeight = maxWeight + weight
            table.insert(weightRange, maxWeight)
            table.insert(itemRange, item)
        end
    end
    return itemRange, weightRange, maxWeight
end

function use_item(item, dir_, uses)
    local data = item_data[item]
    local dir = dir_
    if dir == 5 then
        dir = data.defaultDir or 1
    end

    if data.func then
        return data.func(dir, uses or 0)
    else
        djui_chat_message_create(tostring(item) .. " " .. tostring(dir))
    end
    return 0, 0 -- nothing
end

function drop_item()
    local dropItem = gPlayerSyncTable[0].item or 0
    if dropItem == 0 then dropItem = shuffleItem or 0 end
    if dropItem == 0 then return end
    local m = gMarioStates[0]
    gPlayerSyncTable[0].item = 0
    gPlayerSyncTable[0].itemUses = 0
    shuffleItem = 0
    local data = item_data[dropItem]
    if not data then return end
    local toSpawn = id_bhvDroppedItem
    local despawn = true
    local count = data.count or 1
    local model = data.arenaModel or data.model
    if data.drop then
        toSpawn = data.drop
        if toSpawn == 0 then toSpawn = id_bhvThrownBobomb end
        despawn = false
    end
    for i=1,count do
        spawn_sync_object(toSpawn, model, m.pos.x, m.pos.y + 80, m.pos.z, function(o)
            o.oVelY = math.random(20, 50)
            o.oForwardVel = math.random(20, 50)
            o.oMoveAngleYaw = math.random(0, 0xFFFF)
            o.oFaceAngleYaw = o.oMoveAngleYaw
            o.oObjectOwner = -1
            o.oBalloonNumber = (despawn and 1) or 0
            o.oBalloonAppearance = dropItem
        end)
    end
end

function use_mushroom()
    play_character_sound(gMarioStates[0], CHAR_SOUND_YAHOO_WAHA_YIPPEE)
    gPlayerSyncTable[0].mushroomTime = 60
end

function throw_banana(dir)
    local m = gMarioStates[0]
    local np = gNetworkPlayers[0]
    set_action_after_throw(m, dir)
    spawn_sync_object(
        id_bhvBanana,
        E_MODEL_BANANA,
        m.pos.x, m.pos.y + 50, m.pos.z,
        function(o)
            if dir ~= 3 then
                if dir == 1 then
                    o.oForwardVel = m.forwardVel + 50
                else
                    o.oForwardVel = 50
                end
                o.oVelY = 50
                o.oMoveAngleYaw = m.faceAngle.y + (dir - 1) * 0x4000
            else
                o.oForwardVel = -10
                o.oVelY = 0
                o.oMoveAngleYaw = m.faceAngle.y
            end

            o.oFaceAngleYaw = o.oMoveAngleYaw
            o.oObjectOwner = np.globalIndex
        end
    )
end

function throw_green_shell(dir)
    local m = gMarioStates[0]
    local np = gNetworkPlayers[0]
    set_action_after_throw(m, dir)
    spawn_sync_object(
        id_bhvGreenShell,
        E_MODEL_KOOPA_SHELL,
        m.pos.x, m.pos.y + 50, m.pos.z,
        function(o)
            if dir == 1 then
                o.oForwardVel = math.max(30, m.forwardVel + 50)
            else
                o.oForwardVel = 50
            end
            o.oMoveAngleYaw = m.faceAngle.y + (dir - 1) * 0x4000
            o.oFaceAngleYaw = o.oMoveAngleYaw
            o.oObjectOwner = np.globalIndex
            o.oGravity = -2.5
            o.oVelY = m.vel.y + 10
            if m.action & ACT_FLAG_SWIMMING_OR_FLYING ~= 0 then
                o.oMoveAnglePitch = m.faceAngle.x
                o.oGravity = 0
            end
        end
    )
end

function throw_red_shell(dir)
    local m = gMarioStates[0]
    local np = gNetworkPlayers[0]
    set_action_after_throw(m, dir)
    spawn_sync_object(
        id_bhvRedShell,
        E_MODEL_RED_SHELL,
        m.pos.x, m.pos.y + 50, m.pos.z,
        function(o)
            if dir == 1 then
                o.oForwardVel = math.max(30, m.forwardVel + 50)
            else
                o.oForwardVel = 50
            end
            o.oMoveAngleYaw = m.faceAngle.y + (dir - 1) * 0x4000
            o.oFaceAngleYaw = o.oMoveAngleYaw
            o.oObjectOwner = np.globalIndex
            if m.action & ACT_FLAG_SWIMMING_OR_FLYING ~= 0 then
                o.oMoveAnglePitch = m.faceAngle.x
            end
        end
    )
end

function throw_bomb(m, dir)
    spawn_sync_object(
        id_bhvThrownBobomb,
        E_MODEL_BLACK_BOBOMB,
        m.pos.x, m.pos.y + 50, m.pos.z,
        function(o)
            if dir == 1 then
                o.oForwardVel = m.forwardVel + 35
            else
                o.oForwardVel = 35
            end
            o.oMoveAngleYaw = m.faceAngle.y + (dir - 1) * 0x4000
            o.oFaceAngleYaw = o.oMoveAngleYaw
            o.oObjectOwner = gNetworkPlayers[m.playerIndex].globalIndex
        end
    )
    set_action_after_throw(m, dir)
end

function throw_fireball(m, dir)
    set_action_after_throw(m, dir)
    spawn_sync_object(
        id_bhvFireball,
        E_MODEL_RED_FLAME,
        m.pos.x, m.pos.y + 50, m.pos.z,
        function(o)
            if dir == 1 then
                o.oForwardVel = m.forwardVel + 50
            else
                o.oForwardVel = 50
            end
            o.oVelY = 0
            o.oMoveAngleYaw = m.faceAngle.y + (dir - 1) * 0x4000

            o.oFaceAngleYaw = o.oMoveAngleYaw
            o.oObjectOwner = network_global_index_from_local(0)
        end
    )
end

function throw_boomerang(m, dir, uses)
    local np = gNetworkPlayers[0]
    set_action_after_throw(m, dir)
    spawn_sync_object(
        id_bhvBoomerang,
        E_MODEL_BOOMERANG,
        m.pos.x, m.pos.y + 50, m.pos.z,
        function(o)
            if dir == 1 then
                o.oForwardVel = m.forwardVel + 70
            else
                o.oForwardVel = 70
            end
            o.oVelY = 0
            o.oMoveAngleYaw = m.faceAngle.y + (dir - 1) * 0x4000

            o.oFaceAngleYaw = o.oMoveAngleYaw
            o.oObjectOwner = np.globalIndex
            o.oAnimState = uses + 1
        end
    )
end

-- banana (based on bomb)
--- @param o Object
function banana_init(o)
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_COMPUTE_DIST_TO_MARIO)
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oAction = 0
    o.oGravity = 2.5
    o.oBuoyancy = 1.5
    o.oAnimState = 0
    o.oBounciness = 0

    local hitbox = get_temp_object_hitbox()
    hitbox.damageOrCoinValue = 1
    hitbox.radius = 50
    hitbox.height = 50
    hitbox.hurtboxRadius = 100
    hitbox.hurtboxHeight = 100
    hitbox.downOffset = 0
    hitbox.interactType = INTERACT_DAMAGE
    obj_set_hitbox(o, hitbox)

    cur_obj_init_animation(1)
    network_init_object(o, true, {})
end

--- @param o Object
function banana_loop(o)
    local stepResult = object_step();
    local hitObject = do_item_collision(o)
    if stepResult & (OBJ_MOVE_LANDED | OBJ_MOVE_UNDERWATER_ON_GROUND) ~= 0 then
        o.oForwardVel = 0
        o.oVelY = -10
        cur_obj_update_floor()
        if is_hazard_floor(o.oFloorType) then
            obj_mark_for_deletion(o)
            return
        end
        if o.oFloor and o.oFloor.object then
            apply_platform_displacement(o, o.oFloor.object)
        end
    end
    if (o.oInteractStatus & (INT_STATUS_ATTACKED_MARIO | INT_STATUS_TOUCHED_BOB_OMB)) ~= 0 or hitObject ~= 0 or o.oTimer > 900 then
        obj_mark_for_deletion(o)
    end
end

id_bhvBanana = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, banana_init, banana_loop, "bhvBanana")

-- poison mushroom (very similar to banana)
--- @param o Object
function poison_mushroom_init(o)
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_COMPUTE_DIST_TO_MARIO)
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oAction = 0
    o.oGravity = 2.5
    o.oBuoyancy = 1.5
    o.oAnimState = 0
    o.oBounciness = 0.5
    o.oFriction = 0.8
    o.oGraphYOffset = 30

    local hitbox = get_temp_object_hitbox()
    hitbox.damageOrCoinValue = 0
    hitbox.radius = 50
    hitbox.height = 50
    hitbox.hurtboxRadius = 100
    hitbox.hurtboxHeight = 100
    hitbox.downOffset = 0
    hitbox.interactType = INTERACT_WATER_RING
    obj_set_hitbox(o, hitbox)

    obj_set_billboard(o)
    network_init_object(o, true, {})
end

--- @param o Object
function poison_mushroom_loop(o)
    local stepResult = object_step();
    if stepResult & (OBJ_MOVE_LANDED | OBJ_MOVE_UNDERWATER_ON_GROUND) ~= 0 then
        cur_obj_update_floor()
        if is_hazard_floor(o.oFloorType) then
            spawn_triangle_break_particles(2, 0x8B, 0.25, 2)
            obj_mark_for_deletion(o)
            return
        end
        if o.oFloor and o.oFloor.object then
            apply_platform_displacement(o, o.oFloor.object)
        end
        
        o.oSubAction = 1
    end

    if o.oSubAction == 1 then
        local ownerIndex = network_local_index_from_global(o.oObjectOwner) or 255
        local nearestM
        -- get nearest mario not on team
        local maxDist = 1500
        local ownerTeam = (ownerIndex ~= 255 and gPlayerSyncTable[ownerIndex].team) or 0
        for i=0,MAX_PLAYERS-1 do
            local m = gMarioStates[i]
            local sMario = gPlayerSyncTable[i]
            if i ~= ownerIndex and is_player_active(m) ~= 0 and not is_dead(i) and (ownerTeam == 0 or sMario.team ~= ownerTeam) then
                local dist = dist_between_objects(m.marioObj, o)
                if dist < maxDist then
                    maxDist = dist
                    nearestM = m
                end
            end
        end
        if nearestM then
            o.oForwardVel = 5
            o.oMoveAngleYaw = obj_angle_to_object(o, nearestM.marioObj)
            if is_invincible(nearestM.playerIndex) then
                o.oMoveAngleYaw = o.oMoveAngleYaw + 0x8000
            end
            if nearestM.playerIndex == 0 and (o.oInteractStatus & INT_STATUS_INTERACTED) ~= 0 then
                if is_invincible(nearestM.playerIndex) then
                    cur_obj_play_sound_1(SOUND_OBJ_DYING_ENEMY1)
                    spawn_triangle_break_particles(2, 0x8B, 0.25, 2) -- MODEL_CARTOON_STAR
                else
                    local sMario = gPlayerSyncTable[nearestM.playerIndex]
                    sMario.smallTimer = 150
                    play_sound(SOUND_MENU_ENTER_PIPE, gGlobalSoundSource)
                end
                obj_mark_for_deletion(o)
            end
        end
    end
    
    o.oInteractStatus = 0
    if o.oTimer > 900 then
        spawn_triangle_break_particles(2, 0x8B, 0.25, 2)
        obj_mark_for_deletion(o)
    end
end

id_bhvPoisonMushroom = hook_behavior(nil, OBJ_LIST_LEVEL, true, poison_mushroom_init, poison_mushroom_loop, "bhvPoisonMushroom")

-- boomerang
--- @param o Object
function boomerang_init(o)
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_COMPUTE_DIST_TO_MARIO)
    o.oFaceAnglePitch = 0x4000
    o.oFaceAngleRoll = 0
    o.oFaceAngleYaw = 0
    o.oAction = 0
    o.oGravity = 0
    o.oBuoyancy = 1.5
    o.oFriction = 1

    local hitbox = get_temp_object_hitbox()
    hitbox.damageOrCoinValue = 2
    hitbox.radius = 40
    hitbox.height = 40
    hitbox.hurtboxRadius = 150
    hitbox.hurtboxHeight = 150
    hitbox.downOffset = 40
    hitbox.interactType = INTERACT_DAMAGE
    obj_set_hitbox(o, hitbox)
    cur_obj_scale(0.75)

    cur_obj_init_animation(1)
    network_init_object(o, false, {
        "oPosX",
        "oPosY",
        "oPosZ",
        "oVelY",
        "oForwardVel",
        "oAction",
        "activeFlags",
        "oAnimState"
    })
end

--- @param o Object
function boomerang_loop(o)
    o.globalPlayerIndex = o.oObjectOwner or 0
    local stepResult = 0
    if o.oAction == 0 then
        stepResult = object_step_without_floor_orient()
    else
        obj_move_xyz_using_fvel_and_yaw(o) -- go through walls on return
    end
    local index = network_local_index_from_global(o.oObjectOwner) or 1

    do_item_collision(o, 4)

    if stepResult & OBJ_COL_FLAG_HIT_WALL ~= 0 then
        if o.oAnimState > 2 then
            spawn_triangle_break_particles(2, 0x8B, 0.25, 2) -- MODEL_CARTOON_STAR
            obj_mark_for_deletion(o)
            if index == 0 and o.oSyncID ~= 0 then
                network_send_object(o, true)
            end
            return
        elseif o.oAction == 0 then
            cur_obj_change_action(1)
        end
    end

    o.oFaceAngleYaw = limit_angle(o.oFaceAngleYaw + 0x2000)
    if o.oFaceAngleYaw == 0 then
        cur_obj_play_sound_1(SOUND_ACTION_SPIN)
    end
    if o.oAction == 0 then
        if o.oAnimState <= 2 then
            o.oForwardVel = o.oForwardVel - 2
            if o.oForwardVel <= 0 then
                cur_obj_change_action(1)
            end
        end
    else -- return
        local m = gMarioStates[index]
        local vel = math.max(m.forwardVel + 5, 50)
        if o.oForwardVel < vel then
            o.oForwardVel = approach_s32(o.oForwardVel, vel, 2, 2)
        end

        local dist = dist_between_objects(o, m.marioObj)
        o.oMoveAngleYaw = obj_angle_to_object(o, m.marioObj)
        if m.pos.y - o.oPosY > 100 or m.pos.y - o.oPosY < -100 then
            o.oVelY = (m.pos.y - o.oPosY) // ((dist - 120) / vel)
        elseif o.oForwardVel >= vel then
            o.oVelY = 0
        end

        if dist <= 120 and index == 0 then
            if not is_dead(index) then
                if gPlayerSyncTable[0].item == 0 and shuffleItem == 0 and o.oAnimState ~= 0 then
                    gPlayerSyncTable[0].item = ITEM_BOOMERANG
                    gPlayerSyncTable[0].itemUses = o.oAnimState
                else
                    gPlayerSyncTable[0].specialCooldown = 0
                end
            end
            obj_mark_for_deletion(o)
        end
    end

    if o.oTimer > 300 then
        spawn_triangle_break_particles(2, 0x8B, 0.25, 2) -- MODEL_CARTOON_STAR
        obj_mark_for_deletion(o)
    end

    if index == 0 and o.oSyncID ~= 0 then
        network_send_object(o, true)
    end
    o.oInteractStatus = 0
end

id_bhvBoomerang = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, boomerang_init, boomerang_loop, "bhvBoomerang")

-- green shell
--- @param o Object
function green_shell_init(o)
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_COMPUTE_DIST_TO_MARIO)
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oAction = 0
    --o.oGravity = 2.5
    o.oBuoyancy = -1.5
    o.oFriction = 1
    o.oBounciness = -0.2
    o.oWallHitboxRadius = math.max(50, o.oForwardVel)
    o.oAnimState = 0
    o.oBalloonNumber = 0

    local hitbox = get_temp_object_hitbox()
    hitbox.damageOrCoinValue = 2
    hitbox.radius = 60
    hitbox.height = 60
    hitbox.hurtboxRadius = 150
    hitbox.hurtboxHeight = 150
    hitbox.downOffset = 0
    hitbox.interactType = INTERACT_DAMAGE
    obj_set_hitbox(o, hitbox)

    cur_obj_init_animation(1)
    network_init_object(o, true, {"oBalloonNumber", "oWallHitboxRadius"})
end

--- @param o Object
function green_shell_loop(o)
    local speed = o.oForwardVel
    if o.oGravity == 0 and o.oMoveAnglePitch ~= 0 then
        o.oVelY = sins(o.oMoveAnglePitch) * speed
        o.oForwardVel = coss(o.oMoveAnglePitch) * speed
    end
    cur_obj_update_floor_and_walls();
    -- bounce
    if (o.oMoveFlags & OBJ_MOVE_HIT_WALL) ~= 0 then
        o.oMoveAngleYaw = cur_obj_reflect_move_angle_off_wall()--limit_angle(2 * o.oWallAngle - o.oMoveAngleYaw) + 0x8000
    end
    cur_obj_move_standard(78)
    if o.oMoveAnglePitch ~= 0 then
        o.oForwardVel = speed
    end

    local hitObject = do_item_collision(o)

    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x2000
    if o.oMoveFlags & OBJ_MOVE_BOUNCE ~= 0 then
        --cur_obj_play_sound_1(SOUND_ACTION_TERRAIN_BODY_HIT_GROUND)
        o.oGravity = -2.5
        o.oMoveAnglePitch = 0
        if (not o.oFloor) or is_hazard_floor(o.oFloorType) then
            spawn_triangle_break_particles(2, 0x8B, 0.25, 1) -- MODEL_CARTOON_STAR
            obj_mark_for_deletion(o)
            return
        end
    elseif o.oMoveFlags & OBJ_MOVE_MASK_ON_GROUND ~= 0 then
        o.oBounciness = 0
        o.oGravity = -2.5
        o.oMoveAnglePitch = 0
        if (not o.oFloor) or is_hazard_floor(o.oFloorType) then
            spawn_triangle_break_particles(2, 0x8B, 0.25, 1) -- MODEL_CARTOON_STAR
            obj_mark_for_deletion(o)
            return
        end
    end
    if o.oMoveFlags & OBJ_MOVE_HIT_WALL ~= 0 then
        o.oBalloonNumber = o.oBalloonNumber + 1
        cur_obj_play_sound_1(SOUND_ACTION_HIT_3)
    end
    if o.oBalloonNumber >= 10 or o.oInteractStatus & INT_STATUS_TOUCHED_BOB_OMB ~= 0 or hitObject ~= 0 then
        spawn_triangle_break_particles(2, 0x8B, 0.25, 1) -- MODEL_CARTOON_STAR
        obj_mark_for_deletion(o)
        return
    end

    if o.oTimer > 300 or (o.oInteractStatus & INT_STATUS_ATTACKED_MARIO) ~= 0 then
        spawn_triangle_break_particles(2, 0x8B, 0.25, 1) -- MODEL_CARTOON_STAR
        obj_mark_for_deletion(o)
        return
    end
    o.oInteractStatus = 0 
end

id_bhvGreenShell = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, green_shell_init, green_shell_loop, "bhvGreenShell")

-- red shell
--- @param o Object
function red_shell_init(o)
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_COMPUTE_DIST_TO_MARIO)
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oAction = 0
    o.oGravity = 0
    o.oBuoyancy = 1.5
    o.oFriction = 1

    local hitbox = get_temp_object_hitbox()
    hitbox.damageOrCoinValue = 2
    hitbox.radius = 60
    hitbox.height = 60
    hitbox.hurtboxRadius = 150
    hitbox.hurtboxHeight = 150
    hitbox.downOffset = 0
    hitbox.interactType = INTERACT_DAMAGE
    obj_set_hitbox(o, hitbox)

    cur_obj_init_animation(1)
    network_init_object(o, true, {})
end

--- @param o Object
function red_shell_loop(o)
    local speed = o.oForwardVel
    if o.oMoveAnglePitch ~= 0 then
        o.oVelY = sins(o.oMoveAnglePitch) * speed
        o.oForwardVel = coss(o.oMoveAnglePitch) * speed
    end
    local stepResult = object_step_without_floor_orient()
    if o.oMoveAnglePitch ~= 0 then
        o.oForwardVel = speed
    end
    local index = network_local_index_from_global(o.oObjectOwner) or 1

    local hitObject = do_item_collision(o)

    if stepResult & OBJ_COL_FLAG_HIT_WALL ~= 0 or o.oInteractStatus & INT_STATUS_TOUCHED_BOB_OMB ~= 0 or hitObject ~= 0 then
        spawn_triangle_break_particles(2, 0x8B, 0.25, 0) -- MODEL_CARTOON_STAR
        obj_mark_for_deletion(o)
    end

    local maxDist = 2000
    local bestYaw = 0
    local bestDiff = 0x4000
    local targetIndex = network_local_index_from_global(o.oAnimState - 1) or 255
    local team = gPlayerSyncTable[index].team or 0
    if targetIndex ~= 255 then
        local sMario = gPlayerSyncTable[targetIndex]
        local m = gMarioStates[targetIndex]
        local i = targetIndex
        if i ~= index and is_player_active(m) ~= 0 and m.invincTimer == 0 and m.action & (ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE) == 0 and (sMario.team == nil or sMario.team == 0 or sMario.team ~= team) and not is_dead(i) then
            bestYaw = obj_angle_to_object(o, m.marioObj)
        else
            targetIndex = 255
        end
    end

    if targetIndex == 255 then
        for i = 0, MAX_PLAYERS - 1 do -- target closest opponent
            local sMario = gPlayerSyncTable[i]
            local m = gMarioStates[i]
            if i ~= index and is_player_active(m) ~= 0 and m.invincTimer == 0 and m.action & (ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE) == 0 and (sMario.team == nil or sMario.team == 0 or sMario.team ~= team) and not is_dead(i) then
                local dist = dist_between_objects(o, m.marioObj)
                local yaw = obj_angle_to_object(o, m.marioObj)
                local angleDiff = abs_angle_diff(yaw, o.oMoveAngleYaw)
                if dist < maxDist and angleDiff <= bestDiff then -- target closest within 2000 that is straight from the shell
                    --maxDist = dist
                    bestDiff = angleDiff
                    bestYaw = yaw
                    targetIndex = i
                end
            end
        end
    end

    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x2000
    if targetIndex and targetIndex ~= 255 then
        if targetIndex == 0 then
            cur_obj_play_sound_1(SOUND_MOVING_ALMOST_DROWNING)
        end
        o.oAnimState = network_global_index_from_local(targetIndex) + 1

        local m = gMarioStates[targetIndex]
        local vel = math.max(m.forwardVel + 2, 35)
        o.oForwardVel = approach_s32(o.oForwardVel, vel, 2, 2)

        o.oMoveAngleYaw = approach_s16_symmetric(o.oMoveAngleYaw, bestYaw, 0x1000)
        o.oMoveAnglePitch = 0
        if m.pos.y - o.oPosY > 100 or m.pos.y - o.oPosY < -100 then
            o.oVelY = math.ceil((m.pos.y - o.oPosY) / 3)
        elseif o.oForwardVel >= vel then
            o.oVelY = 0
        end
    else
        o.oAnimState = 0
    end

    if o.oTimer > 300 or (o.oInteractStatus & INT_STATUS_ATTACKED_MARIO) ~= 0 then
        spawn_triangle_break_particles(2, 0x8B, 0.25, 0) -- MODEL_CARTOON_STAR
        obj_mark_for_deletion(o)
    end
end

id_bhvRedShell = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, red_shell_init, red_shell_loop, "bhvRedShell")

-- fireballs
--- @param o Object
function fireball_init(o)
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_COMPUTE_DIST_TO_MARIO)
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oAction = 0
    o.oGravity = 4
    o.oBuoyancy = 1.5
    o.oFriction = 1
    o.oDragStrength = 1
    o.oBounciness = 1
    o.oBalloonNumber = 0

    local hitbox = get_temp_object_hitbox()
    hitbox.damageOrCoinValue = 2
    hitbox.radius = 40
    hitbox.height = 40
    hitbox.hurtboxRadius = 150
    hitbox.hurtboxHeight = 150
    hitbox.downOffset = 0
    hitbox.interactType = INTERACT_FLAME
    obj_set_hitbox(o, hitbox)
    obj_set_billboard(o)
    cur_obj_scale(3)

    cur_obj_init_animation(1)
    network_init_object(o, true, {"oBalloonNumber"})
end

--- @param o Object
function fireball_loop(o)
    if o.oTimer == 1 then
        cur_obj_play_sound_1(SOUND_OBJ_FLAME_BLOWN)
    end
    local stepResult = object_step_without_floor_orient()
    o.oAnimState = o.oAnimState + 1

    local hitObject = do_item_collision(o, 2)

    if stepResult & (OBJ_MOVE_LANDED | OBJ_MOVE_UNDERWATER_ON_GROUND) ~= 0 then
        cur_obj_play_sound_1(SOUND_AIR_BOWSER_SPIT_FIRE)
        cur_obj_update_floor()
        if o.oBalloonNumber > 5 or o.oFloorType == SURFACE_DEATH_PLANE or o.oFloorType == SURFACE_VERTICAL_WIND then
            spawn_triangle_break_particles(2, 0x8B, 0.25, 0) -- MODEL_CARTOON_STAR
            obj_mark_for_deletion(o)
            return
        else
            o.oBalloonNumber = o.oBalloonNumber + 1
            if o.oVelY ~= 0 then
                o.oVelY = 30
            else
                o.oVelY = 50
            end
        end
    end

    if o.oTimer > 300 or o.oInteractStatus & (INT_STATUS_INTERACTED | INT_STATUS_TOUCHED_BOB_OMB) ~= 0 or hitObject ~= 0 then
        spawn_triangle_break_particles(2, 0x8B, 0.25, 0) -- MODEL_CARTOON_STAR
        obj_mark_for_deletion(o)
    end
end

id_bhvFireball = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, fireball_init, fireball_loop, "bhvFireBall")

-- oh lord (blue shell)
--- @param o Object
function blue_shell_init(o)
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_COMPUTE_DIST_TO_MARIO)
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oAction = 0
    o.oGravity = 0
    o.oBuoyancy = 1.5
    o.oFriction = 1
    cur_obj_scale(0.5)

    local hitbox = get_temp_object_hitbox()
    hitbox.damageOrCoinValue = 8
    hitbox.radius = 40
    hitbox.height = 40
    hitbox.hurtboxRadius = 150
    hitbox.hurtboxHeight = 150
    hitbox.downOffset = 0
    hitbox.interactType = INTERACT_DAMAGE
    obj_set_hitbox(o, hitbox)

    cur_obj_init_animation(1)
    network_init_object(o, true, {})
end

--- @param o Object
function blue_shell_loop(o)
    if o.oAction == 3 then
        local hitbox = get_temp_object_hitbox()
        hitbox.damageOrCoinValue = 8
        hitbox.radius = 100
        hitbox.height = 100
        hitbox.hurtboxRadius = 300
        hitbox.hurtboxHeight = 300
        hitbox.interactType = INTERACT_DAMAGE
        obj_set_hitbox(o, hitbox)
        cur_obj_scale(4)
        bhv_explosion_loop()
        do_item_collision(o, 2)
        o.oAnimState = o.oAnimState + 1
        o.oInteractStatus = 0
        return
    end

    obj_move_xyz_using_fvel_and_yaw(o) -- go through walls because Screw You
    local index = network_local_index_from_global(o.oObjectOwner) or 1

    do_item_collision(o, 2) -- ignore items too because Screw You

    local maxDist = 10000   -- basically infinite distance, SCREW. YOU.
    local bestYaw = 0
    local bestScore = 0
    local targetIndex = network_local_index_from_global(o.oAnimState - 1) or 255
    local team = gPlayerSyncTable[index].team or 0
    if targetIndex ~= 255 then
        local sMario = gPlayerSyncTable[targetIndex]
        local m = gMarioStates[targetIndex]
        local i = targetIndex
        if ((i == index) or (is_player_active(m) ~= 0 and (sMario.team == nil or sMario.team == 0 or sMario.team ~= team))) and not is_dead(i) then
            bestYaw = obj_angle_to_object(o, m.marioObj)
        else
            targetIndex = 255
        end
    end

    if targetIndex == 255 then
        for i = 0, MAX_PLAYERS - 1 do -- target closest opponent WITH HIGHEST SCORE
            local sMario = gPlayerSyncTable[i]
            local m = gMarioStates[i]
            if ((i == index) or (is_player_active(m) ~= 0 and (sMario.team == nil or sMario.team == 0 or sMario.team ~= team))) and not is_dead(i) then
                local dist = dist_between_objects(o, m.marioObj)
                local yaw = obj_angle_to_object(o, m.marioObj)

                local score = 0
                if gGlobalSyncTable.gameMode == 1 then
                    score = sMario.balloons
                elseif get_player_owned_shine(i) ~= 0 then
                    score = 500 + sMario.points
                else
                    score = sMario.points
                end

                if bestScore < score or (bestScore == score and i ~= index and dist < maxDist) then
                    bestScore = score
                    if i ~= index then
                        maxDist = dist
                    end
                    bestYaw = yaw
                    targetIndex = i
                end
            end
        end
    end
    if targetIndex == nil or targetIndex == 255 then -- target self if no target found
        targetIndex = index
    end

    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x2000
    if targetIndex == 0 then
        cur_obj_play_sound_1(SOUND_MOVING_ALMOST_DROWNING)
    end
    o.oAnimState = network_global_index_from_local(targetIndex) + 1

    local m = gMarioStates[targetIndex]

    if o.oAction == 0 then
        local vel = math.max(m.forwardVel + 2, 35)
        o.oForwardVel = approach_s32(o.oForwardVel, vel, 2, 2)
        local dist = dist_between_objects(o, m.marioObj)

        o.oMoveAngleYaw = approach_s16_symmetric(o.oMoveAngleYaw, bestYaw, 0x1000)
        if m.pos.y - o.oPosY > 100 or m.pos.y - o.oPosY < -100 then
            o.oVelY = (m.pos.y - o.oPosY) // ((dist - 200) / vel)
        elseif o.oForwardVel >= vel then
            o.oVelY = 0
        end

        if dist < 200 then
            cur_obj_change_action(1)
        end
    elseif o.oAction == 1 then
        if o.oTimer < 60 then
            o.oMoveAngleYaw = o.oMoveAngleYaw + 0xD00
        elseif o.oTimer < 75 then
            o.oFaceAngleYaw = bestYaw
        else
            cur_obj_change_action(2)
        end
        o.oPosX = m.pos.x - sins(o.oMoveAngleYaw) * 200
        o.oForwardVel = 0
        o.oVelX = 0
        o.oVelY = (m.pos.y + 200 - o.oPosY) // 2
        o.oVelZ = 0
        o.oPosZ = m.pos.z - coss(o.oMoveAngleYaw) * 200
    elseif o.oAction == 2 then
        o.oForwardVel = 70
        o.oMoveAngleYaw = bestYaw
        local dist = dist_between_objects(o, m.marioObj)
        if m.pos.y - o.oPosY > 100 or m.pos.y - o.oPosY < -100 then
            o.oVelY = (m.pos.y - o.oPosY) // ((dist - 150) / o.oForwardVel)
        else
            o.oVelY = 0
        end

        if dist < 150 then
            o.oPosX = m.pos.x
            o.oPosY = m.pos.y
            o.oPosZ = m.pos.z
            o.oForwardVel, o.oVelX, o.oVelY, o.oVelZ = 0, 0, 0, 0
            cur_obj_change_action(3)
            obj_set_model_extended(o, E_MODEL_EXPLOSION)
            obj_set_billboard(o)
            bhv_explosion_init()
            o.oAnimState = 0
        end
    end

    if o.oTimer > 900 then
        spawn_triangle_break_particles(2, 0x8B, 0.25, 2) -- MODEL_CARTOON_STAR
        obj_mark_for_deletion(o)
    end
    o.oInteractStatus = 0
end

id_bhvBlueShell = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, blue_shell_init, blue_shell_loop, "bhvBlueShell")

-- dropped items. They behave identically to bananas, but cause their item's effect on touch instead
-- oBalloonNumber is if they despawn instead of landing, and oBalloonAppearance is what item they are
--- @param o Object
function dropped_item_init(o)
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_COMPUTE_DIST_TO_MARIO)
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oAction = 0
    o.oGravity = 2.5
    o.oBuoyancy = 1.5
    o.oAnimState = 0
    o.oBounciness = 0
    o.oGraphYOffset = 30
    o.globalPlayerIndex = network_global_index_from_local(0)
    o.oOpacity = 255

    local hitbox = get_temp_object_hitbox()
    hitbox.damageOrCoinValue = 1
    hitbox.radius = 50
    hitbox.height = 50
    hitbox.hurtboxRadius = 100
    hitbox.hurtboxHeight = 100
    hitbox.downOffset = 0
    hitbox.interactType = INTERACT_WATER_RING
    obj_set_hitbox(o, hitbox)
    o.oIntangibleTimer = 15

    local data = item_data[o.oBalloonAppearance]
    if not data then obj_mark_for_deletion(o) end
    if not data.arenaModel then
        if data.bill then
            obj_set_billboard(o)
        end
        if data.scale then
            cur_obj_scale(data.scale)
        end
    end

    cur_obj_init_animation(1)
    network_init_object(o, true, {})
end

--- @param o Object
function dropped_item_loop(o)
    local data = item_data[o.oBalloonAppearance]
    if not data then obj_mark_for_deletion(o) end
    if not data.arenaModel then
        if data.bill then
            obj_set_billboard(o)
        end
        if data.scale then
            cur_obj_scale(data.scale)
        end
    end
    if o.oBalloonNumber ~= 1 and o.oTimer % 3 == 0 then
        spawn_non_sync_object(id_bhvSparkleSpawn, E_MODEL_NONE, o.oPosX, o.oPosY, o.oPosZ, nil)
    end

    local stepResult = object_step();
    if stepResult & (OBJ_MOVE_LANDED | OBJ_MOVE_UNDERWATER_ON_GROUND) ~= 0 then
        o.oForwardVel = 0
        o.oVelY = -10
        cur_obj_update_floor()
        if o.oBalloonNumber == 1 or is_hazard_floor(o.oFloorType) then
            spawn_mist_particles()
            obj_mark_for_deletion(o)
            return
        end
        if o.oFloor and o.oFloor.object then
            apply_platform_displacement(o, o.oFloor.object)
        end
    end
    if (o.oInteractStatus & INT_STATUS_INTERACTED) ~= 0 and o.oBalloonNumber ~= 1 then
        local m = nearest_living_mario_state_to_object(o)
        if m and m.playerIndex == 0 then
            local newItem, newUses = use_item(o.oBalloonAppearance, 5, 0)
            if (data.count == nil or data.count == 1) and newItem ~= 0 then
                gPlayerSyncTable[0].item, gPlayerSyncTable[0].itemUses = newItem, newUses
                shuffleItem = 0
            end
            obj_mark_for_deletion(o)
            network_send_object(o, true)
        end
    elseif o.oTimer > 900 then
        obj_mark_for_deletion(o)
    end
end

id_bhvDroppedItem = hook_behavior(nil, OBJ_LIST_LEVEL, true, dropped_item_init, dropped_item_loop, "bhvDroppedItem")

-- like obj_attack_collided_from_other_object() but it ignores certain objects
-- also handles collecting coins with the boomerang
function do_item_collision(o, myType)
    if o.numCollidedObjs ~= 0 then
        local other = obj_get_collided_object(o, 0)

        local o_id = get_id_from_behavior(other.behavior)
        local itemType = is_item(o_id)
        if (other.oInteractType & (INTERACT_PLAYER | INTERACT_WATER_RING) == 0) and ((not itemType) or (myType ~= 2 and itemType ~= 2 and myType ~= 4 and itemType ~= 4 and objs_on_different_teams(o, other))) then
            other.oInteractStatus = other.oInteractStatus | ATTACK_PUNCH | INT_STATUS_WAS_ATTACKED | INT_STATUS_INTERACTED | INT_STATUS_TOUCHED_BOB_OMB
            return 1
        end
    end

    if myType ~= 4 then return 0 end

    local index = network_local_index_from_global(o.oObjectOwner) or 255
    if index == 255 or is_dead(index) then return 0 end

    -- run only for certain modes and people
    if gGlobalSyncTable.gameMode == 0 then                                        -- shine thief: host only
        if not network_is_server() then return 0 end
    elseif gGlobalSyncTable.gameMode == 4 then                                    -- renegade roundup: host only, AND only for renegades
        if (not network_is_server()) or gPlayerSyncTable[index].team ~= 1 then return end
    elseif gGlobalSyncTable.gameMode ~= 3 and gGlobalSyncTable.gameMode ~= 5 then -- don't run for balloon battle/attack
        return 0
    end

    -- boomerang collision (run by all players due to ownership stuff)
    if gGlobalSyncTable.gameState ~= 1 then
        other = obj_get_first(OBJ_LIST_LEVEL)
        while other do
            local o_id = get_id_from_behavior(other.behavior)
            if (other.oInteractType == INTERACT_COIN                                                                                -- if this is a coin...
                    or ((o_id == id_bhvShine or o_id == id_bhvMoon) and (other.oAction == 0 or other.oTimer > 30)                   -- or a shine...
                        and (o_id == id_bhvMoon or (get_player_owned_shine(0) == 0 and get_shine_owner(other.oBehParams) == -1)))) then -- and the shine is not owned...
                if obj_check_hitbox_overlap(o, other) then
                    local m = gMarioStates[index]
                    other.oPosX = m.pos.x
                    other.oPosY = m.pos.y
                    other.oPosZ = m.pos.z
                    break -- only interact with one coin/shine per frame
                end
            elseif o_id == id_bhvRRCage then
                if obj_check_overlap_with_hitbox_params(o, other.oPosX, other.oPosY, other.oPosZ, 50, 50, 0) then
                    other.oObjectOwner = index + 1 -- unlike other uses of this variable, this uses the local index
                    break
                end
            end
            other = obj_get_next(other)
        end
    end

    return 0
end

function objs_on_different_teams(o, o2)
    local index = network_local_index_from_global(o.oObjectOwner) or 255
    local index2 = network_local_index_from_global(o2.oObjectOwner) or 255
    if index == 255 or index2 == 255 then return true end
    if index == index2 then return false end

    local sMario = gPlayerSyncTable[index]
    local sMario2 = gPlayerSyncTable[index2]

    if sMario.team == 0 or sMario2.team == 0 then return true end
    return sMario.team ~= sMario2.team
end

-- copied from C code (modified to ONLY support objects)
function apply_platform_displacement(o, platform)
    local x;
    local y;
    local z;
    local platformPosX;
    local platformPosY;
    local platformPosZ;
    local currentObjectOffset = { x = 0, y = 0, z = 0 }
    local relativeOffset = { x = 0, y = 0, z = 0 }
    local newObjectOffset = { x = 0, y = 0, z = 0 }
    local rotation = { x = 0, y = 0, z = 0 }
    local displaceMatrix = { m00 = 0, m01 = 0, m02 = 0, m03 = 0, m10 = 0, m11 = 0, m12 = 0, m13 = 0, m20 = 0, m21 = 0, m22 = 0, m23 = 0, m30 = 0, m31 = 0, m32 = 0, m33 = 0 }
    if not platform then return end
  
    rotation.x = platform.oAngleVelPitch;
    rotation.y = platform.oAngleVelYaw;
    rotation.z = platform.oAngleVelRoll;


    if not o then return end
    x = o.oPosX;
    y = o.oPosY;
    z = o.oPosZ;
  
    x = x + platform.oVelX;
    z = z + platform.oVelZ;
  
    if rotation.x ~= 0 or rotation.y ~= 0 or rotation.z ~= 0 then
      o.oFaceAngleYaw = o.oFaceAngleYaw + rotation.y;
  
      platformPosX = platform.oPosX;
      platformPosY = platform.oPosY;
      platformPosZ = platform.oPosZ;
  
      currentObjectOffset.x = x - platformPosX;
      currentObjectOffset.y = y - platformPosY;
      currentObjectOffset.z = z - platformPosZ;
  
      rotation.x = platform.oFaceAnglePitch - platform.oAngleVelPitch;
      rotation.y = platform.oFaceAngleYaw - platform.oAngleVelYaw;
      rotation.z = platform.oFaceAngleRoll - platform.oAngleVelRoll;
  
      mtxf_rotate_zxy_and_translate(displaceMatrix, currentObjectOffset, rotation);
      linear_mtxf_transpose_mul_vec3f(displaceMatrix, relativeOffset, currentObjectOffset);
  
      rotation.x = platform.oFaceAnglePitch;
      rotation.y = platform.oFaceAngleYaw;
      rotation.z = platform.oFaceAngleRoll;
  
      mtxf_rotate_zxy_and_translate(displaceMatrix, currentObjectOffset, rotation);
      linear_mtxf_mul_vec3f(displaceMatrix, newObjectOffset, relativeOffset);
  
      x = platformPosX + newObjectOffset.x;
      y = platformPosY + newObjectOffset.y;
      z = platformPosZ + newObjectOffset.z;
    end
  
    o.oPosX = x;
    o.oPosY = y;
    o.oPosZ = z;
end

item_data = {
    [ITEM_BANANA] = {
        weight = 70,
        firstWeight = 50, -- weight in first (if nil, cannot be gotten in first)
        protect = 0,  -- can protect from red/green shells; value is the resulting item
        drop = id_bhvBanana, -- id to drop if hit with a ground pound/others (if nil, does not persist on ground)
        model = E_MODEL_BANANA,
        hand = true,  -- show in hand
        scale = 0.5,
        defaultDir = 3,
        func = function(dir)
            throw_banana(dir)
            return 0
        end,
    },
    [ITEM_MUSHROOM] = {
        weight = 45,
        losingWeight = 60,
        firstWeight = 30,
        drop = id_bhvDroppedItem,
        model = E_MODEL_MUSHROOM,
        func = function()
            use_mushroom()
            return 0
        end,
        bill = true, -- billboard
    },
    [ITEM_TRIPLE_MUSHROOM] = {
        weight = 15,
        losingWeight = 45, -- weight if we're below average (lerps from main weight)
        frantic = true, -- frantic item (more likely to appear when Frantic is on and during the endgame of renegade roundup for law)
        drop = id_bhvDroppedItem,
        model = E_MODEL_MUSHROOM,
        count = 3,
        func = function()
            use_mushroom()
            return ITEM_DOUBLE_MUSHROOM
        end,
        bill = true,
    },
    [ITEM_DOUBLE_MUSHROOM] = {
        weight = 0,
        drop = id_bhvDroppedItem,
        model = E_MODEL_MUSHROOM,
        count = 2,
        func = function()
            use_mushroom()
            return ITEM_MUSHROOM
        end,
        bill = true,
    },
    [ITEM_RED_SHELL] = {
        weight = 50,
        losingWeight = 70,
        drop = id_bhvBanana, -- still uses shell model
        model = E_MODEL_RED_SHELL,
        firstWeight = 10,
        protect = 0,
        func = function(dir)
            throw_red_shell(dir)
            return 0
        end,
    },
    [ITEM_TRIPLE_REDS] = {
        weight = 10,
        losingWeight = 50,
        drop = id_bhvBanana,
        frantic = true,
        model = E_MODEL_RED_SHELL,
        count = 3,
        protect = ITEM_DOUBLE_REDS,
        func = function(dir)
            throw_red_shell(dir)
            return ITEM_DOUBLE_REDS
        end,
    },
    [ITEM_DOUBLE_REDS] = {
        weight = 0,
        drop = id_bhvBanana,
        model = E_MODEL_RED_SHELL,
        count = 2,
        protect = ITEM_RED_SHELL,
        func = function(dir)
            throw_red_shell(dir)
            return ITEM_RED_SHELL
        end,
    },
    [ITEM_CAPE] = {
        weight = 60,
        firstWeight = 30,
        model = E_MODEL_CAPE,
        hand = true,
        yOffset = 7,
        yawOffset = 0x4000,
        pitchOffset = -0x2000,
        forwardOffset = -10,
        sideOffset = 5,
        scale = 0.7,
        func = function(dir)
            local m = gMarioStates[0]
            if m.action & ACT_FLAG_SWIMMING ~= 0 then
                return ITEM_CAPE
            end

            m.vel.y = 69 -- triple jump height
            if m.action & ACT_FLAG_RIDING_SHELL == 0 then
                drop_and_set_mario_action(m, ACT_CAPE_JUMP, 0)
                if not camera_config_is_free_cam_enabled() then
                    set_camera_mode(m.area.camera, m.area.camera.defMode, 1);
                else
                    m.area.camera.mode = CAMERA_MODE_NEWCAM;
                    gLakituState.mode = CAMERA_MODE_NEWCAM;
                end
            else
                set_mario_action(m, ACT_CAPE_JUMP_SHELL, 0)
            end
            return 0
        end,
    },
    [ITEM_BOOMERANG] = {
        weight = 30,
        scale = 0.3,
        yawOffset = -0x4000,
        rollOffset = 0x4000,
        pitchOffset = 0x1000,
        yOffset = 20,
        forwardOffset = 13,
        sideOffset = -20,
        hand = true,
        model = E_MODEL_BOOMERANG,
        maxUses = 3,
        func = function(dir, uses)
            local m = gMarioStates[0]
            throw_boomerang(m, dir, uses)
            return 0, 0
        end,
    },
    [ITEM_STAR] = {
        weight = 5,
        losingWeight = 40,
        frantic = true,
        drop = id_bhvDroppedItem,
        model = E_MODEL_STAR,
        yOffset = 30,
        scale = 0.7,
        func = function(dir)
            local m = gMarioStates[0]
            m.capTimer = 300 -- 10 seconds
            gPlayerSyncTable[0].star = true
            play_sound(SOUND_GENERAL_SHORT_STAR, gGlobalSoundSource)
            play_cap_music(SEQ_EVENT_POWERUP)
            play_character_sound(m, CHAR_SOUND_HERE_WE_GO)
            if m.action == ACT_LAVA_BOOST then
                set_mario_action(m, ACT_FREEFALL, 0)
            end
            return 0
        end
    },
    [ITEM_BULLET] = {
        weight = 20, -- not as good as in mario kart
        losingWeight = 30,
        frantic = true,
        model = E_MODEL_BULLET_BILL,
        yOffset = 40,
        scale = 0.2,
        func = function(dir)
            local m = gMarioStates[0]
            if m.action & ACT_FLAG_SWIMMING ~= 0 then
                return ITEM_BULLET
            end

            m.faceAngle.y = m.faceAngle.y + (dir - 1) * 0x4000
            gPlayerSyncTable[0].bulletTimer = 150
            m.flags = m.flags | MARIO_WING_CAP
            m.forwardVel = math.max(m.forwardVel, 50)
            play_sound(SOUND_OBJ_CANNON4, gGlobalSoundSource)
            if m.action == ACT_FLYING then
                -- nothing
            elseif m.action & ACT_FLAG_AIR == 0 then
                m.faceAngle.x = 0x2000
            else
                m.faceAngle.x = 0
            end
            drop_and_set_mario_action(m, ACT_FLYING, 0)
            return 0
        end,
    },
    [ITEM_POW] = {
        weight = 5,
        losingWeight = 20,
        frantic = true,
        model = E_MODEL_POW,
        func = function()
            network_send_include_self(true, {
                id = PACKET_POW_BLOCK,
                owner = gNetworkPlayers[0].globalIndex,
            })
            return 0
        end,
    },
    [ITEM_TRIPLE_BANANA] = {
        weight = 25,
        firstWeight = 5,
        drop = id_bhvBanana,
        count = 3,
        protect = ITEM_DOUBLE_BANANA,
        model = E_MODEL_BANANA,
        defaultDir = 3,
        func = function(dir)
            throw_banana(dir)
            return ITEM_DOUBLE_BANANA
        end,
    },
    [ITEM_DOUBLE_BANANA] = {
        weight = 0,
        count = 2,
        drop = id_bhvBanana,
        protect = ITEM_BANANA,
        model = E_MODEL_BANANA,
        defaultDir = 3,
        func = function(dir)
            throw_banana(dir)
            return ITEM_BANANA
        end,
    },
    [ITEM_FIRE_FLOWER] = {
        weight = 10,
        losingWeight = 40,
        frantic = true,
        hand = true,
        bill = true,
        scale = 2,
        model = E_MODEL_RED_FLAME,
        arenaModel = E_MODEL_FIRE_FLOWER, -- model for arena-style items (also used when dropping)
        updateAnimState = true,
        maxUses = 5,
        func = function(dir, uses)
            local m = gMarioStates[0]
            throw_fireball(m, dir)
            uses = uses + 1
            if uses < 5 then
                return ITEM_FIRE_FLOWER, uses
            end
            return 0
        end
    },
    [ITEM_BOMB] = {
        weight = 30,
        firstWeight = 20,
        protect = 0,
        hand = true,
        scale = 0.4,
        yOffset = -20,
        sideOffset = 10,
        drop = 0,
        model = E_MODEL_BLACK_BOBOMB,
        animation = gObjectAnimations.bobomb_seg8_anims_0802396C,
        func = function(dir)
            local m = gMarioStates[0]
            throw_bomb(m, dir)
            return 0
        end
    },
    [ITEM_TRIPLE_BOMB] = {
        weight = 15,
        losingWeight = 20,
        frantic = true,
        count = 3,
        scale = 0.75,
        protect = ITEM_DOUBLE_BOMB,
        drop = 0,
        model = E_MODEL_BLACK_BOBOMB,
        animation = gObjectAnimations.bobomb_seg8_anims_0802396C,
        func = function(dir)
            local m = gMarioStates[0]
            throw_bomb(m, dir)
            return ITEM_DOUBLE_BOMB
        end
    },
    [ITEM_DOUBLE_BOMB] = {
        weight = 0,
        count = 2,
        scale = 0.75,
        protect = ITEM_BOMB,
        drop = 0,
        model = E_MODEL_BLACK_BOBOMB,
        animation = gObjectAnimations.bobomb_seg8_anims_0802396C,
        func = function(dir)
            local m = gMarioStates[0]
            throw_bomb(m, dir)
            return ITEM_BOMB
        end
    },
    [ITEM_BLUE_SHELL] = {
        weight = 1,
        losingWeight = 10,
        frantic = true,
        model = E_MODEL_BLUE_SHELL,
        scale = 0.5,
        func = function(dir)
            local m = gMarioStates[0]
            local np = gNetworkPlayers[0]
            set_action_after_throw(m, dir)
            spawn_sync_object(
                id_bhvBlueShell,
                E_MODEL_BLUE_SHELL,
                m.pos.x, m.pos.y + 50, m.pos.z,
                function(o)
                    o.oForwardVel = m.forwardVel + 50
                    o.oMoveAngleYaw = m.faceAngle.y + (dir - 1) * 0x4000
                    o.oFaceAngleYaw = o.oMoveAngleYaw
                    o.oObjectOwner = np.globalIndex
                end
            )
            return 0
        end,
    },
    [ITEM_GREEN_SHELL] = {
        weight = 65,
        losingWeight = 30,
        drop = id_bhvBanana,
        model = E_MODEL_KOOPA_SHELL,
        firstWeight = 40,
        protect = 0,
        func = function(dir)
            throw_green_shell(dir)
            return 0
        end,
    },
    [ITEM_TRIPLE_GREENS] = {
        weight = 25,
        losingWeight = 40, -- weight if we're below average (lerps from main weight)
        frantic = true,
        drop = id_bhvBanana,
        model = E_MODEL_KOOPA_SHELL,
        count = 3,
        protect = ITEM_DOUBLE_GREENS,
        func = function(dir)
            throw_green_shell(dir)
            return ITEM_DOUBLE_GREENS
        end,
    },
    [ITEM_DOUBLE_GREENS] = {
        weight = 0,
        drop = id_bhvBanana,
        model = E_MODEL_KOOPA_SHELL,
        count = 2,
        protect = ITEM_GREEN_SHELL,
        func = function(dir)
            throw_green_shell(dir)
            return ITEM_GREEN_SHELL
        end,
    },
    [ITEM_BOO] = {
        weight = 20,
        losingWeight = 50, -- weight if we're below average (lerps from main weight)
        frantic = true,
        model = E_MODEL_BOO,
        scale = 0.75,
        func = function(dir)
            local stolen = 0
            local uses = 0
            local valid = {}
            for i=1,MAX_PLAYERS-1 do
                local np = gNetworkPlayers[i]
                local sMario = gPlayerSyncTable[i]
                if np.connected and (not is_dead(i)) and (sMario.team == 0 or sMario.team ~= gPlayerSyncTable[0].team) and sMario.item and sMario.item ~= 0 and sMario.item ~= ITEM_BOO then
                    table.insert(valid, i)
                end
            end

            if DEBUG_MODE and #valid == 0 then
                on_packet_boo_steal()
                return 0
            end

            if #valid == 0 then
                stolen = ITEM_TRIPLE_MUSHROOM
                play_sound(SOUND_OBJ_DYING_ENEMY1, gGlobalSoundSource)
            else
                local index = valid[math.random(1, #valid)]
                local sMario = gPlayerSyncTable[index]
                stolen = sMario.item
                uses = sMario.itemUses or 0
                sMario.item, sMario.itemUses = 0, 0
                network_send_to(index, true, {
                    id = PACKET_BOO_STEAL,
                    --from = network_global_index_from_local(0),
                })
                play_sound(SOUND_OBJ_BOO_LAUGH_LONG, gGlobalSoundSource)
            end
            return stolen, uses
        end,
    },
    [ITEM_LIGHTNING] = {
        weight = 1,
        losingWeight = 15,
        frantic = true,
        model = E_MODEL_LIGHTNING,
        yOffset = 30,
        scale = 0.7,
        func = function()
            network_send_include_self(true, {
                id = PACKET_LIGHTNING,
                owner = gNetworkPlayers[0].globalIndex,
            })
            return 0
        end,
    },
    [ITEM_POISON_MUSHROOM] = {
        weight = 40,
        firstWeight = 15,
        model = E_MODEL_POISON_MUSHROOM,
        bill = true,
        defaultDir = 3,
        drop = id_bhvPoisonMushroom,
        func = function(dir, uses)
            local m = gMarioStates[0]
            local np = gNetworkPlayers[0]
            set_action_after_throw(m, dir)
            spawn_sync_object(
                id_bhvPoisonMushroom,
                E_MODEL_POISON_MUSHROOM,
                m.pos.x, m.pos.y + 50, m.pos.z,
                function(o)
                    if dir ~= 3 then
                        if dir == 1 then
                            o.oForwardVel = m.forwardVel + 50
                        else
                            o.oForwardVel = 50
                        end
                        o.oVelY = 50
                        o.oMoveAngleYaw = m.faceAngle.y + (dir - 1) * 0x4000
                    else
                        o.oForwardVel = -10
                        o.oVelY = 0
                        o.oMoveAngleYaw = m.faceAngle.y
                    end

                    o.oFaceAngleYaw = o.oMoveAngleYaw
                    o.oObjectOwner = np.globalIndex
                end
            )
            return 0
        end,
    },
}

-- table of item objects (objects created by items).
local item_id_list = {
    [id_bhvGreenShell] = 3, -- blocked type (blocked by holding certain items)
    [id_bhvRedShell] = 3,   -- blocked type
    [id_bhvBanana] = 1,     -- collision type (breaks items on contact)
    [id_bhvBoomerang] = 4,  -- steal type (doesn't break items, picks up coins, shines, etc)
    [id_bhvFireball] = 2,   -- normal type (doesn't break items)
    [id_bhvBlueShell] = 2,  -- normal type
    [id_bhvPoisonMushroom] = 2,  -- normal type
}
function is_item(id)
    return item_id_list[id] or (id == id_bhvThrownBobomb) and 1
end

-- api
function add_item(data)
    table.insert(item_data, data)
    return #item_data
end
function add_item_object(id, type)
    item_id_list[id] = type
end