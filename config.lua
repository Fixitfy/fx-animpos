Config = {}
Config.Language = "en"
Config.Framework = "VORP" -- RSG
Config.Locale = {
    ["en"] = {
        ["active_menu"] = "AnimPos The menu is already open!",

    }
}

Config.KeyBinds = {
    ["W"] = 0x8FD015D8,
    ["A"] = 0x7065027D,
    ["S"] = 0xD27782E3,
    ["D"] = 0xB4E465B4,
    ["Q"] = 0xDE794E3E,
    ["E"] = 0xCEFD9220,
    ["ALT"] = 0x8AAA0AD4,
    ["ENTER"] = 0x2CD5343E,
    ["ESC"] = 0x156F7119,
}


Config.HideHud = function()
    -- exports['fx-hud']:hideHud()
end
Config.ShowHud = function()
    -- exports['fx-hud']:showHud()
end

local isServer = IsDuplicityVersion()

function Notify(data)
    local text = data.text
    local time = data.time
    local type = data.type
    local dict = data.dict
    local icon = data.icon
    local color = data.color
    local core = Config.Framework
    if isServer then
        local src = data.source
        if core == "RSG" then
            RSGCore.Functions.Notify(src, text, type)
        elseif core == "VORP" then
            if icon then
                TriggerClientEvent('vorp:ShowAdvancedRightNotification', src, text,dict,icon,color,time)            
            else
                TriggerClientEvent("vorp:TipBottom",src, text, time, type)
            end
        end
    else
        if core == "RSG" then
            RSGCore.Functions.Notify(text, type)
        elseif core == "VORP" then
            if icon then
                TriggerEvent("vorp:ShowAdvancedRightNotification", text,dict,icon,color,time)
            else
                TriggerEvent("vorp:TipBottom", text, time, type)
            end
        end
    end
end

function Locale(key,subs)
    local translate = Config.Locale[Config.Language][key] and Config.Locale[Config.Language][key] or "Config.Locale["..Config.Language.."]["..key.."] doesn't exits"
    subs = subs and subs or {}
    for k, v in pairs(subs) do
        local templateToFind = '%${' .. k .. '}'
        translate = translate:gsub(templateToFind, tostring(v))
    end
    return tostring(translate)
end