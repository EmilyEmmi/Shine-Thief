-- name: \\#ff5a5a\\Kart Battles (v3.5)
-- description: Battle modes from the Mario Kart series, now in sm64coopdx!\n\nMod by EmilyEmmi\nAdditional programming by EmeraldLockdown and NeedleN64\n\nShine Dynos by Blocky\nMoon model byNinten501 on Models Resource\n\nSome graphics, models, and sounds created/provided by NeedleN64, viandegras, djoslin0, and LeoHaha\n\nSome music by LogoBro, PablosCorner\n\nMcDonalds by chillyzone\nArena by Agent X + others
-- incompatible: gamemode

gGlobalSyncTable.gameLevel = 0
gGlobalSyncTable.gameState = 0
gGlobalSyncTable.gameTimer = 0
gGlobalSyncTable.showTime = false
gGlobalSyncTable.winner = 0
gGlobalSyncTable.winner2 = 0
gGlobalSyncTable.winTime = 20 -- this changes depending on the amount of players (shine thief)
gGlobalSyncTable.spawnOffset = 0
gGlobalSyncTable.shineOwner1 = -1
gGlobalSyncTable.shineOwner2 = -1
gGlobalSyncTable.voteMap1 = 1
gGlobalSyncTable.voteMap2 = 2
gGlobalSyncTable.voteMap3 = 3
gGlobalSyncTable.voteExclude = 0
gGlobalSyncTable.wonMap = -1

-- settings
gGlobalSyncTable.gameMode = 0
gGlobalSyncTable.teamMode = 0
gGlobalSyncTable.variant = 0
gGlobalSyncTable.mapChoice = 0
gGlobalSyncTable.items = 1
gGlobalSyncTable.godMode = false
gGlobalSyncTable.bombSetting = 1
gGlobalSyncTable.startBalloons = 3
gGlobalSyncTable.maxGameTime = 3
gGlobalSyncTable.reduceObjects = false
gGlobalSyncTable.arenaStyleItems = false
map_blacklist = {}

gServerSettings.bubbleDeath = 0
gServerSettings.skipIntro = 1
gServerSettings.playerInteractions = PLAYER_INTERACTIONS_PVP
gServerSettings.stayInLevelAfterStar = 0

gLevelValues.fixCollisionBugs = true
gLevelValues.fixCollisionBugsFalseLedgeGrab = true
gLevelValues.fixCollisionBugsGroundPoundBonks = true
gLevelValues.fixCollisionBugsRoundedCorners = true
gLevelValues.fixCollisionBugsPickBestWall = true

E_MODEL_SHINE = smlua_model_util_get_id("shine_geo")
E_MODEL_MOON = smlua_model_util_get_id("moon_geo")
E_MODEL_ITEM_BOX = smlua_model_util_get_id("item_box_geo")
E_MODEL_COLOR_BOMB = smlua_model_util_get_id("color_bobomb_geo")
E_MODEL_BALLOON = smlua_model_util_get_id("balloon_geo")

MUSIC_ST_WIN = audio_stream_load("shine.mp3")
MUSIC_BB_WIN = audio_stream_load("battle_win.mp3")
MUSIC_BA_WIN = audio_stream_load("attack_win.mp3")
MUSIC_CR_WIN = audio_stream_load("coin_win.mp3")
MUSIC_MR_WIN = audio_stream_load("moon_win.mp3")
MUSIC_RR_WIN = audio_stream_load("renegade_win.mp3")
SOUND_SHINE_GRAB = audio_sample_load("grab.mp3")
-- replaced on join
SEQ_SHOWTIME = SEQ_LEVEL_KOOPA_ROAD
SEQ_WON = SEQ_LEVEL_INSIDE_CASTLE

specialDown = false
specialPressed = false
itemDown = false
itemPressed = false
A_JPAD = (U_JPAD | D_JPAD | L_JPAD | R_JPAD)
itemBindSelection = tonumber(mod_storage_load("iBind")) or 0
specialBindSelection = tonumber(mod_storage_load("sBind")) or 1
-- legacy support
if (mod_storage_load("altBinds") == "1") then
    mod_storage_remove("altBinds")
    itemBindSelection = 8
    specialBindSelection = 2
    mod_storage_save("iBind", "8")
    mod_storage_save("sBind", "2")
end
-- set later
SPECIAL_BUTTON = Y_BUTTON
SPECIAL_OVERRIDE_BUTTON = 0
ITEM_BUTTON = X_BUTTON
ITEM_OVERRIDE_BUTTON = 0

local cappyStealer = 0
local modAttacker = 0
local shineFrameCounter = 0
isHackNotCompatible = false
romHackName = "vanilla"
localWinner = 0
localWinner2 = -1
local renderItemExists = {}
firstBalloonExists = true
torsoTime = gMarioStates[0].marioBodyState.updateTorsoTime
local mostBalls = -1
local mostPoints = -1
local leastPoints = -1
local leastBalls = -1
local teamScores = {}
placementTable = {}
local myPlacement = MAX_PLAYERS
local desyncTimer = 0
local syncValidTimer = 0
local respawnTimer = 0
local afkTimer = 0
local afkSpectator = false

powBlockTimer = 0
powBlockOwner = 0
shuffleItem = 0
shuffleTimer = 0
newBalloonOwner = -1
refillBalloons = 6 - (gGlobalSyncTable.startBalloons or 3)
refillBalloonTimer = 0
coinsExist = 0
sneakingTimer = 0
lastCage = 0
local itemRainTimer = 0

-- team data
-- in order: light color, dark color, full name (+ color code), short name
TEAM_DATA = {
    { { r = 225, g = 5, b = 49 },       { r = 80, g = 20, b = 20 },       "\\#ff4040\\Red Team",    "Red" }, -- red (modified ruby)
    { { r = 0x00, g = 0x2f, b = 0xc8 }, { r = 20, g = 40, b = 80 },       "\\#4040ff\\Blue Team",   "Blu" }, -- blue (modified cobalt)
    { { r = 0x20, g = 0xc8, b = 0x20 }, { r = 20, g = 80, b = 20 },       "\\#40ff40\\Green Team",  "Grn" }, -- green (modified clover)
    { { r = 0xe7, g = 0xe7, b = 0x21 }, { r = 80, g = 80, b = 20 },       "\\#ffff40\\Yellow Team", "Ylw" }, -- yellow (modified busy bee)
    { { r = 0xff, g = 0x8a, b = 0x00 }, { r = 80, g = 50, b = 20 },       "\\#ffa014\\Orange Team", "Org" }, -- orange (modified... orange)
    { { r = 0x5a, g = 0x94, b = 0xff }, { r = 20, g = 50, b = 80 },       "\\#40ffff\\Cyan Team",   "Cyn" }, -- cyan (modified azure)
    { { r = 0xff, g = 0x8e, b = 0xb2 }, { r = 0x82, g = 0x10, b = 0x27 }, "\\#ffa1eb\\Pink Team",   "Pnk" }, -- pink (modified bubblegum)
    { { r = 0x71, g = 0x36, b = 0xc8 }, { r = 0x26, g = 0x26, b = 0x47 }, "\\#a040ff\\Violet Team", "Vlt" }, -- violet (modified waluigi)
}

-- starts a game (called in menu)
function new_game(msg)
    if not (network_is_server() or network_is_moderator()) then
        djui_chat_message_create("You lack the power, young one.")
        return true
    end

    local level = gGlobalSyncTable.gameLevel
    local redo = false
    if msg == "redo" then
        redo = true
    elseif msg and msg ~= "" then
        level = tonumber(msg) or msg
    end

    setup_level_data(level)
    if not (warp_to_level(thisLevel.level, thisLevel.area, thisLevel.act or 6) or warp_to_warpnode(thisLevel.level, thisLevel.area, thisLevel.act or 6, 0)) then
        djui_chat_message_create("This isn't a valid level.")
        setup_level_data(gGlobalSyncTable.gameLevel)
        return true
    else
        warp_to_level(4, 1, -1) -- cancel warp
    end

    --[[gGlobalSyncTable.gameLevel = level
    gGlobalSyncTable.gameTimer = 1
    gGlobalSyncTable.shineOwner1 = -1
    gGlobalSyncTable.shineOwner2 = -1]]

    --[[local playerCount = get_participant_count()

    gGlobalSyncTable.winTime = 36 -
        math.min(playerCount, 26) -- more time with less players (min 10s)
    if gGlobalSyncTable.teamMode ~= 0 then
        gGlobalSyncTable.winTime = gGlobalSyncTable.winTime + 40 // gGlobalSyncTable.teamMode -- more time with less teams
    end

    gGlobalSyncTable.spawnOffset = math.random(0, MAX_PLAYERS - 1)]]

    network_send_include_self(true, {
        id = PACKET_NEWGAME,
        teams = gGlobalSyncTable.teamMode,
        level = level,
        mode = gGlobalSyncTable.gameMode,
        variant = gGlobalSyncTable.variant,
        redo = redo,
    })
    return true
end

--hook_chat_command("newgame","TEST",new_game)

-- desync fix command
function desync_fix_command(msg)
    if not (network_is_server() or network_is_moderator()) then
        djui_chat_message_create("You lack the power, young one.")
        return true
    end

    djui_chat_message_create("Attempting desync fix...")
    if network_is_server() then
        on_packet_fix_desync({ global = true })
        return true
    end
    network_send(true, {
        id = PACKET_FIX_DESYNC,
        global = true,
    })
    return true
end

hook_chat_command("desync", "- Attempt to fix desync issues", desync_fix_command)

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
        if gMarioStates[0].action == ACT_CAPTURED then
            set_mario_action(gMarioStates[0], ACT_IDLE, 0)
            go_to_mario_start(0, gNetworkPlayers[0].globalIndex, true)
        end
        shuffleItem = 0
        sMario.item = 0
        sMario.itemUses = 0
        sMario.boostTime = 0
        sMario.specialCooldown = 0
        sMario.mushroomTime = 0
        sMario.star = false
        sMario.bulletTimer = 0
        sMario.smallTimer = 0
        gMarioStates[0].capTimer = 0
        stop_cap_music()
        if gGlobalSyncTable.gameState ~= 3 then
            if gGlobalSyncTable.gameMode == 1 then
                sMario.balloons = 0
                if sMario.eliminated == 0 then
                    sMario.eliminated = 1
                end
                --sMario.isBomb = false
            elseif gGlobalSyncTable.gameMode == 2 then
                sMario.points = 0
                sMario.balloons = 0
            elseif gGlobalSyncTable.gameMode == 4 then
                handle_hit(0, 4)
                if sMario.eliminated == 0 and sMario.team == 1 then
                    sMario.eliminated = 1
                end
            elseif gGlobalSyncTable.gameMode == 5 then
                set_eliminated(0)
                handle_hit(0, 4)
            else
                handle_hit(0, 4)
            end
        end
        djui_chat_message_create("Entered Spectator Mode.")
        return
    end

    if gGlobalSyncTable.gameState ~= 2 then
        sMario.eliminated = 0
        sMario.isBomb = false
    end

    if sMario.eliminated == 0 then
        sMario.balloons = gGlobalSyncTable.startBalloons or 3
        refillBalloons = 6 - (gGlobalSyncTable.startBalloons or 3)
        gMarioStates[0].flags = gMarioStates[0].flags & ~(MARIO_WING_CAP | MARIO_VANISH_CAP)
        go_to_mario_start(0, gNetworkPlayers[0].globalIndex, true)
        if gGlobalSyncTable.gameState ~= 3 and sMario.team == 0 and gGlobalSyncTable.teamMode ~= 0 then
            sMario.team = calculate_lowest_member_team()
        end
        -- if we become a renegade, get captured
        if gGlobalSyncTable.gameMode == 4 and gGlobalSyncTable.gameState == 2 and sMario.team == 1 then
            handle_hit(0, 4)
        end
    elseif sMario.isBomb then
        go_to_mario_start(0, gNetworkPlayers[0].globalIndex, true)
    end
    djui_chat_message_create("No longer spectating.")
    afkTimer = 0
end

