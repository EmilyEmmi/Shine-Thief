-- does all hud stuff, such as the radar and menu

showGameResults = false
inMenu = false
showTimeDispTimer = 0
tipDispTimer = 0
local menuOption = 1
local menuID = 0
local stickCooldownX = 0
local stickCooldownY = 0
local menuTeam = 0
local menuVariant = 0
local menuGameMode = 0
local menuCurrX = 0
local menuCurrY = 0
local scrollCurrY = 0
local prevSelectedPainting = 0
local menuMotionNotReady = false

local menuDarkMode = (mod_storage_load("menuDarkMode") == "1")
noShakeOrFlash = (mod_storage_load("noShakeOrFlash") == "1")
local customPlayerList = (mod_storage_load("customPlayerList") ~= "0")
local menuMotionEnabled = (mod_storage_load("menuMotion") ~= "0")
quickRespawn = (mod_storage_load("quickRespawn") == "1")
local oldMapMenu = (mod_storage_load("oldMapMenu") == "1")

local prevPointCount = 0
local prevTimerNum = {}
local localGameTimer = 0
local frameCounter = 0
local currTip
local doVoteCalc = true
local votesNumber = { 0, 0, 0 }
local voteScreenTimer = 0
local rItem = 0
local rItem2 = 0
local musicState = 0

local menu_history = {}
local variant_list = {
    "\\#50ffff\\Random (No Air)",
    "\\#50ffff\\Random",
    "\\#ff5050\\None",
    "VARIANT_SPECIAL", -- special case
    "\\#f7b5b5\\Air Battle",
    "\\#4e8f3b\\Shell Rush",
    "\\#5100ff\\Moon Gravity",
    "\\#ff0051\\Boost To Win",
    "\\#b0aca9\\Bombs!!!",
    "\\#9000ff\\Air + Boost",
    "\\#ff3700\\Fire Power",
    "\\#fbffc7\\Double Jump",
    "\\#ffff40\\Star Power",
    "\\#4040ff\\Boomerang",
    "\\#ff9040\\Item Rain",
}
local variant_special_list = {
    "\\#ff8050\\Mode-Specific",
    "\\#ff8050\\Mode-Specific",
    "\\#ff9040\\Double Shine",
    "\\#ff00ea\\Blowout",
    "\\#ff00ea\\Blowout",
    "\\#c49316\\Greed",
    "\\#804040\\Lone Ranger",
    "\\#ff1e1e\\Drop",
}

local tip_general = {
    "Tip: This mod has OMM Rebirth support!",
    "Tip: Team mode can be set to random to randomly pick a number of teams or zero.",
    "Tip: If you get stuck, pause and select 'Respawn' to respawn.",
    "Mod created by EmilyEmmi, with help from EmeraldLockdown and resources from others.",
    "Tip: If someone offers to grant you 3 wishes, there's probably a catch.",
    "Tip: You can enter Spectator Mode in the menu.",
    "Tip: Turn on Disable Hazard Floors to allow players to walk on lava and quicksand.",
    "Tip: Variants can be set to Random to pick a random variant each game!",
    "Tip: Ceiling hanging is a lot faster than in vanilla.",
    "Tip: In this mod, you can kick out of a Triple Jump or Wall Kick.",
    "Tip: Players with a crown on the minimap are in the lead.",
    "Tip: If a room is constantly flooding, turn off the water. There may be a leak.",
    "Tip: Grabbing ceilings can be done out of more actions than in vanilla.",
    "Tip: You can change the item and special binds in the pause menu.",
    "Tip: You can now kick while holding onto a ceiling.",
}
local tip_game_mode = {
    { -- Shine Thief
        "Tip: When you have only 3 seconds left, the timer slows down.",
        "Tip: If you lose the Shine, you will always have at least 5 seconds left.",
        "Tip: A slide kick will instantly steal the Shine.",
        "Tip: The host can reset the Shine's position with /reset.",
        "Tip: The player holding the Shine moves a bit slower.",
        "Tip: In Team Mode, press ITEM_BUTTON while not holding an item to pass the Shine.",
        "Tip: After GAME_TIME, the shine timer will be halved.",
        "Tip: If the Shine falls off of the stage, it will return to its last valid position.",
    },
    { -- Balloon Battle
        "Tip: You'll be eliminated if you lose all of your balloons.",
        "Tip: Elimination will turn you into a Bob-Omb. You can explode another player!",
        "Tip: You can steal a Balloon by slide-kicking into another player.",
        "Tip: You can have up to 5 balloons.",
        "Tip: In Team Mode, press ITEM_BUTTON while not holding an item to share balloons with teammates.",
        "Tip: In Team Mode, bomb players can be revived by sharing a balloon with them.",
        "Tip: After GAME_TIME, the players or teams with the most balloons will enter Showtime.",
        "Tip: You can move during the countdown on some stages.",
    },
    { -- Balloon Attack
        "Tip: You'll lose a third of your points if you lose all of your Balloons.",
        "Tip: You'll get 3 points for sidelining a player.",
        "Tip: You can steal a Balloon by slide-kicking into another player.",
        "Tip: You can have up to 5 balloons.",
        "Tip: In Team Mode, press ITEM_BUTTON while not holding an item to share balloons with teammates.",
        "Tip: After GAME_TIME, the players or teams with the most points will enter Showtime.",
        "Tip: You can move during the countdown on some stages.",
    },
    { -- Coin Rush
        "Tip: Coins that fall off the map will respawn in a random location.",
        "Tip: You'll drop a third of your coins when hit (max of 15).",
        "Tip: You can steal another player's coins with a Slide Kick.",
        "Tip: Defeating enemies will also get you coins.",
        "Tip: If there aren't many coins in a course, you'll start with some.",
        "Tip: After GAME_TIME, the players or teams with the most coins will enter Showtime.",
        "Tip: Players can drop both yellow and blue coins.",
        "Tip: Blue coins are worth 5 coins. But you knew that, right?",
    },
    { -- Renegade Roundup
        "Tip: You can't see opponents that are far away.",
        "Tip: Renegades can save their teammates by touching the cages.",
        "Tip: Only physical attacks or the Boomerang can capture Renegades.",
        "Tip: Press A while captured to shout for help.",
        "Tip: Renegades can hit the Law.",
        "Tip: Renegades can move during the timer.",
        "Tip: The host move the cages with /move [NUM].",
        "Tip: Getting hit will temporarily reveal your location.",
    },
    { -- Moon Runners
        "Tip: If you have the least points, your HUD Moon will glow red.",
        "Tip: The host move the Moons with /move [NUM].",
        "Tip: A slide kick will instantly steal another player's Moon.",
        "Tip: In Team Mode, press ITEM_BUTTON while not holding an item to share Moons.",
        "Tip: Moons are NOT shared in Team Mode.",
        "Tip: If there aren't many Moons in a course, each player will start with one.",
        "Tip: If a Moon falls off of the stage, it will return to its last valid position.",
    },
}
local tip_variant = {
    "VARIANT_SPECIAL_TIP",
    "Renegades and players holding the Shine in Shine Thief will fly much slower.",
    "Press SPECIAL_BUTTON to spawn a shell. This can also be done in midair.",
    "You'll jump higher and fall slower. Hold Z to fall faster.",
    "Hold SPECIAL_BUTTON to boost!",
    "Press SPECIAL_BUTTON to throw bombs. Use the D-PAD to change the direction.",
    "Hold SPECIAL_BUTTON to boost! This can also be done while flying.",
    "Press SPECIAL_BUTTON to shoot a fireball!",
    "Press SPECIAL_BUTTON or A in midair to perform a Feather Jump.",
    "Press SPECIAL_BUTTON to use your star power!",
    "Throw your boomerang with SPECIAL_BUTTON!",
    "Items will fall from the sky!",
}
local tip_variant_special = {
    "Two players must each hold a Shine to win.",
    "Hold SPECIAL_BUTTON while standing still to blow up more balloons!",
    "Hold SPECIAL_BUTTON while standing still to blow up more balloons!",
    "Holding more coins will slow you down.",
    "No saving players! Avoid the Lone Ranger!",
    "You'll drop a Moon at the end of each round.",
}
local tip_item = {
    "Tip: Using a Mushroom lets you move faster AND steal SHINE_OR_BALLOON on any attack.",
    "Tip: You can throw items in front of you, behind you, or to the side with the D-PAD.",
    "Tip: The Feather can be used as a double jump or to steal SHINE_OR_BALLOON.",
    "Tip: You can dive, kick, or ground pound after using a feather.",
    "Tip: Green Shells will bounce off of walls.",
    "Tip: Green Shells can fly if Air Battle is active.",
    "Tip: Red Shells can fly to hit players.",
    "Tip: Red Shells will automatically target the player in front of them.",
    "Tip: The Boomerang can be thrown up to 3 times.",
    "Tip: The Boomerang can hurt players on its return, too.",
    "Tip: The Boomerang can steal SHINE_OR_BALLOON from other players.",
    "Tip: The Boomerang can pick up coins, Shines, and Moons, open cages, and capture Renegades.",
    "Tip: The POW Block hits any players standing on the ground.",
    "Tip: The Super Star makes you invincible and lets you attack players just by touching them!",
    "Tip: The Super Star does NOT make you faster.",
    "Tip: The Super Star steals SHINE_OR_BALLOON on any attack.",
    "Tip: Two players with a Super Star can hurt each other.",
    "Tip: The Super Star lasts 10 seconds.",
    "Tip: Players falling behind will get better items.",
    "Tip: You won't get very good items if you have a big lead.",
    "Tip: The Fire Flower can be used 5 times.",
    "Tip: The Bullet Bill item turns you into an explosive Bullet Bill for 5 seconds.",
    "Tip: The Bullet Bill can be canceled with the B button or by ground pounding.",
    "Tip: You can launch the Bullet Bill in different directions with the D-PAD.",
    "Tip: Only certain items can be obtained while close to victory.",
    "Tip: Some items have rarer, triple forms.",
    "Tip: Bananas can be thrown a far distance if you hold UP on the D-PAD.",
    "Tip: More powerful items will appear if Items are set to Frantic.",
    "Tip: Less powerful items will appear if Items are set to Skilled.",
    "Tip: Red/Green Shells will break if they hit a Banana, Bob-Omb, or another Red/Green Shell.",
    "Tip: You can avoid oncoming Red Shells by leading them into a wall or item.",
    "Tip: A sound effect will play when you're targetted by a Red or Blue Shell.",
    "Tip: Fireballs and Boomerangs won't collide with other items.",
    "Tip: The Blue Shell is an incredibly rare item that attacks whoever is winning!",
    "Tip: The only way to dodge the Blue Shell is to use a Mushroom with precise timing.",
    "Tip: Holding Bananas, Red/Green Shells, or Bob-Ombs will protect you from Red/Green Shells.",
    "Tip: Some items can be thrown faster or farther if you're moving fast.",
    "Tip: The Boo will steal an item from another player.",
    "Tip: If the Boo cannot steal an item, it'll give you Triple Mushrooms.",
    "Tip: The Boo can't steal another boo, that'd be silly!",
    "Tip: Turn on Arena-Style items, and you'll see what's in an item box before opening it!",
    "Tip: You can pick up sparkling dropped items, like Mushrooms and Stars.",
    "Tip: The Lightning Bolt is a rare, devastating item that stuns all players.",
    "Tip: The Lightning Bolt also makes all players drop their items.",
    "Tip: If you see someone with a Lighting Bolt, try to get somewhere safe.",
    "Tip: Strong attacks, such as punches and ground pounds, will cause players to drop items.",
}

local game_mode_list = {
    "\\#ff9040\\Cycle",
    "\\#50ffff\\Random",
    "\\#ffff40\\Shine Thief",
    "\\#ff5a5a\\Balloon Battle",
    "\\#ff5a5a\\Balloon Attack",
    "\\#ffff40\\Coin Rush",
    "\\#ff4040\\Renegade \\#4040ff\\Roundup",
    "\\#50ff50\\Moon Runners",
}
local game_mode_instruct = {
    { "Get the \\#ffff40\\Shine\\#ffffff\\!",       "%d seconds to win!" },
    { "\\#ff1e1e\\Eliminate\\#ffffff\\ all!",       "If you lose all of your balloons, you're out!" },
    { "Pop \\#ff5a5a\\Balloons\\#ffffff\\!",        "Get the most points in %d minute(s)!" },
    { "Collect \\#ffff40\\coins\\#ffffff\\!",       "Get the most coins in %d minute(s)!" },
    { "Catch the \\#ff4040\\Renegades\\#ffffff\\!", "Capture all in %d minute(s)!",                 "Dodge the \\#4040ff\\Law\\#ffffff\\!", "Evade capture for %d minute(s)!" }, -- only game mode that uses the other two args
    { "Get \\#50ff50\\Moons\\#ffffff\\!",           "Losers will be eliminated in %d:%02d!" },
}

local SPECIAL_BUTTON_STRING = "Y"
local ITEM_BUTTON_STRING = "X"
if _G.OmmEnabled then
    tip_game_mode[1][3] = "Tip: A slide kick or Cappy attack will instantly steal the Shine."
    tip_game_mode[2][3] = "Tip: You can steal a Balloon with a slide kick or Cappy attack."
    tip_game_mode[3][3] = "Tip: You can steal a Balloon with a slide kick or Cappy attack."
    tip_game_mode[4][3] = "Tip: You can steal another player's coins with a slide kick or Cappy attack."
    tip_game_mode[5][3] = "Tip: Only physical attacks, the Boomerang, or Cappy can capture Renegades."
    tip_game_mode[6][3] = "Tip: A slide kick or Cappy attack will instantly steal another player's Moon."
    tip_general[1] = "Tip: After throwing Cappy, You can perform a homing attack by pressing the D-PAD."
    tip_general[10] = "Tip: The item and variant buttons change when using OMM."
    tip_variant[9] = "Tip: Press SPECIAL_BUTTON to perform a Feather Jump. This can be done in midair!"
end

local DEFAULT_MAP_SIZE = 8192

