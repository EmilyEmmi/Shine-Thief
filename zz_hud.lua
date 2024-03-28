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

local prevTimerNum = {}
local localGameTimer = 0
local frameCounter = 0
local tipNum = 0
local doVoteCalc = true
local votesNumber = { 0, 0, 0 }
local voteScreenTimer = 0

local menu_history = {}
local variant_list = {
    "Random",
    "None",
    "\\#ff9040\\Double Shine",
    "\\#f7b5b5\\Air Battle",
    "\\#4e8f3b\\Shell Rush",
    "\\#5100ff\\Moon Gravity",
    "\\#ff0051\\Boost To Win",
    "\\#b0aca9\\Bombs!!!",
    "\\#9000ff\\Air + Boost",
}
local tip_general = {
    "Tip: When you have only 3 seconds left, the timer slows down.",
    "Tip: If you lose the Shine, you will always have at least 5 seconds left.",
    "Tip: A slide kick will instantly steal the Shine.",
    "Tip: This mod has OMM Rebirth support!",
    "Tip: Team mode can be set to random to randomly pick a number of teams or zero.",
    "Tip: If you get stuck, pause and select 'Respawn' to respawn.",
    "Mod created by EmilyEmmi, with help from EmeraldLockdown and resources from others.",
    "Tip: If someone offers to grant you 3 wishes, there's probably a catch.",
    "Tip: The host can reset the Shine's position with /reset.",
    "Tip: The player holding the Shine moves a bit slower.",
    "Tip: In Team Mode, press ITEM_BUTTON while not holding an item to pass the Shine.",
    "Tip: After 5 minutes, the shine timer will be halved.",
    "Tip: You can enter Spectator Mode in the menu.",
    "Tip: Turn on God Mode to allow players to walk on lava and quicksand.",
    "Tip: Variants can be set to Random to pick a random variant each game!",
    "Tip: Ceiling climbing is a lot faster than in vanilla.",
}
local tip_variant = {
    "Tip: Two players must each hold a Shine to win.",
    "Tip: The player holding the Shine will fly much slower.",
    "Tip: Press SPECIAL_BUTTON to spawn a shell. This can also be done in midair.",
    "Tip: You'll jump higher and fall slower. Hold Z to fall faster.",
    "Tip: Hold SPECIAL_BUTTON to boost!",
    "Tip: Press SPECIAL_BUTTON to throw bombs. Use the D-PAD to change the direction.",
    "Tip: Hold SPECIAL_BUTTON to boost! This can also be done while flying.",
}
local tip_item = {
    "Tip: Using a Mushroom lets you move faster AND steal the Shine on any attack.",
    "Tip: You can throw items in front of you, behind you, or to the side with the D-PAD.",
    "Tip: The Feather can be used as a double jump or to steal the Shine.",
    "Tip: You can dive, kick, or ground pound after using a feather.",
    "Tip: Red Shells can fly to hit players.",
    "Tip: Red Shells will automatically target the player in front of them.",
    "Tip: The Boomerang can be thrown up to 3 times.",
    "Tip: The Boomerang can hurt players on its return, too.",
    "Tip: The POW Block hits any players standing on the ground.",
    "Tip: The Super Star makes you invincible and lets you attack players just by touching them!",
    "Tip: The Super Star does NOT make you faster.",
    "Tip: Two players with a Super Star can hurt each other.",
    "Tip: The Super Star lasts 10 seconds.",
    "Tip: Players falling behind will get better items.",
    "Tip: The Fire Flower can be used 5 times.",
    "Tip: The Bullet Bill item turns you into an explosive Bullet Bill for 5 seconds.",
    "Tip: The Bullet Bill can be canceled with the B button or by ground pounding.",
    "Tip: You can launch the Bullet Bill in different directions with the D-PAD.",
    "Tip: Only certain items can be obtained while close to victory.",
    "Tip: Some items have rarer, triple forms.",
    "Tip: The Banana can be thrown a far distance if you hold UP un the D-PAD.",
    "Tip: More powerful items will appear if Items are set to Frantic.",
    "Tip: Less powerful items will appear if Items are set to Skilled.",
}
local SPECIAL_BUTTON_STRING = "Y"
local ITEM_BUTTON_STRING = "X"
if _G.OmmEnabled then
    tip_general[3] = "Tip: A slide kick or Cappy attack will instantly steal the Shine."
    tip_general[4] = "Tip: After throwing Cappy, You can perform a homing attack by pressing the D-PAD."
    SPECIAL_BUTTON_STRING = "L"
    ITEM_BUTTON_STRING = "the D-PAD while holding R"
end

local TEAM_NAMES = {
    "\\#ff4040\\Red Team",
    "\\#4040ff\\Blue Team",
    "\\#40ff40\\Green Team",
    "\\#ffff40\\Yellow Team",
    "\\#ffa014\\Orange Team",
    "\\#40ffff\\Cyan Team",
    "\\#ffa1eb\\Pink Team",
    "\\#a040ff\\Violet Team",
}

local DEFAULT_MAP_SIZE = 8192

