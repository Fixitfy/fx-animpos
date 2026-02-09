RegisterNetEvent("fx-animpos:server:syncPlayer", function(coords, heading, alpha)
    local src = source
    TriggerClientEvent("fx-animpos:client:syncPlayer", -1, src, coords, heading, alpha)
end)
