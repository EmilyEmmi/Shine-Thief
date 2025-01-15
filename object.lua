-- This file handles the shine, pipes, and deleted objects

define_custom_obj_fields({
    oObjectOwner = "s32",       -- The global index of the player who owns this item. This used to be used for the shine too
    oShineDistFromHome = "f32", -- oStarSpawnDisFromHome screws up for some reason
    oBalloonNumber = "s32",
    oBalloonNextExists = "s32",
    oBalloonAppearance = "s32", -- would just use globalPlayerIndex but it acts funky
    oLastSafePosX = "s32", -- \
    oLastSafePosY = "s32", -- | for shines and moons
    oLastSafePosZ = "s32", -- /
})

local already_spawn_pointer = {} -- keep track of already used objects (for arena)

-- The shine is built off the star, obviously
--- @param o Object
function bhv_shine_init(o)
    local hitbox = get_temp_object_hitbox()
    hitbox.interactType = INTERACT_WATER_RING -- Don't want to have INTERACT_STAR because it has hard-coded behavior
    hitbox.radius = 80
    hitbox.height = 50
    obj_set_hitbox(o, hitbox)

    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oGravity = 2
    o.oBounciness = -0.2
    o.oBuoyancy = -1
    o.oFriction = 0.8
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oAnimState = 0
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
        'activeFlags',
        'oObjectOwner',
        'oVelY',
        'oLastSafePosX',
        'oLastSafePosY',
        'oLastSafePosZ',
    })
end

