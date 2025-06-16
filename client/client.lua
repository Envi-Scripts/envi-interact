local debug = false
local menuState = {}
local percentState = {}
local sliderData = {}
local interactionPoints = {}
local cam
local currentLabel = 'UNDEFINED'
local callbackFunctions = {}
local interactionPeds = {}
local spawnedPeds = {}
local wait = 1250
local menuOptionSelectedHandler = nil
local scrollCooldown = 250
local scrollCooldownTimer = 0
local currentPointData = {}
local waitingForSpeech = {}
local currentMenuID = nil
local currentPercentageBarID = nil
local currentPed = nil
local lastOptionSelected = 0
local lastInteraction = 0
local optionCooldown = 2000 -- 2 seconds
local interactionPedData = {}
local interactionModelData = {}
local interactionGlobalVehicleData = {}
local interactionGlobalPedData = {}
local interactionGlobalPlayerData = {}

local speechCategories = {
    ["PositiveReaction"] = PositiveReaction,
    ["NegativeReaction"] = NegativeReaction,
    ["AngryReaction"] = AngryReaction,
    ["NeutralReaction"] = NeutralReaction,
    ["ScaredReaction"] = ScaredReaction,
    ["Hello"] = Hello,
    ["Bye"] = Bye,
    ["Yes"] = Yes,
    ["No"] = No,
    ["Thanks"] = Thanks,
    ["OverThere"] = OverThere,
    ["Conversation"] = Conversation,
    ["Apology"] = Apology,
    ["HitCar"] = HitCar,
    ["Tour"] = Tour
}

