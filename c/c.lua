local isAltPressed = false
local maxDistance = 0.60
local originalPos = nil
local animPos = false

function disableControls()
    DisableAllControlActions(0)
    EnableControlAction(0, 0xD2047988, true) 
    EnableControlAction(0, 0xA987235F, true) 
    EnableControlAction(0, 0x156F7119, true) 
end

RegisterCommand(Config.OpenCommand, function (source, args, raw)
    if animPos == true then 
        Notify({
            text = Locale("active_menu"),
            time = 4000,
            type = "error",
            dict = "menu_textures",
            icon = "stamp_locked_rank",
            color = "COLOR_PURE_WHITE"
        })
        return 
    end
    animPosition()
end)

local isMouseControlActive = false

RegisterNUICallback('altPressed', function(data, cb)
    if data.active then
        isMouseControlActive = true
        SetNuiFocus(true, true)
    else
        isMouseControlActive = false
        SetNuiFocus(false, false)
        SendNUIMessage({
            action = "deleteIcon",
        })
    end
    cb('ok')
end)


RegisterNUICallback('mouseMove', function(data, cb)
    local playerPed = PlayerPedId()
    local movementX = tonumber(data.movementX)

    if movementX ~= 0 then
        local newHeading = GetEntityHeading(playerPed) + (movementX * 0.5) -- Hareket hızını ayarlamak için bir çarpan kullanın
        SetEntityHeading(playerPed, newHeading)
        TriggerServerEvent("fx-animpos:server:syncPlayer", GetEntityCoords(playerPed), newHeading, GetEntityAlpha(playerPed))
    end

    cb('ok')
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if animPos and IsDisabledControlJustPressed(0, Config.KeyBinds["ALT"]) then
            isMouseControlActive = not isMouseControlActive
            
            if isMouseControlActive then
                SetNuiFocus(true, true)
                SendNUIMessage({action = "showMouseControl"})
                Citizen.CreateThread(function()
                    while isMouseControlActive do
                        local playerPed = PlayerPedId()
                        local pedCoords = GetEntityCoords(playerPed)
                        local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(pedCoords.x, pedCoords.y, pedCoords.z)
                
                        if onScreen then
                            SendNUIMessage({
                                action = "updatePedIconPosition",
                                x = screenX,
                                y = screenY
                            })
                        end
                
                        Citizen.Wait(1)
                    end
                end)
            else
                isMouseControlActive = false
                SetNuiFocus(false, false)
                SendNUIMessage({action = "hideMouseControl"})
            end
        end
    end
end)

local function _awaitShapeResult(handle)
    local retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(handle)
    while retval == 1 do
        Wait(0)
        retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(handle)
    end
    return hit == 1, endCoords, surfaceNormal, entityHit
end

local function isPathClear(ped, targetPos)
    local pCoords = GetEntityCoords(ped)
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(pCoords.x, pCoords.y, pCoords.z + 0.5, targetPos.x, targetPos.y, targetPos.z + 0.5, 1, ped, 7)
    local retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    return hit == 0
end

local function IsSpotBlockedByMap(ped, pos)
    local z = pos.z + 1           
    local r = 0.15                
    local half = 0.15                 

    -- 4 yönde kısa kapsüller (ön-arka, sağ-sol)
    local offsets = {
        vector3( half, 0.0, 0.0),
        vector3(-half, 0.0, 0.0),
        vector3( 0.0,  half, 0.0),
        vector3( 0.0, -half, 0.0),
    }

    for _, off in ipairs(offsets) do
        local p1 = vector3(pos.x - off.x, pos.y - off.y, z)
        local p2 = vector3(pos.x + off.x, pos.y + off.y, z)
        local handle = StartShapeTestCapsule(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, r, 511, ped, 7)
        local hit = _awaitShapeResult(handle)
        if hit then return true end
    end

    local from = GetEntityCoords(ped)
    local handle = StartShapeTestLosProbe(from.x, from.y, from.z + 1, pos.x, pos.y, pos.z + 1, 511, ped, 7)
    local hit = _awaitShapeResult(handle)
    if hit then return true end

    return false
end

