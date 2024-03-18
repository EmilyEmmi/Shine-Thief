-- this files handles item data, including probability and function

E_MODEL_BANANA = smlua_model_util_get_id("banana_geo")
E_MODEL_RED_SHELL = smlua_model_util_get_id("red_shell_geo")
E_MODEL_BOOMERANG = E_MODEL_BULLY -- TODO: actually make the mo9del

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
item_data = {
    [ITEM_BANANA] = {
        weight = 100,
        first = true, -- can get in first (all other items are off)
        model = E_MODEL_BANANA,
        hand = true,  -- show in hand
        scale = 0.5,
        func = function(dir)
            local m = gMarioStates[0]
            local np = gNetworkPlayers[0]
            play_character_sound(m, CHAR_SOUND_WAH2)
            set_mario_animation(m, MARIO_ANIM_THROW_LIGHT_OBJECT)
            spawn_sync_object(
                id_bhvBanana,
                E_MODEL_BANANA,
                m.pos.x, m.pos.y + 50, m.pos.z,
                function(o)
                    if dir ~= 3 then
                        o.oForwardVel = m.forwardVel + 35
                        o.oVelY = 50
                        o.oMoveAngleYaw = m.intendedYaw + (dir - 1) * 0x4000
                    else
                        o.oForwardVel = m.forwardVel - 10
                        o.oVelY = 0
                        o.oMoveAngleYaw = m.intendedYaw
                    end

                    o.oFaceAngleYaw = o.oMoveAngleYaw
                    o.oObjectOwner = np.globalIndex
                end
            )
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
        weight = 20,
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
        weight = 60,
        model = E_MODEL_RED_SHELL,
        first = true,
    },
    [ITEM_TRIPLE_SHELL] = {
        weight = 10,
        frantic = true,
        model = E_MODEL_RED_SHELL,
        count = 3,
    },
    [ITEM_DOUBLE_SHELL] = {
        weight = 0,
        model = E_MODEL_RED_SHELL,
        count = 2,
    },
    [ITEM_CAPE] = {
        weight = 70,
        first = true,
    },
    [ITEM_BOOMERANG] = {
        weight = 111140,
        hand = true,
        model = E_MODEL_BOOMERANG,
        func = function(dir, uses)
            local m = gMarioStates[0]
            local np = gNetworkPlayers[0]
            play_character_sound(m, CHAR_SOUND_WAH2)
            set_mario_animation(m, MARIO_ANIM_THROW_LIGHT_OBJECT)
            spawn_sync_object(
                id_bhvBoomerang,
                E_MODEL_BOOMERANG, -- TODO: should be boomerang
                m.pos.x, m.pos.y + 50, m.pos.z,
                function(o)
                    o.oForwardVel = 50
                    o.oVelY = 0
                    o.oMoveAngleYaw = m.intendedYaw + (dir - 1) * 0x4000

                    o.oFaceAngleYaw = o.oMoveAngleYaw
                    o.oObjectOwner = np.globalIndex
                    o.oAnimState = uses
                end
            )
            return 0
        end,
    },
    [ITEM_STAR] = {
        weight = 10,
        frantic = true,
        model = E_MODEL_STAR,
        yOffset = 40,
        scale = 0.7,
    },
    [ITEM_BULLET] = {
        weight = 40, -- not as good as in mario kart
        frantic = true,
        model = E_MODEL_BULLET_BILL,
        yOffset = 40,
        scale = 0.2,
    },
    [ITEM_POW] = {
        weight = 5,
        frantic = true,
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
        elseif get_player_owned_shine(0) ~= 0 and (sMario.shineTimer >= gGlobalSyncTable.winTime - 5) and not data.first then
            valid = false                                                                                       -- only certain items when close to winning and owning shine
        elseif sMario.shineTimer < gGlobalSyncTable.winTime - 15 and gMarioStates[0].marioObj.oTimer > 900 then -- after 30 seconds, players not doing well get better items
            if data.frantic then
                weight = weight * 2
            else
                weight = weight // 2
            end
        end

        -- frantic/skilled
        if valid and gGlobalSyncTable.items > 1 then
            if data.frantic == (gGlobalSyncTable.items == 2) then -- for frantic, frantic items have a higher chance, and vice versa
                weight = weight * 4
            else
                weight = weight // 4
            end
        end

        if valid then
            maxWeight = maxWeight + weight
            table.insert(weightRange, maxWeight)
            table.insert(itemRange, item)
        end
    end

    -- diplay probabilities for testing
    if DEBUG_MODE then
        local prevWeight = 0
        for i, weight in ipairs(weightRange) do
            djui_chat_message_create(string.format("%d: %d (%.2f%%)", itemRange[i], weight - prevWeight,
                ((weight - prevWeight) / maxWeight) * 100))
            prevWeight = weight
        end
    end

    local value = math.random(1, maxWeight)
    for i, weight in ipairs(weightRange) do
        if value <= weight then
            return itemRange[i] or ITEM_BANANA
        end
    end
    return ITEM_BANANA -- default (shouldn't happen but who knows)
end

function use_item(item, dir, uses)
    local data = item_data[item]
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
    network_init_object(o, true, {
    })
end

--- @param o Object
function banana_loop(o)
    local collisionFlags = object_step();
    if collisionFlags & OBJ_COL_FLAG_GROUNDED ~= 0 then
        o.oForwardVel = 0
        o.oVelY = 0
        cur_obj_update_floor()
        if is_hazard_floor(o.oFloorType) then
            obj_mark_for_deletion(o)
        end
    end
    if (o.oInteractStatus & INT_STATUS_INTERACTED) ~= 0 or o.oTimer > 900 then
        obj_mark_for_deletion(o)
    end
end

id_bhvBanana = hook_behavior(nil, OBJ_LIST_DEFAULT, true, banana_init, banana_loop, "bhvBanana")

-- boomerang (wip)
--- @param o Object
function boomerang_init(o)
    o.oFlags = (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oAction = 0
    o.oGravity = 0
    o.oBuoyancy = 1.5
    o.oAnimState = 0

    local hitbox = get_temp_object_hitbox()
    hitbox.damageOrCoinValue = 2
    hitbox.radius = 150
    hitbox.height = 150
    hitbox.hurtboxRadius = 150
    hitbox.hurtboxHeight = 150
    hitbox.downOffset = 0
    hitbox.interactType = INTERACT_DAMAGE
    obj_set_hitbox(o, hitbox)

    cur_obj_init_animation(1)
    network_init_object(o, true, {
    })
end

--- @param o Object
function boomerang_loop(o)
    local collisionFlags = object_step();
    if collisionFlags & OBJ_COL_FLAG_HIT_WALL ~= 0 then
        cur_obj_change_action(1)
    end

    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x1000
    if o.oAction == 0 then
        o.oForwardVel = o.oForwardVel - 3
        if o.oForwardVel <= 0 then
            cur_obj_change_action(1)
        end
    else -- return
        if o.oForwardVel < 50 then
            o.oForwardVel = o.oForwardVel + 3
        end
        local index = network_local_index_from_global(o.oObjectOwner) or 0
        local m = gMarioStates[index]
        o.oMoveAngleYaw = obj_angle_to_object(o, m.marioObj)
        if m.pos.y - o.oPosY > 160 or m.pos.y - o.oPosY < -160 then
            o.oVelY = (m.pos.y - o.oPosY) // 5
        else
            o.oVelY = 0
        end
    end
    if o.oTimer > 150 then
        obj_mark_for_deletion(o)
    end
end

id_bhvBoomerang = hook_behavior(nil, OBJ_LIST_DEFAULT, true, boomerang_init, boomerang_loop, "bhvBoomerang")