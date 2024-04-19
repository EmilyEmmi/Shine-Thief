-- This is used for development purposes.

DEBUG_MODE = false
local start_spots = {}
local obj_spots = {}
local item_spots = {}
local shine_spot = {0, 0, 0}
function add_spot(msg)
    if msg == "reset" then
        start_spots = {}
        djui_chat_message_create("reset start spots")

        if DEBUG_MODE then
            thisLevel.startLocations = {}
        end

        return true
    elseif msg == "back" and #start_spots ~= 0 then
        table.remove(start_spots, #start_spots)
        djui_chat_message_create("removed last spot")

        if DEBUG_MODE then
            thisLevel.startLocations = {}
            for i,v in ipairs(start_spots) do
                thisLevel.startLocations[i-1] = v
            end
        end

        return true
    end
    local m = gMarioStates[0]
    local x = math.floor(m.pos.x)
    local y = math.floor(m.pos.y)
    local z = math.floor(m.pos.z)
    if msg ~= "exact" then
        y = math.floor(m.floorHeight) + 1000
    end
    table.insert(start_spots, {x, y, z})
    if DEBUG_MODE then
        thisLevel.startLocations = {}
        for i,v in ipairs(start_spots) do
            thisLevel.startLocations[i-1] = v
        end
    end

    djui_chat_message_create("added (there are "..tostring(#start_spots).." spots)")
    return true
end

function add_shine_start(msg)
    local m = gMarioStates[0]
    local x = math.floor(m.pos.x)
    local y = math.floor(m.pos.y)
    local z = math.floor(m.pos.z)
    if msg ~= "exact" then
        y = math.floor(m.floorHeight) + 160
    end
    shine_spot = {x, y, z}
    djui_chat_message_create("set shine spot")

    if DEBUG_MODE then
        local shine = obj_get_first_with_behavior_id(id_bhvShine)
        if shine then
            shine.oPosX = x
            shine.oPosY = y
            shine.oPosZ = z
        else
            spawn_sync_object(
                id_bhvShine,
                E_MODEL_SHINE,
                x,y,z,
                function(o)
                    o.oBehParams = 0x1
                end
            )
        end
    end
    
    return true
end

local specialObjData = {
    ["plat"] = {id_bhvStaticCheckeredPlatform, "bhvStaticCheckeredPlatform", E_MODEL_CHECKERBOARD_PLATFORM, "E_MODEL_CHECKERBOARD_PLATFORM"},
    ["pipe"] = {id_bhvSTPipe, "bhvSTPipe", E_MODEL_BITS_WARP_PIPE, "E_MODEL_BITS_WARP_PIPE"},
    ["spring"] = {id_bhvArenaSpring, "bhvArenaSpring", E_MODEL_SPRING_BOTTOM, "E_MODEL_SPRING_BOTTOM"},
}

function add_obj_spot(msg)
    if not msg or msg == "" then return false end
    local args = split(msg," ")

    local objName = args[2]
    local model = E_MODEL_ERROR_MODEL
    local modelName = "E_MODEL_ERROR_MODEL"
    local id = 0
    local plat = (objName == "plat")
    if not objName then
        djui_chat_message_create("No such object exists")
        return true
    end
    if specialObjData[objName] then
        id = specialObjData[objName][1]
        model = specialObjData[objName][3]
        modelName = specialObjData[objName][4]
        objName = specialObjData[objName][2]
    else
        id = get_id_from_behavior_name(objName)
        if id == 539 or not id then
            djui_chat_message_create("No such object exists")
            return true
        end
    end
    if not obj_spots then obj_spots = {} end

    if args[1] == "reset" then
        obj_spots = {}
        djui_chat_message_create("removed all "..objName)

        if DEBUG_MODE then
            local o = obj_get_first_with_behavior_id(id)
            while o do
                obj_mark_for_deletion(o)
                o = obj_get_next_with_same_behavior_id(o)
            end
        end

        return true
    elseif args[1] == "remove" and #obj_spots ~= 0 then
        table.remove(obj_spots, #obj_spots)
        djui_chat_message_create("removed last "..objName)

        if DEBUG_MODE then
            local o = obj_get_first_with_behavior_id(id)
            local prevObj = o
            while o do
                prevObj = o
                o = obj_get_next_with_same_behavior_id(o)
            end
            obj_mark_for_deletion(prevObj)
        end

        return true
    end

    local m = gMarioStates[0]
    local x = math.floor(m.pos.x)
    local y = math.floor(m.pos.y)
    local z = math.floor(m.pos.z)
    local params1 = tonumber(args[4]) or 0
    local params2 = tonumber(args[5]) or 0
    local pitch = tonumber(args[6]) or 0
    local yaw = tonumber(args[7]) or m.faceAngle.y
    if id == id_bhvArenaSpring then -- make placing springs less annoying
        yaw = limit_angle(yaw + 0x8000)
    else
        yaw = limit_angle(yaw)
    end
    pitch = limit_angle(pitch)

    if args[3] == "floor" then
        y = math.floor(m.floorHeight)
    elseif args[3] == "shine" and shine_spot[2] then
        x = shine_spot[1]
        y = shine_spot[2] - 160
        z = shine_spot[3]
    elseif args[3] == "slope" then
        y = math.floor(m.floorHeight)
        pitch = math.floor((m.floor.normal.y - 1) * 0x8000)
    elseif tonumber(args[3]) then
        y = y + tonumber(args[3])
    end

    if plat and pitch == 0 then
        y = y - 26
    end

    table.insert(obj_spots, {"id_"..(objName:gsub("id_","")), modelName, x, y, z, params1, params2, pitch, yaw})
    djui_chat_message_create("added "..objName.." (there are "..tostring(#obj_spots).." objects)")

    if DEBUG_MODE then
        spawn_sync_object(
            id,
            model,
            x,y,z,
            function(o)
                o.oBehParams = params1
                o.oBehParams2ndByte = params2
                o.oFaceAnglePitch = pitch
                o.oFaceAngleYaw = yaw
            end
        )
    end

    return true
end

function add_item_spot(msg)
    if not msg or msg == "" then return false end
    local args = split(msg," ")

    if not item_spots then item_spots = {} end

    if args[1] == "reset" then
        item_spots = {}
        djui_chat_message_create("removed all item boxes")

        if DEBUG_MODE then
            local o = obj_get_first_with_behavior_id(id_bhvItemBox)
            while o do
                obj_mark_for_deletion(o)
                o = obj_get_next_with_same_behavior_id(o)
            end
        end

        return true
    elseif args[1] == "remove" and #item_spots ~= 0 then
        table.remove(item_spots, #item_spots)
        djui_chat_message_create("removed last item box")

        if DEBUG_MODE then
            local o = obj_get_first_with_behavior_id(id_bhvItemBox)
            local prevObj = o
            while o do
                prevObj = o
                o = obj_get_next_with_same_behavior_id(o)
            end
            obj_mark_for_deletion(prevObj)
        end

        return true
    end

    local m = gMarioStates[0]
    local x = math.floor(m.pos.x)
    local y = math.floor(m.pos.y)
    local z = math.floor(m.pos.z)

    if args[2] == "floor" then
        y = math.floor(m.floorHeight)
    elseif args[2] == "shine" and shine_spot[2] then
        x = shine_spot[1]
        y = shine_spot[2] - 186
        z = shine_spot[3]
    elseif tonumber(args[2]) then
        y = y + tonumber(args[2])
    end
    if args[2] ~= "exact" then
        y = y + 160
    end

    table.insert(item_spots, {x, y, z})
    djui_chat_message_create("added an item box (there are "..tostring(#item_spots).." item boxes)")

    if DEBUG_MODE then
        spawn_sync_object(
            id_bhvItemBox,
            E_MODEL_ITEM_BOX,
            x,y,z,
            nil
        )
    end

    return true
end

function print_data(msg)
    local np = gNetworkPlayers[0]
    local text = "{\n"
    text = text .. "\tlevel = " .. tostring(np.currLevelNum) .. ",\n"
    text = text .. "\tcourse = " .. tostring(np.currCourseNum) .. ",\n"
    text = text .. "\tarea = " .. tostring(np.currAreaIndex) .. ",\n\n"
    text = text .. "\tstartLocations = {\n"
    for i,v in ipairs(start_spots) do
        text = text .. string.format("\t\t[%d] = {%d, %d, %d},\n",i-1,v[1] or 0, v[2] or 0, v[3] or 0)
    end
    text = text .. string.format("\t},\n\tshineStart = {%d, %d, %d},",shine_spot[1],shine_spot[2],shine_spot[3])
    if obj_spots and #obj_spots ~= 0 then
        text = text .. "\n\n\tobjLocations = {\n"
        for i,v in ipairs(obj_spots) do
            local yaw = (v[9] and string.format("0x%x",math.abs(v[9])) or 0)
            if v[9] and v[9] < 0 then
                yaw = "-"..yaw
            end
            text = text .. string.format("\t\t{%s, %s, %d, %d, %d, %d, %d, 0x%x, %s},\n",v[1] or 0, v[2] or 0, v[3] or 0, v[4] or 0, v[5] or 0, v[6] or 0, v[7] or 0, v[8] or 0, yaw)
        end
        text = text .. "\t},"
    end
    if item_spots and #item_spots ~= 0 then
        text = text .. "\n\n\titemBoxLocations = {\n"
        for i,v in ipairs(item_spots) do
            text = text .. string.format("\t\t{%d, %d, %d},\n",v[1] or 0, v[2] or 0, v[3] or 0)
        end
        text = text .. "\t},"
    end
    text = text .. "\n},"
    print(text)
    return true
end

function debug_mode(msg)
    DEBUG_MODE = not DEBUG_MODE
    if DEBUG_MODE then
        djui_chat_message_create("Entered debug mode")
    else
        djui_chat_message_create("Exiting debug mode")
    end
    return true
end

function round_pos(msg)
    local m = gMarioStates[0]
    if msg == "box" then
        local box = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvItemBox)
        if box then
            m.pos.x = box.oPosX
            m.pos.y = box.oPosY - 160
            m.pos.z = box.oPosZ
        end
        return true
    end
    local num = tonumber(msg) or 10
    m.pos.x = math.floor((m.pos.x/num)+0.5)*num
    m.pos.y = math.floor((m.pos.y/num)+0.5)*num
    m.pos.z = math.floor((m.pos.z/num)+0.5)*num
    return true
end

function round_angle(msg)
    local num = tonumber(msg) or 0x2000
    local m = gMarioStates[0]
    m.faceAngle.y = math.floor((m.faceAngle.y/num)+0.5)*num
    return true
end

function give_item(msg)
    local num = tonumber(msg) or 9
    gPlayerSyncTable[0].item = num
    gPlayerSyncTable[0].itemUses = 0
    shuffleItem = 0
    return true
end

function toggle_elim()
    gPlayerSyncTable[0].eliminated = ((gPlayerSyncTable[0].eliminated == 0) and 1) or 0 
    gPlayerSyncTable[0].isBomb = gPlayerSyncTable[0].eliminated ~= 0
    return true
end

-- debug free move
DEBUG_INVIS = false
function act_debug_free_move(m)
    if not m then
        return true
    end
    local action = ACT_IDLE
    local speed = (m.controller.buttonDown & B_BUTTON ~= 0) and 1 or 4

    if m.controller.buttonPressed & X_BUTTON ~= 0 then
        DEBUG_INVIS = not DEBUG_INVIS
    end
    if DEBUG_INVIS then
        m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
    else
        m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags & ~GRAPH_RENDER_INVISIBLE
    end

    set_mario_animation(m, MARIO_ANIM_A_POSE)

    if m.controller.buttonDown & A_BUTTON ~= 0 then
        m.pos.y = m.pos.y + 16.0 * speed
    end
    if m.controller.buttonDown & Z_TRIG ~= 0 then
        m.pos.y = m.pos.y - 16.0 * speed
    end
    if m.intendedMag > 0 then
        m.pos.x = m.pos.x + 26.0 * speed * sins(m.intendedYaw)
        m.pos.z = m.pos.z + 26.0 * speed * coss(m.intendedYaw)
    end

    resolve_and_return_wall_collisions(m.pos, 0, 100)
    if m.floorHeight > m.pos.y then
        m.pos.y = m.floorHeight
    end

    m.faceAngle.y = m.intendedYaw
    vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
    vec3s_set(m.marioObj.header.gfx.angle, 0, m.faceAngle.y, 0)
    if m.controller.buttonPressed == L_TRIG and m.marioObj.oTimer > 10 then
        if m.pos.y <= m.waterLevel - 100 then
            action = ACT_WATER_IDLE
        end
        set_mario_action(m, action, 0)
        DEBUG_INVIS = false
    end
    return false
end
hook_mario_action(ACT_DEBUG_FREE_MOVE, act_debug_free_move)

local cheatsOn = false
for i,mod in pairs(gActiveMods) do
    if mod.enabled then
        if mod.name == "Cheats" then
            cheatsOn = true
            break
        end
    end
end
if cheatsOn then
    DEBUG_MODE = true
    hook_chat_command("spot","[BACK] - set this spot as a start",add_spot)
    hook_chat_command("shine","[EXACT] - set this spot as the shine's start",add_shine_start)
    hook_chat_command("obj","[ADD|REMOVE|RESET,OBJ,YOFFSET,PARAM1|SHINE,PARAM2,PITCH,YAW] - place or remove objects",add_obj_spot)
    hook_chat_command("data","- Print all course data",print_data)
    hook_chat_command("debug","- Toggle debug mode",debug_mode)
    hook_chat_command("round","[NUM] - round mario's pos",round_pos)
    hook_chat_command("angle","[NUM] - round mario's angle",round_angle)
    hook_chat_command("item","[NUM] - give yourself this item",give_item)
    hook_chat_command("die"," - toggle eliminated state",toggle_elim)
    hook_chat_command("itembox","[ADD|REMOVE|RESET,YOFFSET] - place or remove item boxes",add_item_spot)
    djui_popup_create("Cheats Detected - Debug mode has been unlocked!",1)
end

function deep_copy(aTable)
    local newTable = {}
    for i,v in pairs(aTable) do
        if type(v) == "table" then
            newTable[i] = deep_copy(v)
        else
            newTable[i] = v
        end
    end
    return newTable
end

function reload_obj_data(levelData)
    obj_spots = deep_copy(levelData.objLocations or {})
    item_spots = deep_copy(levelData.itemBoxLocations or {})
    start_spots = {}
    if levelData.startLocations then
        for i,v in pairs(levelData.startLocations) do
            start_spots[i+1] = deep_copy(v)
        end
    end
    shine_spot = levelData.shineStart or shine_spot
end