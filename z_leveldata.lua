-- This stores the information for individual levels (such as start locations)
levelData = {
    {
        level = LEVEL_BOB,
        course = COURSE_BOB,
        area = 1,
        tex = "painting_05",

        startLocations = {
            [0] = { -6526, 1000, 6431 },
        },
        shineStart = { 283, 1133, 1930 },

        objLocations = {
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -4470, 0,    6730, 0, 1, 0x0, 0x6000 },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, 3732,  3072, 269,  1, 0, 0,   2615 },
        },
    },
    {
        level = LEVEL_WF,
        course = COURSE_WF,
        area = 1,
        tex = "painting_00",
        noWater = true, -- people keep going oob
        levelSize = 5600,

        startLocations = {
            [0] = { 4580, 1256, 4416 },
            [1] = { 4580, 1256, 4316 },
            [2] = { 4580, 1256, 4216 },
            [3] = { 4580, 1256, 4116 },
            [4] = { 4580, 1256, 4016 },
            [5] = { 4580, 1256, 3916 },
            [6] = { 4580, 1256, 3816 },
            [7] = { 4580, 1256, 3716 },
            [8] = { 4580, 1256, 3616 },
            [9] = { 4580, 1256, 3516 },
            [10] = { 4580, 1256, 3416 },
            [11] = { 4580, 1256, 3316 },
            [12] = { 4580, 1256, 3216 },
            [13] = { 4580, 1256, 3116 },
            [14] = { 4580, 1256, 3016 },
            [15] = { 4580, 1256, 2916 },
        },

        shineStart = { 307, 5520, 7 },
    },
    {
        level = LEVEL_JRB,
        course = COURSE_JRB,
        area = 2,
        noWater = true,
        tex = "painting_15",
        name = "Inside The Jolly Roger",
        levelSize = 3700,

        startLocations = {
            [0] = { 39, -191, -1119 },
        },
        shineStart = { 43, 1418, 2958 },
    },
    {
        level = LEVEL_CCM,
        course = COURSE_CCM,
        area = 1,
        tex = "painting_06",
        levelSize = 6400,

        startLocations = {
            [0] = { -1406, 3560, -2383 },
        },
        shineStart = { -477, 3631, -941 },

        objLocations = {
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -1861, 2826,  -389, 0, 1, 0, -25100 },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, 3317,  -4694, -147, 1, 0, 0, -3600 },
        },
    },
    {
        level = LEVEL_HMC,
        course = COURSE_HMC,
        area = 1,
        tex = "painting_11",
        noWater = true,
        name = "Deep Cave",
        room = 6,
        maxHeight = -10,

        startLocations = {
            [0] = { -790, -3279, 6290 },
        },
        shineStart = { -3540, -4119, 3540 },

        objLocations = {
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -420,  -4150, 6634, 0,   0, 0x4000, 0xA000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -300,  -4965, 2480, 0,   0, 0x0,    0 },
            --{id_bhvArenaSpring, E_MODEL_SPRING_BOTTOM, -3540, -6327, 5400, 140, 0, 0x0, 0x0000},
            { id_bhvArenaSpring,             E_MODEL_SPRING_BOTTOM,         -2225, -6327, 4855, 140, 0, 0x0,    0x2000 },
            --{id_bhvArenaSpring, E_MODEL_SPRING_BOTTOM, -1680, -6327, 3540, 140, 0, 0x0, 0x4000},
            { id_bhvArenaSpring,             E_MODEL_SPRING_BOTTOM,         -4855, -6327, 4855, 140, 0, 0x0,    0x6000 },
            --{id_bhvArenaSpring, E_MODEL_SPRING_BOTTOM, -3540, -6327, 1680, 140, 0, 0x0, 0x8000},
            { id_bhvArenaSpring,             E_MODEL_SPRING_BOTTOM,         -4855, -6327, 2225, 140, 0, 0x0,    0xA000 },
            --{id_bhvArenaSpring, E_MODEL_SPRING_BOTTOM, -5400, -6327, 3540, 140, 0, 0x0, 0xC000},
            { id_bhvArenaSpring,             E_MODEL_SPRING_BOTTOM,         -2225, -6327, 2225, 140, 0, 0x0,    0xE000 },
        },
    },
    {
        level = LEVEL_LLL,
        course = COURSE_LLL,
        area = 1,
        tex = "painting_02",

        startLocations = {
            [0] = { -3793, 1154, 6272 },
        },
        shineStart = { 0, 685, 0 },

        objLocations = {
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 0, 505, 0, 0, 0, 0, 0x4000 },
        },
    },
    {
        level = LEVEL_SSL,
        course = COURSE_SSL,
        area = 1,
        tex = "painting_03",

        startLocations = {
            [0] = { 699, 1038, 6566 },
        },
        shineStart = { -2047, 1200, -519 },
    },
    {
        level = LEVEL_SSL,
        course = COURSE_SSL,
        area = 2,
        tex = "painting_04",
        name = "The Ancient Pyramid",
        levelSize = 6708,
        romhack_cam = true,

        startLocations = {
            [0] = { 0, 0, 3618 },
        },
        shineStart = { 0, -63, 525 },

        objLocations = {
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 0, -243, 525 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 0, 510,  -300, 0, 0, 0x4000 },
        },
    },
    {
        level = LEVEL_SL,
        course = COURSE_SL,
        area = 1,
        tex = "painting_13",

        startLocations = {
            [0] = { 5241, 2024, 143 },
        },
        shineStart = { 304, 1512, -4543 },
    },
    {
        level = LEVEL_WDW,
        course = COURSE_WDW,
        area = 2,
        noWater = true,
        tex = "painting_09",
        name = "Wet-Dry Town",
        levelSize = 3800,

        startLocations = {
            [0] = { -2385, -1559, 2466 },
            [1] = { -2332, -1559, 1445 },
            [2] = { -2282, -1559, 480 },
            [3] = { -737, -1559, -474 },
            [4] = { -116, -1559, -459 },
            [5] = { -1350, -1559, -517 },
            [6] = { 526, -1559, 465 },
            [7] = { 643, -1559, 1600 },
            [8] = { 565, -1559, 2672 },
            [9] = { -775, -1559, 249 },
            [10] = { -147, -1559, 691 },
            [11] = { -1369, -1559, 765 },
            [12] = { -399, -791, -1590 },
            [13] = { 646, -791, -1541 },
            [14] = { 1644, -407, 1595 },
            [15] = { 1626, -407, 272 },
        },
        shineStart = { -767, -172, 1770 },

        objLocations = {
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -3525, -700, -1590, 0, 0, 0x4000, 0 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -3010, -700, -1590, 0, 0, 0x4000, 0 },
        },
    },
    {
        level = LEVEL_WDW,
        course = COURSE_WDW,
        area = 1,
        noWater = true,
        tex = "painting_07",

        startLocations = {
            [0] = { 3387, 1128, 390 },
        },
        shineStart = { 718, 4192, 94 },

        objLocations = {
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 3790,  3050, -2980 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 4220,  3050, -2980 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 4650,  3050, -2980 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 3790,  3050, -3280 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 4220,  3050, -3280 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 4650,  3050, -3280 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 3790,  3050, -3580 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 4220,  3050, -3580 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 4650,  3050, -3580 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 3790,  3050, -3880 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 4220,  3050, -3880 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 4650,  3050, -3880 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        2869,  0,    -718,  0, 1, 0, -40 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        -3623, 3584, -3623, 1, 0, 0, 7527 },
        },
    },
    {
        level = LEVEL_TTM,
        course = COURSE_TTM,
        area = 1,
        tex = "painting_08",
        noWater = true,

        startLocations = {
            [0] = { 95, -3332, 5693 },
        },
        shineStart = { -3215, -2543, -3750 },

        objLocations = {
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 3281, -1510, 3541, 0, 0, 0, 24576 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 3800, -1510, 3000, 0, 0, 0, 24576 },
        },
    },
    {
        level = LEVEL_THI,
        course = COURSE_THI,
        area = 2,
        tex = "painting_10",
        noWater = true,
        name = "Tiny Island",
        levelSize = 5000,

        startLocations = {
            [0] = { -2119, 110, 2058 },
        },
        shineStart = { 3, 1327, -448 },
    },
    {
        level = LEVEL_THI,
        course = COURSE_THI,
        area = 1,
        tex = "painting_21",
        noWater = true,
        name = "Huge Island",

        startLocations = {
            [0] = { -1800, 3202, -240 },
        },
        shineStart = { 0, 4051, -1530 },

        objLocations = {
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -3040, 512,   -3970, 0, 1, 0x0, 0x0 },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -5750, -3580, 2400,  1, 0, 0x0, 0x0 },
        },
    },
    {
        level = LEVEL_THI,
        course = COURSE_THI,
        area = 3,
        tex = "painting_20",
        name = "Wiggler's Cave",
        levelSize = 2000,

        startLocations = {
            [0] = { 727, 1024, 1230 },
            [1] = { 955, 1024, 1003 },
            [2] = { 1658, 1024, 284 },
            [3] = { 1235, 1024, -626 },
            [4] = { 896, 1024, -883 },
            [5] = { 94, 1024, -1391 },
            [6] = { -351, 1024, -1286 },
            [7] = { -516, 768, -427 },
            [8] = { -1567, 512, -1829 },
            [9] = { -1412, 512, -1120 },
            [10] = { -1861, 512, -1501 },
            [11] = { -1304, 1024, 276 },
            [12] = { -1824, 1024, 286 },
            [13] = { -1695, 1434, 1527 },
            [14] = { -1110, 1434, 1407 },
            [15] = { -387, 1434, 984 },
        },
        shineStart = { 240, 1118, 189 },

        objLocations = {
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 240, 932, 189, 0, 0, 0x0, 0x0 },
        },
    },
    {
        level = LEVEL_RR,
        course = COURSE_RR,
        area = 1,
        tex = "painting_18",

        startLocations = {
            [0] = { 1822, -116, -50 },
        },
        shineStart = { -506, -956, -50 },

        objLocations = {
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -5137, -1782, -42,   0, 1, 0, 0 },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -4222, 3379,  -3052, 1, 0, 0, 32768 },
        },
    },
    {
        level = LEVEL_CASTLE_GROUNDS,
        course = 0,
        area = 1,
        tex = "painting_14",
        noWater = true,

        startLocations = {
            [0] = { -1328, 1260, 4664 },
        },
        shineStart = { 0, 1066, -1200 },

        objLocations = {
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -3383, -550, -2025, 0, 0, 0 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        1370,  3174, -4020, 0, 1, 0x0, -0x8000 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        -5350, 343,  50,    1, 0, 0x0, 0x4000 },
        },
    },
    {
        level = LEVEL_CASTLE_COURTYARD,
        course = 0,
        area = 1,
        tex = "painting_12",
        noWater = true,
        levelSize = 3800,

        startLocations = {
            [0] = { 0, 1000, 250 },
            [1] = { -1600, 1000, -1800 },
            [2] = { -1000, 1000, -3000 },
            [3] = { 0, 1000, -3000 },
            [4] = { 1600, 1000, -1800 },
            [5] = { 1000, 1000, -3000 },
            [6] = { -2277, 796, -2764 },
            [7] = { -3300, 1000, -2256 },
            [8] = { -3300, 1000, -1786 },
            [9] = { -3300, 1000, 0 },
            [10] = { -2277, 796, -500 },
            [11] = { 3300, 1000, -2256 },
            [12] = { 3300, 1000, -1786 },
            [13] = { 3300, 1000, 0 },
            [14] = { 2277, 796, -2764 },
            [15] = { 2277, 796, -500 },
        },
        shineStart = { 0, 110, -1332 },
    },
    {
        level = LEVEL_PSS,
        course = COURSE_PSS,
        area = 1,
        tex = "painting_19",

        startLocations = {
            [0] = { 5632, 7144, -5631 },
        },
        shineStart = { -6350, -4324, 5670 },

        objLocations = {
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, 5632,  7666,  -5631, 0, 1, -0x8000, -0x4000 },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -5550, -4587, 5710,  1, 0, 0x0,     -0x4000 },
        },
    },
    {
        level = LEVEL_BOWSER_1,
        course = COURSE_BITDW,
        area = 1,
        tex = "painting_01",
        name = "Bowser's Dark Domain",
        levelSize = 3000,
        romhack_cam = true,

        startLocations = {
            [0] = { 0, 800, 2500 },
            [1] = { 957, 800, 2310 },
            [2] = { 1768, 800, 1768 },
            [3] = { 2310, 800, 957 },
            [4] = { 2500, 800, 0 },
            [5] = { 2310, 800, -957 },
            [6] = { 1768, 800, -1768 },
            [7] = { 957, 800, -2310 },
            [8] = { 0, 800, -2500 },
            [9] = { -957, 800, -2310 },
            [10] = { -1768, 800, -1768 },
            [11] = { -2310, 800, -957 },
            [12] = { -2500, 800, 0 },
            [13] = { -2310, 800, 957 },
            [14] = { -1768, 800, 1768 },
            [15] = { -957, 800, 2310 },
        },

        shineStart = { 0, 467, 0 },
    },
    {
        level = LEVEL_BOWSER_2,
        course = COURSE_BITFS,
        area = 1,
        tex = "painting_16",
        badLava = true,
        name = "Bowser's Fiery Domain",
        shineDefaultHeight = 1389,
        levelSize = 3000,
        romhack_cam = true,

        startLocations = {
            [0] = { 0, 2229, 2500 },
            [1] = { 957, 2229, 2310 },
            [2] = { 1768, 2229, 1768 },
            [3] = { 2310, 2229, 957 },
            [4] = { 2500, 2229, 0 },
            [5] = { 2310, 2229, -957 },
            [6] = { 1768, 2229, -1768 },
            [7] = { 957, 2229, -2310 },
            [8] = { 0, 2229, -2500 },
            [9] = { -957, 2229, -2310 },
            [10] = { -1768, 2229, -1768 },
            [11] = { -2310, 2229, -957 },
            [12] = { -2500, 2229, 0 },
            [13] = { -2310, 2229, 957 },
            [14] = { -1768, 2229, 1768 },
            [15] = { -957, 2229, 2310 },
        },

        shineStart = { 0, 1389, 0 },
    },
    {
        level = LEVEL_BOWSER_3,
        course = COURSE_BITS,
        area = 1,
        tex = "painting_17",
        name = "Bowser's Sky Domain",
        levelSize = 3000,
        romhack_cam = true,

        startLocations = {
            [0] = { 0, 800, 2500 },
            [1] = { 957, 800, 2310 },
            [2] = { 1768, 800, 1768 },
            [3] = { 2310, 800, 957 },
            [4] = { 2500, 800, 0 },
            [5] = { 2310, 800, -957 },
            [6] = { 1768, 800, -1768 },
            [7] = { 957, 800, -2310 },
            [8] = { 0, 800, -2500 },
            [9] = { -957, 800, -2310 },
            [10] = { -1768, 800, -1768 },
            [11] = { -2310, 800, -957 },
            [12] = { -2500, 800, 0 },
            [13] = { -2310, 800, 957 },
            [14] = { -1768, 800, 1768 },
            [15] = { -957, 800, 2310 },
        },

        shineStart = { 0, 467, 0 },
    },
}

