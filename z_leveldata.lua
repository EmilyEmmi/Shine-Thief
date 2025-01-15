-- This stores the information for individual levels (such as start locations)
levelData = {
    {
        level = LEVEL_BOB,
        course = COURSE_BOB,
        saveName = "bob",
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

        itemBoxLocations = {
            { -80,   160,  5660 },
            { 1600,  1140, 4440 },
            { 4934,  1484, 861 },
            { 5540,  3232, 1200 },
            { 3000,  3232, 1250 },
            { 4360,  3232, 50 },
            { 4350,  3232, 2380 },
            { 3000,  4453, -4000 },
            { 2000,  4453, -5000 },
            { 3000,  4453, -5000 },
            { 2000,  4453, -4000 },
            { -5500, 928,  2400 },
            { -6500, 928,  2400 },
            { -6000, 928,  3024 },
            { -6000, 928,  1880 },
            { -6710, 1184, -2170 },
            { -2987, 1367, -723 },
            { -5294, 1271, -5723 },
            { -2601, 160,  -4167 },
            { 1135,  2034, -7161 },
            { 532,   2843, -5455 },
            { 1628,  3995, -5582 },
            { 7151,  2189, -6707 },
            { -1970, 160,  1360 },
            { -2675, 160,  612 },
            { 7042,  1009, 6469 },
            { 1950,  928,  6610 },
            { 519,   755,  -909 },
            { -1010, 877,  -4073 },
            { -549,  993,  -4314 },
            { -1470, 1007, -3832 },
            { 4921,  3241, -2857 },
            { 3567,  3156, -2082 },
        },
    },
    {
        level = LEVEL_WF,
        course = COURSE_WF,
        saveName = "wf",
        area = 1,
        act = 1,
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

        itemBoxLocations = {
            { 3770,  1540, 650 },
            { 2750,  1235, -3400 },
            { 1636,  2720, -80 },
            { 1900,  2720, 2570 },
            { -256,  2720, 2311 },
            { -2722, 544,  -1101 },
            { -2704, 544,  -477 },
            { -2683, 544,  250 },
            { -2500, 1491, -750 },
            { -2501, 1952, 31 },
            { 1920,  1082, 2518 },
            { 1897,  1082, 3454 },
            { 2323,  1082, 3049 },
            { 1491,  1082, 3028 },
            { 2700,  3744, -900 },
            { 1746,  3744, -3120 },
            { 2320,  3744, -2305 },
            { 3193,  3488, -1809 },
            { -1760, 1184, 3620 },
            { -932,  2720, -1461 },
            { -1351, 2720, -1924 },
            { -1701, 2720, -2309 },
        },

        shineStart = { 280, 3744, 270 },
    },
    {
        level = LEVEL_JRB,
        course = COURSE_JRB,
        saveName = "jrb",
        area = 1,
        noWater = true,
        noSlide = true,
        tex = "painting_15",

        startLocations = {
            [0] = {-6704, 2126, 1482},
        },
        shineStart = { 5000, -5061, 2500 },

        objLocations = {
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -5100, 1126,  -180, 0, 1, 0x0, -0x2000 },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, 3530,  -5119, 2510, 1, 0, 0x0, 0x4000 },
        },

        itemBoxLocations = {
            { 3642,  -4959, 3175 },
            { 5394,  2215,  1300 },
            { 4400,  2209,  1300 },
            { 4900,  1825,  4700 },
            { 2077,  1696,  7465 },
            { 648,   -351,  4256 },
            { -546,  672,   5930 },
            { -1945, 1491,  6509 },
            { -1845, -863,  3518 },
            { -2450, -863,  4272 },
            { -1207, -863,  4336 },
            { -1816, -863,  4964 },
            { 4882,  -4959, 3867 },
            { 6046,  -4959, 2638 },
            { 4992,  -4959, 1456 },
            { 3756,  -2806, -6084 },
            { 1235,  -2806, -4695 },
            { 1080,  -2806, -5960 },
            { 279,   -2806, -7340 },
            { -470,  -2806, -4340 },
            { -1800, -2652, -2100 },
            { -1150, -2652, -1550 },
            { -1700, -2652, -1150 },
            { -2400, -2652, -1800 },
        },
    },
    {
        level = LEVEL_JRB,
        course = COURSE_JRB,
        saveName = "jrb2",
        area = 2,
        noWater = true,
        tex = "painting_25",
        name = "Inside The Jolly Roger",
        levelSize = 3700,

        startLocations = {
            [0] = { 39, -191, -1119 },
        },
        shineStart = { 43, 1418, 2958 },

        itemBoxLocations = {
            { 484,  -42,  701 },
            { -246, 854,  1965 },
            { 809,  1102, 2642 },
            { 863,  590,  1784 },
            { -263, 86,   778 },
            { 253,  482,  1653 },
            { 548,  -191, -2655 },
        },
    },
    {
        level = LEVEL_CCM,
        course = COURSE_CCM,
        saveName = "ccm",
        area = 1,
        tex = "painting_06",
        levelSize = 6400,

        startLocations = {
            [0] = { -1406, 3560, -2383 },
        },
        shineStart = { -477, 3631, -941 },

        objLocations = {
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        -1861, 2826,  -389,  0, 1, 0,   -25100 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        3317,  -4694, -147,  1, 0, 0,   -3600 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        -3618, -4607, 4788,  2, 3, 0,   -29558 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        1092,  -4607, 5726,  3, 2, 0,   16384 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -50,   3096,  -1488, 0, 0, 0x0, 0x0 },
        },

        itemBoxLocations = {
            { -180,  3282,  -1483 },
            { -560,  2961,  -1540 },
            { 2560,  2822,  -1070 },
            { -1930, 1243,  1749 },
            { -3176, -1078, -2085 },
            { -4887, -1618, -4003 },
            { -5100, -1618, -3327 },
            { -5324, -1618, -2655 },
            { -3574, -1989, 6442 },
            { 203,   357,   -2957 },
            { 3243,  -4447, 4178 },
            { 3753,  -4447, 4159 },
            { 4020,  -4447, 4582 },
            { 3793,  -4447, 5032 },
            { 3266,  -4447, 5047 },
            { 3005,  -4447, 4619 },
            { 2700,  -4534, 1230 },
            { 4408,  -4447, -1534 },
            { 1250,  2600,  -2497 },
            { 1250,  2600,  -2950 },
            { -270,  -4584, -3100 },
            { -2000, -2358, -3000 },
            { -2807, -4717, -4237 },
            { -1137, -3423, 6099 },
            { 4200,  -1068, 400 },
            { 2900,  -1279, 2599 },
            { 3832,  -640,  32 },
            { 3391,  -640,  -409 },
            { 1346,  -1375, 3105 },
            { 1663,  -1375, 3761 },
            { -599,  -351,  1939 },
            { -1557, -351,  1794 },
            { -1395, -1477, 4587 },
            { 4136,  -2911, 456 },
        },
    },
    {
        level = LEVEL_CCM,
        course = COURSE_CCM,
        saveName = "ccm2",
        area = 2,
        name = "Snow Slide",
        tex = "painting_22",

        startLocations = {
            [0] = { -5836, 7360, -6143 },
        },
        shineStart = { -4910, 6816, -6160 },

        objLocations = {
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -5836, 7872,  -6143, 1, 0, -0x8000, 0x4000 },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -6540, -5836, -7195, 0, 1, 0x0 },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -7880, -5836, -6970, 2, 1 }, -- failsafe
        },

        itemBoxLocations = {
            { -4895, 1525,  550 },
            { -5580, -4650, -6620 },
            { -6420, -3929, -5910 },
            { -6470, -5520, -4820 },
            { -940,  6131,  -6743 },
            { -940,  6131,  -6443 },
            { -940,  6131,  -6143 },
            { -940,  6131,  -5843 },
            { -940,  6131,  -5543 },
            { 4498,  500,   -6048 },
            { 4502,  357,   -5632 },
            { 3495,  -3171, 6627 },
            { 3557,  -3171, 6375 },
            { 3626,  -3171, 6097 },
        },
    },
    {
        level = LEVEL_BBH,
        course = COURSE_BBH,
        saveName = "bbh",
        area = 1,
        center = {666, 1400},
        levelSize = 5400,
        tex = "painting_28",

        startLocations = {
            [0] = { 666, 796, 5288 },
        },
        shineStart = { 666, 3027, 1160 },

        objLocations = {
            { id_bhvArenaSpring, E_MODEL_SPRING_BOTTOM,  -1540, -204,  2916, 150, 0, 0x0, 0x0 },
            { id_bhvArenaSpring, E_MODEL_SPRING_BOTTOM,  2880,  -204,  2916, 150, 0, 0x0, 0x0 },
            { id_bhvArenaSpring, E_MODEL_SPRING_BOTTOM,  1728,  -204,  2347, 150, 0, 0x0, 0x0 },
            { id_bhvArenaSpring, E_MODEL_SPRING_BOTTOM,  -396,  -204,  2347, 150, 0, 0x0, 0x0 },
            { id_bhvSTPipe,      E_MODEL_BITS_WARP_PIPE, -2212, -204,  6173, 0,   1, 0x0, 0x6000 },
            { id_bhvSTPipe,      E_MODEL_BITS_WARP_PIPE, -3333, -2457, 5042, 1,   0, 0x0, 0x4000 },
        },

        itemBoxLocations = {
            { -1537, 2720,  1971 },
            { 2831,  2720,  1971 },
            { 666,   3437,  270 },
            { -1540, 3437,  276 },
            { 2932,  3437,  266 },
            { 2856,  160,   2144 },
            { 3138,  160,   373 },
            { 1673,  160,   -839 },
            { 50,    979,   -1400 },
            { 259,   979,   -513 },
            { 94,    160,   -814 },
            { -887,  160,   1664 },
            { -1960, 160,   -120 },
            { -1500, 672,   924 },
            { -420,  672,   100 },
            { -1515, 160,   -960 },
            { 2958,  979,   -809 },
            { -3040, 1286,  5460 },
            { 661,   -44,   3069 },
            { 4648,  -44,   1335 },
            { 4607,  -44,   -432 },
            { 2882,  -44,   -2794 },
            { 700,   -44,   -2800 },
            { -1791, -44,   -2764 },
            { -3240, -44,   -264 },
            { -3197, -44,   1901 },
            { -844,  -44,   2923 },
            { 2321,  -44,   2876 },
            { 648,   2082,  2394 },
            { 746,   1901,  648 },
            { 2891,  979,   666 },
            { 2491,  979,   2225 },
            { 1268,  979,   1860 },
            { -184,  979,   1532 },
            { -918,  1491,  -1435 },
            { -2043, 1184,  1934 },
            { -1056, 979,   -287 },
            { -1978, 979,   -317 },
            { -2617, -2297, 4723 },
            { 16,    -2297, 3471 },
            { -2165, -2297, 2089 },
            { -2381, -2297, -1093 },
            { 3213,  -2501, -1158 },
            { 2769,  -2809, 2133 },
            { 960,   -2297, 1784 },
            { 507,   -2400, 266 },
            { -374,  -2400, -576 },
            { -1112, -2400, 231 },
            { -174,  -2400, 1075 },
        },
    },
    {
        level = LEVEL_HMC,
        course = COURSE_HMC,
        saveName = "hmc",
        area = 1,
        tex = "painting_11",
        noWater = true,
        name = "Dorrie's Domain",
        room = { [6] = 1, [16] = 1 },
        maxHeight = -2000,
        levelSize = 4500,
        center = { -3540, 3540 },

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

        itemBoxLocations = {
            { -3540, -6167, 5400 },
            { -1680, -6167, 3540 },
            { -3540, -6167, 1680 },
            { -5400, -6167, 3540 },
            { -1822, -6167, 4252 },
            { -2828, -6167, 5258 },
            { -4252, -6167, 5258 },
            { -5258, -6167, 4252 },
            { -5258, -6167, 2828 },
            { -4252, -6167, 1822 },
            { -2828, -6167, 1822 },
            { -1822, -6167, 2828 },
        },
    },
    {
        level = LEVEL_LLL,
        course = COURSE_LLL,
        saveName = "lll",
        area = 1,
        tex = "painting_02",

        startLocations = {
            [0] = { -3793, 1154, 6272 },
        },
        shineStart = { 0, 685, 0 },

        objLocations = {
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 0, 505, 0, 0, 0, 0, 0x4000 },
        },

        itemBoxLocations = {
            { -5900, 314, 6400 },
            { -5800, 312, 1000 },
            { -5100, 312, 250 },
            { -4400, 312, 1000 },
            { -5100, 312, 1750 },
            { -3133, 325, -2126 },
            { -2333, 784, 886 },
            { 1050,  314, 6200 },
            { 3100,  416, 7900 },
            { 3261,  723, 5088 },
            { 6920,  467, 1145 },
            { 7440,  467, 1145 },
            { 7440,  467, 1770 },
            { 6920,  467, 1770 },
            { 6326,  798, -6580 },
            { 29,    928, -6714 },
            { 0,     467, -2085 },
            { -1924, 160, 3663 },
            { -6780, 359, -6766 },
            { 4856,  314, -579 },
            { 3110,  467, -5603 },
            { 3685,  467, -5603 },
            { 4460,  467, -5603 },
            { 3300,  165, -3720 },
            { 4350,  165, -3700 },
            { 4390,  165, -2660 },
            { 3350,  165, -2680 },
        },
    },
    {
        level = LEVEL_LLL,
        course = COURSE_LLL,
        saveName = "lll2",
        area = 2,
        tex = "painting_23",
        name = "Inside Of The Volcano",
        levelSize = 3000,

        startLocations = {
            [0] = { -955, 1102, -1029 },
        },
        shineStart = { -2355, 2428, -1200 },

        itemBoxLocations = {
            { -1675, 194,  -471 },
            { 831,   242,  -1538 },
            { 2112,  332,  -1719 },
            { 345,   1363, 2765 },
            { 345,   1363, 2505 },
            { -2235, 2024, 901 },
            { -1627, 1880, 750 },
            { -2352, 2141, 360 },
            { 920,   3389, -2502 },
            { 653,   3188, 1097 },
            { 1800,  3392, 1450 },
            { 625,   2310, 312 },
        },

        objLocations = {
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, 2523,  3591, -901, 1, 0, 0x0, -0x6000 },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -1511, 95,   557,  0, 1, 0,   0x6000 },
        },
    },
    {
        level = LEVEL_SSL,
        course = COURSE_SSL,
        saveName = "ssl",
        area = 1,
        tex = "painting_03",
        noWater = true,

        startLocations = {
            [0] = { 699, 1038, 6566 },
        },
        shineStart = { -2047, 1200, -519 },

        itemBoxLocations = {
            { 5900,  211,  2300 },
            { 5900,  211,  3300 },
            { 5900,  211,  4300 },
            { 5900,  774,  2300 },
            { 5900,  774,  3300 },
            { 5900,  774,  4300 },
            { 6380,  160,  -2330 },
            { 6937,  160,  -3333 },
            { 6900,  160,  -5400 },
            { 5906,  160,  -4867 },
            { 3380,  160,  -4900 },
            { 792,   160,  -5903 },
            { -1239, 160,  -6393 },
            { 1817,  1184, 783 },
            { 1787,  1056, -2545 },
            { -5884, 1184, -2552 },
            { -5853, 1184, 776 },
            { -3000, 416,  800 },
            { -1200, 416,  800 },
            { -230,  160,  4164 },
            { -4843, 160,  2194 },
            { 4392,  160,  7182 },
            { 4399,  160,  6350 },
            { 4396,  160,  6740 },
            { -2040, 928,  -2160 },
            { -570,  672,  -980 },
        },
    },
    {
        level = LEVEL_SSL,
        course = COURSE_SSL,
        area = 2,
        tex = "painting_04",
        name = "The Ancient Pyramid",
        saveName = "ssl2",
        levelSize = 6708,
        romhack_cam = true,

        startLocations = {
            [0] = { 0, 0, 3618 },
        },
        shineStart = { 0, -63, 525 },

        objLocations = {
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 0,    -243, 525 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 0,    510,  -300, 0, 0, 0x4000 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        1280, 3942, 1269, 1, 0, 0x0,   -0x4000 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        -11,  -81,  2390, 0, 1, 0x0,   0x0 },
        },

        itemBoxLocations = {
            { -1415, 79,   122 },
            { -886,  79,   -650 },
            { -1387, 79,   -1423 },
            { -2668, 79,   -1426 },
            { -2687, 79,   116 },
            { 1926,  79,   -1367 },
            { 2692,  79,   -2526 },
            { 3422,  811,  98 },
            { 900,   1389, 2350 },
            { -1940, 1389, 2320 },
            { -1940, 1389, -600 },
            { 260,   2127, -600 },
            { -260,  3100, -600 },
            { 260,   4073, -600 },
            { 502,   4975, -550 },
            { -400,  2080, -2250 },
            { -3536, 160,  -3705 },
            { -1242, 160,  -3957 },
            { -15,   595,  -3493 },
            { -10,   1056, -1410 },
            { 42,    2034, 2795 },
            { 2870,  1138, -2640 },
        },
    },
    {
        level = LEVEL_DDD,
        course = COURSE_DDD,
        saveName = "ddd",
        area = 2,
        name = "Bowser's Sub",
        tex = "painting_27",
        noWater = true,
        center = { 3930, 900 },
        levelSize = 5200,

        startLocations = {
            [0] = { -300, -1924, 0 },
        },
        shineStart = { 3400, -3159, -500 },

        objLocations = {
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        1630,  110,   4260, 0, 1, 0x0,    0x2000 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        6627,  -4087, 2927, 1, 0, 0x0,    -0x5102 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 5510,  864,   2410, 0, 0, 0x0,    -0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 4160,  854,   3590, 0, 0, 0x0,    0x0 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 2610,  694,   950,  0, 0, 0x0,    -0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 2004,  874,   -448, 0, 0, 0x0,    -0x8000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -2000, -2612, 485,  0, 0, 0x4000, 0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -2000, -2612, 0,    0, 0, 0x4000, 0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -2000, -2612, -485, 0, 0, 0x4000, 0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -2000, -2312, 485,  0, 0, 0x4000, 0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -2000, -2312, 0,    0, 0, 0x4000, 0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -2000, -2312, -485, 0, 0, 0x4000, 0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -2000, -2012, 485,  0, 0, 0x4000, 0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -2000, -2012, 0,    0, 0, 0x4000, 0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -2000, -2012, -485, 0, 0, 0x4000, 0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -2000, -1712, 485,  0, 0, 0x4000, 0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -2000, -1712, 0,    0, 0, 0x4000, 0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -2000, -1712, -485, 0, 0, 0x4000, 0x4000 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        -2299, -2756, 5,    2, 0, 0x0,    0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 945,   -3618, 290,  0, 0, 0x0,    -0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 945,   -3122, -298, 0, 0, 0x0,    -0x4000 }
        },

        itemBoxLocations = {
            { 4889, -3927, 4433 },
            { 3274, -3927, 4612 },
            { 2709, -3927, 4001 },
            { 1606, -3927, 2751 },
            { 4307, -3625, -2184 },
            { 5856, -3792, -832 },
            { 4884, -3688, 1833 },
            { 3046, -3648, 2011 },
            { 2022, -3726, 540 },
            { 1833, -3923, -1461 },
            { 3900, 731,   -600 },
            { 3900, 731,   518 },
            { 3900, 731,   1896 },
            { 6800, 270,   -150 },
            { 6800, 270,   -850 },
            { 5550, 1038,  3575 },
            { 2974, 1038,  3584 },
            { 5635, 1089,  1139 },
            { 1627, 1089,  1239 },
            { 2100, 1089,  -1600 },
            { 6260, 270,   4356 },
            { 5475, 270,   5086 },
            { 2686, 270,   5303 },
        },
    },
    {
        level = LEVEL_SL,
        course = COURSE_SL,
        saveName = "sl",
        area = 1,
        tex = "painting_13",
        noWater = true,

        startLocations = {
            [0] = { 5241, 2024, 143 },
        },
        shineStart = { 304, 1512, -4543 },

        objLocations = {
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, 4374, 1229, 4359, 0, 1, 0x0, -0x63cf },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -480, 3584, 1350, 1, 0, 0x0, 0x6000 },
        },

        itemBoxLocations = {
            { 700,   4511, 690 },
            { 325,   1112, -4499 },
            { -3380, 1293, -4140 },
            { -4211, 1252, -4723 },
            { -3592, 1232, -5732 },
            { -6560, 2208, -5080 },
            { -6760, 2208, -1360 },
            { -6880, 2017, 1000 },
            { -6271, 1492, 4764 },
            { -5450, 1184, 5900 },
            { -4700, 1184, 5850 },
            { -5688, 939,  3270 },
            { -4960, 959,  3289 },
            { -4025, 962,  3313 },
            { 3608,  1785, -3152 },
            { 2199,  1698, -3277 },
            { 1864,  1696, -2750 },
            { 1529,  1696, -2223 },
            { -768,  1696, -2500 },
            { 4358,  2003, 4984 },
            { 2553,  1184, 5653 },
            { 1694,  1184, 5282 },
            { 2272,  1184, 3945 },
            { 3131,  1184, 4317 },
            { 2365,  1184, 4778 },
        },
    },
    {
        level = LEVEL_WDW,
        course = COURSE_WDW,
        saveName = "wdw",
        area = 1,
        noWater = true,
        tex = "painting_07",
        levelSize = 4600,

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

        itemBoxLocations = {
            { 3388,  1440, 1155 },
            { 3360,  1440, 2660 },
            { -3739, 160,  4120 },
            { -3689, 160,  3205 },
            { -2200, 544,  1145 },
            { -2200, 2464, 3500 },
            { 16,    3360, 3584 },
            { 1550,  4256, 100 },
            { 3724,  3236, -3610 },
            { 4398,  3236, -3585 },
            { 4398,  3236, -3023 },
            { 3735,  3236, -3045 },
            { 943,   3744, -1779 },
            { 2794,  1079, -1477 },
            { 1680,  1901, 2207 },
            { -2075, 2976, -524 },
            { -2200, 2464, -3700 },
            { -788,  3232, -3588 },
            { -3097, 3744, -3056 },
            { -3471, 3744, -2695 },
            { -2723, 3744, -3417 },
            { -1446, 4000, -1444 },
            { -882,  4018, 1164 },
            { -1129, 3857, 1404 },
            { -759,  2336, 2222 },
            { -2066, 1312, 211 },
            { -2034, 1312, 938 },
            { 527,   544,  -120 },
            { 529,   544,  816 },
            { 3330,  314,  2910 },
            { 610,   160,  4240 },
            { 610,   160,  2910 },
        },
    },
    {
        level = LEVEL_WDW,
        course = COURSE_WDW,
        saveName = "wdw2",
        area = 2,
        noWater = true,
        tex = "painting_09",
        name = "Wet-Dry Town",
        romhack_cam = true,
        levelSize = 3800,
        center = { -760, 760 },

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

        itemBoxLocations = {
            { -800,  -2399, -200 },
            { -770,  -1631, 3600 },
            { 1820,  -1247, 1020 },
            { -240,  -1631, 2290 },
            { -1260, -1631, 2310 },
            { -1779, -2399, 3644 },
            { -2930, -1119, 2560 },
            { -2930, -1119, 3080 },
            { -2930, -1119, 2040 },
            { -3720, -991,  520 },
            { 100,   -1631, -1500 },
            { 1655,  -2348, -1293 },
            { -770,  -146,  2790 },
        },
    },
    {
        level = LEVEL_TTM,
        course = COURSE_TTM,
        saveName = "ttm",
        area = 1,
        tex = "painting_08",
        levelSize = 6700,

        startLocations = {
            [0] = { 95, -3332, 5693 },
        },
        shineStart = { -3215, -2543, -3750 },

        objLocations = {
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 3281, -1510, 3541, 0, 0, 0,   24576 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 3800, -1510, 3000, 0, 0, 0,   24576 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        5009, -3848, 5124, 0, 1, 0x0, -0x5755 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        857,  2309,  609,  1, 0, 0x0, 0x603c },
        },

        itemBoxLocations = {
            { -3713, -3991, 3530 },
            { -1600, -1580, -2500 },
            { -1200, -1529, -3250 },
            { -848,  -3288, -4365 },
            { 1450,  -2712, -4250 },
            { 1840,  -2726, -3600 },
            { 2550,  -2675, -3400 },
            { 3261,  -2713, -4092 },
            { 4150,  -2713, -2800 },
            { -1035, -556,  -3400 },
            { -1500, -761,  -2750 },
            { -1850, 160,   -2850 },
            { 4302,  -3214, 1655 },
            { 4613,  -3214, 1648 },
            { -2639, -1988, 2547 },
            { -3141, -1987, 3337 },
            { -3213, -2043, 2675 },
            { -2423, -1957, 3177 },
            { 3542,  -1157, 3293 },
            { 1624,  780,   1918 },
            { 1800,  1241,  1050 },
            { 2408,  1624,  2020 },
            { 1088,  2466,  -304 },
            { 1436,  2466,  83 },
            { 1715,  2466,  392 },
            { -899,  1395,  -1071 },
            { 2043,  -418,  -2994 },
            { 909,   -176,  -3150 },
            { -472,  150,   -3025 },
            { 126,   22,    -2925 },
            { 1479,  -283,  -2844 },
            { 2512,  -1346, 1330 },
        },
    },
    {
        level = LEVEL_THI,
        course = COURSE_THI,
        saveName = "thi",
        area = 2,
        tex = "painting_10",
        noWater = true,
        name = "Tiny Island",
        borderSize = 42,
        levelSize = 5000,

        startLocations = {
            [0] = { -2119, 110, 2058 },
        },
        shineStart = { 3, 1327, -448 },

        itemBoxLocations = {
            { -1866, -607, 311 },
            { -1779, -453, -1753 },
            { -1485, 7,    112 },
            { -916,  7,    1144 },
            { -142,  -607, 1992 },
            { 1988,  -689, 2094 },
            { 1849,  -453, -183 },
            { 2035,  -300, -1687 },
            { 0,     -607, -4500 },
            { -952,  314,  -1114 },
            { 687,   -453, -1551 },
        },
    },
    {
        level = LEVEL_THI,
        course = COURSE_THI,
        saveName = "thi2",
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

        itemBoxLocations = {
            { 2600,  3386,  -2400 },
            { -4414, 365,   -2157 },
            { -6562, -2809, 6132 },
            { -6606, -2809, 7171 },
            { -5857, -2809, 6683 },
            { -7207, -2809, 6625 },
            { -5913, -3423, -2252 },
            { -6000, -3423, -1320 },
            { -5434, -3423, -1790 },
            { -6366, -3423, -1877 },
            { -6161, -1887, -3815 },
            { -6196, -1887, -4854 },
            { -6234, -1887, -5998 },
            { -69,   -1477, -5112 },
            { -98,   -1477, -4811 },
            { 4139,  -1720, -5454 },
            { 6863,  -1375, -5676 },
            { 6022,  -1887, -633 },
            { 7098,  -2399, 1281 },
            { 3980,  -351,  2706 },
            { 4730,  -1375, 3492 },
            { -461,  -3423, 6080 },
            { -596,  -3423, 7229 },
            { -555,  -3423, 7747 },
            { 5896,  -2399, 4942 },
            { 6415,  -2399, 4900 },
            { 6829,  -2399, 4866 },
            { 115,   2362,  400 },
            { -3176, 672,   371 },
            { -2910, -351,  3847 },
            { -1974, -351,  3847 },
            { -4054, -351,  3847 },
        },
    },
    {
        level = LEVEL_THI,
        course = COURSE_THI,
        saveName = "thi3",
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
            [10] = { -1498, 512, -1501 },
            [11] = { -1304, 1024, 276 },
            [12] = { -1824, 1024, 286 },
            [13] = { -1695, 1434, 1527 },
            [14] = { -1110, 1434, 1407 },
            [15] = { -387, 1434, 984 },
        },
        shineStart = { 240, 1118, 189 },

        objLocations = {
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 240,   932,  189,   0, 0, 0x0, 0x0 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        -1861, 512,  -1501, 0, 1, 0x0, 0x4000 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        -500,  1843, 0,     1, 0, 0x0, 0xC000 },
        },

        itemBoxLocations = {
            { -1920, 1696, -1040 },
            { -1914, 1491, -1909 },
            { -683,  1594, 1284 },
            { -1380, 1594, 1512 },
            { 510,   1168, 2152 },
            { -238,  1874, -1319 },
            { 1038,  1800, -823 },
            { 1590,  1910, 160 },
            { 1038,  1826, 998 },
            { -523,  1704, -500 },
            { -1838, 1932, 338 },
            { 0,     2003, 0 },
            { 0,     2250, 1780 },
            { 0,     2250, -1780 },
            { 1780,  2250, 0 },
            { -1780, 2250, 0 },
        },
    },
    {
        level = LEVEL_TTC,
        course = COURSE_TTC,
        saveName = "ttc",
        area = 1,
        levelSize = 2000,
        tex = "painting_26",

        startLocations = {
            [0] = {1384, -3822, -515},
        },
        shineStart = { 0, 4635, 0 },

        objLocations = {
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -1047, 6011,  -741, 1, 0, 0x0, 0x6022 },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, 176,   -5211, 1660, 0, 1, 0x0, 0x4000 },
        },

        itemBoxLocations = {
            { -1140, -3843, -1620 },
            { -130,  -4248, -1050 },
            { -1730, -3331, 980 },
            { 620,   -5051, 1540 },
            { 840,   -2327, 860 },
            { 380,   -2327, 1319 },
            { -1470, -1293, -1040 },
            { -1144, -832,  -731 },
            { -1511, -832,  -1099 },
            { 520,   141,   1500 },
            { 1240,  141,   840 },
            { -1850, 141,   -950 },
            { -1333, 447,   1116 },
            { -1011, 1389,  532 },
            { 660,   1511,  1880 },
            { -1475, 1225,  -1175 },
            { -1181, 1225,  -881 },
            { -887,  1225,  -587 },
            { -1050, 2274,  -790 },
            { -1247, 2786,  -966 },
            { -400,  3478,  1880 },
            { -40,   4020,  -1280 },
            { 1883,  4020,  550 },
            { -1260, 4179,  16 },
            { 48,    6171,  -1279 },
            { 2200,  7211,  2210 },
            { 1680,  5444,  1680 },
            { 2169,  5444,  2169 },
            { 1653,  5444,  2191 },
            { 2149,  5444,  1684 },
            { -22,   141,   -1662 },
            { -1272, -2286, -1282 },
            { 1057,  -1774, -775 },
        },
    },
    {
        level = LEVEL_RR,
        course = COURSE_RR,
        saveName = "rr",
        area = 1,
        tex = "painting_18",
        noFlySpawn = true,
        noSlide = true,

        startLocations = {
            [0] = { 1822, -116, -50 },
        },
        shineStart = { -506, -956, -50 },

        objLocations = {
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -5137, -1782, -42,   0, 1, 0,   0 },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -4160, 6451,  -5890, 1, 0, 0x0, 0x0 },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, 2615,  -1833, 2092,  2, 3, 0x0, 0x4000 },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, 5550,  3333,  -2360, 3, 2, 0x0, -0x4000 },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, -5850, -1116, 4950,  4, 5, 0x0, 0x4000 },
            { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, 3700,  -732,  6600,  5, 4, 0x0, 0x4000 },
        },

        itemBoxLocations = {
            { -2950, -137,  -50 },
            { -5850, -956,  -50 },
            { -7071, -1622, -31 },
            { -5800, -342,  -50 },
            { -5300, -342,  -50 },
            { -4550, 732,   -50 },
            { -5050, 886,   -50 },
            { -5850, 1193,  50 },
            { 200,   -956,  1249 },
            { 1032,  -956,  1238 },
            { 168,   -956,  -1351 },
            { 1104,  -956,  -1363 },
            { 5040,  2116,  280 },
            { 5016,  3979,  4060 },
            { 1450,  3321,  -2352 },
            { -3428, 6611,  -5128 },
            { -4200, 6611,  -4450 },
            { -4970, 6611,  -5120 },
            { 1902,  3243,  -636 },
            { -844,  1850,  -160 },
            { -6750, 2524,  -50 },
            { -2694, 2524,  -50 },
            { -5814, 2524,  -49 },
            { -4774, 2524,  -47 },
            { -3631, 2524,  -46 },
            { -957,  2972,  -134 },
            { 2572,  1193,  -1629 },
            { 466,   -2902, 4733 },
            { 778,   -2902, 4729 },
            { -705,  -2799, 6575 },
            { -1258, -1775, 6575 },
            { -3612, -1569, 4772 },
            { 6383,  -1391, 6562 },
            { 5973,  -982,  6567 },
            { 5538,  -777,  6547 },
            { 790,   -1366, 6580 },
            { -4844, -4438, 6622 },
            { -3330, 3382,  -5485 },
            { -3330, 3382,  -4652 },
            { -4200, 3539,  -3078 },
            { -6550, 4102,  -2320 },
            { -7743, 4512,  -3823 },
        },
    },
    {
        level = LEVEL_CASTLE_GROUNDS,
        course = 0,
        saveName = "cg",
        area = 1,
        tex = "painting_14",
        music = SEQ_LEVEL_INSIDE_CASTLE,
        noWater = true,

        startLocations = {
            [0] = { -1328, 1260, 4664 },
        },
        shineStart = { 0, 1066, -1200 },

        objLocations = {
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -3383, -550,  -2025, 0, 0, 0 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        1370,  3174,  -4020, 0, 1, 0x0, -0x8000 },
            { id_bhvSTPipe,                  E_MODEL_BITS_WARP_PIPE,        -5350, 343,   50,    1, 0, 0x0, 0x4000 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -3790, -1250, -5980 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -3790, -1250, -5680 },
        },

        itemBoxLocations = {
            { -440,  3334,  -5000 },
            { 0,     3334,  -5220 },
            { 440,   3334,  -5000 },
            { -500,  -351,  -1200 },
            { -500,  -351,  -576 },
            { -500,  -351,  -1824 },
            { 2385,  225,   1950 },
            { 5968,  -1170, 3557 },
            { 6465,  -1170, 3670 },
            { 4662,  -1170, 3274 },
            { 4035,  565,   -670 },
            { 4126,  565,   -399 },
            { -5642, 585,   3371 },
            { -5823, 420,   1067 },
            { -6128, 645,   -2771 },
            { -3800, -1068, -4858 },
            { -4300, -1068, -4858 },
            { -4800, -1068, -4858 },
            { 5956,  812,   -3706 },
            { 6436,  858,   -3640 },
            { 6955,  917,   -3603 },
            { -1946, 748,   2250 },
        },
    },
    {
        level = LEVEL_CASTLE_COURTYARD,
        course = 0,
        saveName = "cc",
        area = 1,
        tex = "painting_12",
        music = SEQ_LEVEL_INSIDE_CASTLE,
        noWater = true,
        levelSize = 3800,
        center = { 0, -1720 },

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

        itemBoxLocations = {
            { 2277,  -44, -1800 },
            { 0,     110, -2100 },
            { -2397, -44, -1290 },
            { -3300, 160, -800 },
            { 3300,  160, -800 },
            { 0,     160, -488 },
        },
    },
    {
        level = LEVEL_PSS,
        course = COURSE_PSS,
        saveName = "pss",
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
        itemBoxLocations = {
            { 3200,  6304,  -5631 },
            { 3200,  6304,  -5331 },
            { 3200,  6304,  -5931 },
            { -1400, 2858,  2177 },
            { -1400, 2858,  1877 },
            { -1400, 2858,  2477 },
            { 1861,  -1865, -2890 },
            { 2161,  -1865, -2890 },
            { 1561,  -1865, -2890 },
            { -6360, -4474, 3700 },
            { -6060, -4474, 3700 },
            { -6660, -4474, 3700 },
            { -7180, -4427, 5670 },
        },
    },
    {
        level = LEVEL_SA,
        course = COURSE_SA,
        saveName = "sa",
        area = 1,
        tex = "painting_24",
        levelSize = 3100,
        maxHeight = 10000, -- just for coin rush
        romhack_cam = true,
        noWater = true,

        startLocations = {
            [0] = { 0, -3607, 2500 },
            [1] = { 957, -3607, 2310 },
            [2] = { 1768, -3607, 1768 },
            [3] = { 2310, -3607, 957 },
            [4] = { 2500, -3607, 0 },
            [5] = { 2310, -3607, -957 },
            [6] = { 1768, -3607, -1768 },
            [7] = { 957, -3607, -2310 },
            [8] = { 0, -3607, -2500 },
            [9] = { -957, -3607, -2310 },
            [10] = { -1768, -3607, -1768 },
            [11] = { -2310, -3607, -957 },
            [12] = { -2500, -3607, 0 },
            [13] = { -2310, -3607, 957 },
            [14] = { -1768, -3607, 1768 },
            [15] = { -957, -3607, 2310 },
        },

        itemBoxLocations = {
            { 2500,  -4447, 2500 },
            { -2500, -4447, 2500 },
            { 2500,  -4447, -2500 },
            { -2500, -4447, -2500 },
            { 0,     -4447, 1250 },
            { -1250, -4447, 0 },
            { 0,     -4447, -1250 },
            { 1250,  -4447, 0 },
        },

        shineStart = { 0, -4242, 0 },
    },
    {
        level = LEVEL_BOWSER_1,
        course = COURSE_BITDW,
        saveName = "b1",
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

        itemBoxLocations = {
            { 0,     467, 1000 },
            { 707,   467, 707 },
            { 1000,  467, 0 },
            { 707,   467, -707 },
            { 0,     467, -1000 },
            { -707,  467, -707 },
            { -1000, 467, 0 },
            { -707,  467, 707 },
        },

        shineStart = { 0, 467, 0 },
    },
    {
        level = LEVEL_BOWSER_2,
        course = COURSE_BITFS,
        saveName = "b2",
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

        itemBoxLocations = {
            { 0,     1389, 1000 },
            { 707,   1389, 707 },
            { 1000,  1389, 0 },
            { 707,   1389, -707 },
            { 0,     1389, -1000 },
            { -707,  1389, -707 },
            { -1000, 1389, 0 },
            { -707,  1389, 707 },
        },

        shineStart = { 0, 1389, 0 },
    },
    {
        level = LEVEL_BOWSER_3,
        course = COURSE_BITS,
        saveName = "b3",
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

        itemBoxLocations = {
            { 0,     467, 1000 },
            { 707,   467, 707 },
            { 1000,  467, 0 },
            { 707,   467, -707 },
            { 0,     467, -1000 },
            { -707,  467, -707 },
            { -1000, 467, 0 },
            { -707,  467, 707 },
        },

        shineStart = { 0, 467, 0 },
    },
}

