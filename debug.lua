-- This is used for development purposes.

DEBUG_MODE = false
dev_spots = {}
box_spots = {}
shine_spot = {0, 0, 0}
pipe_spots = {}
function add_spot(msg)
    if msg == "reset" then
        dev_spots = {}
        djui_chat_message_create("reset start spots")

        if DEBUG_MODE then
            thisLevel.startLocations = {}
        end

        return true
    elseif msg == "back" and #dev_spots > 0 then
        table.remove(dev_spots, #dev_spots)
        djui_chat_message_create("removed last spot")

        if DEBUG_MODE then
            thisLevel.startLocations = {}
            for i,v in ipairs(dev_spots) do
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
    table.insert(dev_spots, {x, y, z})
    if DEBUG_MODE then
        thisLevel.startLocations = {}
        for i,v in ipairs(dev_spots) do
            thisLevel.startLocations[i-1] = v
        end
    end

    djui_chat_message_create("added (there are "..tostring(#dev_spots).." spots)")
    return true
end

function add_shine_spot(msg)
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
        local shine = obj_get_first_with_behavior_id(bhvShine)
        if shine then
            shine.oPosX = x
            shine.oPosY = y
            shine.oPosZ = z
        else
            spawn_sync_object(
                bhvShine,
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

function add_pipe_spot(msg)
    if msg == "reset" then
        pipe_spots = {}
        djui_chat_message_create("reset pipes")

        if DEBUG_MODE then
            local pipe = obj_get_first_with_behavior_id(bhvSTPipe)
            while pipe do
                obj_mark_for_deletion(pipe)
                pipe = obj_get_next_with_same_behavior_id(pipe)
            end
        end

        return true
    elseif msg == "back" and #pipe_spots > 0 then
        table.remove(pipe_spots, #pipe_spots)
        djui_chat_message_create("removed last pipe")

        if DEBUG_MODE then
            local pipe = obj_get_first_with_behavior_id(bhvSTPipe)
            local prevObj = pipe
            while pipe do
                prevObj = pipe
                pipe = obj_get_next_with_same_behavior_id(pipe)
            end
            obj_mark_for_deletion(prevObj)
        end

        return true
    end
    local m = gMarioStates[0]
    local x = math.floor(m.pos.x)
    local y = math.floor(m.floorHeight)
    local z = math.floor(m.pos.z)
    local to = tonumber(msg)
    local angle = m.faceAngle.y
    table.insert(pipe_spots, {x, y, z, to, angle})
    djui_chat_message_create("added (there are "..tostring(#pipe_spots).." pipes)")

    if DEBUG_MODE then
        spawn_non_sync_object(
            bhvSTPipe,
            E_MODEL_BITS_WARP_PIPE,
            x,y,z,
            function(o)
                o.oBehParams = #pipe_spots
                o.oBehParams2ndByte = to
                o.oFaceAngleYaw = angle
            end
        )
    end

    return true
end

function add_box_spot(msg)
    if msg == "reset" then
        box_spots = {}
        djui_chat_message_create("reset platforms")

        if DEBUG_MODE then
            local plat = obj_get_first_with_behavior_id(id_bhvStaticCheckeredPlatform)
            while plat do
                obj_mark_for_deletion(plat)
                plat = obj_get_next_with_same_behavior_id(plat)
            end
        end

        return true
    elseif msg == "back" and #box_spots > 0 then
        table.remove(box_spots, #box_spots)
        djui_chat_message_create("removed last platform")

        if DEBUG_MODE then
            local plat = obj_get_first_with_behavior_id(id_bhvStaticCheckeredPlatform)
            local prevObj = plat
            while plat do
                prevObj = plat
                plat = obj_get_next_with_same_behavior_id(plat)
            end
            obj_mark_for_deletion(prevObj)
        end

        return true
    end
    local m = gMarioStates[0]
    local x = math.floor(m.pos.x)
    local y = math.floor(m.pos.y) - 26
    local z = math.floor(m.pos.z)
    local pitch = 0
    local yaw = 0
    if msg == "shine" and shine_spot[2] then
        x = shine_spot[1]
        y = shine_spot[2] - 186
        z = shine_spot[3]
    elseif msg and msg ~= "" then
        local args = split(msg," ")
        pitch = tonumber(args[1]) or 0
        yaw = tonumber(args[2]) or m.faceAngle.y
    end
    table.insert(box_spots, {x, y, z, pitch, yaw})
    djui_chat_message_create("added (there are "..tostring(#box_spots).." platforms)")

    if DEBUG_MODE then
        spawn_non_sync_object(
            id_bhvStaticCheckeredPlatform,
            E_MODEL_CHECKERBOARD_PLATFORM,
            x,y,z,
            function(o)
                o.oFaceAnglePitch = pitch
                o.oFaceAngleYaw = yaw
            end
        )
    end

    return true
end

function print_data(msg)
    local np = gNetworkPlayers[0]
    local text = "[NUM] = {\n"
    text = text .. "\tlevel = " .. tostring(np.currLevelNum) .. ",\n"
    text = text .. "\tcourse = " .. tostring(np.currCourseNum) .. ",\n"
    text = text .. "\tarea = " .. tostring(np.currAreaIndex) .. ",\n\n"
    text = text .. "\tstartLocations = {\n"
    for i,v in ipairs(dev_spots) do
        text = text .. string.format("\t\t[%d] = {%d, %d, %d},\n",i-1,v[1],v[2],v[3])
    end
    text = text .. string.format("\t},\n\tshineStart = {%d, %d, %d},",shine_spot[1],shine_spot[2],shine_spot[3])
    if #box_spots > 0 then
        text = text .. "\n\n\tboxLocations = {\n"
        for i,v in ipairs(box_spots) do
            text = text .. string.format("\t\t{%d, %d, %d, 0x%x, %d},\n",v[1],v[2],v[3],v[4],v[5])
        end
        text = text .. "\t},"
    end
    if #pipe_spots > 0 then
        text = text .. "\n\n\tpipeLocations = {\n"
        for i,v in ipairs(pipe_spots) do
            text = text .. string.format("\t\t{%d, %d, %d, %d, %d},\n",v[1],v[2],v[3],v[4],v[5])
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
        gGlobalSyncTable.gameState = 0
        showGameResults = false
        inMenu = false
        djui_chat_message_create("Entered debug mode")
    else
        djui_chat_message_create("Exiting debug mode")
    end
    return true
end

function round_pos(msg)
    local num = tonumber(msg) or 10
    local m = gMarioStates[0]
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

if network_is_server() and gServerSettings.enableCheats ~= 0 then
    hook_chat_command("spot","- set this spot as a start",add_spot)
    hook_chat_command("shine","- set this spot as the shine's start",add_shine_spot)
    hook_chat_command("plat","- place a platform at this spot",add_box_spot)
    hook_chat_command("pipe","- place a platform at this spot",add_pipe_spot)
    hook_chat_command("data","- Print all course data",print_data)
    hook_chat_command("debug","- Toggle debug mode",debug_mode)
    hook_chat_command("round","[NUM] - round mario's pos",round_pos)
    hook_chat_command("angle","[NUM] - round mario's angle",round_angle)
    djui_popup_create("Cheats Detected - Debug mode has been unlocked!",1)
end