thisLevel = levelData[1]
BASE_LEVELS = #levelData
arenaSpawnLocations = {}
function setup_level_data(level)
    if level == 0 then return end

    if levelData[level] ~= nil then
        thisLevel = levelData[level]
    else
        local args = split(level, " ")
        thisLevel = {}
        thisLevel.level = tonumber(args[1]) or LEVEL_WF
        thisLevel.area = tonumber(args[2]) or 1
        thisLevel.noWater = (tonumber(args[3]) == 1)
    end
    if arenaSpawnLocations[0] then
        thisLevel.startLocations = arenaSpawnLocations
    end
    arenaSpawnLocations = {}

    if DEBUG_MODE then
        reload_obj_data(thisLevel)
    end
end

-- TODO: Fix weird desync with referring only using spot 0?
function go_to_mario_start(localIndex, globalIndex, spawning)
    local m = gMarioStates[localIndex]
    m.invincTimer = 90 -- 3 seconds
    local pos = {}
    if thisLevel.startLocations and thisLevel.startLocations[1] then
        local location = thisLevel.startLocations[(globalIndex + gGlobalSyncTable.spawnOffset) % MAX_PLAYERS]
        if location == nil then location = thisLevel.startLocations[1] end
        pos = { location[1], location[2], location[3] }
    else
        if not (thisLevel.startLocations and thisLevel.startLocations[0]) then
            if localIndex == 0 and spawning then
                thisLevel.startLocations = {}
                thisLevel.startLocations[0] = { m.pos.x, m.pos.y, m.pos.z }
            end
            return
        end
        pos = { thisLevel.startLocations[0][1], thisLevel.startLocations[0][2], thisLevel.startLocations[0][3] }
        pos[1] = pos[1] + ((globalIndex) % 4) * 100 - 150
        pos[3] = pos[3] + ((globalIndex) // 4) * 100 - 150
    end
    m.pos.x = pos[1]
    if spawning then
        m.pos.y = pos[2]
        m.vel.y = 0
        m.marioObj.oPosX = pos[1]
        m.marioObj.oPosZ = pos[3]
        m.squishTimer = 0
        m.bounceSquishTimer = 0
        mario_drop_held_object(m)
        if m.riddenObj ~= nil then
            obj_mark_for_deletion(m.riddenObj)
            m.riddenObj = nil
        end
        m.faceAngle.y = obj_angle_to_point(m.marioObj, 0, 0)
        set_mario_action(m, ACT_SPAWN_SPIN_AIRBORNE, 0)
        if localIndex == 0 then
            showGameResults = false
            if thisLevel.romhack_cam then
                m.area.camera.defMode = CAMERA_MODE_ROM_HACK
                set_camera_mode(m.area.camera, CAMERA_MODE_ROM_HACK, 0)
            end
            soft_reset_camera(m.area.camera)
            set_ttc_speed_setting(1)
            gMarioStates[0].numStars = 0
            save_file_set_using_backup_slot(true)
            save_file_set_flags(SAVE_FLAG_MOAT_DRAINED)
            save_file_clear_flags(SAVE_FLAG_HAVE_KEY_2)
            save_file_clear_flags(SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)
            gPlayerSyncTable[0].item = 0
            gPlayerSyncTable[0].itemUses = 0
            gPlayerSyncTable[0].mushroomTime = 0
            gMarioStates[0].capTimer = 0
            stop_cap_music()
        end
    end
    m.pos.z = pos[3]
end

-- forces rom hack camera
function on_set_camera_mode(c, mode, frames)
    if thisLevel.romhack_cam and mode ~= CAMERA_MODE_ROM_HACK and mode ~= CAMERA_MODE_NEWCAM and mode ~= CAMERA_MODE_C_UP and mode ~= CAMERA_MODE_BEHIND_MARIO then
        set_camera_mode(c, CAMERA_MODE_ROM_HACK, 0)
        return false
    end
end

hook_event(HOOK_ON_SET_CAMERA_MODE, on_set_camera_mode)

-- split into arguments
function split(s, delimiter, limit_)
    local limit = limit_ or 999
    local result = {}
    local finalmatch = ""
    local i = 0
    for match in (s):gmatch(string.format("[^%s]+", delimiter)) do
        --djui_chat_message_create(match)
        i = i + 1
        if i >= limit then
            finalmatch = finalmatch .. match .. delimiter
        else
            table.insert(result, match)
        end
    end
    if i >= limit then
        finalmatch = string.sub(finalmatch, 1, string.len(finalmatch) - string.len(delimiter))
        table.insert(result, finalmatch)
    end
    return result
end

course_to_level = {
    [COURSE_NONE] = LEVEL_CASTLE_GROUNDS, -- Course 0 (note that courtyard and inside are also course 0); won't appear in minihunt
    [COURSE_BOB] = LEVEL_BOB,             -- Course 1
    [COURSE_WF] = LEVEL_WF,               -- Course 2
    [COURSE_JRB] = LEVEL_JRB,             -- Course 3
    [COURSE_CCM] = LEVEL_CCM,             -- Course 4
    [COURSE_BBH] = LEVEL_BBH,             -- Course 5
    [COURSE_HMC] = LEVEL_HMC,             -- Course 6
    [COURSE_LLL] = LEVEL_LLL,             -- Course 7
    [COURSE_SSL] = LEVEL_SSL,             -- Course 8
    [COURSE_DDD] = LEVEL_DDD,             -- Course 9
    [COURSE_SL] = LEVEL_SL,               -- Course 10
    [COURSE_WDW] = LEVEL_WDW,             -- Course 11
    [COURSE_TTM] = LEVEL_TTM,             -- Course 12
    [COURSE_THI] = LEVEL_THI,             -- Course 13
    [COURSE_TTC] = LEVEL_TTC,             -- Course 14
    [COURSE_RR] = LEVEL_RR,               -- Course 15
    [COURSE_BITDW] = LEVEL_BITDW,         -- Course 16 (also bowser 1)
    [COURSE_BITFS] = LEVEL_BITFS,         -- Course 17 (also bowser 2)
    [COURSE_BITS] = LEVEL_BITS,           -- Course 18 (also bowser 3)
    [COURSE_PSS] = LEVEL_PSS,             -- Course 19
    [COURSE_COTMC] = LEVEL_COTMC,         -- Course 20
    [COURSE_TOTWC] = LEVEL_TOTWC,         -- Course 21
    [COURSE_VCUTM] = LEVEL_VCUTM,         -- Course 22
    [COURSE_WMOTR] = LEVEL_WMOTR,         -- Course 23
    [COURSE_SA] = LEVEL_SA,               -- Course 24
    [25] = LEVEL_ENDING,                  -- Course 25
    -- beyond this isn't actually correct, and is only set this way for the menu
    [26] = LEVEL_BOWSER_1,
    [27] = LEVEL_BOWSER_2,
    [28] = LEVEL_BOWSER_3,
    [29] = LEVEL_CASTLE,
    [30] = LEVEL_CASTLE_COURTYARD,
}
level_to_course = {
    [LEVEL_CASTLE_GROUNDS] = COURSE_NONE,   -- Course 0
    [LEVEL_CASTLE] = COURSE_NONE,           -- Course 0
    [LEVEL_CASTLE_COURTYARD] = COURSE_NONE, -- Course 0
    [LEVEL_BOB] = COURSE_BOB,               -- Course 1
    [LEVEL_WF] = COURSE_WF,                 -- Course 2
    [LEVEL_JRB] = COURSE_JRB,               -- Course 3
    [LEVEL_CCM] = COURSE_CCM,               -- Course 4
    [LEVEL_BBH] = COURSE_BBH,               -- Course 5
    [LEVEL_HMC] = COURSE_HMC,               -- Course 6
    [LEVEL_LLL] = COURSE_LLL,               -- Course 7
    [LEVEL_SSL] = COURSE_SSL,               -- Course 8
    [LEVEL_DDD] = COURSE_DDD,               -- Course 9
    [LEVEL_SL] = COURSE_SL,                 -- Course 10
    [LEVEL_WDW] = COURSE_WDW,               -- Course 11
    [LEVEL_TTM] = COURSE_TTM,               -- Course 12
    [LEVEL_THI] = COURSE_THI,               -- Course 13
    [LEVEL_TTC] = COURSE_TTC,               -- Course 14
    [LEVEL_RR] = COURSE_RR,                 -- Course 15
    [LEVEL_BITDW] = COURSE_BITDW,           -- Course 16
    [LEVEL_BOWSER_1] = COURSE_BITDW,        -- Course 16
    [LEVEL_BITFS] = COURSE_BITFS,           -- Course 17
    [LEVEL_BOWSER_2] = COURSE_BITFS,        -- Course 17
    [LEVEL_BITS] = COURSE_BITS,             -- Course 18
    [LEVEL_BOWSER_3] = COURSE_BITS,         -- Course 18
    [LEVEL_PSS] = COURSE_PSS,               -- Course 19
    [LEVEL_COTMC] = COURSE_COTMC,           -- Course 20
    [LEVEL_TOTWC] = COURSE_TOTWC,           -- Course 21
    [LEVEL_VCUTM] = COURSE_VCUTM,           -- Course 22
    [LEVEL_WMOTR] = COURSE_WMOTR,           -- Course 23
    [LEVEL_SA] = COURSE_SA,                 -- Course 24
    [LEVEL_ENDING] = COURSE_CAKE_END,       -- Course 25 (will not appear in MiniHunt)
}
