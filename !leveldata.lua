-- This stores the information for individual levels (such as start locations)
levelData = {
    [2] = {
        level = LEVEL_WF,
        course = COURSE_WF,
        area = 1,
        tex = "painting_00",
        noWater = true, -- people keep going oob

        startLocations = {
            --[[[0] = {2646, 1256, 5170},
            [1] = {3846, 1256, 5170},
            [2] = {4580, 1256, 4416},
            [3] = {4580, 1256, 4016},
            [4] = {4580, 1256, 3616},
            [5] = {4580, 1256, 3216},
            [6] = {4580, 1256, 2816},
            [7] = {4580, 1256, 2416},
            [8] = {4580, 1256, 2016},
            [9] = {4580, 1256, 1616},
            [10] = {4580, 1256, 1216},
            [11] = {4580, 1256, 816},
            [12] = {4580, 1256, 416},
            [13] = {4580, 1256, 16},
            [14] = {1560, 1922, 2356},
            [15] = {1560, 1922, 3500},]]
            [0] = {4580, 1256, 4416},
            [1] = {4580, 1256, 4316},
            [2] = {4580, 1256, 4216},
            [3] = {4580, 1256, 4116},
            [4] = {4580, 1256, 4016},
            [5] = {4580, 1256, 3916},
            [6] = {4580, 1256, 3816},
            [7] = {4580, 1256, 3716},
            [8] = {4580, 1256, 3616},
            [9] = {4580, 1256, 3516},
            [10] = {4580, 1256, 3416},
            [11] = {4580, 1256, 3316},
            [12] = {4580, 1256, 3216},
            [13] = {4580, 1256, 3116},
            [14] = {4580, 1256, 3016},
            [15] = {4580, 1256, 2916},
        },

        shineStart = {307, 5520, 7},
    },
    [17] = {
        level = LEVEL_BOWSER_1,
        course = COURSE_BITDW,
        area = 1,
        tex = "painting_01",
        name = "Bowser's Dark Domain",

        startLocations = {
            [0] = {0, 800, 2500},
            [1] = {957, 800, 2310},
            [2] = {1768, 800, 1768},
            [3] = {2310, 800, 957},
            [4] = {2500, 800, 0},
            [5] = {2310, 800, -957},
            [6] = {1768, 800, -1768},
            [7] = {957, 800, -2310},
            [8] = {0, 800, -2500},
            [9] = {-957, 800, -2310},
            [10] = {-1768, 800, -1768},
            [11] = {-2310, 800, -957},
            [12] = {-2500, 800, 0},
            [13] = {-2310, 800, 957},
            [14] = {-1768, 800, 1768},
            [15] = {-957, 800, 2310},
        },

        shineStart = {0, 467, 0},
    },
    [6] = {
        level = LEVEL_LLL,
        course = COURSE_LLL,
        area = 1,
        tex = "painting_02",

        startLocations = {
            --[[[0] = {-3793, 1154, 6272},
            [1] = {-2596, 1154, 6272},
            [2] = {844, 154, 6246},
            [3] = {-5902, 1154, 6625},
            [4] = {-4351, 1307, 3494},
            [5] = {-5090, 1512, -4098},
            [6] = {-92, 1307, -4352},
            [7] = {6326, 1633, -6554},
            [8] = {18, 1768, -6683},
            [9] = {5929, 1307, 1401},
            [10] = {4831, 1154, -610},
            [11] = {2060, 1307, 3787},
            [12] = {-4348, 1154, 237},
            [13] = {-5107, 1307, -777},
            [14] = {-6754, 1154, 4613},
            [15] = {3928, 1307, -5575},]]
            [0] = {-3793, 1154, 6272},
        },
        shineStart = {0, 685, 0},

        boxLocations = {
            {0, 505, 0, 0, 0x4000},
        },
    },
    [7] = {
        level = LEVEL_SSL,
        course = COURSE_SSL,
        area = 1,
        tex = "painting_03",

        startLocations = {
            [0] = {699, 1038, 6566},
            --[[[1] = {7351, 1000, 7336},
            [2] = {6701, 1000, -6158},
            [3] = {-5672, 1000, -4346},
            [4] = {-5084, 1000, 3981},
            [5] = {5879, 1614, 3858},
            [6] = {5942, 1614, 2905},
            [7] = {1786, 2024, 780},
            [8] = {1816, 1896, -2573},
            [9] = {-5907, 2024, -2570},
            [10] = {-5911, 2024, 765},
            [11] = {4876, 1000, -5892},
            [12] = {5881, 1210, 936},
            [13] = {3256, 1000, 6750},
            [14] = {-1442, 1000, 7066},
            [15] = {-5932, 1074, -846},]]
        },
        shineStart = {-2047, 1200, -519},
    },
    [8] = {
        level = LEVEL_SSL,
        course = COURSE_SSL,
        area = 2,
        tex = "painting_04",
        name = "The Ancient Pyramid",

        startLocations = {
            [0] = {0, 0, 3618},
            --[[[1] = {1293, 0, 3618},
            [2] = {2487, 0, 3618},
            [3] = {3515, 0, 3618},
            [4] = {3575, 0, 2277},
            [5] = {3575, 0, 1152},
            [6] = {3515, 0, -804},
            [7] = {3575, 0, -2034},
            [8] = {3575, 0, -3012},
            [9] = {0, 435, -3500},
            [10] = {-1441, 0, 3618},
            [11] = {-2786, 0, 3618},
            [12] = {-3632, 0, 3618},
            [13] = {-3788, 0, 2331},
            [14] = {-3788, 0, 735},
            [15] = {-3788, 0, 3041},]]
        },
        shineStart = {0, -63, 525},

        boxLocations = {
            {0, -243, 525},
            {0, 510, -300, 0x4000},
        },
    },
    [1] = {
        level = LEVEL_BOB,
        course = COURSE_BOB,
        area = 1,
        tex = "painting_05",

        startLocations = {
            [0] = {-6526, 1000, 6431},
            --[[[1] = {-6528, 1000, 4499},
            [2] = {-4444, 1000, 5653},
            [3] = {-2676, 1000, 3861},
            [4] = {-1366, 1000, 3822},
            [5] = {257, 1000, 3775},
            [6] = {1971, 1768, 6587},
            [7] = {4067, 1768, 6637},
            [8] = {3833, 1839, 3189},
            [9] = {6746, 1901, 3015},
            [10] = {6914, 1854, 6431},
            [11] = {-5951, 1768, 3034},
            [12] = {-5989, 1768, 1759},
            [13] = {-6102, 2024, -1422},
            [14] = {-5051, 2331, -3316},
            [15] = {-6606, 2024, -3362},]]
        },
        shineStart = {283, 1133, 1930},

        pipeLocations = {
            {2971, 4293, -3447, 2, -30876},
            {3732, 3072, 269, 1, 2615},
        },
    },
    [4] = {
        level = LEVEL_CCM,
        course = COURSE_CCM,
        area = 1,
        tex = "painting_06",

        startLocations = {
            [0] = {-1406, 3560, -2383},
            --[[[0] = {-4500, -404, 1046},
            --[1] = {-4987, -332, -391},
            [2] = {-2428, 179, 1621},
            [3] = {264, 177, 2495},
            [4] = {-4105, -286, -2737},
            [5] = {-599, -129, -3725},
            [6] = {1940, 73, -3762},
            [7] = {-4970, -740, 3943},
            [8] = {-5813, -740, 1933},
            [9] = {-5868, -744, -921},
            [10] = {-5169, -770, -2927},
            [11] = {-3507, -740, 5831},
            [12] = {1330, -535, 3796},
            [13] = {3207, 182, 431},
            [14] = {4196, -2071, 422},
            [15] = {2076, -535, 3030},]]
        },
        shineStart = {-477, 3631, -941},

        pipeLocations = {
            {-1861, 2826, -389, 2 , -25100},
            {3317, -4694, -147, 1, -3600},
        },
    },
    [10] = {
        level = LEVEL_WDW,
        course = COURSE_WDW,
        area = 1,
        noWater = true,
        tex = "painting_07",

        startLocations = {
            [0] = {3387, 1128, 390},
            --[[[0] = {-767, 2770, 167},
            [1] = {-767, 2714, 1497},
            [2] = {-776, 2782, 3575},
            [3] = {1773, 2741, 2123},
            [4] = {3377, 2791, 413},
            [5] = {3417, 2280, 1703},
            [6] = {-3301, 2152, 212},
            [7] = {-1736, 1000, 4366},
            [8] = {1609, 1000, 3839},
            [9] = {4077, 1000, 4195},
            [10] = {3895, 1000, -1324},
            [11] = {1686, 1205, -1716},
            [12] = {3004, 1000, -3484},
            [13] = {540, 1384, 325},
            [14] = {-3023, 1384, 1744},
            [15] = {4306, 1000, 2190},]]
        },
        shineStart = {718, 4192, 94},

        boxLocations = {
            {3790, 3050, -2980},
            {4220, 3050, -2980},
            {4650, 3050, -2980},
            {3790, 3050, -3280},
            {4220, 3050, -3280},
            {4650, 3050, -3280},
            {3790, 3050, -3580},
            {4220, 3050, -3580},
            {4650, 3050, -3580},
            {3790, 3050, -3880},
            {4220, 3050, -3880},
            {4650, 3050, -3880},
        },

        pipeLocations = {
            {2869, 0, -718, 2, -40},
            {-3623, 3584, -3623, 1, 7527},
        },
    },
    [12] = {
        level = LEVEL_TTM,
        course = COURSE_TTM,
        area = 1,
        tex = "painting_08",

        startLocations = {
            [0] = {95, -3332, 5693},
        },
        shineStart = {-3215, -2543, -3750},

        boxLocations = {
            {3281, -1510, 3541, 0, 24576},
            {3800, -1510, 3000, 0, 24576},
        },
    },
    [11] = {
        level = LEVEL_WDW,
        course = COURSE_WDW,
        area = 2,
        noWater = true,
        tex = "painting_09",
        name = "Wet-Dry Town",

        startLocations = {
            [0] = {-2385, -1559, 2466},
            [1] = {-2332, -1559, 1445},
            [2] = {-2282, -1559, 480},
            [3] = {-737, -1559, -474},
            [4] = {-116, -1559, -459},
            [5] = {-1350, -1559, -517},
            [6] = {526, -1559, 465},
            [7] = {643, -1559, 1600},
            [8] = {565, -1559, 2672},
            [9] = {-775, -1559, 249},
            [10] = {-147, -1559, 691},
            [11] = {-1369, -1559, 765},
            [12] = {-399, -791, -1590},
            [13] = {646, -791, -1541},
            [14] = {1644, -407, 1595},
            [15] = {1626, -407, 272},
        },
        shineStart = {-767, -172, 1770},

        boxLocations = {
            {-3525, -700, -1590, 0x4000, 0},
            {-3010, -700, -1590, 0x4000, 0},
        },
    },
    [13] = {
        level = LEVEL_THI,
        course = COURSE_THI,
        area = 2,
        tex = "painting_10",
        noWater = true,
        name = "Tiny Island",

        startLocations = {
            [0] = {-2119, 110, 2058},
        },
        shineStart = {3, 1327, -448},
    },
    [16] = {
        level = LEVEL_CASTLE_COURTYARD,
        course = 0,
        area = 1,
        tex = "painting_12",
        noWater = true,

        startLocations = {
            [0] = {0, 1000, 250},
            [1] = {-1600, 1000, -1800},
            [2] = {-1000, 1000, -3000},
            [3] = {0, 1000, -3000},
            [4] = {1600, 1000, -1800},
            [5] = {1000, 1000, -3000},
            [6] = {-2277, 796, -2764},
            [7] = {-3300, 1000, -2256},
            [8] = {-3300, 1000, -1786},
            [9] = {-3300, 1000, 0},
            [10] = {-2277, 796, -500},
            [11] = {3300, 1000, -2256},
            [12] = {3300, 1000, -1786},
            [13] = {3300, 1000, 0},
            [14] = {2277, 796, -2764},
            [15] = {2277, 796, -500},
        },
        shineStart = {0, 110, -1332},
    },
    [3] = {
        level = LEVEL_JRB,
        course = COURSE_JRB,
        area = 2,
        noWater = true,
        tex = "painting_15",
        name = "Inside The Jolly Roger",

        startLocations = {
            [0] = {39, -191, -1119},
        },
        shineStart = {43, 1418, 2958},
    },
    [9] = {
        level = LEVEL_SL,
        course = COURSE_SL,
        area = 1,
        tex = "painting_13",

        startLocations = {
            [0] = {5241, 2024, 143},
        },
        shineStart = {304, 1512, -4543},
    },
    [14] = {
        level = LEVEL_RR,
        course = COURSE_RR,
        area = 1,
        tex = "painting_18",

        startLocations = {
            [0] = {1822, -116, -50},
        },
        shineStart = {-506, -956, -50},

        pipeLocations = {
            {-5137, -1782, -42, 2, 0},
            {-4222, 3379, -3052, 1, 32768},
        },
    },
    [18] = {
        level = LEVEL_BOWSER_2,
        course = COURSE_BITFS,
        area = 1,
        tex = "painting_16",
        badLava = true,
        name = "Bowser's Fiery Domain",
        shineDefaultHeight = 1389,

        startLocations = {
            [0] = {0, 2229, 2500},
            [1] = {957, 2229, 2310},
            [2] = {1768, 2229, 1768},
            [3] = {2310, 2229, 957},
            [4] = {2500, 2229, 0},
            [5] = {2310, 2229, -957},
            [6] = {1768, 2229, -1768},
            [7] = {957, 2229, -2310},
            [8] = {0, 2229, -2500},
            [9] = {-957, 2229, -2310},
            [10] = {-1768, 2229, -1768},
            [11] = {-2310, 2229, -957},
            [12] = {-2500, 2229, 0},
            [13] = {-2310, 2229, 957},
            [14] = {-1768, 2229, 1768},
            [15] = {-957, 2229, 2310},
        },

        shineStart = {0, 1389, 0},
    },
    [19] = {
        level = LEVEL_BOWSER_3,
        course = COURSE_BITS,
        area = 1,
        tex = "painting_17",
        name = "Bowser's Sky Domain",

        startLocations = {
            [0] = {0, 800, 2500},
            [1] = {957, 800, 2310},
            [2] = {1768, 800, 1768},
            [3] = {2310, 800, 957},
            [4] = {2500, 800, 0},
            [5] = {2310, 800, -957},
            [6] = {1768, 800, -1768},
            [7] = {957, 800, -2310},
            [8] = {0, 800, -2500},
            [9] = {-957, 800, -2310},
            [10] = {-1768, 800, -1768},
            [11] = {-2310, 800, -957},
            [12] = {-2500, 800, 0},
            [13] = {-2310, 800, 957},
            [14] = {-1768, 800, 1768},
            [15] = {-957, 800, 2310},
        },

        shineStart = {0, 467, 0},
    },
    [15] = {
        level = LEVEL_CASTLE_GROUNDS,
        course = 0,
        area = 1,
        tex = "painting_14",

        startLocations = {
            [0] = {-1328, 1260, 4664},
        },
        shineStart = {0, 1066, -1200},

        boxLocations = {
            {-3383, -550, -2025, 0},
        },
    },
    [5] = {
        level = LEVEL_HMC,
        course = COURSE_HMC,
        area = 1,
        tex = "painting_11",
        name = "Underground Lake",
        room = 6,
        maxHeight = -10,

        startLocations = {
            [0] = {-790, -3279, 6290},
        },
        shineStart = {-3540, -4119, 3540},

        boxLocations = {
            {-420, -4150, 6634, 0x4000, 0xA000},
            {-3525, 1800, -6900, 0x0, 0},
            {-3525, 1800, -7200, 0x0, 0},
            {-300, -4965, 2480, 0x0, 0},
        },
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
end

function go_to_mario_start(localIndex,globalIndex,spawning)
    local m = gMarioStates[localIndex]
    m.invincTimer = 90 -- 3 seconds
    local pos = {}
    if thisLevel.startLocations and thisLevel.startLocations[1] then
        local location = thisLevel.startLocations[(globalIndex + gGlobalSyncTable.spawnOffset) % MAX_PLAYERS]
        if location == nil then location = thisLevel.startLocations[1] end
        pos = {location[1], location[2], location[3]}
    else
        if not (thisLevel.startLocations and thisLevel.startLocations[0]) then
            if localIndex == 0 and spawning then
                thisLevel.startLocations = {}
                thisLevel.startLocations[0] = {m.pos.x,m.pos.y,m.pos.z}
            end
            return
        end
        pos = {thisLevel.startLocations[0][1], thisLevel.startLocations[0][2], thisLevel.startLocations[0][3]}
        pos[1] = pos[1] + ((globalIndex)%4)*100-150
        pos[3] = pos[3] + ((globalIndex)//4)*100-150
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
        if m.riddenObj ~= nil then obj_mark_for_deletion(m.riddenObj) m.riddenObj = nil end
        m.faceAngle.y = obj_angle_to_point(m.marioObj, 0, 0)
        set_mario_action(m, ACT_SPAWN_SPIN_AIRBORNE, 0)
        if localIndex == 0 then
            showGameResults = false
            m.area.camera.defMode = CAMERA_MODE_ROM_HACK
            set_camera_mode(m.area.camera, CAMERA_MODE_ROM_HACK, 0)
            soft_reset_camera(m.area.camera)
            set_ttc_speed_setting(1)
            gMarioStates[0].numStars = 0
            save_file_set_using_backup_slot(true)
            save_file_set_flags(SAVE_FLAG_MOAT_DRAINED)
            save_file_clear_flags(SAVE_FLAG_HAVE_KEY_2)
            save_file_clear_flags(SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)
        end
    end
    m.pos.z = pos[3]
end

-- forces rom hack camera
function on_set_camera_mode(c, mode, frames)
    if mode ~= CAMERA_MODE_ROM_HACK and mode ~= 6 then
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
      finalmatch = string.sub(finalmatch,1,string.len(finalmatch)-string.len(delimiter))
      table.insert(result, finalmatch)
    end
    return result
end

course_to_level = {
    [COURSE_NONE] = LEVEL_CASTLE_GROUNDS, -- Course 0 (note that courtyard and inside are also course 0); won't appear in minihunt
    [COURSE_BOB] = LEVEL_BOB, -- Course 1
    [COURSE_WF] = LEVEL_WF, -- Course 2
    [COURSE_JRB] = LEVEL_JRB, -- Course 3
    [COURSE_CCM] = LEVEL_CCM, -- Course 4
    [COURSE_BBH] = LEVEL_BBH, -- Course 5
    [COURSE_HMC] = LEVEL_HMC, -- Course 6
    [COURSE_LLL] = LEVEL_LLL, -- Course 7
    [COURSE_SSL] = LEVEL_SSL, -- Course 8
    [COURSE_DDD] = LEVEL_DDD, -- Course 9
    [COURSE_SL] = LEVEL_SL, -- Course 10
    [COURSE_WDW] = LEVEL_WDW, -- Course 11
    [COURSE_TTM] = LEVEL_TTM, -- Course 12
    [COURSE_THI] = LEVEL_THI, -- Course 13
    [COURSE_TTC] = LEVEL_TTC, -- Course 14
    [COURSE_RR] = LEVEL_RR, -- Course 15
    [COURSE_BITDW] = LEVEL_BITDW, -- Course 16 (also bowser 1)
    [COURSE_BITFS] = LEVEL_BITFS, -- Course 17 (also bowser 2)
    [COURSE_BITS] = LEVEL_BITS, -- Course 18 (also bowser 3)
    [COURSE_PSS] = LEVEL_PSS, -- Course 19
    [COURSE_COTMC] = LEVEL_COTMC, -- Course 20
    [COURSE_TOTWC] = LEVEL_TOTWC, -- Course 21
    [COURSE_VCUTM] = LEVEL_VCUTM, -- Course 22
    [COURSE_WMOTR] = LEVEL_WMOTR, -- Course 23
    [COURSE_SA] = LEVEL_SA, -- Course 24
    [25] = LEVEL_ENDING, -- Course 25
    -- beyond this isn't actually correct, and is only set this way for the menu
    [26] = LEVEL_BOWSER_1,
    [27] = LEVEL_BOWSER_2,
    [28] = LEVEL_BOWSER_3,
    [29] = LEVEL_CASTLE,
    [30] = LEVEL_CASTLE_COURTYARD,
  }