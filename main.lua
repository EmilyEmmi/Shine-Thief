-- name: \\#ffff40\\Shine Thief (v1.1)
-- description: Shine Thief from Mario Kart: Double Dash and Mario Kart 8 Deluxe, now in sm64ex-coop!\n\nMod by EmilyEmmi\n\nShine Dynos by Blocky\n\nSome graphics/sounds created/provided by NeedleN64\n\nMcDonalds by chillyzone\nArena by Agent X\nArena stage base by angelicmiracles
-- incompatible: gamemode

gGlobalSyncTable.gameLevel = 0
gGlobalSyncTable.gameState = 0
gGlobalSyncTable.gameTimer = 0
gGlobalSyncTable.showTime = false
gGlobalSyncTable.winner = 0
gGlobalSyncTable.winner2 = 0
gGlobalSyncTable.winTime = 20 -- this changes depending on the amount of players
gGlobalSyncTable.teamMode = 0
gGlobalSyncTable.variant = 0
gGlobalSyncTable.autoGame = false
gGlobalSyncTable.spawnOffset = 0

gServerSettings.bubbleDeath = 0
gServerSettings.skipIntro = 1
gServerSettings.playerInteractions = PLAYER_INTERACTIONS_PVP
gServerSettings.stayInLevelAfterStar = 0

gLevelValues.fixCollisionBugs = true
gLevelValues.fixCollisionBugsFalseLedgeGrab = true
gLevelValues.fixCollisionBugsGroundPoundBonks = true
gLevelValues.fixCollisionBugsRoundedCorners = true
gLevelValues.fixCollisionBugsPickBestWall = true

E_MODEL_SHINE = smlua_model_util_get_id("shine_geo") or E_MODEL_STAR

MUSIC_SHINE_GET = audio_stream_load("shine.mp3")
SOUND_SHINE_GRAB = audio_sample_load("grab.mp3")

lastAttacker = 0

local shineFrameCounter = 0
local showTimeTimer = 0
sentShineMessage = false
isRomHack = false
localWinner = 0
localWinner2 = -1

-- starts a game (called in menu)
function new_game(msg)
    if not (network_is_server() or network_is_moderator()) then
        djui_chat_message_create("You lack the power, young one.")
        return true
    end

    local level = gGlobalSyncTable.gameLevel
    if msg and msg ~= "" then
        level = tonumber(msg) or msg
    end

    setup_level_data(level)
    if not (warp_to_level(thisLevel.level, thisLevel.area, 6) or warp_to_warpnode(thisLevel.level, thisLevel.area, 6, 0)) then
        djui_chat_message_create("This isn't a valid level.")
        setup_level_data(gGlobalSyncTable.gameLevel)
        return true
    end

    gGlobalSyncTable.gameLevel = level
    gGlobalSyncTable.gameTimer = 1

    local playerCount = get_participant_count()

    gGlobalSyncTable.winTime = 36 - playerCount -- more time with less players
    if gGlobalSyncTable.teamMode ~= 0 then
        gGlobalSyncTable.winTime = gGlobalSyncTable.winTime + 40 // gGlobalSyncTable.teamMode -- more time with less teams
    end
    if gGlobalSyncTable.variant == 2 then -- increase time in wing cap
        gGlobalSyncTable.winTime = gGlobalSyncTable.winTime + 20
    end

    gGlobalSyncTable.spawnOffset = math.random(0, MAX_PLAYERS-1)

    network_send_include_self(true, {
        id = PACKET_NEWGAME,
        teams = gGlobalSyncTable.teamMode,
    })
    return true
end
--hook_chat_command("newgame","TEST",new_game)

-- counts how many non-spectators there are
function get_participant_count()
    local playerCount = 0
    for i=0,(MAX_PLAYERS-1) do
        if gNetworkPlayers[i].connected and not gPlayerSyncTable[i].spectator then
            playerCount = playerCount + 1
        end
    end
    return playerCount
end

-- enter spectator mode
function spectator_mode()
    local sMario = gPlayerSyncTable[0]
    sMario.spectator = not sMario.spectator
    if sMario.spectator then
        if gGlobalSyncTable.gameState ~= 3 then  
            if sMario.hasShine ~= 0 and gGlobalSyncTable.gameState ~= 3 then
                lose_shine(0,1)
            end
            sMario.team = 0
        end
        djui_chat_message_create("Entered Spectator Mode.")
    else
        gMarioStates[0].flags = gMarioStates[0].flags & ~(MARIO_WING_CAP | MARIO_VANISH_CAP)
        if gGlobalSyncTable.gameState ~= 3 then
            go_to_mario_start(0, gNetworkPlayers[0].globalIndex, true)
            sMario.team = calculate_lowest_member_team()
        end
        djui_chat_message_create("No longer spectating.")
    end
end


