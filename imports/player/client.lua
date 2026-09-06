--- Estado do jogador local em cache.
--- GetPlayerPed(-1) é barato mas não é grátis: chamá-lo dentro de loops rápidos
--- em cinco recursos diferentes soma. Aqui é atualizado por evento, não por tick.

local player = {
    id = PlayerId(),
    serverId = GetPlayerServerId(PlayerId()),
    ped = PlayerPedId(),
    vehicle = false,
}

local function refresh()
    player.ped = PlayerPedId()

    local vehicle = GetVehiclePedIsIn(player.ped, false)
    player.vehicle = vehicle ~= 0 and vehicle or false
end

-- O ped muda em respawn, troca de modelo e transições de sessão.
AddEventHandler('playerSpawned', refresh)
AddEventHandler('onClientResourceStart', refresh)

CreateThread(function()
    while true do
        -- 500 ms é suficiente: nada depende de saber do veículo no mesmo frame.
        Wait(500)
        refresh()
    end
end)

return player