-- Various movement tweaks
--- @param m MarioState
function before_phys_step(m, stepType)
    if m.action == ACT_SHOT_FROM_CANNON then return end

    local sMario = gPlayerSyncTable[m.playerIndex]
    local ownedShine = get_player_owned_shine(m.playerIndex)

    local speed_cap = 35
    local use_speed_cap = (ownedShine ~= 0)

    if (m.action & ACT_FLAG_SWIMMING) ~= 0 then speed_cap = 20 end
    if using_omm_moveset(m.playerIndex) then speed_cap = speed_cap + 15 end        -- speed cap is greater for OMM
    if (m.action & ACT_FLAG_RIDING_SHELL) ~= 0 then speed_cap = speed_cap + 10 end -- other players can travel at >60 speed

    local doBoost = false
    -- boost variant
    if (sMario.boostTime and sMario.boostTime ~= 0) then
        if (m.action & (ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE)) == 0 and m.action ~= ACT_FLYING then
            speed_cap = speed_cap + 15

            if ownedShine == 0 then speed_cap = speed_cap + 15 end -- boost is worse for shine player
            doBoost = true
        end
    end
    -- mushroom (similar to boost)
    if (sMario.mushroomTime and sMario.mushroomTime ~= 0) then
        if (m.action & (ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE)) == 0 and m.action ~= ACT_FLYING then
            speed_cap = speed_cap + 15

            if ownedShine == 0 then speed_cap = speed_cap + 15 end -- boost is worse for shine player
            doBoost = true
        end
    end
    -- allows for stacking
    if doBoost then
        local intendedDYaw = limit_angle(m.intendedYaw - m.faceAngle.y)
        local intendedMag = m.intendedMag / 32
        m.forwardVel = m.forwardVel + intendedMag * coss(intendedDYaw) * 3
        if m.forwardVel > speed_cap then
            m.forwardVel = speed_cap
        elseif m.forwardVel < -20 then
            m.forwardVel = -20
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

        if m.actionState == 0 and m.floor.type == SURFACE_VERTICAL_WIND and m.vel.y < 20 and m.pos.y < -1000 then
            m.vel.y = 20 -- initial vertical boost
        end
    end

    if m.action == ACT_FLYING then
        speed_cap = 80
        local speed_min = 50

        if (ownedShine ~= 0 or (gGlobalSyncTable.gameMode == 4 and sMario.team == 1)) then
            speed_cap = speed_min
            speed_min = speed_min - 30
            if m.forwardVel > speed_cap then
                m.forwardVel = math.max(m.forwardVel - 4, speed_cap)
            end
        end

        if gGlobalSyncTable.variant == 1 and gGlobalSyncTable.gameMode == 3 and sMario.points and sMario.points ~= 0 then -- greed variant
            speed_cap = math.max(10, speed_cap - sMario.points)
            speed_min = math.min(speed_min, speed_cap)
            if m.forwardVel > speed_cap then
                m.forwardVel = math.max(m.forwardVel - 4, speed_cap)
            end
        end

        if (m.pos.y - math.max(256, m.floorHeight) > 3000) or (m.ceilHeight - 181 - m.vel.y <= m.pos.y) or (thisLevel and thisLevel.maxHeight and thisLevel.maxHeight - 181 - m.vel.y <= m.pos.y) then
            speed_min = 0
            speed_cap = 30
        else
            if sMario.boostTime ~= 0 then
                speed_min = speed_min + 20
                if m.forwardVel < speed_cap then
                    m.forwardVel = math.min(m.forwardVel + 3, speed_cap)
                end
            end
            if sMario.mushroomTime ~= 0 then
                speed_min = speed_min + 20
                if m.forwardVel < speed_cap then
                    m.forwardVel = math.min(m.forwardVel + 3, speed_cap)
                end
            end
        end

        if m.forwardVel < speed_min then
            m.forwardVel = math.min(m.forwardVel + 2, speed_min)
        end
        return
    elseif gGlobalSyncTable.variant == 1 and gGlobalSyncTable.gameMode == 3 and sMario.points and sMario.points ~= 0 then -- greed variant
        use_speed_cap = true
        speed_cap = math.max(10, speed_cap - sMario.points + 15)
    end

    if m.action == ACT_WATER_SHELL_SWIMMING then
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
            m.forwardVel = speed_cap                       -- as fast as player with shine can swim
        end
    elseif use_speed_cap and m.forwardVel > speed_cap then -- the player with the shine is slowed
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

    if m.floor then
        if m.floor.type == SURFACE_HORIZONTAL_WIND then -- no floor wind
            m.floor.type = SURFACE_DEFAULT
        elseif thisLevel and thisLevel.noSlide and m.area.terrainType ~= TERRAIN_SLIDE and (m.floor.type == SURFACE_DEFAULT or m.floor.type == SURFACE_HARD) then -- disable slide option
            m.floor.type = (m.floor.type == SURFACE_HARD and SURFACE_HARD_NOT_SLIPPERY) or SURFACE_NOT_SLIPPERY
        end
    end
    -- move when hanging
    if m.action == ACT_START_HANGING and m.input & INPUT_NONZERO_ANALOG ~= 0 then
        set_mario_action(m, ACT_HANG_MOVING, 0)
    end
    -- ground pound out of cannon action
    if m.action == ACT_SHOT_FROM_CANNON and m.controller.buttonPressed & Z_TRIG ~= 0 then
        if m.playerIndex == 0 then
            set_camera_mode(m.area.camera, m.area.camera.defMode, 0)
        end
        set_mario_action(m, ACT_GROUND_POUND, 0)
    end

    local sMario = gPlayerSyncTable[m.playerIndex]
    local np = gNetworkPlayers[m.playerIndex]
    local ownedShine = get_player_owned_shine(m.playerIndex)

    if m.playerIndex == 0 and gGlobalSyncTable.gameState == 3 and m.action ~= ACT_GAME_WIN and m.action ~= ACT_GAME_LOSE then
        drop_queued_background_music()
        fadeout_level_music(1)
        set_dance_action()
    end

    -- cancel double shine if there aren't enough players
    if m.playerIndex == 0 and network_is_server() and gGlobalSyncTable.gameMode == 0 and gGlobalSyncTable.variant == 1 and gGlobalSyncTable.gameState == 2 and get_participant_count() < 3 then
        gGlobalSyncTable.variant = 0
        new_game("redo")
        djui_popup_create_global("Not enough players for Double Shine!", 2)
    end

    -- drop the shine if we take damage or enter a painting
    if (m.hurtCounter > 0 or cappyStealer ~= 0 or modAttacker ~= 0) and m.playerIndex == 0 then
        -- drop item if the attack is powerful (needs to be stronger than pvp because lava is 12)
        if m.hurtCounter >= 15 then
            drop_item()
        end

        if modAttacker ~= 0 then
            handle_hit(0, 0, modAttacker)
            modAttacker = 0
        elseif cappyStealer == 0 then
            handle_hit(0, 0)
        else
            handle_hit(0, 3, cappyStealer)
            cappyStealer = 0
        end
        m.hurtCounter = 0
    end

    -- reduced invinc frames in renegade roundup
    if gGlobalSyncTable.gameMode == 4 and m.invincTimer ~= 0 and m.invincTimer <= 30 then m.invincTimer = 0 end

    -- for underground lake and wiggler's cave
    if m.playerIndex == 0 and thisLevel then
        torsoTime = math.max(gMarioStates[0].marioBodyState.updateTorsoTime, torsoTime + 1)

        if thisLevel.room and m.currentRoom and m.currentRoom ~= 0 and (not (m.floor and m.floor.object)) and not thisLevel.room[m.currentRoom] then
            print("Room mismatch", m.currentRoom, thisLevel.room)
            --log_to_console(tostring(m.currentRoom))
            on_death(m)
        elseif thisLevel.maxHeight and m.pos.y > thisLevel.maxHeight then
            --print("Height limit", m.pos.y, thisLevel.maxHeight)
            m.pos.y = thisLevel.maxHeight
            if m.vel.y > 0 and m.action & ACT_FLAG_SWIMMING_OR_FLYING == 0 then
                m.vel.y = 0
                set_mario_particle_flags(m, PARTICLE_HORIZONTAL_STAR, 0)
                play_character_sound(m, CHAR_SOUND_DOH)
            end
        end
    end

    -- better ceiling hang
    if m.ceil and m.ceil.type & SURFACE_HANGABLE ~= 0 and m.vel.y > 0 and m.ceilHeight - 181 - m.vel.y <= m.pos.y and m.controller.buttonDown & A_BUTTON ~= 0 and m.action & ACT_FLAG_AIR ~= 0 then
        if m.playerIndex == 0 then
            set_camera_mode(m.area.camera, CAMERA_MODE_FREE_ROAM, 1)
        end
        m.faceAngle.x = 0
        m.faceAngle.z = 0
        set_mario_action(m, ACT_START_HANGING, 0)
    end

    -- prevent instant death upon spawning
    if (not (thisLevel and thisLevel.noFlySpawn)) and m.action == ACT_SPAWN_SPIN_AIRBORNE and m.floor and (is_hazard_floor(m.floor.type) or mario_floor_is_slippery(m) ~= 0) then
        if gGlobalSyncTable.gameState == 1 then
            m.vel.y = 0
        else
            m.flags = m.flags | MARIO_WING_CAP
            m.capTimer = 60 -- 2 seconds
            set_mario_action(m, ACT_FLYING_TRIPLE_JUMP, 1)
            m.vel.y = 80
        end
    elseif m.action == ACT_TRIPLE_JUMP and m.actionArg == 1 then
        m.faceAngle.y = approach_s16_symmetric(m.faceAngle.y, m.intendedYaw, 0x1000)
    end

    -- quick respawn
    if m.playerIndex == 0 and quickRespawn and gGlobalSyncTable.gameState ~= 3 then
        if get_player_owned_shine(0) == 0 and (m.floor == nil or m.floor.type == SURFACE_DEATH_PLANE or m.floor.type == SURFACE_VERTICAL_WIND) and m.vel.y < -10 and m.action & ACT_FLAG_INVULNERABLE ~= 0 then
            respawnTimer = respawnTimer + 1
            if respawnTimer >= 20 then
                on_pause_exit(false)
                respawnTimer = 0
            end
        else
            respawnTimer = 0
        end
    end

    -- afk timer
    if m.playerIndex == 0 and gGlobalSyncTable.gameState == 2 and (not DEBUG_MODE) and sMario.eliminated == 0 then
        if m.input & INPUT_NONZERO_ANALOG == 0 and m.controller.buttonDown == 0 then
            afkTimer = afkTimer + 1
            if m.action & ACT_FLAG_INVULNERABLE ~= 0 then
                afkTimer = afkTimer + 9 -- 10 times faster in hit actions
            end
            if afkTimer >= 1800 and not sMario.spectator then
                spectator_mode()
                afkTimer = 0
                afkSpectator = true
                djui_chat_message_create("AFK: Move to disable spectator mode")
            end
        else
            afkTimer = 0
            if sMario.spectator and afkSpectator then
                spectator_mode()
                afkSpectator = false
            end
        end
    end

    -- kill player ourselves before the actual death can (for oob and OMM)
    if m.floor == nil or (m.pos.y - m.floorHeight <= 2048 and (m.floor.type == SURFACE_DEATH_PLANE or m.floor.type == SURFACE_VERTICAL_WIND)) then
        on_death(m)
    end

    if sMario.points == nil then sMario.points = 0 end
    if sMario.balloons == nil then sMario.balloons = gGlobalSyncTable.startBalloons or 3 end

    -- set player colors + desc
    if djui_attempting_to_open_playerlist() then
        if gGlobalSyncTable.gameMode == 4 then
            network_player_set_override_location(np, "...")
        else
            network_player_set_override_location(np, remove_color(placeString(get_placement(m.playerIndex))))
        end
    end
    if sMario.spectator then
        network_player_set_description(np, "Spectator", 128, 128, 128, 255)
    elseif gGlobalSyncTable.gameMode ~= 4 and sMario.eliminated and sMario.eliminated ~= 0 and not sMario.isBomb then
        network_player_set_description(np, "Lost", 255, 30, 30, 255)
    else
        local desc = ""
        local highlight = false
        local extra
        local color = { r = 255, g = 64, b = 64, a = 255 } -- red
        if sMario.isBomb then
            desc = "Bomb"
        elseif gGlobalSyncTable.gameMode == 0 then
            desc = tostring(get_point_amount(m.playerIndex))
            if ownedShine ~= 0 then
                highlight = true
            end
        elseif gGlobalSyncTable.gameMode == 1 then
            desc = tostring(sMario.balloons)
            if has_most_balloons(m.playerIndex) then
                highlight = true
            end
        elseif gGlobalSyncTable.gameMode == 5 then
            desc = tostring(get_point_amount(m.playerIndex))
            if not has_least_points(m.playerIndex) then
                highlight = true
            end
        elseif gGlobalSyncTable.gameMode ~= 4 then
            desc = tostring(get_point_amount(m.playerIndex))
            if has_most_points(m.playerIndex) then
                highlight = true
            end
        elseif sMario.team == 2 then
            desc = "Law"
            highlight = true
        elseif sMario.eliminated ~= 0 then
            desc = "Captured"
        else
            desc = "Renegade"
            highlight = true
        end

        if sMario.team and sMario.team ~= 0 and TEAM_DATA[sMario.team] then
            if gGlobalSyncTable.gameMode ~= 4 then
                set_override_team_colors(np, TEAM_DATA[sMario.team][1], TEAM_DATA[sMario.team][2])
                extra = TEAM_DATA[sMario.team][4]
            else
                network_player_reset_override_palette_custom(np)
                if sMario.team == 2 then
                    m.marioBodyState.modelState = m.marioBodyState.modelState | MODEL_STATE_METAL
                end
            end
            local lightColor = TEAM_DATA[sMario.team][1]
            color = { r = lightColor.r, g = lightColor.g, b = lightColor.b, a = 255 }
            if not highlight then color.a = 100 end
        elseif sMario.isBomb then
            network_player_reset_override_palette_custom(np)
            color = { r = 128, g = 64, b = 64, a = 255 } -- faint red
        else
            network_player_reset_override_palette_custom(np)
            if highlight then
                color = { r = 255, g = 255, b = 64, a = 255 } -- yellow
            end
        end

        -- set player descriptions
        if extra then
            network_player_set_description(np, extra .. ": " .. desc, color.r, color.g, color.b,
                color.a)
        else
            network_player_set_description(np, desc, color.r, color.g, color.b, color.a)
        end
    end

    -- handle holding shine
    if ownedShine ~= 0 then
        if m.invincTimer ~= 0 then m.invincTimer = m.invincTimer - 1 end

        if gGlobalSyncTable.variant ~= 1 then
            if m.playerIndex == 0 and sMario.points <= gGlobalSyncTable.winTime then
                shineFrameCounter = shineFrameCounter + 1
                if gGlobalSyncTable.showTime then
                    shineFrameCounter = shineFrameCounter + 1
                end
                if gGlobalSyncTable.gameState == 2 then
                    if shineFrameCounter >= 60 or (shineFrameCounter >= 30 and sMario.points < gGlobalSyncTable.winTime - 3) then -- it's 2 seconds per second near the end
                        sMario.points = sMario.points +
                            1                                                                                                     -- increment timer
                        shineFrameCounter = 0
                    end
                    if sMario.points > gGlobalSyncTable.winTime then -- victory
                        sMario.points = gGlobalSyncTable.winTime
                        network_send_include_self(true, {
                            id = PACKET_VICTORY,
                            winner = np.globalIndex,
                            winner2 = -1,
                        })
                        play_sound(SOUND_MENU_STAR_SOUND, gGlobalSoundSource)
                    end
                end
            end
        else -- double shine works a bit different
            local mySMario = gPlayerSyncTable[0]
            if m.playerIndex ~= 0 and get_player_owned_shine(0) ~= 0 and mySMario.points <= gGlobalSyncTable.winTime then
                shineFrameCounter = shineFrameCounter + 1
                if gGlobalSyncTable.showTime then
                    shineFrameCounter = shineFrameCounter + 1
                end
                if gGlobalSyncTable.gameState == 2 then
                    if shineFrameCounter >= 60 or (shineFrameCounter >= 30 and sMario.points < gGlobalSyncTable.winTime - 3) then -- it's 2 seconds per second near the end
                        mySMario.points = mySMario.points +
                            1                                                                                                     -- increment timer
                        shineFrameCounter = 0
                    end
                    if mySMario.points > gGlobalSyncTable.winTime then -- victory
                        mySMario.points = gGlobalSyncTable.winTime
                        network_send_include_self(true, {
                            id = PACKET_VICTORY,
                            winner = get_shine_owner(1) or gNetworkPlayers[0].globalIndex,
                            winner2 = get_shine_owner(2),
                        })
                        play_sound(SOUND_MENU_STAR_SOUND, gGlobalSoundSource)
                    end
                end
            end
        end

        if m.playerIndex ~= 0 then
            local mySMario = gPlayerSyncTable[0]
            -- update team shine timer
            if get_player_owned_shine(0) ~= 0 and ownedShine ~= 0 then
                if math.abs(mySMario.points - sMario.points) > 1 then
                    -- average the time
                    local avg = (mySMario.points + sMario.points) // 2
                    mySMario.points = avg
                    sMario.points = avg
                    shineFrameCounter = 0
                elseif mySMario.points < sMario.points then
                    mySMario.points = sMario.points
                    shineFrameCounter = 0
                end
            elseif mySMario.team ~= 0 and mySMario.team == sMario.team then
                if mySMario.points < sMario.points and sMario.points <= gGlobalSyncTable.winTime - 5 then
                    mySMario.points = sMario.points
                    shineFrameCounter = 0
                end
            end
        end

        set_mario_particle_flags(m, PARTICLE_SPARKLES, 0) -- sparkle if we have shine
    elseif m.playerIndex == 0 and gGlobalSyncTable.gameMode == 0 then
        shineFrameCounter = 0
        if sMario.points > gGlobalSyncTable.winTime - 5 then
            sMario.points = gGlobalSyncTable.winTime - 5 -- always have '5' seconds left (actually more)
        end
    end

    -- mini effect
    if sMario.smallTimer and sMario.smallTimer ~= 0 then
        local marioScale = 1
        if m.bounceSquishTimer < 9 then
            m.bounceSquishTimer = m.bounceSquishTimer + 2
            marioScale = 1 - (m.bounceSquishTimer / 20)
        else
            marioScale = 0.5
            m.bounceSquishTimer = 10
        end
        cur_obj_scale(marioScale)
        m.marioObj.hitboxHeight = 37 * marioScale
        m.marioObj.hitboxRadius = 160 * marioScale
        m.squishTimer = math.max(m.squishTimer, 1)
        if m.playerIndex == 0 then
            sMario.smallTimer = sMario.smallTimer - 1
            if sMario.smallTimer == 0 then
                play_sound(SOUND_MENU_EXIT_PIPE, gGlobalSoundSource)
            end
        end
    end

    -- star effect
    if sMario.star then
        if m.playerIndex == 0 and m.capTimer == 0 then
            sMario.star = false
        end
        local r, g, b = hue_shift_over_time(m.marioObj.oTimer, 60)
        m.marioBodyState.shadeR = r
        m.marioBodyState.shadeG = g
        m.marioBodyState.shadeB = b
        set_mario_particle_flags(m, ACTIVE_PARTICLE_SPARKLES, 0)
        -- metal doesn't show shading, so change the metal color
        if m.marioBodyState.modelState & MODEL_STATE_METAL ~= 0 then
            network_player_set_override_palette_color(np, METAL, { r = r, g = g, b = b })
        end
    else
        m.marioBodyState.shadeR = 127
        m.marioBodyState.shadeG = 127
        m.marioBodyState.shadeB = 127
    end

    -- item shuffle effect, rr timer
    if m.playerIndex == 0 then
        if shuffleItem ~= 0 then
            shuffleTimer = shuffleTimer + 1
            if shuffleTimer > 60 then
                sMario.item = shuffleItem
                sMario.itemUses = 0
                shuffleItem = 0
            end
        else
            shuffleTimer = 0
        end

        if gGlobalSyncTable.gameMode == 4 and gGlobalSyncTable.gameState == 2 and sMario.team == 1 and (not is_dead(0)) and sneakingTimer < 900 then
            sneakingTimer = sneakingTimer + 1
            if sneakingTimer == 900 then
                djui_popup_create("Your location was revealed because you haven't been seen in a while.", 2)
                sMario.showOnMap = -1
            end
        end
    end

    -- render item
    if is_player_active(m) ~= 0 and ((sMario.item and sMario.item ~= 0) or sMario.bulletTimer ~= 0 or sMario.isBomb) and not renderItemExists[m.playerIndex] then
        local o = spawn_non_sync_object(id_bhvHeldItem, E_MODEL_NONE, m.pos.x, m.pos.y, m.pos.z, nil)
        renderItemExists[m.playerIndex] = 1
        o.globalPlayerIndex = np.globalIndex
        o.hookRender = m.playerIndex + 1 -- plus one so it's non-zero
    end

    -- first balloon
    if (not gGlobalSyncTable.reduceObjects) and m.playerIndex == 0 and m.area.localAreaTimer > 20 and (np.currAreaSyncValid and np.currLevelSyncValid) and didFirstJoinStuff and gGlobalSyncTable.gameMode > 0 and gGlobalSyncTable.gameMode < 3 then
        if sMario.balloons ~= 0 and not firstBalloonExists then
            newBalloonOwner = -1
            local behParams = (np.globalIndex << 8) + 1
            local o = obj_get_first_with_behavior_id_and_field_s32(id_bhvBalloon, 0x40, behParams)
            if not o then
                play_sound(SOUND_MENU_YOSHI_GAIN_LIVES, gGlobalSoundSource)
                o = spawn_sync_object(id_bhvBalloon,
                    E_MODEL_BALLOON,
                    m.pos.x, m.pos.y + 80, m.pos.z,
                    function(o)
                        o.oObjectOwner = np.globalIndex + 1 -- plus one for bug reasons
                        o.oBalloonAppearance = np.globalIndex
                        o.oBalloonNumber = 1
                        o.oBehParams = behParams
                    end)
            end
            if o then
                firstBalloonExists = true
            end
        end
    end

    -- bullet bill
    if sMario.bulletTimer and sMario.bulletTimer ~= 0 then
        m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
        set_mario_particle_flags(m, ACTIVE_PARTICLE_DUST, 0)
        if m.playerIndex == 0 then
            sMario.bulletTimer = sMario.bulletTimer - 1

            if m.action & ACT_FLAG_SWIMMING ~= 0 or m.action & ACT_FLAG_SWIMMING_OR_FLYING == 0 then
                m.flags = m.flags & ~MARIO_WING_CAP
                sMario.bulletTimer = 0
            elseif m.controller.buttonPressed & B_BUTTON ~= 0 then
                sMario.bulletTimer = 0
            end

            if sMario.bulletTimer == 0 then
                spawn_sync_object(id_bhvThrownBobomb,
                    E_MODEL_NONE,
                    m.pos.x, m.pos.y, m.pos.z,
                    function(o)
                        o.oForwardVel = 0
                        o.oVelY = -20
                        o.oObjectOwner = np.globalIndex
                        o.oInteractStatus = INT_STATUS_TOUCHED_BOB_OMB
                    end)
                if gGlobalSyncTable.variant ~= 2 and gGlobalSyncTable.variant ~= 7 then
                    m.flags = m.flags & ~MARIO_WING_CAP
                end
            end
        end
    end

    -- items and shine/balloon passing
    if m.playerIndex == 0 and m.action & ACT_FLAG_INVULNERABLE == 0 and gGlobalSyncTable.gameState ~= 3 and (sMario.item ~= 0 or (gGlobalSyncTable.teamMode ~= 0 and shuffleItem == 0)) then
        local throwDir = throw_direction()
        if throwDir ~= 4 then
            if sMario.item and sMario.item ~= 0 then
                sMario.item, sMario.itemUses = use_item(sMario.item, throwDir, sMario.itemUses)
            else -- pass shine/balloons
                handle_hit(0, 2)
            end
        end
    end

    -- pow block effect
    if m.playerIndex == 0 and powBlockTimer ~= 0 then
        powBlockTimer = powBlockTimer - 1
        if powBlockTimer % 30 == 0 then
            if powBlockTimer ~= 0 then
                set_camera_shake_from_hit(SHAKE_SMALL_DAMAGE)
            else
                local index = network_local_index_from_global(powBlockOwner) or 0
                local otherTeam = gPlayerSyncTable[index].team or 0
                set_camera_shake_from_hit(SHAKE_LARGE_DAMAGE)
                if index ~= 0 and (otherTeam == 0 or sMario.team ~= otherTeam) and m.action & ACT_FLAG_AIR == 0 and not (is_invincible(0) or is_spectator(0)) then
                    local m2 = gMarioStates[index]
                    m2.marioObj.oDamageOrCoinValue = 4
                    m.interactObj = m2.marioObj
                    if take_damage_and_knock_back(m, m2.marioObj) ~= 0 then
                        on_pvp_attack(m2, m, 0, false, true)
                    end
                end
            end
            play_sound(SOUND_GENERAL_BIG_POUND, gGlobalSoundSource)
        end
    end

    -- spectator mode
    if is_spectator(m.playerIndex) then
        m.flags = m.flags | MARIO_WING_CAP | MARIO_VANISH_CAP
        goto BOOST
    elseif gGlobalSyncTable.gameMode == 4 and gGlobalSyncTable.gameState ~= 3 and is_dead(m.playerIndex) then
        m.flags = m.flags | MARIO_VANISH_CAP
        if m.action ~= ACT_CAPTURED then
            set_mario_action(m, ACT_CAPTURED, 0)
        end
        goto BOOST
    end

    -- bomb model
    if sMario.isBomb and gGlobalSyncTable.gameState == 2 then
        m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
        if m.heldObj then
            local o = m.heldObj
            mario_drop_held_object(m)
            o.oPosX = m.pos.x
            o.oPosY = m.pos.y
            o.oPosZ = m.pos.z
            if m.action ~= ACT_DIVE then
                force_idle_state(m)
            end
        end
    end

    -- blowout variant (balloon battle/attack)
    if m.playerIndex == 0 and (sMario.eliminated == 0) and gGlobalSyncTable.variant == 1 and gGlobalSyncTable.gameState == 2
        and gGlobalSyncTable.gameMode > 0 and gGlobalSyncTable.gameMode < 3 and refillBalloons > 0 and sMario.balloons < 5 then
        local filling = false
        if m.action & ACT_FLAG_AIR == 0 and special_down(m) then
            m.freeze = 2
            if m.action & ACT_FLAG_MOVING == 0 then
                play_sound(SOUND_AIR_BLOW_WIND, gGlobalSoundSource)
                refillBalloonTimer = refillBalloonTimer + 1
                filling = true
                if refillBalloonTimer > 90 then
                    sMario.balloons = sMario.balloons + 1
                    refillBalloons = refillBalloons - 1
                    refillBalloonTimer = 0
                end
            end
        end
        if (not filling) and refillBalloonTimer ~= 0 then
            refillBalloonTimer = math.max(0, refillBalloonTimer - 2)
        end
    end

    -- wing cap variant
    if gGlobalSyncTable.variant == 2 or gGlobalSyncTable.variant == 7 then
        m.flags = m.flags | MARIO_WING_CAP
    end

    -- shell rush variant
    if m.riddenObj and m.riddenObj.heldByPlayerIndex ~= m.playerIndex then
        m.riddenObj.heldByPlayerIndex = m.playerIndex
    end
    if m.playerIndex == 0 and gGlobalSyncTable.variant == 3 and gGlobalSyncTable.gameState ~= 3 and special_pressed(m) and m.action & (ACT_GROUP_CUTSCENE | ACT_FLAG_INVULNERABLE) == 0 and not m.heldObj then
        shell_rush_shell(m)
    end
    if m.playerIndex == 0 and m.action == ACT_RIDING_SHELL_GROUND and m.floor and m.floor.type == SURFACE_BURNING and thisLevel.badLava then
        on_death(m)
    end
    if m.playerIndex == 0 and m.riddenObj and (m.action & ACT_FLAG_RIDING_SHELL) == 0 then
        m.riddenObj.activeFlags = ACTIVE_FLAG_DEACTIVATED -- prevent hyper speed
        m.riddenObj = nil
    end

    if (m.action & ACT_FLAG_AIR) ~= 0 and m.action ~= ACT_TWIRLING and m.action ~= ACT_SHOT_FROM_CANNON then
        if gGlobalSyncTable.variant == 4 then -- moon gravity variant
            if m.vel.y < -25 then
                if m.controller.buttonDown & Z_TRIG == 0 then
                    m.vel.y = -25
                elseif m.vel.y < -50 then
                    m.vel.y = -50
                end
            elseif m.vel.y ~= 0 then
                m.vel.y = m.vel.y + 1
            end
        elseif gGlobalSyncTable.variant == 1 and gGlobalSyncTable.gameMode == 3 and sMario.points then -- greed variant (vertical)
            if m.vel.y > 20 then
                m.vel.y = m.vel.y - math.min(5, sMario.points // 10)
            end
        end
    end

    if m.playerIndex == 0 and (m.action & (ACT_GROUP_CUTSCENE | ACT_FLAG_INVULNERABLE) == 0) and gGlobalSyncTable.gameState ~= 3 and sMario.specialCooldown == 0 and (special_pressed(m) or (gGlobalSyncTable.variant == 9 and m.action & ACT_FLAG_AIR ~= 0 and m.controller.buttonPressed & A_BUTTON ~= 0 and m.vel.y < 15 and not using_omm_moveset(0))) then
        if (not sMario.isBomb) then
            if gGlobalSyncTable.variant == 6 then -- bombs variant
                local throwDir = throw_direction(true)
                if throwDir == 5 then throwDir = 1 end
                throw_bomb(m, throwDir)
                sMario.specialCooldown = 15
            elseif gGlobalSyncTable.variant == 8 then -- fire power variant
                local throwDir = throw_direction(true)
                if throwDir == 5 then throwDir = 1 end
                throw_fireball(m, throwDir)
                sMario.specialCooldown = 15
            elseif gGlobalSyncTable.variant == 11 then -- boomerang variant
                local throwDir = throw_direction(true)
                if throwDir == 5 then throwDir = 1 end
                throw_boomerang(m, throwDir, -1)
                sMario.specialCooldown = 400
            end
            if gGlobalSyncTable.variant == 10 then -- star variant
                m.capTimer = 300                   -- 10 seconds
                gPlayerSyncTable[0].star = true
                play_sound(SOUND_GENERAL_SHORT_STAR, gGlobalSoundSource)
                play_cap_music(SEQ_EVENT_POWERUP)
                play_character_sound(m, CHAR_SOUND_HERE_WE_GO)
                if m.action == ACT_LAVA_BOOST then
                    set_mario_action(m, ACT_FREEFALL, 0)
                end
                sMario.specialCooldown = 900 -- 30 seconds
            end
        end
        if gGlobalSyncTable.variant == 9 then -- feather variant
            if m.action & ACT_FLAG_SWIMMING == 0 then
                m.vel.y = 69                  -- triple jump height
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
                sMario.specialCooldown = 900 -- 30 seconds (but also when hitting the ground)
            end
        end
    end

    if m.playerIndex == 0 and gGlobalSyncTable.variant == 9 and m.action & ACT_FLAG_AIR == 0 then -- feather variant
        sMario.specialCooldown = 0
    end

    ::BOOST::
    -- used for bombs, boost, etc.
    if m.playerIndex == 0 and sMario.specialCooldown and sMario.specialCooldown > 0 then
        sMario.specialCooldown = sMario.specialCooldown - 1
    end
    -- renegade show on map timer
    if m.playerIndex == 0 and sMario.showOnMap and sMario.showOnMap > 0 then
        sMario.showOnMap = sMario.showOnMap - 1
    end

    -- boost variant
    if (gGlobalSyncTable.variant == 5 or gGlobalSyncTable.variant == 7 or is_spectator(m.playerIndex)) and sMario.boostTime then
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
    -- mushroom effect
    if sMario.mushroomTime and sMario.mushroomTime ~= 0 then
        set_mario_particle_flags(m, ACTIVE_PARTICLE_SPARKLES, 0)
        if m.playerIndex == 0 then
            sMario.mushroomTime = sMario.mushroomTime - 1
        end
    end

    -- item rain variant
    if m.playerIndex == 0 and network_is_server() then
        if gGlobalSyncTable.variant == 12 and gGlobalSyncTable.gameState ~= 3 then
            itemRainTimer = itemRainTimer + 1
            if itemRainTimer >= 30 then
                itemRainTimer = 0
                local dropItem = random_item(-1, true)
                local data = item_data[dropItem]
                local toSpawn = id_bhvDroppedItem
                local model = data.arenaModel or data.model
                if data.drop then
                    toSpawn = data.drop
                    if toSpawn == 0 then toSpawn = id_bhvThrownBobomb end
                    despawn = false
                end
                spawn_sync_object(toSpawn, model, m.pos.x, m.pos.y + 80, m.pos.z, function(o)
                    random_valid_pos(m.pos.y + 5000, o)
                    o.oForwardVel = 0
                    o.oMoveAngleYaw = math.random(0, 0xFFFF)
                    o.oFaceAngleYaw = o.oMoveAngleYaw
                    o.oObjectOwner = -1
                    o.oBalloonNumber = 0
                    o.oBalloonAppearance = dropItem
                end)
            end
        else
            itemRainTimer = 0
        end
    end

    if m.playerIndex == 0 and network_is_server() and gGlobalSyncTable.mapChoice ~= 0 and (gGlobalSyncTable.gameState == 0 or showGameResults) then -- auto game
        if (not DEBUG_SCORES) and get_participant_count() < 2 then
            if gGlobalSyncTable.mapChoice == 1 then
                gGlobalSyncTable.gameTimer = 630 -- 21 seconds
            else
                gGlobalSyncTable.gameTimer = 330 -- 11 seconds
            end
        elseif gGlobalSyncTable.gameTimer > 0 then
            gGlobalSyncTable.gameTimer = gGlobalSyncTable.gameTimer - 1
            if gGlobalSyncTable.gameTimer == 179 and gGlobalSyncTable.mapChoice == 1 then
                -- count the votes
                local votes = { { gGlobalSyncTable.voteMap1, 0, 1 }, { gGlobalSyncTable.voteMap2, 0, 2 }, { gGlobalSyncTable.voteMap3, 0, 3 } }
                for i = 0, MAX_PLAYERS - 1 do
                    local sMario = gPlayerSyncTable[i]
                    if gNetworkPlayers[i].connected and sMario.myVote and sMario.myVote ~= 0 and sMario.myVote ~= gGlobalSyncTable.voteExclude and votes[sMario.myVote] then
                        votes[sMario.myVote][2] = votes[sMario.myVote][2] + 1
                    elseif DEBUG_SCORES and i ~= 0 then
                        sMario.myVote = (i - 1) % 3 + 1
                        votes[sMario.myVote][2] = votes[sMario.myVote][2] + 1
                    end
                end

                table.sort(votes, function(a, b) return a[2] > b[2] end)

                local map = 0
                if votes[1][2] == votes[3][2] then -- all tie
                    if gGlobalSyncTable.voteExclude ~= 0 or votes[1][2] == 0 then
                        map = votes[math.random(1, 3)][1]
                    else -- eliminate a random map and vote again, if at least one map got a vote
                        gGlobalSyncTable.voteExclude = math.random(1, 3)
                    end
                elseif votes[1][2] == votes[2][2] then -- two tie
                    if gGlobalSyncTable.voteExclude ~= 0 or votes[3][2] == 0 then
                        map = votes[math.random(1, 2)][1]
                    else -- eliminate the outlier map and vote again, if the outlier got any vote
                        gGlobalSyncTable.voteExclude = votes[3][3]
                    end
                else
                    map = votes[1][1]
                end
                if map ~= 0 then
                    gGlobalSyncTable.wonMap = map
                else
                    gGlobalSyncTable.wonMap = -1
                end
            end
        elseif gGlobalSyncTable.mapChoice == 1 then
            if gGlobalSyncTable.wonMap ~= -1 then
                new_game_set_settings(gGlobalSyncTable.wonMap)
            else
                gGlobalSyncTable.gameTimer = 630 -- 21 seconds
                for i = 0, MAX_PLAYERS - 1 do
                    local sMario = gPlayerSyncTable[i]
                    if sMario.myVote == gGlobalSyncTable.voteExclude then
                        sMario.myVote = 0
                    end
                end
            end
        else
            start_random_level(type(gGlobalSyncTable.gameLevel) == "number")
        end
    end

    if didFirstJoinStuff then
        local act = (thisLevel and thisLevel.act) or 6

        if m.playerIndex == 0 and (not network_is_server()) and (gGlobalSyncTable.gameState == 1 or gGlobalSyncTable.gameState == 2) then
            local hostNP = gNetworkPlayers[1]
            local team = sMario.team or 0
            local hostTeam = gPlayerSyncTable[1].team or 0
            if (team == 0) ~= (hostTeam == 0) or hostNP.currLevelNum ~= np.currLevelNum or hostNP.currAreaIndex ~= np.currAreaIndex or hostNP.currActNum ~= np.currActNum then
                desyncTimer = desyncTimer + 1
                if desyncTimer >= 30 then
                    desyncTimer = 0
                    network_send_to(1, true, {
                        id = PACKET_FIX_DESYNC,
                        from = np.globalIndex,
                    })
                end
            end
        end

        if m.playerIndex == 0 and (gGlobalSyncTable.gameLevel ~= 0 or gGlobalSyncTable.gameState == 0) and (np.currLevelNum ~= thisLevel.level or np.currAreaIndex ~= thisLevel.area or (np.currActNum ~= act and np.currCourseNum ~= COURSE_NONE)) then -- stay in the right level
            spawn_potential = {}
            if not warp_to_level(thisLevel.level, thisLevel.area, act) then
                warp_to_warpnode(thisLevel.level, thisLevel.area, act, 0)
            end
        elseif gGlobalSyncTable.gameState == 1 then
            go_to_mario_start(m.playerIndex, np.globalIndex, false)

            -- give coins if this course is lacking in coins
            if gGlobalSyncTable.gameMode == 3 and m.playerIndex == 0 and gGlobalSyncTable.gameTimer > 60 and sMario.points == 0 then
                local participants = get_participant_count()
                local wantedCoins = 20                                          -- coins for each player
                if (thisLevel and (thisLevel.room or thisLevel.maxHeight)) then -- hmc has tons of oob coins, so just give 20
                    -- nothing
                elseif coinsExist < participants * wantedCoins then             -- enough coins so that each person CAN have 20
                    wantedCoins = wantedCoins - coinsExist // participants
                else
                    wantedCoins = 0
                end

                if sMario.team ~= 0 then -- larger teams get around the same amount of coins as other teams
                    local teamTotal = gGlobalSyncTable.teamMode
                    if teamTotal ~= 0 and participants > teamTotal then
                        local expectedPerTeam = participants // teamTotal
                        local myTeammates = 1
                        for i = 1, MAX_PLAYERS - 1 do
                            if (gNetworkPlayers[i].connected and gPlayerSyncTable[i].team == sMario.team) then
                                myTeammates = myTeammates + 1
                            end
                        end
                        if expectedPerTeam ~= myTeammates then
                            wantedCoins = wantedCoins * expectedPerTeam // myTeammates
                        end
                    end
                end

                sMario.points = wantedCoins
            elseif gGlobalSyncTable.gameMode == 5 and m.playerIndex == 0 and gGlobalSyncTable.gameTimer > 60 and sMario.points == 0 then
                local shine = obj_get_first_with_behavior_id(id_bhvMoon)
                local shines = 0
                while shine do
                    shines = shines + 1
                    shine = obj_get_next_with_same_behavior_id(shine)
                    if shines > 1 then break end
                end
                if shines <= 1 then
                    sMario.points = 1 -- free shine!
                end
            end

            -- time until start
            if m.playerIndex == 0 and network_is_server() then
                gGlobalSyncTable.gameTimer = gGlobalSyncTable.gameTimer + 1
                if DEBUG_MODE or gGlobalSyncTable.gameTimer > 300 then
                    if gGlobalSyncTable.gameMode ~= 5 then
                        gGlobalSyncTable.gameTimer = gGlobalSyncTable.maxGameTime * 1800 + 29
                    else
                        gGlobalSyncTable.gameTimer = gGlobalSyncTable.maxGameTime * 600 + 29 -- 1 min by default
                    end
                    gGlobalSyncTable.gameState = 2
                end
            elseif gGlobalSyncTable.gameState == 1 and gGlobalSyncTable.gameTimer > 330 then -- fix desync
                gGlobalSyncTable.gameState = 2
            end
        elseif gGlobalSyncTable.gameState == 2 and m.playerIndex == 0 and network_is_server() then
            -- detect eliminated (balloon battle, showtime in balloon attack, renegade roundup, moon runners)
            if gGlobalSyncTable.gameMode == 1 or (gGlobalSyncTable.gameMode == 2 and gGlobalSyncTable.showTime) or gGlobalSyncTable.gameMode > 3 then
                local winner = -1
                local winningTeam = 0
                local connected = 0
                local alive = 0
                local highestEliminated = 0
                local winnerIfAllDead = 0
                for i = 0, MAX_PLAYERS - 1 do
                    local sMario = gPlayerSyncTable[i]
                    if gNetworkPlayers[i].connected then
                        connected = connected + 1
                        if not is_dead(i) then
                            alive = alive + 1
                            if winner ~= -1 then
                                if winningTeam == 0 or sMario.team ~= winningTeam then
                                    winner = -1
                                    break
                                end
                            else
                                winningTeam = sMario.team
                                winner = network_global_index_from_local(i)
                            end
                        elseif highestEliminated < sMario.eliminated then -- prevent softlock when everyone dies
                            highestEliminated = sMario.eliminated
                            winnerIfAllDead = network_global_index_from_local(i)
                        end
                    end
                end

                if alive == 0 and winner == -1 then winner = winnerIfAllDead end

                if connected > 1 and winner ~= -1 then
                    network_send_include_self(true, {
                        id = PACKET_VICTORY,
                        winner = winner,
                        winner2 = -1,
                    })
                end
            end

            if gGlobalSyncTable.gameTimer > 0 then
                gGlobalSyncTable.gameTimer = gGlobalSyncTable.gameTimer - 1
                if gGlobalSyncTable.gameMode == 0 and gGlobalSyncTable.gameTimer == 300 then -- 10 seconds left
                    djui_popup_create_global("10 seconds until Showtime!", 1)
                end
            elseif gGlobalSyncTable.gameMode > 2 or (not gGlobalSyncTable.showTime) then
                if gGlobalSyncTable.gameMode == 0 then
                    gGlobalSyncTable.showTime = true
                    network_send_include_self(true, {
                        id = PACKET_SHOWTIME,
                    })
                elseif gGlobalSyncTable.gameMode == 4 then
                    local winner = -1
                    for i = 0, MAX_PLAYERS - 1 do
                        local sMario = gPlayerSyncTable[i]
                        if sMario.team == 1 then -- renegades win
                            winner = network_global_index_from_local(i)
                            break
                        end
                    end
                    network_send_include_self(true, {
                        id = PACKET_VICTORY,
                        winner = winner,
                        winner2 = -1,
                    })
                elseif gGlobalSyncTable.gameMode == 5 then
                    local toKill = {}
                    for i = 0, MAX_PLAYERS - 1 do
                        if gNetworkPlayers[i].connected and (not is_dead(i)) and has_least_points(i) then
                            table.insert(toKill, network_global_index_from_local(i))
                        end
                    end

                    -- drop one moon if no one is dead, or in drop variant
                    if #toKill == 0 or gGlobalSyncTable.variant == 1 then
                        network_send_include_self(true, {
                            id = PACKET_MR_DEAD,
                            victim = 0,
                            none = true,
                        })
                    end

                    for i, victim in ipairs(toKill) do
                        network_send_include_self(true, {
                            id = PACKET_MR_DEAD,
                            victim = victim,
                        })
                    end

                    gGlobalSyncTable.gameTimer = gGlobalSyncTable.maxGameTime * 300 +
                    29                                                                   -- 30 sec default, plus a bit under 1 second
                else
                    local winner = -1
                    local winningTeam = 0
                    mostPoints = -1
                    for i = 0, MAX_PLAYERS - 1 do
                        local sMario = gPlayerSyncTable[i]
                        if gNetworkPlayers[i].connected and (not is_spectator(i)) and ((gGlobalSyncTable.gameMode == 1 and has_most_balloons(i)) or (gGlobalSyncTable.gameMode ~= 1 and has_most_points(i))) then
                            if winner ~= -1 then
                                if winningTeam == 0 or sMario.team ~= winningTeam then
                                    winner = -1
                                    break
                                end
                            else
                                winningTeam = sMario.team
                                winner = network_global_index_from_local(i)
                            end
                        end
                    end

                    if winner ~= -1 then
                        network_send_include_self(true, {
                            id = PACKET_VICTORY,
                            winner = winner,
                            winner2 = -1,
                        })
                    elseif not gGlobalSyncTable.showTime then
                        gGlobalSyncTable.showTime = true
                        network_send_include_self(true, {
                            id = PACKET_SHOWTIME,
                        })
                    end
                end
            end
        end
    elseif m.playerIndex == 0 and gGlobalSyncTable.gameState ~= 0 and (not network_is_server()) then
        desyncTimer = desyncTimer + 1
        if desyncTimer >= 15 then
            desyncTimer = 0
            on_joined_game()
        end
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)