local function PlaySpeech(ped, speech, params)
    CreateThread(function()
        if speechCategories[speech] then
            local category = speechCategories[speech]
            local random = math.random(1, #category)
            speech = category[random]
        end
        PlayPedAmbientSpeechNative(ped, speech, params)
    end)
end

exports("PlaySpeech", PlaySpeech)

--- Opens a choice menu with given parameters.
---@param data table Table containing menu options like title, menuID, timeout table, and options list.
---@return string The key of the selected option.
function OpenChoiceMenu(data)
    local timedOut = false
    currentMenuID = data.menuID
    if data.timeout and data.timeout.time then
        data.timeout.time = data.timeout.time * 1000
        SetTimeout(data.timeout.time, function()
            if menuState[data.menuID] then
                print('Choice Menu timed out after ' .. data.timeout.time / 1000 .. ' seconds')
                if data.timeout.closeEverything then
                    CloseEverything()
                    currentMenuID = nil
                else
                    CloseMenu(data.menuID)
                    if currentMenuID == data.menuID then
                        currentMenuID = nil
                    end
                end
                timedOut = true
            end
        end)
    end
    menuState[data.menuID] = true
    local serializableOptions = {}
    local filteredOptions = {}
    for i, option in ipairs(data.options) do
        local shouldInclude = true
        if option.canSee then
            shouldInclude = option.canSee()
        end
        if shouldInclude then
            table.insert(filteredOptions, {
                key = option.key,
                label = option.label,
                closeAll = option.closeAll or nil,
                speech = option.speech or nil,
                speechOptions = option.speechOptions or nil,
                reaction = option.reaction or nil
            })
            callbackFunctions[data.menuID] = callbackFunctions[data.menuID] or {}
            callbackFunctions[data.menuID][option.key] = option.selected
        end
    end
    callbackFunctions[data.menuID].onESC = data.onESC
    local duration = Config.DefaultTypeDelay
    if data.speechOptions and data.speechOptions.duration then
        duration = data.speechOptions.duration
    end
    SendNUIMessage({
        action = 'openChoiceMenu',
        speech = data.speech,
        title = data.title,
        menuID = data.menuID,
        position = data.position,
        speechOptions = data.speechOptions or nil,
        duration = duration,
        options = filteredOptions,
        onESC = data.onESC ~= nil
    })
    SetNuiFocus(true, true)
    return 'done'
end

--- Creates a NPC with the given data and interaction options.
---@param pedData table Table containing ped data like model, coordinates, and heading.
---@param interactionData table Table containing interaction options like slider state, speech, and position.
function CreateNPC(pedData, interactionData)
    RequestModel(pedData.model)
    while not HasModelLoaded(pedData.model) do
        Wait(100)
    end
    local ped = CreatePed(4, pedData.model, pedData.coords.x, pedData.coords.y, pedData.coords.z, pedData.heading, false, false)
    while not DoesEntityExist(ped) do
        Wait(100)
    end
    table.insert(spawnedPeds, ped)
    interactionPeds[interactionData.menuID] = ped
    if pedData.isFrozen then
        Wait(950)
        FreezeEntityPosition(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetEntityInvincible(ped, true)
    end
    InteractionEntity(ped, {
        {
            name = interactionData.menuID,
            distance = interactionData.distance or 2.0,
            radius = interactionData.radius or 1.5,
            options = {
                {
                    label = '[E] - Talk',
                    selected = function(data)
                        PedInteraction(ped, interactionData)
                    end,
                }
            }
        }
    })
    return ped
end

--- Handles interactions with a ped, setting up a menu based on provided options.
---@param entity any The entity involved in the interaction.
---@param data table Table containing interaction options like slider state, speech, and position.
---@return boolean Returns false if the menu timed out - true if all menus are closed after interaction.
function PedInteraction(entity, data)
    local currentTime = GetGameTimer()
    if currentTime - lastInteraction < 1000 then
        return false
    end
    lastInteraction = currentTime
    currentPed = entity
    local timedOut = false
    menuState[data.menuID] = true
    if data.timeout and data.timeout.time then
        data.timeout.time = data.timeout.time * 1000
        SetTimeout(data.timeout.time, function()
            if menuState[data.menuID] then
                print('Choice Menu timed out after ' .. data.timeout.time / 1000 .. ' seconds')
                if data.timeout.closeEverything then
                    CloseEverything()
                    currentMenuID = nil
                else
                    CloseMenu(data.menuID)
                    if currentMenuID == data.menuID then
                        currentMenuID = nil
                    end
                end
                timedOut = true
            end
        end)
    end
    if data.freeze then
        FreezeEntityPosition(entity, true)
    end
    if not data.coords then
        data.coords = GetEntityCoords(entity, true)
    end
    if data.focusCam then
        local coords = GetEntityCoords(PlayerPedId())
        local entCoords = GetEntityCoords(entity)
        local screenCoords = GetOffsetFromEntityInWorldCoords(entity, 0.0, 0.9, 0.55)
        local dist = #(coords - entCoords)
        if dist < 8.0 then
            cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
            SetCamCoord(cam, screenCoords.x, screenCoords.y, screenCoords.z)
            PointCamAtCoord(cam, data.coords.x, data.coords.y, data.coords.z + 0.4)
            RenderScriptCams(true, true, 1000, 1, 1)
            Wait(500)
        end
    end
    if data.greeting then
        PlaySpeech(entity, data.greeting, 'SPEECH_PARAMS_FORCE_NORMAL_CLEAR')
    end
    local serializableOptions = {}
    local filteredOptions = {}
    for i, option in ipairs(data.options) do
        local shouldInclude = true
        if option.canSee then
            shouldInclude = option.canSee()
        end
        if shouldInclude then
            table.insert(filteredOptions, {
                key = option.key,
                label = option.label,
                stayOpen = option.stayOpen or false,
                closeAll = option.closeAll or false,
                speech = option.speech or nil,
                reaction = option.reaction or nil
            })
            callbackFunctions[data.menuID] = callbackFunctions[data.menuID] or {}
            callbackFunctions[data.menuID][option.key] = option.selected
        end
    end

    -- Check if there are no available options
    if #filteredOptions == 0 then
        SendNUIMessage({
            action = 'openPedMenu',
            title = data.title,
            menuID = data.menuID,
            position = data.position,
            speech = "I've got nothing to say to you!",
            options = {},
            onESC = true
        })
        SetNuiFocus(true, true)
        Wait(5000)
        CloseMenu(data.menuID)
        currentMenuID = nil
        if data.freeze then
            FreezeEntityPosition(entity, false)
        end
        return false
    end

    callbackFunctions[data.menuID].onESC = data.onESC
    local duration = Config.DefaultTypeDelay
    if data.speechOptions and data.speechOptions.duration then
        duration = data.speechOptions.duration
    end
    SendNUIMessage({
        action = 'openPedMenu',
        title = data.title,
        menuID = data.menuID,
        position = data.position,
        sliderState = data.sliderState or 'disabled',
        sliderValue = data.sliderValue or false,
        speech = data.speech or false,
        speechOptions = data.speechOptions or nil,
        duration = duration,
        options = filteredOptions,
        onESC = data.onESC ~= nil
    })
    SetNuiFocus(true, true)
    local wait = 1000
    while menuState[data.menuID] do
        local coords = GetEntityCoords(PlayerPedId())
        local pedCoord = GetEntityCoords(entity)
        local distance = #(coords - pedCoord)
        if data.standStill or data.freeze then
            ClearPedTasks(entity)
            TaskStandStill(entity, 10000)
            wait = 10
        end
        if distance > 5.0 then
            CloseMenu(data.menuID)
            currentMenuID = nil
            break
        end
        Wait(wait)
    end
    if data.freeze then
        FreezeEntityPosition(entity, false)
    end
    currentMenuID = nil
    return not timedOut
end

-- Returns the currently open menu IDs.
---@return any, any The currently open menu IDs.
function GetOpenMenuIDs()
    if not currentMenuID and not currentPercentageBarID then
        return nil, nil
    end
    return currentMenuID, currentPercentageBarID
end

--- Returns the currently open menu IDs and their states.
---@return table -- A table containing the IDs of all currently open menus and their states.
function GetOpenMenus()
    if not next(menuState) then
        return {}
    end
    return menuState
end

--- Returns the currently open percentage bar IDs and their states.
---@return table -- A table containing the IDs of all currently open percentage bars and their states.
function GetOpenPercentBars()
    if not next(percentState) then
        return {}
    end
    return percentState
end

--- Allows user interaction with a slider within a menu.
---@param menuID string The ID of the menu containing the slider.
---@param data table Table containing slider options like initial and new values.
---@return number, number The new and old slider values.
function UseSlider(menuID, data)
    sliderData[menuID] = {
        min = data.min or 0,
        max = data.max or 100,
        title = data.title,
        sliderState = data.sliderState or 'locked',
        sliderValue = data.sliderValue or 0,
        confirm = msgpack.unpack(msgpack.pack(data.confirm)),
        nextState = data.nextState or 'locked',
        hideChoice = data.hideChoice or false
    }
    SendNUIMessage({
        menuID = menuID,
        title = data.title,
        action = 'useSlider',
        nextState = data.nextState,
        min = data.min,
        max = data.max,
        sliderState = data.sliderState,
        sliderValue = data.sliderValue,
        hideChoice = data.hideChoice
    })
end

--- Forces an update of the slider value in a menu.
---@param menuID string The ID of the menu where the slider is active.
---@param sliderValue number The new value to set the slider to.
function ForceUpdateSlider(menuID, sliderValue)
    local minSliderValue = sliderData[menuID].min
    local maxSliderValue = sliderData[menuID].max
    if sliderValue < minSliderValue or sliderValue > maxSliderValue then
        print("Error: slider value is out of bounds.")
        return
    end
    SendNUIMessage({
        menuID = menuID,
        action = 'forceUpdateSlider',
        sliderValue = sliderValue
    })
end

-- Updates the speech bubble for a menu.
---@param menuID string The ID of the menu to update the speech bubble for.
---@param speech string The new speech bubble text.
function UpdateSpeech(menuID, speech, duration)
    SendNUIMessage({
        menuID = menuID,
        action = 'updateSpeech',
        duration = duration or Config.DefaultTypeDelay,
        speech = speech
    })
    waitingForSpeech[menuID] = true
    while waitingForSpeech[menuID] do
        Wait(500)
    end
    Wait(500)
end

--- Displays a percentage bar as a separate menu.
---@param menuID string The new menu ID for the percentage bar.
---@param percent number The percentage value to display.
---@param title string The title of the percentage bar.
---@param position string The position of the percentage bar on the screen.
---@param tooltip string The tooltip position of the percentage bar on the screen.
---@param c1 string Replace green color value of the percentage bar. 0% - 24%
---@param c2 string Replace amber color value of the percentage bar. 25% - 75%
---@param c3 string Replace red color value of the percentage bar. 76% - 100%
function PercentageBar(menuID, percent, title, position, tooltip, c1, c2, c3)
    if percent < 0 then
        percent = 0
    end
    if percent > 100 then
        percent = 100
    end
    percentState[menuID] = true
    currentPercentageBarID = menuID
    SendNUIMessage({
        percentID = menuID,
        action = 'percentageBar',
        title = title,
        percentage = percent,
        tooltip = tooltip or 'hover', -- 'hover, 'none', 'always'
        position = position,
        colors = {
            c1 = c1,
            c2 = c2,
            c3 = c3
        }
    })
    return menuID
end

--- Returns the ped associated with a menu ID.
---@param menuID string The ID of the menu to get the ped from.
---@return any The ped associated with the menu ID.
function GetInteractionPed(menuID)
    return interactionPeds[menuID]
end

-- -- Raycast Based - PRESS E Interaction - (runs at 0.00ms!)
---@param position vector3 - The position of the interaction point.
---@param data table - Table containing interaction options like slider state, speech, and position.
function InteractionPoint(position, data)
    if data then
        if data.name then
            interactionPoints[data.name] = {
                name = data.name,
                position = position,
                options = {},
                distance = data.distance,
                currentOption = 1,
                radius = data.radius or 1.0,
            }
            for _, option in ipairs(data.options) do
                table.insert(interactionPoints[data.name].options, option)
            end
        else
            print('No name provided for interaction point')
        end
    end
end

---@param entity number - The ped to be used as the interaction point.
---@param data table - Table containing interaction options like slider state, speech, and position.
function InteractionEntity(entity, data)
    if data then
        if data[1].name then
            interactionPedData[data[1].name] = {
                name = data[1].name,
                options = {},
                distance = data[1].distance,
                currentOption = 1,
                radius = data[1].radius or 1.0,
                entity = entity or nil
            }
            for _, option in ipairs(data[1].options) do
                table.insert(interactionPedData[data[1].name].options, option)
            end
        else
            print('No name provided for interaction point')
        end
    end
end

---@param model string - The model hash to be used as the interaction point.
---@param data table - Table containing interaction options like slider state, speech, and position.
function InteractionModel(model, data)
    if not data or not data[1] or not data[1].name then
        print('Invalid data provided for interaction model')
        return
    end

    local models = type(model) == 'table' and model or {model}

    for _, modelHash in ipairs(models) do
        local model = modelHash
        if type(modelHash) == 'string' then
            model = joaat(modelHash)
        end
        local name = data[1].name..'_'..model
        interactionModelData[name] = {
            name = name,
            options = {},
            distance = data[1].distance,
            currentOption = 1,
            radius = data[1].radius or 1.0,
            model = model,
            bones = data[1].bones or {}
        }
        for _, option in ipairs(data[1].options) do
            table.insert(interactionModelData[name].options, option)
        end
    end
end

---@param data table - Table containing interaction options for all vehicles.
function InteractionGlobalVehicle(data)
    if not data or not data.name then
        print('Invalid data provided for global vehicle interaction')
        return
    end

    interactionGlobalVehicleData[data.name] = {
        name = data.name,
        options = {},
        distance = data.distance or 2.0,
        currentOption = 1,
        radius = data.radius or 1.0,
        bones = data.bones or {}
    }
    for _, option in ipairs(data.options) do
        table.insert(interactionGlobalVehicleData[data.name].options, option)
    end
end

---@param data table - Table containing interaction options for all non-player peds.
function InteractionGlobalPed(data)
    if not data or not data.name then
        print('Invalid data provided for global ped interaction')
        return
    end

    interactionGlobalPedData[data.name] = {
        name = data.name,
        options = {},
        distance = data.distance or 2.0,
        currentOption = 1,
        radius = data.radius or 1.0
    }
    for _, option in ipairs(data.options) do
        table.insert(interactionGlobalPedData[data.name].options, option)
    end
end

---@param data table - Table containing interaction options for all players.
function InteractionGlobalPlayer(data)
    if not data or not data.name then
        print('Invalid data provided for global player interaction')
        return
    end

    interactionGlobalPlayerData[data.name] = {
        name = data.name,
        options = {},
        distance = data.distance or 2.0,
        currentOption = 1,
        radius = data.radius or 1.0
    }
    for _, option in ipairs(data.options) do
        table.insert(interactionGlobalPlayerData[data.name].options, option)
    end
end

---------------------------------------
---------------------------------------
-- Credits: QB-Core
-- Source:  https://github.com/qbcore-framework/qb-adminmenu/blob/main/client/entity_view.lua

local RotationToDirection = function(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end


local RayCastGamePlayCamera = function(distance)
    local currentRenderingCam = nil
    if not IsGameplayCamRendering() then
        currentRenderingCam = GetRenderingCam()
    end
    local cameraRotation = not currentRenderingCam and GetGameplayCamRot() or GetCamRot(currentRenderingCam, 2)
    local cameraCoord = not currentRenderingCam and GetGameplayCamCoord() or GetCamCoord(currentRenderingCam)
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local _, b, c, _, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end

--- Validates if hit position is within range of specified bones
---@param entity number The entity to check bones on
---@param hitPosition vector3 The hit position to validate
---@param bones table Table of bone names or indices to check
---@return boolean True if within range of any specified bone
local function ValidateBoneProximity(entity, hitPosition, myCoords, bones, radius, distance)
    if not bones or #bones == 0 then
        return true -- No bone validation required
    end
    -- single bone (string)
    if type(bones) == 'string' then
        local boneId = GetEntityBoneIndexByName(entity, bones)
        if boneId ~= -1 and #(hitPosition - GetEntityBonePosition_2(entity, boneId)) <= radius or 0.5 and #(myCoords - hitPosition) <= distance or 2.0 then
            return true
        else
            return false
        end
    end
    --  multiple bones (table)
    if type(bones) == 'table' then
        local closestBone, boneDistance
        for i = 1, #bones do
            local bone = bones[i]
            local boneId
            if type(bone) == 'string' then
                boneId = GetEntityBoneIndexByName(entity, bone)
            else
                boneId = bone
            end
            if boneId ~= -1 then
                local dist = #(hitPosition - GetEntityBonePosition_2(entity, boneId))
                if dist <= (boneDistance or 1.0) then
                    closestBone = boneId
                    boneDistance = dist
                end
            end
        end
        if closestBone then
            return true
        else
            return false
        end
    end
    return false
end

-------------------------------------------------

CreateThread(function()
    local lastPointData = nil
    while true do
        local ped = PlayerPedId()
        local closestPoint = nil
        local minDistance = math.huge
        local hit, hitPosition, hitEntity = RayCastGamePlayCamera(200)
        local coords = GetEntityCoords(ped)

        if debug and hit and hitPosition and not closestPoint then
            local coords = GetEntityCoords(hitEntity)
            DrawLine(coords.x, coords.y, coords.z, hitPosition.x, hitPosition.y, hitPosition.z, 255, 0, 0, 100)
        end

        -- Check for model interactions
        for _, modelInteraction in pairs(interactionModelData) do
            if hit and hitEntity > 0 then
                local hitType = GetEntityType(hitEntity)
                local success, hitModel = false, nil
                if hitType > 0 then
                    success, hitModel = pcall(function()
                        return GetEntityModel(hitEntity)
                    end)
                end
                if success and hitModel then
                    if hitModel == modelInteraction.model then
                        modelInteraction.entity = hitEntity
                        local entityCoords = GetEntityCoords(hitEntity)
                        local myCoords = GetEntityCoords(ped)
                        if entityCoords then
                            local distance = #(myCoords - entityCoords)
                            local hitDistance = #(hitPosition - entityCoords)
                            if hitDistance < (modelInteraction.radius or 1.0) and distance < modelInteraction.distance then
                                minDistance = distance
                                closestPoint = modelInteraction
                                if debug and closestPoint then
                                    local coords = GetEntityCoords(hitEntity)
                                    DrawLine(coords.x, coords.y, coords.z, hitPosition.x, hitPosition.y, hitPosition.z, 0, 255, 0, 100)
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Check for global vehicle interactions
        for _, globalVehicleInteraction in pairs(interactionGlobalVehicleData) do
            if hit and hitEntity > 0 then
                local hitType = GetEntityType(hitEntity)
                if hitType == 2 then -- Vehicle entity type
                    globalVehicleInteraction.entity = hitEntity
                    local entityCoords = GetEntityCoords(hitEntity)
                    local myCoords = GetEntityCoords(ped)
                    if entityCoords then
                        local distance = #(myCoords - entityCoords)
                        local hitDistance = #(hitPosition - entityCoords)
                        local boneValid = ValidateBoneProximity(hitEntity, hitPosition, myCoords, globalVehicleInteraction.bones, globalVehicleInteraction.radius, globalVehicleInteraction.distance)
                        if hitDistance < (globalVehicleInteraction.radius or 1.0) and distance < globalVehicleInteraction.distance and distance < minDistance and boneValid then
                            minDistance = distance
                            closestPoint = globalVehicleInteraction
                            if debug and closestPoint then
                                local coords = GetEntityCoords(hitEntity)
                                DrawLine(coords.x, coords.y, coords.z, hitPosition.x, hitPosition.y, hitPosition.z, 0, 255, 0, 100)
                            end
                        end
                    end
                end
            end
        end

        -- Check for global ped interactions (non-player peds)
        for _, globalPedInteraction in pairs(interactionGlobalPedData) do
            if hit and hitEntity > 0 then
                local hitType = GetEntityType(hitEntity)
                if hitType == 1 then
                    local isPlayer = IsPedAPlayer(hitEntity)
                    if not isPlayer then -- Only non-player peds
                        globalPedInteraction.entity = hitEntity
                        local entityCoords = GetEntityCoords(hitEntity)
                        local myCoords = GetEntityCoords(ped)
                        if entityCoords then
                            local distance = #(myCoords - entityCoords)
                            local hitDistance = #(hitPosition - entityCoords)
                            if hitDistance < (globalPedInteraction.radius or 1.0) and distance < globalPedInteraction.distance and distance < minDistance then
                                minDistance = distance
                                closestPoint = globalPedInteraction
                                if debug and closestPoint then
                                    local coords = GetEntityCoords(hitEntity)
                                    DrawLine(coords.x, coords.y, coords.z, hitPosition.x, hitPosition.y, hitPosition.z, 0, 255, 0, 100)
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Check for global player interactions
        for _, globalPlayerInteraction in pairs(interactionGlobalPlayerData) do
            if hit and hitEntity > 0 then
                local hitType = GetEntityType(hitEntity)
                if hitType == 1 then
                    local isPlayer = IsPedAPlayer(hitEntity)
                    if isPlayer and hitEntity ~= ped then -- Only other players, not self
                        globalPlayerInteraction.entity = hitEntity
                        local entityCoords = GetEntityCoords(hitEntity)
                        local myCoords = GetEntityCoords(ped)
                        if entityCoords then
                            local distance = #(myCoords - entityCoords)
                            local hitDistance = #(hitPosition - entityCoords)
                            if hitDistance < (globalPlayerInteraction.radius or 1.0) and distance < globalPlayerInteraction.distance and distance < minDistance then
                                minDistance = distance
                                closestPoint = globalPlayerInteraction
                                if debug and closestPoint then
                                    local coords = GetEntityCoords(hitEntity)
                                    DrawLine(coords.x, coords.y, coords.z, hitPosition.x, hitPosition.y, hitPosition.z, 0, 255, 0, 100)
                                end
                            end
                        end
                    end
                end
            end
        end

        for _, npc in pairs(interactionPedData) do
            local entityCoords = GetEntityCoords(npc.entity)
            local myCoords = GetEntityCoords(ped)
            local distance = #(myCoords - entityCoords)
            local hitDistance = #(hitPosition - entityCoords)
            if distance < npc.distance and hitDistance < (npc.radius or 1.0) and distance < (interactionPedData.distance or 2.0) then
                minDistance = distance
                closestPoint = npc
                if debug and closestPoint then
                    local coords = GetEntityCoords(hitEntity)
                    DrawLine(coords.x, coords.y, coords.z, hitPosition.x, hitPosition.y, hitPosition.z, 0, 255, 0, 100)
                end
            end
        end

        for _, interactionPoint in pairs(interactionPoints) do
            local distance = #(coords - interactionPoint.position)
            local hitDistance = #(hitPosition - interactionPoint.position)
            if distance < interactionPoint.distance and distance < minDistance and hitDistance < (interactionPoint.radius or 1.0) then
                minDistance = distance
                closestPoint = interactionPoint
                if debug and closestPoint then
                    local coords = GetEntityCoords(hitEntity)
                    DrawLine(coords.x, coords.y, coords.z, hitPosition.x, hitPosition.y, hitPosition.z, 0, 255, 0, 100)
                end
            end
        end

        if closestPoint then
            if lastPointData ~= closestPoint then
                local visibleOptions = {}
                for _, option in ipairs(closestPoint.options) do
                    local shouldInclude = true
                    if option.canSee then
                        shouldInclude = option.canSee(closestPoint.entity)
                    end
                    if shouldInclude then
                        table.insert(visibleOptions, option)
                    end
                end

                if #visibleOptions > 0 then
                    lastPointData = closestPoint
                    currentPointData = closestPoint
                    currentPointData.visibleOptions = visibleOptions
                    currentPointData.currentOption = 1
                    ShowText(visibleOptions[1].label, true, visibleOptions)
                else
                    HideText()
                    lastPointData = nil
                    currentPointData = nil
                end
            end
        else
            if lastPointData then
                ShowText(currentLabel, false, nil)
                HideText()
                lastPointData = nil
                currentPointData = nil
            end
        end
        Wait(wait)
    end
end)

--- Closes a menu based on its ID.
---@param menuID string The ID of the menu to close.
---@param speech string The speech to play before the menu closes.
function CloseMenu(menuID, speech)
    if menuState[menuID] then
        if speech then
            UpdateSpeech(menuID, speech)
        end
        SendNUIMessage({
            action = 'closeMenu',
            menuID = menuID,
            percentID = 'none'
        })
        menuState[menuID] = nil
        currentMenuID = nil
        if cam then
            SetCamActive(cam, false)
            RenderScriptCams(false, true, 1000, 1, 1)
            DestroyCam(cam, true)
        end
        cam = nil
        SetNuiFocus(false, false)
        if menuOptionSelectedHandler then
            RemoveEventHandler(menuOptionSelectedHandler)
            menuOptionSelectedHandler = nil
        end
        currentPed = nil
    end
    if percentState[menuID] then
        SendNUIMessage({
            action = 'closeMenu',
            menuID = 'none',
            percentID = menuID
        })
        percentState[menuID] = nil
    end
end

-- Checks if any menu is open.
---@return boolean - Whether any menu is open.
function IsAnyMenuOpen()
    return currentMenuID ~= nil
end

-- Checks if any percentage bar is open.
---@return boolean - Whether any percentage bar is open.
function IsAnyPercentBarOpen()
    return next(percentState) ~= nil
end

-- Closes all open menus and percentage bars.
function CloseEverything()
    CloseAllPercentBars()
    CloseAllMenus()
    currentMenuID = nil
end

--- Closes all open menus.
function CloseAllMenus()
    local openMenus = GetOpenMenus()
    if not openMenus then
        print('No menus are open')
        return
    else
        for menuID, _ in pairs(openMenus) do
            CloseMenu(menuID)
        end
    end
    currentMenuID = nil
end

-- Closes all open percentage bars.
function CloseAllPercentBars()
    local openPercentBars = GetOpenPercentBars()
    if not openPercentBars then
        print('No percentage bars are open')
        return
    else
        for percentID, _ in pairs(openPercentBars) do
            CloseMenu(percentID)
        end
    end
    if currentPercentageBarID then
        CloseMenu(currentPercentageBarID)
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end
    for _, ped in pairs(spawnedPeds) do
        DeleteEntity(ped)
    end
    HideText()
end)

RegisterCommand('+scrollDown', function()
    if not currentPointData or not currentPointData.visibleOptions then
        return
    end
    local currentTime = GetGameTimer()
    if currentTime - scrollCooldownTimer < scrollCooldown then
        return
    end
    scrollCooldownTimer = currentTime
    local numberOfOptions = #currentPointData.visibleOptions
    currentPointData.currentOption = currentPointData.currentOption + 1
    if currentPointData.currentOption > numberOfOptions then
        currentPointData.currentOption = numberOfOptions
    end
    ShowText(currentPointData.visibleOptions[currentPointData.currentOption].label, true, currentPointData.visibleOptions)
end, false)

RegisterCommand('+scrollUp', function()
    if not currentPointData or not currentPointData.visibleOptions then
        return
    end
    local currentTime = GetGameTimer()
    if currentTime - scrollCooldownTimer < scrollCooldown then
        return
    end
    scrollCooldownTimer = currentTime
    currentPointData.currentOption = currentPointData.currentOption - 1
    if currentPointData.currentOption < 1 then
        currentPointData.currentOption = 1
    end
    ShowText(currentPointData.visibleOptions[currentPointData.currentOption].label, true, currentPointData.visibleOptions)
end, false)

RegisterCommand('interact', function()
    if not currentPointData or not currentPointData.visibleOptions then
        return
    end
    local currentOption = currentPointData.visibleOptions[currentPointData.currentOption]
    HideText()
    currentOption.selected(currentPointData)
end, false)

RegisterCommand('-scrollUp', function()
    return
end, false)

RegisterCommand('-scrollDown', function()
    return
end, false)


RegisterKeyMapping('interact', 'Envi-Interact - Interact', 'keyboard', 'E')
RegisterKeyMapping('+scrollDown', 'Envi-Interact - Scroll Down', 'MOUSE_WHEEL', 'IOM_WHEEL_DOWN')
RegisterKeyMapping('+scrollUp', 'Envi-Interact - Scroll Up', 'MOUSE_WHEEL', 'IOM_WHEEL_UP')

--- Registers a callback for when an option is selected in a NUI menu.
---@param data table Data passed from the NUI containing the selected option.
---@param cb function Callback function to execute after selection.
RegisterNuiCallback('selectOption', function(data, cb)
    local currentTime = GetGameTimer()
    if currentTime - lastOptionSelected < optionCooldown then
        cb(0)
        return
    end
    lastOptionSelected = currentTime
    
    local menuID = data.menuID
    local key = data.key
    local speech = data.speech
    local reaction = data.reaction

    if reaction and currentPed then
            PlaySpeech(currentPed, reaction, 'SPEECH_PARAMS_FORCE_NORMAL_CLEAR')
    end
    if speech then
        UpdateSpeech(menuID, speech)
    end
    if callbackFunctions[menuID] and callbackFunctions[menuID][key] then
        callbackFunctions[menuID][key](data)
        TriggerEvent('envi-interact:menuOptionSelected', key)  -- Trigger custom event with the key
        cb(1)
    else
        TriggerEvent('envi-interact:menuOptionSelected', key)  -- Trigger custom event with the key
        cb(0)
        CloseMenu(menuID)
    end
end)


--- Registers a callback for when a slider value is confirmed in a NUI menu.
---@param data table Data passed from the NUI containing the slider confirmation.
---@param cb function Callback function to execute after confirmation.
RegisterNuiCallback('sliderConfirm', function(data, cb)
    local menuID = data.menuID
    if sliderData[menuID].nextState == 'disabled' then
        cb('hideSlider')
    elseif sliderData[menuID].nextState == 'locked' then
        cb('lockSlider')
    elseif sliderData[menuID].nextState == 'unlocked' then
        cb('unlockSlider')  
    else
        cb('lockSlider')
    end
    if not data or not data.menuID or not data.sliderValue then
        print("Error: invalid data received from NUI")
        return
    end
    if not sliderData[menuID] then
        print("Error: menuID not found in sliderData")
        return
    end
    local newValue = data.sliderValue
    local oldValue = sliderData[menuID].sliderValue
    sliderData[menuID].sliderValue = newValue
    sliderData[menuID].confirm(tonumber(newValue), tonumber(oldValue))
end)

RegisterNuiCallback('close', function(data, cb)
    CloseMenu(data.menuID)
    cb(1)
end)

RegisterNuiCallback('closeAll', function(data, cb)
    CloseAllMenus()
    cb(1)
end)

RegisterNuiCallback('keydown', function(data, cb)
    cb(1)
end)

RegisterNUICallback('speechComplete', function(data)
    if waitingForSpeech[data.menuID] then
        waitingForSpeech[data.menuID] = nil
    end
end)

RegisterNuiCallback('escPressed', function(data, cb)
    local menuID = data.menuID
    if callbackFunctions[menuID] and callbackFunctions[menuID].onESC then
        callbackFunctions[menuID].onESC()
    else
        CloseMenu(menuID)
    end
    cb(1)
end)

RegisterCommand('toggleDebug', function()
    if not Config.EnableDebugLine then
        return
    end
    debug = not debug
    if debug then
        wait = 0
    else
        wait = 1250
    end
end, false)

RegisterCommand('testCloseEverything', function()
    CloseEverything()
end, false)

RegisterCommand('testCloseAllMenus', function()
    CloseAllMenus()
end, false)

RegisterCommand('testCloseAllPercentBars', function()
    CloseAllPercentBars()
end, false)


RegisterKeyMapping('toggleDebug', 'Envi-Interact - Debug Vision', 'keyboard', 'RMENU')

--- Removes a global vehicle interaction by name.
---@param name string The name of the global vehicle interaction to remove.
function RemoveInteractionGlobalVehicle(name)
    if interactionGlobalVehicleData[name] then
        interactionGlobalVehicleData[name] = nil
        return true
    end
    return false
end

--- Removes a global ped interaction by name.
---@param name string The name of the global ped interaction to remove.
function RemoveInteractionGlobalPed(name)
    if interactionGlobalPedData[name] then
        interactionGlobalPedData[name] = nil
        return true
    end
    return false
end

--- Removes a global player interaction by name.
---@param name string The name of the global player interaction to remove.
function RemoveInteractionGlobalPlayer(name)
    if interactionGlobalPlayerData[name] then
        interactionGlobalPlayerData[name] = nil
        return true
    end
    return false
end

--- Removes all global interactions.
function RemoveAllGlobalInteractions()
    interactionGlobalVehicleData = {}
    interactionGlobalPedData = {}
    interactionGlobalPlayerData = {}
end

--- Exports functions to be accessible from other scripts.
exports('OpenChoiceMenu', OpenChoiceMenu)

exports('UseSlider', UseSlider)
exports('ForceUpdateSlider', ForceUpdateSlider)

exports('PedInteraction', PedInteraction)
exports('UpdateSpeech', UpdateSpeech)

exports('CreateNPC', CreateNPC)

exports('PercentageBar', PercentageBar)

exports('GetOpenMenus', GetOpenMenus)
exports('IsAnyPercentBarOpen', IsAnyPercentBarOpen)
exports('IsAnyMenuOpen', IsAnyMenuOpen)

exports('CloseEverything', CloseEverything)
exports('CloseAllPercentBars', CloseAllPercentBars)
exports('CloseMenu', CloseMenu)
exports('CloseAllMenus', CloseAllMenus)

exports('InteractionPoint', InteractionPoint)
exports('InteractionEntity', InteractionEntity)
exports('InteractionModel', InteractionModel)
exports('InteractionGlobalVehicle', InteractionGlobalVehicle)
exports('InteractionGlobalPed', InteractionGlobalPed)
exports('InteractionGlobalPlayer', InteractionGlobalPlayer)
exports('GetInteractionPed', GetInteractionPed)
exports('RemoveInteractionGlobalVehicle', RemoveInteractionGlobalVehicle)
exports('RemoveInteractionGlobalPed', RemoveInteractionGlobalPed)
exports('RemoveInteractionGlobalPlayer', RemoveInteractionGlobalPlayer)
exports('RemoveAllGlobalInteractions', RemoveAllGlobalInteractions)