-- builds the new map menu based on the level data
function build_fancy_map_menu(menu)
    -- clear
    for i=1,#menu do
        menu[i] = nil
    end

    djui_hud_set_resolution(RESOLUTION_DJUI)
    local screenWidth = djui_hud_get_screen_width()
    local columns = screenWidth // 360
    menu.columns = columns
    menu.squareFormat = true
    local x = 0
    local y = 1
    table.insert(menu, {"Row 1", function(x)
        if x == 1 then
            start_random_level(true)
        elseif x == 2 then
            enter_menu(4)
        else
            new_game_set_settings(x-2)
        end
    end, currNum = 1, maxNum = math.min(#levelData + 2, columns)})
    if #levelData >= columns - 1 then
        for i=columns-1,#levelData do
            x = x + 1
            if x >= columns then
                x = 0
                y = y + 1
                table.insert(menu, {"Row "..y, function(x)
                    new_game_set_settings(x+columns*(menuOption-1)-2)
                end, currNum = 1, maxNum = columns})
            end
        end
        if x ~= 0 then
            table.insert(menu, {"Row "..y, function(x) new_game_set_settings(x+columns*(menuOption-1)-2) end, currNum = 1, maxNum = x})
        end
    end
end

-- menu data
local menu_data = {
    [1] = {
        { "Continue",      function() inMenu = false end },
        { "Respawn", function()
            on_pause_exit(false)
            inMenu = false
        end },
        { "Spectate",      function() spectator_mode() end },
        { "Options",       function() enter_menu(7) end },
        { "Restart",       function() new_game("redo") end,      true },
        { "New Game",      function() enter_menu(3) end,   true },
        { "Game Settings", function() enter_menu(5) end,   true },
        { "Open Character Select",
            function()
                _G.charSelect.set_menu_open(true)
                inMenu = false
            end,
            false,
            function()
                return not CS_ACTIVE
            end
        },
    },
    [2] = {
        { "Play Again",    function() new_game("redo") end,    true },
        { "Choose Map",      function() enter_menu(3) end, true },
        { "Options",       function() enter_menu(7) end },
        { "Game Settings", function() enter_menu(5) end, true },
        { "Open Character Select",
            function()
                _G.charSelect.set_menu_open(true)
                inMenu = false
            end,
            false,
            function()
                return not CS_ACTIVE
            end
        },
    },
    [3] = {
        { "Placeholder",   function(x) new_game_set_settings(x) end, currNum = 2, maxNum = #levelData },
        { "Random",        function() start_random_level(true) end },
        { "Custom",        function() enter_menu(4) end },
        { "Options",       function() enter_menu(7) end },
        { "Game Settings", function() enter_menu(5) end,             true },
        noScroll = true,
    },
    [4] = {
        {
            "Level",
            function(x)
                local course = x
                local level = course_to_level[course]
                new_game_set_settings(tostring(level) .. " " .. tostring(get_menu_option(4, 2)) ..
                    " " .. get_menu_option(4, 3))
            end,
            currNum = 0,
            minNum = 0,
            maxNum = #course_to_level
        },
        {
            "Area",
            function(x)
                local course = get_menu_option(4, 1)
                local level = course_to_level[course]
                new_game_set_settings(tostring(level) .. " " .. tostring(x) .. " " .. get_menu_option(4, 3))
            end,
            currNum = 1,
            maxNum = 7
        },
        {
            "Water",
            function(x)
                local course = get_menu_option(4, 1)
                local level = course_to_level[course]
                new_game_set_settings(tostring(level) .. " " .. tostring(get_menu_option(4, 2)) .. " " .. tostring(x))
            end,
            currNum = 0,
            minNum = 0,
            maxNum = 1,
            nameRef = { "\\#50ff50\\On", "\\#ff5050\\Off" },
        },
        { "Random", function()
            start_random_level()
        end },
        { "Game Settings", function() enter_menu(5) end },
    },
    [5] = {
        {
            "Game Mode",
            function(x)
                menuGameMode = x
                save_setting("gameMode", x)
            end,
            currNum = 0,
            minNum = -2,
            maxNum = (#game_mode_list - 3),
            nameRef = game_mode_list,
            runOnChange = true
        },
        {
            "Map Select",
            function(x)
                gGlobalSyncTable.mapChoice = x
                save_setting("mapChoice", x)
                if gGlobalSyncTable.gameState ~= 0 and gGlobalSyncTable.gameState ~= 3 then
                    return
                end

                if x == 0 then
                    gGlobalSyncTable.gameTimer = 0
                elseif x == 1 then
                    gGlobalSyncTable.gameTimer = 630 -- 21 seconds
                else
                    gGlobalSyncTable.gameTimer = 330 -- 11 seconds
                end
            end,
            currNum = 0,
            minNum = 0,
            maxNum = 2,
            nameRef = { "\\#ff5050\\Choose", "\\#50ff50\\Vote", "\\#50ffff\\Random" },
            runOnChange = true
        },
        {
            "Variant",
            function(x)
                menuVariant = x
                save_setting("variant", x)
            end,
            currNum = 0,
            minNum = -2,
            maxNum = #variant_list - 3,
            nameRef = variant_list,
            runOnChange = true
        },
        {
            "Teams",
            function(x)
                menuTeam = x
                save_setting("teamMode", x)
            end,
            currNum = 0,
            minNum = -1,
            maxNum = 8,
            excludeNum = 1,
            nameRef = { "\\#50ffff\\Random", "\\#ff5050\\Off" },
            runOnChange = true
        },
        {
            "Items",
            function(x)
                gGlobalSyncTable.items = x
                save_setting("items", x)
            end,
            currNum = 1,
            minNum = 0,
            maxNum = 3,
            nameRef = { "\\#ff5050\\Off", "\\#50ff50\\Normal", "\\#ffff50\\Frantic", "\\#ff8050\\Skilled" },
            runOnChange = true
        },
        {
            "Arena-Style Items",
            function(x)
                gGlobalSyncTable.arenaStyleItems = (x == 1)
                save_setting("arenaStyle", (x == 1))
            end,
            true,
            function() return gGlobalSyncTable.items == 0 end,
            currNum = 0,
            minNum = 0,
            maxNum = 1,
            nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
            runOnChange = true
        },
        {
            "Game Time (Min)",
            function(x)
                gGlobalSyncTable.maxGameTime = x
                save_setting("maxGameTime", x)
            end,
            currNum = 5,
            minNum = 1,
            maxNum = 30,
            runOnChange = true
        },
        {
            "Initial Balloons",
            function(x)
                gGlobalSyncTable.startBalloons = x
                save_setting("initBalloons", x)
            end,
            true,
            function() return menuGameMode >= 0 and menuGameMode ~= 1 and menuGameMode ~= 2 end,
            currNum = 3,
            minNum = 1,
            maxNum = 5,
            runOnChange = true
        },
        {
            "Disable Hazard Floors",
            function(x)
                gGlobalSyncTable.godMode = (x == 1)
                save_setting("godMode", (x == 1))
            end,
            currNum = 0,
            minNum = 0,
            maxNum = 1,
            nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
            runOnChange = true
        },
        {
            "Bomb Players",
            function(x)
                gGlobalSyncTable.bombSetting = x
                save_setting("bombSetting", x)
            end,
            true,
            function() return menuGameMode == 0 or menuGameMode == 4 end,
            currNum = 1,
            minNum = 0,
            maxNum = 2,
            nameRef = { "\\#ff5050\\Off", "One-Time", "Respawn" },
            runOnChange = true
        },
        {
            "Reduce Objects",
            function(x)
                gGlobalSyncTable.reduceObjects = (x == 1)
                save_setting("reduceObjects", (x == 1))
            end,
            currNum = 0,
            minNum = 0,
            maxNum = 1,
            nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
            runOnChange = true
        },
    },
    [6] = {
        {
            "Placeholder",
            function(x)
                if gGlobalSyncTable.gameTimer >= 180 and gGlobalSyncTable.voteExclude ~= (x + 1) then
                    gPlayerSyncTable[0].myVote = x + 1
                end
            end,
            currNum = 1,
            minNum = 0,
            maxNum = 2
        },
        { "Play Again",    function() new_game("redo") end,    true, function() return gGlobalSyncTable.gameState == 0 end },
        { "Choose Map",      function() enter_menu(3) end, true },
        { "Options",       function() enter_menu(7) end },
        { "Game Settings", function() enter_menu(5) end, true },
        noScroll = true,
    },
    [7] = {
        {
            "Item Bind",
            function(x)
                itemBindSelection = x
                setup_controls()
                mod_storage_save("iBind", tostring(x))
            end,
            currNum = itemBindSelection,
            minNum = 0,
            maxNum = 8,
            nameRef = { "X", "Y", "L", "R", "D-Pad", "X + D-Pad", "Y + D-Pad", "L + D-Pad", "R + D-Pad" },
            runOnChange = true,
        },
        {
            "Special Bind",
            function(x)
                specialBindSelection = x
                local baseButtons = {X_BUTTON, Y_BUTTON, L_TRIG, R_TRIG, A_JPAD}
                if x < 5 then
                    SPECIAL_BUTTON = baseButtons[x+1]
                    SPECIAL_OVERRIDE_BUTTON = 0
                else
                    SPECIAL_BUTTON = A_JPAD
                    SPECIAL_OVERRIDE_BUTTON = baseButtons[x-4]
                end
                setup_controls()
                mod_storage_save("sBind", tostring(x))
            end,
            currNum = specialBindSelection,
            minNum = 0,
            maxNum = 8,
            nameRef = { "X", "Y", "L", "R", "D-Pad", "X + D-Pad", "Y + D-Pad", "L + D-Pad", "R + D-Pad" },
            runOnChange = true,
        },
        {
            "Quick Respawn",
            function(x)
                quickRespawn = (x == 1)
                mod_storage_save("quickRespawn", tostring(x))
            end,
            currNum = (quickRespawn and 1) or 0,
            minNum = 0,
            maxNum = 1,
            nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
            runOnChange = true,
        },
        {
            "Reduce Shaking/Flashing",
            function(x)
                noShakeOrFlash = (x == 1)
                mod_storage_save("noShakeOrFlash", tostring(x))
            end,
            currNum = (noShakeOrFlash and 1) or 0,
            minNum = 0,
            maxNum = 1,
            nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
            runOnChange = true,
        },
        {
            "Menu Dark Mode",
            function(x)
                menuDarkMode = (x == 1)
                mod_storage_save("menuDarkMode", tostring(x))
            end,
            currNum = (menuDarkMode and 1) or 0,
            minNum = 0,
            maxNum = 1,
            nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
            runOnChange = true,
        },
        {
            "Custom Player List",
            function(x)
                customPlayerList = (x == 1)
                mod_storage_save("customPlayerList", tostring(x))
            end,
            currNum = (customPlayerList and 1) or 0,
            minNum = 0,
            maxNum = 1,
            nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
            runOnChange = true,
        },
        {
            "Old Map Menu",
            function(x)
                oldMapMenu = (x == 1)
                mod_storage_save("oldMapMenu", tostring(x))
            end,
            true,
            currNum = (oldMapMenu and 1) or 0,
            minNum = 0,
            maxNum = 1,
            nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
            runOnChange = true,
        },
        {
            "Reduce Menu Motion",
            function(x)
                menuMotionEnabled = (x ~= 1)
                mod_storage_save("menuMotion", tostring(-x+1))
            end,
            currNum = (menuMotionEnabled and 0) or 1,
            minNum = 0,
            maxNum = 1,
            nameRef = { "\\#ff5050\\Off", "\\#50ff50\\On" },
            runOnChange = true,
        },
    },
    [8] = {
        buildFunc = build_fancy_map_menu,
    },
}

function on_hud_render()
    -- no hud
    if _G.OmmEnabled then
        _G.OmmApi.omm_force_setting("hud", 3)
    else
        hud_hide()
    end

    if DEBUG_INVIS then return end
    if CS_ACTIVE and _G.charSelect.is_menu_open() then return end

    local sMario0 = gPlayerSyncTable[0]

    -- render starting locations
    if DEBUG_MODE and thisLevel.startLocations then
        djui_hud_set_resolution(RESOLUTION_N64)
        djui_hud_set_font(FONT_HUD)
        for i, v in pairs(thisLevel.startLocations) do
            local pos = {}
            pos = { x = v[1], y = v[2], z = v[3] }
            local out = { x = 0, y = 0, z = 0 }
            djui_hud_world_pos_to_screen_pos(pos, out)
            djui_hud_print_text(string.format("%x", i), out.x - 8, out.y - 16, 1)
            spawn_non_sync_object(id_bhvSparkleSpawn, E_MODEL_NONE, pos.x, pos.y, pos.z, nil)
        end
    end

    -- display probabilities for testing
    if DEBUG_MODE then
        djui_hud_set_resolution(RESOLUTION_DJUI)
        djui_hud_set_font(FONT_HUD)
        local itemRange, weightRange, maxWeight = get_item_probabilities(0, gGlobalSyncTable.arenaStyleItems)
        local screenHeight = djui_hud_get_screen_height()
        local scale = 0.75
        if screenHeight - #weightRange * 80 * scale < 0 then
            scale = screenHeight / (#weightRange * 80 + 40)
        end
        local x = 20
        local y = (screenHeight - #weightRange * 80 * scale) / 2
        local prevWeight = 0
        for i, weight in ipairs(weightRange) do
            x = 20
            local item = itemRange[i]
            local data = item_data[item]
            local tex = (data and data.tex) or get_texture_info(string.format("item_preview_%02d", item))
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_render_texture(tex, x, y, scale, scale)
            djui_hud_print_text(tostring(item), x, y, scale*1.5)
            x = x + 80 * scale
            local width = ((weight - prevWeight) / maxWeight) * 1000
            prevWeight = weight
            djui_hud_set_color(0, 255, 0, 255)
            djui_hud_render_rect(x, y, width, tex.height * scale)
            y = y + 80 * scale
        end
    end

    -- time until next game
    if gGlobalSyncTable.mapChoice ~= 0 and (gGlobalSyncTable.gameState == 0 or showGameResults) then
        djui_hud_set_resolution(RESOLUTION_DJUI)
        djui_hud_set_font(FONT_MENU)

        local scale = 0.75
        local x = 10
        local y = 0
        djui_hud_set_color(255, 255, 255, 255)
        if (not DEBUG_SCORES) and get_participant_count() < 2 then
            djui_hud_print_text("Waiting for players...", x, y, scale)
        elseif gGlobalSyncTable.mapChoice ~= 1 or (gGlobalSyncTable.gameTimer < 180 and gGlobalSyncTable.wonMap ~= -1) then
            djui_hud_print_text("Next game in " .. (gGlobalSyncTable.gameTimer // 30), x, y, scale)
        elseif gGlobalSyncTable.gameTimer >= 180 then
            djui_hud_print_text("Voting ends in " .. (gGlobalSyncTable.gameTimer // 30 - 5), x, y, scale)
        else
            djui_hud_print_text("Revoting in " .. (gGlobalSyncTable.gameTimer // 30), x, y, scale)
        end
    end

    frameCounter = frameCounter + 1
    if frameCounter >= 60 then frameCounter = 0 end

    -- menu render
    if inMenu then
        localGameTimer = gGlobalSyncTable.gameTimer
        return render_menu()
    end

    local shineIndexes = {}
    if gGlobalSyncTable.gameMode == 0 and gGlobalSyncTable.gameState == 2 then
        for i = 0, (MAX_PLAYERS - 1) do
            if get_player_owned_shine(i) ~= 0 then
                table.insert(shineIndexes, i)
            end
        end
    end

    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_MENU)

    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    if gGlobalSyncTable.gameState ~= 3 then
        showGameResults = false
        if gGlobalSyncTable.mapChoice == 1 then
            voteScreenTimer = 210 -- 7 sec
        end
    elseif showGameResults then
        djui_hud_set_font(FONT_NORMAL)
        local scale = 1
        local leftEdge = screenWidth * 0.5 - 300 * scale
        local topEdge = 10
        local x = leftEdge
        local y = topEdge

        calculate_placements()
        if gGlobalSyncTable.teamMode == 0 then
            for i, data in ipairs(placementTable) do
                if i > 16 then break end

                local index = data.index
                local sMario = gPlayerSyncTable[index]
                local np = gNetworkPlayers[index]
                djui_hud_set_color(0, 0, 0, 128);
                djui_hud_render_rect(x - 6, y - 3 * scale, 600 * scale + 6, 40 * scale);

                local playerColor = network_get_player_text_color_string(index)
                local place = data.placement
                local text = placeString(place)
                djui_hud_print_text_with_color(text, x, y, scale)
                x = x + 80 * scale
                render_player_head(index, x, y, scale * 2, scale * 2, false, true)
                x = x + 80 * scale
                text = playerColor .. np.name
                djui_hud_print_text_with_color(text, x, y, scale)
                text = tostring(sMario.points)
                local width = djui_hud_measure_text(text) * scale
                x = screenWidth * 0.5 + 300 * scale - width - 6
                djui_hud_set_color(255, 255, 64, 255)
                djui_hud_print_text(text, x, y, scale)

                y = y + 45 * scale
                x = leftEdge
            end
        else
            local alreadyDidTeam = {}
            local maxLinesPerTeam = 15 // ((gGlobalSyncTable.teamMode + 1) // 2)
            local teamTotal = 0
            topEdge = topEdge + 90 * scale -- down 2 lines
            for i, data in ipairs(placementTable) do
                local team = data.team
                if team ~= 0 and not alreadyDidTeam[team] then
                    alreadyDidTeam[team] = 1
                    teamTotal = teamTotal + 1
                    local place = data.placement
                    
                    if teamTotal == 1 then
                        leftEdge = 20
                    elseif teamTotal % 2 ~= 0 then
                        leftEdge = 20
                        topEdge = topEdge + maxLinesPerTeam * 45 * scale --
                    else
                        leftEdge = screenWidth - 20 - 600 * scale
                    end
                    x = leftEdge
                    y = topEdge

                    local color = deep_copy(TEAM_DATA[team][1])
                    color.r = math.max(0, color.r - 50)
                    color.g = math.max(0, color.g - 50)
                    color.b = math.max(0, color.b - 50)

                    djui_hud_set_color(color.r, color.g, color.b, 128)
                    djui_hud_render_rect(x - 6, y - 3 * scale, 600 * scale + 6, 40 * scale)

                    local text = placeString(place)
                    djui_hud_print_text_with_color(text, x, y, scale)
                    x = x + 80 * scale
                    if gGlobalSyncTable.gameMode ~= 4 then
                        text = TEAM_DATA[team][3]
                    else
                        if team == 2 then
                            text = "\\#4040ff\\Law"
                        else
                            text = "\\#ff4040\\Renegades"
                            plural = true
                        end
                    end
                    djui_hud_print_text_with_color(text, x, y, scale)
                    if gGlobalSyncTable.gameMode ~= 1 and gGlobalSyncTable.gameMode < 4 then
                        text = tostring(get_point_amount(data.index))
                        local width = djui_hud_measure_text(text) * scale
                        x = leftEdge + 600 * scale - width - 6
                        djui_hud_set_color(255, 255, 64, 255)
                        djui_hud_print_text(text, x, y, scale)
                    end
                    y = y + 40 * scale

                    local teamLines = 0
                    for a, data2 in ipairs(placementTable) do
                        local sMario = gPlayerSyncTable[data2.index]
                        local np = gNetworkPlayers[data2.index]

                        if np.connected and data2.team == team and ((not sMario.spectator) or get_player_owned_shine(i) ~= 0) then
                            x = leftEdge
                            teamLines = teamLines + 1

                            djui_hud_set_color(color.r, color.g, color.b, 128)
                            djui_hud_render_rect(x - 6, y - 3 * scale, 600 * scale + 6, 40 * scale);
                            local playerColor = network_get_player_text_color_string(a)

                            render_player_head(data2.index, x, y, scale * 2, scale * 2, false, true)
                            x = x + 80 * scale
                            text = playerColor .. np.name
                            djui_hud_print_text_with_color(text, x, y, scale)
                            if gGlobalSyncTable.gameMode ~= 0 then
                                text = tostring(sMario.points)
                                local width = djui_hud_measure_text(text) * scale
                                x = leftEdge + 600 * scale - width - 6
                                djui_hud_set_color(255, 255, 64, 255)
                                djui_hud_print_text(text, x, y, scale)
                            end

                            y = y + 40 * scale
                            if teamLines >= maxLinesPerTeam then break end
                        end
                    end
                end
            end
        end

        djui_hud_set_font(FONT_MENU)
        if not currTip then
            currTip = new_tip()
        end
        local tipText = currTip
        local scale3 = 0.5
        y = screenHeight - scale3 * 70
        width = djui_hud_measure_text(tipText) * scale3
        x = (screenWidth - width) * 0.5
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_print_text_with_color(tipText, x, y, scale3, 255)

        return
    else
        currTip = nil

        djui_hud_set_font(FONT_NORMAL)
        local np = {}
        np[1] = network_player_from_global_index(localWinner or 0)
        if localWinner2 ~= -1 then
            np[2] = network_player_from_global_index(localWinner2)
        end
        if not (np[1] or np[2]) then return end

        local text = ""
        local plural = false
        for i = 1, #np do
            local sMario = gPlayerSyncTable[np[i].localIndex]
            local sMario2
            if np[2] and i ~= 2 then
                sMario2 = gPlayerSyncTable[np[2].localIndex]
            end

            if sMario.team == 0 then
                local playerColor = network_get_player_text_color_string(np[i].localIndex)
                text = text .. playerColor .. np[i].name
            elseif i ~= 2 and sMario2 and sMario2.team == sMario.team then
                -- nothing
            elseif gGlobalSyncTable.gameMode == 4 then
                if sMario.team == 2 then
                    text = "\\#4040ff\\Law"
                else
                    text = "\\#ff4040\\Renegades"
                    plural = true
                end
            elseif TEAM_DATA[sMario.team] then
                text = text .. TEAM_DATA[sMario.team][3]
            end
            if i == 1 and sMario2 and (sMario2.team == 0 or sMario2.team ~= sMario.team) then
                plural = true
                text = text .. "\\#ffff40\\ + "
            end
        end

        if plural then
            text = text .. "\\#ffff40\\ win!"
        else
            text = text .. "\\#ffff40\\ wins!"
        end
        local scale = 3
        local width = djui_hud_measure_text(remove_color(text)) * scale

        local x = (screenWidth - width) * 0.5
        local y = screenHeight * 0.5 - 48 * scale

        djui_hud_set_color(0, 0, 0, 128);
        djui_hud_render_rect(x - 12, y - 6, width + 24, 36 * scale + 12);

        djui_hud_print_text_with_color(text, x, y, scale)
        return
    end

    djui_hud_set_resolution(RESOLUTION_DJUI)
    if gGlobalSyncTable.gameState == 2 then
        -- placement
        local x = 0
        local y = 0
        if gGlobalSyncTable.gameMode ~= 4 then
            djui_hud_set_font(FONT_MENU)
            local scale = 1.25
            local text = placeString(get_placement(0))
            local tWidth = djui_hud_measure_text(remove_color(text)) * scale
            x = screenWidth - tWidth - 30
            y = screenHeight - 80
            djui_hud_print_text_with_color(text, x, y, scale)
        end

        -- minimap/radar
        local mapWidth = screenWidth // 4
        x = screenWidth - mapWidth - 20
        y = screenHeight - mapWidth - 80
        local levelSize = (thisLevel and thisLevel.levelSize) or DEFAULT_MAP_SIZE
        local centerX, centerY = 0, 0
        if thisLevel and thisLevel.center then
            centerX, centerY = thisLevel.center[1], thisLevel.center[2]
        end
        djui_hud_set_color(180, 180, 180, 100)
        djui_hud_render_rect(x, y, mapWidth, mapWidth)

        -- first, determine the level size (expand if a player is beyond the bounds)
        for i = 0, MAX_PLAYERS - 1 do
            local m = gMarioStates[i]
            if (i == 0 or ((not is_dead(i)) and is_player_active(m) ~= 0)) and (math.abs(m.pos.x-centerX) > levelSize or math.abs(m.pos.z-centerY) > levelSize) then
                levelSize = math.max(math.abs(m.pos.x-centerX), math.abs(m.pos.z-centerY))
            end
        end

        -- render item boxes (minimap only)
        djui_hud_set_color(255, 255, 255, 200)
        local iBox = obj_get_first_with_behavior_id(id_bhvItemBox)
        while iBox do
            local tex = TEX_HUD_ITEM
            local item = iBox.oBalloonAppearance or 0
            if item and item ~= 0 then
                local data = item_data[item]
                tex = (data and data.tex) or get_texture_info(string.format("item_preview_%02d", item)) or tex
            end
            if iBox.oAction == 0 then
                local scale = 24 / tex.width
                local renderX = get_minimap_pos(iBox.oPosX, centerX, levelSize, mapWidth) + x - 12
                local renderY = get_minimap_pos(iBox.oPosZ, centerY, levelSize, mapWidth) + y - 12
                djui_hud_render_texture(tex, math.floor(renderX), math.floor(renderY), scale, scale)
            end
            iBox = obj_get_next_with_same_behavior_id(iBox)
        end
        -- render pipes (minimap only)
        if thisLevel.objLocations and #thisLevel.objLocations ~= 0 then
            local pipe = obj_get_first_with_behavior_id(id_bhvSTPipe)
            while pipe do
                -- reverse; check if any pipes LEAD to this one
                local pair = obj_get_first_with_behavior_id_and_field_s32(id_bhvSTPipe, 0x2F, pipe.oBehParams)
                if pair then
                    if pipe.oBehParams < 2 then
                        djui_hud_set_color(20, 255, 20, 255) -- green
                    elseif pipe.oBehParams < 4 then
                        djui_hud_set_color(50, 50, 255, 255) -- blue
                    else
                        djui_hud_set_color(255, 20, 20, 255) -- red
                    end
                    local tex = TEX_HUD_PIPE
                    local renderX = get_minimap_pos(pipe.oPosX, centerX, levelSize, mapWidth) + x - 12
                    local renderY = get_minimap_pos(pipe.oPosZ, centerY, levelSize, mapWidth) + y - 12
                    djui_hud_render_texture(tex, math.floor(renderX), math.floor(renderY), 1.5, 1.5)
                end
                pipe = obj_get_next_with_same_behavior_id(pipe)
            end
        end

        if gGlobalSyncTable.gameMode == 0 then
            local shineList = {}
            djui_hud_set_color(0, 0, 0, 100)
            local mark = obj_get_first_with_behavior_id(id_bhvShineMarker)
            while mark do
                local renderX = get_minimap_pos(mark.oPosX, centerX, levelSize, mapWidth) + x - 12
                local renderY = get_minimap_pos(mark.oPosZ, centerY, levelSize, mapWidth) + y - 12
                djui_hud_render_texture(gTextures.star, math.floor(renderX), math.floor(renderY), 1.5, 1.5)
                table.insert(shineList, mark.parentObj)
                mark = obj_get_next_with_same_behavior_id(mark)
            end

            for i, shine in ipairs(shineList) do
                djui_hud_set_color(255, 255, 255, 255)
                if get_shine_owner(shine.oBehParams) == -1 then
                    local renderX = get_minimap_pos(shine.oPosX, centerX, levelSize, mapWidth) + x - 20
                    local renderY = get_minimap_pos(shine.oPosZ, centerY, levelSize, mapWidth) + y - 20
                    djui_hud_render_texture(TEX_SHINE, math.floor(renderX), math.floor(renderY), 2.5, 2.5)
                end

                if obj_radar[i] == nil then
                    obj_radar[i] = { prevX = 0, prevY = 0, prevScale = 0 }
                end
                render_radar(TEX_SHINE, shine, obj_radar[i])
                djui_hud_set_resolution(RESOLUTION_DJUI)
            end
        elseif gGlobalSyncTable.gameMode == 3 then
            local coin = obj_get_first(OBJ_LIST_LEVEL)
            while coin do
                if (thisLevel.maxHeight == nil or thisLevel.maxHeight - coin.oPosY > 100) and coin.oInteractType & INTERACT_COIN ~= 0 then
                    local scale = 1
                    local tex = gTextures.coin
                    djui_hud_set_color(255, 255, 255, 100)
                    if coin.oDamageOrCoinValue == 5 then
                        scale = 1.5
                        tex = TEX_HUD_BLUE_COIN
                    end
                    djui_hud_set_font(FONT_HUD)
                    local renderX = get_minimap_pos(coin.oPosX, centerX, levelSize, mapWidth) + x - 8 * scale
                    local renderY = get_minimap_pos(coin.oPosZ, centerY, levelSize, mapWidth) + y - 8 * scale
                    djui_hud_render_texture(tex, math.floor(renderX), math.floor(renderY), scale, scale)
                end
                coin = obj_get_next(coin)
            end
        elseif gGlobalSyncTable.gameMode == 4 then
            local cage = obj_get_first_with_behavior_id(id_bhvRRCage)
            local i = 1
            while cage do
                if cage.oAction ~= 0 then
                    djui_hud_set_color(255, 255, 255, 255)
                    djui_hud_set_font(FONT_HUD)
                    local renderX = get_minimap_pos(cage.oPosX, centerX, levelSize, mapWidth) + x - 20
                    local renderY = get_minimap_pos(cage.oPosZ, centerY, levelSize, mapWidth) + y - 20
                    djui_hud_render_texture(TEX_CAGE, math.floor(renderX), math.floor(renderY), 2.5, 2.5)
                    djui_hud_print_text(tostring(cage.oAnimState), math.floor(renderX) + 4, math.floor(renderY) + 4, 2)
                    if cage.oAction == 2 and cage.oVelY > 0 then
                        djui_hud_print_text("Help!", math.floor(renderX) - 10, math.floor(renderY) - 20, 1)
                    end

                    if obj_radar[i] == nil then
                        obj_radar[i] = { prevX = 0, prevY = 0, prevScale = 0 }
                    end
                    render_radar(TEX_CAGE, cage, obj_radar[i], 50)
                    djui_hud_set_resolution(RESOLUTION_DJUI)
                end
                cage = obj_get_next_with_same_behavior_id(cage)
                i = i + 1
            end
        elseif gGlobalSyncTable.gameMode == 5 then
            djui_hud_set_color(0, 0, 0, 100)
            local mark = obj_get_first_with_behavior_id(id_bhvShineMarker)
            while mark do
                local renderX = get_minimap_pos(mark.oPosX, centerX, levelSize, mapWidth) + x - 12
                local renderY = get_minimap_pos(mark.oPosZ, centerY, levelSize, mapWidth) + y - 12
                djui_hud_render_texture(gTextures.star, math.floor(renderX), math.floor(renderY), 1.5, 1.5)
                mark = obj_get_next_with_same_behavior_id(mark)
            end

            djui_hud_set_color(255, 255, 255, 255)
            local moon = obj_get_first_with_behavior_id(id_bhvMoon)
            local i = 1
            while moon do
                local renderX = get_minimap_pos(moon.oPosX, centerX, levelSize, mapWidth) + x - 20
                local renderY = get_minimap_pos(moon.oPosZ, centerY, levelSize, mapWidth) + y - 20
                djui_hud_render_texture(TEX_MOON, math.floor(renderX), math.floor(renderY), 2.5, 2.5)

                if obj_radar[i] == nil then
                    obj_radar[i] = { prevX = 0, prevY = 0, prevScale = 0 }
                end
                render_radar(TEX_MOON, moon, obj_radar[i])
                djui_hud_set_resolution(RESOLUTION_DJUI)
                djui_hud_set_color(255, 255, 255, 255)
                i = i + 1
                moon = obj_get_next_with_same_behavior_id(moon)
            end
        end

        local allInvalid = true
        local star = false
        local myTeam = gPlayerSyncTable[0].team or 0
        for i = MAX_PLAYERS - 1, 0, -1 do -- go backwards so that our own player renders on top
            local m = gMarioStates[i]
            if i == 0 or ((not is_dead(i)) and is_player_active(m) ~= 0) then
                local valid = true
                local sMario = gPlayerSyncTable[i]
                if i ~= 0 and myTeam == 0 or sMario.team ~= myTeam then -- don't show far away members of other team
                    local dist = dist_between_objects(gMarioStates[i].marioObj, gMarioStates[0].marioObj)
                    if dist > 2500 then
                        valid = false
                    else
                        if gGlobalSyncTable.gameMode == 4 and not is_dead(0) then
                            allInvalid = false
                            if myTeam == 1 then
                                sneakingTimer = math.max(0, sneakingTimer - 30)
                            end
                            if gPlayerSyncTable[0].showOnMap and gPlayerSyncTable[0].showOnMap < 5 then
                                gPlayerSyncTable[0].showOnMap = 5
                            end
                        end
                        if sMario.star then
                            star = true
                        end
                    end
                end

                if gGlobalSyncTable.gameMode ~= 4 or valid or (sMario.showOnMap and sMario.showOnMap ~= 0) then
                    local scale = (i == 0 and 2.5) or 2
                    local renderX = get_minimap_pos(m.pos.x, centerX, levelSize, mapWidth) + x - 8 * scale
                    local renderY = get_minimap_pos(m.pos.z, centerY, levelSize, mapWidth) + y - 8 * scale

                    local alpha = 155
                    if i == 0 then alpha = 255 end
                    render_player_head(i, math.floor(renderX), math.floor(renderY), scale, scale, false, true, alpha)
                    local playercolor = network_get_player_text_color_string(i)
                    local r, g, b = convert_color(playercolor)
                    djui_hud_set_color(r, g, b, alpha - 100)
                    djui_hud_set_rotation(m.faceAngle.y, 0.5, 0.5)
                    djui_hud_render_texture(TEX_MAP_ARROW, renderX - 8 * scale, renderY - 8 * scale, scale, scale)
                    djui_hud_set_rotation(0, 0, 0)

                    if i ~= 0 and gGlobalSyncTable.gameMode == 4 and sMario.team ~= myTeam then
                        render_radar(TEX_TARGET, m.marioObj, player_radar[i], 80, i)
                        djui_hud_set_resolution(RESOLUTION_DJUI)
                    end

                    if gGlobalSyncTable.gameMode == 0 then
                        if get_player_owned_shine(i) ~= 0 then
                            djui_hud_set_color(255, 255, 255, 255)
                            djui_hud_render_texture(TEX_SHINE_SMALL, renderX, renderY - 15 * scale, scale, scale)
                        end
                    elseif (gGlobalSyncTable.gameMode == 1 and has_most_balloons(i)) or (gGlobalSyncTable.gameMode ~= 1 and gGlobalSyncTable.gameMode ~= 4 and has_most_points(i)) then
                        djui_hud_set_color(255, 255, 255, alpha)
                        djui_hud_render_texture(TEX_CROWN, renderX, renderY - 12 * scale, scale, scale)
                    end
                end
            end
        end

        if get_current_background_music() ~= 0 or gNetworkPlayers[0].currLevelNum < LEVEL_COUNT then
            if star then -- near star
                if musicState == 2 then
                    stop_secondary_music(100)
                end
                musicState = 1
                play_secondary_music(SEQ_EVENT_POWERUP, 0, 255, 1000)
            elseif allInvalid then
                stop_secondary_music(100)
                musicState = 0
            else -- near law
                if musicState == 1 then
                    stop_secondary_music(100)
                end
                musicState = 2
                play_secondary_music(SEQ_EVENT_METAL_CAP, 0, 255, 1000)
            end
        end
    end

    -- beginning timer
    if gGlobalSyncTable.gameState == 1 or tipDispTimer ~= 0 then
        djui_hud_set_font(FONT_MENU)
        local usingTimer = gGlobalSyncTable.gameTimer
        if tipDispTimer ~= 0 then
            usingTimer = tipDispTimer
            tipDispTimer = tipDispTimer - 1
        end
        local text = ""
        local instructText = ""
        local variantText = ""
        local tipText = ""
        local scale = 2
        local alpha = 255

        if tipDispTimer == 0 and usingTimer > 210 then
            scale = 3
            localGameTimer = localGameTimer + 1
            local secFrame = localGameTimer % 30
            if secFrame > 25 then secFrame = 30 - (secFrame - 25) * 6 end

            -- sound
            if localGameTimer % 30 == 1 then
                localGameTimer = usingTimer
                play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, gGlobalSoundSource)
            end

            text = string.format("%d", ((300 - localGameTimer) // 30) + 1)
            alpha = 17 * secFrame
        else
            if usingTimer < 30 then
                alpha = 8 * usingTimer
            end

            text = game_mode_instruct[gGlobalSyncTable.gameMode + 1][1]
            if gGlobalSyncTable.gameMode == 4 and gPlayerSyncTable[0].team == 1 then
                text = game_mode_instruct[gGlobalSyncTable.gameMode + 1][3]
                instructText = string.format(game_mode_instruct[gGlobalSyncTable.gameMode + 1][4],
                    gGlobalSyncTable.maxGameTime)
            elseif gGlobalSyncTable.gameMode == 0 then
                instructText = string.format(game_mode_instruct[gGlobalSyncTable.gameMode + 1][2], gGlobalSyncTable.winTime)
            elseif gGlobalSyncTable.gameMode == 5 then
                local thirdTime = gGlobalSyncTable.maxGameTime / 3
                local minutes = math.floor(thirdTime)
                local seconds = math.floor((thirdTime % 1) * 60)
                instructText = string.format(game_mode_instruct[gGlobalSyncTable.gameMode + 1][2], minutes, seconds)
            else
                instructText = string.format(game_mode_instruct[gGlobalSyncTable.gameMode + 1][2],
                    gGlobalSyncTable.maxGameTime)
            end

            if gGlobalSyncTable.variant ~= 0 then
                variantText = tostring(variant_list[gGlobalSyncTable.variant + 3])
                if variantText == "VARIANT_SPECIAL" then variantText = variant_special_list[gGlobalSyncTable.gameMode + 3] end
                variantText = "Variant: " .. variantText
                variantInfoText = tip_variant[gGlobalSyncTable.variant]
                if variantInfoText == "VARIANT_SPECIAL_TIP" then
                    variantInfoText = tip_variant_special[gGlobalSyncTable.gameMode + 1]
                end
                variantInfoText = string.gsub(variantInfoText, "SPECIAL_BUTTON", SPECIAL_BUTTON_STRING)
            end
            localGameTimer = usingTimer

            if not currTip then
                currTip = new_tip()
            end
            tipText = currTip
        end

        if alpha > 255 then alpha = 255 end

        if tipDispTimer == 0 and gGlobalSyncTable.gameMode == 4 and gPlayerSyncTable[0].team ~= 1 then
            if localGameTimer > 285 then
                djui_hud_set_color(0, 0, 0, alpha)
            else
                djui_hud_set_color(0, 0, 0, 255)
            end
            djui_hud_render_rect(0, 0, screenWidth + 10, screenHeight + 10)
        end

        local width = djui_hud_measure_text(remove_color(text)) * scale
        local x = (screenWidth - width) * 0.5
        local y = screenHeight * 0.5 - 48 * scale
        djui_hud_set_color(255, 255, 255, alpha)
        djui_hud_print_text_with_color(text, x, y, scale, alpha)

        if instructText ~= "" then
            local scale1 = 1
            y = y + 48 * scale + 20 * scale1
            width = djui_hud_measure_text(remove_color(instructText)) * scale1
            x = (screenWidth - width) * 0.5
            djui_hud_set_color(255, 255, 255, alpha)
            djui_hud_print_text_with_color(instructText, x, y, scale1, alpha)
        end
        if variantText ~= "" then
            local scale2 = 0.8
            y = y + 48 * scale + 40 * scale2
            width = djui_hud_measure_text(remove_color(variantText)) * scale2
            x = (screenWidth - width) * 0.5
            djui_hud_set_color(255, 255, 255, alpha)
            djui_hud_print_text_with_color(variantText, x, y, scale2, alpha)
            y = y + 64 * scale2
            scale2 = 0.5 
            width = djui_hud_measure_text(remove_color(variantInfoText)) * scale2
            x = (screenWidth - width) * 0.5
            djui_hud_print_text_with_color(variantInfoText, x, y, scale2, alpha)
        end
        if tipText ~= "" then
            local scale3 = 0.5
            y = screenHeight - scale3 * 70
            width = djui_hud_measure_text(tipText) * scale3
            x = (screenWidth - width) * 0.5
            djui_hud_set_color(255, 255, 255, alpha)
            djui_hud_print_text_with_color(tipText, x, y, scale3, alpha)
        end
        if gGlobalSyncTable.godMode then
            text = "\\#ffff40\\No Hazard Floors"
            local scale4 = 0.5
            y = 0
            x = 10
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_print_text_with_color(text, x, y, scale4, 255)
        end
    end

    -- showtime!
    if showTimeDispTimer > 0 then
        local text = "SHOWTIME!"
        local scale = 4
        local alpha = 255
        djui_hud_set_font(FONT_MENU)

        if showTimeDispTimer < 30 then
            alpha = 8 * showTimeDispTimer
        end

        if alpha > 200 then alpha = 200 end
        local width = djui_hud_measure_text(text) * scale
        local x = (screenWidth - width) * 0.5
        local y = screenHeight * 0.5 - 48 * scale
        djui_hud_set_color(255, 40, 40, alpha)
        djui_hud_print_text(text, x, y, scale)

        showTimeDispTimer = showTimeDispTimer - 1
    end

    -- boost variant
    if (gGlobalSyncTable.gameState == 2 or gGlobalSyncTable.gameState == 0) and tipDispTimer == 0 then
        if ((gGlobalSyncTable.variant >= 5 and gGlobalSyncTable.variant <= 11) or is_spectator(0)) and gMarioStates[0].action ~= ACT_CAPTURED then
            local max = 900
            if gGlobalSyncTable.variant == 5 or gGlobalSyncTable.variant == 7 or is_spectator(0) then
                max = 120
            else
                if gGlobalSyncTable.variant == 6 or gGlobalSyncTable.variant == 8 then
                    max = 15
                elseif gGlobalSyncTable.variant == 11 then
                    max = 400
                end
                if sMario0.isBomb and gGlobalSyncTable.variant ~= 9 then
                    max = 0
                end
            end

            if max ~= 0 then
                local amount = (max - (sMario0.specialCooldown or 0)) / max
                local boosting = (sMario0.boostTime ~= 0)
                local x = screenWidth * 0.4
                local y = screenHeight - 40

                djui_hud_set_color(0, 0, 0, 128)
                djui_hud_render_rect(x - 6, y - 2, screenWidth * 0.2 + 12, 34)
                local text = "Ready (" .. SPECIAL_BUTTON_STRING .. ")"

                if amount == 1 then
                    djui_hud_set_color(81, 0, 255, 200)
                else
                    if boosting then
                        text = "Boosting"
                        djui_hud_set_color(200, 200, 81, 200)
                    else
                        text = "Recharging"
                        djui_hud_set_color(255, 0, 81, 200)
                    end
                end

                djui_hud_render_rect(x, y, amount * screenWidth * 0.2, 30)

                djui_hud_set_font(FONT_TINY)
                local scale = 2
                local width = djui_hud_measure_text(text) * scale
                x = (screenWidth - width) * 0.5
                y = y - 20 * scale
                djui_hud_print_text(text, x, y, scale)
            end
        elseif gGlobalSyncTable.variant == 1 and sMario0.eliminated == 0 and gGlobalSyncTable.gameState == 2 and gGlobalSyncTable.gameMode > 0 and gGlobalSyncTable.gameMode < 3 then
            local amount = refillBalloonTimer / 90
            local x = 0
            local y = screenHeight - 60
            local scale = 3

            if refillBalloons ~= 0 then
                local color = network_player_get_override_palette_color(gNetworkPlayers[0], CAP)
                local tex = TEX_BALLOON
                x = (screenWidth - (((tex.width + 5) * refillBalloons - 5) * scale)) / 2
                for i = 1, refillBalloons do
                    djui_hud_set_color(color.r, color.g, color.b, 255)
                    djui_hud_render_texture(tex, x, y, scale, scale)
                    djui_hud_set_color(255, 255, 255, 255)
                    djui_hud_render_texture(TEX_BALLOON_SHINE, x, y, scale, scale)
                    x = x + (tex.width + 5) * scale
                end
            end
            if amount ~= 0 then
                x = screenWidth * 0.4
                y = y - 40
                djui_hud_set_color(0, 0, 0, 128)
                djui_hud_render_rect(x - 6, y - 2, screenWidth * 0.2 + 12, 34)
                local text = "Refilling"
                djui_hud_set_color(255, 0, 81, 200)
                djui_hud_render_rect(x, y, amount * screenWidth * 0.2, 30)

                djui_hud_set_font(FONT_TINY)
                scale = 2
                local width = djui_hud_measure_text(text) * scale
                x = (screenWidth - width) * 0.5
                y = y - 20 * scale
                djui_hud_print_text(text, x, y, scale)
            end
        end
    end

    -- shine timer on top (also does sound)
    if #shineIndexes ~= 0 then
        local headDistance = 20
        local scale = 3
        local width = 24 * scale

        local x = (screenWidth - width) * 0.5
        local y = 4 * scale

        djui_hud_set_color(0, 0, 0, 128);
        djui_hud_render_rect(x - 6 - 20 * scale, 0, width + 46 * scale + scale * (#shineIndexes - 1) * headDistance,
            28 * scale);


        djui_hud_set_font(FONT_HUD)
        local shineIndex = shineIndexes[1]
        local shinePlayer = gPlayerSyncTable[shineIndex]
        local timeLeft = (gGlobalSyncTable.winTime - shinePlayer.points)

        -- sound
        if prevTimerNum[0] ~= timeLeft and timeLeft >= 0 then
            if timeLeft > 3 then
                play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, gGlobalSoundSource)
            else
                play_sound(SOUND_GENERAL_SHORT_STAR, gGlobalSoundSource)
            end
            prevTimerNum[0] = timeLeft
        end

        local text = string.format("%02d", timeLeft)

        djui_hud_set_color(255, 255, 255, 255);
        djui_hud_print_text(text, x, y, scale)

        djui_hud_render_texture(TEX_SHINE, x - 20 * scale, y, scale, scale)
        for i, shineIndex in ipairs(shineIndexes) do
            render_player_head(shineIndex, x + width + 6 * scale, y, scale, scale, false, true)
            x = x + scale * headDistance
        end
    elseif gGlobalSyncTable.gameMode ~= 0 and gGlobalSyncTable.gameState == 2 then
        djui_hud_set_font(FONT_HUD)
        local scale = 3

        local renegades = {}
        local text2 = ""
        local width2 = 0
        if gGlobalSyncTable.gameMode == 4 then
            for i = 0, MAX_PLAYERS - 1 do
                local sMario = gPlayerSyncTable[i]
                if gNetworkPlayers[i].connected and sMario.team == 1 and not sMario.spectator then
                    if #renegades <= 8 or not is_dead(i) then
                        table.insert(renegades, i)
                        if #renegades > 8 then
                            for a, index in ipairs(renegades) do
                                if is_dead(index) then
                                    table.remove(renegades, a)
                                    break
                                end
                            end
                            if #renegades > 8 then
                                table.remove(renegades, #renegades)
                            end
                        end
                    end
                end
            end
            width2 = (18 * #renegades - 2) * scale
        elseif gGlobalSyncTable.gameMode ~= 1 then
            if frameCounter % 2 == 0 then
                if prevPointCount < gPlayerSyncTable[0].points then
                    prevPointCount = prevPointCount + 1
                    if gGlobalSyncTable.gameMode == 3 then
                        play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
                    end
                elseif prevPointCount > gPlayerSyncTable[0].points then
                    prevPointCount = prevPointCount - 1
                end
            end
            text2 = tostring(prevPointCount)
            width2 = (djui_hud_measure_text(text2) + 22) * scale -- 20 of this is space for the balloon
        end

        local minutes = gGlobalSyncTable.gameTimer // 30 // 60
        local seconds = gGlobalSyncTable.gameTimer // 30 % 60

        -- sound
        if prevTimerNum[0] ~= seconds and seconds < 10 and minutes == 0 then
            play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, gGlobalSoundSource)
            prevTimerNum[0] = seconds
        end

        local text = string.format("%d'%02d", minutes, seconds)
        local width = (djui_hud_measure_text(text) + 2) * scale

        local x = (screenWidth - width) * 0.5
        local y = 4 * scale

        if gGlobalSyncTable.gameState == 0 then
            x = (screenWidth - width2) * 0.5
        else
            if width2 ~= 0 then
                x = (screenWidth - width) * 0.5 - 100
            end
            djui_hud_set_color(0, 0, 0, 128);
            djui_hud_render_rect(x - 12, 0, width + 24,
                28 * scale);

            djui_hud_set_color(255, 255, 255, 255);
            djui_hud_print_text(text, x, y, scale)
            if width2 ~= 0 then
                x = (screenWidth - width) * 0.5 + 100
            end
        end

        if width2 ~= 0 then
            djui_hud_set_color(0, 0, 0, 128);
            djui_hud_render_rect(x - 12, 0, width2 + 24,
                28 * scale);
            if gGlobalSyncTable.gameMode ~= 4 then
                local tex = gTextures.coin
                if gGlobalSyncTable.gameMode == 2 then
                    tex = TEX_BALLOON
                    djui_hud_set_color(255, 0, 0, 255);
                    djui_hud_render_texture(tex, x, y, scale, scale)
                    djui_hud_set_color(255, 255, 255, 255);
                    djui_hud_render_texture(TEX_BALLOON_SHINE, x, y, scale, scale)
                elseif gGlobalSyncTable.gameMode == 5 then
                    tex = TEX_MOON
                    if has_least_points(0) then
                        local gb = sins(frameCounter * 2000) * 100 + 150
                        djui_hud_set_color(255, gb, gb, 255);
                    else
                        djui_hud_set_color(255, 255, 255, 255);
                    end
                    djui_hud_render_texture(tex, x, y, scale, scale)
                else
                    djui_hud_set_color(255, 255, 255, 255);
                    djui_hud_render_texture(tex, x, y, scale, scale)
                end

                x = x + 20 * scale
                djui_hud_set_color(255, 255, 255, 255);
                djui_hud_print_text(text2, x, y, scale)
            else
                for i, index in ipairs(renegades) do
                    djui_hud_set_color(255, 255, 255, 255)
                    render_player_head(index, x, y, scale, scale, false, true)
                    x = x + 18 * scale
                end
            end
        end
    end

    -- item preview
    local item = sMario0.item or 0
    if ((gGlobalSyncTable.gameState == 2 and gGlobalSyncTable.items ~= 0) or item ~= 0 or shuffleItem ~= 0) and not is_dead(0) then
        local scale = 2
        local x = 10
        if DEBUG_MODE then x = 200 end
        local y = 50
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_set_font(FONT_HUD)
        djui_hud_render_texture(get_texture_info("item_bg"), x, y, scale, scale)
        if shuffleItem == 0 then
            if rItem ~= 0 then
                play_sound(SOUND_MENU_REVERSE_PAUSE + 61569, gGlobalSoundSource)
                rItem = 0
            end
            local data = item_data[item]
            local tex = (data and data.tex) or get_texture_info(string.format("item_preview_%02d", item))
            djui_hud_render_texture(tex, x, y, scale, scale)
        else
            -- displays two items at once to look like the roulette wheel
            -- I wasted so much time on this...
            if rItem == 0 or shuffleTimer % 5 == 2 then
                if shuffleTimer < 52 then
                    local itemRange, weightRange, maxWeight = get_item_probabilities(0)
                    if rItem2 == 0 then
                        rItem = itemRange[math.random(1, #itemRange)]
                    else
                        rItem = rItem2
                    end
                    rItem2 = itemRange[math.random(1, #itemRange)]
                else
                    rItem = rItem2
                end
                play_sound(SOUND_MENU_REVERSE_PAUSE, gGlobalSoundSource)
            end
            local testTimer = shuffleTimer - 2
            if shuffleTimer >= 57 then
                testTimer = 0
                rItem = shuffleItem
            elseif shuffleTimer >= 52 then
                rItem2 = shuffleItem
            end
            local data = item_data[rItem]
            local data2 = item_data[rItem2]
            local tex = (data and data.tex) or get_texture_info(string.format("item_preview_%02d", rItem))
            local tex2 = (data2 and data2.tex) or get_texture_info(string.format("item_preview_%02d", rItem2))
            local dOffset = math.floor((testTimer % 5) * 16)
            local xScale = scale
            local yOffset = 0
            if dOffset ~= 0 then
                xScale = scale * (1-dOffset/64)
                yOffset = dOffset*scale-6
                djui_hud_render_texture_tile(tex, x, y+yOffset, xScale, scale, 0, 0, 64, 64-dOffset)
                djui_hud_render_texture_tile(tex2, x, y+6, scale, scale, 0, 64-dOffset, 64, 64)
            else
                djui_hud_render_texture(tex, x, y, scale, scale)
            end
        end

        local data = item_data[item]
        if shuffleItem == 0 and data and data.maxUses then
            local uses = data.maxUses - sMario0.itemUses
            djui_hud_print_text("@" .. uses, x + 34 * scale, y + 45 * scale, scale)
        end

        if shuffleItem == 0 and item ~= 0 and (frameCounter % 30 <= 15) then
            local nameRef = { "X", "Y", "L", "R", "+", "X+", "Y+", "L+", "R+" }
            local text = nameRef[itemBindSelection+1]
            local width = djui_hud_measure_text(text) * scale + 10
            djui_hud_print_text(text, x + 64 * scale - width, y + 10, scale)
        end
    end

    -- show variant
    if gGlobalSyncTable.gameState == 2 and gGlobalSyncTable.variant ~= 0 then
        djui_hud_set_font(FONT_MENU)
        local scale = 0.75
        local x = 10
        local y = 0
        local text = variant_list[gGlobalSyncTable.variant + 3]
        if text == "VARIANT_SPECIAL" then text = variant_special_list[gGlobalSyncTable.gameMode + 3] end
        djui_hud_print_text_with_color(text, x, y, scale)
        djui_hud_set_font(FONT_NORMAL)
    end

    -- pow block effect
    if powBlockTimer ~= 0 then
        local scaleY = 4
        if powBlockTimer < 30 then
            scaleY = 2
        end
        if powBlockTimer % 30 <= 5 then
            scaleY = scaleY - 2 + (powBlockTimer % 30) / 2.5
        end
        local scaleX = 6 - scaleY / 2
        local tex = get_texture_info("item_preview_12")
        local x = (screenWidth - tex.width * scaleX) / 2
        local y = (screenHeight * 0.4 - (tex.height * scaleY)) / 2
        local index = network_local_index_from_global(powBlockOwner) or 0
        local sMario = gPlayerSyncTable[index]
        if sMario.team == nil or sMario.team == 0 then
            djui_hud_set_color(155, 255, 255, 155)
        else
            local color = TEAM_DATA[sMario.team][1]
            --color.r = math.max(0, color.r - 50)
            --color.g = math.max(0, color.g - 50)
            --color.b = math.max(0, color.b - 50)
            djui_hud_set_color(color.r, color.g, color.b, 155)
        end
        djui_hud_render_texture(tex, x, y, scaleX, scaleY)
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)

function enter_menu(id, option, back)
    menuMotionNotReady = true
    if not back then
        local menu = menu_data[menuID]
        local optionNum = menu and menu[menuOption].currNum
        table.insert(menu_history, { menuID, menuOption, optionNum })
    end

    -- redirect to/from vote menu
    if (id == 2 or id == 8) and gGlobalSyncTable.mapChoice == 1 and not back then
        if network_is_server() or network_is_moderator() then
            id = 6
            if option then
                option = option + 2
            end
        else
            id = 7
            option = 1
        end
    elseif id == 6 and gGlobalSyncTable.mapChoice ~= 1 then
        if network_is_server() or network_is_moderator() then
            if gGlobalSyncTable.gameState ~= 0 then
                id = 2
                if option then
                    option = option - 2
                end
            else
                id = 3
                inMenu = false
            end
        else
            id = 7
            option = 1
        end
    end

    -- redirect to/from old map selection menu
    if id == 8 and oldMapMenu then
        id = 3
        option = 1
    elseif id == 3 and not oldMapMenu then
        id = 8
        option = 1
    end

    local prevMenuId = menuID
    menuID = id or 1
    menuOption = option or 1

    -- build menu
    local menu = menu_data[menuID]
    if menu.buildFunc then
        menu.buildFunc(menu)
    end

    -- set map menu option to last played map
    if menuID == 3 then
        if #levelData == 0 then
            enter_menu(4, 1, true)
            return
        end

        if back then
            -- nothing
        elseif type(gGlobalSyncTable.gameLevel) == "number" and gGlobalSyncTable.gameLevel > 0 and gGlobalSyncTable.gameLevel <= #levelData then
            set_menu_option(3, 1, gGlobalSyncTable.gameLevel)
        elseif type(gGlobalSyncTable.gameLevel) ~= "number" then
            set_menu_option(3, 1, 1) -- first entry
            menuOption = 3 -- select "custom"
        elseif isHackNotCompatible or #levelData == 1 then
            set_menu_option(3, 1, 1) -- whatever the first entry is
        else
            set_menu_option(3, 1, 2) -- wf
        end
    elseif menuID == 8 then
        if #levelData == 0 then
            enter_menu(4, 1, true)
            return
        end

        local select = 0
        if back then
            -- nothing
        elseif type(gGlobalSyncTable.gameLevel) == "number" and gGlobalSyncTable.gameLevel > 0 and gGlobalSyncTable.gameLevel <= #levelData then
            select = gGlobalSyncTable.gameLevel + 2
        elseif type(gGlobalSyncTable.gameLevel) ~= "number" then
            select = 2 -- custom
        elseif isHackNotCompatible or #levelData == 1 then
            select = 3 -- third option (because the first two are random and custom)
        else
            select = 4 -- wf
        end
        -- y is the first value and x is the second
        if select ~= 0 then
            local columns = menu.columns or 3
            menuOption = (select-1) // columns + 1
            set_menu_option(8, menuOption, (select-1) % columns + 1)
        end
    end
end

-- show the menu
function render_menu()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_NORMAL)

    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    if gGlobalSyncTable.gameState == 1 and gGlobalSyncTable.gameMode == 4 and gPlayerSyncTable[0].team ~= 1 then
        if menuDarkMode then
            djui_hud_set_color(0, 0, 0, 255)
        else
            djui_hud_set_color(128, 128, 128, 255)
        end
    else
        if menuDarkMode then
            djui_hud_set_color(0, 0, 0, 200)
        else
            djui_hud_set_color(255, 255, 255, 128)
        end
    end
    djui_hud_render_rect(0, 0, screenWidth + 10, screenHeight + 10)

    local menu = menu_data[menuID]
    if not menu then return end

    -- first, determine menu size
    local scroll = false
    local scale = 2
    local renderButtons = 0
    for i, button in ipairs(menu) do
        if option_valid(button) then
            renderButtons = renderButtons + 1
        end
    end
    local totalButtons = renderButtons
    local buttonSize = 40
    if menuID == 8 then buttonSize = 180 end
    while (not menu.noScroll) and (renderButtons * buttonSize * scale) > screenHeight do
        scroll = true
        renderButtons = renderButtons - 1
    end

    local x = 0
    local y = (screenHeight - renderButtons * buttonSize * scale) / 2
    local downBy = 0
    while renderButtons + downBy < totalButtons and (y + (menuOption - 1) * buttonSize * scale > screenHeight / 2) do
        y = y - buttonSize * scale
        downBy = downBy + 1
    end
    local wasMotionNotReady = false
    local expectedY = y
    if menuMotionEnabled then
        wasMotionNotReady = menuMotionNotReady
        menuMotionNotReady = false
        if wasMotionNotReady or menu.noScroll then
            menuCurrY = expectedY
        else
            menuCurrY = smooth_approach(expectedY, menuCurrY, 0.25)
            y = menuCurrY
        end
    end

    for i, button in ipairs(menu) do
        if menuID == 3 and i == 1 then -- special case (paintings)
            x = screenWidth / 2 - 180 * scale
            y = (screenHeight - 6 * buttonSize * scale) / 2
            local lowRange, highRange = button.currNum - 1, button.currNum + 1
            if menuMotionEnabled then
                local selectedPainting = button.currNum
                if (prevSelectedPainting - selectedPainting) > 1 then
                    menuCurrX = menuCurrX + #levelData * 180 * scale
                elseif (prevSelectedPainting - selectedPainting) < -1 then
                    menuCurrX = menuCurrX - #levelData * 180 * scale
                end
                prevSelectedPainting = selectedPainting

                local expectedX = x - selectedPainting * 180 * scale
                if wasMotionNotReady then
                    menuCurrX = expectedX
                else
                    menuCurrX = smooth_approach(expectedX, menuCurrX, 0.25)
                    x = menuCurrX + selectedPainting * 180 * scale
                end
                lowRange, highRange = button.currNum - 2, button.currNum + 2
                x = x - 180 * scale
            end
            for i = lowRange, highRange do
                if #levelData == 1 then
                    if i == 0 then
                        i = 1
                    else
                        break
                    end
                    x = x + 180 * scale
                end

                if i < 1 then
                    i = #levelData + i
                elseif i > #levelData then
                    i = i - #levelData
                end

                local alpha = 0
                if menuMotionEnabled then
                    alpha = 255 - math.min(255, math.abs(x - screenWidth / 2) // scale)
                else
                    alpha = (i == button.currNum and 255) or 100
                end
                djui_hud_set_color(255, 255, 255, alpha)
                if alpha ~= 0 then
                    render_painting(i, x, y, scale, alpha, is_blacklisted(i), false, (i == button.currNum))
                end
                x = x + 180 * scale
            end
            djui_hud_set_font(FONT_NORMAL)
            scale = 2
            local text = levelData[button.currNum].name or
                get_level_name(levelData[button.currNum].course, levelData[button.currNum].level,
                    levelData[button.currNum].area)
            local width = djui_hud_measure_text(text) * scale
            x = (screenWidth - width) * 0.5
            y = 10 * scale
            if menuDarkMode then
                djui_hud_set_color(255, 255, 255, 255)
            else
                djui_hud_set_color(0, 0, 0, 255)
            end
            djui_hud_print_text(text, x, y, scale)
            if i == menuOption then
                djui_hud_set_color(255, 255, 64, sins(frameCounter * 500) * 50 + 50)
                djui_hud_render_rect(x - 6, y - 6, width + 12, 36 * scale + 12)
            end

            scale = 2
            y = screenHeight - 160 * scale
        elseif menuID == 6 and i == 1 then -- special case (voting screen paintings)
            x = screenWidth * 0.5 - 180 * scale
            y = (screenHeight - 6 * buttonSize * scale) / 2
            local currMap = -1
            local currMapText = ""
            local voteEnd = false

            if gGlobalSyncTable.gameTimer <= 180 then
                voteEnd = true
                -- count the votes
                if doVoteCalc then
                    votesNumber = { 0, 0, 0 }
                    for i = 0, MAX_PLAYERS - 1 do
                        local sMario = gPlayerSyncTable[i]
                        if gNetworkPlayers[i].connected and sMario.myVote and sMario.myVote ~= 0 and sMario.myVote ~= gGlobalSyncTable.voteExclude and votesNumber[sMario.myVote] then
                            votesNumber[sMario.myVote] = votesNumber[sMario.myVote] + 1
                        elseif DEBUG_SCORES and sMario.myVote and votesNumber[sMario.myVote] then
                            votesNumber[sMario.myVote] = votesNumber[sMario.myVote] + 1
                        end
                    end
                    doVoteCalc = false
                end
                currMap = gGlobalSyncTable.wonMap or -1
            else
                doVoteCalc = true
            end

            for i = 0, 2 do
                local map = 1
                if i == 0 then
                    map = gGlobalSyncTable.voteMap1
                elseif i == 1 then
                    map = gGlobalSyncTable.voteMap2
                else
                    map = gGlobalSyncTable.voteMap3
                end

                local alpha = 100
                if voteEnd then
                    if currMap == map then
                        alpha = 255
                    else
                        alpha = 100
                    end
                elseif i == button.currNum then
                    alpha = 255
                    currMap = map
                end

                local renderBorder = false
                if not voteEnd then
                    renderBorder = (gPlayerSyncTable[0].myVote and i == (gPlayerSyncTable[0].myVote - 1))
                else
                    renderBorder = (currMap == map)
                end
                djui_hud_set_color(255, 255, 255, alpha)
                local levelName = render_painting(map, x, y, scale, alpha, gGlobalSyncTable.voteExclude == (i + 1), renderBorder)
                if currMap == map then
                    currMapText = levelName
                end

                if voteEnd then
                    local text = tostring(votesNumber[i + 1])
                    djui_hud_set_font(FONT_TINY)
                    local tWidth = djui_hud_measure_text(text) * scale
                    if currMap == map then
                        djui_hud_set_color(64, 255, 64, 255)
                    else
                        djui_hud_set_color(255, 255, 255, 255)
                    end
                    djui_hud_print_text(text, x - tWidth, y - scale * 6, scale * 2)
                end
                x = x + 180 * scale
            end
            djui_hud_set_font(FONT_NORMAL)
            scale = 2
            local text = ""
            if currMap == -1 then
                text = "Revoting!"
            elseif currMapText == "" and levelData[currMap] then
                text = levelData[currMap].name or
                    get_level_name(levelData[currMap].course, levelData[currMap].level, levelData[currMap].area)
            else
                text = currMapText
            end
            local width = djui_hud_measure_text(text) * scale
            x = (screenWidth - width) * 0.5
            y = 10 * scale
            if menuDarkMode then
                djui_hud_set_color(255, 255, 255, 255)
            else
                djui_hud_set_color(0, 0, 0, 255)
            end
            djui_hud_print_text(text, x, y, scale)
            if i == menuOption then
                djui_hud_set_color(255, 255, 64, sins(frameCounter * 500) * 50 + 50)
                djui_hud_render_rect(x - 6, y - 6, width + 12, 36 * scale + 12)
            end

            scale = 2
            y = screenHeight - 160 * scale
        elseif menuID == 8 then -- special case (new map menu)
            local lowRange = (i-1) * menu.columns - 1
            local highRange = lowRange + button.maxNum - 1
            x = screenWidth / 2 - (menu.columns-1) * 90 * scale
            if i == 1 then
                y = y + 40 * scale
            end
            local paintingX = 0
            for a = lowRange, highRange do
                paintingX = paintingX + 1

                local alpha = (i == menuOption and paintingX == button.currNum and 255) or 100
                djui_hud_set_color(255, 255, 255, alpha)
                if alpha ~= 0 then
                    render_painting(a, x, y, scale, alpha, is_blacklisted(a), false, (i == menuOption and paintingX == button.currNum and a > 0))
                end
                x = x + 180 * scale
            end
            djui_hud_set_font(FONT_NORMAL)
            if i == #menu then
                local map = ((menuOption-1) * menu.columns) + menu[menuOption].currNum - 2
                local text = ""
                if map == -1 then
                    text = "Random"
                elseif map == 0 then
                    text = "Custom"
                else
                    text = levelData[map].name or get_level_name(levelData[map].course, levelData[map].level, levelData[map].area)
                end
                local width = djui_hud_measure_text(text) * scale
                local tx = (screenWidth - width) * 0.5
                local ty = 0
                if not menuDarkMode then
                    djui_hud_set_color(0, 0, 0, 128)
                    djui_hud_render_rect(tx - 4, ty, width + 8, 40 * scale)
                end
                djui_hud_set_color(255, 255, 255, 255)
                djui_hud_print_text(text, tx, ty, scale)

                -- settings icons
                x = 10
                y = 10
                local tex = TEX_BALLOON
                local textInstead = ""
                if menuGameMode == -2 then
                    tex = gTextures.star
                elseif menuGameMode == -1 then
                    textInstead = "?"
                elseif menuGameMode == 0 then
                    tex = TEX_SHINE
                elseif menuGameMode == 3 then
                    tex = gTextures.coin
                elseif menuGameMode == 4 then
                    tex = TEX_CAGE
                elseif menuGameMode == 5 then
                    tex = TEX_MOON
                end
                if textInstead ~= "" then
                    djui_hud_set_font(FONT_HUD)
                    djui_hud_set_color(255, 255, 255, 255)
                    djui_hud_print_text(textInstead, x, y, scale)
                elseif tex == TEX_BALLOON then
                    if menuGameMode == 2 then
                        djui_hud_set_color(0, 0, 255, 255)
                    else
                        djui_hud_set_color(255, 0, 0, 255)
                    end
                    djui_hud_render_texture(tex, x, y, scale, scale)
                    tex = TEX_BALLOON_SHINE
                    djui_hud_set_color(255, 255, 255, 255)
                    djui_hud_render_texture(tex, x, y, scale, scale)
                else
                    djui_hud_set_color(255, 255, 255, 255)
                    djui_hud_render_texture(tex, x, y, scale, scale)
                end
                djui_hud_set_font(FONT_CUSTOM_HUD)
                text = "Z - Game Settings"
                local tWidth = djui_hud_measure_text(text) * scale / 2
                djui_hud_print_text(text, x+tex.width*scale+10, -5, scale / 2)
                tex = TEX_COG
                x = screenWidth - 10 - tex.width * scale
                text = "Y - Options"
                tWidth = djui_hud_measure_text(text) * scale / 2
                djui_hud_print_text(text, x-tWidth-10, -5, scale / 2)
                djui_hud_render_texture(tex, x, y, scale, scale)
            end

            y = y + 180 * scale
        elseif option_valid(button) then
            local text = button[1]
            if menuID == 4 and i == 1 then -- special case (level name)
                local course = button.currNum
                local level = 0
                if course <= 25 then
                    level = course_to_level[course] or 0
                    text = get_level_name(course, level, 1)
                elseif course == 26 then
                    level = LEVEL_BOWSER_1
                    text = "Bowser 1"
                elseif course == 27 then
                    level = LEVEL_BOWSER_2
                    text = "Bowser 2"
                elseif course == 28 then
                    level = LEVEL_BOWSER_3
                    text = "Bowser 3"
                elseif course == 29 then
                    level = LEVEL_CASTLE
                    text = get_level_name(0, level, get_menu_option(4, 2))
                elseif course == 30 then
                    level = LEVEL_CASTLE_COURTYARD
                    text = get_level_name(0, level, 1)
                end

                if (isHackNotCompatible and level_is_vanilla_level(level)) then
                    text = text .. " (ORG)"
                end
                local area = get_menu_option(4, 2) or 1
                if is_blacklisted(tostring(level).." "..tostring(area)) then
                    text = "(X) " .. text
                end
            end
            local width = djui_hud_measure_text(text) * scale
            if button.currNum then
                local color = "\\#5050ff\\"
                local optionText = ""
                if button.nameRef and button.nameRef[button.currNum - button.minNum + 1] then
                    optionText = button.nameRef[button.currNum - button.minNum + 1]
                    if optionText == "VARIANT_SPECIAL" then optionText = variant_special_list[menuGameMode + 3] end
                else
                    optionText = tostring(button.currNum)
                    if button.currNum == 0 then optionText = "\\#ff5050\\" .. optionText end
                end
                text = text .. color .. "  < " .. optionText .. color .. " >"
                local oldWidth = width + 16 * scale
                width = djui_hud_measure_text(remove_color(text)) * scale
                x = (screenWidth - width) * 0.5
                if not menuDarkMode then
                    djui_hud_set_color(50, 50, 50, 100)
                    djui_hud_render_rect(x + oldWidth - 2, y, width - oldWidth + 4, 36 * scale)
                end
                djui_hud_print_text_with_color(text, x, y, scale, nil, menuDarkMode)
            else
                x = (screenWidth - width) * 0.5
                djui_hud_print_text_with_color(text, x, y, scale, nil, menuDarkMode)
            end
            
            if i == menuOption then
                djui_hud_set_color(255, 255, 64, sins(frameCounter * 500) * 50 + 50)
                frameCounter = frameCounter + 1
                if frameCounter >= 60 then frameCounter = 0 end
                djui_hud_render_rect(x - 6, y - 6, width + 12, 36 * scale + 12)
            end
            y = y + 40 * scale
        end
    end

    -- render scroll bar
    if scroll then
        x = screenWidth - 50
        y = 100
        if menuDarkMode then
            djui_hud_set_color(0, 0, 0, 255)
        else
            djui_hud_set_color(100, 100, 100, 255)
        end
        djui_hud_render_rect(x, y, 20, screenHeight - 150)
        local portion = renderButtons / totalButtons
        local height = (screenHeight - 154) * portion
        y = y + (screenHeight - 154) * (1 - portion) * downBy / (totalButtons - renderButtons)
        if menuMotionEnabled then
            if wasMotionNotReady then
                scrollCurrY = y
            else
                scrollCurrY = smooth_approach(y, scrollCurrY, 0.25)
                y = scrollCurrY
            end
        end
        
        if menuDarkMode then
            djui_hud_set_color(155, 155, 155, 255)
        else
            djui_hud_set_color(200, 200, 200, 255)
        end
        djui_hud_render_rect(x + 2, y + 2, 16, height)
    end
end

function render_reduce_object_hud()
    -- hud balloons and items
    if not gGlobalSyncTable.reduceObjects then return end
    djui_hud_set_resolution(RESOLUTION_N64)
    for i = 0, MAX_PLAYERS - 1 do
        local m = gMarioStates[i]
        local sMario = gPlayerSyncTable[i]
        local item = (m.playerIndex ~= 0 and sMario.item and item_data[sMario.item])
        local balloons = (gGlobalSyncTable.gameMode > 0 and gGlobalSyncTable.gameMode < 3 and sMario.balloons) or 0
        if (m.playerIndex == 0 or is_player_active(m) ~= 0) and (balloons ~= 0 or item) then
            local pos = { x = m.marioObj.header.gfx.pos.x, y = m.pos.y + 300, z = m.marioObj.header.gfx.pos.z }
            local out = { x = 0, y = 0, z = 0 }
            if not djui_hud_world_pos_to_screen_pos(pos, out) then goto CONTINUE end
            local x, y, scale = 0, 0, 1.5
            local dist = vec3f_dist(gLakituState.pos, m.pos)
            if dist ~= 0 then
                scale = clampf(scale / dist * 1000, 0, 100)
            else
                scale = 100
            end
            if scale == 0 then goto CONTINUE end
            y = out.y
            if balloons ~= 0 then
                local color = network_player_get_override_palette_color(gNetworkPlayers[i], CAP)
                local tex = TEX_BALLOON
                x = out.x - (((tex.width + 2) * balloons - 2) * scale / 2)
                for i = 1, balloons do
                    djui_hud_set_color(color.r, color.g, color.b, 200)
                    djui_hud_render_texture(tex, x, y, scale, scale)
                    djui_hud_set_color(255, 255, 255, 200)
                    djui_hud_render_texture(TEX_BALLOON_SHINE, x, y, scale, scale)
                    x = x + (tex.width + 2) * scale
                end
                y = y - (tex.height + 3) * scale
            end
            if item then
                local iScale = scale * 0.25
                local tex = get_texture_info("item_bg")
                x = out.x - tex.width * iScale * 0.5
                djui_hud_set_color(255, 255, 255, 200)
                djui_hud_render_texture(tex, x, y, iScale, iScale)
                tex = (item and item.tex) or get_texture_info(string.format("item_preview_%02d", sMario.item))
                djui_hud_render_texture(tex, x, y, iScale, iScale)
            end
        end
        ::CONTINUE::
    end
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, render_reduce_object_hud)

item_override_down = false
item_override_finished = false
special_override_down = false
special_override_finished = false
-- menu controls + special action control
---@param m MarioState
function menu_controls(m)
    if m.playerIndex ~= 0 then return end

    if showGameResults then
        local leave_game_results = (m.controller.buttonPressed & (A_BUTTON | START_BUTTON)) ~= 0 and not inMenu
        if voteScreenTimer > 0 and not leave_game_results then
            voteScreenTimer = voteScreenTimer - 1
            if voteScreenTimer == 0 and gGlobalSyncTable.mapChoice == 1 then
                leave_game_results = true
            end
        end
        m.controller.buttonPressed = m.controller.buttonPressed & ~START_BUTTON
        if leave_game_results then
            voteScreenTimer = 0
            if gGlobalSyncTable.mapChoice == 1 then
                enter_menu(6)
            elseif network_is_server() or network_is_moderator() then
                enter_menu(2)
            else
                enter_menu(7)
            end
            menu_history = {}
            inMenu = true
            return
        end
    elseif (m.controller.buttonPressed & START_BUTTON) ~= 0 then
        if not showGameResults then
            if gGlobalSyncTable.mapChoice == 1 and gGlobalSyncTable.gameState == 0 then
                enter_menu(6)
            elseif gGlobalSyncTable.gameState ~= 0 then
                enter_menu(1)
            else
                enter_menu(3)
            end
            menu_history = {}
            inMenu = not inMenu
            play_sound(SOUND_MENU_PAUSE, gGlobalSoundSource)
        end
        m.controller.buttonPressed = m.controller.buttonPressed & ~START_BUTTON
        return
    end

    -- debug free move
    if DEBUG_MODE and not (inMenu or showGameResults) then
        if m.action == ACT_DEBUG_FREE_MOVE then
            if m.controller.buttonPressed & X_BUTTON ~= 0 then
                DEBUG_INVIS = not DEBUG_INVIS
            elseif m.controller.buttonPressed & Y_BUTTON ~= 0 then
                DEBUG_SCORES = not DEBUG_SCORES
                djui_chat_message_create("Debug scores: "..tostring(DEBUG_SCORES))
            elseif m.controller.buttonPressed & D_JPAD ~= 0 then
                debug_place()
            elseif m.controller.buttonPressed & U_JPAD ~= 0 then
                local action = ACT_IDLE
                if m.pos.y <= m.waterLevel - 100 then
                    action = ACT_WATER_IDLE
                end
                set_mario_action(m, action, 0)
                DEBUG_INVIS = false
            end
        elseif (m.controller.buttonPressed & U_JPAD) ~= 0 and network_player_connected_count() <= 1 then
            set_mario_action(m, ACT_DEBUG_FREE_MOVE, 0)
        end
    end

    -- handle item and special button controls
    if not (inMenu or showGameResults or m.action == ACT_DEBUG_FREE_MOVE) then
        -- special
        if SPECIAL_OVERRIDE_BUTTON ~= 0 then
            if m.controller.buttonDown & SPECIAL_OVERRIDE_BUTTON ~= 0 then
                m.controller.buttonPressed = m.controller.buttonPressed & ~SPECIAL_OVERRIDE_BUTTON
                m.controller.buttonDown = m.controller.buttonDown & ~SPECIAL_OVERRIDE_BUTTON
                special_override_down = true
            elseif special_override_down then
                if not special_override_finished then
                    m.controller.buttonPressed = m.controller.buttonPressed | SPECIAL_OVERRIDE_BUTTON
                    m.controller.buttonDown = m.controller.buttonDown | SPECIAL_OVERRIDE_BUTTON
                end
                special_override_down = false
            end
            if m.controller.buttonDown & SPECIAL_BUTTON ~= 0 and special_override_down then
                specialPressed = not specialDown
                specialDown = true
                special_override_finished = true
            else
                specialPressed = false
                specialDown = false
                if not special_override_down then
                    special_override_finished = false
                end
            end
        else
            specialPressed = (m.controller.buttonDown & SPECIAL_BUTTON ~= 0) and not specialDown
            specialDown = (m.controller.buttonDown & SPECIAL_BUTTON ~= 0)
            special_override_down = false
            special_override_finished = false
            m.controller.buttonPressed = m.controller.buttonPressed & ~SPECIAL_BUTTON
            m.controller.buttonDown = m.controller.buttonDown & ~SPECIAL_BUTTON
        end

        -- item
        if ITEM_OVERRIDE_BUTTON ~= 0 then
            if m.controller.buttonDown & ITEM_OVERRIDE_BUTTON ~= 0 then
                m.controller.buttonPressed = m.controller.buttonPressed & ~ITEM_OVERRIDE_BUTTON
                m.controller.buttonDown = m.controller.buttonDown & ~ITEM_OVERRIDE_BUTTON
                item_override_down = true
            elseif item_override_down then
                if not item_override_finished then
                    m.controller.buttonPressed = m.controller.buttonPressed | ITEM_OVERRIDE_BUTTON
                    m.controller.buttonDown = m.controller.buttonDown | ITEM_OVERRIDE_BUTTON
                end
                item_override_down = false
            end
            if m.controller.buttonDown & ITEM_BUTTON ~= 0 and item_override_down then
                itemPressed = not itemDown
                itemDown = true
                item_override_finished = true
            else
                itemPressed = false
                itemDown = false
                if not item_override_down then
                    item_override_finished = false
                end
            end
        else
            itemPressed = (m.controller.buttonDown & ITEM_BUTTON ~= 0) and not itemDown
            itemDown = (m.controller.buttonDown & ITEM_BUTTON ~= 0)
            item_override_down = false
            item_override_finished = false
            m.controller.buttonPressed = m.controller.buttonPressed & ~ITEM_BUTTON
            m.controller.buttonDown = m.controller.buttonDown & ~ITEM_BUTTON
        end

        return
    else
        itemPressed, itemDown = false, false
        specialPressed, specialDown = false, false
        if not (inMenu or showGameResults) then return end
    end
    if m.freeze < 2 then m.freeze = 2 end
    if not inMenu then return end
    if (m.controller.buttonPressed & R_TRIG) ~= 0 then
        djui_open_pause_menu()
        m.controller.buttonPressed = m.controller.buttonPressed & ~R_TRIG
    end

    local stickX = m.controller.rawStickX
    if (m.controller.buttonDown & L_JPAD) ~= 0 then
        stickX = stickX - 65
    end
    if (m.controller.buttonDown & R_JPAD) ~= 0 then
        stickX = stickX + 65
    end
    local stickY = m.controller.rawStickY
    if (m.controller.buttonDown & D_JPAD) ~= 0 then
        stickY = stickY - 65
    end
    if (m.controller.buttonDown & U_JPAD) ~= 0 then
        stickY = stickY + 65
    end

    if stickCooldownY > 0 then stickCooldownY = stickCooldownY - 1 end
    if stickCooldownX > 0 then stickCooldownX = stickCooldownX - 1 end

    local menu = menu_data[menuID]
    if not menu then return end
    local button = menu[menuOption]
    if not button then return end

    if (m.controller.buttonPressed & A_BUTTON) ~= 0 and button[2] and not button.runOnChange then
        if not option_valid(button) then
            play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
        else
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
            button[2](button.currNum)
        end
    elseif (m.controller.buttonPressed & B_BUTTON) ~= 0 then
        if #menu_history ~= 0 then
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
            local optionNum = menu_history[#menu_history][3]
            enter_menu(menu_history[#menu_history][1], menu_history[#menu_history][2], true)
            if optionNum then
                menu = menu_data[menuID]
                button = menu[menuOption]
                if button.currNum then
                    button.currNum = optionNum
                end
            end
            table.remove(menu_history, #menu_history)
        elseif not showGameResults then
            play_sound(SOUND_MENU_PAUSE, gGlobalSoundSource)
            inMenu = false
        else
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
            inMenu = false
        end
    elseif (m.controller.buttonPressed & Z_TRIG) ~= 0 and menuID == 8 then
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        enter_menu(5, 1)
    elseif (m.controller.buttonPressed & Y_BUTTON) ~= 0 and menuID == 8 then
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        enter_menu(7, 1)
    elseif (m.controller.buttonPressed & X_BUTTON) ~= 0 and (menuID == 8 or menuID == 4 or menuID == 3) then
        local map = 0
        if menuID == 8 then
            map = (menuOption-1) * menu.columns + button.currNum - 2
            if map < 0 then map = 0 end
        elseif menuID == 3 then
            map = get_menu_option(3, 1)
        else
            local course = get_menu_option(4, 1)
            local level = course_to_level[course]
            map = tostring(level) .. " " .. tostring(get_menu_option(4, 2))
        end
        if map ~= 0 then
            local saveCheck = map
            if type(map) == "number" then
                saveCheck = levelData[map].saveName or levelData[map].name or get_level_name(levelData[map].course, levelData[map].level, levelData[map].area or 1)
                saveCheck = saveCheck:gsub("%W", " ")
            end

            local levelName = "ERROR"
            if levelData[map] then
                local level = levelData[map].level
                local area = levelData[map].area or 1
                levelName = levelData[map].name or get_level_name(levelData[map].course, level, area)
                if area ~= 1 and level ~= LEVEL_CASTLE and not levelData[map].name then
                    levelName = levelName .. " (A"..area..")"
                end
            else
                local args = split(map, " ")
                local level = tonumber(args[1]) or LEVEL_WF
                local area = tonumber(args[2]) or 1
                if level == LEVEL_BOWSER_1 then
                    levelName = "Bowser 1"
                elseif level == LEVEL_BOWSER_2 then
                    levelName = "Bowser 2"
                elseif level == LEVEL_BOWSER_3 then
                    levelName = "Bowser 3"
                else
                    levelName = get_level_name(level_to_course[level] or 0, level, area)
                end
                if area ~= 1 and level ~= LEVEL_CASTLE then
                    levelName = levelName .. " (A"..area..")"
                end
                levelName = levelName .. " (CUSTOM)"
            end
            
            if map_blacklist[saveCheck] then
                map_blacklist[saveCheck] = nil
                djui_chat_message_create("Unblacklisted "..levelName..".")
            else
                map_blacklist[saveCheck] = 1
                djui_chat_message_create("Blacklisted "..levelName..".")
            end
            network_send_include_self(true, map_blacklist)
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        end
    end

    if button.currNum and stickCooldownX == 0 then
        if stickX > 64 then
            play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
            button.currNum = button.currNum + 1
            if button.maxNum < button.currNum then
                button.currNum = button.minNum or 1
            elseif button.currNum == button.excludeNum then
                button.currNum = button.currNum + 1
            end
            stickCooldownX = 5
            if button.runOnChange then
                button[2](button.currNum)
            end
        elseif stickX < -64 then
            play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
            button.currNum = button.currNum - 1
            local min = button.minNum or 1
            if button.currNum < min then
                button.currNum = button.maxNum
            elseif button.currNum == button.excludeNum then
                button.currNum = button.currNum - 1
            end
            stickCooldownX = 5
            if button.runOnChange then
                button[2](button.currNum)
            end
        end
    end

    if #menu > 1 and stickCooldownY == 0 then
        if stickY > 64 then
            play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
            local valid = true
            local prevCurrNum = button.currNum
            local LIMIT = #menu
            while valid and LIMIT ~= 0 do
                LIMIT = LIMIT - 1
                menuOption = menuOption - 1
                if menuOption < 1 then
                    menuOption = #menu
                end
                button = menu[menuOption]
                valid = not option_valid(button)
            end
            stickCooldownY = 5
            if menu.squareFormat and prevCurrNum and button.currNum then
                button.currNum = clamp(prevCurrNum, button.minNum or 0, button.maxNum)
            end
        elseif stickY < -64 then
            play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
            local valid = true
            local prevCurrNum = button.currNum
            local LIMIT = #menu
            while valid and LIMIT ~= 0 do
                LIMIT = LIMIT - 1
                menuOption = menuOption + 1
                if #menu < menuOption then
                    menuOption = 1
                end
                button = menu[menuOption]
                valid = not option_valid(button)
            end
            stickCooldownY = 5
            if menu.squareFormat and prevCurrNum and button.currNum then
                button.currNum = clamp(prevCurrNum, button.minNum or 0, button.maxNum)
            end
        end
    end
end

hook_event(HOOK_BEFORE_MARIO_UPDATE, menu_controls)

function set_menu_option(id, option, value)
    menu_data[id][option].currNum = value
end

function get_menu_option(id, option)
    return menu_data[id][option].currNum
end

function option_valid(button)
    if button[3] and not (network_is_server() or network_is_moderator()) then
        return false
    elseif button[4] and button[4]() then
        return false
    end
    return true
end

function new_game_set_settings(msg)
    if menuGameMode >= 0 then
        gGlobalSyncTable.gameMode = menuGameMode
    elseif menuGameMode == -1 then
        gGlobalSyncTable.gameMode = math.random(0, (#game_mode_list - 3)) -- random
    elseif gGlobalSyncTable.gameState == 0 then
        gGlobalSyncTable.gameMode = 0 -- start of cycle (always shine thief)
    else
        gGlobalSyncTable.gameMode = (gGlobalSyncTable.gameMode + 1) % (#game_mode_list - 2) -- cycle
    end

    if gGlobalSyncTable.gameMode == 4 then -- always two teams for renegade roundup
        gGlobalSyncTable.teamMode = 2
    elseif menuTeam ~= -1 then
        gGlobalSyncTable.teamMode = menuTeam
    elseif math.random(1, 2) == 1 then -- 50% chance of free for all
        gGlobalSyncTable.teamMode = 0
    else
        local maxTeam = math.min(get_participant_count() // 2, 8) -- always have at least two people per team
        if maxTeam > 1 then
            gGlobalSyncTable.teamMode = math.random(2, maxTeam)
        else
            gGlobalSyncTable.teamMode = 0
        end
    end

    if menuVariant == 1 then
        if gGlobalSyncTable.gameMode == 0 and (gGlobalSyncTable.teamMode == 2 or get_participant_count() < 3) then
            djui_popup_create("Not enough teams or players for Double Shine!", 2)
            gGlobalSyncTable.variant = 0
        else
            gGlobalSyncTable.variant = menuVariant
        end
    elseif menuVariant >= 0 then
        gGlobalSyncTable.variant = menuVariant
    else
        local bottom = 1
        if (gGlobalSyncTable.gameMode == 0 and (gGlobalSyncTable.teamMode == 2 or get_participant_count() < 3)) then
            bottom = 2
        end
        gGlobalSyncTable.variant = math.random(bottom, #variant_list - 3)
        if menuVariant == -2 and (gGlobalSyncTable.variant == 2 or gGlobalSyncTable.variant == 7) then
            while (gGlobalSyncTable.variant == 2 or gGlobalSyncTable.variant == 7) do
                gGlobalSyncTable.variant = math.random(bottom, #variant_list - 3)
            end
        end
    end
    new_game(msg)
end

-- returns the current value approach the goal value at some rate (50% for going halfway there each time, etc)
function smooth_approach(goal, current, rate)
    local diff = (goal - current)
    local result = goal
    if diff > 1 then
        result = current + math.ceil(diff * rate)
    elseif diff < 1 then
        result = current + math.floor(diff * rate)
    end
    return result
end

-- this is based off of MarioHunt, which is based off of Arena
TEX_SHINE = get_texture_info("shine_hud")
TEX_SHINE_SMALL = get_texture_info("shine_hud_small")
TEX_SHINE_CIRCLE = get_texture_info("shine_hud_circle")
TEX_MAP_ARROW = get_texture_info("map-arrow")
TEX_BALLOON = get_texture_info("balloon")
TEX_BALLOON_SHINE = get_texture_info("balloon_shine")
TEX_CAGE = get_texture_info("cage_hud")
TEX_TARGET = get_texture_info("target")
TEX_MOON = get_texture_info("moon_hud")
TEX_HUD_ITEM = get_texture_info("item_hud")
TEX_HUD_PIPE = get_texture_info("pipe_hud")
TEX_HUD_BLUE_COIN = get_texture_info("blue_coin_hud")
TEX_COG = get_texture_info("cog_hud")
TEX_TRASH = get_texture_info("trash_hud")
TEX_CROWN = get_texture_info("gcrown_hud")
obj_radar = {}
player_radar = {}
for i = 1, MAX_PLAYERS - 1 do
    table.insert(player_radar, { prevX = 0, prevY = 0, prevScale = 0 })
end

function render_radar(tex, o, hudIcon, yOffset, index)
    djui_hud_set_resolution(RESOLUTION_N64)
    local pos = {}
    pos = { x = o.oPosX, y = o.oPosY + (yOffset or 0), z = o.oPosZ } -- I'm just guessing
    local out = { x = 0, y = 0, z = 0 }

    djui_hud_world_pos_to_screen_pos(pos, out)

    local dX = out.x
    local dY = out.y
    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    local dist = vec3f_dist(pos, gMarioStates[0].pos)
    local alpha = clamp(dist, 0, 900) - 800
    if alpha <= 0 then
        hudIcon.prevX = dX
        hudIcon.prevY = dY
        return
    end

    if out.z > -260 then
        local cdist = vec3f_dist(pos, gLakituState.pos)
        if (dist < cdist) then
            dY = 0
        else
            dY = screenHeight
        end
    end

    local eScale = 16 / tex.width
    local scale = (clamp(dist, 0, 2400) / 2000) * eScale
    local r, g, b = 255, 255, 255
    if index then
        local playerColor = network_get_player_text_color_string(index)
        r, g, b = convert_color(playerColor)
    end

    local circle = false
    local num = 0
    if tex == TEX_SHINE and get_shine_owner(o.oBehParams) ~= -1 then
        tex = TEX_SHINE_SMALL
        circle = true
    elseif tex == TEX_CAGE then
        num = o.oAnimState or 0
    end
    local width = tex.width * scale
    dX = dX - width / 2
    dY = dY - width / 2
    if dX > (screenWidth - width) then
        dX = (screenWidth - width)
    elseif dX < 0 then
        dX = 0
    end
    if dY > (screenHeight - width) then
        dY = (screenHeight - width)
    elseif dY < 0 then
        dY = 0
    end

    djui_hud_set_color(r, g, b, alpha)
    djui_hud_render_texture_interpolated(tex, hudIcon.prevX, hudIcon.prevY, hudIcon.prevScale, hudIcon.prevScale,
        dX, dY, scale, scale)
    if circle then
        local cScale = scale * 1.2
        local newWidth = tex.width * cScale
        local cPrevScale = hudIcon.prevScale * 1.2
        local cDX = dX + width * 0.5 - newWidth * 0.5
        local cDY = dY + width * 0.5 - newWidth * 0.5
        local cPrevX = hudIcon.prevX + width * 0.5 - newWidth * 0.5
        local cPrevY = hudIcon.prevY + width * 0.5 - newWidth * 0.5
        djui_hud_set_color(255, 255, sins(frameCounter * 500) * 200, alpha)
        djui_hud_render_texture_interpolated(TEX_SHINE_CIRCLE, cPrevX, cPrevY, cPrevScale, cPrevScale, cDX, cDY,
            cScale, cScale)
    elseif num ~= 0 then
        djui_hud_print_text_interpolated(tostring(num), hudIcon.prevX, hudIcon.prevY, hudIcon.prevScale, dX, dY, scale)
    end

    hudIcon.prevX = dX
    hudIcon.prevY = dY
    hudIcon.prevScale = scale
end

-- renders a border around a rectangle of the given size, with the specified width
function djui_hud_render_rect_border(x, y, width, height, borderWidth)
    djui_hud_render_rect(x, y, borderWidth, height)
    djui_hud_render_rect(x+borderWidth, y, width-borderWidth*2, borderWidth)
    djui_hud_render_rect(x+width-borderWidth, y, borderWidth, height)
    djui_hud_render_rect(x+borderWidth, y+height-borderWidth, width-borderWidth*2, borderWidth)
end

-- renders the painting for this stage, returning its name
function render_painting(map, x, y, scale, alpha, cross, border, trashIcon)
    local levelName = ""
    local tex = get_texture_info("painting_default")
    local doText = true
    if map == -1 then
        tex = get_texture_info("painting_random")
        doText = false
    elseif map == 0 then
        tex = get_texture_info("painting_custom")
        doText = false
    elseif levelData[map] and levelData[map].tex then
        if type(levelData[map].tex) == "string" then
            tex = get_texture_info(levelData[map].tex) or tex
        else
            tex = levelData[map].tex
        end
        doText = false
    end

    local width = tex.width * scale * 2
    if border then
        if menuDarkMode then
            djui_hud_set_color(64, 255, 64, alpha)
        else
            djui_hud_set_color(20, 100, 20, alpha)
        end
        local bWidth = (levelData[map] and levelData[map].borderSize and levelData[map].borderSize * scale * 2) or width
        djui_hud_render_rect_border(x - bWidth / 2 - 8, y + (width-bWidth) / 2 - 8, bWidth + 16, bWidth + 16, 8)
    end
    djui_hud_set_color(255, 255, 255, alpha)
    djui_hud_render_texture(tex, x - width / 2, y, scale * 2, scale * 2)

    if doText then
        local text = ""
        local area = 1
        local level = 0
        if levelData[map] then
            level = levelData[map].level
            area = levelData[map].area or 1
            text = levelData[map].name or get_level_name(levelData[map].course, level, area)
        else
            local args = split(map, " ")
            level = tonumber(args[1]) or LEVEL_WF
            area = tonumber(args[2]) or 1
            if level == LEVEL_BOWSER_1 then
                text = "Bowser 1"
            elseif level == LEVEL_BOWSER_2 then
                text = "Bowser 2"
            elseif level == LEVEL_BOWSER_3 then
                text = "Bowser 3"
            else
                text = get_level_name(level_to_course[level] or 0, level, area)
            end
        end

        levelName = text
        if (levelData[map] == nil or levelData[map].name == nil) and area ~= 1 and level ~= LEVEL_CASTLE then
            levelName = levelName .. " (A" .. area .. ")"
        end

        if text:len() > 10 then
            text = convert_to_abbreviation(text)
            if (levelData[map] == nil or levelData[map].name == nil) and area ~= 1 and level ~= LEVEL_CASTLE then
                text = text .. area
            end
        end
        djui_hud_set_font(FONT_TINY)
        local tWidth = djui_hud_measure_text(text) * scale
        djui_hud_print_text(text, x - tWidth, y + scale * 6, scale * 2)
    end

    -- cross icon
    if cross then
        djui_hud_set_color(255, 255, 255, alpha)
        djui_hud_render_texture(gTextures.no_camera, x-width / 2, y, scale * 8, scale * 8)
    end

    if trashIcon then
        djui_hud_render_texture(TEX_TRASH, x+width/2-32*scale, y, scale*2, scale*2)
        djui_hud_set_font(FONT_HUD)
        djui_hud_print_text("X", x+width/2-32*scale, y, scale)
    end
    return levelName
end

-- prints text on the screen... with color!
function djui_hud_print_text_with_color(text, x, y, scale, alpha, darkMode)
    if darkMode == false then
        djui_hud_set_color(0, 0, 0, alpha or 255)
    else
        djui_hud_set_color(255, 255, 255, alpha or 255)
    end
    local space = 0
    local color = ""
    text, color, render = remove_color(text, true)
    while render ~= nil do
        local r, g, b, a = convert_color(color)
        if alpha then a = alpha end
        djui_hud_print_text(render, x + space, y, scale);
        if r then djui_hud_set_color(r, g, b, a) end
        space = space + djui_hud_measure_text(render) * scale
        text, color, render = remove_color(text, true)
    end
    djui_hud_print_text(text, x + space, y, scale);
end

-- removes color string
function remove_color(text, get_color)
    local start = text:find("\\")
    local next = 1
    while (next ~= nil) and (start ~= nil) do
        start = text:find("\\")
        if start ~= nil then
            next = text:find("\\", start + 1)
            if next == nil then
                next = text:len() + 1
            end

            if get_color then
                local color = text:sub(start, next)
                local render = text:sub(1, start - 1)
                text = text:sub(next + 1)
                return text, color, render
            else
                text = text:sub(1, start - 1) .. text:sub(next + 1)
            end
        end
    end
    return text
end

-- converts hex string to RGB values
function convert_color(text)
    if text:sub(2, 2) ~= "#" then
        return nil
    end
    text = text:sub(3, -2)
    local rstring, gstring, bstring = "", "", ""
    if text:len() ~= 3 and text:len() ~= 6 then return 255, 255, 255, 255 end
    if text:len() == 6 then
        rstring = text:sub(1, 2) or "ff"
        gstring = text:sub(3, 4) or "ff"
        bstring = text:sub(5, 6) or "ff"
    else
        rstring = text:sub(1, 1) .. text:sub(1, 1)
        gstring = text:sub(2, 2) .. text:sub(2, 2)
        bstring = text:sub(3, 3) .. text:sub(3, 3)
    end
    local r = tonumber("0x" .. rstring) or 255
    local g = tonumber("0x" .. gstring) or 255
    local b = tonumber("0x" .. bstring) or 255
    return r, g, b, 255 -- alpha is no longer writeable
end

-- get place string (1st, 2nd, etc.)
function placeString(num)
    local twoDigit = num % 100
    local oneDigit = num % 10
    if num == 1 then
        return "\\#e3bc2d\\1st"
    elseif num == 2 then
        return "\\#c5d8de\\2nd"
    elseif num == 3 then
        return "\\#b38752\\3rd"
    end

    if twoDigit > 3 and twoDigit < 20 then
        return tostring(num) .. "th"
    elseif oneDigit == 1 then
        return tostring(num) .. "st"
    elseif oneDigit == 2 then
        return tostring(num) .. "nd"
    elseif oneDigit == 3 then
        return tostring(num) .. "rd"
    end
    return tostring(num) .. "th"
end

-- generates a new tip based on the mode and other settings
function new_tip()
    local tip_curr_mode = tip_game_mode[gGlobalSyncTable.gameMode + 1]
    local tipNum = 0
    if gNetworkPlayers[0].name == "Unreal" then
        return tip_general[4] -- always show credit tip
    elseif gGlobalSyncTable.items ~= 0 then
        tipNum = math.random(1, #tip_general + #tip_curr_mode + #tip_item)
    else
        tipNum = math.random(1, #tip_general + #tip_curr_mode)
    end

    local text = ""
    if tipNum > #tip_general + #tip_curr_mode then
        text = tip_item[tipNum - #tip_general - #tip_curr_mode]
    elseif tipNum > #tip_general then
        text = tip_curr_mode[tipNum - #tip_general]
    else
        text = tip_general[tipNum]
    end

    text = string.gsub(text, "ITEM_BUTTON", ITEM_BUTTON_STRING)
    text = string.gsub(text, "GAME_TIME", string.format("%d minute(s)", gGlobalSyncTable.maxGameTime))
    text = string.gsub(text, "SPECIAL_BUTTON", SPECIAL_BUTTON_STRING)

    if gGlobalSyncTable.gameMode == 0 or gGlobalSyncTable.gameMode == 4 then -- since there's nothing to steal in Renegade Roundup, give the shine tip
        text = string.gsub(text, "SHINE_OR_BALLOON", "the Shine")
    elseif gGlobalSyncTable.gameMode == 3 then
        text = string.gsub(text, "SHINE_OR_BALLOON", "10 coins")
    elseif gGlobalSyncTable.gameMode == 5 then
        text = string.gsub(text, "SHINE_OR_BALLOON", "a Moon")
    else
        text = string.gsub(text, "SHINE_OR_BALLOON", "a balloon")
    end
    return text
end

-- minimap pos calculation
function get_minimap_pos(pos, center, levelSize, mapWidth)
    return clampf((pos-center) / (levelSize * 2) + 0.5, 0, 1) * mapWidth
end

-- renders player head... with color!
local PART_ORDER = {
    SKIN,
    HAIR,
    CAP,
}

HEAD_HUD = get_texture_info("hud_head_recolor")
WING_HUD = get_texture_info("hud_wing")
CS_ACTIVE = _G.charSelectExists

local defaultIcons = {
    [gTextures.mario_head.name] = true,
    [gTextures.luigi_head.name] = true,
    [gTextures.toad_head.name] = true,
    [gTextures.waluigi_head.name] = true,
    [gTextures.wario_head.name] = true,
}

-- the actual head render function.
--- @param index integer
--- @param x integer
--- @param y integer
--- @param scaleX number
--- @param scaleY number
function render_player_head(index, x, y, scaleX, scaleY, noSpecial, alwaysCap, alpha_)
    local m = gMarioStates[index]
    local np = gNetworkPlayers[index]

    -- default head
    if not np.connected then
        djui_hud_set_color(255, 255, 255, alpha_ or 255)
        local oldFont = djui_hud_get_font()
        djui_hud_set_font(FONT_HUD)
        djui_hud_print_text("?", x, y, scaleX)
        djui_hud_set_font(oldFont)
        return
    end

    local alpha = alpha_ or 255
    if (not noSpecial) and (m.marioBodyState.modelState & MODEL_STATE_NOISE_ALPHA) ~= 0 then
        alpha = math.max(alpha - 155, 0) -- vanish effect
    end

    if charSelectExists then
        djui_hud_set_color(255, 255, 255, alpha)
        local TEX_CS_ICON = charSelect.character_get_life_icon(index)
        if TEX_CS_ICON and not defaultIcons[TEX_CS_ICON.name] then -- changed for new char select version
            djui_hud_render_texture(TEX_CS_ICON, x, y, scaleX / (TEX_CS_ICON.width * 0.0625),
                scaleY / (TEX_CS_ICON.width * 0.0625))

            -- star effect
            if (not noSpecial) and gPlayerSyncTable[index].star then
                djui_hud_set_color(m.marioBodyState.shadeR, m.marioBodyState.shadeG, m.marioBodyState.shadeB, alpha-155)
                djui_hud_render_texture(TEX_CS_ICON, x, y, scaleX / (TEX_CS_ICON.width * 0.0625),
                scaleY / (TEX_CS_ICON.width * 0.0625))
            end

            if (not noSpecial) and m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
                djui_hud_render_texture(WING_HUD, x, y, scaleX, scaleY) -- wing
            end
            -- render box in bottom left for team
            local sMario = gPlayerSyncTable[index]
            if sMario.team and sMario.team ~= 0 and TEAM_DATA[sMario.team] then
                local color = TEAM_DATA[sMario.team][1]
                djui_hud_set_color(color.r, color.g, color.b, 255)
                djui_hud_render_rect(x + scaleX * 10, y + scaleY * 10, scaleX * 6, scaleY * 6)
            end
            return
        elseif TEX_CS_ICON == nil then
            local oldFont = djui_hud_get_font()
            djui_hud_set_font(FONT_HUD)
            djui_hud_print_text("?", x, y, scaleX)
            -- star effect
            if (not noSpecial) and gPlayerSyncTable[index].star then
                djui_hud_set_color(m.marioBodyState.shadeR, m.marioBodyState.shadeG, m.marioBodyState.shadeB, alpha-155)
                djui_hud_print_text("?", x, y, scaleX)
            end
            djui_hud_set_font(oldFont)

            if (not noSpecial) and m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
                djui_hud_render_texture(WING_HUD, x, y, scaleX, scaleY) -- wing
            end
            -- render box in bottom left for team
            local sMario = gPlayerSyncTable[index]
            if sMario.team and sMario.team ~= 0 and TEAM_DATA[sMario.team] then
                local color = TEAM_DATA[sMario.team][1]
                djui_hud_set_color(color.r, color.g, color.b, 255)
                djui_hud_render_rect(x + scaleX * 10, y + scaleY * 10, scaleX * 6, scaleY * 6)
            end
            return
        end
    end
    local isMetal = false
    local capless = false

    local tileY = m.character.type
    for i = 1, #PART_ORDER do
        local color = { r = 255, g = 255, b = 255 }
        if (not noSpecial) and (m.marioBodyState.modelState & MODEL_STATE_METAL) ~= 0 then -- metal
            color = network_player_get_override_palette_color(np, METAL)
            djui_hud_set_color(color.r, color.g, color.b, alpha)
            isMetal = true

            if (not (noSpecial or alwaysCap)) and m.marioBodyState.capState == MARIO_HAS_DEFAULT_CAP_OFF then
                capless = true
                djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, 7 * 16, tileY * 16, 16, 16) -- capless metal
            else
                djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, 5 * 16, tileY * 16, 16, 16)
            end
            break
        end

        local part = PART_ORDER[i]
        if (not (noSpecial or alwaysCap)) and part == CAP and m.marioBodyState.capState == MARIO_HAS_DEFAULT_CAP_OFF then -- capless check
            capless = true
            part = HAIR
        elseif tileY == 2 or tileY == 7 then
            if part == CAP and capless then return end
            tileY = 7            -- use alt toad
            if part == HAIR then -- toad doesn't use hair except when cap is off
                if (not (noSpecial or alwaysCap)) and m.marioBodyState.capState == MARIO_HAS_DEFAULT_CAP_OFF then
                    capless = true
                    part = HAIR
                else
                    part = GLOVES
                end
            end
        end
        color = network_player_get_override_palette_color(np, part)

        djui_hud_set_color(color.r, color.g, color.b, alpha)
        if capless then
            djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, 6 * 16, tileY * 16, 16, 16) -- render hair instead of cap
        else
            djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (i - 1) * 16, tileY * 16, 16, 16)
        end

        -- star effect; render texture with our shade over
        if (not noSpecial) and gPlayerSyncTable[index].star then
            djui_hud_set_color(m.marioBodyState.shadeR, m.marioBodyState.shadeG, m.marioBodyState.shadeB, alpha-155)
            if capless then
                djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, 6 * 16, tileY * 16, 16, 16) -- render hair instead of cap
            else
                djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (i - 1) * 16, tileY * 16, 16, 16)
            end
        end
    end

    if not isMetal then
        djui_hud_set_color(255, 255, 255, alpha)
        --djui_hud_render_texture(HEAD_HUD, x, y, scaleX, scaleY)
        djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (#PART_ORDER) * 16, tileY * 16, 16, 16)

        if not capless then
            djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (#PART_ORDER + 1) * 16, tileY * 16, 16, 16) -- hat emblem
            if (not noSpecial) and m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
                djui_hud_render_texture(WING_HUD, x, y, scaleX, scaleY)                                              -- wing
            end
        end
    elseif m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
        djui_hud_set_color(109, 170, 173, alpha)                -- blueish green
        djui_hud_render_texture(WING_HUD, x, y, scaleX, scaleY) -- wing
    end
end

-- arena map support
local addedMcDonalds = false
_G.Arena = {}
_G.Arena.add_level = function(level, name)
    table.insert(levelData, {
        level = level,
        course = 0,
        name = name,
        area = 1,
    })
    menu_data[3][1].maxNum = #levelData -- make selectable
    table.insert(course_to_level, level)
end

-- tag map support
_G.tag = {}
_G.tag.add_level = function(level, name, painting, area, pipes, spawnLocation)
    table.insert(levelData, {
        level = level,
        course = 0,
        name = name,
        area = area,
        tex = painting,
    })
    local data = levelData[#levelData]
    if spawnLocation then
        data.startLocations = {}
        data.startLocations[0] = { spawnLocation.x, spawnLocation.y, spawnLocation.z }
    end

    if pipes then
        data.objLocations = {}
        local set = 0
        for i, pair in ipairs(pipes) do
            table.insert(data.objLocations,
                { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, pair[1].x, pair[1].y, pair[1].z, set, set + 1 })
            table.insert(data.objLocations,
                { id_bhvSTPipe, E_MODEL_BITS_WARP_PIPE, pair[2].x, pair[2].y, pair[2].z, set + 1, set })
            set = set + 2
        end
    end

    menu_data[3][1].maxNum = #levelData -- make selectable
    table.insert(course_to_level, level)
end

-- mcdonalds support
function add_mcdonalds()
    if addedMcDonalds then return end
    addedMcDonalds = true

    table.insert(levelData, {
        level = 100,
        course = 0,
        name = "McDonald's",
        area = 1,
        act = 0,
        tex = "painting_md",

        startLocations = {
            [0] = { 10, 1154, 3910 },
        },
        shineStart = { 310, 985, 230 },

        --[[objLocations = {
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -1114, 300, -1150, 0, 0, 0x4000, 16384 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -1114, 300, -445,  0, 0, 0x4000, 16384 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, 627,   300, -445,  0, 0, 0x4000, 16384 },
            { id_bhvStaticCheckeredPlatform, E_MODEL_CHECKERBOARD_PLATFORM, -276,  300, -1430, 0, 0, 0x4000, 0 },
        },]]

        itemBoxLocations = {
            { -1045, 292, 966 },
            { -2402, 292, -3160 },
            { -2418, 343, -2434 },
            { 3403,  292, 496 },
            { 950,   292, 970 },
            { 960,   292, -1360 },
            { -900,  985, -1190 },
            { 374,   985, -1190 },
            { -1787, 270, -140 },
            { -1475, 270, -140 },
            { 189,   270, -3156 },
            { 189,   270, -2428 },
            { 189,   270, -1804 },
            { 1060,  270, -452 },
            { 1684,  270, -452 },
            { 2330,  270, -452 },
            { -3689, 292, 1730 },
            { -3535, 292, -492 },
            { -3317, 292, -2472 },
            { -1722, 292, 3878 },
            { 1683,  292, 3973 },
        },
    })
    menu_data[3][1].maxNum = #levelData -- make selectable
    table.insert(course_to_level, 100)
end

-- fix issue with romhacks and adding base stages
function menu_update_for_romhack(levels)
    menu_data[3][1].currNum = 1
    menu_data[3][1].maxNum = levels
end

-- set menu settings when starting a new game
function menu_set_settings(load)
    doVoteCalc = true
    currTip = nil
    if load then
        menuTeam = load_setting("teamMode") or 0
        menuVariant = load_setting("variant") or 0
        if menuVariant > (#variant_list - 3) then menuVariant = 0 end
        if menuVariant >= 0 then
            gGlobalSyncTable.variant = menuVariant
        end
        menuGameMode = load_setting("gameMode") or 0
        if menuGameMode >= 0 then
            gGlobalSyncTable.gameMode = menuGameMode
        else
            gGlobalSyncTable.gameMode = math.random(0, (#game_mode_list - 3)) -- both random and cycle start at a random spot
        end
        if gGlobalSyncTable.gameMode == 4 then
            gGlobalSyncTable.teamMode = 2
        elseif menuTeam ~= -1 then
            gGlobalSyncTable.teamMode = menuTeam
        end
        gGlobalSyncTable.mapChoice = load_setting("mapChoice") or (gServerSettings.headlessServer ~= 0 and 1) or 0
        gGlobalSyncTable.items = load_setting("items") or 1
        gGlobalSyncTable.maxGameTime = load_setting("maxGameTime") or 3
        gGlobalSyncTable.startBalloons = load_setting("initBalloons") or 3
        gGlobalSyncTable.godMode = load_setting("godMode", true) or false
        gGlobalSyncTable.bombSetting = load_setting("bombSetting") or 1
        gGlobalSyncTable.reduceObjects = load_setting("reduceObjects", true) or false
        gGlobalSyncTable.arenaStyleItems = load_setting("arenaStyle", true) or false
    else
        if menuTeam ~= -1 and gGlobalSyncTable.gameMode ~= 4 then
            menuTeam = gGlobalSyncTable.teamMode
        end
        if menuVariant >= 0 and (menuVariant ~= 1 or gGlobalSyncTable.variant ~= 0) then
            menuVariant = gGlobalSyncTable.variant
        end
        if menuGameMode >= 0 then
            menuGameMode = gGlobalSyncTable.gameMode
        end
    end
    prevPointCount = 0
    set_menu_option(5, 1, menuGameMode)
    set_menu_option(5, 2, gGlobalSyncTable.mapChoice)
    set_menu_option(5, 3, menuVariant)
    set_menu_option(5, 4, menuTeam)
    set_menu_option(5, 5, gGlobalSyncTable.items)
    set_menu_option(5, 6, (gGlobalSyncTable.arenaStyleItems and 1) or 0)
    set_menu_option(5, 7, gGlobalSyncTable.maxGameTime)
    set_menu_option(5, 8, gGlobalSyncTable.startBalloons)
    set_menu_option(5, 9, (gGlobalSyncTable.godMode and 1) or 0)
    set_menu_option(5, 10, gGlobalSyncTable.bombSetting)
    set_menu_option(5, 11, (gGlobalSyncTable.reduceObjects and 1) or 0)
end

-- converts text to sm64 style abbreviation (ex: Bowser In The Sky becomes BitS)
function convert_to_abbreviation(text)
    local ab = ""
    local start, send = string.find(text, "%a+")
    while start ~= nil do
        local word = text:sub(start, send):upper()
        if word ~= "OF" and word ~= "THE" and word ~= "IN" and word ~= "S" and word ~= "OVER" and word ~= "OMB" then
            ab = ab .. word:sub(1, 1)
        elseif ab ~= "" and word ~= "S" then
            ab = ab .. word:sub(1, 1):lower()
        end
        start, send = string.find(text, "%a+", send + 1)
    end
    return ab
end

-- for api
function add_variant(name, tip_)
    local tip = tip_ or ""
    table.insert(variant_list, name)
    table.insert(tip_variant, tip)
    menu_data[5][2].maxNum = (#variant_list - 3)
    return (#variant_list - 3)
end

-- set controls based on menu selection
function setup_controls(updateMenu)
    local baseButtons = {X_BUTTON, Y_BUTTON, L_TRIG, R_TRIG, A_JPAD}
    local nameRef = { "X", "Y", "L", "R", "D-Pad", "X + D-Pad", "Y + D-Pad", "L + D-Pad", "R + D-Pad" }
    if itemBindSelection < 5 then
        ITEM_BUTTON = baseButtons[itemBindSelection+1]
        ITEM_OVERRIDE_BUTTON = 0
    else
        ITEM_BUTTON = A_JPAD
        ITEM_OVERRIDE_BUTTON = baseButtons[itemBindSelection-4]
    end
    ITEM_BUTTON_STRING = nameRef[itemBindSelection+1]

    if specialBindSelection < 5 then
        SPECIAL_BUTTON = baseButtons[specialBindSelection+1]
        SPECIAL_OVERRIDE_BUTTON = 0
    else
        SPECIAL_BUTTON = A_JPAD
        SPECIAL_OVERRIDE_BUTTON = baseButtons[specialBindSelection-4]
    end
    SPECIAL_BUTTON_STRING = nameRef[specialBindSelection+1]

    if updateMenu then
        set_menu_option(7, 1, itemBindSelection)
        set_menu_option(7, 2, specialBindSelection)
    end
end

setup_controls()

-- custom player list
local expectedPlayerListSetting = true
local truePlayerListSetting = true
local playerListCurrY = {}
local wasOpening = false
for i=1,MAX_PLAYERS do
    table.insert(playerListCurrY, 0)
end
function render_custom_player_list()
    -- custom player list
    local gServerSettings = gServerSettings
    if gServerSettingsCS then
        gServerSettings = gServerSettingsCS -- use character select's player list
    end

    if expectedPlayerListSetting ~= gServerSettings.enablePlayerList then
        expectedPlayerListSetting = gServerSettings.enablePlayerList
        truePlayerListSetting = expectedPlayerListSetting
    end
    if truePlayerListSetting == 0 then return end

    if not customPlayerList then
        gServerSettings.enablePlayerList = true
        expectedPlayerListSetting = 1
        return
    end
    gServerSettings.enablePlayerList = false
    expectedPlayerListSetting = 0
    if not djui_attempting_to_open_playerlist() then
        wasOpening = false
        return
    end

    -- base square
    local bodyHeight = (16 * 32) + (16 - 1) * 4;
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_MENU)
    local DjuiTheme = djui_menu_get_theme()
    local color1 = DjuiTheme.threePanels.borderColor
    local color2 = DjuiTheme.threePanels.rectColor
    djui_hud_set_color(color1.r, color1.g, color1.b, color1.a)
    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()
    local width = 710
    local height = bodyHeight + (32 + 16) + 32 + 32
    local borderWidth = 8
    local x = (screenWidth - width) / 2
    local y = (screenHeight - height) / 2
    djui_hud_render_rect_border(x, y, width, height, borderWidth)
    djui_hud_set_color(color2.r, color2.g, color2.b, color2.a)
    width = width - borderWidth * 2
    height = height - borderWidth * 2
    x = (screenWidth - width) / 2
    y = (screenHeight - height) / 2
    djui_hud_render_rect(x, y, width, height)

    -- title
    local text = trans_table[smlua_text_utils_get_language()]["players"] or "PLAYERS"
    local tWidth = djui_hud_measure_text(text)
    djui_hud_print_text_rainbow(text, x + (width - tWidth) / 2, y + 6, 1, 255, DjuiTheme.panels.hudFontHeader)

    -- players
    djui_hud_set_font(djui_menu_get_font())
    width = width - 32
    height = 32
    y = y + 80
    local initialY = y
    calculate_placements()
    local rendered = 0
    local renderedPlayers = {}
    for i,data in ipairs(placementTable) do
        if rendered >= 16 then break end
        local index = data.index
        local np = gNetworkPlayers[index]
        if np.connected or DEBUG_SCORES then
            rendered = rendered + 1
            renderedPlayers[index] = 1
            local sMario = gPlayerSyncTable[index]
            x = (screenWidth - width) / 2
            if menuMotionEnabled then
                local expectedY = initialY + 36 * (i-1)
                if wasOpening and playerListCurrY[index] ~= 0 then
                    playerListCurrY[index] = smooth_approach(expectedY, playerListCurrY[index], 0.25)
                else
                    playerListCurrY[index] = expectedY
                end
                y = playerListCurrY[index]
            end

            if data.team ~= 0 then
                local color = deep_copy(TEAM_DATA[data.team][1])
                local v = 50
                color.r = math.max(0, color.r - v)
                color.g = math.max(0, color.g - v)
                color.b = math.max(0, color.b - v)
                djui_hud_set_color(color.r, color.g, color.b, 128)
            else
                local v = 16 + (i % 2) * 16
                djui_hud_set_color(v, v, v, 128)
            end
            djui_hud_render_rect(x, y, width, height)
            -- border for our player
            if index == 0 then
                djui_hud_set_color(255, 255, 0, 128)
                djui_hud_render_rect(x, y-2, width, 2) -- top
                djui_hud_render_rect(x, y+height, width, 2) -- bottom
                djui_hud_render_rect(x-2, y-2, 2, height+4) -- left
                djui_hud_render_rect(x+width, y-2, 2, height+4) -- right
            end

            if data.placement ~= 0 and (gGlobalSyncTable.gameMode ~= 4 or (gGlobalSyncTable.gameState and gGlobalSyncTable.gameState > 2)) and not sMario.spectator then
                x = x + 5
                local place = placeString(data.placement)
                djui_hud_print_text_with_color(place, x, y, 1)
                x = x + 60
            end
            djui_hud_set_color(255, 255, 255, 255)
            render_player_head(index, x, y, 2, 2, false, true)
            x = x + 40
            local playerColor = network_get_player_text_color_string(index)
            local name = np.name
            if name == "" then name = tostring(index) end
            text = playerColor .. name
            if data.team ~= 0 and gGlobalSyncTable.gameMode ~= 4 then
                local colorString = TEAM_DATA[data.team][3]:sub(1, 9)
                text = text .. colorString .. " (" .. TEAM_DATA[data.team][4] .. ")"
            end
            while djui_hud_measure_text(remove_color(text)) + x > (screenWidth + width / 2) / 2 do
                text = text:sub(1, -2)
            end
            djui_hud_print_text_with_color(text, x, y, 1)

            -- points/description
            text = ""
            if data.team == 0 or gGlobalSyncTable.gameMode == 4 or sMario.spectator then
                text = np.description
                djui_hud_set_color(np.descriptionR, np.descriptionG, np.descriptionB, np.descriptionA)
            elseif sMario.isBomb then
                text = "Bomb"
                if data.team ~= 4 then
                    djui_hud_set_color(128, 64, 64, 255) -- faint red
                else
                    djui_hud_set_color(64, 64, 64, 255) -- grey so it's actually readable
                end
            elseif is_spectator(index) then
                text = "Lost"
                djui_hud_set_color(255, 30, 30, 255) -- deep red
            elseif gGlobalSyncTable.gameMode == 1 then
                text = tostring(sMario.balloons)
                if data.placement == 1 then
                    djui_hud_set_color(255, 255, 64, 255) -- yellow
                else
                    djui_hud_set_color(255, 64, 64, 255) -- red
                end
            else
                text = tostring(get_point_amount(index))
                if gGlobalSyncTable.gameMode == 2 or gGlobalSyncTable.gameMode == 3 then
                    text = text .. " (" .. tostring(sMario.points) .. ")"
                end
                local highlight = (data.placement == 1)
                if gGlobalSyncTable.gameMode == 0 then
                    highlight = (get_player_owned_shine(index) ~= 0)
                elseif gGlobalSyncTable.gameMode == 5 then
                    highlight = (not has_least_points(index))
                end
                if highlight then
                    djui_hud_set_color(255, 255, 64, 255) -- yellow
                else
                    djui_hud_set_color(255, 64, 64, 255) -- red
                end
            end
            tWidth = djui_hud_measure_text(text)
            x = (screenWidth + width) / 2 - tWidth - 16
            
            djui_hud_print_text(text, x, y, 1)

            y = y + 36
        end
    end
    -- if any players didn't get rendered on here, add them to the placement table
    if gGlobalSyncTable.gameState == 3 and rendered < 16 then
        for i=0,MAX_PLAYERS-1 do
            if gNetworkPlayers[i].connected and not renderedPlayers[i] then
                table.insert(placementTable, {index = i, placement = 0, team = gPlayerSyncTable[i].team or 0, score = 0})
            end
        end
    end

    -- mods list base square
    local renderModList = gActiveMods
    local csPacks = 0
    if charSelectExists then
        -- only show non-cs mods
        renderModList = {}
        local a = 0
        for i=0,#gActiveMods do
            local mod = gActiveMods[i]
            if (mod.name and mod.name == "Character Select") or (remove_color(mod.name):sub(1, 4) ~= "[CS]" and mod.category ~= "cs") then
                renderModList[a] = mod
                a = a + 1
            else
                csPacks = csPacks + 1
            end
        end
    end
    local activeModNum = #renderModList + 1
    bodyHeight = (activeModNum * 32) + (activeModNum - 1) * 4;
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_MENU)
    djui_hud_set_color(color1.r, color1.g, color1.b, color1.a)
    width = 280
    height = bodyHeight + (32 + 16) + 32 + 32
    x = (screenWidth + 710) / 2 + 8
    y = (screenHeight - height) / 2
    djui_hud_render_rect(x, y, borderWidth, height)
    djui_hud_render_rect(x+borderWidth, y, width-borderWidth*2, borderWidth)
    djui_hud_render_rect(x+width-borderWidth, y, borderWidth, height)
    djui_hud_render_rect(x+borderWidth, y+height-borderWidth, width-borderWidth*2, borderWidth)
    djui_hud_set_color(color2.r, color2.g, color2.b, color2.a)
    width = width - 16
    height = height - 16
    x = x + 8
    y = (screenHeight - height) / 2
    djui_hud_render_rect(x, y, width, height)

    -- mods list title
    text = trans_table[smlua_text_utils_get_language()]["mods"] or "MODS"
    tWidth = djui_hud_measure_text(text)
    djui_hud_print_text_rainbow(text, x + (width - tWidth) / 2, y + 6, 1, 255, DjuiTheme.panels.hudFontHeader)

    -- mods list mods
    djui_hud_set_font(djui_menu_get_font())
    width = width - 32
    height = 32
    y = y + 80
    for i=0,activeModNum-1 do
        local mod = renderModList[i]
        x = (screenWidth + 710) / 2 + 32
        local v = 32 - (i % 2) * 16
        djui_hud_set_color(v, v, v, 128)
        djui_hud_render_rect(x, y, width, height)
        djui_hud_set_color(220, 220, 220, 255)
        text = mod.name
        if text == "Character Select" then
            text = text .. " (+"..csPacks..")"
        end
        while djui_hud_measure_text(remove_color(text)) > width do
            text = text:sub(1, -2)
        end
        djui_hud_print_text_with_color(text, x, y, 1)
        y = y + 36
    end
    wasOpening = true
end
hook_event(HOOK_ON_HUD_RENDER, render_custom_player_list)

-- translation table (custom player list)
trans_table = {
    ["Czech"] = {
      players = "HRACI",
      mods = "MODY",
    },
    ["Dutch"] = {
      players = "Spelers",
      mods = "MODS",
    },
    ["French"] = {
      players = "JOUREURS",
      mods = "MODS",
    },
    ["German"] = {
      players = "SPIELER",
      mods = "MODS",
    },
    ["Italian"] = {
      players = "GIOCATORI",
      mods = "MODS",
    },
    ["Polish"] = {
      player = "GRACZE",
      mods = "MODS",
    },
    ["Portuguese"] = {
      players = "JOGADORES",
      mods = "MODS",
    },
    ["Russian"] = {
      players = "PLAYERS",
      mods = "MODS",
    },
    ["Spanish"] = {
      players = "JUGADORES",
      mods = "MODS",
    },
    ["English"] = {
        players = "PLAYERS",
        mods = "MODS",
    }
  }

-- temporarily function for theme info, since this function won't be exposed until next update
djui_menu_get_theme = djui_menu_get_theme or function()
    return {
        threePanels = {
            rectColor = {r = 0, g = 0, b = 0, a = 230},
            borderColor = {r = 0, g = 0, b = 0, a = 200},
        },
        panels = {
            hudFontHeader = false,
        },
    }
    -- file select theme
    --[[return {
        threePanels = {
            rectColor = {r = 208, g = 165, b = 32, a = 255},
            borderColor = {r = 182, g = 135, b = 8, a = 255}
        },
        panels = {
            hudFontHeader = true,
        },
    }]]
end

-- print text in red, green, blue, yellow for each character
local sRainbowColors = {
    {0xff, 0x30, 0x30},
    {0x40, 0xe7, 0x40},
    {0x40, 0xb0, 0xff},
    {0xff, 0xef, 0x40},
}
function djui_hud_print_text_rainbow(text, x, y, scale, alpha_, hudFont)
    if not text then return end
    if hudFont then
        djui_hud_set_font(FONT_HUD)
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_print_text(text, x+8*scale, y+16*scale, scale*2.8)
        return
    end
    local alpha = alpha_ or 255
    for i = 1, text:len() do
        local char = text:sub(i,i)
        local width = djui_hud_measure_text(char) * scale
        local color = sRainbowColors[(i-1) % 4+1]
        djui_hud_set_color(color[1], color[2], color[3], alpha)
        djui_hud_print_text(char, x, y, scale)
        x = x + width
    end
end