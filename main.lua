-- name: \\#ffff40\\Shine Thief (v1.5 WIP)
-- description: Stealing mods is a bannable offense.
-- description_actual: Shine Thief from Mario Kart: Double Dash and Mario Kart 8 Deluxe, now in sm64ex-coop!\n\nMod by EmilyEmmi\n\nShine Dynos by Blocky\n\nSome graphics/sounds created/provided by NeedleN64\n\nMcDonalds by chillyzone\nArena by Agent X\nArena stage base by angelicmiracles
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
gGlobalSyncTable.mapChoice = 0
gGlobalSyncTable.spawnOffset = 0
gGlobalSyncTable.shineOwner1 = -1
gGlobalSyncTable.shineOwner2 = -1
gGlobalSyncTable.voteMap1 = 1
gGlobalSyncTable.voteMap2 = 2
gGlobalSyncTable.voteMap3 = 3
gGlobalSyncTable.wonMap = -1

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

cappyStealer = 0


local shineFrameCounter = 0
local showTimeTimer = 0
SPECIAL_BUTTON = (_G.OmmEnabled and L_TRIG) or Y_BUTTON
isRomHack = false
localWinner = 0
localWinner2 = -1
specialDown = false
specialPressed = false

-- team colors (first is palette, second is table for HUD color)
TEAM_PALETTE = {
    { PALETTE_BURGUNDY or 15,  { r = 255, g = 64, b = 64, a = 255 },      "Red" }, -- red
    { PALETTE_COBALT or 7,     { r = 64, g = 64, b = 255, a = 255 },      "Blu" }, -- blue
    { PALETTE_CLOVER or 6,     { r = 64, g = 255, b = 64, a = 255 },      "Grn" }, -- green
    { PALETTE_BUSY_BEE or 24,  { r = 255, g = 255, b = 64, a = 255 },     "Ylw" }, -- yellow
    { PALETTE_ORANGE or 18,    { r = 255, g = 160, b = 20, a = 255 },     "Org" }, -- orange
    { PALETTE_AZURE or 14,     { r = 64, g = 255, b = 255, a = 255 },     "Cyn" }, -- cyan
    { PALETTE_NICE_PINK or 10, { r = 0xff, g = 0xa1, b = 0xeb, a = 255 }, "Pnk" }, -- pink
    { PALETTE_WALUIGI or 2,    { r = 0xa0, g = 64, b = 255, a = 255 },    "Vlt" }, -- violet
}

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
    else
        warp_to_level(4, 1, -1) -- cancel warp
    end

    gGlobalSyncTable.gameLevel = level
    gGlobalSyncTable.gameTimer = 1
    gGlobalSyncTable.shineOwner1 = -1
    gGlobalSyncTable.shineOwner2 = -1

    local playerCount = get_participant_count()

    gGlobalSyncTable.winTime = 36 -
        math.min(playerCount, 26) -- more time with less players (min 10s)
    if gGlobalSyncTable.teamMode ~= 0 then
        gGlobalSyncTable.winTime = gGlobalSyncTable.winTime +
            40 //
            gGlobalSyncTable.teamMode -- more time with less teams
    end

    gGlobalSyncTable.spawnOffset = math.random(0, MAX_PLAYERS - 1)

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
    for i = 0, (MAX_PLAYERS - 1) do
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
            if get_player_owned_shine(0) ~= 0 then
                drop_shine(0, 1)
            end
            if sMario.team ~= 0 then
                sMario.shineTimer = 0
                sMario.team = 0
            end
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
    local ownedShine = get_player_owned_shine(m.playerIndex)

    local speed_cap = 40

    if (m.action & ACT_FLAG_SWIMMING) ~= 0 then speed_cap = 20 end
    if _G.OmmEnabled then speed_cap = speed_cap + 10 end                           -- speed cap is greater for OMM
    if (m.action & ACT_FLAG_RIDING_SHELL) ~= 0 then speed_cap = speed_cap + 10 end -- other players can travel at >60 speed

    -- boost variant
    if (gGlobalSyncTable.variant == 5 or gGlobalSyncTable.variant == 7 or sMario.spectator) and sMario.boostTime and sMario.boostTime ~= 0 then
        if (m.action & ACT_FLAG_INTANGIBLE) == 0 then
            speed_cap = speed_cap + 15

            if ownedShine == 0 then speed_cap = speed_cap + 15 end -- boost is worse for shine player

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
        if get_player_owned_shine(m.playerIndex) ~= 0 then
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
        speed_cap = 80
        local speed_min = 30
        if (m.pos.y > 7000 and m.pos.y - m.floorHeight > 3000) then
            speed_min = 0
        elseif sMario.boostTime ~= 0 then
            speed_min = speed_min + 20
            speed_cap = speed_cap + 20
            m.forwardVel = approach_f32(m.forwardVel, speed_cap, 4, 4)
        end

        if ownedShine ~= 0 then
            m.forwardVel = clamp(m.forwardVel, speed_min, speed_cap - 30)
        else
            m.forwardVel = math.max(m.forwardVel, speed_min)
        end
    elseif m.action == ACT_WATER_SHELL_SWIMMING then
        m.forwardVel = 40 -- usually 28
        if ownedShine ~= 0 then m.forwardVel = 30 end
        if (m.input & INPUT_Z_PRESSED) ~= 0 then
            m.actionTimer = 240                          -- drop water shell
        else
            m.actionTimer = 0                            -- no time limit
        end
    elseif m.action == ACT_WATER_PUNCH then              -- buff water punch (like in mariohunt)
        if m.prevAction == ACT_WATER_SHELL_SWIMMING then -- stay at same speed when using water shell
            m.forwardVel = 40                            -- usually 28
            if ownedShine ~= 0 then m.forwardVel = 30 end
        else
            m.forwardVel = speed_cap                           -- as fast as player with shine can swim
        end
    elseif (ownedShine ~= 0) and m.forwardVel > speed_cap then -- the player with the shine is slowed
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
    m.health = 0x880       -- health? get that outta here
    m.peakHeight = m.pos.y -- fall damage bad
    m.cap = 0              -- don't lose cap permanently
    m.numCoins = 0         -- no 100 coin star! bad

    local sMario = gPlayerSyncTable[m.playerIndex]
    local np = gNetworkPlayers[m.playerIndex]
    local ownedShine = get_player_owned_shine(m.playerIndex)

    if m.playerIndex == 0 and gGlobalSyncTable.gameState == 3 and m.action ~= ACT_SHINE_DANCE and m.action ~= ACT_SHINE_LOSE then
        drop_queued_background_music()
        fadeout_level_music(1)
        set_dance_action()
    end

    -- cancel game if there aren't enough players
    if m.playerIndex == 0 and gGlobalSyncTable.variant == 1 and gGlobalSyncTable.mhState == 2 and get_participant_count() < 3 then
        gGlobalSyncTable.variant = 0
        new_game()
        djui_popup_create_global("Not enough players for Double Shine!", 2)
    end

    -- drop the shine if we take damage
    if (m.action == ACT_BURNING_FALL or m.action == ACT_BURNING_GROUND or m.action == ACT_BURNING_JUMP
    or m.hurtCounter > 0)
    and ownedShine ~= 0 and m.playerIndex == 0 then
        if cappyStealer == 0 then
            drop_shine(0, 0)
        else
            drop_shine(0, 3, cappyStealer)
            cappyStealer = 0
        end
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

    if (m.pos.y - m.floorHeight <= 2048 and m.floor.type == SURFACE_DEATH_PLANE) then -- happens when falling in OMM
        on_death(m)
    end

    if sMario.shineTimer == nil then sMario.shineTimer = 0 end

    -- set player colors
    local extra
    local color = { r = 255, g = 64, b = 64, a = 255 } -- red
    if sMario.team == 0 or sMario.team == nil then
        if ownedShine ~= 0 then
            color = { r = 255, g = 255, b = 64, a = 255 } -- yellow
        end
        np.overridePaletteIndex = np.paletteIndex
    elseif TEAM_PALETTE[sMario.team] then
        np.overridePaletteIndex = TEAM_PALETTE[sMario.team][1]
        color = deep_copy(TEAM_PALETTE[sMario.team][2])
        extra = TEAM_PALETTE[sMario.team][3]
        if ownedShine == 0 then color.a = 100 end
    end
    -- set player descriptions
    if sMario.spectator then
        network_player_set_description(np, "Spectator", 128, 128, 128, 255)
    elseif extra then
        network_player_set_description(np, extra .. ": " .. tostring(sMario.shineTimer), color.r, color.g, color.b,
            color.a)
    else
        network_player_set_description(np, tostring(sMario.shineTimer), color.r, color.g, color.b, color.a)
    end

    -- handle holding shine
    if ownedShine ~= 0 then
        if m.invincTimer ~= 0 then m.invincTimer = m.invincTimer - 1 end

        if gGlobalSyncTable.variant ~= 1 then
            if m.playerIndex == 0 and sMario.shineTimer <= gGlobalSyncTable.winTime then
                shineFrameCounter = shineFrameCounter + 1
                if gGlobalSyncTable.showTime then
                    shineFrameCounter = shineFrameCounter + 1
                end
                if gGlobalSyncTable.gameState == 2 then
                    if shineFrameCounter >= 60 or (shineFrameCounter >= 30 and sMario.shineTimer < gGlobalSyncTable.winTime - 3) then -- it's 2 seconds per second near the end
                        sMario.shineTimer = sMario.shineTimer +
                            1                                                                                                         -- increment timer
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
            end
        else -- double shine works a bit different
            local mySMario = gPlayerSyncTable[0]
            if m.playerIndex ~= 0 and get_player_owned_shine(0) ~= 0 and mySMario.shineTimer <= gGlobalSyncTable.winTime then
                shineFrameCounter = shineFrameCounter + 1
                if gGlobalSyncTable.showTime then
                    shineFrameCounter = shineFrameCounter + 1
                end
                if gGlobalSyncTable.gameState == 2 then
                    if shineFrameCounter >= 60 or (shineFrameCounter >= 30 and sMario.shineTimer < gGlobalSyncTable.winTime - 3) then -- it's 2 seconds per second near the end
                        mySMario.shineTimer = mySMario.shineTimer +
                            1                                                                                                         -- increment timer
                        shineFrameCounter = 0
                    end
                    if mySMario.shineTimer > gGlobalSyncTable.winTime then -- victory
                        mySMario.shineTimer = gGlobalSyncTable.winTime
                        network_send_include_self(true, {
                            id = PACKET_VICTORY,
                            winner = get_shine_owner(1) or gNetworkPlayers[0].globalIndex,
                            winner2 = get_shine_owner(2),
                        })
                        play_sound(SOUND_MENU_STAR_SOUND, m.marioObj.header.gfx.cameraToObject)
                    end
                end
            end
        end

        if m.playerIndex ~= 0 then
            local mySMario = gPlayerSyncTable[0]
            -- prevent dual ownership
            if get_player_owned_shine(0) == ownedShine then
                if gMarioStates[0].forwardVel > m.forwardVel then -- the player moving faster gets priority
                    drop_shine(m.playerIndex)
                else
                    drop_shine(0)
                end
            end
            -- update team shine timer
            if get_player_owned_shine(0) ~= 0 and ownedShine ~= 0 then
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
        if gGlobalSyncTable.teamMode ~= 0 and special_down(m) and m.framesSinceB < 5 then
            drop_shine(m.playerIndex, 2)
        end

        set_mario_particle_flags(m, PARTICLE_SPARKLES, 0) -- sparkle if we have shine
    elseif m.playerIndex == 0 then
        shineFrameCounter = 0
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
    if gGlobalSyncTable.variant == 2 or gGlobalSyncTable.variant == 7 then
        m.flags = m.flags | MARIO_WING_CAP
    end

    -- shell rush variant
    if m.riddenObj and m.riddenObj.heldByPlayerIndex ~= m.playerIndex then
        m.riddenObj.heldByPlayerIndex = m.playerIndex
    end
    if gGlobalSyncTable.variant == 3 and gGlobalSyncTable.gameState ~= 3 and special_pressed(m) and m.action & ACT_FLAG_INTANGIBLE == 0 and not m.heldObj then
        shell_rush_shell(m)
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
            elseif m.vel.y < -50 then
                m.vel.y = -50
            end
        elseif m.vel.y ~= 0 then
            m.vel.y = m.vel.y + 1
        end
    end

    -- bombs variant
    if gGlobalSyncTable.variant == 6 and gGlobalSyncTable.gameState ~= 3 and sMario.specialCooldown == 0 and special_pressed(m) then
        if m.playerIndex == 0 then
            spawn_sync_object(
                id_bhvThrownBobomb,
                E_MODEL_BLACK_BOBOMB,
                m.pos.x, m.pos.y + 50, m.pos.z,
                function(o)
                    o.oForwardVel = m.forwardVel + 35
                    o.oMoveAngleYaw = m.intendedYaw
                    o.oFaceAngleYaw = o.oMoveAngleYaw
                    o.oObjectOwner = np.globalIndex
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
            m.vel.y = prevVel                     -- prevent stalling
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
    if (gGlobalSyncTable.variant == 5 or gGlobalSyncTable.variant == 7 or sMario.spectator) and sMario.boostTime then
        if sMario.boostTime ~= 0 then
            if special_down(m) then                                  -- boost while holding Y
                set_mario_particle_flags(m, ACTIVE_PARTICLE_FIRE, 0) -- fire when boosting
                if m.playerIndex == 0 then
                    sMario.boostTime = sMario.boostTime + 1
                    sMario.specialCooldown = sMario.boostTime * 2 -- cooldown is longer the more you use the boost
                    if sMario.boostTime >= 60 then                -- maximum of 2 seconds of boost (for 4 seconds cooldown)
                        sMario.boostTime = 0
                        sMario.specialCooldown = 120
                    end
                end
            elseif m.playerIndex == 0 then
                sMario.specialCooldown = sMario.boostTime * 2 -- cooldown is longer the more you use the boost
                sMario.boostTime = 0
            end
        elseif m.playerIndex == 0 and special_pressed(m) and sMario.specialCooldown == 0 then
            sMario.boostTime = 1 -- start boost by pressing y
        end
    end

    if m.playerIndex == 0 and network_is_server() and gGlobalSyncTable.mapChoice ~= 0 and (gGlobalSyncTable.gameState == 0 or showGameResults) then -- auto game
        if gGlobalSyncTable.gameTimer > 0 then
            gGlobalSyncTable.gameTimer = gGlobalSyncTable.gameTimer - 1
            if gGlobalSyncTable.gameTimer == 179 and gGlobalSyncTable.mapChoice == 1 then
                -- count the votes
                local votes = { { gGlobalSyncTable.voteMap1, 0 }, { gGlobalSyncTable.voteMap2, 0 }, { gGlobalSyncTable.voteMap3, 0 } }
                for i = 0, MAX_PLAYERS - 1 do
                    local sMario = gPlayerSyncTable[i]
                    if sMario.myVote and sMario.myVote ~= 0 and votes[sMario.myVote] then
                        votes[sMario.myVote][2] = votes[sMario.myVote][2] + 1
                    end
                end

                table.sort(votes, function(a, b) return a[2] > b[2] end)

                local map = 0
                if votes[1][2] == votes[3][2] then     -- all tie
                    map = votes[math.random(1, 3)][1]
                elseif votes[1][2] == votes[2][2] then -- two tie
                    map = votes[math.random(1, 2)][1]
                else
                    map = votes[1][1]
                end
                gGlobalSyncTable.wonMap = map
            end
        elseif gGlobalSyncTable.mapChoice == 1 and gGlobalSyncTable.wonMap ~= -1 then
            new_game_set_settings(gGlobalSyncTable.wonMap)
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
            go_to_mario_start(m.playerIndex, np.globalIndex, false)
            -- time until start
            if m.playerIndex == 0 and network_is_server() then
                gGlobalSyncTable.gameTimer = gGlobalSyncTable.gameTimer + 1
                if DEBUG_MODE or gGlobalSyncTable.gameTimer > 300 then
                    gGlobalSyncTable.gameTimer = 0
                    gGlobalSyncTable.gameState = 2
                end
            end
        elseif gGlobalSyncTable.gameState == 2 and m.playerIndex == 0 and network_is_server() then
            if showTimeTimer < 9000 then
                showTimeTimer = showTimeTimer + 1
                if showTimeTimer == 8700 then -- 10 seconds left
                    djui_popup_create_global("10 seconds until Showtime!", 1)
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

-- important functions: gets or sets the shine status
function get_player_owned_shine(index)
    local globalIndex = network_global_index_from_local(index)
    if not globalIndex then return 0 end
    if globalIndex == gGlobalSyncTable.shineOwner1 then
        return 1
    elseif globalIndex == gGlobalSyncTable.shineOwner2 then
        return 2
    end
    return 0
end

function set_player_owned_shine(index, shine)
    local globalIndex = -1
    if index ~= -1 then
        globalIndex = network_global_index_from_local(index)
        if not globalIndex then return -1 end
    end

    if shine == 1 then
        gGlobalSyncTable.shineOwner1 = globalIndex
        return globalIndex
    elseif shine == 2 then
        gGlobalSyncTable.shineOwner2 = globalIndex
        return globalIndex
    end
    return -1
end

function get_shine_owner(shine)
    if shine == 1 then
        return gGlobalSyncTable.shineOwner1
    elseif shine == 2 then
        return gGlobalSyncTable.shineOwner2
    end
    return -1
end

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
    for i = 1, teamTotal do
        table.insert(teamCounts, 0)
        table.insert(possible, i)
    end

    for i = 1, (MAX_PLAYERS - 1) do
        if gNetworkPlayers[i].connected then
            local team = gPlayerSyncTable[i].team
            if team ~= 0 and not gPlayerSyncTable[i].spectator then
                teamCounts[team] = teamCounts[team] + 1
            end
        end
    end
    for team, count in pairs(teamCounts) do
        if count < minTeamCount then
            possible = { team }
            minTeamCount = count
        elseif count == minTeamCount then
            table.insert(possible, team)
        end
    end
    return possible[math.random(1, #possible)]
end

-- starts a random level, which is either from the supported list or any random level if "custom" was used
function start_random_level(list)
    if list then
        new_game_set_settings(math.random(1, #levelData))
        return
    end

    local LIMIT = 0
    local dry = (get_menu_option(4, 3) == 1)
    while LIMIT < 1000 do
        local level = course_to_level[math.random(0, #course_to_level)]
        local area = math.random(1, 7)
        local levelString = tostring(level) .. " " .. tostring(area) .. " " .. tostring(dry)
        setup_level_data(levelString)
        if not (isRomHack and level_is_vanilla_level(thisLevel.level)) and (warp_to_level(thisLevel.level, thisLevel.area, 6) or warp_to_warpnode(thisLevel.level, thisLevel.area, 6, 0)) then
            new_game_set_settings(levelString)
            break
        end
        LIMIT = LIMIT + 1
    end
end

-- chooses 3 random levels for the voting screen, which is either from the supported list or any random level if "custom" was used
-- if there are less than 3 supported levels, nonsupported levels will be listed for the other two
function vote_pick_random_levels(list)
    local LIMIT = 0
    local chosen = 0
    local maps = {}
    local alreadyChosen = {}
    if list or isRomHack then
        while LIMIT < 1000 and #levelData > chosen and chosen < 3 do
            local map = math.random(1, #levelData)
            if not alreadyChosen[map] then
                chosen = chosen + 1
                maps[chosen] = map
                alreadyChosen[map] = 1
                if isRomHack then break end
            end
        end
    end

    LIMIT = 0
    local dry = (get_menu_option(4, 3) == 1)
    while LIMIT < 1000 and chosen < 3 do
        local level = course_to_level[math.random(0, #course_to_level)]
        local area = math.random(1, 7)
        local map = tostring(level) .. " " .. tostring(area) .. " " .. tostring(dry)
        if not (alreadyChosen[map] or (isRomHack and level_is_vanilla_level(level))) and (warp_to_level(level, area, 6) or warp_to_warpnode(level, area, 6, 0)) then
            chosen = chosen + 1
            maps[chosen] = map
            alreadyChosen[map] = 1
            warp_to_level(4, 1, -1) -- cancel warp
        end
        LIMIT = LIMIT + 1
    end

    gGlobalSyncTable.voteMap1 = maps[1] or gGlobalSyncTable.voteMap1
    gGlobalSyncTable.voteMap2 = maps[2] or gGlobalSyncTable.voteMap2
    gGlobalSyncTable.voteMap3 = maps[3] or gGlobalSyncTable.voteMap3
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
        local vOwnedShine = get_player_owned_shine(0)

        if attacker.action == ACT_SLIDE_KICK or attacker.action == ACT_SLIDE_KICK_SLIDE or attacker.action == ACT_SLIDE_KICK_SLIDE_STOP or cappyAttack then
            if vOwnedShine ~= 0 and get_player_owned_shine(attacker.playerIndex) == 0 then
                if cappyAttack then -- can't send packet from OMM, so use old system (kind of)
                    cappyStealer = attacker.playerIndex
                    return
                end
                return drop_shine(victim.playerIndex, 3, attacker.playerIndex)
            end
        end

        if vOwnedShine ~= 0 then
            drop_shine(victim.playerIndex, 0, attacker.playerIndex)
        end
    end
end

hook_event(HOOK_ON_PVP_ATTACK, on_pvp_attack)

-- omm support
function omm_allow_attack(index, setting)
    if setting == 3 and index ~= 0 then
        return allow_pvp_attack(gMarioStates[index], gMarioStates[0])
    end
    return true
end

function omm_attack(index, setting)
    if setting == 3 and index ~= 0 then
        return on_pvp_attack(gMarioStates[index], gMarioStates[0], true)
    end
end

function omm_disable_feature(feature, disable)
    return -- set when OMM is enabled
end

-- drop shine on death (runs when falling)
function on_death(m)
    if get_player_owned_shine(m.playerIndex) ~= 0 then
        drop_shine(m.playerIndex, 1)
    end
    go_to_mario_start(m.playerIndex, gNetworkPlayers[m.playerIndex].globalIndex, true)
    return false
end

hook_event(HOOK_ON_DEATH, on_death)

function on_pause_exit(exitToCastle)
    if gGlobalSyncTable.gameState ~= 3 then
        go_to_mario_start(0, gNetworkPlayers[0].globalIndex, true)
        if get_player_owned_shine(0) ~= 0 then
            drop_shine(0, 1)
        end
    end
    return false
end

hook_event(HOOK_ON_PAUSE_EXIT, on_pause_exit)
--hook_event(HOOK_ON_WARP, on_pause_exit)

-- spawns or despawns shell
function shell_rush_shell(m)
    local spawnShell = 0
    if m.riddenObj then
        m.riddenObj.oInteractStatus = INT_STATUS_STOP_RIDING
        force_idle_state(m)
    elseif (m.input & INPUT_IN_WATER) ~= 0 then
        if (m.waterLevel - m.pos.y) < 100 then
            spawnShell = 1
            m.pos.y = m.waterLevel
        else
            spawnShell = 2
            if m.playerIndex == 0 and m.area.camera.mode == CAMERA_MODE_WATER_SURFACE then
                set_camera_mode(m.area.camera, CAMERA_MODE_FREE_ROAM, 1)
            end
        end
    elseif m.prevAction ~= ACT_RIDING_SHELL_GROUND then
        spawnShell = 1
    end

    if spawnShell == 2 then
        if m.playerIndex == 0 then
            m.heldObj = spawn_sync_object(
                id_bhvKoopaShellUnderwater,
                E_MODEL_KOOPA_SHELL,
                m.pos.x, m.pos.y, m.pos.z,
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
        if m.playerIndex == 0 then
            m.riddenObj = spawn_sync_object(
                id_bhvSTShell,
                E_MODEL_KOOPA_SHELL,
                m.pos.x, m.pos.y, m.pos.z,
                function(o)
                    o.oFaceAnglePitch = 0
                    o.oFaceAngleRoll = 0
                    o.oAction = 1
                    o.heldByPlayerIndex = 0
                end
            )
        end
        set_mario_action(m, ACT_RIDING_SHELL_FALL, 0)
    end
end

-- check if the special button is pressed or held
function special_down(m)
    if m.playerIndex == 0 then
        return specialDown
    else
        return (m.controller.buttonDown & SPECIAL_BUTTON ~= 0)
    end
end

function special_pressed(m)
    if m.playerIndex == 0 then
        return specialPressed
    else
        return (m.controller.buttonPressed & SPECIAL_BUTTON ~= 0)
    end
end

-- no!!!! no dialog!!!!
function on_dialog(id)
    return false
end

hook_event(HOOK_ON_DIALOG, on_dialog)

-- set our status when we enter; spawn platforms and pipes, and spawn shine if host
function on_sync_valid()
    local sMario = gPlayerSyncTable[0]
    if get_player_owned_shine(0) ~= 0 then -- if we just entered, we obviously don't have the shine
        set_player_owned_shine(-1, 0)
    end
    sMario.specialCooldown = 0
    sMario.boostTime = 0
    setup_level_data(gGlobalSyncTable.gameLevel)
    if gGlobalSyncTable.gameState ~= 0 then
        go_to_mario_start(0, gNetworkPlayers[0].globalIndex, true)
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
            local shine = obj_get_first_with_behavior_id(id_bhvShine)
            if not shine then
                local m = gMarioStates[0]
                local pos = { m.pos.x, m.floorHeight + 161, m.pos.z + 500 }
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
                        pos = { actor.oPosX, actor.oPosY + 160, actor.oPosZ }
                        needPlat = true
                    end
                end
                --djui_popup_create("spawned shine",1)
                if gGlobalSyncTable.variant ~= 1 then
                    spawn_sync_object(
                        id_bhvShine,
                        E_MODEL_SHINE,
                        pos[1], pos[2], pos[3],
                        function(o)
                            o.oBehParams = 0x1
                        end
                    )
                else
                    spawn_sync_object(
                        id_bhvShine,
                        E_MODEL_SHINE,
                        pos[1] - 100, pos[2], pos[3],
                        function(o)
                            o.oBehParams = 0x1
                        end
                    )
                    spawn_sync_object(
                        id_bhvShine,
                        E_MODEL_SHINE,
                        pos[1] + 100, pos[2], pos[3],
                        function(o)
                            o.oBehParams = 0x2
                        end
                    )
                end

                spawn_sync_object(
                    id_bhvShineMarker,
                    E_MODEL_TRANSPARENT_STAR,
                    pos[1], pos[2] - 120, pos[3],
                    nil
                )

                if needPlat then
                    spawn_sync_object(
                        id_bhvStaticCheckeredPlatform,
                        E_MODEL_CHECKERBOARD_PLATFORM,
                        pos[1], pos[2] - 186, pos[3],
                        nil
                    )
                end
            end

            if thisLevel.objLocations then
                for i, v in ipairs(thisLevel.objLocations) do
                    spawn_sync_object(
                        v[1],
                        v[2],
                        v[3], v[4], v[5],
                        function(o)
                            o.oBehParams = v[6] or 0
                            o.oBehParams2ndByte = v[7] or 0
                            o.oFaceAnglePitch = v[8] or 0
                            o.oFaceAngleYaw = v[9] or 0
                        end
                    )
                end
            end
        end
    elseif network_is_server() then -- lobby shine
        vote_pick_random_levels(true)
        local shine = obj_get_first_with_behavior_id(id_bhvShine)
        if not shine then
            local pos = { 0, 1066, -1200 }
            if isRomHack then
                local m = gMarioStates[0]
                pos = { m.pos.x, m.floorHeight + 161, m.pos.z + 500 }
                if m.floor and is_hazard_floor(m.floor.type) then
                    pos[2] = m.pos.y
                end
            end
            spawn_sync_object(
                id_bhvShine,
                E_MODEL_SHINE,
                pos[1], pos[2], pos[3],
                function(o)
                    o.oBehParams = 0x1
                end
            )

            spawn_sync_object(
                id_bhvShineMarker,
                E_MODEL_TRANSPARENT_STAR,
                pos[1], pos[2] - 120, pos[3],
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
        print("My global index is ", gNetworkPlayers[0].globalIndex)

        sMario.shineTimer = 0
        sMario.specialCooldown = 0
        sMario.boostTime = 0
        sMario.spectator = false
        sMario.myVote = 0
        gMarioStates[0].numStars = 0
        save_file_set_using_backup_slot(true)
        save_file_set_flags(SAVE_FLAG_MOAT_DRAINED)
        save_file_clear_flags(SAVE_FLAG_HAVE_KEY_2)
        save_file_clear_flags(SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)

        sMario.team = calculate_lowest_member_team()
        if _G.OmmEnabled then
            _G.OmmApi.omm_force_setting("player", 2)
            _G.OmmApi.omm_force_setting("color", 0)
            _G.OmmApi.omm_force_setting("powerups", 0)
            _G.OmmApi.omm_force_setting("stars", 0)
            _G.OmmApi.omm_force_setting("bubble", 0)
        end
        if gGlobalSyncTable.gameState ~= 0 and not warp_to_level(thisLevel.level, thisLevel.area, 6) then
            warp_to_warpnode(thisLevel.level, thisLevel.area, 6, 0)
        elseif gGlobalSyncTable.gameState == 0 then
            warp_to_start_level()
        end
        if gGlobalSyncTable.gameState == 2 then
            tipDispTimer = 150
        end

        for i, mod in pairs(gActiveMods) do
            if mod.enabled then
                if mod.incompatible and mod.incompatible:find("romhack") then
                    isRomHack = true
                    for a = 1, BASE_LEVELS do
                        table.remove(levelData, 1)
                    end
                    menu_update_for_romhack(#levelData)
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

    if network_is_server() and gGlobalSyncTable.mapChoice ~= 0 then
        if gGlobalSyncTable.mapChoice == 1 then
            gGlobalSyncTable.gameTimer = 630 -- 21 seconds
        else
            gGlobalSyncTable.gameTimer = 330 -- 11 seconds
        end
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
    gGlobalSyncTable.shineOwner1 = -1
    gGlobalSyncTable.shineOwner2 = -1

    if network_is_server() then
        gGlobalSyncTable.wonMap = -1
        vote_pick_random_levels(type(gGlobalSyncTable.gameLevel) == "number")
    end

    showTimeTimer = 0
    if not self then
        setup_level_data(gGlobalSyncTable.gameLevel)
        
    end
    if not warp_to_level(thisLevel.level, thisLevel.area, 6) then
        warp_to_warpnode(thisLevel.level, thisLevel.area, 6, 0)
    end

    for i = 0, MAX_PLAYERS - 1 do
        gPlayerSyncTable[i].shineTimer = 0
        gPlayerSyncTable[i].specialCooldown = 0
        gPlayerSyncTable[i].myVote = 0
        if data.teams == 0 then
            gPlayerSyncTable[i].team = 0
        end
    end

    inMenu = false
    menu_set_settings()

    if data.teams ~= 0 and self then
        local teamTotal = data.teams
        local teamCounts = {}
        local possible = {}
        local maxTeamCount = math.ceil(network_player_connected_count() / teamTotal)
        for i = 1, teamTotal do
            table.insert(teamCounts, 0)
            table.insert(possible, i)
        end

        for i = 0, (MAX_PLAYERS - 1) do
            if gNetworkPlayers[i].connected and not gPlayerSyncTable[i].spectator then
                local a = math.random(1, #possible)
                local team = possible[a]
                gPlayerSyncTable[i].team = team
                teamCounts[team] = teamCounts[team] + 1
                if teamCounts[team] >= maxTeamCount then
                    table.remove(possible, a)
                end
            end
        end
    end
end

function on_packet_grab_shine(data, self)
    local np = network_player_from_global_index(data.grabbed)
    local playerColor = network_get_player_text_color_string(np.localIndex)
    if not data.stealer then
        djui_popup_create(playerColor .. np.name .. "\\#ffffff\\ stole the \\#ffff40\\Shine\\#ffffff\\!", 1)
    else
        local aNP = network_player_from_global_index(data.stealer)
        local aPlayerColor = network_get_player_text_color_string(np.localIndex)
        djui_popup_create(
            string.format("%s\\#ffffff\\ stole %s's \\#ffff40\\Shine\\#ffffff\\!", aPlayerColor .. aNP.name,
                playerColor .. np.name), 1)
    end

    audio_sample_play(SOUND_SHINE_GRAB, gMarioStates[0].marioObj.header.gfx.cameraToObject, 1)
end

function on_packet_drop_shine(data, self)
    -- no need to convert global indexes to local indexes, as global indexes are
    -- local indexes for the server
    --local owner = network_local_index_from_global(data.owner)
    --local attacker = network_local_index_from_global(data.attacker)
    local dropType = data.dropType
    lose_shine(data.owner, dropType, data.attacker)
end

function on_packet_reset_shine(data, self)
    local shine = obj_get_first_with_behavior_id(id_bhvShine)
    while shine do
        set_player_owned_shine(-1, shine.oBehParams)
        shine.oTimer = 0
        shine_return(shine)
        shine = obj_get_next_with_same_behavior_id(shine)
    end

    djui_popup_create("Resetting the \\#ffff40\\Shine\\#ffffff\\!", 1)
end

function on_packet_move_shine(data, self)
    local shine = obj_get_first_with_behavior_id(id_bhvShine)
    local m = gMarioStates[0]
    if not self then
        local np = network_player_from_global_index(data.mover)
        m = gMarioStates[np.localIndex]
    end

    while shine do
        shine.oHomeX = m.pos.x
        shine.oHomeY = m.pos.y + 80
        shine.oHomeZ = m.pos.z
        if get_shine_owner(shine) == -1 then
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

function on_packet_receive(data)
    if sPacketTable[data.id] ~= nil then
        sPacketTable[data.id](data, false)
    end
end

hook_event(HOOK_ON_PACKET_RECEIVE, on_packet_receive)

PACKET_VICTORY = 1
PACKET_NEWGAME = 2
PACKET_GRAB_SHINE = 3
PACKET_DROP_SHINE = 4
PACKET_RESET_SHINE = 5
PACKET_SHOWTIME = 6
PACKET_MOVE_SHINE = 7
sPacketTable = {
    [PACKET_VICTORY] = on_packet_victory,
    [PACKET_NEWGAME] = on_packet_new_game,
    [PACKET_GRAB_SHINE] = on_packet_grab_shine,
    [PACKET_DROP_SHINE] = on_packet_drop_shine,
    [PACKET_RESET_SHINE] = on_packet_reset_shine,
    [PACKET_SHOWTIME] = on_packet_showtime,
    [PACKET_MOVE_SHINE] = on_packet_move_shine,
}