--- @param o Object
function bhv_shine_loop(o)
    local send = false
    local m = nearest_living_mario_state_to_object(o)

    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x800 -- spin
    local shineOwner = get_shine_owner(o.oBehParams)

    if shineOwner ~= -1 then -- go above owner's head
        local np = network_player_from_global_index(shineOwner)
        if network_is_server() then o.oAction = 0 end
        if np and np.connected and is_player_active(gMarioStates[np.localIndex]) ~= 0 then
            local ownerM = gMarioStates[np.localIndex]
            o.oTimer = 0
            o.oPosX = ownerM.pos.x
            o.oPosY = ownerM.pos.y + 250
            o.oPosZ = ownerM.pos.z
            if network_is_server() then
                -- update safe pos
                if m.pos.y == m.floorHeight and not (is_hazard_floor(m.floor.type) or mario_floor_is_slippery(m) ~= 0) then
                    o.oLastSafePosX = m.pos.x
                    o.oLastSafePosY = m.floorHeight + 160
                    o.oLastSafePosZ = m.pos.z
                end
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
        and (o.oAction == 0 or o.oTimer > 30)
        and dist_between_objects(o, m.marioObj) <= 275 then -- interaction (only if shine has not been dropped recently) handled by the server
        -- set shine owner to the collecter
        shineOwner = set_player_owned_shine(m.playerIndex, o.oBehParams)
        cur_obj_change_action(0)
        cur_obj_become_intangible()
        -- create popup + sound
        network_send_include_self(true, {
            id = PACKET_SHINE,
            victim = network_global_index_from_local(m.playerIndex),
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
    if o.oAction == 0 and shineOwner == -1 and network_is_server() then -- default action, can be picked up
        cur_obj_become_tangible()
        cur_obj_update_floor()
        if is_hazard_floor(o.oFloorType) and dist_between_object_and_point(o, o.oLastSafePosX, o.oLastSafePosY, o.oLastSafePosZ) > 1 then
            shine_return(o)
            cur_obj_become_intangible()
        end
    elseif o.oAction == 1 and network_is_server() then -- bouncing on ground
        local prevY = o.oPosY
        local collisionFlags = object_step_without_floor_orient()
        cur_obj_update_floor()

        -- prevent ceiling clip
        if ((o.oFloorHeight > prevY + 2 or (thisLevel and thisLevel.maxHeight and o.oPosY > thisLevel.maxHeight))) and o.oVelY > 2 then
            o.oPosY = prevY
            o.oVelY = 0
        end

        o.oFaceAngleYaw = o.oFaceAngleYaw + 0x1000 -- spin faster

        if o.oTimer >= 10 then
            cur_obj_become_tangible()
        end

        if (o.oFloorType == SURFACE_DEATH_PLANE or o.oFloorType == SURFACE_VERTICAL_WIND) and (o.oPosY - o.oFloorHeight < 2048) then -- return if fallen
            shine_return(o)
            cur_obj_become_intangible()
            cur_obj_play_sound_1(SOUND_GENERAL_GRAND_STAR_JUMP)
        elseif is_hazard_floor(o.oFloorType)
            and collisionFlags & OBJ_COL_FLAG_GROUNDED ~= 0 then -- return if in quicksand or lava
            shine_return(o)
            cur_obj_become_intangible()
            cur_obj_play_sound_1(SOUND_GENERAL_GRAND_STAR_JUMP)
        elseif (o.oForwardVel < 2 and o.oVelY < 1) or (collisionFlags & OBJ_COL_FLAG_GROUNDED ~= 0 and o.oTimer > 300) then -- sometimes the shine gets stuck on slopes, so stop automatically after 10 seconds
            cur_obj_play_sound_1(SOUND_GENERAL_GRAND_STAR_JUMP)
            if is_hazard_floor(o.oFloorType) then
                -- prevent shine from getting stuck on these floors
                shine_return(o)
                cur_obj_become_intangible()
            elseif find_water_level(o.oPosX, o.oPosZ) > o.oFloorHeight then -- stay in place in water
                o.oForwardVel = 0
                cur_obj_change_action(0)
            else
                o.oForwardVel = 0
                o.oPosY = o.oFloorHeight + 160 -- Mario is 161 units tall; thus Mario is just barely able to pick this up without jumping
                cur_obj_change_action(0)
            end
        elseif collisionFlags & OBJ_COL_FLAG_GROUNDED ~= 0 then
            cur_obj_play_sound_1(SOUND_GENERAL_GRAND_STAR_JUMP)
            -- update safe pos
            if o.oFloor and not is_hazard_floor(o.oFloorType, o.oFloor.normal.y) then
                o.oLastSafePosX = o.oPosX
                if o.oPosY - o.oFloorHeight < 160 then
                    o.oLastSafePosY = o.oFloorHeight + 160
                else
                    o.oLastSafePosY = o.oPosY + 160
                end
                o.oLastSafePosZ = o.oPosZ
            end
        end

        send = true
    elseif o.oAction == 2 and network_is_server() then                     -- return to home if off stage (from star code)
        obj_move_xyz_using_fvel_and_yaw(o)
        o.oStarSpawnUnkFC = o.oStarSpawnUnkFC + o.oVelY                    -- why?
        o.oPosY = o.oStarSpawnUnkFC + sins((o.oTimer * 0x8000) / 30) * 400 -- why?
        o.oFaceAngleYaw = o.oFaceAngleYaw + 0x1000                         -- spin faster
        if (o.oTimer == 30) then                                           -- always returns after 1 second
            o.oPosX = o.oLastSafePosX
            o.oPosY = o.oLastSafePosY
            o.oPosZ = o.oLastSafePosZ

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

--- @param o Object
function bhv_moon_loop(o)
    local m = nearest_living_mario_state_to_object(o)
    local isOwner = false
    local send = false

    if o.oObjectOwner == nil or o.oObjectOwner == 0 then
        if o.oTimer > 30 then -- if no owner is found for 30s, give ownership to host
            o.oObjectOwner = 1
            isOwner = network_is_server()
            send = true
        end
    elseif o.oObjectOwner == 1 then
        isOwner = network_is_server()
    else
        -- owner is whoever dropped it, and they handle interaction (like how the host always handles interaction for shine thief)
        local np = network_player_from_global_index(o.oObjectOwner - 1)
        if np and np.localIndex == 0 then
            isOwner = true
        elseif np and np.connected and is_player_active(gMarioStates[np.localIndex]) ~= 0 then
            -- nothing
        else
            o.oObjectOwner = 1
            isOwner = network_is_server() -- give ownership to host if the owner dced
            send = true
        end
    end
    

    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x800 -- spin

    if m and isOwner and gGlobalSyncTable.gameState ~= 1
        and (o.oAction == 0 or o.oTimer > 30) 
        and dist_between_objects(o, m.marioObj) <= 275 then -- interaction (only if shine has not been dropped recently)
        obj_mark_for_deletion(o)
        spawn_sync_object(id_bhvGoldenCoinSparkles, E_MODEL_SPARKLES, o.oPosX, o.oPosY, o.oPosZ, nil)
        -- create popup + sound
        if m.playerIndex == 0 then
            on_packet_moon({ victim = network_global_index_from_local(0) })
        else
            network_send_to(m.playerIndex, true, {
                id = PACKET_MOON,
                victim = network_global_index_from_local(m.playerIndex),
            })
        end
        send = true
    end

    -- handles bouncing and returning
    if o.oAction == 0 then
        cur_obj_become_tangible()
        cur_obj_update_floor()
        if isOwner and is_hazard_floor(o.oFloorType) and dist_between_object_and_point(o, o.oLastSafePosX, o.oLastSafePosY, o.oLastSafePosZ) > 1 then
            shine_return(o)
            cur_obj_become_intangible()
            send = true
        end
    elseif o.oAction == 1 then -- bouncing on ground
        send = true
        local prevY = o.oPosY
        local collisionFlags = object_step_without_floor_orient()
        cur_obj_update_floor()

        -- prevent ceiling clip
        if ((o.oFloorHeight > prevY + 2 or (thisLevel and thisLevel.maxHeight and o.oPosY > thisLevel.maxHeight))) and o.oVelY > 2 then
            o.oPosY = prevY
            o.oVelY = 0
        end

        o.oFaceAngleYaw = o.oFaceAngleYaw + 0x1000 -- spin faster

        if o.oTimer >= 10 then
            cur_obj_become_tangible()
        end

        if (o.oFloorType == SURFACE_DEATH_PLANE or o.oFloorType == SURFACE_VERTICAL_WIND) and (o.oPosY - o.oFloorHeight < 2048) then -- return if fallen
            if isOwner then shine_return(o) end
            cur_obj_become_intangible()
            cur_obj_play_sound_1(SOUND_GENERAL_GRAND_STAR_JUMP)
        elseif is_hazard_floor(o.oFloorType)
            and collisionFlags & OBJ_COL_FLAG_GROUNDED ~= 0 then -- return if in quicksand or lava
            if isOwner then shine_return(o) end
            cur_obj_become_intangible()
            cur_obj_play_sound_1(SOUND_GENERAL_GRAND_STAR_JUMP)
        elseif (o.oForwardVel < 2 and o.oVelY < 1) or (collisionFlags & OBJ_COL_FLAG_GROUNDED ~= 0 and o.oTimer > 300) then -- sometimes the shine gets stuck on slopes, so stop automatically after 10 seconds
            cur_obj_play_sound_1(SOUND_GENERAL_GRAND_STAR_JUMP)
            if is_hazard_floor(o.oFloorType) then
                -- prevent shine from getting stuck on these floors
                if isOwner then shine_return(o) end
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
        elseif collisionFlags & OBJ_COL_FLAG_GROUNDED ~= 0 then
            cur_obj_play_sound_1(SOUND_GENERAL_GRAND_STAR_JUMP)
            -- update safe pos
            if o.oFloor and not is_hazard_floor(o.oFloorType, o.oFloor.normal.y) then
                o.oLastSafePosX = o.oPosX
                if o.oPosY - o.oFloorHeight < 160 then
                    o.oLastSafePosY = o.oFloorHeight + 160
                else
                    o.oLastSafePosY = o.oPosY + 160
                end
                o.oLastSafePosZ = o.oPosZ
            end
        end
    elseif o.oAction == 2 then                                             -- return to home if off stage (from star code)
        obj_move_xyz_using_fvel_and_yaw(o)
        o.oStarSpawnUnkFC = o.oStarSpawnUnkFC + o.oVelY                    -- why?
        o.oPosY = o.oStarSpawnUnkFC + sins((o.oTimer * 0x8000) / 30) * 400 -- why?
        o.oFaceAngleYaw = o.oFaceAngleYaw + 0x1000                         -- spin faster
        if (o.oTimer >= 30) and isOwner then                               -- always returns after 1 second
            o.oPosX = o.oLastSafePosX
            o.oPosY = o.oLastSafePosY
            o.oPosZ = o.oLastSafePosZ

            cur_obj_change_action(0)
            cur_obj_become_tangible()
            o.oForwardVel = 0
        end
        send = true
    end

    o.oInteractStatus = 0

    -- send object data to clients
    if isOwner and o.oSyncID ~= 0 and send then
        network_send_object(o, true)
    end
end

id_bhvShine = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_shine_init, bhv_shine_loop, "bhvShine")
id_bhvMoon = hook_behavior(nil, OBJ_LIST_LEVEL, true, bhv_shine_init, bhv_moon_loop, "bhvMoon")

-- uses the same formula as stars
function shine_return(shine, home)
    if home then
        shine.oLastSafePosX, shine.oLastSafePosY, shine.oLastSafePosZ = shine.oHomeX, shine.oHomeY, shine.oHomeZ
    end
    if thisLevel and thisLevel.shineDefaultHeight then
        shine.oLastSafePosY = thisLevel.shineDefaultHeight
    end
    local returnPos = {x = shine.oLastSafePosX, y = shine.oLastSafePosY, z = shine.oLastSafePosZ}
    shine.oMoveAngleYaw = atan2s(returnPos.z - shine.oPosZ, returnPos.x - shine.oPosX)
    shine.oShineDistFromHome = math.sqrt(sqrf(returnPos.x - shine.oPosX) + sqrf(returnPos.z - shine.oPosZ))
    shine.oVelY = (returnPos.y - shine.oPosY) / 30
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
        network_send_include_self(true, {
            id = PACKET_SHINE,
            victim = np.globalIndex,
            attacker = attacker and network_global_index_from_local(attacker),
            lost = true,
        })
    elseif dropType == 3 then
        network_send_include_self(true, {
            id = PACKET_SHINE,
            victim = np.globalIndex,
            attacker = gNetworkPlayers[attacker].globalIndex,
        })
    end

    local shine = obj_get_first_with_behavior_id_and_field_s32(id_bhvShine, 0x40, ownedShine)

    if shine and network_is_server() then
        shine.oTimer = 0
        if dropType == 1 or dropType == 4 or dropType == 5 then -- fell off stage, spectator, respawn
            shine_return(shine, (dropType ~= 1)) -- home if not fallen off stage
        elseif dropType == 2 then -- pass
            shine.oVelY = 0
            shine.oAction = 3

            -- pass to closest teammate
            local vel = 60
            local angle = m.intendedYaw
            local reachFrames = 15
            local team = gPlayerSyncTable[m.playerIndex].team
            local minDist = 3000
            for i = 0, MAX_PLAYERS - 1 do
                local m2 = gMarioStates[i]
                if index ~= i and gPlayerSyncTable[i].team == team and not is_dead(i) then
                    local pos = {x = m2.pos.x, y = m2.pos.y + 80, z = m2.pos.z}
                    -- throw to floor/water level if not flying or swimming
                    if m2.action & ACT_FLAG_SWIMMING_OR_FLYING == 0 then
                        pos.y = math.max(m2.waterLevel, m2.floorHeight) + 80
                    else
                        pos.y = pos.y + m2.vel.y*15
                    end
                    local yDist = shine.oPosY - pos.y
                    if yDist < 0 and yDist >= -80 then
                        pos.y = pos.y - yDist
                        yDist = 0
                    end
                    if yDist >= 0 then
                        -- throw to ideal position based on speed
                        local thisReachFrames = math.ceil((math.sqrt(4 * yDist + 1) - 1) / 2)
                        if m2.action & ACT_FLAG_STATIONARY == 0 then
                            pos.x = pos.x + m2.vel.x*thisReachFrames
                            pos.z = pos.z + m2.vel.z*thisReachFrames
                        end
                        local dist = dist_between_object_and_point(m.marioObj, pos.x, pos.y, pos.z)
                        if minDist > dist then
                            minDist = dist
                            angle = obj_angle_to_point(shine, pos.x, pos.z)
                            reachFrames = thisReachFrames
                        end
                    end
                end
            end

            -- calculate velocity for perfect shot
            vel = math.min(math.ceil(minDist / reachFrames), vel)

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

local lastBalloonStolen = false
local lastBalloonOwner = -1
function lose_balloon(dropType, attacker)
    if gGlobalSyncTable.reduceObjects then
        lastBalloonOwner = network_global_index_from_local(0)
    end
    
    local sMario = gPlayerSyncTable[0]
    local steal = -1
    if dropType == 2 then -- pass balloons
        if sMario.balloons > 1 then
            local m = gMarioStates[0]
            local team = sMario.team
            local minDist = 500
            local passChoice = -1
            for i = 1, MAX_PLAYERS - 1 do
                if gPlayerSyncTable[i].team == team and gPlayerSyncTable[i].balloons < 5 and (not is_spectator(i)) then
                    local player = gMarioStates[i].marioObj
                    local dist = dist_between_objects(m.marioObj, player)
                    if minDist > dist then
                        minDist = dist
                        passChoice = i
                    end
                end
            end

            if passChoice ~= -1 then
                sMario.balloons = sMario.balloons - 1
                network_send_to(passChoice, true, {
                    id = PACKET_BALLOON,
                    victim = network_global_index_from_local(0),
                    attacker = network_global_index_from_local(passChoice),
                    share = lastBalloonOwner,
                })
                on_packet_balloon({
                    victim = network_global_index_from_local(0),
                    attacker = network_global_index_from_local(passChoice),
                    share = lastBalloonOwner,
                })
                lastBalloonStolen = true
            end
        end
        return
    elseif dropType == 3 then
        sMario.balloons = sMario.balloons - 1
        steal = lastBalloonOwner
        lastBalloonStolen = true
    else
        sMario.balloons = sMario.balloons - 1
    end

    if sMario.balloons == 0 then
        local gIndex = network_global_index_from_local(0)
        if dropType ~= 1 then
            drop_item()
            go_to_mario_start(0, gIndex, true)
        else
            shuffleItem = 0
            sMario.item = 0
            sMario.itemUses = 0
        end

        if (gGlobalSyncTable.gameMode == 1 or gGlobalSyncTable.showTime) and gGlobalSyncTable.gameState == 2 then
            set_eliminated(0)
            network_send_include_self(true, {
                id = PACKET_BALLOON,
                victim = network_global_index_from_local(0),
                attacker = attacker and network_global_index_from_local(attacker),
                sideline = true,
                steal = steal,
            })
        else
            sMario.points = math.floor(sMario.points // 1.5) -- using "//" alone causes float conversion
            sMario.balloons = gGlobalSyncTable.startBalloons or 3
            refillBalloons = 6 - (gGlobalSyncTable.startBalloons or 3)
            network_send_include_self(true, {
                id = PACKET_BALLOON,
                victim = gIndex,
                attacker = attacker and network_global_index_from_local(attacker),
                sideline = true,
                steal = steal,
            })
        end
    elseif attacker then
        network_send_to(attacker, true, {
            id = PACKET_BALLOON,
            victim = network_global_index_from_local(0),
            attacker = network_global_index_from_local(attacker),
            steal = steal,
        })
        on_packet_balloon({
            attacker = network_global_index_from_local(attacker),
            victim = network_global_index_from_local(0),
            steal = steal,
        })
    else
        on_packet_balloon({
            victim = network_global_index_from_local(0),
            fall = (dropType == 1),
        })
    end
end

function lose_coins(index, dropType, attacker)
    local sMario = gPlayerSyncTable[index]
    if sMario.points == nil or sMario.points == 0 then return end
    local steal = 0
    local dropped = 0
    if dropType == 2 then -- no pass action here
        return
    elseif dropType == 3 then
        dropped = math.min(sMario.points, 10)
        steal = dropped
    elseif dropType == 4 or sMario.points <= 3 then -- spectate (or drop all 3)
        dropped = sMario.points
    else
        dropped = clamp(sMario.points // 3, 3, 15)
    end

    if dropped > 0 then
        sMario.points = sMario.points - dropped
        local gIndex = network_global_index_from_local(index)

        if dropType ~= 4 then
            if attacker then
                network_send_to(attacker, true, {
                    id = PACKET_LOSE_COINS,
                    victim = gIndex,
                    attacker = network_global_index_from_local(attacker),
                    steal = steal,
                    fall = (dropType == 1),
                })
            end
            on_packet_lose_coins({
                victim = gIndex,
                attacker = attacker and network_global_index_from_local(attacker),
                steal = steal,
                fall = (dropType == 1),
            })
        end

        if dropType == 3 then return end

        -- spawn coins, blue ones too if the player has a lot
        local m = gMarioStates[index]
        local blue = 0
        local yellow = dropped
        if dropped > 10 then
            blue = dropped // 5 - 1
            yellow = dropped % 5 + 5
        end

        local x, y, z = m.pos.x, m.pos.y, m.pos.z
        local id = id_bhvSTYellowCoin
        local model = E_MODEL_YELLOW_COIN
        for i = 1, yellow + blue do
            if i == yellow + 1 then
                id = id_bhvSTBlueCoin
                model = E_MODEL_BLUE_COIN
            end

            spawn_sync_object(id, model, x, y, z, function(o)
                o.oVelY = math.random(10, 50)
                o.oForwardVel = math.random(5, 30)
                o.oMoveAngleYaw = math.random(0, 0xFFFF)
            end)
        end
    end
end

function lose_moon(index, dropType, attacker)
    local sMario = gPlayerSyncTable[index]
    local steal = -1
    local initialPoints = sMario.points
    if dropType == 2 then -- share shines
        if sMario.balloons > 1 then
            local m = gMarioStates[index]
            local team = sMario.team
            local minDist = 500
            local passChoice = -1
            for i = 1, MAX_PLAYERS - 1 do
                if gPlayerSyncTable[i].team == team and (not is_dead(i)) then
                    local player = gMarioStates[i].marioObj
                    local dist = dist_between_objects(m.marioObj, player)
                    if minDist > dist then
                        minDist = dist
                        passChoice = i
                    end
                end
            end

            if passChoice ~= -1 then
                sMario.points = sMario.points - 1
                network_send_to(passChoice, true, {
                    id = PACKET_MOON,
                    victim = network_global_index_from_local(index),
                    attacker = network_global_index_from_local(passChoice),
                    share = true,
                })
                on_packet_moon({
                    victim = network_global_index_from_local(index),
                    attacker = network_global_index_from_local(passChoice),
                    share = true,
                })
            end
        end
        return
    elseif dropType == 3 then
        sMario.points = sMario.points - 1
        steal = 1
        lastBalloonStolen = true
    elseif dropType == 4 then
        sMario.points = 0
    else
        sMario.points = sMario.points - 1
    end

    local dropped = (initialPoints - sMario.points)
    if steal == -1 and dropped > 0 then
        local m = gMarioStates[index]
        local x, y, z = m.pos.x, m.pos.y, m.pos.z
        for i = 1, dropped do
            spawn_sync_object(id_bhvMoon, E_MODEL_MOON, x, y, z, function(moon)
                local validMarks = {}
                local mark = obj_get_first_with_behavior_id(id_bhvShineMarker)
                local firstMark = mark
                while mark do
                    if mark.oBehParams == 0 then
                        table.insert(validMarks, mark)
                    end
                    mark = obj_get_next_with_same_behavior_id(mark)
                end
                if #validMarks ~= 0 then
                    mark = validMarks[math.random(1, #validMarks)]
                    mark.parentObj = moon
                    mark.oBehParams = moon.oSyncID
                    if mark.oSyncID ~= 0 then
                        network_send_object(mark, true)
                    end
                    moon.oHomeX, moon.oHomeY, moon.oHomeZ = mark.oPosX, mark.oPosY,
                        mark.oPosZ
                elseif dropType == 0 then
                    moon.oHomeX, moon.oHomeY, moon.oHomeZ = x, y + 40, z
                elseif firstMark then
                    moon.oHomeX, moon.oHomeY, moon.oHomeZ = firstMark.oPosX + 100, firstMark.oPosY, firstMark.oPosZ
                end
                moon.oHomeY = moon.oHomeY + 120
                moon.oObjectOwner = network_global_index_from_local(0) + 1 -- if host spawns, they own it

                -- update last safe pos
                if not (is_hazard_floor(m.floor.type) or mario_floor_is_slippery(m) ~= 0) then
                    moon.oLastSafePosX = x
                    moon.oLastSafePosY = m.floorHeight + 160
                    moon.oLastSafePosZ = z
                else
                    moon.oLastSafePosX = moon.oHomeX
                    moon.oLastSafePosY = moon.oHomeY
                    moon.oLastSafePosZ = moon.oHomeZ
                end

                if dropType ~= 0 then
                    shine_return(moon, (dropType ~= 1))
                else
                    moon.oVelY = 50
                    moon.oAction = 1
                    moon.oForwardVel = 20
                    moon.oMoveAngleYaw = math.random(0, 0xFFFF) -- random; any direction
                end
            end)
        end
    end

    if dropType == 4 then return end

    if dropType ~= 4 then
        if attacker then
            network_send_include_self(true, {
                id = PACKET_MOON,
                victim = network_global_index_from_local(index),
                attacker = network_global_index_from_local(attacker),
                steal = steal,
                lost = true,
            })
        else
            network_send_include_self(true, {
                id = PACKET_MOON,
                victim = network_global_index_from_local(index),
                lost = true,
            })
        end
    end
end

function handle_hit(index, dropType, attacker, item)
    if attacker == 0 then attacker = nil end -- prevent hurting ourselves
    if gGlobalSyncTable.gameMode == 0 then
        if get_player_owned_shine(index) == 0 then return end
        if not network_is_server() then
            -- send drop packet to server
            local owner = nil
            if index ~= nil then owner = network_global_index_from_local(index) end
            local globalAttacker = nil
            if attacker ~= nil then globalAttacker = network_global_index_from_local(attacker) end
            network_send_to(1, true, {
                id = PACKET_DROP_SHINE,
                victim = owner,
                dropType = dropType,
                attacker = globalAttacker,
            })
        else
            -- drop shine
            lose_shine(index, dropType, attacker)
        end
    elseif gGlobalSyncTable.gameMode < 3 then
        local sMario = gPlayerSyncTable[index]
        if (gGlobalSyncTable.gameState == 0 or gGlobalSyncTable.gameState == 2) and index == 0 and sMario.balloons ~= 0 and (not is_dead(0)) then
            lose_balloon(dropType, attacker)
        end
    elseif gGlobalSyncTable.gameMode == 3 then
        local sMario = gPlayerSyncTable[index]
        if (gGlobalSyncTable.gameState == 0 or gGlobalSyncTable.gameState == 2) and index == 0 and sMario.points ~= 0 and (dropType == 4 or not is_spectator(0)) then
            lose_coins(index, dropType, attacker)
        end
    elseif gGlobalSyncTable.gameMode == 4 then
        if index ~= 0 or is_dead(index) then return end
        if dropType == 2 then return end
        if (gGlobalSyncTable.gameState ~= 0 and gGlobalSyncTable.gameState ~= 2) then return end
        local sMario = gPlayerSyncTable[index]
        if gGlobalSyncTable.gameMode == 4 and sMario.showOnMap ~= -1 then
            sMario.showOnMap = 45 -- show on map when hurt
        end
        if (not item) and (attacker or dropType ~= 0) and sMario.team ~= 2 then
            sMario.eliminated = math.random(1, 3)
            if dropType ~= 1 and index == 0 then
                drop_item()
            else
                sMario.item, sMario.itemUses = 0, 0
                shuffleItem = 0
            end
            local owner = nil
            if index ~= nil then owner = network_global_index_from_local(index) end
            local globalAttacker = nil
            if attacker ~= nil then globalAttacker = network_global_index_from_local(attacker) end

            network_send_include_self(true, {
                id = PACKET_CAPTURE,
                victim = owner,
                attacker = globalAttacker,
            })
        end
    elseif gGlobalSyncTable.gameMode == 5 then
        local sMario = gPlayerSyncTable[index]
        if (gGlobalSyncTable.gameState == 0 or gGlobalSyncTable.gameState == 2) and index == 0 and sMario.points ~= 0 and (dropType == 4 or not is_spectator(0)) then
            lose_moon(index, dropType, attacker)
        end
    end
end

function set_eliminated(index, lowest)
    local sMario = gPlayerSyncTable[index]
    if sMario.eliminated ~= 0 then return end
    sMario.isBomb = (gGlobalSyncTable.bombSetting ~= 0) and not sMario.spectator
    sMario.item, sMario.itemUses = 0, 0
    if index == 0 then
        stop_cap_music()
        shuffleItem = 0
    end
    sMario.star, sMario.bulletTimer, sMario.smallTimer = false, 0, 0

    if lowest then
        sMario.eliminated = 2
        return
    end
    local max = 1
    for i = 1, MAX_PLAYERS - 1 do
        local sMario2 = gPlayerSyncTable[i]
        if sMario2.eliminated > max then
            max = sMario2.eliminated
        end
    end
    sMario.eliminated = max + 1
end

-- gets nearest mario state that is alive to an object
function nearest_living_mario_state_to_object(o)
    local maxDist = -1
    local nearestM
    for i=0,MAX_PLAYERS-1 do
        local m = gMarioStates[i]
        if is_player_active(m) ~= 0 and not is_dead(i) then
            local dist = dist_between_objects(m.marioObj, o)
            if maxDist == -1 or dist < maxDist then
                maxDist = dist
                nearestM = m
            end
        end
    end
    return nearestM
end

-- command to reset shine
function reset_shine_command(msg)
    if not (network_is_server() or network_is_moderator()) then
        djui_chat_message_create("You lack the power, young one.")
        return true
    elseif gGlobalSyncTable.gameMode ~= 0 and gGlobalSyncTable.gameMode ~= 5 then
        djui_chat_message_create("Not availabe in this mode!")
        return true
    end

    network_send_include_self(true, {
        id = PACKET_RESET_SHINE,
        reset = tonumber(msg),
    })
    return true
end

hook_chat_command("reset", "[NUM] - Resets the shine or moon", reset_shine_command)

-- command to move shine
function move_shine_command(msg)
    if not (network_is_server() or network_is_moderator()) then
        djui_chat_message_create("You lack the power, young one.")
        return true
    elseif gGlobalSyncTable.gameMode ~= 0 and gGlobalSyncTable.gameMode ~= 4 and gGlobalSyncTable.gameMode ~= 5 then
        djui_chat_message_create("Not availabe in this mode!")
        return true
    end

    network_send_include_self(true, {
        id = PACKET_MOVE_SHINE,
        mover = network_global_index_from_local(0),
        moved = tonumber(msg),
    })
    return true
end

hook_chat_command("move", "[NUM] - Moves the shine, moon, or cage to where you are standing", move_shine_command)

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
end

--- @param o Object
function st_pipe_loop(o)
    local m = nearest_mario_state_to_object(o)
    if m and obj_check_if_collided_with_object(o, m.marioObj) == 1 then
        local pair = obj_get_first_with_behavior_id_and_field_s32(id_bhvSTPipe, 0x40, o.oBehParams2ndByte) -- 0x40 is "oBehParams"
        if pair then
            if pair.oFaceAnglePitch >= 0 then
                drop_and_set_mario_action(m, ACT_TRIPLE_JUMP, 1)
                m.pos.y = pair.oPosY + 160
                m.vel.y = 65
            else
                drop_and_set_mario_action(m, ACT_FREEFALL, 0)
                mario_set_forward_vel(m, 0)
                m.pos.y = pair.oPosY - 320
                m.vel.y = math.min(0, m.vel.y)
                m.invincTimer = math.max(m.invincTimer, 20)
            end

            m.pos.x = pair.oPosX
            m.peakHeight = m.pos.y
            m.pos.z = pair.oPosZ
            m.faceAngle.y = pair.oFaceAngleYaw
            --m.actionTimer = 11
            if m.playerIndex == 0 then
                cur_obj_play_sound_1(SOUND_MENU_ENTER_PIPE)
                soft_reset_camera_fix_bug(m.area.camera)
                warp_camera(m.pos.x - gLakituState.curPos.x, m.pos.y - gLakituState.curPos.y, m.pos.z - gLakituState.curPos.z)
                skip_camera_interpolation()
                m.statusForCamera.pos.y = m.pos.y
                m.statusForCamera.faceAngle.y = m.faceAngle.y
                m.area.camera.yaw = m.faceAngle.y
            end
        end
        o.oInteractStatus = 0
        o.oIntangibleTimer = 2 -- fix double interact
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
    network_init_object(o, true, {
        'oBehParams',
    })
end

--- @param o Object
function shine_marker_loop(o)
    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x100
    o.oFaceAnglePitch = 0x4000

    if gGlobalSyncTable.gameState ~= 1 and gGlobalSyncTable.gameState ~= 2 then return end

    -- anti-camp
    --[[local m = gMarioStates[0]
    local dist = dist_between_objects(o, m.marioObj)
    if dist < 400 and get_player_owned_shine(0) == 0 then
        if o.oTimer > 150 then
            djui_popup_create("No camping the spawn point!", 1)

            local burningAction = ACT_BURNING_JUMP
            queue_rumble_data_mario(m, 5, 80)
            m.marioObj.oMarioBurnTimer = 0
            update_mario_sound_and_camera(m);
            play_character_sound(m, CHAR_SOUND_ON_FIRE)

            if ((m.action & ACT_FLAG_AIR ~= 0) and m.vel.y <= 0) then
                burningAction = ACT_BURNING_FALL
            end

            drop_and_set_mario_action(m, burningAction, 1)
            o.oTimer = 0
        end
    else
        o.oTimer = 0
    end]]

    local id = (o.parentObj and get_id_from_behavior(o.parentObj.behavior)) or 0
    local sync = (o.oTimer < 5)
    if id ~= id_bhvShine and id ~= id_bhvMoon then
        -- re-find shine
        o.parentObj = nil
        if gGlobalSyncTable.gameMode == 0 then
            local shine = obj_get_first_with_behavior_id_and_field_s32(id_bhvShine, 0x40, o.oBehParams) -- 0x40 is "oBehParams"
            if not shine then return end
            o.parentObj = shine
        else
            local shine = obj_get_first_with_behavior_id_and_field_s32(id_bhvMoon, 0x04, o.oBehParams) -- 0x04 is "oSyncID"
            if not shine then
                o.oBehParams = 0
                if network_is_server() then
                    network_send_object(o, true)
                end
                return
            else
                o.oBehParams = shine.oSyncID
                sync = true
                o.parentObj = shine
            end
        end
    end
    if o.parentObj.oObjectOwner ~= 0 then
        local prevPos = { o.oPosX, o.oPosY, o.oPosZ }
        o.oPosX = o.parentObj.oHomeX
        o.oPosY = o.parentObj.oHomeY - 120
        o.oPosZ = o.parentObj.oHomeZ
        if network_is_server() and (sync or prevPos[1] ~= o.oPosX or prevPos[2] ~= o.oPosY or prevPos[3] ~= o.oPosZ) then
            network_send_object(o, true)
        end
    end
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
    hitbox.radius = 40
    hitbox.height = 40
    hitbox.hurtboxRadius = 200
    hitbox.hurtboxHeight = 200
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
        local hitObject = do_item_collision(o)
        if o.oAnimState == -1 or (o.oInteractStatus & (INT_STATUS_ATTACKED_MARIO | INT_STATUS_TOUCHED_BOB_OMB)) ~= 0 or hitObject ~= 0 or ((collisionFlags & OBJ_COL_FLAG_GROUNDED) ~= 0) or o.oTimer > 300 then
            cur_obj_change_action(1)
            obj_set_model_extended(o, E_MODEL_EXPLOSION)
            obj_set_billboard(o)
            bhv_explosion_init()
            
            o.oAnimState = -1
            if (o.oInteractStatus & INT_STATUS_ATTACKED_MARIO) ~= 0 then
                network_send_object(o, true)
            end
        end
    else
        bhv_explosion_loop()
        do_item_collision(o)
        o.oInteractStatus = 0
        o.oAnimState = o.oAnimState + 1
    end
end

id_bhvThrownBobomb = hook_behavior(nil, OBJ_LIST_DESTRUCTIVE, true, thrown_bomb_init, thrown_bomb_loop, "bhvThrownBobomb")

-- item boxes!
function item_box_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oOpacity = 200
    local hitbox = get_temp_object_hitbox()
    hitbox.interactType = INTERACT_WATER_RING -- Has no hard-coded behavior
    hitbox.radius = 80
    hitbox.height = 150
    hitbox.downOffset = 70
    obj_set_hitbox(o, hitbox)
    o.oFaceAngleYaw = math.random(0, 0xFFFF)
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.globalPlayerIndex = network_global_index_from_local(0)

    network_init_object(o, false, {
        'oTimer',
        'oAction',
        'oBalloonAppearance',
    })
end

function item_box_loop(o)
    local m = nearest_living_mario_state_to_object(o)

    local respawnTime = 120
    local baseScale = 1
    if gGlobalSyncTable.arenaStyleItems then
        respawnTime = 300
        if m and o.oBalloonAppearance == 0 and network_is_server() then
            o.oBalloonAppearance = random_item(m.playerIndex, true) or 0
            if o.oSyncID ~= 0 then
                network_send_object(o, true)
            end
        end
    else
        obj_set_model_extended(o, E_MODEL_ITEM_BOX)
        o.oBalloonAppearance = 0
        o.header.gfx.node.flags = o.header.gfx.node.flags & ~GRAPH_RENDER_BILLBOARD
    end

    if o.oBalloonAppearance ~= 0 then
        local data = item_data[o.oBalloonAppearance]
        if not data then
            o.oBalloonAppearance = 0
            obj_set_model_extended(o, E_MODEL_ITEM_BOX)
            o.header.gfx.node.flags = o.header.gfx.node.flags & ~GRAPH_RENDER_BILLBOARD
        else
            obj_set_model_extended(o, (data.arenaModel or data.model))
            if not data.arenaModel then
                if data.bill then
                    obj_set_billboard(o)
                else
                    o.header.gfx.node.flags = o.header.gfx.node.flags & ~GRAPH_RENDER_BILLBOARD
                end
                if data.scale then
                    baseScale = data.scale
                end
                if data.hand then
                    baseScale = baseScale * 2
                end
                if data.animation then
                    o.oAnimations = data.animation
                    cur_obj_init_animation(0)
                else
                    o.oAnimations = nil
                end
            end
        end
    end

    if o.oAction == 0 then
        cur_obj_enable_rendering_and_become_tangible(o)
        cur_obj_scale(baseScale)
    elseif o.oAction == 1 then
        if o.oTimer == 1 then
            spawn_triangle_break_particles(4, 0x8B, 0.25, 0) -- MODEL_CARTOON_STAR
        end
        cur_obj_become_intangible()
        if o.oTimer < 5 then
            cur_obj_scale_over_time(7, 5, baseScale, 0)
        elseif o.oTimer < respawnTime then
            cur_obj_disable_rendering()
        elseif m and gGlobalSyncTable.arenaStyleItems then
            if m.playerIndex == 0 then
                o.oBalloonAppearance = random_item(0, true) or 0
                cur_obj_enable_rendering()
                cur_obj_change_action(2)
                if o.oSyncID ~= 0 then
                    network_send_object(o, true)
                end
            end
        else
            cur_obj_enable_rendering()
            cur_obj_change_action(2)
            o.oBalloonAppearance = 0
        end
    elseif o.oTimer < 5 then
        cur_obj_scale_over_time(7, 5, 0, baseScale)
    else
        cur_obj_change_action(0)
        cur_obj_scale(baseScale)
    end
    o.oFaceAngleYaw = o.oFaceAngleYaw + 100

    if not m then return end
    local sMario = gPlayerSyncTable[m.playerIndex]
    if o.oAction == 0 and o.oInteractStatus ~= 0 and m.playerIndex == 0 and shuffleItem == 0 and sMario.item == 0 and not is_dead(0) then
        cur_obj_change_action(1)
        o.oTimer = 0
        if o.oBalloonAppearance == 0 then
            shuffleItem = random_item(0)
        else
            sMario.item = o.oBalloonAppearance
            sMario.itemUses = 0
        end
        cur_obj_play_sound_1(SOUND_GENERAL_COLLECT_1UP)
        if o.oSyncID ~= 0 then
            network_send_object(o, true)
        end
    end
    o.oInteractStatus = 0
end

id_bhvItemBox = hook_behavior(nil, OBJ_LIST_LEVEL, true, item_box_init, item_box_loop, "bhvItemBox")

-- balloons
function balloon_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oOpacity = 100
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oFaceAngleYaw = 0
    cur_obj_scale(0.75)

    network_init_object(o, false, {
        'oPosX',
        'oPosY',
        'oPosZ',
        --'oForwardVel',
        --'oVelY',
        'oBalloonAppearance',
        'oObjectOwner',
        'oAction',
        'oBalloonNumber',    -- what number balloon this is
        'oBalloonNextExists' -- for checking if the upper balloon exists
    })
    --log_to_console("Spawn balloon: "..tostring(o.oObjectOwner-1)..", "..tostring(o.oSyncID)..", "..tostring(o.oBalloonNumber))
end

---@param o Object
function balloon_loop(o)
    if o.oObjectOwner == 0 then
        if o.oTimer > 30 then
            obj_mark_for_deletion(o)
        end
        return
    end

    local index = network_local_index_from_global(o.oObjectOwner - 1)
    if not (index and gNetworkPlayers[index].connected) then
        obj_mark_for_deletion(o)
        if o.parentObj then
            o.parentObj.oBalloonNextExists = 0
        end
        return
    end
    local m = gMarioStates[index]

    if gGlobalSyncTable.reduceObjects then
        cur_obj_disable_rendering()
        return
    end

    if index == 0 then
        if o.oSyncID == 0 then -- sometimes this happens for some reason, replace balloon
            spawn_sync_object(id_bhvBalloon, E_MODEL_BALLOON, o.oPosX, o.oPosY, o.oPosZ, function(other)
                other.oBalloonNumber = o.oBalloonNumber
                other.parentObj = o.parentObj
                other.oObjectOwner = o.oObjectOwner
                other.oBehParams = o.oBehParams
                other.oBalloonAppearance = o.oBalloonAppearance
                other.oBalloonNextExists = o.oBalloonNextExists
                if other.oBalloonNextExists ~= 0 then
                    local other2 = obj_get_first_with_behavior_id(id_bhvBalloon)
                    while other2 do
                        if other2.parentObj == o then
                            other2.parentObj = other
                            break
                        end
                        other2 = obj_get_next_with_same_behavior_id(other2)
                    end
                end
                obj_mark_for_deletion(o)
            end)
            return
        elseif o.activeFlags & ACTIVE_FLAG_DEACTIVATED ~= 0 then
            network_send_object(o, false)
            return
        end
    end

    if index ~= 0 and is_player_active(m) == 0 then
        --obj_mark_for_deletion(o)
        cur_obj_disable_rendering()
        return
    end

    local sMario = gPlayerSyncTable[index]
    o.globalPlayerIndex = o.oBalloonAppearance

    if o.oAction == 0 then
        cur_obj_enable_rendering()
        -- check if balloon should exist / create new balloons
        if sMario.balloons < o.oBalloonNumber then
            if o.parentObj and index == 0 then
                lastBalloonOwner = o.parentObj.oBalloonAppearance
            end
            if index == 0 and lastBalloonStolen then
                cur_obj_disable_rendering()
                cur_obj_change_action(2)
                lastBalloonStolen = false
            else
                cur_obj_change_action(1)
            end
        elseif index == 0 and sMario.balloons > o.oBalloonNumber and o.oBalloonNextExists == 0 and o.oTimer > 5 then
            spawn_sync_object(id_bhvBalloon, E_MODEL_BALLOON, o.oPosX, o.oPosY, o.oPosZ, function(other)
                play_sound(SOUND_MENU_YOSHI_GAIN_LIVES, gGlobalSoundSource)
                other.oBalloonNumber = o.oBalloonNumber + 1
                other.parentObj = o
                other.oObjectOwner = o.oObjectOwner
                other.oBehParams = o.oBehParams + 1

                if newBalloonOwner ~= -1 then
                    other.oBalloonAppearance = newBalloonOwner
                    newBalloonOwner = -1
                else
                    other.oBalloonAppearance = o.oObjectOwner - 1
                end
                lastBalloonOwner = other.oBalloonAppearance
                o.oBalloonNextExists = 1
            end)
        end

        if index == 0 then
            local distFromBalloon = 30
            local sinYaw = sins(m.faceAngle.y)
            local cosYaw = coss(m.faceAngle.y)
            local pos = { m.pos.x, m.pos.y + 170, m.pos.z }
            o.oFaceAngleYaw = m.faceAngle.y
            if o.oTimer ~= 1 then
                if o.oBalloonNumber % 2 == 0 then
                    pos[1] = pos[1] + cosYaw * distFromBalloon * o.oBalloonNumber
                    pos[2] = pos[2] - 10 * o.oBalloonNumber
                    pos[3] = pos[3] - sinYaw * distFromBalloon * o.oBalloonNumber
                    o.oFaceAngleRoll = -0x800 * o.oBalloonNumber
                elseif o.oBalloonNumber ~= 1 then
                    pos[1] = pos[1] - cosYaw * distFromBalloon * (o.oBalloonNumber - 1)
                    pos[2] = pos[2] - 10 * (o.oBalloonNumber - 1)
                    pos[3] = pos[3] + sinYaw * distFromBalloon * (o.oBalloonNumber - 1)
                    o.oFaceAngleRoll = 0x800 * (o.oBalloonNumber - 1)
                else
                    o.oFaceAngleRoll = 0
                end

                local dist = dist_between_object_and_point(o, pos[1], o.oPosY, pos[3])

                if dist > 30 then
                    o.oMoveAngleYaw = obj_angle_to_point(o, pos[1], pos[3])
                    o.oForwardVel = dist // 3 + 1
                else
                    o.oForwardVel = 0
                end
                o.oVelY = math.ceil((pos[2] - o.oPosY) / 3)
                obj_move_xyz_using_fvel_and_yaw(o)
            else
                o.oFaceAngleRoll = 0
                o.oPosX, o.oPosY, o.oPosZ = pos[1], pos[2], pos[3]
            end
        else
            o.oFaceAngleYaw = m.faceAngle.y
            if o.oBalloonNumber % 2 == 0 then
                o.oFaceAngleRoll = -0x800 * o.oBalloonNumber
            elseif o.oBalloonNumber ~= 1 then
                o.oFaceAngleRoll = 0x800 * (o.oBalloonNumber - 1)
            else
                o.oFaceAngleRoll = 0
            end
        end
    elseif o.oAction == 1 then
        o.oFaceAngleRoll = 0
        obj_set_vel(o, 0, 15, 0)
        o.oForwardVel = 0
        obj_move_xyz_using_fvel_and_yaw(o)
        if o.oTimer >= 30 then
            cur_obj_play_sound_1(SOUND_ACTION_BOUNCE_OFF_OBJECT)
            spawn_triangle_break_particles(5, 0x8B, 0.25, 1) -- MODEL_CARTOON_STAR
            cur_obj_change_action(2)
        end
    else
        cur_obj_disable_rendering()
    end

    if o.oAction ~= 0 and sMario.balloons >= o.oBalloonNumber then
        if index == 0 then
            play_sound(SOUND_MENU_YOSHI_GAIN_LIVES, gGlobalSoundSource)
            if newBalloonOwner ~= -1 then
                o.oBalloonAppearance = newBalloonOwner
                newBalloonOwner = -1
            else
                o.oBalloonAppearance = o.oObjectOwner - 1
            end
            lastBalloonOwner = o.oBalloonAppearance
        end
        cur_obj_change_action(0)
    end

    if index == 0 and o.oSyncID ~= 0 then
        network_send_object(o, false) -- trying this as unreliable, since they're visual only
    end
end

id_bhvBalloon = hook_behavior(nil, OBJ_LIST_DEFAULT, true, balloon_init, balloon_loop, "bhvBalloon")

-- renegade roundup cage
---@param o Object
function rr_cage_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oFaceAngleYaw = 0

    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oGravity = 2
    o.oBounciness = 0
    o.oBuoyancy = 1.4
    o.oFriction = 0

    -- host only, like the shine
    network_init_object(o, false, {
        'oPosX',
        'oPosY',
        'oPosZ',
        'oHomeX',
        'oHomeY',
        'oHomeZ',
        'oVelY',
        'oAction',
        'oAnimState',
        'oBehParams',
    })
end

---@param o Object
function rr_cage_loop(o)
    if network_is_server() then
        local visible = false
        local trapped = 0
        for i = 0, MAX_PLAYERS - 1 do
            local m = gMarioStates[i]
            if is_player_active(m) ~= 0 then
                local sMario = gPlayerSyncTable[i]
                if sMario.eliminated == o.oBehParams then
                    visible = true
                    trapped = trapped + 1
                    if o.oAction == 0 then break end
                elseif o.oAction ~= 0 and gGlobalSyncTable.gameState ~= 3 and sMario.team ~= 2 and not is_dead(i) then
                    local dist = dist_between_objects(o, m.marioObj)
                    if dist <= 275 or o.oObjectOwner == m.playerIndex + 1 then
                        trapped = 0
                        for a = 0, MAX_PLAYERS - 1 do
                            local sMario = gPlayerSyncTable[a]
                            if sMario.eliminated == o.oBehParams then
                                trapped = trapped + 1
                                sMario.eliminated = 0
                            end
                        end
                        if trapped ~= 0 then
                            visible = false
                            network_send_include_self(true, {
                                id = PACKET_CAPTURE,
                                free = o.oBehParams,
                                victim = network_global_index_from_local(i),
                                points = trapped,
                            })
                        end
                        break
                    end
                end
            end
        end
        o.oAnimState = trapped
        o.oObjectOwner = 0

        if (not visible) and o.oAction ~= 0 then
            o.oPosX, o.oPosY, o.oPosZ = o.oHomeX, o.oHomeY, o.oHomeZ
            cur_obj_change_action(0)
            if network_is_server() and o.oSyncID ~= 0 then
                network_send_object(o, true)
            end
        elseif visible and o.oAction == 0 and o.oTimer > 30 then
            o.oPosX, o.oPosY, o.oPosZ = o.oHomeX, o.oHomeY, o.oHomeZ
            cur_obj_change_action(2)
        end
    end

    if o.oAction == 0 then
        cur_obj_disable_rendering()
        return
    end
    cur_obj_enable_rendering()

    if o.oAction == 4 then
        o.oPosX, o.oPosY, o.oPosZ = o.oHomeX, o.oHomeY, o.oHomeZ
        o.header.gfx.pos.x, o.header.gfx.pos.y, o.header.gfx.pos.z = o.oHomeX, o.oHomeY, o.oHomeZ
    else
        if o.oAction == 1 then
            o.oVelY = 30
            cur_obj_play_sound_1(SOUND_OBJ_MR_BLIZZARD_ALERT)
            cur_obj_change_action(2)
        end
        local collisionFlags = object_step()
        cur_obj_update_floor()
        if (is_hazard_floor(o.oFloorType) and o.oPosY < o.oHomeY) then
            cur_obj_change_action(4)
        elseif collisionFlags & OBJ_COL_FLAG_GROUNDED ~= 0 then
            o.oVelY = 0
            if o.oAction ~= 3 then
                cur_obj_change_action(3)
            end
        end
    end

    if network_is_server() and o.oSyncID ~= 0 then
        network_send_object(o, true)
    end
end

id_bhvRRCage = hook_behavior(nil, OBJ_LIST_LEVEL, true, rr_cage_init, rr_cage_loop, "bhvRRCage")

-- held items by players
function held_item_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oFaceAnglePitch = 0
    o.oFaceAngleYaw = 0
    o.oOpacity = 255
    cur_obj_disable_rendering()
end

function held_item_loop(o)
    local sMario = gPlayerSyncTable[o.hookRender - 1]
    local m = gMarioStates[o.hookRender - 1]

    if m.playerIndex == 0 and m.action == ACT_DEBUG_FREE_MOVE and DEBUG_MODEL then
        handle_debug_appear(m, o)
        return
    elseif (sMario.isBomb and (not sMario.spectator) and gGlobalSyncTable.gameState == 2) then
        if o.unused1 ~= 0 or (m.invincTimer > 2 and m.marioObj.oTimer & 1 ~= 0) then
            cur_obj_disable_rendering()
        else
            cur_obj_enable_rendering()
            o.header.gfx.node.flags = o.header.gfx.node.flags & ~GRAPH_RENDER_BILLBOARD
            o.oAnimations = gObjectAnimations.bobomb_seg8_anims_0802396C
            cur_obj_init_animation_with_accel_and_sound(0, math.max(0, m.forwardVel) * 0.1)
        end
        return
    elseif (sMario.bulletTimer and sMario.bulletTimer ~= 0) and (m.action & ACT_FLAG_SWIMMING == 0 and m.action & ACT_FLAG_SWIMMING_OR_FLYING ~= 0) then
        if o.unused1 ~= 0 then
            cur_obj_disable_rendering()
        else
            cur_obj_enable_rendering()
            o.header.gfx.node.flags = o.header.gfx.node.flags & ~GRAPH_RENDER_BILLBOARD
        end
        return
    end

    -- dont render off-screen
    if m.playerIndex ~= 0 and (is_player_active(m) == 0 or (m.marioBodyState.updateTorsoTime ~= torsoTime)) then
        cur_obj_disable_rendering()
        return
    end

    if sMario.item == nil or sMario.item == 0 then
        cur_obj_disable_rendering()
        return
    end
    local data = item_data[sMario.item]
    local model = data.model or E_MODEL_GOOMBA
    obj_set_model_extended(o, model)

    if data.updateAnimState then
        o.oAnimState = o.oAnimState + 1
    end
    if data.animation then
        o.oAnimations = data.animation
        cur_obj_init_animation(0)
    else
        o.oAnimations = nil
    end

    if data.hand then
        o.oFaceAngleYaw = 0
        if o.unused1 ~= 0 then
            cur_obj_disable_rendering()
        else
            cur_obj_enable_rendering()
            cur_obj_scale(data.scale or 1)
            if data.bill then
                obj_set_billboard(o)
            else
                o.header.gfx.node.flags = o.header.gfx.node.flags & ~GRAPH_RENDER_BILLBOARD
            end
        end
    else                                                  -- spin around player
        cur_obj_enable_rendering()
        local dir = o.oTimer * 1024 + (o.unused1 * 21845) -- add 1/3 distance for animstate
        if o.oTimer >= 64 then
            o.oTimer = 0
        end
        local dist = 120

        -- spawn extra items for triples/doubles
        local count = data.count or 1
        if gGlobalSyncTable.reduceObjects then
            count = 1
        end

        if o.unused1 < count - 1 and (o.parentObj == o or o.parentObj == nil) then
            local newObj = spawn_non_sync_object(id_bhvHeldItem, E_MODEL_NONE, o.oPosX, o.oPosY, o.oPosZ, nil)
            o.parentObj = newObj
            newObj.unused1 = o.unused1 + 1
            newObj.hookRender = o.hookRender
            newObj.oTimer = o.oTimer
        elseif o.unused1 > count - 1 then
            cur_obj_disable_rendering()
            return
        end

        o.oPosX = m.pos.x + sins(dir) * dist
        o.oPosY = m.pos.y + 40 + (data.yOffset or 0)
        o.oPosZ = m.pos.z + coss(dir) * dist
        o.oFaceAnglePitch = 0
        o.oFaceAngleRoll = 0

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
    -- jank way of deleting generated stars and coins
    if o.hookRender == 0x60 then
        local np = gNetworkPlayers[0]
        if o.oInteractType & INTERACT_STAR_OR_KEY ~= 0 or obj_has_behavior_id(o, id_bhvStarSpawnCoordinates) ~= 0 then
            if (np.currAreaSyncValid and np.currLevelSyncValid) then
                obj_mark_for_deletion(o)
            end
        elseif obj_is_coin(o) then
            if gGlobalSyncTable.gameMode ~= 3 then
                if (np.currAreaSyncValid and np.currLevelSyncValid) then
                    obj_mark_for_deletion(o)
                end
            else
                coinsExist = coinsExist + o.oDamageOrCoinValue
            end
        end
        o.hookRender = 0
        return
    end

    if get_id_from_behavior(o.behavior) ~= id_bhvHeldItem or o.unused1 ~= 0 then return end
    local sMario = gPlayerSyncTable[o.hookRender - 1]
    ---@type MarioState
    local m = gMarioStates[o.hookRender - 1]
    local graphicsObj = m.marioObj.header.gfx

    if m.playerIndex == 0 and m.action == ACT_DEBUG_FREE_MOVE and DEBUG_MODEL then
        handle_debug_appear(m, o)
        return
    elseif sMario.isBomb and (not sMario.spectator) and gGlobalSyncTable.gameState == 2 then
        obj_scale_xyz(o, graphicsObj.scale.x, graphicsObj.scale.y, graphicsObj.scale.z)
        obj_set_model_extended(o, E_MODEL_COLOR_BOMB)
        o.oPosX = m.pos.x
        o.oPosY = m.pos.y
        if m.action & ACT_FLAG_RIDING_SHELL ~= 0 then
            o.oPosY = o.oPosY + 40
        end
        o.oPosZ = m.pos.z

        o.oFaceAnglePitch = graphicsObj.angle.x + (m.action ~= ACT_WALKING and 0 or m.marioBodyState.torsoAngle.x * 0.5)
        o.oFaceAngleYaw = graphicsObj.angle.y
        if m.action == ACT_SIDE_FLIP or m.action == ACT_SIDE_FLIP_LAND or m.action == ACT_TURNING_AROUND or m.action == ACT_FINISH_TURNING_AROUND then
            o.oFaceAngleYaw = o.oFaceAngleYaw + 0x8000
        elseif m.action == ACT_TOP_OF_POLE or m.action == ACT_TOP_OF_POLE_TRANSITION then
            o.oPosY = o.oPosY - 80
        elseif m.action & ACT_FLAG_ON_POLE ~= 0 then
            o.oPosX = o.oPosX - sins(o.oFaceAngleYaw) * 50
            o.oPosZ = o.oPosZ - coss(o.oFaceAngleYaw) * 50
        end
        o.oFaceAngleRoll = graphicsObj.angle.z

        o.header.gfx.pos.x = o.oPosX
        o.header.gfx.pos.y = o.oPosY
        o.header.gfx.pos.z = o.oPosZ
        o.header.gfx.angle.x = o.oFaceAnglePitch
        o.header.gfx.angle.y = o.oFaceAngleYaw
        o.header.gfx.angle.z = o.oFaceAngleRoll
        return
    elseif sMario.bulletTimer and sMario.bulletTimer ~= 0 then
        obj_scale(o, 0.25)
        obj_set_model_extended(o, E_MODEL_BULLET_BILL)
        o.oPosX = m.pos.x
        o.oPosY = m.pos.y + 40
        o.oPosZ = m.pos.z
        o.oFaceAnglePitch = -m.faceAngle.x
        o.oFaceAngleYaw = m.faceAngle.y
        o.oFaceAngleRoll = m.faceAngle.z
        o.header.gfx.pos.x = o.oPosX
        o.header.gfx.pos.y = o.oPosY
        o.header.gfx.pos.z = o.oPosZ
        o.header.gfx.angle.x = o.oFaceAnglePitch
        o.header.gfx.angle.y = o.oFaceAngleYaw
        o.header.gfx.angle.z = o.oFaceAngleRoll
        return
    end

    -- dont render off-screens
    if m.playerIndex ~= 0 and (is_player_active(m) == 0 or (m.marioBodyState.updateTorsoTime < torsoTime)) then
        return
    end

    if sMario.item == nil or sMario.item == 0 then
        return
    end

    local data = item_data[sMario.item]
    if data.hand then
        o.oPosX = get_hand_foot_pos_x(m, 0)
        o.oPosY = get_hand_foot_pos_y(m, 0) + (data.yOffset or 0)
        o.oPosZ = get_hand_foot_pos_z(m, 0)
        if m.marioBodyState.handState ~= MARIO_HAND_FISTS or m.marioBodyState.action & ACT_FLAG_SWIMMING_OR_FLYING ~= 0 then
            o.oPosX = m.marioBodyState.headPos.x
            o.oPosY = m.marioBodyState.headPos.y + 70 + (data.yOffset or 0)
            o.oPosZ = m.marioBodyState.headPos.z
        end
        o.oFaceAnglePitch = (data.pitchOffset or 0)
        o.oFaceAngleYaw = graphicsObj.angle.y + (data.yawOffset or 0)
        o.oFaceAngleRoll = (data.rollOffset or 0)
        if data.forwardOffset then
            o.oPosX = o.oPosX + sins(o.oFaceAngleYaw) * data.forwardOffset
            o.oPosZ = o.oPosZ + coss(o.oFaceAngleYaw) * data.forwardOffset
        end
        if data.sideOffset then
            o.oPosX = o.oPosX - coss(-o.oFaceAngleYaw) * data.sideOffset
            o.oPosZ = o.oPosZ - sins(-o.oFaceAngleYaw) * data.sideOffset
        end
        o.header.gfx.pos.x = o.oPosX
        o.header.gfx.pos.y = o.oPosY
        o.header.gfx.pos.z = o.oPosZ
        o.header.gfx.angle.x = o.oFaceAnglePitch
        o.header.gfx.angle.y = o.oFaceAngleYaw
        o.header.gfx.angle.z = o.oFaceAngleRoll
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
    o.oFriction = 0.1
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
    local sp1C = spawn_non_sync_object(id_bhvMistParticleSpawner, E_MODEL_NONE, o.oPosX, o.oPosY, o.oPosZ, nil)
    if not sp1C then return end
    sp1C.oPosY = sp1C.oPosY + a
end

id_bhvSTShell = hook_behavior(nil, OBJ_LIST_LEVEL, true, custom_shell_init, custom_shell_loop, "bhvSTShell")

function custom_coin_init(o, damageOrCoinValue)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE

    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oGravity = -3
    o.oFriction = 0.9
    o.oBuoyancy = -1.5
    o.oBounciness = -0.7
    o.oDragStrength = 0
    o.oWallHitboxRadius = 50
    o.oCoinUnk1B0 = 0
    o.oSubAction = 0
    o.oInteractStatus = 0

    local hitbox = get_temp_object_hitbox()
    hitbox.interactType = INTERACT_COIN
    hitbox.downOffset = 0
    hitbox.damageOrCoinValue = damageOrCoinValue or 1
    hitbox.health = 0
    hitbox.numLootCoins = 0
    hitbox.radius = 100
    hitbox.height = 64
    hitbox.hurtboxRadius = 0
    hitbox.hurtboxHeight = 0
    obj_set_hitbox(o, hitbox)
    cur_obj_become_intangible()

    network_init_object(o, true, {})
end

function custom_blue_coin_init(o)
    custom_coin_init(o, 5)
end

function custom_coin_loop(o)
    -- so that both 3d coins and 2d coins work
    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x200
    o.oAnimState = o.oAnimState + 1
    obj_set_billboard(o)

    if (o.oTimer == 1) then
        cur_obj_play_sound_2(SOUND_GENERAL_COIN_SPURT_2)
    end
    if o.oVelY <= 0 then
        cur_obj_become_tangible()
    end

    local sp1C = o.oFloor

    if sp1C then
        if (o.oMoveFlags & OBJ_MOVE_ON_GROUND ~= 0) then
            o.oSubAction = 1;
            if (sp1C.normal.y >= 0.9) then
                o.oForwardVel = o.oForwardVel * o.oFriction
            end
        end
        if (o.oSubAction == 1) then
            if o.oVelY > 0 then
                o.oBounciness = 0
            else
                o.oBounciness = 1
            end

            if (sp1C.normal.y < 0.9) then
                local sp1A = atan2s(sp1C.normal.z, sp1C.normal.x);
                cur_obj_rotate_yaw_toward(sp1A, 0x400);
            end
        end
    end

    local prevY = o.oPosY
    cur_obj_update_floor_and_walls();
    cur_obj_if_hit_wall_bounce_away();
    cur_obj_move_standard(62);
    sp1C = o.oFloor

    -- prevent ceiling clip
    if ((o.oFloorHeight > prevY + 2 or (thisLevel and thisLevel.maxHeight and o.oPosY > thisLevel.maxHeight))) and o.oVelY > 2 then
        o.oPosY = prevY
        o.oVelY = 0
    end

    if (not sp1C) or o.oMoveFlags & (OBJ_MOVE_LANDED | OBJ_MOVE_ON_GROUND) ~= 0 then
        cur_obj_become_tangible()
        if is_hazard_floor(o.oFloorType) then
            random_valid_pos(nil, o)
            o.oForwardVel = 0
            o.oVelY = -20
        end
    end
    if (o.oMoveFlags & OBJ_MOVE_BOUNCE ~= 0) then
        cur_obj_play_sound_2(SOUND_GENERAL_COIN_DROP)
        cur_obj_become_tangible()
        if (not sp1C) or (sp1C.normal.y >= 0.9) then
            o.oForwardVel = o.oForwardVel * o.oFriction
        elseif o.oForwardVel == 0 then
            o.oForwardVel = 5 // sp1C.normal.y
            local sp1A = atan2s(sp1C.normal.z, sp1C.normal.x)
            o.oMoveAngleYaw = sp1A
        end
    end

    if (o.oInteractStatus & INT_STATUS_INTERACTED ~= 0 and o.oInteractStatus & INT_STATUS_TOUCHED_BOB_OMB == 0) then
        spawn_non_sync_object(id_bhvGoldenCoinSparkles, E_MODEL_SPARKLES, o.oPosX, o.oPosY, o.oPosZ, nil)
        obj_mark_for_deletion(o)
    end
    if o.oIntangibleTimer ~= -1 and o.oTimer < 15 then
        o.oIntangibleTimer = 15 - o.oTimer
    end
    o.oInteractStatus = 0
end

id_bhvSTYellowCoin = hook_behavior(nil, OBJ_LIST_LEVEL, true, custom_coin_init, custom_coin_loop, "bhvSTYellowCoin")
id_bhvSTBlueCoin = hook_behavior(nil, OBJ_LIST_LEVEL, true, custom_blue_coin_init, custom_coin_loop, "bhvSTBlueCoin")

-- fix bowser
function fix_bowser()
    local level = gNetworkPlayers[0].currLevelNum
    if level ~= LEVEL_BOWSER_1 and level ~= LEVEL_BOWSER_2 and level ~= LEVEL_BOWSER_3 then return end
    local o = obj_get_first_with_behavior_id(id_bhvBowser)
    if not o then return end

    if gGlobalSyncTable.gameState == 1 then
        o.oAction = 5
        o.oForwardVel = 0
    elseif o.oAction == 5 then
        o.oAction = 14
    elseif o.oAction == 2 and o.oSubAction == 1 and o.oTimer > 60 then -- fix softlock?
        o.oMoveAngleYaw = o.oBowserAngleToCentre
        o.oVelY = 150
        o.oBowserUnk1AC = 0xFF
        o.oBowserUnkF8 = 0
        o.oSubAction = 2
    end
end

hook_event(HOOK_UPDATE, fix_bowser)

-- make star pieces fall over time
function custom_falling_platform_loop(o)
    local time = (180 * gGlobalSyncTable.maxGameTime)
    if o.oAction ~= 2 and o.oTimer > (o.oBehParams2ndByte) * time + 300 then
        cur_obj_change_action(2)
    end
end

hook_behavior(id_bhvFallingBowserPlatform, OBJ_LIST_SURFACE, false, nil, custom_falling_platform_loop,
    "bhvFallingBowserPlatform")

-- delete objects
function set_spawn_potential(o)
    if prevent_obj_dupe(o) then return end
    table.insert(spawn_potential, { o.oPosX, o.oPosY + 160, o.oPosZ })
    obj_mark_for_deletion(o)
end

function set_spawn_potential_priority(o)
    if prevent_obj_dupe(o) then return end
    table.insert(spawn_potential, 1, { o.oPosX, o.oPosY + 160, o.oPosZ })
    obj_mark_for_deletion(o)
end

local id_delete = {
    [id_bhvStar] = 2,
    [id_bhvBowserBomb] = 1,
    [id_bhvCannonBarrel] = 1,
    -- [id_bhvBlueCoinSwitch] = 1,
    [id_bhvMessagePanel] = 1,
    [id_bhvBobombBuddy] = 2,
    [id_bhvBobombBuddyOpensCannon] = 2,
    [id_bhvChuckya] = 1,
    [id_bhvWaterLevelDiamond] = 1,
    [id_bhvWarpPipe] = 2,
    [id_bhvTweester] = 1,
    [id_bhvExclamationBox] = 0,
    [id_bhvRedCoinStarMarker] = 1,
    [id_bhvTreasureChestBottom] = 0,
    [id_bhvTreasureChestTop] = 1,
    [id_bhvDoor] = 1,
    [id_bhvStarDoor] = 1,
    [id_bhvHmcElevatorPlatform] = 1,
    [id_bhvPyramidElevator] = 1,
    [id_bhvTuxiesMother] = 1,
    [id_bhvPenguinBaby] = 1,
    [id_bhvRacingPenguin] = 1,
    [id_bhvSmallPenguin] = 1,
    [id_bhvWhompKingBoss] = 1,
    [id_bhvWigglerHead] = 1,
    [id_bhvWigglerBody] = 1,
    [id_bhvCapSwitch] = 2,
    [id_bhv1Up] = 0,
    [id_bhv1upSliding] = 0,
    [id_bhvRecoveryHeart] = 0,
    [id_bhvRedCoin] = 0,
    [id_bhvHiddenStarTrigger] = 0,
    [id_bhvBreakableBox] = 1,
    [id_bhvBreakableBoxSmall] = 0,
    [id_bhvKoopaShell] = 1,
}
for id, v in pairs(id_delete) do
    if v == 1 then
        hook_behavior(id, OBJ_LIST_DEFAULT, true, obj_mark_for_deletion, nil)
    elseif v == 2 then
        hook_behavior(id, OBJ_LIST_DEFAULT, true, set_spawn_potential_priority, nil)
    else
        hook_behavior(id, OBJ_LIST_DEFAULT, true, set_spawn_potential, nil)
    end
end

-- is this stupid? maybe
---@param o Object
function set_hook_render_temp(o)
    if get_object_list_from_behavior(o.behavior) == OBJ_LIST_LEVEL then
        o.hookRender = 0x60
    end
end

hook_event(HOOK_ON_OBJECT_LOAD, set_hook_render_temp)

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

-- deletes duplicate objects on load, used mainly for arena support
function prevent_obj_dupe(o)
    if already_spawn_pointer[o] then
        obj_mark_for_deletion(o)
        return true
    end
    already_spawn_pointer[o] = 1
end

-- reset already used ids + delete coins if not coin rush
function reset_spawned()
    already_spawn_pointer = {}

    ---@type Object
    local o = obj_get_first(OBJ_LIST_LEVEL)
    while o do
        if o.oInteractType & INTERACT_STAR_OR_KEY ~= 0 then
            obj_mark_for_deletion(o)
        elseif obj_is_coin(o) and gGlobalSyncTable.gameMode ~= 3 then
            -- rather than use obj_mark_for_deletion, we mark the coin as collected, which deletes it anyway
            -- this SOMEHOW fixes balloon desync issues???
            o.oInteractStatus = INT_STATUS_INTERACTED
        end
        o = obj_get_next(o)
    end
    if gGlobalSyncTable.gameMode ~= 3 then
        o = obj_get_first_with_behavior_id(id_bhvBlueCoinSwitch)
        if o then
            obj_mark_for_deletion(o)
            o = obj_get_next_with_same_behavior_id(o)
        end
    end
end

hook_event(HOOK_ON_SYNC_VALID, reset_spawned)

-- arena map support starts here
function replace_shine(o)
    if prevent_obj_dupe(o) then return end
    local pos = 2
    if o.oBehParams == 0 or #spawn_potential == 0 then pos = 1 end
    table.insert(spawn_potential, pos, { o.oPosX, o.oPosY, o.oPosZ })
    obj_mark_for_deletion(o)
end

id_bhvArenaFlag = hook_behavior(nil, OBJ_LIST_LEVEL, false, replace_shine, nil, "bhvArenaFlag")

function replace_spawn(o)
    if prevent_obj_dupe(o) then return end
    if arenaSpawnLocations == nil or arenaSpawnLocations[0] == nil then
        arenaSpawnLocations = {}
        arenaSpawnLocations[0] = { o.oPosX, o.oPosY, o.oPosZ }
    else
        table.insert(arenaSpawnLocations, { o.oPosX, o.oPosY, o.oPosZ })
    end
    obj_mark_for_deletion(o)
end

id_bhvArenaSpawn = hook_behavior(nil, OBJ_LIST_LEVEL, false, replace_spawn, nil, "bhvArenaSpawn")

function replace_item(o)
    if prevent_obj_dupe(o) then return end
    if not arenaItemBoxLocations then
        arenaItemBoxLocations = {}
    end
    table.insert(arenaItemBoxLocations, { o.oPosX, o.oPosY, o.oPosZ })
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
