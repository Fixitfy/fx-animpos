local isAltPressed = false
local maxDistance = 1.0
local originalPos = nil
local animPos = false

RegisterNetEvent("fx-animpos:client:syncPlayer", function(target, coords, heading, alpha)
    local targetId = GetPlayerFromServerId(target)
    local targetPed = GetPlayerPed(targetId)
    if targetId ~= nil and targetPed ~= nil and PlayerPedId() ~= targetPed then
        FreezeEntityPosition(targetPed, true)
        SetEntityCoordsNoOffset(targetPed, coords.x, coords.y, coords.z, true, true)
        SetEntityHeading(targetPed, heading)
        if alpha == 0 then
            ResetEntityAlpha(targetPed)
        else
            SetEntityAlpha(targetPed, alpha)
        end
    end
end)

function disableControls()
    DisableAllControlActions(0)
    EnableControlAction(0, 0xD2047988, true) 
    EnableControlAction(0, 0xA987235F, true) 
    EnableControlAction(0, 0x156F7119, true) 
end

RegisterCommand("animpos", function (source, args, raw)
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

function animPosition()
    local playerPed = PlayerPedId()
    originalPos = GetEntityCoords(playerPed)  
    local originalHeading = GetEntityHeading(playerPed) 
    local playerCoords = originalPos
    local playerHeading = originalHeading
    FreezeEntityPosition(playerPed, true)
    local posChanged = false
    animPos = not animPos
    Config.HideHud()
    SendNUIMessage({action = "showUI"})

    Citizen.CreateThread(function()
        while animPos do
            for alpha = 50, 255, 5 do
                if not animPos then break end
                SetEntityAlpha(playerPed, alpha, false)
                Citizen.Wait(7) 
            end
            for alpha = 255, 50, -5 do
                if not animPos then break end
                SetEntityAlpha(playerPed, alpha, false)
                Citizen.Wait(7) 
            end
        end
        SetEntityAlpha(playerPed, 255, false)
    end)

    while true do
        disableControls()
        local tempCoord = GetEntityCoords(playerPed)
        local x = tempCoord.x
        local y = tempCoord.y
        local z = tempCoord.z
        local heading = GetEntityHeading(playerPed)
        local dist = GetDistanceBetweenCoords(playerCoords, tempCoord, true)
        local forwardVector = GetEntityForwardVector(playerPed)
        local rightVector = vector3(forwardVector.y, -forwardVector.x, 0)

        if dist <= maxDistance then
            if IsDisabledControlJustPressed(0, Config.KeyBinds["W"]) then 
                x = x + forwardVector.x * 0.1
                y = y + forwardVector.y * 0.1
                SetEntityCoordsNoOffset(playerPed, x, y, z, true, true)
                SendNUIMessage({action = "presseffect", key = "w"})
                TriggerServerEvent("fx-animpos:server:syncPlayer", vector3(x, y, z), heading, GetEntityAlpha(playerPed))
            end

            if IsDisabledControlJustPressed(0, Config.KeyBinds["S"]) then 
                x = x - forwardVector.x * 0.1
                y = y - forwardVector.y * 0.1
                SetEntityCoordsNoOffset(playerPed, x, y, z, true, true)
                SendNUIMessage({action = "presseffect", key = "s"})
                TriggerServerEvent("fx-animpos:server:syncPlayer", vector3(x, y, z), heading, GetEntityAlpha(playerPed))
            end

            if IsDisabledControlJustPressed(0, Config.KeyBinds["A"]) then 
                x = x - rightVector.x * 0.1
                y = y - rightVector.y * 0.1
                SetEntityCoordsNoOffset(playerPed, x, y, z, true, true)
                SendNUIMessage({action = "presseffect", key = "a"})
                TriggerServerEvent("fx-animpos:server:syncPlayer", vector3(x, y, z), heading, GetEntityAlpha(playerPed))
            end

            if IsDisabledControlJustPressed(0, Config.KeyBinds["D"]) then 
                x = x + rightVector.x * 0.1
                y = y + rightVector.y * 0.1
                SetEntityCoordsNoOffset(playerPed, x, y, z, true, true)
                SendNUIMessage({action = "presseffect", key = "d"})
                TriggerServerEvent("fx-animpos:server:syncPlayer", vector3(x, y, z), heading, GetEntityAlpha(playerPed))
            end

            if IsDisabledControlJustPressed(0, Config.KeyBinds["Q"]) then
                z = z + 0.1
                if z > playerCoords.z + maxDistance then
                    z = playerCoords.z + maxDistance
                end
                SetEntityCoordsNoOffset(playerPed, x, y, z, true, true)
                TriggerServerEvent("fx-animpos:server:syncPlayer", vector3(x, y, z), heading, GetEntityAlpha(playerPed))
            end

            if IsDisabledControlJustPressed(0, Config.KeyBinds["E"]) then
                z = z - 0.1
                if z < playerCoords.z - maxDistance then
                    z = playerCoords.z - maxDistance
                end
                SetEntityCoordsNoOffset(playerPed, x, y, z, true, true)
                TriggerServerEvent("fx-animpos:server:syncPlayer", vector3(x, y, z), heading, GetEntityAlpha(playerPed))
            end

            if IsDisabledControlJustPressed(0, Config.KeyBinds["ENTER"]) then
                posChanged = false
                playerCoords = vector3(x, y, z) 
                playerHeading = heading 
                TriggerServerEvent("fx-animpos:server:syncPlayer", playerCoords, playerHeading, 0)
                SendNUIMessage({action = "hideUI"})
                Config.ShowHud() 
                break
            end

            if IsDisabledControlJustPressed(0, Config.KeyBinds["ESC"]) then
                posChanged = false
                SendNUIMessage({action = "hideUI"})
                Config.ShowHud() 
                local groundZ = playerCoords.z
                local foundGround, zPos = GetGroundZFor_3dCoord(originalPos.x, originalPos.y, originalPos.z + 100.0, true)
                if foundGround then
                    groundZ = zPos
                end
                SetEntityCoords(playerPed, originalPos.x, originalPos.y, groundZ) 
                SetEntityHeading(playerPed, originalHeading) 
                break
            end
        else
            posChanged = false
            playerCoords = vector3(x, y, z) 
            playerHeading = heading 
            TriggerServerEvent("fx-animpos:server:syncPlayer", playerCoords, playerHeading, 0)
            SendNUIMessage({action = "hideUI"})
            Config.ShowHud() 
            break
        end

        Wait(1)
    end

    FreezeEntityPosition(playerPed, false)

    if not posChanged then
        animPos = false
    end
end






AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    posChanged = false
    ResetEntityAlpha(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    SendNUIMessage({action = "hideUI"})
    Config.ShowHud() 
end)