-- menu data
local menu_data = {
    [1] = {
        { "Continue", function() inMenu = false end },
        { "Respawn", function()
            on_pause_exit(false)
            inMenu = false
        end },
        { "Spectate", function() spectator_mode() end },
        { "Restart",  function() new_game() end,      true },
        { "New Game", function() enter_menu(3) end,   true },
        { "Options",  function() enter_menu(5) end,   true },
    },
    [2] = {
        { "Play Again", function() new_game() end,    true },
        { "New Game",   function() enter_menu(3) end, true },
        { "Options",    function() enter_menu(5) end, true },
    },
    [3] = {
        { "Placeholder", function(x) new_game_set_settings(x) end, currNum = 2, maxNum = #levelData },
        { "Random",      function() start_random_level(true) end },
        { "Custom",      function() enter_menu(4) end },
        { "Options",     function() enter_menu(5) end,             true },
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
            nameRef = { "On", "Off" },
        },
        { "Random", function()
            start_random_level()
        end },
        { "Options", function() enter_menu(5) end },
    },
    [5] = {
        {
            "Map",
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
            nameRef = { "Choose", "Vote", "Random" },
            runOnChange = true
        },
        {
            "Variant",
            function(x)
                menuVariant = x
                save_setting("variant", x)
            end,
            currNum = 0,
            minNum = -1,
            maxNum = #variant_list - 2,
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
            nameRef = { "Random" },
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
            nameRef = { "Off", "Normal", "Frantic", "Skilled" },
            runOnChange = true
        },
        {
            "God Mode",
            function(x)
                gGlobalSyncTable.godMode = (x == 1)
                save_setting("godMode", (x == 1))
            end,
            currNum = 0,
            minNum = 0,
            maxNum = 1,
            nameRef = { "Off", "On" },
            runOnChange = true
        },
    },
    [6] = {
        {
            "Placeholder",
            function(x)
                if gGlobalSyncTable.gameTimer >= 180 then
                    gPlayerSyncTable[0].myVote = x + 1
                end
            end,
            currNum = 1,
            minNum = 0,
            maxNum = 2
        },
        { "Play Again", function() new_game() end,    true },
        { "New Game",   function() enter_menu(3) end, true },
        { "Options",    function() enter_menu(5) end, true },
    }
}