-- Various movement tweaks
--- @param m MarioState
function before_phys_step(m)
    local sMario = gPlayerSyncTable[m.playerIndex]

    local speed_cap = 40

    if (m.action & ACT_FLAG_SWIMMING) ~= 0 then speed_cap = 20 end
    if _G.OmmEnabled then speed_cap = speed_cap + 10 end -- speed cap is greater for OMM
    if (m.action & ACT_FLAG_RIDING_SHELL) ~= 0 then speed_cap = speed_cap + 10 end -- other players can travel at >60 speed

    -- boost variant
    if (gGlobalSyncTable.variant == 5 or sMario.spectator) and sMario.boostTime and sMario.boostTime ~= 0 then
        if (m.action & ACT_FLAG_INTANGIBLE) == 0 then
            speed_cap = speed_cap + 15
            
            if sMario.hasShine == 0 then speed_cap = speed_cap + 15 end -- boost is worse for shine player

            local intendedDYaw = limit_angle(m.intendedYaw - m.faceAngle.y)
            local intendedMag = m.intendedMag / 32

            m.forwardVel = m.forwardVel + intendedMag * coss(intendedDYaw) * 3
            if m.forwardVel > speed_cap then
                m.forwardVel = speed_cap
            elseif m.forwardVel < -20 then
                m.forwardVel = -20
            end
        end
    end

    -- make vertical wind a bit more tolerable
    if m.action == ACT_VERTICAL_WIND then
        if sMario.hasShine ~= 0 then
            m.actionTimer = m.actionTimer + 1
            if m.actionTimer > 90 and m.vel.y > -20 then -- prevent camping
                m.vel.y = m.vel.y - 3
            end
        end

        if m.actionState == 0 and m.floor.type == SURFACE_VERTICAL_WIND and m.vel.y < 20 then
            m.vel.y = 20 -- initial vertical boost
        end
    end

    if m.action == ACT_FLYING then
        speed_cap = 60
        if sMario.boostTime ~= 0 then speed_cap = speed_cap + 20 end
        
        if sMario.hasShine ~= 0 then
            speed_cap = speed_cap - 30
            m.forwardVel = approach_f32(m.forwardVel, speed_cap, 4, 4)
        else
            m.forwardVel = speed_cap
        end
    elseif m.action == ACT_WATER_SHELL_SWIMMING then
        m.forwardVel = 40 -- usually 28
        if sMario.hasShine ~= 0 then m.forwardVel = 30 end
        if (m.input & INPUT_Z_PRESSED) ~= 0 then
            m.actionTimer = 240 -- drop water shell
        else
            m.actionTimer = 0 -- no time limit
        end
    elseif m.action == ACT_WATER_PUNCH then -- buff water punch (like in mariohunt)
        if m.prevAction == ACT_WATER_SHELL_SWIMMING then -- stay at same speed when using water shell
            m.forwardVel = 40 -- usually 28
            if sMario.hasShine ~= 0 then m.forwardVel = 30 end
        else
            m.forwardVel = speed_cap -- as fast as player with shine can swim
        end
    elseif (sMario.hasShine ~= 0) and m.forwardVel > speed_cap then -- the player with the shine is slowed
        m.forwardVel = math.max(speed_cap, m.forwardVel - 2)
    end

    if m.prevAction == ACT_WATER_SHELL_SWIMMING and m.action ~= ACT_WATER_SHELL_SWIMMING and m.action ~= ACT_WATER_PUNCH then -- drop water shell
        mario_drop_held_object(m)
    end
end
hook_event(HOOK_BEFORE_PHYS_STEP, before_phys_step)

