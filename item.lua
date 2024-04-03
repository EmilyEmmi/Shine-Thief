-- this files handles item data, including probability and function

E_MODEL_BANANA = smlua_model_util_get_id("banana_geo")
E_MODEL_RED_SHELL = smlua_model_util_get_id("red_shell_geo")
E_MODEL_BOOMERANG = smlua_model_util_get_id("boomerang_geo")
E_MODEL_CAPE = smlua_model_util_get_id("feather_geo")
E_MODEL_POW = smlua_model_util_get_id("pow_block_geo")

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
            set_mario_action(m, ACT_FLYING, 0)
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
                    o.oObjectOwner = np.globalIndex
                end
            )
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
}

-- get a random item (does weight and stuff)
function random_item()
    local weightRange = {}
    local itemRange = {}
    local maxWeight = 0
    local sMario = gPlayerSyncTable[0]

    for item, data in ipairs(item_data) do
        local weight = data.weight
        local valid = true
        if weight == 0 then
            valid = false
        elseif (item == ITEM_BOMB or item == ITEM_TRIPLE_BOMB) and gGlobalSyncTable.variant == 6 then
            valid = false
        elseif get_player_owned_shine(0) ~= 0 and (sMario.points >= gGlobalSyncTable.winTime - 15) and not data.first then -- only certain items when close to winning and owning shine
            valid = false
        elseif sMario.points < gGlobalSyncTable.winTime - 15 and gMarioStates[0].marioObj.oTimer > 900 and data.frantic then                -- after 30 seconds, players not doing well get better items
            weight = weight * 2
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
            djui_chat_message_create(string.format("%d: %d-%d (%d, %.2f%%)", itemRange[i], prevWeight, weight, weight - prevWeight,
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

-- banana (based on bomb)
--- @param o Object
function banana_init(o)
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oAction = 0
    o.oGravity = 2.5
    o.oBuoyancy = 1.5
    o.oAnimState = 0
    o.oBounciness = 0

    local hitbox = get_temp_object_hitbox()
    hitbox.damageOrCoinValue = 1
    hitbox.radius = 100
    hitbox.height = 100
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
    if stepResult & OBJ_MOVE_LANDED ~= 0 then
        o.oForwardVel = 0
        o.oVelY = -10
        cur_obj_update_floor()
        if is_hazard_floor(o.oFloorType) then
            obj_mark_for_deletion(o)
        end
    end
    if (o.oInteractStatus & INT_STATUS_ATTACKED_MARIO) ~= 0 or o.oTimer > 900 then
        obj_mark_for_deletion(o)
    end
end

id_bhvBanana = hook_behavior(nil, OBJ_LIST_GENACTOR, true, banana_init, banana_loop, "bhvBanana")

-- boomerang
--- @param o Object
function boomerang_init(o)
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)
    o.oFaceAnglePitch = 0x4000
    o.oFaceAngleRoll = 0
    o.oFaceAngleYaw = 0
    o.oAction = 0
    o.oGravity = 0
    o.oBuoyancy = 1.5
    o.oFriction = 1

    local hitbox = get_temp_object_hitbox()
    hitbox.damageOrCoinValue = 2
    hitbox.radius = 100
    hitbox.height = 100
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
        "oAnimState",
    })
end

--- @param o Object
function boomerang_loop(o)
    local stepResult = object_step_without_floor_orient()
    local index = network_local_index_from_global(o.oObjectOwner) or 1

    if stepResult & OBJ_COL_FLAG_HIT_WALL ~= 0 then
        if o.oAnimState > 2 then
            spawn_triangle_break_particles(2, 0x8B, 0.25, 2) -- MODEL_CARTOON_STAR
            obj_mark_for_deletion(o)
        elseif o.oAction == 0 then
            cur_obj_change_action(1)
        elseif o.oForwardVel > 0 then
            o.oForwardVel = -20
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

        o.oMoveAngleYaw = obj_angle_to_object(o, m.marioObj)
        if m.pos.y - o.oPosY > 100 or m.pos.y - o.oPosY < -100 then
            o.oVelY = (m.pos.y - o.oPosY) // 10
        elseif o.oForwardVel >= vel then
            o.oVelY = 0
        end

        local dist = dist_between_objects(o, m.marioObj)
        if dist <= 120 and index == 0 then
            if gPlayerSyncTable[0].item == 0 then
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

    if index == 0 then
        network_send_object(o, true)
    end
    o.oInteractStatus = 0
end

id_bhvBoomerang = hook_behavior(nil, OBJ_LIST_GENACTOR, true, boomerang_init, boomerang_loop, "bhvBoomerang")

-- shell
--- @param o Object
function red_shell_init(o)
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oAction = 0
    o.oGravity = 0
    o.oBuoyancy = 1.5
    o.oFriction = 1

    local hitbox = get_temp_object_hitbox()
    hitbox.damageOrCoinValue = 2
    hitbox.radius = 100
    hitbox.height = 100
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

    if stepResult & OBJ_COL_FLAG_HIT_WALL ~= 0 then
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
        if not (is_player_active(m) ~= 0 and m.invincTimer == 0 and m.action & (ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE | ACT_GROUP_CUTSCENE) == 0 and (sMario.team == nil or sMario.team ~= 0 or sMario.team == team) and not sMario.spectator) then
            targetIndex = 255
        else
            bestYaw = obj_angle_to_object(o, m.marioObj)
        end
    end

    if targetIndex == 255 then
        for i = 0, MAX_PLAYERS - 1 do -- target closest opponent
            local sMario = gPlayerSyncTable[i]
            local m = gMarioStates[i]
            if i ~= index and is_player_active(m) ~= 0 and m.invincTimer == 0 and m.action & (ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE | ACT_GROUP_CUTSCENE) == 0 and (sMario.team == nil or sMario.team == 0 or sMario.team ~= team) and not sMario.spectator then
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
            o.oVelY = (m.pos.y - o.oPosY) // 10
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

id_bhvRedShell = hook_behavior(nil, OBJ_LIST_GENACTOR, true, red_shell_init, red_shell_loop, "bhvRedShell")

-- fireballs
--- @param o Object
function fireball_init(o)
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oAction = 0
    o.oGravity = 4
    o.oBuoyancy = 1.5
    o.oFriction = 1
    o.oBounciness = 1

    local hitbox = get_temp_object_hitbox()
    hitbox.damageOrCoinValue = 2
    hitbox.radius = 100
    hitbox.height = 100
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

    if o.oTimer > 300 or (o.oInteractStatus & INT_STATUS_INTERACTED) ~= 0 then
        spawn_triangle_break_particles(2, 0x8B, 0.25, 0) -- MODEL_CARTOON_STAR
        obj_mark_for_deletion(o)
    end
end

id_bhvFireball = hook_behavior(nil, OBJ_LIST_GENACTOR, true, fireball_init, fireball_loop, "bhvFireBall")

local item_id_list = {
    [id_bhvRedShell] = 1,
    [id_bhvBanana] = 1,
    [id_bhvBoomerang] = 1,
    [id_bhvFireball] = 1,
}
function is_item(id)
    return item_id_list[id] ~= nil or id == id_bhvThrownBobomb
end