function on_hud_render()
    -- no hud
    if _G.OmmEnabled then
        _G.OmmApi.omm_force_setting("hud", 3)
    else
        hud_hide()
    end

    if DEBUG_INVIS then return end

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

    -- time until next game
    if gGlobalSyncTable.mapChoice ~= 0 and (gGlobalSyncTable.gameState == 0 or showGameResults) then
        djui_hud_set_resolution(RESOLUTION_DJUI)
        djui_hud_set_font(FONT_MENU)

        local scale = 0.75
        local x = 10
        local y = 0
        djui_hud_set_color(255, 255, 255, 255)
        if gGlobalSyncTable.mapChoice ~= 1 or gGlobalSyncTable.gameTimer < 180 then
            djui_hud_print_text("Next game in " .. (gGlobalSyncTable.gameTimer // 30), x, y, scale)
        else
            djui_hud_print_text("Voting ends in " .. (gGlobalSyncTable.gameTimer // 30 - 5), x, y, scale)
        end
    end

    frameCounter = frameCounter + 1
    if frameCounter > 60 then frameCounter = 0 end

    -- menu render
    if inMenu then
        localGameTimer = gGlobalSyncTable.gameTimer
        return render_menu()
    end

    local shineIndexes = {}
    if gGlobalSyncTable.gameState == 2 then
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
        local x = screenWidth * 0.5 - 300 * scale
        local y = 10
        local playerScore = {}
        for i = 0, (MAX_PLAYERS - 1) do
            local np = gNetworkPlayers[i]
            local sMario = gPlayerSyncTable[i]
            if np.connected and ((not sMario.spectator) or get_player_owned_shine(i) ~= 0) then
                table.insert(playerScore, { i, sMario.shineTimer or 0 })
            end
        end
        table.sort(playerScore, function(a, b)
            return a[2] > b[2]
        end)

        local place = 1
        local prevScore = 0
        for i, score in ipairs(playerScore) do
            djui_hud_set_color(0, 0, 0, 128);
            djui_hud_render_rect(x - 6, y - 3 * scale, 600 * scale + 6, 40 * scale);

            local index = score[1]
            local sMario = gPlayerSyncTable[index]
            local np = gNetworkPlayers[index]
            local playerColor = network_get_player_text_color_string(index)
            if score[2] ~= prevScore then
                place = i
                prevScore = score[2]
            end
            local text = placeString(place)
            djui_hud_print_text_with_color(text, x, y, scale)
            x = x + 80 * scale
            render_player_head(index, x, y, scale * 2, scale * 2)
            x = x + 80 * scale
            text = playerColor .. np.name
            djui_hud_print_text_with_color(text, x, y, scale)
            text = tostring(sMario.shineTimer)
            local width = djui_hud_measure_text(text) * scale
            x = screenWidth * 0.5 + 300 * scale - width - 6
            djui_hud_set_color(255, 255, 64, 255)
            djui_hud_print_text(text, x, y, scale)

            y = y + 45 * scale
            x = screenWidth * 0.5 - 300 * scale
        end

        if tipNum == 0 then
            if gGlobalSyncTable.items ~= 0 then
                tipNum = math.random(1, #tip_general + #tip_item)
            else
                tipNum = math.random(1, #tip_general)
            end
        end
        djui_hud_set_font(FONT_MENU)
        local subText3
        if tipNum > #tip_general then
            subText3 = tip_item[tipNum - #tip_general]
        else
            subText3 = tip_general[tipNum]
        end
        subText3 = string.gsub(subText3, "ITEM_BUTTON", ITEM_BUTTON_STRING)
        local scale3 = 0.5
        y = screenHeight - scale3 * 70
        width = djui_hud_measure_text(subText3) * scale3
        x = (screenWidth - width) * 0.5
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_print_text_with_color(subText3, x, y, scale3, 255)

        return
    else
        tipNum = 0
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
            elseif TEAM_NAMES[sMario.team] then
                text = text .. TEAM_NAMES[sMario.team]
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

    render_radar()
    djui_hud_set_resolution(RESOLUTION_DJUI)

    -- beginning timer
    if gGlobalSyncTable.gameState == 1 or tipDispTimer ~= 0 then
        local usingTimer = gGlobalSyncTable.gameTimer
        if tipDispTimer ~= 0 then
            usingTimer = tipDispTimer
            tipDispTimer = tipDispTimer - 1
        end
        local text = ""
        local subText1 = ""
        local subText2 = ""
        local subText3 = ""
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
                play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, gMarioStates[0].marioObj.header.gfx.cameraToObject)
            end

            text = string.format("%d", ((300 - localGameTimer) // 30) + 1)
            alpha = 17 * secFrame
            tipNum = 0
        else
            if usingTimer < 30 then
                alpha = 8 * usingTimer
            end
            text = "Get the \\#ffff40\\Shine\\#ffffff\\!"
            subText1 = gGlobalSyncTable.winTime .. " seconds to win!"
            if gGlobalSyncTable.variant ~= 0 then
                subText2 = "Variant: " .. tostring(variant_list[gGlobalSyncTable.variant + 2])
            end
            localGameTimer = usingTimer
            if tipNum == 0 then
                if gGlobalSyncTable.teamMode ~= 0 then
                    tipNum = 9 -- always show team tip
                elseif gNetworkPlayers[0].name == "Unreal" then
                    tipNum = 5 -- always show credit tip
                elseif gGlobalSyncTable.items ~= 0 then
                    tipNum = math.random(1, #tip_general + #tip_item)
                else
                    tipNum = math.random(1, #tip_general)
                end
            end
        end

        if tipNum == 0 then
            -- nothing
        elseif gGlobalSyncTable.variant == 0 then
            if tipNum > #tip_general then
                subText3 = tip_item[tipNum - #tip_general]
            else
                subText3 = tip_general[tipNum]
            end
        else
            subText3 = tip_variant[gGlobalSyncTable.variant]
        end

        if alpha > 255 then alpha = 255 end
        local width = djui_hud_measure_text(remove_color(text)) * scale
        local x = (screenWidth - width) * 0.5
        local y = screenHeight * 0.5 - 48 * scale
        djui_hud_set_color(255, 255, 255, alpha)
        djui_hud_print_text_with_color(text, x, y, scale, alpha)

        if subText1 ~= "" then
            local scale1 = 1
            y = y + 48 * scale + 20 * scale1
            width = djui_hud_measure_text(remove_color(subText1)) * scale1
            x = (screenWidth - width) * 0.5
            djui_hud_set_color(255, 255, 255, alpha)
            djui_hud_print_text_with_color(subText1, x, y, scale1, alpha)
        end
        if subText2 ~= "" then
            local scale2 = 0.8
            y = y + 48 * scale + 40 * scale2
            width = djui_hud_measure_text(remove_color(subText2)) * scale2
            x = (screenWidth - width) * 0.5
            djui_hud_set_color(255, 255, 255, alpha)
            djui_hud_print_text_with_color(subText2, x, y, scale2, alpha)
        end
        if subText3 ~= "" then
            subText3 = string.gsub(subText3, "SPECIAL_BUTTON", SPECIAL_BUTTON_STRING)
            subText3 = string.gsub(subText3, "ITEM_BUTTON", ITEM_BUTTON_STRING)
            local scale3 = 0.5
            y = screenHeight - scale3 * 70
            width = djui_hud_measure_text(subText3) * scale3
            x = (screenWidth - width) * 0.5
            djui_hud_set_color(255, 255, 255, alpha)
            djui_hud_print_text_with_color(subText3, x, y, scale3, alpha)
        end
        if gGlobalSyncTable.godMode then
            text = "\\#ffff40\\God Mode"
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
    if (gGlobalSyncTable.variant == 5 or gGlobalSyncTable.variant == 7 or gPlayerSyncTable[0].spectator) and gGlobalSyncTable.gameState == 2 then
        local amount = (120 - (gPlayerSyncTable[0].specialCooldown or 0)) / 120
        local boosting = (gPlayerSyncTable[0].boostTime > 0)
        local x = screenWidth * 0.4
        local y = screenHeight - 40

        djui_hud_set_color(0, 0, 0, 128)
        djui_hud_render_rect(x - 6, y - 2, screenWidth * 0.2 + 12, 34)
        local text = "Ready"
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

    -- shine timer on top (also does sound)
    if #shineIndexes > 0 then
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
        local timeLeft = (gGlobalSyncTable.winTime - shinePlayer.shineTimer)

        -- sound
        if prevTimerNum[0] ~= timeLeft and timeLeft >= 0 then
            if timeLeft > 3 then
                play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, gMarioStates[0].marioObj.header.gfx.cameraToObject)
            else
                play_sound(SOUND_GENERAL_SHORT_STAR, gMarioStates[0].marioObj.header.gfx.cameraToObject)
            end
            prevTimerNum[0] = timeLeft
        end

        local text = string.format("%02d", timeLeft)

        djui_hud_set_color(255, 255, 255, 255);
        djui_hud_print_text(text, x, y, scale)

        djui_hud_render_texture(TEX_SHINE, x - 20 * scale, y, scale, scale)
        for i, shineIndex in ipairs(shineIndexes) do
            render_player_head(shineIndex, x + width + 6 * scale, y, scale, scale)
            x = x + scale * headDistance
        end
    end

    -- item preview
    local item = gPlayerSyncTable[0].item or 0
    if gGlobalSyncTable.gameState == 2 and (gGlobalSyncTable.items ~= 0 or item ~= 0) then
        local scale = 2
        local x = 10
        local y = 10
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_set_font(FONT_HUD)
        djui_hud_render_texture(get_texture_info("item_bg"), x, y, scale, scale)
        djui_hud_render_texture(get_texture_info(string.format("item_preview_%02d", item)), x, y, scale, scale)
        
        local data = item_data[item]
        if data and data.maxUses then
            local uses = data.maxUses - gPlayerSyncTable[0].itemUses
            
            djui_hud_print_text("@"..uses, x+34*scale, y+45*scale, scale)
        end

        if item ~= 0 and (frameCounter % 30 <= 15) then
            local text = "X"
            if altAbilityButtons then
                text = "R+"
            end
            local width = djui_hud_measure_text(text) * scale + 10
            djui_hud_print_text(text, x+64*scale-width, y+10, scale)
        end
    end

    -- minimap
    if gGlobalSyncTable.gameState == 2 then
        local mapWidth = screenWidth // 4
        local x = screenWidth - mapWidth - 20
        local y = screenHeight - mapWidth - 50
        local levelSize = (thisLevel and thisLevel.levelSize) or DEFAULT_MAP_SIZE
        djui_hud_set_color(180, 180, 180, 100)
        djui_hud_render_rect(x, y, mapWidth, mapWidth)

        -- first, determine the level size (expand if a player is beyond the bounds)
        for i = 0, MAX_PLAYERS - 1 do
            local m = gMarioStates[i]
            if not (gPlayerSyncTable[i].spectator) and is_player_active(m) ~= 0 and math.abs(m.pos.x) > levelSize or math.abs(m.pos.z) > levelSize then
                levelSize = math.max(math.abs(m.pos.x), math.abs(m.pos.z))
            end
        end

        local shineList = {}
        djui_hud_set_color(0, 0, 0, 100)
        local mark = obj_get_first_with_behavior_id(id_bhvShineMarker)
        while mark do
            local renderX = clampf(mark.oPosX / (levelSize * 2) + 0.5, 0, 1) * mapWidth + x - 12
            local renderY = clampf(mark.oPosZ / (levelSize * 2) + 0.5, 0, 1) * mapWidth + y - 12
            djui_hud_render_texture(gTextures.star, math.floor(renderX), math.floor(renderY), 1.5, 1.5)
            table.insert(shineList, mark.parentObj)
            mark = obj_get_next_with_same_behavior_id(mark)
        end

        djui_hud_set_color(255, 255, 255, 255)
        for i,shine in ipairs(shineList) do
            if get_shine_owner(shine.oBehParams) == -1 then
                local renderX = clampf(shine.oPosX / (levelSize * 2) + 0.5, 0, 1) * mapWidth + x - 20
                local renderY = clampf(shine.oPosZ / (levelSize * 2) + 0.5, 0, 1) * mapWidth + y - 20
                djui_hud_render_texture(TEX_SHINE, math.floor(renderX), math.floor(renderY), 2.5, 2.5)
            end
        end

        for i = MAX_PLAYERS - 1, 0, -1 do -- go backwards so that our own player renders on top
            local m = gMarioStates[i]
            if i == 0 or (not (gPlayerSyncTable[i].spectator) and is_player_active(m) ~= 0) then
                local scale = (i == 0 and 2.5) or 2
                local renderX = m.pos.x / (levelSize * 2) + 0.5
                local renderY = m.pos.z / (levelSize * 2) + 0.5
                renderX = clampf(renderX, 0, 1) * mapWidth + x - 8 * scale
                renderY = clampf(renderY, 0, 1) * mapWidth + y - 8 * scale

                render_player_head(i, math.floor(renderX), math.floor(renderY), scale, scale)
                local playercolor = network_get_player_text_color_string(i)
                local r, g, b = convert_color(playercolor)
                djui_hud_set_color(r, g, b, 155)
                djui_hud_set_rotation(m.faceAngle.y, 0.5, 0.5)
                djui_hud_render_texture(TEX_MAP_ARROW, renderX - 8 * scale, renderY - 8 * scale, scale, scale)
                djui_hud_set_rotation(0, 0, 0)

                if get_player_owned_shine(i) ~= 0 then
                    djui_hud_set_color(255, 255, 255, 255)
                    djui_hud_render_texture(TEX_SHINE_SMALL, renderX, renderY - 15 * scale, scale, scale)
                end
            end
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)

function enter_menu(id, option, back)
    if not back then
        table.insert(menu_history, { menuID, menuOption })
    end

    -- redirect to/from vote menu
    if id == 2 and gGlobalSyncTable.mapChoice == 1 then
        id = 6
        if option then
            option = option + 1
        end
    elseif id == 6 and gGlobalSyncTable.mapChoice ~= 1 then
        id = 2
        if option then
            option = option - 1
        end
    end

    menuID = id or 1
    menuOption = option or 1

    if menuID == 3 then
        if #levelData == 0 then
            enter_menu(4, 1, true)
            return
        end

        if type(gGlobalSyncTable.gameLevel) == "number" and gGlobalSyncTable.gameLevel > 0 and gGlobalSyncTable.gameLevel <= #levelData then
            set_menu_option(3, 1, gGlobalSyncTable.gameLevel)
        elseif isRomHack then
            set_menu_option(3, 1, 1) -- whatever the first entry is
        else
            set_menu_option(3, 1, 2) -- wf
        end
    end
end

-- show the menu
function render_menu()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_NORMAL)

    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    djui_hud_set_color(255, 255, 255, 128)
    djui_hud_render_rect(0, 0, screenWidth + 10, screenHeight + 10)

    local menu = menu_data[menuID]
    if not menu then return end

    local scale = 2
    local x = 0
    local y = (screenHeight * 0.5) - (20 * scale) - (#menu * 20 * scale)
    if (#menu % 2 == 0) then
        y = y + 20 * scale
    end

    for i, button in ipairs(menu) do
        if menuID == 3 and i == 1 then -- special case (paintings)
            x = screenWidth * 0.5 - 180 * scale
            y = y - 20 * scale
            for i = button.currNum - 1, button.currNum + 1 do
                if #levelData == 1 then
                    if i == 0 then
                        i = 1
                    else
                        break
                    end
                    x = x + 180 * scale
                end

                if i < 1 then
                    i = #levelData
                elseif i > #levelData then
                    i = 1
                end

                local alpha = (i == button.currNum and 255) or 100
                djui_hud_set_color(255, 255, 255, alpha)
                local tex = get_texture_info("painting_default")
                local doText = true
                if levelData[i].tex then
                    tex = get_texture_info(levelData[i].tex) or tex
                    doText = false
                end
                local width = tex.width * scale * 2
                djui_hud_render_texture(tex, x - width * 0.5, y, scale * 2, scale * 2)
                if doText then
                    local text = levelData[i].name
                    djui_hud_set_font(FONT_TINY)
                    local tWidth = djui_hud_measure_text(text) * scale
                    djui_hud_print_text(text, x - tWidth, y + scale * 6, scale * 2)
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
            djui_hud_set_color(0, 0, 0, 255)
            djui_hud_print_text(text, x, y, scale)
            if i == menuOption then
                djui_hud_set_color(255, 255, 64, sins(frameCounter * 500) * 50 + 50)
                djui_hud_render_rect(x - 6, y - 6, width + 12, 36 * scale + 12)
            end

            scale = 2
            y = screenHeight - 120 * scale
        elseif menuID == 6 and i == 1 then -- special case (voting screen paintings)
            x = screenWidth * 0.5 - 180 * scale
            y = y - 20 * scale
            local currMap = 1
            local currMapText = ""
            local voteEnd = false

            if gGlobalSyncTable.gameTimer <= 180 then
                voteEnd = true
                -- count the votes
                if doVoteCalc then
                    votesNumber = { 0, 0, 0 }
                    for i = 0, MAX_PLAYERS - 1 do
                        local sMario = gPlayerSyncTable[i]
                        if sMario.myVote and sMario.myVote ~= 0 and votesNumber[sMario.myVote] then
                            votesNumber[sMario.myVote] = votesNumber[sMario.myVote] + 1
                        end
                    end
                    doVoteCalc = false
                end
                currMap = gGlobalSyncTable.wonMap or 1
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

                djui_hud_set_color(255, 255, 255, alpha)
                local tex = get_texture_info("painting_default")
                local doText = true
                if levelData[map] and levelData[map].tex then
                    tex = get_texture_info(levelData[map].tex) or tex
                    doText = false
                end
                local width = tex.width * scale * 2
                djui_hud_render_texture(tex, x - width * 0.5, y, scale * 2, scale * 2)
                if doText then
                    local text = ""
                    local area = 1
                    if levelData[map] then
                        text = levelData[map].name
                        if currMap == map then
                            currMapText = text
                        end
                    else
                        local args = split(map, " ")
                        local level = tonumber(args[1]) or LEVEL_WF
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
                    if currMap == map then
                        currMapText = text
                        if area ~= 1 then
                            currMapText = currMapText .. " (A" .. area .. ")"
                        end
                    end
                    if text:len() > 10 then
                        text = convert_to_abbreviation(text)
                        if area ~= 1 then
                            text = text .. area
                        end
                    end
                    djui_hud_set_font(FONT_TINY)
                    local tWidth = djui_hud_measure_text(text) * scale
                    djui_hud_print_text(text, x - tWidth, y + scale * 6, scale * 2)
                end
                if voteEnd then
                    local text = tostring(votesNumber[i + 1])
                    djui_hud_set_font(FONT_TINY)
                    local tWidth = djui_hud_measure_text(text) * scale
                    if currMap == map then
                        djui_hud_set_color(100, 255, 100, 255)
                    else
                        djui_hud_set_color(255, 255, 255, 255)
                    end
                    djui_hud_print_text(text, x - tWidth, y - scale * 6, scale * 2)
                elseif gPlayerSyncTable[0].myVote and i == (gPlayerSyncTable[0].myVote - 1) then
                    djui_hud_set_color(80, 255, 80, 100)
                    djui_hud_render_rect(x - width * 0.5, y, width, width)
                end
                x = x + 180 * scale
            end
            djui_hud_set_font(FONT_NORMAL)
            scale = 2
            local text = ""
            if currMapText == "" and levelData[currMap] then
                text = levelData[currMap].name or
                    get_level_name(levelData[currMap].course, levelData[currMap].level, levelData[currMap].area)
            else
                text = currMapText
            end
            local width = djui_hud_measure_text(text) * scale
            x = (screenWidth - width) * 0.5
            y = 10 * scale
            djui_hud_set_color(0, 0, 0, 255)
            djui_hud_print_text(text, x, y, scale)
            if i == menuOption then
                djui_hud_set_color(255, 255, 64, sins(frameCounter * 500) * 50 + 50)
                djui_hud_render_rect(x - 6, y - 6, width + 12, 36 * scale + 12)
            end

            scale = 2
            y = screenHeight - 120 * scale
        else
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

                if (isRomHack and level_is_vanilla_level(level)) then
                    text = "VANILLA COURSE"
                end
            end
            if button.currNum then
                if button.nameRef and button.nameRef[button.currNum - button.minNum + 1] then
                    local optionText = button.nameRef[button.currNum - button.minNum + 1]
                    text = text .. "  < " .. remove_color(optionText) .. " >"
                else
                    text = text .. "  < " .. button.currNum .. " >"
                end
            end
            local width = djui_hud_measure_text(text) * scale

            x = (screenWidth - width) * 0.5

            local alpha = 255
            if button[3] and not (network_is_server() or network_is_moderator()) then
                alpha = 100
            elseif button[3] and i == 2 and menuID == 6 and gGlobalSyncTable.gameState == 0 then
                alpha = 100
            end
            djui_hud_set_color(0, 0, 0, alpha)
            djui_hud_print_text(text, x, y, scale)
            if i == menuOption then
                djui_hud_set_color(255, 255, 64, sins(frameCounter * 500) * 50 + 50)
                djui_hud_render_rect(x - 6, y - 6, width + 12, 36 * scale + 12)
            end
            y = y + 40 * scale
        end
    end
end

r_press = false
-- menu controls + special action control
---@param m MarioState
function menu_controls(m)
    if m.playerIndex ~= 0 then return end

    if showGameResults then
        local leave_game_results = (network_is_server() or network_is_moderator() or gGlobalSyncTable.mapChoice == 1) and
            (m.controller.buttonPressed & A_BUTTON) ~= 0 and not inMenu
        if voteScreenTimer > 0 and not leave_game_results then
            voteScreenTimer = voteScreenTimer - 1
            if voteScreenTimer == 0 and gGlobalSyncTable.mapChoice == 1 then
                leave_game_results = true
            end
        end
        if leave_game_results then
            voteScreenTimer = 0
            enter_menu(2)
            menu_history = {}
            inMenu = true
            return
        end
    elseif (m.controller.buttonPressed & START_BUTTON) ~= 0 then
        if not showGameResults then
            if gGlobalSyncTable.mapChoice == 1 and gGlobalSyncTable.gameState == 0 then
                enter_menu(6)
            elseif gGlobalSyncTable.gameState ~= 0 or not (network_is_server() or network_is_moderator()) then
                enter_menu(1)
            else
                enter_menu(3)
            end
            menu_history = {}
            inMenu = not inMenu
            play_sound(SOUND_MENU_PAUSE, m.marioObj.header.gfx.cameraToObject)
        end
        m.controller.buttonPressed = m.controller.buttonPressed & ~START_BUTTON
        return
    end

    if DEBUG_MODE and (m.controller.buttonPressed & U_JPAD) ~= 0 then
        set_mario_action(m, ACT_DEBUG_FREE_MOVE, 0)
    end

    -- if holding R, the special button acts like it should
    if not (inMenu or showGameResults) then
        if m.controller.buttonPressed & R_TRIG ~= 0 then
            m.controller.buttonPressed = m.controller.buttonPressed & ~R_TRIG
            r_press = true
        elseif m.controller.buttonDown & R_TRIG == 0 and r_press then
            m.controller.buttonPressed = m.controller.buttonPressed | R_TRIG
            r_press = false
        elseif m.controller.buttonDown & SPECIAL_BUTTON ~= 0 and m.controller.buttonDown & R_TRIG == 0 then
            specialPressed = not specialDown
            specialDown = true
            m.controller.buttonPressed = m.controller.buttonPressed & ~SPECIAL_BUTTON
            m.controller.buttonDown = m.controller.buttonDown & ~SPECIAL_BUTTON
        else
            specialPressed = false
            specialDown = false
            if m.controller.buttonDown & SPECIAL_BUTTON ~= 0 then
                r_press = false
            end
        end
        return
    end
    if m.freeze < 2 then m.freeze = 2 end
    if (m.controller.buttonPressed & R_TRIG) ~= 0 then
        djui_open_pause_menu()
        m.controller.buttonPressed = m.controller.buttonPressed & ~R_TRIG
    end
    if not inMenu then return end

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
        if button[3] and not (network_is_server() or network_is_moderator()) then
            play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
        elseif button[3] and menuOption == 2 and menuID == 6 and gGlobalSyncTable.gameState == 0 then
            play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
        else
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
            button[2](button.currNum)
        end
    elseif (m.controller.buttonPressed & B_BUTTON) ~= 0 then
        if #menu_history > 0 then
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
            enter_menu(menu_history[#menu_history][1], menu_history[#menu_history][2], true)
            table.remove(menu_history, #menu_history)
        elseif not showGameResults then
            play_sound(SOUND_MENU_PAUSE, m.marioObj.header.gfx.cameraToObject)
            inMenu = false
        else
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
            inMenu = false
        end
    end

    if button.currNum and stickCooldownX == 0 then
        if stickX > 64 then
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
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
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
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
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            menuOption = menuOption - 1
            if menuOption < 1 then
                menuOption = #menu
            end
            stickCooldownY = 5
        elseif stickY < -64 then
            play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
            menuOption = menuOption + 1
            if #menu < menuOption then
                menuOption = 1
            end
            stickCooldownY = 5
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

function new_game_set_settings(msg)
    if menuTeam ~= -1 then
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

    if menuVariant == 1 and (gGlobalSyncTable.teamMode == 2 or get_participant_count() < 3) then
        djui_popup_create("Not enough teams or players for Double Shine!", 2)
        gGlobalSyncTable.variant = 0
    elseif menuVariant ~= -1 then
        gGlobalSyncTable.variant = menuVariant
    else
        local bottom = 1
        if (gGlobalSyncTable.teamMode == 2 or get_participant_count() < 3) then
            bottom = 2
        end
        gGlobalSyncTable.variant = math.random(bottom, #variant_list - 2)
    end
    new_game(msg)
end

-- this is based off of MarioHunt, which is based off of Arena
TEX_SHINE = get_texture_info("shine_hud")
TEX_SHINE_SMALL = get_texture_info("shine_hud_small")
TEX_SHINE_CIRCLE = get_texture_info("shine_hud_circle")
TEX_MAP_ARROW = get_texture_info("map-arrow")
shine_radar = {}
shine_radar[1] = { prevX = 0, prevY = 0, prevScale = 0 }
shine_radar[2] = { prevX = 0, prevY = 0, prevScale = 0 }

function render_radar()
    local shine = obj_get_first_with_behavior_id(id_bhvShine)
    local i = 0
    while shine do
        i = i + 1
        if get_player_owned_shine(0) ~= shine.oBehParams then
            local hudIcon = shine_radar[i]
            if hudIcon == nil then
                shine_radar[i] = { prevX = 0, prevY = 0, prevScale = 0 }
                hudIcon = shine_radar[i]
            end

            djui_hud_set_resolution(RESOLUTION_N64)
            local pos = {}
            pos = { x = shine.oPosX, y = shine.oPosY, z = shine.oPosZ } -- I'm just guessing
            local out = { x = 0, y = 0, z = 0 }

            djui_hud_world_pos_to_screen_pos(pos, out)

            local dX = out.x
            local dY = out.y
            local screenWidth = djui_hud_get_screen_width()
            local screenHeight = djui_hud_get_screen_height()

            if out.z > -260 then
                hudIcon.prevX = dX
                hudIcon.prevY = dY
                return
            end

            local dist = vec3f_dist(pos, gMarioStates[0].pos)
            local alpha = clamp(dist, 0, 900) - 800
            if alpha <= 0 then
                hudIcon.prevX = dX
                hudIcon.prevY = dY
                return
            end

            local r, g, b = 0, 0, 0
            r, g, b = 255, 255, 255 -- texture is already colored

            local scale = clamp(dist, 0, 2400) / 2000
            local tex = TEX_SHINE
            local circle = false
            if get_shine_owner(shine) ~= -1 then
                tex = TEX_SHINE_SMALL
                circle = true
            end
            local width = tex.width * scale
            local dX = dX - width * 0.5
            local dY = dY - width * 0.5
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
            end

            hudIcon.prevX = dX
            hudIcon.prevY = dY
            hudIcon.prevScale = scale
        end
        shine = obj_get_next_with_same_behavior_id(shine)
    end
end

-- prints text on the screen... with color!
function djui_hud_print_text_with_color(text, x, y, scale, alpha)
    djui_hud_set_color(255, 255, 255, alpha or 255)
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
    local rstring = text:sub(1, 2) or "ff"
    local gstring = text:sub(3, 4) or "ff"
    local bstring = text:sub(5, 6) or "ff"
    local astring = text:sub(7, 8) or "ff"
    local r = tonumber("0x" .. rstring) or 255
    local g = tonumber("0x" .. gstring) or 255
    local b = tonumber("0x" .. bstring) or 255
    local a = tonumber("0x" .. astring) or 255
    return r, g, b, a
end

-- get place string (1st, 2nd, etc.)
function placeString(num)
    local twoDigit = num % 100
    local oneDigit = num % 10
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

-- renders player head... with color!
local PART_ORDER = {
    SKIN,
    HAIR,
    CAP,
}
-- cap only
local TEAM_COLORS = {
    { r = 0x68, g = 0x0a, b = 0x17 }, -- burgundy
    { r = 0x00, g = 0x2f, b = 0xc8 }, -- cobalt
    { r = 0x4c, g = 0x5f, b = 0x20 }, -- clover
    { r = 0xe7, g = 0xe7, b = 0x21 }, -- busy bee
    { r = 0xff, g = 0x8a, b = 0x00 }, -- orange
    { r = 0x5a, g = 0x94, b = 0xff }, -- azure
    { r = 0xff, g = 0x96, b = 0xc8 }, -- nice pink
    { r = 0x61, g = 0x26, b = 0xb0 }, -- waluigi
}

HEAD_HUD = get_texture_info("hud_head_recolor")
WING_HUD = get_texture_info("hud_wing")
CS_ACTIVE = _G.charSelectExists
if CS_ACTIVE then
    _G.charSelect.hook_allow_menu_open(function()
        return not (inMenu or showGameResults)
    end)
end

local defaultIcons = {
    [gTextures.mario_head] = true,
    [gTextures.luigi_head] = true,
    [gTextures.toad_head] = true,
    [gTextures.waluigi_head] = true,
    [gTextures.wario_head] = true,
}

-- the actual head render function.
--- @param index integer
--- @param x integer
--- @param y integer
--- @param scaleX number
--- @param scaleY number
function render_player_head(index, x, y, scaleX, scaleY)
    local m = gMarioStates[index]
    local sMario = gPlayerSyncTable[index]
    local np = gNetworkPlayers[index]

    if CS_ACTIVE then
        djui_hud_set_color(255, 255, 255, 255)
        local TEX_CS_ICON = _G.charSelect.character_get_life_icon(index)
        if TEX_CS_ICON and not defaultIcons[TEX_CS_ICON] then
            djui_hud_render_texture(TEX_CS_ICON, x, y, scaleX / (TEX_CS_ICON.width * 0.0625),
                scaleY / (TEX_CS_ICON.width * 0.0625))
            return
        elseif TEX_CS_ICON == nil then
            djui_hud_set_font(FONT_HUD)
            djui_hud_print_text("?", x, y, scaleX)
            return
        end
    end

    local alpha = 255
    if (m.marioBodyState.modelState & MODEL_STATE_NOISE_ALPHA) ~= 0 then
        alpha = 100 -- vanish effect
    end
    local isMetal = false

    local tileY = m.character.type
    for i = 1, #PART_ORDER do
        local color = { r = 255, g = 255, b = 255 }
        if sMario.team and TEAM_COLORS[sMario.team] then
            if (m.marioBodyState.modelState & MODEL_STATE_METAL) ~= 0 then -- metal
                color = TEAM_COLORS[sMario.team]
                djui_hud_set_color(color.r, color.g, color.b, alpha)
                djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, 5 * 16, tileY * 16, 16, 16)
                isMetal = true

                djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, 5 * 16, tileY * 16, 16, 16)
                break
            end

            if i == 1 then         -- same skin color
                color = { r = 0xfe, g = 0xc1, b = 0x79 }
            elseif i == 2 then     -- same hair color
                if tileY == 2 then -- toad's mushroom is always white
                    color = { r = 255, g = 255, b = 255 }
                else
                    color = { r = 0x73, g = 6, b = 0 }
                end
            else
                color = TEAM_COLORS[sMario.team]
            end
        else
            if (m.marioBodyState.modelState & MODEL_STATE_METAL) ~= 0 then -- metal
                color = network_player_palette_to_color(np, METAL, color)
                djui_hud_set_color(color.r, color.g, color.b, alpha)
                djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, 5 * 16, tileY * 16, 16, 16)
                isMetal = true

                break
            end

            local part = PART_ORDER[i]
            if tileY == 2 and part == HAIR then -- toad doesn't use hair
                part = GLOVES
            end
            network_player_palette_to_color(np, part, color)
        end

        djui_hud_set_color(color.r, color.g, color.b, alpha)
        djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (i - 1) * 16, tileY * 16, 16, 16)
    end

    if not isMetal then
        djui_hud_set_color(255, 255, 255, alpha)
        --djui_hud_render_texture(HEAD_HUD, x, y, scaleX, scaleY)
        djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (#PART_ORDER) * 16, tileY * 16, 16, 16)

        djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (#PART_ORDER + 1) * 16, tileY * 16, 16, 16) -- hat emblem
        if m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
            djui_hud_render_texture(WING_HUD, x, y, scaleX, scaleY)                                              -- wing
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

-- mcdonalds support
function add_mcdonalds()
    if addedMcDonalds then return end
    addedMcDonalds = true

    table.insert(levelData, {
        level = 100,
        course = 0,
        name = "McDonald's",
        area = 1,
        tex = "painting_md",

        startLocations = {
            [0] = { 10, 1154, 3910 },
        },
        shineStart = { 310, 985, 230 },

        boxLocations = {
            { -1114, 300, -1150, 0x4000, 16384 },
            { -1114, 300, -445,  0x4000, 16384 },
            { 627,   300, -445,  0x4000, 16384 },
            { -276,  300, -1430, 0x4000, 0 },
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
    if load then
        menuTeam = load_setting("teamMode") or 0
        menuVariant = load_setting("variant") or 0
        if menuVariant > (#variant_list - 2) then menuVariant = 0 end
        gGlobalSyncTable.mapChoice = load_setting("mapChoice") or 0
        gGlobalSyncTable.items = load_setting("items") or 1
        gGlobalSyncTable.godMode = load_setting("godMode", true) or false
    else
        if menuTeam ~= -1 then
            menuTeam = gGlobalSyncTable.teamMode
        end

        if menuVariant ~= -1 then
            menuVariant = gGlobalSyncTable.variant
        end
    end
    set_menu_option(5, 1, gGlobalSyncTable.mapChoice)
    set_menu_option(5, 2, menuVariant)
    set_menu_option(5, 3, menuTeam)
    set_menu_option(5, 4, gGlobalSyncTable.items)
    set_menu_option(5, 5, (gGlobalSyncTable.godMode and 1) or 0)
end

-- converts text to sm64 style abbreviation (ex: Bowser In The Sky becomes BitS)
function convert_to_abbreviation(text)
    local ab = ""
    local start, send = string.find(text, "%a+")
    while start ~= nil do
        local word = text:sub(start, send):upper()
        if word ~= "OF" and word ~= "THE" and word ~= "IN" and word ~= "S" and word ~= "OVER" then
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
    menu_data[5][2].maxNum = (#variant_list - 2)
    return (#variant_list - 2)
end
function set_alt_ability_strings(set)
    if set then
        SPECIAL_BUTTON_STRING = "L"
        ITEM_BUTTON_STRING = "the D-PAD while holding R"
    else
        SPECIAL_BUTTON_STRING = "Y"
        ITEM_BUTTON_STRING = "X"
    end
end