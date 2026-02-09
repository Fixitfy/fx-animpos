Config = {}
Config.Language = "en"
Config.Framework = "VORP" -- RSG
Config.OpenCommand = "animpos"
Config.Locale = {
    ["en"] = {
        ["active_menu"] = "AnimPos The menu is already open!",
        ["wallError"] = "There is a wall/object here. You cannot move to this location!",
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
    if GetResourceState("fx-hud") == "started" then
      exports["fx-hud"]:hideHud()
    end
  end
  
Config.ShowHud = function()
  if GetResourceState("fx-hud") == "started" then
    exports["fx-hud"]:showHud()
  end
end

function Notify(data)
    local text = data.text or "No message" 
    local time = data.time or 5000  
    local type = data.type or "info" 
    local dict = data.dict
    local icon = data.icon
    local color = data.color or 0
    local src = data.source
  
    if IsDuplicityVersion() then
        if Framework == "RSG" then
            text = string.gsub(text, "~.-~", "")
            TriggerClientEvent('ox_lib:notify', src, { title = text, type = type, duration = time })
        elseif Framework == "REDEMRP" then
            text = string.gsub(text, "~.-~", "")
            TriggerClientEvent("redem_roleplay:Tip", src, text, time)
        elseif Framework == "VORP" then
            if icon then
                TriggerClientEvent('vorp:ShowAdvancedRightNotification', src, text, dict, icon, color, time)
            else
                TriggerClientEvent("vorp:TipBottom",src, text, time, type)
            end
        end
    else
        if Framework == "RSG" then
            text = string.gsub(text, "~.-~", "")
            TriggerEvent('ox_lib:notify', { title = text, type = type, duration = time })
        elseif Framework == "REDEMRP" then
            text = string.gsub(text, "~.-~", "")
            TriggerEvent("redem_roleplay:Tip", text, time)
        elseif Framework == "VORP" then
            if icon then
                TriggerEvent("vorp:ShowAdvancedRightNotification", text, dict, icon, color, time)
            else
                TriggerEvent("vorp:TipBottom", text, time, type)
            end
        end
    end
end

function Locale(key, subs)
  local translate = Config.Locale[Config.Language][key] and Config.Locale[Config.Language][key] or "Config.Locale[" .. Config.Language .. "][" .. key .. "] doesn't exist"
  subs = subs and subs or {}
  for k, v in pairs(subs) do
      local templateToFind = '%${' .. k .. '}'
      local safeValue = tostring(v):gsub("%%", "%%%%")
      translate = translate:gsub(templateToFind, safeValue)
  end
  translate = tostring(translate):gsub("%%%%", "%%")
  return tostring(translate)
end