-- important functions: gets or sets the shine status
function get_player_owned_shine(index)
    if gGlobalSyncTable.gameMode ~= 0 then return 0 end

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
    if gGlobalSyncTable.gameMode ~= 0 then return -1 end

    if shine == 1 then
        return gGlobalSyncTable.shineOwner1
    elseif shine == 2 then
        return gGlobalSyncTable.shineOwner2
    end
    return -1
end

function has_most_balloons(index)
    if mostBalls ~= -1 then
        local sMario = gPlayerSyncTable[index]
        return (gNetworkPlayers[index].connected and (not is_spectator(index)) and
            sMario.balloons >= mostBalls and mostBalls ~= leastBalls), mostBalls
    end

    local hasMost = false
    for i = 0, MAX_PLAYERS - 1 do
        local sMario = gPlayerSyncTable[i]
        if gNetworkPlayers[i].connected and (not is_spectator(index)) then
            local points = sMario.balloons or 0
            if points > mostBalls then
                hasMost = (i == index)
                mostBalls = points
            elseif points == mostBalls and i == index then
                hasMost = true
            end

            -- calc least balloons too
            if leastBalls == -1 or points < leastBalls then
                leastBalls = points
            end
        end
    end
    if leastBalls == mostBalls then hasMost = false end
    return hasMost, mostBalls