-- Handle all players, including shine dropping
--- @param m MarioState
function mario_update(m)
    if m.health <= 0xFF then -- happens when falling in OMM
        on_death(m)
    end
    m.health = 0x880 -- health? get that outta here
    m.peakHeight = m.pos.y -- fall damage bad
    m.cap = 0 -- don't lose cap permanently
    m.numCoins = 0 -- no 100 coin star! bad

    local sMario = gPlayerSyncTable[m.playerIndex]
    local np = gNetworkPlayers[m.playerIndex]

    -- cancel game if there aren't enough players
    if m.playerIndex == 0 and gGlobalSyncTable.variant == 1 and gGlobalSyncTable.mhState == 2 and get_participant_count() < 3 then
        gGlobalSyncTable.variant = 0
        new_game()
        djui_popup_create_global("Not enough players for Double Shine!",2)
    end
    
    -- don't take damage, but drop shine if we get hit
    if m.hurtCounter > 0 or m.action == ACT_BURNING_FALL or m.action == ACT_BURNING_GROUND or m.action == ACT_BURNING_JUMP then
        m.hurtCounter = 0
        if sMario.hasShine ~= 0 and m.playerIndex == 0 then
            lose_shine(0)
        end
    elseif m.playerIndex == 0 then
        lastAttacker = 0
    end

    -- for underground lake
    if m.playerIndex == 0 and thisLevel then
        if thisLevel.room and m.currentRoom ~= 0 and m.currentRoom ~= thisLevel.room then
            print("Room mismatch", m.currentRoom, thisLevel.room)
            on_death(m)
        elseif thisLevel.maxHeight and m.pos.y > thisLevel.maxHeight then
            print("Height limit", m.pos.y, thisLevel.maxHeight)
            on_death(m)
        end
    end
    
    -- prevent instant death upon spawning
    if m.action == ACT_SPAWN_SPIN_AIRBORNE and m.floor and is_hazard_floor(m.floor.type) then
        if gGlobalSyncTable.gameState == 1 then
            m.vel.y = 0
        else
            if (m.flags & MARIO_WING_CAP) == 0 then
                set_mario_action(m, ACT_TRIPLE_JUMP, 1)
            else
                set_mario_action(m, ACT_FLYING_TRIPLE_JUMP, 1)
            end
            m.vel.y = 80
        end
    elseif m.action == ACT_TRIPLE_JUMP and m.actionArg == 1 then
        m.faceAngle.y = approach_s16_symmetric(m.faceAngle.y, m.intendedYaw, 0x1000)
    end

    if sMario.shineTimer == nil then sMario.shineTimer = 0 end

    -- set player colors
    local color = {r = 255, g = 64, b = 64, a = 255} -- red
    if sMario.team == 0 or sMario.team == nil then
        if sMario.hasShine ~= 0 then
            color = {r = 255, g = 255, b = 64, a = 255} -- yellow
        end
        np.overridePaletteIndex = np.paletteIndex
    else
        if sMario.team == 1 then
            np.overridePaletteIndex = 15
            color = {r = 255, g = 64, b = 64, a = 255} -- red
        elseif sMario.team == 2 then
            np.overridePaletteIndex = 7
            color = {r = 64, g = 64, b = 255, a = 255} -- blue
        elseif sMario.team == 3 then
            np.overridePaletteIndex = 6
            color = {r = 75, g = 255, b = 64, a = 255} -- green
        elseif sMario.team == 4 then
            np.overridePaletteIndex = 18
            color = {r = 255, g = 255, b = 64, a = 255} -- yellow
        end
        if sMario.hasShine == 0 then color.a = 100 end
    end
    -- set player descriptions
    if sMario.spectator then
        network_player_set_description(np, "Spectator", 128, 128, 128, 255)
    else
        network_player_set_description(np, tostring(sMario.shineTimer), color.r, color.g, color.b, color.a)
    end

    -- handle holding shine
    if sMario.hasShine and sMario.hasShine ~= 0 then
        if m.invincTimer ~= 0 then m.invincTimer = m.invincTimer - 1 end

        if gGlobalSyncTable.variant ~= 1 then
            if m.playerIndex == 0 and sMario.shineTimer <= gGlobalSyncTable.winTime then
                shineFrameCounter = shineFrameCounter + 1
                if gGlobalSyncTable.showTime then
                    shineFrameCounter = shineFrameCounter + 1
                end
                if gGlobalSyncTable.gameState == 2 then
                    if shineFrameCounter >= 60 or (shineFrameCounter >= 30 and sMario.shineTimer < gGlobalSyncTable.winTime - 3) then -- it's 2 seconds per second near the end
                        sMario.shineTimer = sMario.shineTimer + 1 -- increment timer
                        shineFrameCounter = 0
                    end
                    if sMario.shineTimer > gGlobalSyncTable.winTime then -- victory
                        sMario.shineTimer = gGlobalSyncTable.winTime
                        network_send_include_self(true, {
                            id = PACKET_VICTORY,
                            winner = np.globalIndex,
                            winner2 = -1,
                        })
                        play_sound(SOUND_MENU_STAR_SOUND, m.marioObj.header.gfx.cameraToObject)
                    end
                end

                -- wait 5 frames to prevent message spam
                if sentShineMessage == false and shineFrameCounter > 4 then
                    network_send_include_self(true, {
                        id = PACKET_GRAB_SHINE,
                        grabbed = np.globalIndex,
                    })
                    sentShineMessage = true
                end
            end
        else -- double shine works a bit different
            local mySMario = gPlayerSyncTable[0]
            if m.playerIndex ~= 0 and mySMario.hasShine ~= 0 and mySMario.shineTimer <= gGlobalSyncTable.winTime then
                shineFrameCounter = shineFrameCounter + 1
                if gGlobalSyncTable.showTime then
                    shineFrameCounter = shineFrameCounter + 1
                end
                if gGlobalSyncTable.gameState == 2 then
                    if shineFrameCounter >= 60 or (shineFrameCounter >= 30 and sMario.shineTimer < gGlobalSyncTable.winTime - 3) then -- it's 2 seconds per second near the end
                        mySMario.shineTimer = mySMario.shineTimer + 1 -- increment timer
                        shineFrameCounter = 0
                    end
                    if mySMario.shineTimer > gGlobalSyncTable.winTime then -- victory
                        mySMario.shineTimer = gGlobalSyncTable.winTime
                        network_send_include_self(true, {
                            id = PACKET_VICTORY,
                            winner = gNetworkPlayers[0].globalIndex,
                            winner2 = np.globalIndex,
                        })
                        play_sound(SOUND_MENU_STAR_SOUND, m.marioObj.header.gfx.cameraToObject)
                    end
                end
            elseif m.playerIndex == 0 then
                -- wait 5 frames to prevent message spam
                if sentShineMessage == false then
                    if shineFrameCounter > 4 then
                        network_send_include_self(true, {
                            id = PACKET_GRAB_SHINE,
                            grabbed = np.globalIndex,
                        })
                        sentShineMessage = true
                        shineFrameCounter = 0
                    else
                        shineFrameCounter = shineFrameCounter + 1
                    end
                end
            end
        end

        -- fix desync issues
        --[[local shine = obj_get_first_with_behavior_id_and_field_s32(bhvShine, 0x40, sMario.hasShine)
        if shine then
            if (shine.oShineOwner ~= np.globalIndex and shine.oShineOwner ~= -1) then
                sMario.hasShine = 0
            end
        end]]

        if m.playerIndex ~= 0 then
            local mySMario = gPlayerSyncTable[0]
            -- prevent dual ownership
            if mySMario.hasShine == sMario.hasShine then
                if gMarioStates[0].forwardVel > m.forwardVel then -- the player moving faster gets priority
                    lose_shine(m.playerIndex)
                else
                    lose_shine(0)
                end
            end
            -- update team shine timer
            if mySMario.hasShine ~= 0 and sMario.hasShine ~= 0 then
                if mySMario.shineTimer < sMario.shineTimer then
                    mySMario.shineTimer = sMario.shineTimer
                    shineFrameCounter = 0
                end
            elseif mySMario.team ~= 0 and mySMario.team == sMario.team then
                if mySMario.shineTimer < sMario.shineTimer and sMario.shineTimer <= gGlobalSyncTable.winTime - 5 then
                    mySMario.shineTimer = sMario.shineTimer
                    shineFrameCounter = 0
                end
            end
        end

        -- pass shine in team mode
        if gGlobalSyncTable.teamMode ~= 0 and (m.controller.buttonDown & Y_BUTTON) ~= 0 and m.framesSinceB < 5 then
            lose_shine(m.playerIndex, 2)
        end

        set_mario_particle_flags(m, PARTICLE_SPARKLES, 0)-- sparkle if we have shine
    elseif m.playerIndex == 0 then
        shineFrameCounter = 0
        sentShineMessage = false
        if sMario.shineTimer > gGlobalSyncTable.winTime - 5 then
            sMario.shineTimer = gGlobalSyncTable.winTime - 5 -- always have '5' seconds left (actually more)
        end
    end

    -- spectator mode
    if sMario.spectator then
        m.flags = m.flags | MARIO_WING_CAP | MARIO_VANISH_CAP
        goto BOOST
    end

    -- wing cap variant
    if gGlobalSyncTable.variant == 2 then
        m.flags = m.flags | MARIO_WING_CAP
    end

    -- shell rush variant
    if gGlobalSyncTable.variant == 3 and gGlobalSyncTable.gameState ~= 3 and (m.input & INPUT_Z_PRESSED) ~= 0 and m.riddenObj == nil and m.heldObj == nil then
        local spawnShell = 0
        if (m.input & INPUT_IN_WATER) ~= 0 then
            if (m.waterLevel - m.pos.y) < 100 then
                spawnShell = 1
            else
                spawnShell = 2
            end
        elseif (m.input & INPUT_OFF_FLOOR) == 0 and m.prevAction ~= ACT_RIDING_SHELL_GROUND then
            spawnShell = 1
        end

        if spawnShell == 2 then
            if m.playerIndex == 0 then
                m.heldObj = spawn_sync_object(
                    id_bhvKoopaShellUnderwater,
                    E_MODEL_KOOPA_SHELL,
                    m.pos.x,m.pos.y,m.pos.z,
                    function(o)
                        o.oFaceAnglePitch = 0
                        o.oFaceAngleRoll = 0
                        o.oAction = 1
                        o.oHeldState = HELD_HELD
                    end
                )
            end
            set_mario_action(m, ACT_WATER_SHELL_SWIMMING, 0)
        elseif spawnShell == 1 then
            if (m.input & INPUT_OFF_FLOOR) ~= 0 then
                m.pos.y = m.waterLevel
            end
            if m.playerIndex == 0 then
                m.riddenObj = spawn_sync_object(
                    id_bhvKoopaShell,
                    E_MODEL_KOOPA_SHELL,
                    m.pos.x,m.pos.y,m.pos.z,
                    function(o)
                        o.oFaceAnglePitch = 0
                        o.oFaceAngleRoll = 0
                        o.oAction = 1
                    end
                )
            end
            set_mario_action(m, ACT_RIDING_SHELL_GROUND, 0)
        end
    end
    if m.playerIndex == 0 and m.action == ACT_RIDING_SHELL_GROUND and m.floor and m.floor.type == SURFACE_BURNING and thisLevel.badLava then
        on_death(m)
    end
    if m.playerIndex == 0 and m.riddenObj and (m.action & ACT_FLAG_RIDING_SHELL) == 0 then
        m.riddenObj.activeFlags = ACTIVE_FLAG_DEACTIVATED -- prevent hyper speed
        m.riddenObj = nil
    end

    -- moon gravity variant
    if gGlobalSyncTable.variant == 4 and (m.action & ACT_FLAG_AIR) ~= 0 and m.action ~= ACT_TWIRLING and m.action ~= ACT_SHOT_FROM_CANNON then
        if m.vel.y < -25 then
            local interaction = determine_interaction(m, m.marioObj)
            if interaction ~= INT_GROUND_POUND then
                m.vel.y = -25
            elseif m.vel.y < -40 then
                m.vel.y = -40
            end
        elseif m.vel.y ~= 0 then
            m.vel.y = m.vel.y + 1
        end
    end

    -- bombs variant
    if gGlobalSyncTable.variant == 6 and gGlobalSyncTable.gameState ~= 3 and sMario.specialCooldown == 0 and (m.controller.buttonPressed & Y_BUTTON) ~= 0 then
        if m.playerIndex == 0 then
            spawn_sync_object(
                bhvThrownBobomb,
                E_MODEL_BLACK_BOBOMB,
                m.pos.x, m.pos.y + 50, m.pos.z,
                function(o)
                    o.oForwardVel = m.forwardVel + 35
                    o.oMoveAngleYaw = m.intendedYaw
                    o.oFaceAngleYaw = o.oMoveAngleYaw
                    o.oShineOwner = np.globalIndex
                end
            )
        end
        
        -- from arena
        if (m.action & ACT_FLAG_INVULNERABLE) ~= 0 or (m.action & ACT_FLAG_INTANGIBLE) ~= 0 then
            -- nothing
        elseif (m.action == ACT_SHOT_FROM_CANNON) then
            -- nothing
        elseif (m.action & ACT_FLAG_SWIMMING) ~= 0 then
            set_mario_action(m, ACT_WATER_PUNCH, 0)
            m.faceAngle.y = m.intendedYaw
        elseif (m.action & ACT_FLAG_MOVING) ~= 0 then
            set_mario_action(m, ACT_MOVE_PUNCHING, 0)
            m.faceAngle.y = m.intendedYaw
        elseif (m.action & ACT_FLAG_AIR) ~= 0 and m.action ~= ACT_GROUND_POUND then
            local prevVel = m.vel.y
            set_mario_action(m, ACT_JUMP_KICK, 0) -- I prefer this
            m.vel.y = prevVel -- prevent stalling
            m.faceAngle.y = m.intendedYaw
        elseif (m.action & ACT_FLAG_STATIONARY) ~= 0 then
            set_mario_action(m, ACT_PUNCHING, 0)
            m.faceAngle.y = m.intendedYaw
        end
        sMario.specialCooldown = 15
    end

    ::BOOST::
    -- used for bombs and boost
    if sMario.specialCooldown and sMario.specialCooldown > 0 and m.playerIndex == 0 then
        sMario.specialCooldown = sMario.specialCooldown - 1
    end

    -- boost variant
    if (gGlobalSyncTable.variant == 5 or sMario.spectator) and sMario.boostTime then
        if sMario.boostTime ~= 0 then
            if (m.controller.buttonDown & Y_BUTTON) ~= 0 then -- boost while holding Y
                set_mario_particle_flags(m, ACTIVE_PARTICLE_FIRE, 0) -- fire when boosting
                if m.playerIndex == 0 then
                    sMario.boostTime = sMario.boostTime + 1
                    sMario.specialCooldown = sMario.boostTime * 2 -- cooldown is longer the more you use the boost
                    if sMario.boostTime >= 60 then -- maximum of 2 seconds of boost (for 4 seconds cooldown)
                        sMario.boostTime = 0
                        sMario.specialCooldown = 120
                    end
                end
            elseif m.playerIndex == 0 then
                sMario.specialCooldown = sMario.boostTime * 2 -- cooldown is longer the more you use the boost
                sMario.boostTime = 0
            end
        elseif m.playerIndex == 0 and (m.controller.buttonPressed & Y_BUTTON) ~= 0 and sMario.specialCooldown == 0 then
            sMario.boostTime = 1 -- start boost by pressing y
        end
    end

    if m.playerIndex == 0 and network_is_server() and gGlobalSyncTable.autoGame and (gGlobalSyncTable.gameState == 0 or showGameResults) then -- auto game
        if gGlobalSyncTable.gameTimer > 0 then
            gGlobalSyncTable.gameTimer = gGlobalSyncTable.gameTimer - 1
        else
            start_random_level(type(gGlobalSyncTable.gameLevel) == "number")
        end
    elseif gGlobalSyncTable.gameState ~= 0 and didFirstJoinStuff then
        local act = ((np.currCourseNum == COURSE_NONE) and 0) or 6
        if m.playerIndex == 0 and (np.currLevelNum ~= thisLevel.level or np.currAreaIndex ~= thisLevel.area or np.currActNum ~= act) then -- stay in the right level
            if not warp_to_level(thisLevel.level, thisLevel.area, act) then
                warp_to_warpnode(thisLevel.level, thisLevel.area, act, 0)
            end
        elseif gGlobalSyncTable.gameState == 1 then
            go_to_mario_start(m.playerIndex,np.globalIndex,false)
            -- time until start
            if m.playerIndex == 0 and network_is_server() then
                gGlobalSyncTable.gameTimer = gGlobalSyncTable.gameTimer + 1
                if gGlobalSyncTable.gameTimer > 300 then
                    gGlobalSyncTable.gameTimer = 0
                    gGlobalSyncTable.gameState = 2
                end
            end
        elseif gGlobalSyncTable.gameState == 2 and m.playerIndex == 0 and network_is_server() then
            if showTimeTimer < 9000 then
                showTimeTimer = showTimeTimer + 1
                if showTimeTimer == 8700 then -- 10 seconds left
                    djui_popup_create_global("10 seconds until Showtime!",1)
                end
            elseif gGlobalSyncTable.showTime == false then
                gGlobalSyncTable.showTime = true
                network_send_include_self(true, {
                    id = PACKET_SHOWTIME,
                })
            end
        end
    else
        if m.playerIndex == 0 and (np.currLevelNum ~= gLevelValues.entryLevel or np.currAreaIndex ~= 1 or np.currActNum ~= 0) then -- stay in the right level
            warp_to_level(gLevelValues.entryLevel, 1, 0)
        end
    end