function animPosition()
    local playerPed = PlayerPedId()
    originalPos = GetEntityCoords(playerPed)  
    local originalHeading = GetEntityHeading(playerPed) 
    
    animPos = true
    FreezeEntityPosition(playerPed, true)
    Config.HideHud()
    SendNUIMessage({action = "showUI"})

    Citizen.CreateThread(function()
        while animPos do
            for alpha = 50, 255, 5 do
                if not animPos then break end
                SetEntityAlpha(playerPed, alpha, false)
                Citizen.Wait(15)
            end
            for alpha = 255, 50, -5 do
                if not animPos then break end
                SetEntityAlpha(playerPed, alpha, false)
                Citizen.Wait(15)
            end
        end
        ResetEntityAlpha(playerPed)
    end)

    while animPos do
        disableControls()
        local currentCoords = GetEntityCoords(playerPed)
        local forwardVector = GetEntityForwardVector(playerPed)
        local rightVector = vector3(forwardVector.y, -forwardVector.x, 0)

        local function attemptMove(moveVec)
            local targetPos = currentCoords + moveVec
            
            if #(targetPos - originalPos) <= 5.0 then 
                if isPathClear(playerPed, targetPos) then
                    SetEntityCoordsNoOffset(playerPed, targetPos.x, targetPos.y, targetPos.z, true, true, true)
                    
                    FreezeEntityPosition(playerPed, false)
                    Citizen.Wait(2) 
                    
                    if HasEntityCollidedWithAnything(playerPed) then
                        SetEntityCoordsNoOffset(playerPed, currentCoords.x, currentCoords.y, currentCoords.z, true, true, true)
                    else
                        TriggerServerEvent("fx-animpos:server:syncPlayer", targetPos, GetEntityHeading(playerPed), GetEntityAlpha(playerPed))
                    end
                    FreezeEntityPosition(playerPed, true)
                end
            end
        end

        if IsDisabledControlJustPressed(0, Config.KeyBinds["W"]) then 
            attemptMove(forwardVector * 0.1)
            SendNUIMessage({action = "presseffect", key = "w"})
        elseif IsDisabledControlJustPressed(0, Config.KeyBinds["S"]) then 
            attemptMove(forwardVector * -0.1)
            SendNUIMessage({action = "presseffect", key = "s"})
        elseif IsDisabledControlJustPressed(0, Config.KeyBinds["A"]) then 
            attemptMove(rightVector * -0.1)
            SendNUIMessage({action = "presseffect", key = "a"})
        elseif IsDisabledControlJustPressed(0, Config.KeyBinds["D"]) then 
            attemptMove(rightVector * 0.1)
            SendNUIMessage({action = "presseffect", key = "d"})
        elseif IsDisabledControlJustPressed(0, Config.KeyBinds["Q"]) then
            attemptMove(vector3(0, 0, 0.05))
            SendNUIMessage({action = "presseffect", key = "q"})
        elseif IsDisabledControlJustPressed(0, Config.KeyBinds["E"]) then
            attemptMove(vector3(0, 0, -0.05))
            SendNUIMessage({action = "presseffect", key = "e"})
        end

        if IsDisabledControlJustPressed(0, Config.KeyBinds["ENTER"]) then
            animPos = false
            ResetEntityAlpha(playerPed)
            TriggerServerEvent("fx-animpos:server:syncPlayer", GetEntityCoords(playerPed), GetEntityHeading(playerPed), 255)
            break
        end

        if IsDisabledControlJustPressed(0, Config.KeyBinds["ESC"]) then
            animPos = false
            SetEntityCoords(playerPed, originalPos.x, originalPos.y, originalPos.z, true, false, false, true) 
            SetEntityHeading(playerPed, originalHeading) 
            ResetEntityAlpha(playerPed)
            TriggerServerEvent("fx-animpos:server:syncPlayer", originalPos, originalHeading, 255)
            break
        end

        Wait(1)
    end

    -- Cleanup
    animPos = false
    FreezeEntityPosition(playerPed, false)
    ResetEntityAlpha(playerPed)
    SetNuiFocus(false, false)
    SendNUIMessage({action = "hideUI"})
    Config.ShowHud() 
end

RegisterNetEvent("fx-animpos:client:syncPlayer", function(target, coords, heading, alpha)
    if target == GetPlayerServerId(PlayerId()) then return end

    local timeout = GetGameTimer() + 2000
    local targetId = -1
    local targetPed = 0

    while GetGameTimer() < timeout do
        targetId = GetPlayerFromServerId(target)
        if targetId ~= -1 then
            targetPed = GetPlayerPed(targetId)
            if DoesEntityExist(targetPed) then break end
        end
        Wait(0)
    end

    if not DoesEntityExist(targetPed) then return end

    -- FreezeEntityPosition(targetPed, false)
    SetEntityCoords(targetPed, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(targetPed, heading)

    if alpha == 0 then
        ResetEntityAlpha(targetPed)
    else
        SetEntityAlpha(targetPed, alpha)
    end

    -- FreezeEntityPosition(targetPed, true)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    animPos = false
    local ped = PlayerPedId()
    ResetEntityAlpha(ped)
    FreezeEntityPosition(ped, false)
    SetNuiFocus(false, false)
    Config.ShowHud() 
end)