end

function has_most_points(index)
    local sMario = gPlayerSyncTable[index]
    if (not gNetworkPlayers[index].connected) or is_dead(index) then
        return false, mostPoints
    end

    local myPoints = sMario.points or 0
    local myTeam = sMario.team or 0
    if mostPoints ~= -1 and (myTeam == 0 or teamScores[myTeam] or gGlobalSyncTable.gameMode == 5) then
        if myTeam ~= 0 and gGlobalSyncTable.gameMode ~= 5 then
            myPoints = teamScores[myTeam]
        end
        return (myPoints >= mostPoints and mostPoints ~= leastPoints), mostPoints
    end

    teamScores = {}
    local hasMost = false
    for i = 0, MAX_PLAYERS - 1 do
        local sMario = gPlayerSyncTable[i]
        if (gNetworkPlayers[i].connected and (not is_dead(i))) or (DEBUG_SCORES and network_player_connected_count() <= 1) then
            if (not sMario.team) or sMario.team == 0 or gGlobalSyncTable.gameMode == 5 then
                local points = sMario.points or 0
                if points > mostPoints then
                    hasMost = (i == index)
                    mostPoints = points
                elseif points == mostPoints and i == index then
                    hasMost = true
                end

                -- calc least points too
                if leastPoints == -1 or points < leastPoints then
                    leastPoints = points
                end
            elseif gGlobalSyncTable.gameMode ~= 0 then
                if not teamScores[sMario.team] then
                    teamScores[sMario.team] = 0
                end
                teamScores[sMario.team] = teamScores[sMario.team] + sMario.points
            elseif teamScores[sMario.team] == nil or sMario.points > teamScores[sMario.team] then -- for shine thief, team score is whatever the max is
                teamScores[sMario.team] = sMario.points
            end
        end
    end

    if myTeam ~= 0 and gGlobalSyncTable.gameMode ~= 5 then
        mostPoints = -1
        leastPoints = -1
        hasMost = false
        for team, points in pairs(teamScores) do
            if points > mostPoints then
                hasMost = (team == myTeam)
                mostPoints = points
            elseif points == mostPoints and team == myTeam then
                hasMost = true
            end

            -- calc least points too
            if leastPoints == -1 or points < leastPoints then
                leastPoints = points
            end
        end
    end

    if leastPoints == mostPoints then hasMost = false end
    return hasMost, mostPoints
end

-- for moon runners only
function has_least_points(index)
    local sMario = gPlayerSyncTable[index]
    if (not gNetworkPlayers[index].connected) or is_dead(index) then
        return false, leastPoints
    end

    local myPoints = sMario.points or 0
    local myTeam = sMario.team or 0
    if mostPoints == -1 then
        has_most_points(index) -- calculate scores
    end

    if (myTeam == 0 or teamScores[myTeam] or gGlobalSyncTable.gameMode == 5) then
        if myTeam ~= 0 and gGlobalSyncTable.gameMode ~= 5 then
            myPoints = teamScores[myTeam]
        end
        return (myPoints <= leastPoints and mostPoints ~= leastPoints), leastPoints
    end
    return false -- shouldn't happen
end