-- rom hacks
hackData = {
    --[[
    ["green_screen_level"] = { -- example
        {
            name = "Green Screen",
            level = LEVEL_CASTLE_COURTYARD,
            course = 0,
            area = 1,
            tex = get_texture_info("painting_default"), -- for outside APIs, use a texture (strings only work for textures in the folder for THIS mod)
            noWater = true,
            lobby = true, -- set this for the level loaded when loading the mod

            startLocations = {
                [0] = { -3000, 1120, 0 },
            },
            shineStart = { 0, 260, 0 },

            itemBoxLocations = {
                { 0, 220, -1000 },
                { 0, 220, 1000 },
            },
        },
    }
    ]]
}

thisLevel = levelData[1]
BASE_LEVELS = #levelData
LOBBY_LEVEL = BASE_LEVELS - 6
arenaSpawnLocations = {}
arenaItemBoxLocations = {}
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
        thisLevel.noSlide = true
    end
    if arenaSpawnLocations[0] then
        thisLevel.startLocations = arenaSpawnLocations
    end
    arenaSpawnLocations = {}
    if arenaItemBoxLocations and #arenaItemBoxLocations ~= 0 then
        thisLevel.itemBoxLocations = arenaItemBoxLocations
    end
    arenaItemBoxLocations = {}

    if DEBUG_MODE then
        reload_obj_data(thisLevel)
    end
