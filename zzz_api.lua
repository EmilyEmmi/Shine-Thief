-- small api, useful for mod support with custom projectiles and such

_G.ShineThief = {
    add_painting = function(tex) -- run this immediately after adding a level with _G.Arena.add_level (tex should be a texture file from get_texture_info, NOT a string)
        local data = levelData[#levelData]
        data.tex = tex
    end,

    get_team = function(index)
        return gPlayerSyncTable[index].team or 0
    end,

    -- includes players that have lost and are no longer bombs as well as willing spectators
    get_spectator = function(index)
        return is_spectator(index)
    end,

    -- includes players that have lost (bombs or not) as well as willing spectators
    get_dead = function(index)
        return is_dead(index)
    end,

    get_held_shine = function(index) -- returns 0 if no shine, 1 for the main shine, and 2 for the other shine in Double Shine
        return get_player_owned_shine(index)
    end,

    -- sets attacker from an attack for the local player, useful for custom projectiles and such
    -- index should be the local index for the attacker
    -- set "steal" to make this a steal attack
    set_shine_attacker = function(index, steal)
        if steal then
            cappyStealer = index
        else
            modAttacker = index
        end
    end,

    -- takes an action value and marks it as being able to steal the shine (must be an attacking action to work)
    add_steal_attack = add_steal_attack,

    get_item = function(index) -- returns held item; see item.lua for the values (0 is neutral)
        return gPlayerSyncTable[index].item or 0
    end,

    get_item_uses = function(index) -- only for boomerang and fire flower
        return gPlayerSyncTable[index].itemUses or 0
    end,

    star_active = function(index) -- if star is active (bool, the actual time is m.capTimer)
        return gPlayerSyncTable[index].star
    end,

    bullet_active = function(index) -- if bullet bill is active (non-zero if active)
        return gPlayerSyncTable[index].bulletTimer or 0
    end,

    mushroom_active = function(index) -- if mushroom is active (non-zero if active)
        return gPlayerSyncTable[index].mushroomTime or 0
    end,

    boost_active = function(index) -- if boost is active (non-zero if active)
        return gPlayerSyncTable[index].boostTime or 0
    end,

    get_variant = function() -- see zz_hud.lua for values
        return gGlobalSyncTable.variant or 0
    end,

    -- adds a variant, returning the created variant's value. You can use this in combination with get_variant to add your own variants!
    -- it takes the name as a string for the first argument, and a tip as a string for the second argument.
    -- be sure to give the name a color string (like with \\#000000\\, for example)
    add_variant = add_variant,

    is_menu_open = function() -- self explanatory
        return inMenu or showGameResults
    end,

    set_alt_buttons = function(set) -- changes the buttons for abilities to what they are when OMM is enabled if SET is true
        altAbilityButtons = set
        SPECIAL_BUTTON = (altAbilityButtons and L_TRIG) or Y_BUTTON
        ITEM_BUTTON = (altAbilityButtons and (U_JPAD | D_JPAD | L_JPAD | R_JPAD)) or X_BUTTON
        set_alt_ability_strings(set)
    end,

    get_gamemode = function() -- returns gamemode (list in zz_hud)
        return gGlobalSyncTable.gameMode
    end,

    is_eliminated = function(index) -- 0 if not eliminated (other number is based on when elimination occured)
        return gPlayerSyncTable[index].eliminated or 0
    end,

    is_bomb = function(index) -- bool
        return gPlayerSyncTable[index].isBomb or false
    end,

    -- adds a new item, see item.lua for information; returns item id
    -- IMPORTANT: add a field called "tex" set to the texture you want to appear in the item preview
    add_item = function(data)
        table.insert(item_data, data)
        return #item_data
    end,

    -- returns if two players are on different teams (also true if either is neutral)
    on_different_teams = function(index, index2)
        local team = gPlayerSyncTable[index].team
        local team2 = gPlayerSyncTable[index2].team
        return team == 0 or team2 == 0 or team ~= team2
    end,

    -- actions
    ACT_CAPE_JUMP = ACT_CAPE_JUMP,
    ACT_CAPE_JUMP_SHELL = ACT_CAPE_JUMP_SHELL,
    ACT_GAME_WIN = ACT_GAME_WIN,
    ACT_GAME_LOSE = ACT_GAME_LOSE,
    ACT_ITEM_THROW_GROUND = ACT_ITEM_THROW_GROUND,
    ACT_ITEM_THROW_AIR = ACT_ITEM_THROW_AIR,
}