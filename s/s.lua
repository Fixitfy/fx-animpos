RegisterNetEvent("fx-animpos:server:syncPlayer", function(coords, heading, alpha)
    local source = source
    TriggerClientEvent("fx-animpos:client:syncPlayer", -1, source, coords, heading, alpha)
end)