end

function go_to_mario_start(localIndex, globalIndex, spawning)
    local m = gMarioStates[localIndex]
    if m.action == ACT_CAPTURED then return end
    m.invincTimer = 90 -- 3 seconds
    local pos = {}
    if thisLevel.startLocations and thisLevel.startLocations[1] then
        local location = thisLevel.startLocations
            [(globalIndex + gGlobalSyncTable.spawnOffset) % (#thisLevel.startLocations + 1)]
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
        if not DEBUG_MODE then
            pos[1] = pos[1] + ((globalIndex) % 4) * 100 - 150
            pos[3] = pos[3] + ((globalIndex) // 4) * 100 - 150
        end
        if (not spawning) and gGlobalSyncTable.gameMode > 0 and gGlobalSyncTable.gameMode < 3 then return end
    end
    if (not spawning) and gGlobalSyncTable.gameMode == 4 and gPlayerSyncTable[localIndex].team ~= 2 then return end

    m.pos.x = pos[1]
    m.pos.z = pos[3]
    if spawning then
        m.pos.y = pos[2]
        m.vel.y = 0
        mario_set_forward_vel(m, 0)
        m.marioObj.oPosX = pos[1]
        m.marioObj.oPosZ = pos[3]
        m.squishTimer = 0
        m.bounceSquishTimer = 0
        mario_drop_held_object(m)
        if m.riddenObj ~= nil then
            obj_mark_for_deletion(m.riddenObj)
            m.riddenObj = nil
        end
        local centerX, centerZ = 0, 0
        if thisLevel.center then
            centerX, centerZ = thisLevel.center[1], thisLevel.center[2]
        end
        m.faceAngle.y = obj_angle_to_point(m.marioObj, centerX, centerZ)
        set_mario_action(m, ACT_SPAWN_SPIN_AIRBORNE, 0)
        if localIndex == 0 then
            showGameResults = false
            if thisLevel.romhack_cam then
                m.area.camera.defMode = CAMERA_MODE_ROM_HACK
            end
            m.floor = collision_find_floor(m.pos.x, m.pos.y, m.pos.z)
            set_camera_mode(m.area.camera, m.area.camera.defMode, 0)
            m.marioObj.oPosX, m.marioObj.oPosY, m.marioObj.oPosZ = m.pos.x, m.pos.y, m.pos.z
            soft_reset_camera_fix_bug(m.area.camera)
            warp_camera(m.pos.x - gLakituState.curPos.x, m.pos.y - gLakituState.curPos.y, m.pos.z - gLakituState.curPos
            .z)
            skip_camera_interpolation()
            m.statusForCamera.pos.y = m.pos.y
            m.statusForCamera.faceAngle.y = m.faceAngle.y
            m.area.camera.yaw = m.faceAngle.y

            set_ttc_speed_setting(1)
            gMarioStates[0].numStars = 0
            save_file_set_using_backup_slot(true)
            save_file_set_flags(SAVE_FLAG_MOAT_DRAINED)
            save_file_clear_flags(SAVE_FLAG_HAVE_KEY_2)
            save_file_clear_flags(SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)

            gPlayerSyncTable[0].bulletTimer = 0
            gPlayerSyncTable[0].smallTimer = 0
            gPlayerSyncTable[0].star = false
            gPlayerSyncTable[0].mushroomTime = 0
            gMarioStates[0].flags = gMarioStates[0].flags & ~(MARIO_WING_CAP | MARIO_VANISH_CAP)
            gMarioStates[0].capTimer = 0
            stop_cap_music()
        end
    end
end

-- gets a random positon in the level
function random_valid_pos(y_, o)
    local y = y_ or 2000
    y = y + 2000
    local max = (thisLevel and thisLevel.levelSize) or 8972
    y = (thisLevel and thisLevel.maxHeight) or y
    y = y - 300
    local centerX, centerY = 0, 0
    if thisLevel.center then
        centerX, centerY = thisLevel.center[1], thisLevel.center[2]
    end
    local x = math.random(-max, max) + centerX
    local z = math.random(-max, max) + centerY
    if o then
        o.oPosX, o.oPosY, o.oPosZ = x, y, z
        o.oFloor = collision_find_floor(x, y, z)
        local LIMIT = 100
        while (o.oFloor == nil or is_hazard_floor(o.oFloorType) or o.oFloor.normal.y < 0.9) and LIMIT > 0 do
            LIMIT = LIMIT - 1
            x = math.random(-max, max) + centerX
            z = math.random(-max, max) + centerY
            o.oPosX, o.oPosY, o.oPosZ = x, y, z
            o.oFloor = collision_find_floor(x, y, z)
        end
        y = o.oFloorHeight + 120
    end
    return x, y, z
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