end
hook_event(HOOK_MARIO_UPDATE, mario_update)

-- utility function that returns if a floor is hazardous (lava, quicksand, or death plane)
function is_hazard_floor(type)
    return (type == SURFACE_INSTANT_QUICKSAND or type == SURFACE_INSTANT_MOVING_QUICKSAND or type == SURFACE_BURNING or type == SURFACE_DEATH_PLANE or type == SURFACE_VERTICAL_WIND)
end

-- from extended moveset
function limit_angle(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

-- assigns the specified player to whichever team has the least amount of members (excludes the local player)
function calculate_lowest_member_team()
    local teamTotal = gGlobalSyncTable.teamMode

    if teamTotal == 0 then return 0 end

    local teamCounts = {}
    local possible = {}
    local minTeamCount = 99
    for i=1,teamTotal do
        table.insert(teamCounts,0)
        table.insert(possible,i)
    end
    
    for i=1,(MAX_PLAYERS-1) do
        if gNetworkPlayers[i].connected then
            local team = gPlayerSyncTable[i].team
            if team ~= 0 and not gPlayerSyncTable[i].spectator then
                teamCounts[team] = teamCounts[team] + 1
            end
        end
    end
    for team,count in pairs(teamCounts) do
        if count < minTeamCount then
            possible = {team}
            minTeamCount = count
        elseif count == minTeamCount then
            table.insert(possible,team)
        end
    end
    return possible[math.random(1,#possible)]
end

-- starts a random level, which is either from the supported list or any random level if "custom" was used
function start_random_level(list)
    if list then
        new_game_set_settings(math.random(1,#levelData))
        return
    end

    local LIMIT = 0
    local dry = (get_menu_option(4,3) == 1)
    while LIMIT < 1000 do
        local level = course_to_level[math.random(0,#course_to_level)]
        local area = math.random(1,7)
        local levelString = tostring(level).." "..tostring(area).." "..tostring(dry)
        setup_level_data(levelString)
        if (warp_to_level(thisLevel.level, thisLevel.area, 6) or warp_to_warpnode(thisLevel.level, thisLevel.area, 6, 0)) then
            new_game_set_settings(levelString)
            break
        end
        LIMIT = LIMIT + 1
    end
end

-- prevent team attack
--- @param attacker MarioState
--- @param victim MarioState
function allow_pvp_attack(attacker, victim)
    local sAttacker = gPlayerSyncTable[attacker.playerIndex]
    local sVictim = gPlayerSyncTable[victim.playerIndex]
    return (sAttacker.spectator or sVictim.spectator) or (sAttacker.team == 0 or sAttacker.team ~= sVictim.team)
end
hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp_attack)

-- steal shine directly for some attacks
--- @param attacker MarioState
--- @param victim MarioState
function on_pvp_attack(attacker, victim, cappyAttack)
    if victim.playerIndex == 0 then
        lastAttacker = attacker.playerIndex

        if attacker.action == ACT_SLIDE_KICK or attacker.action == ACT_SLIDE_KICK_SLIDE or attacker.action == ACT_SLIDE_KICK_SLIDE_STOP then
            local sVictim = gPlayerSyncTable[victim.playerIndex]
            local sAttacker = gPlayerSyncTable[attacker.playerIndex]
            if sVictim.hasShine ~= 0 and sAttacker.hasShine == 0 then
                local shine = obj_get_first_with_behavior_id_and_field_s32(bhvShine, 0x40, (sVictim.hasShine or 0))
                if shine then
                    local np = gNetworkPlayers[attacker.playerIndex]
                    gMarioStates[0].hurtCounter = 0 -- don't run standard lose function
                    shine.oShineOwner = np.globalIndex
                    print("sending direct steal to",np.globalIndex)
                        network_send_to(np.localIndex, true, {
                            id = PACKET_DIRECT_STEAL,
                            shineID = shine.oBehParams,
                            victim = gNetworkPlayers[0].globalIndex,
                    })
                    shine.oAction = 0
                    
                    sAttacker.hasShine = shine.oBehParams
                    sVictim.hasShine = 0
                end
            end
        end
    end
end
hook_event(HOOK_ON_PVP_ATTACK, on_pvp_attack)

-- omm support
function omm_allow_attack(index,setting)
    if setting == 3 and index ~= 0 then
      return allow_pvp_attack(gMarioStates[index], gMarioStates[0])
    end
    return true
end
function omm_attack(index,setting)
    if setting == 3 and index ~= 0 then
      return on_pvp_attack(gMarioStates[index], gMarioStates[0], true)
    end
end
function omm_disable_feature(feature, disable)
    return -- set when OMM is enabled
end

-- drop shine on death (runs when falling)
function on_death(m)
    local sMario = gPlayerSyncTable[m.playerIndex]
    if sMario.hasShine ~= 0 then
        lose_shine(m.playerIndex,1)
    end
    go_to_mario_start(m.playerIndex,gNetworkPlayers[m.playerIndex].globalIndex, true)
    return false
end
hook_event(HOOK_ON_DEATH, on_death)

function on_pause_exit(exitToCastle)
    if gGlobalSyncTable.gameState ~= 3 then
        go_to_mario_start(0, gNetworkPlayers[0].globalIndex, true)
        if gPlayerSyncTable[0].hasShine ~= 0 then
            sentShineMessage = true
            lose_shine(0, 1)
        end
    end
    return false
end
hook_event(HOOK_ON_PAUSE_EXIT, on_pause_exit)
--hook_event(HOOK_ON_WARP, on_pause_exit)

-- no!!!! no dialog!!!!
function on_dialog(id)
    return false
end
hook_event(HOOK_ON_DIALOG, on_dialog)

-- set our status when we enter; spawn platforms and pipes, and spawn shine if host
function on_sync_valid()
    local sMario = gPlayerSyncTable[0]
    sMario.hasShine = 0 -- if we just entered, we obviously don't have the shine
    sMario.specialCooldown = 0
    sMario.boostTime = 0
    setup_level_data(gGlobalSyncTable.gameLevel)
    if gGlobalSyncTable.gameState ~= 0 then
        go_to_mario_start(0,gNetworkPlayers[0].globalIndex,true)
    end
    if _G.OmmEnabled then
        gLevelValues.disableActs = false
        omm_disable_feature = _G.OmmApi.omm_disable_feature
        omm_disable_feature("trueNonStop", true)
        omm_disable_feature("starsDisplay", true)
        _G.OmmApi.omm_allow_cappy_mario_interaction = omm_allow_attack
        _G.OmmApi.omm_resolve_cappy_mario_interaction = omm_attack
    end

    if thisLevel.noWater then
        set_environment_region(0, -10000)
        set_environment_region(1, -10000)
        set_environment_region(2, -10000)
    end

    if gGlobalSyncTable.gameState ~= 0 then
        if network_is_server() then
            local shine = obj_get_first_with_behavior_id(bhvShine)
            if not shine then
                local m = gMarioStates[0]
                local pos = {m.pos.x,m.floorHeight + 161,m.pos.z+500}
                if m.floor and is_hazard_floor(m.floor.type) then
                    pos[2] = m.pos.y
                end
                local needPlat = false
                if thisLevel.shineStart then
                    pos = thisLevel.shineStart
                elseif #spawn_potential > 0 then
                    pos = spawn_potential[1]
                else
                    local actor = obj_get_first(OBJ_LIST_GENACTOR)
                    if actor then
                        pos = {actor.oPosX, actor.oPosY + 160, actor.oPosZ}
                        needPlat = true
                    end
                end
                --djui_popup_create("spawned shine",1)
                if gGlobalSyncTable.variant ~= 1 then
                    spawn_sync_object(
                        bhvShine,
                        E_MODEL_SHINE,
                        pos[1],pos[2],pos[3],
                        function(o)
                            o.oBehParams = 0x1
                            o.oShineOwner = -1
                        end
                    )
                else
                    spawn_sync_object(
                        bhvShine,
                        E_MODEL_SHINE,
                        pos[1]-100,pos[2],pos[3],
                        function(o)
                            o.oBehParams = 0x1
                            o.oShineOwner = -1
                        end
                    )
                    spawn_sync_object(
                        bhvShine,
                        E_MODEL_SHINE,
                        pos[1]+100,pos[2],pos[3],
                        function(o)
                            o.oBehParams = 0x2
                            o.oShineOwner = -1
                        end
                    )
                end

                spawn_sync_object(
                    bhvShineMarker,
                    E_MODEL_TRANSPARENT_STAR,
                    pos[1],pos[2]-120,pos[3],
                    nil
                )

                if needPlat then
                    spawn_sync_object(
                        id_bhvStaticCheckeredPlatform,
                        E_MODEL_CHECKERBOARD_PLATFORM,
                        pos[1],pos[2]-186,pos[3],
                        nil
                    )
                end
            end
        end

        if thisLevel.boxLocations then
            for i,v in ipairs(thisLevel.boxLocations) do
                local pos = v
                spawn_non_sync_object(
                    id_bhvStaticCheckeredPlatform,
                    E_MODEL_CHECKERBOARD_PLATFORM,
                    pos[1],pos[2],pos[3],
                    function(o)
                        o.oFaceAnglePitch = pos[4] or 0
                        o.oFaceAngleYaw = pos[5] or 0
                    end
                )
            end
        end

        if thisLevel.pipeLocations then
            for i,v in ipairs(thisLevel.pipeLocations) do
                local pos = v
                spawn_non_sync_object(
                    bhvSTPipe,
                    E_MODEL_BITS_WARP_PIPE,
                    pos[1],pos[2],pos[3],
                    function(o)
                        o.oBehParams = i
                        o.oBehParams2ndByte = pos[4]
                        o.oFaceAngleYaw = pos[5]
                    end
                )
            end
        end
    elseif network_is_server() then -- lobby shine
        local shine = obj_get_first_with_behavior_id(bhvShine)
        if not shine then
            local pos = {0, 1066, -1200}
            if isRomHack then
                local m = gMarioStates[0]
                pos = {m.pos.x,m.floorHeight + 161,m.pos.z+500}
                if m.floor and is_hazard_floor(m.floor.type) then
                    pos[2] = m.pos.y
                end
            end
            spawn_sync_object(
                bhvShine,
                E_MODEL_SHINE,
                pos[1],pos[2],pos[3],
                function(o)
                    o.oBehParams = 0x1
                    o.oShineOwner = -1
                end
            )

            spawn_sync_object(
                bhvShineMarker,
                E_MODEL_TRANSPARENT_STAR,
                pos[1],pos[2]-120,pos[3],
                nil
            )
        end
    end

    if gGlobalSyncTable.gameState == 3 then
        drop_queued_background_music()
        fadeout_level_music(1)
        set_dance_action()
    elseif gGlobalSyncTable.gameState == 2 and gGlobalSyncTable.showTime then
        set_background_music(0, SEQ_LEVEL_KOOPA_ROAD, 120)
    end

    if not didFirstJoinStuff then
        print("My global index is ",gNetworkPlayers[0].globalIndex)

        sMario.shineTimer = 0
        sMario.specialCooldown = 0
        sMario.boostTime = 0
        sMario.spectator = false
        gMarioStates[0].numStars = 0
        save_file_set_using_backup_slot(true)
        save_file_set_flags(SAVE_FLAG_MOAT_DRAINED)
        save_file_clear_flags(SAVE_FLAG_HAVE_KEY_2)
        save_file_clear_flags(SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)

        sMario.team = calculate_lowest_member_team()
        if _G.OmmEnabled then
            _G.OmmApi.omm_force_setting_value("player",2)
            _G.OmmApi.omm_force_setting_value("color",0)
            _G.OmmApi.omm_force_setting_value("powerups",0)
            _G.OmmApi.omm_force_setting_value("stars",0)
            _G.OmmApi.omm_force_setting_value("bubble",0)
        end
        if gGlobalSyncTable.gameState ~= 0 and not warp_to_level(thisLevel.level, thisLevel.area, 6) then
            warp_to_warpnode(thisLevel.level, thisLevel.area, 6, 0)
        elseif gGlobalSyncTable.gameState == 0 then
            warp_to_start_level()
        end
        if gGlobalSyncTable.gameState == 2 then
            tipDispTimer = 150
        end

        for i,mod in pairs(gActiveMods) do
            if mod.enabled then
                if mod.incompatible and mod.incompatible:find("romhack") then
                    isRomHack = true
                    for a=1,BASE_LEVELS do
                        table.remove(levelData, 1)
                    end
                elseif mod.name:find("McDonald's") then
                    add_mcdonalds()
                end
            end
        end
        
        localWinner = gGlobalSyncTable.winner or -1
        localWinner2 = gGlobalSyncTable.winner2 or -1

        if network_is_server() then
            inMenu = true
            enter_menu(3, 1, true)
        end

        didFirstJoinStuff = true
    end
end
hook_event(HOOK_ON_SYNC_VALID, on_sync_valid)

-- no star select
hook_event(HOOK_USE_ACT_SELECT, function() return false end)

-- packet stuff
function network_send_include_self(reliable, data)
    network_send(reliable, data)
    if sPacketTable[data.id] ~= nil then
        sPacketTable[data.id](data, true)
    end
end

function on_packet_victory(data, self)
    gGlobalSyncTable.gameState = 3
    localWinner = data.winner or 0
    localWinner2 = data.winner2 or -1

    if self then
        gGlobalSyncTable.winner = localWinner
        gGlobalSyncTable.winner2 = localWinner2
    end

    if network_is_server() and gGlobalSyncTable.autoGame then
        gGlobalSyncTable.gameTimer = 480 -- 16 seconds
    end
    drop_queued_background_music()
    fadeout_level_music(1)
    audio_stream_play(MUSIC_SHINE_GET, false, 1)
    set_dance_action()
end

spawn_potential = {}
function on_packet_new_game(data, self)
    spawn_potential = {}
    if _G.OmmEnabled then
        gLevelValues.disableActs = false
        _G.OmmApi.omm_disable_feature("trueNonStop", true)
    end
    gGlobalSyncTable.gameState = 1
    gGlobalSyncTable.showTime = false
    showTimeTimer = 0
    if not self then
        setup_level_data(gGlobalSyncTable.gameLevel)
        if not warp_to_level(thisLevel.level, thisLevel.area, 6) then
            warp_to_warpnode(thisLevel.level, thisLevel.area, 6, 0)
        end
    end
    local sMario = gPlayerSyncTable[0]
    sMario.shineTimer = 0
    lose_shine(0, 3)
    sMario.specialCooldown = 0
    inMenu = false

    if data.teams ~= 0 and self then
        local teamTotal = data.teams
        local teamCounts = {}
        local possible = {}
        local maxTeamCount = math.ceil(network_player_connected_count() / teamTotal)
        for i=1,teamTotal do
            table.insert(teamCounts,0)
            table.insert(possible,i)
        end

        for i=0,(MAX_PLAYERS-1) do
            if gNetworkPlayers[i].connected and not gPlayerSyncTable[i].spectator then
                local a = math.random(1,#possible)
                local team = possible[a]
                gPlayerSyncTable[i].team = team
                teamCounts[team] = teamCounts[team] + 1
                if teamCounts[team] >= maxTeamCount then
                    table.remove(possible, a)
                end
            end
        end
    elseif data.teams == 0 then
        sMario.team = 0
    end
end

function on_packet_grab_shine(data, self)
    if not data.steal then
        local np = network_player_from_global_index(data.grabbed)
        local playerColor = network_get_player_text_color_string(np.localIndex)
        djui_popup_create(playerColor..np.name.."\\#ffffff\\ stole the \\#ffff40\\Shine\\#ffffff\\!", 1)
    end
    audio_sample_play(SOUND_SHINE_GRAB, gMarioStates[0].marioObj.header.gfx.cameraToObject, 1)
end

function on_packet_reset_shine(data, self)
    local shine = obj_get_first_with_behavior_id(bhvShine)
    while shine do
        if shine.oShineOwner ~= -1 then
            local np = network_player_from_global_index(shine.oShineOwner)
            local sMario = gPlayerSyncTable[np.localIndex]
            sMario.hasShine = 0
        end
        shine.oShineOwner = -1
        shine.oTimer = 0
        shine_return(shine)
        shine = obj_get_next_with_same_behavior_id(shine)
    end

    djui_popup_create("Resetting the \\#ffff40\\Shine\\#ffffff\\!", 1)
end

function on_packet_move_shine(data, self)
    local shine = obj_get_first_with_behavior_id(bhvShine)
    local m = gMarioStates[0]
    if not self then
        local np = network_player_from_global_index(data.mover)
        m = gMarioStates[np.localIndex]
    end

    while shine do
        shine.oHomeX = m.pos.x
        shine.oHomeY = m.pos.y + 80
        shine.oHomeZ = m.pos.z
        if shine.oShineOwner == -1 then
            shine.oShineOwner = -1
            shine.oTimer = 0
            shine_return(shine)
        end
        
        shine = obj_get_next_with_same_behavior_id(shine)
    end

    djui_popup_create("Moving the \\#ffff40\\Shine\\#ffffff\\!", 1)
end

function on_packet_showtime(data, self)
    gGlobalSyncTable.showTime = true
    showTimeDispTimer = 90 -- 3 seconds
    set_background_music(0, SEQ_LEVEL_KOOPA_ROAD, 120)
end

function on_packet_direct_steal(data, self)
    local np = network_player_from_global_index(data.victim)
    print("received direct steal from",data.victim)
    local shine = obj_get_first_with_behavior_id_and_field_s32(bhvShine, 0x40, data.shineID)
    if shine then
        print("steal succeeded")
        sentShineMessage = true
        local aNP = gNetworkPlayers[0]
        local aPlayerColor = network_get_player_text_color_string(0)
        local playerColor = network_get_player_text_color_string(np.localIndex)
        shine.oShineOwner = aNP.globalIndex
        gPlayerSyncTable[0].hasShine = shine.oBehParams
        gPlayerSyncTable[np.localIndex].hasShine = 0
        gMarioStates[0].invincTimer = 90
        network_send_include_self(true, {
            id = PACKET_GRAB_SHINE,
            steal = true,
        })
        djui_popup_create_global(string.format("%s\\#ffffff\\ stole %s's \\#ffff40\\Shine\\#ffffff\\!",aPlayerColor..aNP.name,playerColor..np.name), 1)
    end
end

function on_packet_receive(data)
    if sPacketTable[data.id] ~= nil then
        sPacketTable[data.id](data, false)
    end
end
hook_event(HOOK_ON_PACKET_RECEIVE, on_packet_receive)

PACKET_VICTORY = 1
PACKET_NEWGAME = 2
PACKET_GRAB_SHINE = 3
PACKET_RESET_SHINE = 4
PACKET_SHOWTIME = 5
PACKET_MOVE_SHINE = 6
PACKET_DIRECT_STEAL = 7
sPacketTable = {
    [PACKET_VICTORY] = on_packet_victory,
    [PACKET_NEWGAME] = on_packet_new_game,
    [PACKET_GRAB_SHINE] = on_packet_grab_shine,
    [PACKET_RESET_SHINE] = on_packet_reset_shine,
    [PACKET_SHOWTIME] = on_packet_showtime,
    [PACKET_MOVE_SHINE] = on_packet_move_shine,
    [PACKET_DIRECT_STEAL] = on_packet_direct_steal,
}
