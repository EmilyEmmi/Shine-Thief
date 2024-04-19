-- this files handles item data, including probability and function

E_MODEL_BANANA = smlua_model_util_get_id("banana_geo")
E_MODEL_RED_SHELL = smlua_model_util_get_id("red_shell_geo")
E_MODEL_BOOMERANG = smlua_model_util_get_id("boomerang_geo")
E_MODEL_CAPE = smlua_model_util_get_id("feather_geo")
E_MODEL_POW = smlua_model_util_get_id("pow_block_geo")
E_MODEL_BLUE_SHELL = smlua_model_util_get_id("blue_shell_geo")

local ITEM_BANANA = 1
local ITEM_MUSHROOM = 2
local ITEM_TRIPLE_MUSHROOM = 3
local ITEM_DOUBLE_MUSHROOM = 4
local ITEM_SHELL = 5
local ITEM_TRIPLE_SHELL = 6
local ITEM_DOUBLE_SHELL = 7
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
item_data = {
    [ITEM_BANANA] = {
        weight = 90,
        first = true, -- can get in first (all other items are off)
        model = E_MODEL_BANANA,
        hand = true,  -- show in hand
        scale = 0.5,
        defaultDir = 3,
        func = function(dir)
            banana_general(dir)
            return 0
        end,
    },
    [ITEM_MUSHROOM] = {
        weight = 40,
        first = true,
        model = E_MODEL_1UP,
        func = function()
            mushroom_general()
            return 0
        end,
        bill = true,
    },
    [ITEM_TRIPLE_MUSHROOM] = {
        weight = 10,
        frantic = true, -- frantic item (more likely to appear for last and when Frantic is on)
        model = E_MODEL_1UP,
        count = 3,
        func = function()
            mushroom_general()
            return ITEM_DOUBLE_MUSHROOM
        end,
        bill = true,
    },
    [ITEM_DOUBLE_MUSHROOM] = {
        weight = 0,
        model = E_MODEL_1UP,
        count = 2,
        func = function()
            mushroom_general()
            return ITEM_MUSHROOM
        end,
        bill = true,
    },
    [ITEM_SHELL] = {
        weight = 70,
        model = E_MODEL_RED_SHELL,
        first = true,
        func = function(dir)
            shell_general(dir)
            return 0
        end,
    },
    [ITEM_TRIPLE_SHELL] = {
        weight = 15,
        frantic = true,
        model = E_MODEL_RED_SHELL,
        count = 3,
        func = function(dir)
            shell_general(dir)
            return ITEM_DOUBLE_SHELL
        end,
    },
    [ITEM_DOUBLE_SHELL] = {
        weight = 0,
        model = E_MODEL_RED_SHELL,
        count = 2,
        func = function(dir)
            shell_general(dir)
            return ITEM_SHELL
        end,
    },
    [ITEM_CAPE] = {
        weight = 70,
        first = true,
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
            else
                set_mario_action(m, ACT_CAPE_JUMP_SHELL, 0)
            end
            return 0
        end,
    },
    [ITEM_BOOMERANG] = {
        weight = 40,
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
            local np = gNetworkPlayers[0]
            set_action_after_toss(m, dir)
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
            return 0, 0
        end,
    },
    [ITEM_STAR] = {
        weight = 5,
        frantic = true,
        model = E_MODEL_STAR,
        yOffset = 30,
        scale = 0.7,
        func = function(dir)
            local m = gMarioStates[0]
            m.capTimer = 300 -- 10 seconds
            gPlayerSyncTable[0].star = true
            play_sound(SOUND_GENERAL_SHORT_STAR, m.marioObj.header.gfx.cameraToObject)
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
            play_sound(SOUND_OBJ_CANNON4, m.marioObj.header.gfx.cameraToObject)
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
        first = true,
        count = 3,
        model = E_MODEL_BANANA,
        defaultDir = 3,
        func = function(dir)
            banana_general(dir)
            return ITEM_DOUBLE_BANANA
        end,
    },
    [ITEM_DOUBLE_BANANA] = {
        weight = 0,
        count = 2,
        model = E_MODEL_BANANA,
        defaultDir = 3,
        func = function(dir)
            banana_general(dir)
            return ITEM_BANANA
        end,
    },
    [ITEM_FIRE_FLOWER] = {
        weight = 10,
        frantic = true,
        hand = true,
        bill = true,
        scale = 2,
        model = E_MODEL_RED_FLAME,
        updateAnimState = true,
        maxUses = 5,
        func = function(dir, uses)
            local m = gMarioStates[0]
            local np = gNetworkPlayers[0]
            throw_fireball(m, dir)
            uses = uses + 1
            if uses < 5 then
                return ITEM_FIRE_FLOWER, uses
            end
            return 0
        end
    },
    [ITEM_BOMB] = {
        weight = 20,
        first = true,
        hand = true,
        scale = 0.4,
        yOffset = -20,
        sideOffset = 10,
        model = E_MODEL_BLACK_BOBOMB,
        animation = gObjectAnimations.bobomb_seg8_anims_0802396C,
        func = function(dir)
            local m = gMarioStates[0]
            throw_bomb(m, dir)
            return 0
        end
    },
    [ITEM_TRIPLE_BOMB] = {
        weight = 10,
        frantic = true,
        count = 3,
        scale = 0.75,
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
        frantic = true,
        count = 2,
        scale = 0.75,
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
        frantic = true,
        model = E_MODEL_BLUE_SHELL,
        scale = 0.5,
        func = function(dir)
            local m = gMarioStates[0]
            local np = gNetworkPlayers[0]
            set_action_after_toss(m, dir)
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
}

-- get a random item (does weight and stuff)
function random_item()
    local weightRange = {}
    local itemRange = {}
    local maxWeight = 0
    local sMario = gPlayerSyncTable[0]
    local gIndex = network_global_index_from_local(0)

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
        elseif gGlobalSyncTable.gameMode == 0 and get_player_owned_shine(gIndex) ~= 0 and (sMario.points >= gGlobalSyncTable.winTime - 15) and not data.first then   -- only certain items when close to winning and owning shine
            valid = false
        else
            local hasMost, most = has_most_points(0) -- calculate most
            local myScore = get_point_amount(0)
            if gGlobalSyncTable.gameMode == 1 then
                hasMost, most = has_most_balloons(0)
                myScore = sMario.balloons
            end
            if (most - myScore) > 5 and gMarioStates[0].marioObj.oTimer > 900 and data.frantic then -- after 30 seconds, players not doing well get better items
                weight = weight * ((most - myScore) // 2.5)
            end
        end

        -- frantic/skilled
        if valid and gGlobalSyncTable.items > 1 then
            local frantic = data.frantic or false
            if frantic == (gGlobalSyncTable.items == 2) then -- for frantic, frantic items have a higher chance, and vice versa
                weight = weight * 4
            end
        end

        if valid then
            maxWeight = maxWeight + weight
            table.insert(weightRange, maxWeight)
            table.insert(itemRange, item)
        end
    end

    local value = math.random(1, maxWeight)
    -- display probabilities for testing
    if DEBUG_MODE then
        local prevWeight = 0
        for i, weight in ipairs(weightRange) do
            djui_chat_message_create(string.format("%d: %d-%d (%d, %.2f%%)", itemRange[i], prevWeight+1, weight,
                weight - prevWeight,
                ((weight - prevWeight) / maxWeight) * 100))
            prevWeight = weight
        end
        djui_chat_message_create(tostring(value))
    end

    for i, weight in ipairs(weightRange) do
        if value <= weight then
            return itemRange[i] or ITEM_BANANA
        end
    end
    return ITEM_BANANA -- default (shouldn't happen but who knows)
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

function mushroom_general()
    play_character_sound(gMarioStates[0], CHAR_SOUND_YAHOO_WAHA_YIPPEE)
    gPlayerSyncTable[0].mushroomTime = 60
end

function banana_general(dir)
    local m = gMarioStates[0]
    local np = gNetworkPlayers[0]
    set_action_after_toss(m, dir)
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

function shell_general(dir)
    local m = gMarioStates[0]
    local np = gNetworkPlayers[0]
    set_action_after_toss(m, dir)
    spawn_sync_object(
        id_bhvRedShell,
        E_MODEL_RED_SHELL,
        m.pos.x, m.pos.y + 50, m.pos.z,
        function(o)
            o.oForwardVel = m.forwardVel + 50
            o.oMoveAngleYaw = m.faceAngle.y + (dir - 1) * 0x4000
            o.oFaceAngleYaw = o.oMoveAngleYaw
            o.oObjectOwner = np.globalIndex
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
    set_action_after_toss(m, dir)
end

function throw_fireball(m, dir)
    set_action_after_toss(m, dir)
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
    if stepResult & OBJ_MOVE_LANDED ~= 0 then
        o.oForwardVel = 0
        o.oVelY = -10
        cur_obj_update_floor()
        if is_hazard_floor(o.oFloorType) then
            obj_mark_for_deletion(o)
        end
    end
    if (o.oInteractStatus & (INT_STATUS_ATTACKED_MARIO | INT_STATUS_TOUCHED_BOB_OMB)) ~= 0 or hitObject ~= 0 or o.oTimer > 900 then
        obj_mark_for_deletion(o)
    end
end

id_bhvBanana = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, banana_init, banana_loop, "bhvBanana")

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
    hitbox.downOffset = 0
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

    do_item_collision(o, true)

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
            if gPlayerSyncTable[0].item == 0 and shuffleItem == 0 and not is_dead(index) then
                gPlayerSyncTable[0].item = ITEM_BOOMERANG
                gPlayerSyncTable[0].itemUses = o.oAnimState
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

-- shell
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
function red_shell_loop(o)
    local stepResult = object_step_without_floor_orient()
    local index = network_local_index_from_global(o.oObjectOwner) or 1

    local hitObject = do_item_collision(o)

    if stepResult & OBJ_COL_FLAG_HIT_WALL ~= 0 or o.oInteractStatus & INT_STATUS_TOUCHED_BOB_OMB ~= 0 or hitObject ~= 0 then
        spawn_triangle_break_particles(2, 0x8B, 0.25, 0) -- MODEL_CARTOON_STAR
        obj_mark_for_deletion(o)
    end

    local maxDist = 2000
    local bestYaw = 0
    local targetIndex = network_local_index_from_global(o.oAnimState - 1) or 255
    local team = gPlayerSyncTable[index].team or 0
    if targetIndex ~= 255 then
        local sMario = gPlayerSyncTable[targetIndex]
        local m = gMarioStates[targetIndex]
        if not (is_player_active(m) ~= 0 and m.invincTimer == 0 and m.action & (ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE | ACT_GROUP_CUTSCENE) == 0 and (sMario.team == nil or sMario.team ~= 0 or sMario.team == team) and not is_spectator(targetIndex)) then
            targetIndex = 255
        else
            bestYaw = obj_angle_to_object(o, m.marioObj)
        end
    end

    if targetIndex == 255 then
        for i = 0, MAX_PLAYERS - 1 do -- target closest opponent
            local sMario = gPlayerSyncTable[i]
            local m = gMarioStates[i]
            if i ~= index and is_player_active(m) ~= 0 and m.invincTimer == 0 and m.action & (ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE | ACT_GROUP_CUTSCENE) == 0 and (sMario.team == nil or sMario.team == 0 or sMario.team ~= team) and not is_spectator(i) then
                local dist = dist_between_objects(o, m.marioObj)
                local yaw = obj_angle_to_object(o, m.marioObj)
                if dist < maxDist and abs_angle_diff(yaw, o.oMoveAngleYaw) <= 0x4000 then -- only target in front of
                    maxDist = dist
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
        if m.pos.y - o.oPosY > 100 or m.pos.y - o.oPosY < -100 then
            local dist = dist_between_objects(o, m.marioObj)
            o.oVelY = (m.pos.y - o.oPosY) // ((dist - 150) / vel)
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
    o.oBounciness = 1

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
    network_init_object(o, true, {})
end

--- @param o Object
function fireball_loop(o)
    if o.oTimer == 1 then
        cur_obj_play_sound_1(SOUND_OBJ_FLAME_BLOWN)
    end
    local stepResult = object_step_without_floor_orient()
    o.oAnimState = o.oAnimState + 1

    local hitObject = do_item_collision(o, true)

    if stepResult & OBJ_MOVE_LANDED ~= 0 then
        cur_obj_play_sound_1(SOUND_AIR_BOWSER_SPIT_FIRE)
        cur_obj_update_floor()
        if o.oFlameSpeedTimerOffset > 5 or o.oFloorType == SURFACE_DEATH_PLANE or o.oFloorType == SURFACE_VERTICAL_WIND then
            spawn_triangle_break_particles(2, 0x8B, 0.25, 0) -- MODEL_CARTOON_STAR
            obj_mark_for_deletion(o)
        else
            o.oFlameSpeedTimerOffset = o.oFlameSpeedTimerOffset + 1
            o.oVelY = 30
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
        do_item_collision(o, true)
        o.oAnimState = o.oAnimState + 1
        o.oInteractStatus = 0
        return
    end

    obj_move_xyz_using_fvel_and_yaw(o) -- go through walls because Screw You
    local index = network_local_index_from_global(o.oObjectOwner) or 1

    do_item_collision(o, true) -- ignore items too because Screw You

    local maxDist = 10000      -- basically infinite distance, SCREW. YOU.
    local bestYaw = 0
    local bestScore = 0
    local targetIndex = network_local_index_from_global(o.oAnimState - 1) or 255
    local team = gPlayerSyncTable[index].team or 0
    if targetIndex ~= 255 then
        local sMario = gPlayerSyncTable[targetIndex]
        local m = gMarioStates[targetIndex]
        if not (is_player_active(m) ~= 0 and (sMario.team == nil or sMario.team ~= 0 or sMario.team == team) and  not is_spectator(targetIndex)) then
            targetIndex = 255
        else
            bestYaw = obj_angle_to_object(o, m.marioObj)
        end
    end

    if targetIndex == 255 then
        for i = 0, MAX_PLAYERS - 1 do -- target closest opponent WITH HIGHEST SCORE
            local sMario = gPlayerSyncTable[i]
            local m = gMarioStates[i]
            if (i == index and targetIndex == 255) or (i ~= index and is_player_active(m) ~= 0 and (sMario.team == nil or sMario.team == 0 or sMario.team ~= team) and not is_spectator(i)) then
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

                if bestScore < score or (bestScore == score and dist < maxDist) then
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

-- like obj_attack_collided_from_other_object() but it ignores certain objects
function do_item_collision(o, ignoreItem)
    if o.numCollidedObjs == 0 then return 0 end

    local other = obj_get_collided_object(o, 0)

    local o_id = get_id_from_behavior(other.behavior)
    local itemType = is_item(o_id)
    if (other.oInteractType & (INTERACT_PLAYER | INTERACT_WATER_RING) == 0) and ((not itemType) or ((not ignoreItem) and itemType ~= 2 and objs_on_different_teams(o, other))) then
        other.oInteractStatus = other.oInteractStatus | ATTACK_PUNCH | INT_STATUS_WAS_ATTACKED | INT_STATUS_INTERACTED |
            INT_STATUS_TOUCHED_BOB_OMB
        return 1
    end

    return 0
end

function objs_on_different_teams(o, o2)
    local index = network_local_index_from_global(o.oObjectOwner)
    local index2 = network_local_index_from_global(o2.oObjectOwner)
    if not (index or index2) then return true end
    if index == index2 then return false end

    local sMario = gPlayerSyncTable[index]
    local sMario2 = gPlayerSyncTable[index2]

    if sMario.team == 0 or sMario2.team == 0 then return true end
    return sMario.team ~= sMario2.team
end

local item_id_list = {
    [id_bhvRedShell] = 1,
    [id_bhvBanana] = 1,
    [id_bhvBoomerang] = 2,
    [id_bhvFireball] = 2,
    [id_bhvBlueShell] = 2,
}
function is_item(id)
    return item_id_list[id] or (id == id_bhvThrownBobomb) and 1
end