-- gets points, including in team battle (moon runners doesn't do team points)
function get_point_amount(index)
    local sMario0 = gPlayerSyncTable[index]
    if sMario0.team == nil or sMario0.team == 0 or gGlobalSyncTable.gameMode == 5 then
        return sMario0.points or 0
    elseif teamScores[sMario0.team] then
        return teamScores[sMario0.team]
    else -- recalculate
        teamScores = {}
        for i = 0, MAX_PLAYERS - 1 do
            local sMario = gPlayerSyncTable[i]
            if ((gNetworkPlayers[i].connected and (not is_spectator(i))) or (DEBUG_SCORES and network_player_connected_count() <= 1)) and sMario.team and sMario.team ~= 0 and sMario.points then
                if gGlobalSyncTable.gameMode ~= 0 then
                    if teamScores[sMario.team] then
                        teamScores[sMario.team] = teamScores[sMario.team] + sMario.points
                    else
                        teamScores[sMario.team] = sMario.points
                    end
                elseif teamScores[sMario.team] == nil or sMario.points > teamScores[sMario.team] then -- for shine thief, team score is whatever the max is
                    teamScores[sMario.team] = sMario.points
                end
            end
        end
        return teamScores[sMario0.team] or 0
    end
end

-- create placement table
function calculate_placements()
    if #placementTable ~= 0 then return end
    myPlacement = MAX_PLAYERS

    for i = 0, MAX_PLAYERS - 1 do
        local np = gNetworkPlayers[i]
        local sMario = gPlayerSyncTable[i]
        if np.connected then
            table.insert(placementTable, { index = i, placement = 0, team = (sMario.team or 0), score = 0 })
        end
    end

    -- debug scores
    if DEBUG_SCORES and network_player_connected_count() <= 1 then
        placementTable = {}
        for i = 0, MAX_PLAYERS - 1 do
            local sMario = gPlayerSyncTable[i]
            if i ~= 0 then
                sMario.balloons = (i % 5) + 1
                sMario.eliminated = 0
                sMario.points = i * 2
                if gGlobalSyncTable.teamMode ~= 0 then
                    sMario.team = (i % gGlobalSyncTable.teamMode) + 1
                end
            end
            table.insert(placementTable, { index = i, placement = 0, team = (sMario.team or 0), score = 0 })
        end
    end

    table.sort(placementTable, function(a, b)
        local sMario = gPlayerSyncTable[a.index]
        local sMario2 = gPlayerSyncTable[b.index]

        -- if it's team mode and we aren't assigned to a team, put us in last
        if gGlobalSyncTable.teamMode ~= 0 and a.team ~= b.team and (a.team == 0 or b.team == 0) then
            return (a.team ~= 0)
        end

        local spec, spec2 = sMario.spectator, sMario2.spectator
        if get_player_owned_shine(a.index) ~= 0 then spec = false end
        if get_player_owned_shine(b.index) ~= 0 then spec2 = false end
        if spec or spec2 then
            if spec and not spec2 then return false end
            if spec2 and not spec then return true end
            return a.index < b.index -- show lower local index first
        end

        local elim, elim2 = (sMario.eliminated or 1), (sMario2.eliminated or 1)

        -- alt calculation during renegade roundup
        if gGlobalSyncTable.gameMode == 4 then
            if gGlobalSyncTable.gameState and gGlobalSyncTable.gameState <= 2 then
                if a.team ~= b.team then
                    return a.team == gPlayerSyncTable[0].team -- show our team first
                end
            else
                local winIndex = network_local_index_from_global(gGlobalSyncTable.winner) or 0
                local sMario = gPlayerSyncTable[winIndex]
                a.score = (a.team == sMario.team) and (MAX_PLAYERS + 1) or 0
                b.score = (b.team == sMario.team) and (MAX_PLAYERS + 1) or 0
                if a.team ~= b.team then
                    return a.team == sMario.team
                end
            end
            if a.team ~= 2 then
                if elim == 0 then elim = MAX_PLAYERS + 1 end
                if elim2 == 0 then elim2 = MAX_PLAYERS + 1 end
                if elim ~= elim2 then return elim > elim2 end
            end

            return a.index < b.index -- show lower local index first
        elseif gGlobalSyncTable.gameMode ~= 0 then
            if elim == 0 then elim = MAX_PLAYERS + 1 end
            if elim2 == 0 then elim2 = MAX_PLAYERS + 1 end
            a.score, b.score = elim, elim2
            if elim ~= elim2 then return elim > elim2 end
        end

        if gGlobalSyncTable.gameMode == 1 then
            -- count balloons in balloon battle
            local balls, balls2 = (sMario.balloons or 0), (sMario2.balloons or 0)
            a.score, b.score = balls, balls2
            if balls ~= balls2 then return balls > balls2 end
        elseif (gGlobalSyncTable.gameMode ~= 2 or gGlobalSyncTable.showTime == false or elim ~= MAX_PLAYERS + 1) then
            -- count points in other modes (ignore in balloon attack showtime if not eliminated)
            local points, points2 = get_point_amount(a.index), get_point_amount(b.index)
            a.score, b.score = points, points2
            -- sort team mode players by their personal score
            if a.team == b.team and gGlobalSyncTable.gameMode ~= 0 then
                points, points2 = (sMario.points or 0), (sMario2.points or 0)
            end
            if points ~= points2 then return points > points2 end
            if a.team ~= b.team then return a.team < b.team end -- show lower team first
        end

        return a.index < b.index -- show lower local index first
    end)

    -- now we can set the placement values
    local prevScore = -1
    local currPlace = 0
    local teamTotal = 0
    local prevTeam = 0
    local bestPlacement = {}
    for i, data in ipairs(placementTable) do
        if data.team ~= 0 and ((gGlobalSyncTable.gameMode ~= 1 and gGlobalSyncTable.gameMode ~= 5) or (gGlobalSyncTable.gameState and gGlobalSyncTable.gameState > 2)) then
            if not bestPlacement[data.team] then
                teamTotal = teamTotal + 1
                if data.score ~= prevScore then
                    prevScore = data.score
                    bestPlacement[data.team] = teamTotal
                else
                    bestPlacement[data.team] = bestPlacement[prevTeam] or teamTotal
                end
            end
            currPlace = bestPlacement[data.team]
            prevTeam = data.team
        elseif data.score ~= prevScore then
            prevScore = data.score
            currPlace = i
        end
        if data.team == 0 then
            teamTotal = teamTotal + 1
        end

        data.placement = currPlace
        if data.index == 0 then
            myPlacement = currPlace
        end
    end
end

function get_placement(index)
    calculate_placements()
    if index == 0 then
        return myPlacement, true
    end
    for i, data in ipairs(placementTable) do
        if data.index == index then
            return (data.placement or MAX_PLAYERS), true
        end
    end
    return MAX_PLAYERS, false
end

-- utility function that returns if a floor is hazardous (lava, quicksand, or death plane)
function is_hazard_floor(type, normalY)
    if (type == nil or type == SURFACE_DEATH_PLANE or type == SURFACE_VERTICAL_WIND) then
        return true
    end
    if (type == SURFACE_INSTANT_QUICKSAND or type == SURFACE_INSTANT_MOVING_QUICKSAND or type == SURFACE_BURNING) and ((gGlobalSyncTable.variant ~= 3 and not gGlobalSyncTable.godMode) or thisLevel.badLava) then
        return true
    end
    -- check steepness
    if normalY then
        return normalY <= 0.97
    end
    return false
end

-- used for bombs and items
function set_action_after_throw(m, arg_)
    local arg = arg_ or 1
    if (m.action & (ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE | ACT_FLAG_HANGING | ACT_FLAG_RIDING_SHELL)) ~= 0 or ((m.action & ACT_FLAG_SWIMMING) == 0 and (m.action & ACT_FLAG_SWIMMING_OR_FLYING) ~= 0) then
        -- nothing
        play_character_sound(m, CHAR_SOUND_PUNCH_YAH)
    elseif (m.action == ACT_SHOT_FROM_CANNON) or (m.action == ACT_DIVE) then
        -- nothing
        play_character_sound(m, CHAR_SOUND_PUNCH_YAH)
    elseif (m.action & ACT_FLAG_SWIMMING) ~= 0 then
        set_mario_action(m, ACT_WATER_PUNCH, 0)
    elseif (m.action & (ACT_FLAG_MOVING | ACT_FLAG_STATIONARY)) ~= 0 then
        set_mario_action(m, ACT_ITEM_THROW_GROUND, arg)
    elseif (m.action & ACT_FLAG_AIR) ~= 0 and m.action ~= ACT_GROUND_POUND then
        set_mario_action(m, ACT_ITEM_THROW_AIR, arg)
    end
end

-- star effect
function hue_shift_over_time(time, max)
    local h = time % max * (360 / max)
    local s = 0.8
    local v = 1
    -- Now it's time to convert this to RGB, which is very annoying
    local M = 255 * v
    local m = M * (1 - s)
    local z = (M - m) * (1 - math.abs(h / 60 % 2 - 1))
    -- there's SIX CASES
    if h < 60 then
        r = M
        g = z + m
        b = m
    elseif h < 120 then
        r = z + m
        g = M
        b = m
    elseif h < 180 then
        r = m
        g = M
        b = z + m
    elseif h < 240 then
        r = m
        g = z + m
        b = M
    elseif h < 300 then
        r = z + m
        g = m
        b = M
    else
        r = M
        g = m
        b = z + m
    end
    return r, g, b
end

-- from extended moveset
function limit_angle(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

-- assigns the specified player to whichever team has the least amount of members (excludes the local player)
function calculate_lowest_member_team()
    local teamTotal = gGlobalSyncTable.teamMode

    if teamTotal == 0 then return 0 end

    if gGlobalSyncTable.variant == 1 and gGlobalSyncTable.gameMode == 4 then
        return 1 -- always join renegades in Lone Ranger
    end

    local teamCounts = {}
    local possible = {}
    local minTeamCount = 99
    for i = 1, teamTotal do
        table.insert(teamCounts, 0)
        table.insert(possible, i)
    end

    for i = 1, (MAX_PLAYERS - 1) do
        if gNetworkPlayers[i].connected then
            local team = gPlayerSyncTable[i].team or 0
            if team ~= 0 then
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
    -- join law if both teams are equal
    if #possible ~= 1 and gGlobalSyncTable.gameMode == 4 then
        return 2
    end
    return possible[math.random(1, #possible)]
end

-- returns if a map is blacklisted; if this value is above BASE_LEVELS, it uses the name instead (for arena support)
function is_blacklisted(map)
    local saveCheck = map
    if type(map) == "number" then
        if map < 1 then return false end
        if not levelData[map] then return true end
        saveCheck = levelData[map].saveName or levelData[map].name or
        get_level_name(levelData[map].course, levelData[map].level, levelData[map].area or 1)
        saveCheck = saveCheck:gsub("%W", " ")
    end
    return (map_blacklist[saveCheck] == 1)
end

-- returns if a level exists (determined by checking if its collision exists)
function level_exists(level, area)
    local col = smlua_collision_util_get_level_collision(level, area)
    if col then
        return (romHackName ~= "vanilla" or level == LEVEL_CASTLE or level == LEVEL_THI or area < 3) -- don't add eyerok area or ttm slide
    end
    return false
end

-- starts a random level, which is either from the supported list or any random level if "custom" was used
function start_random_level(list)
    local LIMIT = 0
    if list and #levelData ~= 0 then
        local map = math.random(1, #levelData)
        while is_blacklisted(map) and LIMIT < 1000 do
            map = math.random(1, #levelData)
            LIMIT = LIMIT + 1
        end
        new_game_set_settings(map)
        return
    end

    local maxAreas = (romHackName == "vanilla" and 3) or 7
    local dry = get_menu_option(4, 3)
    while LIMIT < 1000 do
        local level = course_to_level[math.random(0, #course_to_level)]
        local area = math.random(1, maxAreas)
        local levelString = tostring(level) .. " " .. tostring(area)
        setup_level_data(levelString)
        if not (romHackName ~= "vanilla" and level_is_vanilla_level(thisLevel.level)) and (not is_blacklisted(levelString)) and level_exists(thisLevel.level, thisLevel.area) then
            -- warp_to_level(-4, 1, -1) -- cancel warp
            new_game_set_settings(levelString .. " " .. tostring(dry))
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
    if list or isHackNotCompatible then
        while LIMIT < 1000 and #levelData > chosen and chosen < 3 do
            local map = math.random(1, #levelData)
            if not (alreadyChosen[map] or is_blacklisted(map)) then
                chosen = chosen + 1
                maps[chosen] = map
                alreadyChosen[map] = 1
                if isHackNotCompatible then break end
            end
            LIMIT = LIMIT + 1
        end
    end

    LIMIT = 0
    local maxAreas = (romHackName == "vanilla" and 3) or 7
    local dry = get_menu_option(4, 3)
    while LIMIT < 1000 and chosen < 3 do
        local level = course_to_level[math.random(0, #course_to_level)]
        local area = math.random(1, maxAreas)
        local map = tostring(level) .. " " .. tostring(area)
        -- print("Trying warp:", map)
        if not (alreadyChosen[map] or is_blacklisted(map) or (romHackName ~= "vanilla" and level_is_vanilla_level(level))) and level_exists(level, area) then
            chosen = chosen + 1
            maps[chosen] = map .. " " .. tostring(dry)
            alreadyChosen[map] = 1
            -- print("Warp succeeded!")
            -- warp_to_level(4, 1, -1) -- cancel warp
        end
        LIMIT = LIMIT + 1
    end

    gGlobalSyncTable.voteMap1 = maps[1] or "9 1"
    gGlobalSyncTable.voteMap2 = maps[2] or "24 1"
    gGlobalSyncTable.voteMap3 = maps[3] or "5 1"
    gGlobalSyncTable.voteExclude = 0
end

-- returns if the player is a spectator, or if the player has lost and is no longer a bomb
-- the only difference between these two states is that spectatating can be canceled
function is_spectator(index)
    local sMario = gPlayerSyncTable[index]
    return sMario.spectator or
        (sMario.eliminated and sMario.eliminated ~= 0 and not (sMario.isBomb or (gGlobalSyncTable.gameMode == 4 and gGlobalSyncTable.variant ~= 1)))
end

-- returns if the player is a spectator, or if the player has lost (includes bombs)
function is_dead(index)
    local sMario = gPlayerSyncTable[index]
    return sMario.spectator or (sMario.eliminated and sMario.eliminated ~= 0)
end

-- prevent team attack
--- @param attacker MarioState
--- @param victim MarioState
function allow_pvp_attack(attacker, victim, interaction, item_)
    local item = item_ or false
    local sAttacker = gPlayerSyncTable[attacker.playerIndex]
    local sVictim = gPlayerSyncTable[victim.playerIndex]
    local valid = (item or not (is_spectator(attacker.playerIndex) or is_spectator(victim.playerIndex))) and
        (sAttacker.team == 0 or sAttacker.team ~= sVictim.team) and
        ((not is_invincible(victim.playerIndex)) or is_invincible(attacker.playerIndex) or item)
    -- slide kick buff; it beats dives from the front
    if valid and (not item) and (victim.action == ACT_SLIDE_KICK or victim.action == ACT_SLIDE_KICK_SLIDE) and interaction == INT_FAST_ATTACK_OR_SHELL then
        local diff = abs_angle_diff(attacker.faceAngle.y, victim.faceAngle.y)
        --log_to_console("Checking slide kick angle: "..tostring(diff))
        if diff > 0x7000 then
            --log_to_console("Slide kick beats dive")
            local o = victim.marioObj
            o.oDamageOrCoinValue = 2
            attacker.interactObj = o
            if is_vulnerable(attacker) and take_damage_and_knock_back(attacker, o) ~= 0 then
                on_pvp_attack(victim, attacker)
                attacker.hurtCounter = 0
            end
            return false
        end
    end
    return valid
end

hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp_attack)

-- steal shine directly for some attacks
local steal_actions = {
    [ACT_SLIDE_KICK] = 1,
    [ACT_SLIDE_KICK_SLIDE] = 1,
    [ACT_SLIDE_KICK_SLIDE_STOP] = 1,
    [ACT_CAPE_JUMP] = 1,
    [ACT_CAPE_JUMP_SHELL] = 1,
}

--- @param attacker MarioState
--- @param victim MarioState
function on_pvp_attack(attacker, victim, interaction, cappyAttack, item)
    local damage = victim.hurtCounter
    victim.hurtCounter = 0
    if victim.playerIndex == 0 then
        local sVictim = gPlayerSyncTable[victim.playerIndex]
        local sAttacker = gPlayerSyncTable[attacker.playerIndex]

        -- drop item if the attack is powerful
        if damage >= 12 then
            drop_item()
        end

        -- it's possible to attack without running interact
        if sAttacker.isBomb and not (item or cappyAttack or sVictim.isBomb) then
            network_send_to(attacker.playerIndex, true, {
                id = PACKET_BOMB_HIT
            })
        end

        if not (item or is_dead(attacker.playerIndex)) and ((sAttacker.star and not sVictim.star) or (sAttacker.mushroomTime and sAttacker.mushroomTime ~= 0)
                or steal_actions[attacker.action] or cappyAttack) then
            if get_player_owned_shine(attacker.playerIndex) == 0 then
                if cappyAttack then -- can't send packet from OMM, so use old system (kind of)
                    cappyStealer = attacker.playerIndex
                    return
                end
                return handle_hit(victim.playerIndex, 3, attacker.playerIndex)
            end
        end

        return handle_hit(victim.playerIndex, 0, attacker.playerIndex, item)
    end
end

hook_event(HOOK_ON_PVP_ATTACK, on_pvp_attack)

-- api
function add_steal_attack(action)
    steal_actions[action] = 1
end

-- omm support
function omm_allow_attack(index, setting)
    if setting == 3 and index ~= 0 then
        return allow_pvp_attack(gMarioStates[index], gMarioStates[0])
    end
    return true
end

function omm_attack(index, setting)
    if setting == 3 and index ~= 0 then
        return on_pvp_attack(gMarioStates[index], gMarioStates[0], 0, true)
    end
end

function omm_disable_feature(feature, disable)
    return -- set when OMM is enabled
end

-- drop shine on death (runs when falling)
function on_death(m)
    handle_hit(m.playerIndex, 1)
    go_to_mario_start(m.playerIndex, gNetworkPlayers[m.playerIndex].globalIndex, true)
    return false
end

hook_event(HOOK_ON_DEATH, on_death)

function on_pause_exit(exitToCastle)
    if gGlobalSyncTable.gameState ~= 3 then
        handle_hit(0, 5)
        go_to_mario_start(0, gNetworkPlayers[0].globalIndex, true)
    end
    return false
end

hook_event(HOOK_ON_PAUSE_EXIT, on_pause_exit)

function set_custom_music()
    local wantedSequence = -1
    if gGlobalSyncTable.gameState == 0 then
        wantedSequence = SEQ_WON
    elseif thisLevel and thisLevel.music and (gGlobalSyncTable.gameState == 1 or gGlobalSyncTable.gameState == 2) and (not gGlobalSyncTable.showTime) then
        wantedSequence = thisLevel.music
    end
    if wantedSequence ~= -1 and get_current_background_music() ~= wantedSequence then
        set_background_music(0, wantedSequence, 120)
    end
end

hook_event(HOOK_ON_WARP, set_custom_music)

-- spawns or despawns shell
---@param m MarioState
function shell_rush_shell(m)
    local spawnShell = 0
    if m.riddenObj then
        m.riddenObj.oInteractStatus = INT_STATUS_STOP_RIDING
        if (m.action & ACT_FLAG_AIR) ~= 0 then
            set_mario_action(m, ACT_FREEFALL, 0)
        else
            force_idle_state(m)
        end
    elseif (m.input & INPUT_IN_WATER) ~= 0 then
        if (m.waterLevel - m.pos.y) < 100 then
            spawnShell = 1
            m.pos.y = m.waterLevel
        else
            spawnShell = 2
            if m.playerIndex == 0 and m.area.camera.mode == CAMERA_MODE_WATER_SURFACE then
                set_camera_mode(m.area.camera, m.area.camera.defMode, 1)
            end
        end
    elseif m.action ~= ACT_BACKWARD_GROUND_KB then
        spawnShell = 1
    end

    local model = E_MODEL_KOOPA_SHELL
    local shellChance = math.random(1, 20)
    if shellChance == 1 then
        model = E_MODEL_RED_SHELL
    end
    if spawnShell == 2 then
        if m.playerIndex == 0 then
            m.heldObj = spawn_sync_object(
                id_bhvKoopaShellUnderwater,
                model,
                m.pos.x, m.pos.y, m.pos.z,
                function(o)
                    o.oFaceAnglePitch = 0
                    o.oFaceAngleRoll = 0
                    o.oAction = 1
                    o.oHeldState = HELD_HELD
                end
            )
        end
        m.marioBodyState.grabPos = GRAB_POS_LIGHT_OBJ
        set_mario_action(m, ACT_WATER_SHELL_SWIMMING, 0)
    elseif spawnShell == 1 then
        if m.playerIndex == 0 then
            m.riddenObj = spawn_sync_object(
                id_bhvSTShell,
                model,
                m.pos.x, m.pos.y, m.pos.z,
                function(o)
                    o.oFaceAnglePitch = 0
                    o.oFaceAngleRoll = 0
                    o.oAction = 1
                    o.heldByPlayerIndex = 0
                end
            )
            set_camera_mode(m.area.camera, m.area.camera.defMode, 0)
        end
        if m.action == ACT_JUMP_KICK then -- prevent infinite height
            m.vel.y = 0
        end
        set_mario_action(m, ACT_RIDING_SHELL_FALL, 0)
    end
end

-- check if the special button is pressed or held
function special_down(m)
    if m.freeze ~= 0 and gGlobalSyncTable.variant ~= 1 then return false end
    if m.playerIndex == 0 then
        return specialDown
    else
        return (m.controller.buttonDown & SPECIAL_BUTTON ~= 0)
    end
end

function special_pressed(m)
    if m.freeze ~= 0 then return false end
    if m.playerIndex == 0 then
        return specialPressed
    else
        return (m.controller.buttonPressed & SPECIAL_BUTTON ~= 0)
    end
end

-- check if the item button is pressed (we don't need held)
function item_pressed(m)
    if m.playerIndex == 0 then
        return itemPressed
    else
        return (m.controller.buttonPressed & ITEM_BUTTON ~= 0)
    end
end

-- check direction item is thrown
-- clockwise starting right and at 0 (no direction is 4, default direction is 5)
function throw_direction(dPadOnly)
    local m = gMarioStates[0]
    if m.freeze ~= 0 then return 4 end
    if not dPadOnly then
        if not item_pressed(m) then
            return 4
        end
    end

    if m.controller.buttonDown & U_JPAD ~= 0 then
        return 1
    elseif m.controller.buttonDown & D_JPAD ~= 0 then
        return 3
    elseif m.controller.buttonDown & R_JPAD ~= 0 then
        return 0
    elseif m.controller.buttonDown & L_JPAD ~= 0 then
        return 2
    end

    return 5
end

-- loads settings if host
function load_setting(setting, bool)
    if not network_is_server() then return end
    local result = mod_storage_load(setting)
    if bool then
        return (result == "1")
    else
        result = tonumber(result)
        if result and math.floor(result) == result and result < 100 then
            return result
        end
    end
end

-- saves settings if host
function save_setting(setting, value)
    if not network_is_server() then return end
    if type(value) == "boolean" then
        mod_storage_save(setting, (value and "1") or "0")
    else
        if value and math.floor(value) == value and value < 100 then
            mod_storage_save(setting, tostring(value))
        end
    end
end

-- check if OMM moveset is on
function using_omm_moveset(index)
    if not _G.OmmEnabled then return false end
    if _G.OmmApi.omm_get_setting(gMarioStates[index], "moveset") ~= 0 then
        return true
    end
    return false
end

-- no!!!! no dialog!!!!
function on_dialog(id)
    return false
end

hook_event(HOOK_ON_DIALOG, on_dialog)

-- set our status when we enter
function on_sync_valid()
    local sMario = gPlayerSyncTable[0]
    if get_player_owned_shine(0) ~= 0 then -- if we just entered, we obviously don't have the shine
        set_player_owned_shine(-1, 0)
    end
    sMario.specialCooldown = 0
    sMario.boostTime = 0

    if gGlobalSyncTable.gameState ~= 0 then
        renderItemExists = {}
        setup_level_data(gGlobalSyncTable.gameLevel)
        go_to_mario_start(0, gNetworkPlayers[0].globalIndex, true)
    else
        setup_level_data(LOBBY_LEVEL)
    end

    on_joined_game()

    gLevelValues.disableActs = false
    if _G.OmmEnabled then
        omm_disable_feature("trueNonStop", true)
        omm_disable_feature("starsDisplay", true)
    end

    if thisLevel.noWater then
        set_water_level(0, gLevelValues.floorLowerLimit, false)
        set_water_level(1, gLevelValues.floorLowerLimit, false)
        set_water_level(2, gLevelValues.floorLowerLimit, false)
        set_water_level(3, gLevelValues.floorLowerLimit, false)
    end

    if gGlobalSyncTable.gameState == 3 then
        drop_queued_background_music()
        fadeout_level_music(1)
        set_dance_action()
    elseif gGlobalSyncTable.gameState == 2 and gGlobalSyncTable.showTime then
        on_packet_showtime()
        showTimeDispTimer = 0
    end

    syncValidTimer = 3
end

hook_event(HOOK_ON_SYNC_VALID, on_sync_valid)

function on_joined_game()
    if didFirstJoinStuff then return end
    print("My global index is ", gNetworkPlayers[0].globalIndex)

    if _G.OmmEnabled then
        ShineThief.set_alt_buttons(true)
    end

    local sMario = gPlayerSyncTable[0]
    sMario.points = 0
    sMario.team = calculate_lowest_member_team()
    if gGlobalSyncTable.gameState ~= 2 or (gGlobalSyncTable.gameMode ~= 1 and gGlobalSyncTable.gameMode ~= 4 and gGlobalSyncTable.gameMode ~= 5) then
        sMario.balloons = gGlobalSyncTable.startBalloons or 3
        sMario.eliminated = 0
        sMario.isBomb = false
    elseif gGlobalSyncTable.gameMode == 4 then
        sMario.balloons = 3
        sMario.eliminated = (sMario.team == 2 and 0) or 1
        sMario.isBomb = false
    else
        sMario.balloons = 0
        sMario.eliminated = 1
        sMario.isBomb = (gGlobalSyncTable.bombSetting ~= 0)
    end
    sMario.specialCooldown = 0
    sMario.boostTime = 0
    sMario.item = 0
    sMario.itemUses = 0
    sMario.mushroomTime = 0
    sMario.star = false
    sMario.bulletTimer = 0
    sMario.smallTimer = 0
    sMario.spectator = false
    sMario.myVote = 0
    sMario.showOnMap = 0
    gMarioStates[0].numStars = 0
    save_file_set_using_backup_slot(true)
    save_file_erase_current_backup_save()
    save_file_set_flags(SAVE_FLAG_MOAT_DRAINED)
    save_file_clear_flags(SAVE_FLAG_HAVE_KEY_2)
    save_file_clear_flags(SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)
    math.randomseed(get_time(), gNetworkPlayers[0].globalIndex)

    if _G.OmmEnabled then
        _G.OmmApi.omm_force_setting("player", PLAYER_INTERACTIONS_PVP)
        _G.OmmApi.omm_force_setting("color", 0)
        _G.OmmApi.omm_force_setting("powerups", 0)
        _G.OmmApi.omm_force_setting("stars", 0)
        _G.OmmApi.omm_force_setting("bubble", 0)
    end
    if gGlobalSyncTable.gameState ~= 0 and not warp_to_level(thisLevel.level, thisLevel.area, thisLevel.act or 6) then
        warp_to_warpnode(thisLevel.level, thisLevel.area, thisLevel.act or 6, 0)
    end
    if gGlobalSyncTable.gameState == 2 then
        tipDispTimer = 150
    end

    gLevelValues.wingCapDurationTotwc = 1
    gLevelValues.vanishCapDurationVcutm = 1
    gLevelValues.metalCapDurationCotmc = 1

    ---@type ModFile
    for i, mod in pairs(gActiveMods) do
        if mod.enabled then
            if mod.incompatible and mod.incompatible:find("romhack") then
                romHackName = mod.relativePath or "UNKNOWN"
                romHackName = romHackName:gsub("ROMHACK - ", "")
                for a = 1, BASE_LEVELS do
                    table.remove(levelData, 1)
                end
                BASE_LEVELS = 0
                local thisHackData = hackData[romHackName] or hackData["customHack"]
                if thisHackData then
                    for a, data in ipairs(thisHackData) do
                        BASE_LEVELS = BASE_LEVELS + 1
                        table.insert(levelData, BASE_LEVELS, data)
                        if data.lobby then
                            LOBBY_LEVEL = a
                        end
                    end
                    setup_level_data(LOBBY_LEVEL)
                    go_to_mario_start(0, gNetworkPlayers[0].globalIndex, true)
                else
                    isHackNotCompatible = true
                    setup_level_data(tostring(gLevelValues.entryLevel))
                end
                menu_update_for_romhack(#levelData)
            elseif mod.name:find("McDonald's") and (not mod.name:find("Tag")) then
                add_mcdonalds()
            end
        end
    end

    -- custom sequences
    if get_os_name() ~= "Mac OSX" then
        SEQ_SHOWTIME = 0x55
        SEQ_WON = 0x56
        smlua_audio_utils_replace_sequence(SEQ_SHOWTIME, 26, 75, "showtime")
        smlua_audio_utils_replace_sequence(SEQ_WON, 37, 65, "marioKartWiiMenu")
    elseif romHackName == "vanilla" then
        SEQ_SHOWTIME = 0x42
        SEQ_WON = 0x43
        smlua_audio_utils_replace_sequence(SEQ_SHOWTIME, 26, 75, "showtime")
        smlua_audio_utils_replace_sequence(SEQ_WON, 37, 65, "marioKartWiiMenu")
    end
    if romHackName == "vanilla" then
        smlua_audio_utils_replace_sequence(SEQ_LEVEL_INSIDE_CASTLE, 37, 50, "castlesm64remix")
    end
    set_custom_music()

    localWinner = gGlobalSyncTable.winner or -1
    localWinner2 = gGlobalSyncTable.winner2 or -1

    if network_is_server() then
        -- load blacklist
        map_blacklist = { id = PACKET_UPDATE_BLACKLIST }
        local line = 0
        local blacklistString = ""
        local lineString = mod_storage_load(romHackName .. "_black_" .. line)
        while lineString and lineString ~= "" do
            blacklistString = blacklistString .. lineString
            line = line + 1
            lineString = mod_storage_load(romHackName .. "_black_" .. line)
        end
        local loadedBlacklist = split(blacklistString, "-")
        for i, v in ipairs(loadedBlacklist) do
            local map = tonumber(v)
            if not map then
                map = v:gsub("_", " ")
            end
            map_blacklist[map] = 1
        end

        vote_pick_random_levels(true)
        menu_set_settings(true)
        sMario.balloons = gGlobalSyncTable.startBalloons or 3

        if gGlobalSyncTable.mapChoice == 0 then
            gGlobalSyncTable.gameTimer = 0
        elseif gGlobalSyncTable.mapChoice == 1 then
            gGlobalSyncTable.gameTimer = 630 -- 21 seconds
        else
            gGlobalSyncTable.gameTimer = 330 -- 11 seconds
        end

        inMenu = true
        if gGlobalSyncTable.mapChoice == 1 then
            enter_menu(6, 1, true)
        else
            enter_menu(3, 1, true)
        end

        if gServerSettings.headlessServer ~= 0 then
            spectator_mode()
        end
    end

    if _G.OmmEnabled then
        gLevelValues.disableActs = false
        omm_disable_feature = _G.OmmApi.omm_disable_feature
        _G.OmmApi.omm_allow_cappy_mario_interaction = omm_allow_attack
        _G.OmmApi.omm_resolve_cappy_mario_interaction = omm_attack
    end

    -- give coins to new players
    if gGlobalSyncTable.gameState == 2 and gGlobalSyncTable.gameMode == 3 then
        local totalPoints = 0
        local totalPlayers = 1 -- ourselves
        for i = 1, MAX_PLAYERS - 1 do
            if gNetworkPlayers[i].connected and not is_dead(i) then
                totalPlayers = totalPlayers + 1
                totalPoints = totalPoints + (gPlayerSyncTable[i].points or 0)
            end
        end
        sMario.points = totalPoints //
        totalPlayers                                -- average coins (since this includes ourselves, it's actually a bit less, which is what we want)
    end

    didFirstJoinStuff = true
end

--hook_event(HOOK_JOINED_GAME, on_joined_game)

function on_player_connected(m)
    if m.playerIndex == 0 then return end
    placementTable = {}
    reset_points(tostring(m.playerIndex), 1, 0)
    network_send(true, map_blacklist)
end

hook_event(HOOK_ON_PLAYER_CONNECTED, on_player_connected)

-- reset points on disconnect
function on_player_disconnected(m)
    if m.playerIndex == 0 then return end
    if network_is_server() then
        if gGlobalSyncTable.gameMode == 3 then
            lose_coins(m.playerIndex, 4)
        elseif gGlobalSyncTable.gameMode == 5 then
            lose_moon(m.playerIndex, 4)
        end
    end
    reset_points(tostring(m.playerIndex), 1, 0)
end

hook_event(HOOK_ON_PLAYER_DISCONNECTED, on_player_disconnected)

function update()
    -- disable screen shake
    if noShakeOrFlash then
        vec3s_set(gLakituState.shakeMagnitude, 0, 0, 0)
        --set_fov_shake(0, 0, 0)
    end

    -- set restrict palette setting for character select (only restrict in team mode)
    if charSelectExists then
        charSelect.restrict_palettes(gGlobalSyncTable.gameMode ~= 4 and gGlobalSyncTable.teamMode ~= 0)
    end

    -- spawn objects (done in this weird way to prevent sync bugs)
    if syncValidTimer == 0 or not (gNetworkPlayers[0].currAreaSyncValid and gNetworkPlayers[0].currLevelSyncValid) then return end
    syncValidTimer = syncValidTimer - 1
    if syncValidTimer ~= 0 then return end

    firstBalloonExists = false

    if network_is_server() then
        if gGlobalSyncTable.gameState == 0 and gGlobalSyncTable.teamMode ~= 0 then
            gPlayerSyncTable[0].team = calculate_lowest_member_team()
        end

        local itemTakenUp = {}
        if gGlobalSyncTable.gameMode == 0 then
            itemTakenUp[0] = 1
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
                elseif #spawn_potential ~= 0 then
                    pos = spawn_potential[1]
                    itemTakenUp[1] = 1
                else
                    local actor = obj_get_first(OBJ_LIST_GENACTOR)
                    if actor then
                        pos = { actor.oPosX, actor.oPosY + 160, actor.oPosZ }
                        needPlat = true
                    end
                end
                --djui_popup_create("spawned shine",1)

                if gGlobalSyncTable.variant ~= 1 then
                    shine = spawn_sync_object(
                        id_bhvShine,
                        E_MODEL_SHINE,
                        pos[1], pos[2], pos[3],
                        function(o)
                            o.oLastSafePosX = pos[1]
                            o.oLastSafePosY = pos[2]
                            o.oLastSafePosZ = pos[3]
                            o.oBehParams = 0x1
                            o.oObjectOwner = 1
                        end
                    )
                    spawn_sync_object(
                        id_bhvShineMarker,
                        E_MODEL_TRANSPARENT_STAR,
                        pos[1], pos[2] - 120, pos[3],
                        function(o)
                            o.parentObj = shine
                            o.oBehParams = 0x1
                        end
                    )
                else
                    shine = spawn_sync_object(
                        id_bhvShine,
                        E_MODEL_SHINE,
                        pos[1] - 100, pos[2], pos[3],
                        function(o)
                            o.oLastSafePosX = pos[1] - 100
                            o.oLastSafePosY = pos[2]
                            o.oLastSafePosZ = pos[3]
                            o.oBehParams = 0x1
                            o.oObjectOwner = 1
                        end
                    )
                    spawn_sync_object(
                        id_bhvShineMarker,
                        E_MODEL_TRANSPARENT_STAR,
                        pos[1], pos[2] - 120, pos[3],
                        function(o)
                            o.parentObj = shine
                            o.oBehParams = 0x1
                        end
                    )
                    shine = spawn_sync_object(
                        id_bhvShine,
                        E_MODEL_SHINE,
                        pos[1] + 100, pos[2], pos[3],
                        function(o)
                            o.oLastSafePosX = pos[1] + 100
                            o.oLastSafePosY = pos[2]
                            o.oLastSafePosZ = pos[3]
                            o.oBehParams = 0x2
                            o.oObjectOwner = 1
                        end
                    )
                    spawn_sync_object(
                        id_bhvShineMarker,
                        E_MODEL_TRANSPARENT_STAR,
                        pos[1], pos[2] - 120, pos[3],
                        function(o)
                            o.parentObj = shine
                            o.oBehParams = 0x2
                        end
                    )
                end

                if needPlat then
                    spawn_sync_object(
                        id_bhvStaticCheckeredPlatform,
                        E_MODEL_CHECKERBOARD_PLATFORM,
                        pos[1], pos[2] - 186, pos[3],
                        nil
                    )
                end
            end
        elseif gGlobalSyncTable.gameMode == 4 and gGlobalSyncTable.variant ~= 1 then
            local cage = obj_get_first_with_behavior_id(id_bhvRRCage)
            if not cage then
                local m = gMarioStates[0]
                local pos = { m.pos.x, m.floorHeight, m.pos.z + 500 }
                if m.floor and is_hazard_floor(m.floor.type) then
                    pos[2] = m.pos.y
                end
                if thisLevel.shineStart then
                    pos = thisLevel.shineStart
                elseif thisLevel.itemBoxLocations or #spawn_potential ~= 0 then
                    pos = nil
                else
                    local actor = obj_get_first(OBJ_LIST_GENACTOR)
                    if actor then
                        pos = { actor.oPosX, actor.oPosY, actor.oPosZ }
                    end
                end

                local locations = {}
                if pos then
                    itemTakenUp[0] = 1
                    table.insert(locations, pos)
                end

                local LIMIT = 500
                if thisLevel.itemBoxLocations then
                    while #locations ~= 3 and LIMIT ~= 0 and #locations < #thisLevel.itemBoxLocations do
                        LIMIT = LIMIT - 1
                        local random = math.random(1, #thisLevel.itemBoxLocations)
                        if not itemTakenUp[random] then
                            table.insert(locations, thisLevel.itemBoxLocations[random])
                            itemTakenUp[random] = 1
                        end
                    end
                elseif #spawn_potential ~= 0 then
                    for i, pos in ipairs(spawn_potential) do
                        table.insert(locations, pos)
                        itemTakenUp[i] = 1
                        if #locations == 3 then break end
                    end
                end

                for i, pos in ipairs(locations) do
                    spawn_sync_object(
                        id_bhvRRCage,
                        E_MODEL_HAUNTED_CAGE,
                        pos[1], pos[2], pos[3],
                        function(o)
                            o.oBehParams = i
                            o.oHomeX, o.oHomeY, o.oHomeZ = pos[1], pos[2], pos[3]
                        end
                    )
                end
            end
        elseif gGlobalSyncTable.gameMode == 5 then
            local mark = obj_get_first_with_behavior_id(id_bhvShineMarker)
            if not mark then
                local m = gMarioStates[0]
                local pos = { m.pos.x, m.floorHeight + 161, m.pos.z + 500 }
                if m.floor and is_hazard_floor(m.floor.type) then
                    pos[2] = m.pos.y
                end
                if thisLevel.shineStart then
                    pos = thisLevel.shineStart
                elseif thisLevel.itemBoxLocations or #spawn_potential ~= 0 then
                    pos = nil
                else
                    local actor = obj_get_first(OBJ_LIST_GENACTOR)
                    if actor then
                        pos = { actor.oPosX, actor.oPosY + 160, actor.oPosZ }
                    end
                end

                local locations = {}
                if pos then
                    itemTakenUp[0] = 1
                    table.insert(locations, pos)
                end

                local total = get_participant_count() + 1
                local LIMIT = 500
                if thisLevel.itemBoxLocations then
                    while #locations ~= total and LIMIT ~= 0 and #locations < #thisLevel.itemBoxLocations do
                        LIMIT = LIMIT - 1
                        local random = math.random(1, #thisLevel.itemBoxLocations)
                        if not itemTakenUp[random] then
                            table.insert(locations, thisLevel.itemBoxLocations[random])
                            itemTakenUp[random] = 1
                        end
                    end
                elseif #spawn_potential ~= 0 then
                    for i, pos in ipairs(spawn_potential) do
                        table.insert(locations, pos)
                        itemTakenUp[i] = 1
                        if #locations == total then break end
                    end
                end

                if #locations ~= total and #locations > 0 then
                    locations = { locations[1] }
                    itemTakenUp = { [0] = 1 }
                end

                for i, pos in ipairs(locations) do
                    local shine = spawn_sync_object(
                        id_bhvMoon,
                        E_MODEL_MOON,
                        pos[1], pos[2], pos[3],
                        function(o)
                            o.oHomeX, o.oHomeY, o.oHomeZ = pos[1], pos[2], pos[3]
                            o.oLastSafePosX = pos[1]
                            o.oLastSafePosY = pos[2]
                            o.oLastSafePosZ = pos[3]
                            o.oBehParams = (i << 16)
                            o.oObjectOwner = 1
                        end
                    )
                    mark = spawn_sync_object(
                        id_bhvShineMarker,
                        E_MODEL_TRANSPARENT_STAR,
                        pos[1], pos[2] - 120, pos[3],
                        function(o)
                            o.parentObj = shine
                            o.oBehParams = shine.oSyncID
                        end
                    )
                end
            end
        end

        local item = obj_get_first_with_behavior_id(id_bhvItemBox)
        if (not item) and gGlobalSyncTable.items ~= 0 then
            local itemNum = 1
            if thisLevel.itemBoxLocations then
                for i, pos in ipairs(thisLevel.itemBoxLocations) do
                    if not itemTakenUp[i] then
                        spawn_sync_object(id_bhvItemBox, E_MODEL_ITEM_BOX, pos[1], pos[2], pos[3], function(o)
                            o.oBehParams = itemNum
                            itemNum = itemNum + 1
                        end)
                    end
                end
                if (not itemTakenUp[0]) and thisLevel.shineStart then
                    local pos = thisLevel.shineStart
                    spawn_sync_object(id_bhvItemBox, E_MODEL_ITEM_BOX, pos[1], pos[2], pos[3], function(o)
                        o.oBehParams = itemNum
                        itemNum = itemNum + 1
                    end)
                end
            elseif #spawn_potential ~= 0 then
                for i, pos in ipairs(spawn_potential) do
                    if not itemTakenUp[i] then
                        spawn_sync_object(id_bhvItemBox, E_MODEL_ITEM_BOX, pos[1], pos[2], pos[3], function(o)
                            o.oBehParams = itemNum
                            itemNum = itemNum + 1
                        end)
                    end
                end
            end
        end
    end

    if thisLevel.objLocations then
        for i, v in ipairs(thisLevel.objLocations) do
            spawn_non_sync_object(
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

hook_event(HOOK_UPDATE, update)

-- no star select
hook_event(HOOK_USE_ACT_SELECT, function() return false end)

-- cs support
function network_player_reset_override_palette_custom(np)
    if charSelectExists and charSelect.character_get_current_palette_number and charSelect.character_get_current_palette_number(np.localIndex) ~= 0 then
        -- nothing
    else
        return network_player_reset_override_palette(np)
    end
end

-- used for team colors
function set_override_team_colors(np, lightColor, darkColor)
    local m = gMarioStates[np.localIndex]
    network_player_reset_override_palette_part(np, GLOVES)
    network_player_reset_override_palette_part(np, SKIN)
    network_player_reset_override_palette_part(np, SHOES)
    network_player_reset_override_palette_part(np, HAIR)
    network_player_set_override_palette_color(np, EMBLEM, darkColor)
    network_player_set_override_palette_color(np, CAP, lightColor)
    network_player_set_override_palette_color(np, PANTS, darkColor)
    network_player_set_override_palette_color(np, SHIRT, lightColor)
    if m.marioBodyState.modelState & MODEL_STATE_METAL ~= 0 then
        network_player_set_override_palette_color(np, METAL, lightColor)
        return
    end
end

function network_player_reset_override_palette_part(np, part)
    network_player_set_override_palette_color(np, part, network_player_get_palette_color(np, part))
end

-- reset_camera and soft_reset_camera have a bug that makes it impossible to disable freecam when they are run.
-- This gets around that issue.
function soft_reset_camera_fix_bug(c)
    if camera_config_is_free_cam_enabled() then
        camera_config_enable_free_cam(false) -- temporarily disable
        local mode = gLakituState.mode
        local defMode = gLakituState.defMode
        soft_reset_camera(c)
        gLakituState.mode = mode
        gLakituState.defMode = defMode
        set_camera_mode(c, mode, 0)
        camera_reset_overrides()
    else
        soft_reset_camera(c)
    end
end

function reset_camera_fix_bug(c)
    if camera_config_is_free_cam_enabled() then
        camera_config_enable_free_cam(false) -- temporarily disable
        local mode = gLakituState.mode
        local defMode = gLakituState.defMode
        reset_camera(c)
        gLakituState.mode = mode
        gLakituState.defMode = defMode
        set_camera_mode(c, mode, 0)
        camera_reset_overrides()
    else
        reset_camera(c)
    end
end

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
    if (get_current_background_music() ~= 0 and get_current_background_music_target_volume() ~= 0) or gNetworkPlayers[0].currLevelNum < LEVEL_COUNT then -- assume that custom maps with no music have custom music
        if gGlobalSyncTable.gameMode == 0 then
            audio_stream_play(MUSIC_ST_WIN, false, 1)
        elseif gGlobalSyncTable.gameMode == 1 then
            audio_stream_play(MUSIC_BB_WIN, false, 1)
        elseif gGlobalSyncTable.gameMode == 2 then
            audio_stream_play(MUSIC_BA_WIN, false, 1)
        elseif gGlobalSyncTable.gameMode == 3 then
            audio_stream_play(MUSIC_CR_WIN, false, 0.5)
        elseif gGlobalSyncTable.gameMode == 4 then
            audio_stream_play(MUSIC_RR_WIN, false, 0.8)
        elseif gGlobalSyncTable.gameMode == 5 then
            audio_stream_play(MUSIC_MR_WIN, false, 0.8)
        end
    else
        play_sound(SOUND_GENERAL_RACE_GUN_SHOT, gGlobalSoundSource)
    end
    set_dance_action()
end

spawn_potential = {}
function on_packet_new_game(data, self)
    coinsExist = 0
    shuffleItem = 0
    showTimeDispTimer = 0
    spawn_potential = {}
    if _G.OmmEnabled then
        gLevelValues.disableActs = false
        _G.OmmApi.omm_disable_feature("trueNonStop", true)
    end
    gGlobalSyncTable.gameLevel = data.level
    gGlobalSyncTable.gameMode = data.mode
    gGlobalSyncTable.variant = data.variant
    gGlobalSyncTable.teamMode = data.teams or 0
    gGlobalSyncTable.gameState = 1
    gGlobalSyncTable.showTime = false
    gGlobalSyncTable.shineOwner1 = -1
    gGlobalSyncTable.shineOwner2 = -1
    if self then
        gGlobalSyncTable.gameTimer = 1
    end

    if network_is_server() then
        local playerCount = get_participant_count()

        gGlobalSyncTable.winTime = 36 - math.min(playerCount, 26)                                 -- more time with less players (min 10s)
        if gGlobalSyncTable.teamMode ~= 0 then
            gGlobalSyncTable.winTime = gGlobalSyncTable.winTime +
            40 // gGlobalSyncTable.teamMode                                                       -- more time with less teams
        end

        gGlobalSyncTable.spawnOffset = math.random(0, MAX_PLAYERS - 1)

        gGlobalSyncTable.gameTimer = 1
        gGlobalSyncTable.wonMap = -1
        vote_pick_random_levels(type(gGlobalSyncTable.gameLevel) == "number")
    end

    if not self then
        setup_level_data(gGlobalSyncTable.gameLevel)
    end
    if not warp_to_level(thisLevel.level, thisLevel.area, thisLevel.act or 6) then
        warp_to_warpnode(thisLevel.level, thisLevel.area, thisLevel.act or 6, 0)
    end

    for i = 0, MAX_PLAYERS - 1 do
        local sMario = gPlayerSyncTable[i]
        sMario.points = 0
        if i == 0 then
            shuffleItem = 0
            if sMario.spectator then
                refillBalloons = 0
            else
                refillBalloons = 6 - (gGlobalSyncTable.startBalloons or 3)
            end
        end
        if sMario.spectator then
            sMario.eliminated = (gGlobalSyncTable.gameMode == 1 or gGlobalSyncTable.gameMode == 5) and 1 or 0
            sMario.balloons = 0
            sMario.team = 0
        else
            sMario.eliminated = 0
            sMario.balloons = gGlobalSyncTable.startBalloons or 3
        end
        sMario.isBomb = false
        sMario.specialCooldown = 0
        sMario.myVote = 0
        sMario.bulletTimer = 0
        sMario.smallTimer = 0
        sMario.star = false
        sMario.mushroomTime = 0
        sMario.item = 0
        sMario.itemUses = 0
        if data.teams == 0 or sMario.spectator then
            sMario.team = 0
        end
    end

    inMenu = false
    menu_set_settings()

    if data.teams ~= 0 and self then
        if gGlobalSyncTable.variant == 1 and gGlobalSyncTable.gameMode == 4 then -- Lone Ranger variant
            local valid = {}
            for i = 0, (MAX_PLAYERS - 1) do
                local sMario = gPlayerSyncTable[i]
                if gNetworkPlayers[i].connected and not sMario.spectator then
                    table.insert(valid, i)
                end
            end
            local ranger = math.random(1, #valid)
            for i = 1, #valid do
                local index = valid[i]
                gPlayerSyncTable[index].team = (ranger == i and 2) or 1
            end
            return
        end

        local teamTotal = data.teams
        local teamCounts = {}
        local possible = {}
        local participants = get_participant_count()
        local maxTeamCount = participants // teamTotal -- undershoot (some teams get more players)
        local extraMembers = participants % teamTotal  -- extra players total (each team can only get 1 extra max)
        for i = 1, teamTotal do
            table.insert(teamCounts, 0)
            table.insert(possible, i)
        end

        -- run teams for already-teamed players if we're replaying (that way, we still have fair teams)
        local alreadyDone = {}
        if data.redo then
            for i = 0, (MAX_PLAYERS - 1) do
                local sMario = gPlayerSyncTable[i]
                if gNetworkPlayers[i].connected and not sMario.spectator and sMario.team ~= 0 then
                    alreadyDone[i] = 1
                    local a = math.random(1, #possible)
                    for b, team in ipairs(possible) do
                        if sMario.team == team then
                            a = b
                            break
                        end
                    end
                    local team = possible[a]
                    sMario.team = team
                    teamCounts[team] = teamCounts[team] + 1
                    if teamCounts[team] > maxTeamCount then
                        table.remove(possible, a)
                    elseif teamCounts[team] == maxTeamCount then
                        if extraMembers == 0 then
                            table.remove(possible, a)
                        elseif gGlobalSyncTable.gameMode == 4 then -- law always gets the extra
                            if team == 1 then table.remove(possible, a) end
                        else
                            extraMembers = extraMembers - 1
                        end
                    end
                    if #possible == 0 then return end
                end
            end
        end

        for i = 0, (MAX_PLAYERS - 1) do
            local sMario = gPlayerSyncTable[i]
            if gNetworkPlayers[i].connected and not (sMario.spectator or alreadyDone[i]) then
                local a = math.random(1, #possible)
                local team = possible[a]
                sMario.team = team
                teamCounts[team] = teamCounts[team] + 1
                if teamCounts[team] > maxTeamCount then
                    table.remove(possible, a)
                elseif teamCounts[team] == maxTeamCount then
                    if extraMembers == 0 then
                        table.remove(possible, a)
                    elseif gGlobalSyncTable.gameMode == 4 then -- law always gets the extra
                        if team == 1 then table.remove(possible, a) end
                    else
                        extraMembers = extraMembers - 1
                    end
                end
                if #possible == 0 then return end
            end
        end
    end
end

function on_packet_shine(data)
    local np = network_player_from_global_index(data.victim)
    local playerColor = network_get_player_text_color_string(np.localIndex)
    local victimName = np.name

    if data.lost then
        if data.attacker then
            if np.localIndex == 0 then victimName = "you" end
            local aNP = network_player_from_global_index(data.attacker)
            local aPlayerColor = network_get_player_text_color_string(aNP.localIndex)
            local attackerName = "You"
            if aNP.localIndex ~= 0 then
                attackerName = aNP.name
            end

            djui_popup_create(
                string.format("%s\\#ffffff\\ made %s\\#ffffff\\\ndrop the \\#ffff40\\Shine\\#ffffff\\!",
                    aPlayerColor .. attackerName, playerColor .. victimName), 1)
        else
            if np.localIndex == 0 then victimName = "You" end
            djui_popup_create(playerColor .. victimName .. "\\#ffffff\\ dropped the \\#ffff40\\Shine\\#ffffff\\!", 1)
        end
    elseif not data.attacker then
        if np.localIndex == 0 then victimName = "You" end
        djui_popup_create(playerColor .. victimName .. "\\#ffffff\\ stole the \\#ffff40\\Shine\\#ffffff\\!", 1)
    else
        local aNP = network_player_from_global_index(data.attacker)
        local aPlayerColor = network_get_player_text_color_string(aNP.localIndex)
        local attackerName = "You"
        if aNP.localIndex ~= 0 then
            attackerName = aNP.name
        end

        if np.localIndex ~= 0 then
            djui_popup_create(
                string.format("%s\\#ffffff\\ stole %s's \\#ffff40\\Shine\\#ffffff\\!", aPlayerColor .. attackerName,
                    playerColor .. victimName), 1)
        else
            djui_popup_create(
                string.format("%s\\#ffffff\\ stole %s \\#ffff40\\Shine\\#ffffff\\!", aPlayerColor .. attackerName,
                    playerColor .. "your"), 1)
        end
    end

    if data.lost then return end

    gMarioStates[np.localIndex].invincTimer = math.max(gMarioStates[np.localIndex].invincTimer, 60) -- is halved in code

    audio_sample_play(SOUND_SHINE_GRAB, gGlobalSoundSource, 1)
end

function on_packet_drop_shine(data)
    -- no need to convert global indexes to local indexes, as global indexes are
    -- local indexes for the server
    --local owner = network_local_index_from_global(data.victim)
    --local attacker = network_local_index_from_global(data.attacker)
    local dropType = data.dropType
    lose_shine(data.victim, dropType, data.attacker)
end

function on_packet_reset_shine(data)
    local id = id_bhvShine
    if gGlobalSyncTable.gameMode == 5 then id = id_bhvMoon end
    local shine = obj_get_first_with_behavior_id(id)
    local i = 1
    while shine do
        if data.reset == nil or i == data.reset then
            if gGlobalSyncTable.gameMode == 0 then
                set_player_owned_shine(-1, shine.oBehParams)
            end
            shine.oTimer = 0
            shine_return(shine, true)
            if data.reset then break end
        end
        i = i + 1
        shine = obj_get_next_with_same_behavior_id(shine)
    end

    if gGlobalSyncTable.gameMode == 0 then
        djui_popup_create("Resetting the \\#ffff40\\Shine\\#ffffff\\!", 1)
    else
        djui_popup_create("Resetting the \\#50ff50\\Moon\\#ffffff\\!", 1)
    end
end

function on_packet_move_shine(data, self)
    local m = gMarioStates[0]
    if not self then
        local np = network_player_from_global_index(data.mover)
        m = gMarioStates[np.localIndex]
    end

    local id = id_bhvShine
    if gGlobalSyncTable.gameMode == 4 then
        id = id_bhvRRCage
    elseif gGlobalSyncTable.gameMode == 5 then
        id = id_bhvMoon
    end
    local o = obj_get_first_with_behavior_id(id)

    local i = 1
    while o do
        if data.moved == nil or i == data.moved then
            o.oTimer = 0
            o.oHomeX = m.pos.x
            o.oHomeY = m.pos.y + 160
            o.oHomeZ = m.pos.z
            if id ~= id_bhvRRCage then
                if id ~= id_bhvShine and get_shine_owner(o) == -1 then
                    shine_return(o, true)
                end
            else
                o.oPosX, o.oPosY, o.oPosZ = o.oHomeX, o.oHomeY, o.oHomeZ
            end
            if data.moved then break end
        end
        i = i + 1
        o = obj_get_next_with_same_behavior_id(o)
    end

    if gGlobalSyncTable.gameMode == 0 then
        djui_popup_create("Moving the \\#ffff40\\Shine\\#ffffff\\!", 1)
    elseif gGlobalSyncTable.gameMode == 5 then
        djui_popup_create("Moving the \\#50ff50\\Moon\\#ffffff\\!", 1)
    else
        djui_popup_create("Moving the cage!", 1)
    end
end

function on_packet_showtime()
    gGlobalSyncTable.showTime = true
    showTimeDispTimer = 90 -- 3 seconds

    -- showtime for non shine thief modes
    local sMario = gPlayerSyncTable[0]
    if sMario.eliminated == 0 and gGlobalSyncTable.showTime and gGlobalSyncTable.gameMode > 0 and gGlobalSyncTable.gameMode < 4 then
        if gGlobalSyncTable.gameMode == 1 then
            if (not has_most_balloons(0)) and mostBalls ~= leastBalls then
                sMario.balloons = 0
                set_eliminated(0)
            end
        else
            if (not has_most_points(0)) and mostPoints ~= leastPoints then
                sMario.balloons = 0
                set_eliminated(0, true)
            end
        end
        if sMario.balloons and sMario.balloons > 1 then
            sMario.balloons = 1
        end
    end

    if (get_current_background_music() ~= 0 and get_current_background_music_target_volume() ~= 0) or gNetworkPlayers[0].currLevelNum < LEVEL_COUNT then -- assume that custom maps with no music have custom music
        set_background_music(0, SEQ_SHOWTIME, 120)
    end
end

function on_packet_pow_block(data)
    set_camera_shake_from_hit(SHAKE_SMALL_DAMAGE)
    play_sound(SOUND_GENERAL_BIG_POUND, gGlobalSoundSource)
    powBlockTimer = 60
    powBlockOwner = data.owner
end

function on_packet_balloon(data)
    local np = network_player_from_global_index(data.victim)
    local playerColor = network_get_player_text_color_string(np.localIndex)
    local victimName = np.name
    if np.localIndex == 0 then victimName = "you" end

    if data.share then -- team share
        if np.localIndex == 0 then victimName = "You" end
        local aNP = network_player_from_global_index(data.attacker)
        if not aNP then return end
        local aPlayerColor = network_get_player_text_color_string(aNP.localIndex)
        local attackerName = "you"
        if aNP.localIndex ~= 0 then
            attackerName = aNP.name
        else
            local sAttacker = gPlayerSyncTable[0]
            sAttacker.balloons = sAttacker.balloons + 1
            newBalloonOwner = data.share
            if sAttacker.eliminated ~= 0 then
                sAttacker.isBomb = false
                sAttacker.eliminated = 0
            end
        end
        djui_popup_create(
            string.format("%s\\#ffffff\\ shared a balloon with %s\\#ffffff\\.", playerColor .. victimName,
                aPlayerColor .. attackerName), 2)
    elseif data.attacker then
        local aNP = network_player_from_global_index(data.attacker)
        if not aNP then return end
        local aPlayerColor = network_get_player_text_color_string(aNP.localIndex)
        local attackerName = "You"
        if aNP.localIndex ~= 0 then
            attackerName = aNP.name
        elseif data.steal ~= -1 then
            local sAttacker = gPlayerSyncTable[0]
            if sAttacker.balloons ~= 0 then
                if sAttacker.balloons < 5 then
                    sAttacker.balloons = sAttacker.balloons + 1
                    if gGlobalSyncTable.reduceObjects then
                        play_sound(SOUND_MENU_YOSHI_GAIN_LIVES, gGlobalSoundSource)
                    end
                elseif gGlobalSyncTable.variant == 1 and refillBalloons < 5 then
                    refillBalloons = refillBalloons + 1
                    play_sound(SOUND_MENU_YOSHI_GAIN_LIVES, gGlobalSoundSource)
                end
            end
            newBalloonOwner = data.steal
        end

        if data.sideline then
            djui_popup_create(
                string.format("%s\\#ffffff\\ sidelined %s\\#ffffff\\!", aPlayerColor .. attackerName,
                    playerColor .. victimName), 1)
            if aNP.localIndex == 0 then
                play_sound(SOUND_MENU_STAR_SOUND, gGlobalSoundSource)
                if not is_dead(0) then
                    gPlayerSyncTable[0].points = gPlayerSyncTable[0].points + 3
                end
            end
        else
            djui_popup_create(
                string.format("%s\\#ffffff\\ hit %s\\#ffffff\\!", aPlayerColor .. attackerName, playerColor .. victimName),
                1)
            if aNP.localIndex == 0 then
                play_sound(SOUND_GENERAL2_RIGHT_ANSWER, gGlobalSoundSource)
                if not is_dead(0) then
                    gPlayerSyncTable[0].points = gPlayerSyncTable[0].points + 1
                end
            end
        end
    else
        if data.sideline then
            if np.localIndex ~= 0 then
                djui_popup_create(string.format("%s\\#ffffff\\ was sidelined!", playerColor .. victimName), 1)
            else
                play_sound(SOUND_GENERAL2_BOBOMB_EXPLOSION, gGlobalSoundSource)
                djui_popup_create(string.format("%s\\#ffffff\\ were sidelined!", playerColor .. "You"), 1)
            end
        elseif data.fall then
            play_sound(SOUND_ACTION_BOUNCE_OFF_OBJECT, gGlobalSoundSource)
            djui_popup_create(string.format("%s\\#ffffff\\ fell off the stage!", playerColor .. "You"), 1) -- will always be you
        else
            play_sound(SOUND_ACTION_BOUNCE_OFF_OBJECT, gGlobalSoundSource)
            djui_popup_create(string.format("%s\\#ffffff\\ were hit!", playerColor .. "You"), 1) -- will always be you
        end
    end
end

function on_packet_lose_coins(data)
    local np = network_player_from_global_index(data.victim)
    local playerColor = network_get_player_text_color_string(np.localIndex)
    local victimName = np.name
    if np.localIndex == 0 then victimName = "You" end

    if data.attacker then
        if np.localIndex == 0 then victimName = "you" end
        local aNP = network_player_from_global_index(data.attacker)
        if not aNP then return end
        local aPlayerColor = network_get_player_text_color_string(aNP.localIndex)
        local attackerName = "You"
        if aNP.localIndex ~= 0 then
            attackerName = aNP.name
        elseif data.steal and data.steal ~= 0 then
            local sAttacker = gPlayerSyncTable[0]
            if not sAttacker.spectator then
                sAttacker.points = sAttacker.points + data.steal
            end
        end

        djui_popup_create(
            string.format("%s\\#ffffff\\ hit %s\\#ffffff\\!", aPlayerColor .. attackerName, playerColor .. victimName),
            1)
        if aNP.localIndex == 0 then
            play_sound(SOUND_GENERAL2_RIGHT_ANSWER, gGlobalSoundSource)
        end
    elseif data.fall then
        djui_popup_create(string.format("%s\\#ffffff\\ fell off the stage!", playerColor .. victimName), 1)
    else
        djui_popup_create(string.format("%s\\#ffffff\\ were hit!", playerColor .. victimName), 1) -- always you
    end
end

-- when hitting a player as a bob-omb
function on_packet_bomb_hit()
    local m = gMarioStates[0]
    local sMario = gPlayerSyncTable[0]

    if not sMario.isBomb then return end

    local gIndex = network_global_index_from_local(0)
    spawn_sync_object(id_bhvThrownBobomb,
        E_MODEL_NONE,
        m.pos.x, m.pos.y, m.pos.z,
        function(o)
            o.oForwardVel = 0
            o.oVelY = -20
            o.oObjectOwner = gIndex
            o.oInteractStatus = INT_STATUS_TOUCHED_BOB_OMB
        end)
    if gGlobalSyncTable.bombSetting == 2 then
        go_to_mario_start(0, gIndex, true)
    else
        sMario.isBomb = false
    end
end

-- renegade roundup
function on_packet_capture(data)
    local np = network_player_from_global_index(data.victim)
    local playerColor = network_get_player_text_color_string(np.localIndex)
    local victimName = np.name
    if np.localIndex == 0 then victimName = "You" end

    local sMario0 = gPlayerSyncTable[0]
    if data.free then
        if np.localIndex == 0 then
            sMario0.points = sMario0.points + data.points
        end
        if sMario0.team ~= 2 and lastCage == data.free then
            lastCage = 0
            local aPlayerColor = network_get_player_text_color_string(0)
            local attackerName = "you"
            sMario0.eliminated = 0
            gMarioStates[0].flags = gMarioStates[0].flags & ~MARIO_VANISH_CAP
            djui_popup_create(
                string.format("%s\\#ffffff\\ freed %s\\#ffffff\\!", playerColor .. victimName,
                    aPlayerColor .. attackerName),
                1)
        else
            djui_popup_create(
                string.format("%s\\#ffffff\\ opened a cell!", playerColor .. victimName),
                1)
        end
        if sMario0.team ~= 2 then
            play_sound(SOUND_GENERAL2_RIGHT_ANSWER, gGlobalSoundSource)
        end
    elseif data.attacker then
        if np.localIndex == 0 then victimName = "you" end
        local aNP = network_player_from_global_index(data.attacker)
        if not aNP then return end
        local aPlayerColor = network_get_player_text_color_string(aNP.localIndex)
        local attackerName = "You"
        if aNP.localIndex ~= 0 then
            attackerName = aNP.name
        else
            local sAttacker = gPlayerSyncTable[0]
            sAttacker.points = sAttacker.points + 1
        end

        djui_popup_create(
            string.format("%s\\#ffffff\\ captured %s\\#ffffff\\!", aPlayerColor .. attackerName,
                playerColor .. victimName),
            1)
        if sMario0.team == 2 then
            play_sound(SOUND_GENERAL2_RIGHT_ANSWER, gGlobalSoundSource)
        end
    elseif np.localIndex ~= 0 then
        djui_popup_create(string.format("%s\\#ffffff\\ was captured!", playerColor .. victimName), 1)
        if sMario0.team == 2 then
            play_sound(SOUND_GENERAL2_RIGHT_ANSWER, gGlobalSoundSource)
        end
    else
        djui_popup_create(string.format("%s\\#ffffff\\ were captured!", playerColor .. victimName), 1)
    end
end

function on_packet_moon(data)
    local np = network_player_from_global_index(data.victim)
    local playerColor = network_get_player_text_color_string(np.localIndex)
    local victimName = np.name
    if np.localIndex == 0 then victimName = "you" end

    if data.share then -- team share
        if np.localIndex == 0 then victimName = "You" end
        local aNP = network_player_from_global_index(data.attacker)
        if not aNP then return end
        local aPlayerColor = network_get_player_text_color_string(aNP.localIndex)
        local attackerName = "you"
        if aNP.localIndex ~= 0 then
            attackerName = aNP.name
        else
            local sAttacker = gPlayerSyncTable[0]
            sAttacker.points = sAttacker.points + 1
            audio_sample_play(SOUND_SHINE_GRAB, gGlobalSoundSource, 1)
        end
        djui_popup_create(
            string.format("%s\\#ffffff\\ shared a \\#50ff50\\Moon\\#ffffff\\ with %s\\#ffffff\\.",
                playerColor .. victimName,
                aPlayerColor .. attackerName), 2)
    elseif data.lost then
        if data.attacker then
            local aNP = network_player_from_global_index(data.attacker)
            if not aNP then return end
            local aPlayerColor = network_get_player_text_color_string(aNP.localIndex)
            local attackerName = "You"
            if aNP.localIndex ~= 0 then
                attackerName = aNP.name
            elseif data.steal ~= -1 then
                local sAttacker = gPlayerSyncTable[0]
                sAttacker.points = sAttacker.points + 1
                audio_sample_play(SOUND_SHINE_GRAB, gGlobalSoundSource, 1)
            else
                play_sound(SOUND_GENERAL2_RIGHT_ANSWER, gGlobalSoundSource)
            end

            if data.steal == -1 then
                djui_popup_create(
                    string.format("%s\\#ffffff\\ hit %s\\#ffffff\\!", aPlayerColor .. attackerName,
                        playerColor .. victimName),
                    1)
            elseif np.localIndex ~= 0 then
                djui_popup_create(
                    string.format("%s\\#ffffff\\ stole %s's \\#50ff50\\Moon\\#ffffff\\!", aPlayerColor .. attackerName,
                        playerColor .. victimName), 1)
            else
                djui_popup_create(
                    string.format("%s\\#ffffff\\ stole %s \\#50ff50\\Moon\\#ffffff\\!", aPlayerColor .. attackerName,
                        playerColor .. "your"), 1)
            end
        elseif np.localIndex ~= 0 then
            djui_popup_create(
                string.format("%s\\#ffffff\\ dropped a \\#50ff50\\Moon\\#ffffff\\!", playerColor .. np.name), 1)
        else
            djui_popup_create(
                string.format("%s\\#ffffff\\ dropped a \\#50ff50\\Moon\\#ffffff\\!", playerColor .. "You"), 1)
        end
    elseif np.localIndex == 0 then
        local sMario = gPlayerSyncTable[np.localIndex]
        sMario.points = sMario.points + 1
        audio_sample_play(SOUND_SHINE_GRAB, gGlobalSoundSource, 1)
    end
end

function on_packet_mr_dead(data)
    local np = network_player_from_global_index(data.victim)
    local playerColor = network_get_player_text_color_string(np.localIndex)

    play_sound(SOUND_GENERAL_RACE_GUN_SHOT, gGlobalSoundSource)
    if data.none then
        handle_hit(0, 5)
    elseif np.localIndex ~= 0 then
        local victimName = np.name
        djui_popup_create(string.format("%s\\#ffffff\\ was eliminated!", playerColor .. victimName), 1)
    else
        -- uneliminate ourselves to re-sync state?
        if gPlayerSyncTable[0].eliminated ~= 0 then
            gPlayerSyncTable[0].eliminated = 0
        end
        set_eliminated(0)
        handle_hit(0, 4)
        djui_popup_create(string.format("%s\\#ffffff\\ were eliminated!", playerColor .. "You"), 1)
    end
end

function on_packet_fix_desync(data)
    if network_is_server() then
        if data.global then
            for i = 1, MAX_PLAYERS - 1 do
                fix_desync_for_player(i)
            end
            return
        end
        local fromLocal = network_local_index_from_global(data.from) or 255
        if fromLocal == 255 then return end
        fix_desync_for_player(fromLocal)
    else
        local sMario = gPlayerSyncTable[0]
        for field, value in pairs(data) do
            if field ~= "id" then
                if field:sub(1, 2) == "G_" then
                    gGlobalSyncTable[field] = value or gGlobalSyncTable[field]
                else
                    sMario[field] = value or sMario[field]
                end
            end
        end
        if gGlobalSyncTable.teamMode == 0 and sMario.team ~= 0 then
            sMario.team = 0
        elseif gGlobalSyncTable.teamMode ~= 0 and sMario.team == 0 then
            sMario.team = calculate_lowest_member_team()
        end
        coinsExist = 0
        setup_level_data(gGlobalSyncTable.gameLevel)
        menu_set_settings()
    end
end

-- used with above
function fix_desync_for_player(index)
    local np = gNetworkPlayers[index]
    if not np.connected then return end
    local sMario = gPlayerSyncTable[index]
    local resync_fields = { "team", "spectator", "isBomb", "eliminated", "star", "bulletTimer", "smallTimer" }
    local syncTable = {
        id = PACKET_FIX_DESYNC,
        G_gameLevel = gGlobalSyncTable.gameLevel,
        G_gameMode = gGlobalSyncTable.gameMode,
        G_gameState = gGlobalSyncTable.gameState,
        G_showTime = gGlobalSyncTable.showTime,
        G_variant = gGlobalSyncTable.variant,
        G_teamMode = gGlobalSyncTable.teamMode,
    }
    for a, field in ipairs(resync_fields) do
        syncTable[field] = sMario[field]
    end
    network_send_to(index, true, syncTable)
end

function on_packet_boo_steal(data)
    local m = gMarioStates[0]
    local sMario = gPlayerSyncTable[0]
    sMario.item, sMario.itemUses = 0, 0
    play_sound(SOUND_OBJ_BOO_LAUGH_LONG, gGlobalSoundSource)
    spawn_non_sync_object(id_bhvCelebrationStarSparkle, E_MODEL_BOO, m.pos.x, m.pos.y + 200, m.pos.z, function(o)
        o.oVelY = 50
        o.oOpacity = 100
        o.oTimer = 0
    end)
    spawn_non_sync_object(id_bhvStarKeyCollectionPuffSpawner, E_MODEL_NONE, m.pos.x, m.pos.y, m.pos.z, nil)
end

function on_packet_lightning(data)
    local m = gMarioStates[0]
    set_camera_shake_from_hit(SHAKE_LARGE_DAMAGE)
    play_sound(SOUND_GENERAL_BOWSER_BOMB_EXPLOSION, gGlobalSoundSource)
    set_camera_shake_from_hit(SHAKE_LARGE_DAMAGE)

    local index = network_local_index_from_global(data.owner) or 0
    local otherTeam = gPlayerSyncTable[index].team or 0
    if ((index ~= 0 and (otherTeam == 0 or gPlayerSyncTable[0].team ~= otherTeam)) or (DEBUG_MODE and network_player_connected_count() <= 1)) and not (is_invincible(0) or is_spectator(0)) then
        if not noShakeOrFlash then
            play_transition(WARP_TRANSITION_FADE_INTO_COLOR, 10, 255, 255, 255)
            play_transition(WARP_TRANSITION_FADE_FROM_COLOR, 20, 255, 255, 255)
        end
        if m.action & (ACT_FLAG_SWIMMING | ACT_FLAG_METAL_WATER) ~= 0 then
            drop_and_set_mario_action(m, ACT_WATER_SHOCKED_HURTABLE, 0)
        else
            drop_and_set_mario_action(m, ACT_SHOCKED_HURTABLE, 0)
        end
        m.invincTimer = 10
        drop_item()
    end
end

function on_packet_update_blacklist(data)
    map_blacklist = data
    if network_is_server() then
        -- save blacklist
        local line = 0
        local saveString = ""
        for i, v in pairs(map_blacklist) do
            if v == 1 then
                if type(i) == "string" then
                    i = i:gsub(" ", "_")
                end
                local newSaveString = saveString .. i .. "-"
                if #newSaveString <= 512 then
                    saveString = newSaveString
                else
                    mod_storage_save(romHackName .. "_black_" .. line, saveString)
                    line = line + 1
                    saveString = i .. "-"
                end
            end
        end
        if saveString ~= "" then
            mod_storage_save(romHackName .. "_black_" .. line, saveString)
        else
            mod_storage_remove(romHackName .. "_black_" .. line)
        end
        line = line + 1
        local oldLine = mod_storage_load(romHackName .. "_black_" .. line)
        while oldLine and oldLine ~= "" do
            mod_storage_remove(romHackName .. "_black_" .. line)
            line = line + 1
            oldLine = mod_storage_load(romHackName .. "_black_" .. line)
        end

        -- reset vote levels if we just blacklisted one of them
        local voteMap1 = gGlobalSyncTable.voteMap1
        if type(voteMap1) == "string" then voteMap1 = voteMap1:sub(1, -3) end
        local voteMap2 = gGlobalSyncTable.voteMap2
        if type(voteMap2) == "string" then voteMap2 = voteMap2:sub(1, -3) end
        local voteMap3 = gGlobalSyncTable.voteMap3
        if type(voteMap3) == "string" then voteMap3 = voteMap3:sub(1, -3) end
        if (map_blacklist[voteMap1] or map_blacklist[voteMap2] or map_blacklist[voteMap3]) then
            vote_pick_random_levels(type(gGlobalSyncTable.gameLevel) == "number")
        end
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
PACKET_SHINE = 3
PACKET_DROP_SHINE = 4
PACKET_RESET_SHINE = 5
PACKET_SHOWTIME = 6
PACKET_MOVE_SHINE = 7
PACKET_POW_BLOCK = 8
PACKET_BALLOON = 9
PACKET_LOSE_COINS = 10
PACKET_BOMB_HIT = 11
PACKET_CAPTURE = 12
PACKET_MOON = 13
PACKET_MR_DEAD = 14
PACKET_FIX_DESYNC = 15
PACKET_BOO_STEAL = 16
PACKET_LIGHTNING = 17
PACKET_UPDATE_BLACKLIST = 18
sPacketTable = {
    [PACKET_VICTORY] = on_packet_victory,
    [PACKET_NEWGAME] = on_packet_new_game,
    [PACKET_SHINE] = on_packet_shine,
    [PACKET_DROP_SHINE] = on_packet_drop_shine,
    [PACKET_RESET_SHINE] = on_packet_reset_shine,
    [PACKET_SHOWTIME] = on_packet_showtime,
    [PACKET_MOVE_SHINE] = on_packet_move_shine,
    [PACKET_POW_BLOCK] = on_packet_pow_block,
    [PACKET_BALLOON] = on_packet_balloon,
    [PACKET_LOSE_COINS] = on_packet_lose_coins,
    [PACKET_BOMB_HIT] = on_packet_bomb_hit,
    [PACKET_CAPTURE] = on_packet_capture,
    [PACKET_MOON] = on_packet_moon,
    [PACKET_MR_DEAD] = on_packet_mr_dead,
    [PACKET_FIX_DESYNC] = on_packet_fix_desync,
    [PACKET_BOO_STEAL] = on_packet_boo_steal,
    [PACKET_LIGHTNING] = on_packet_lightning,
    [PACKET_UPDATE_BLACKLIST] = on_packet_update_blacklist,
}

function reset_points(tag, oldVal, newVal)
    if oldVal ~= newVal and ((not DEBUG_SCORES) or gNetworkPlayers[tonumber(tag)].connected) then
        mostPoints = -1
        mostBalls = -1
        leastPoints = -1
        leastBalls = -1
        teamScores = {}
        if gGlobalSyncTable.gameState and gGlobalSyncTable.gameState <= 2 then
            placementTable = {}
        end
    end
end

function on_game_state_change(tag, oldVal, newVal)
    if oldVal == newVal then return end
    if gGlobalSyncTable.teamMode ~= 0 and (gGlobalSyncTable.gameMode == 1 or gGlobalSyncTable.gameMode == 4 or gGlobalSyncTable.gameMode == 5) then
        reset_points("0", oldVal, newVal)
    end
end

for i = 0, MAX_PLAYERS - 1 do
    hook_on_sync_table_change(gPlayerSyncTable[i], "points", tostring(i), reset_points)
    hook_on_sync_table_change(gPlayerSyncTable[i], "balloons", tostring(i), reset_points)
    hook_on_sync_table_change(gPlayerSyncTable[i], "team", tostring(i), reset_points)
    hook_on_sync_table_change(gPlayerSyncTable[i], "eliminated", tostring(i), reset_points)
    hook_on_sync_table_change(gPlayerSyncTable[i], "spectator", tostring(i), reset_points)
    hook_on_sync_table_change(gGlobalSyncTable, "gameState", "gameStateChange", on_game_state_change)
end
