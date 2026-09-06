--- Barra de progresso com cancelamento.
--- Bloqueia a corrotina que a chama e devolve true quando completou.

local player = tc.player

local progress = {}
local active = nil

---@class ProgressOptions
---@field label string
---@field duration number Milissegundos
---@field canCancel? boolean
---@field disableMovement? boolean
---@field anim? { dict: string, clip: string }

---@param options ProgressOptions
---@return boolean completed
function progress.start(options)
    if active then return false end

    active = promise.new()

    SendNUIMessage({
        module = 'progress',
        action = 'start',
        payload = { label = options.label, duration = options.duration },
    })

    if options.anim then
        RequestAnimDict(options.anim.dict)
        while not HasAnimDictLoaded(options.anim.dict) do Wait(0) end
        TaskPlayAnim(player.ped, options.anim.dict, options.anim.clip, 3.0, 1.0, -1, 49, 0, false, false, false)
    end

    local finishAt = GetGameTimer() + options.duration
    local cancelled = false

    CreateThread(function()
        while active and GetGameTimer() < finishAt do
            if options.disableMovement then
                DisableControlAction(0, 30, true)  -- movimento esquerda/direita
                DisableControlAction(0, 31, true)  -- movimento frente/trás
            end

            -- Cancelar com a mesma tecla em todos os produtos: previsibilidade.
            if options.canCancel and IsControlJustPressed(0, 202) then
                cancelled = true
                break
            end

            -- Morrer ou entrar em veículo invalida qualquer ação em curso.
            if IsEntityDead(player.ped) then
                cancelled = true
                break
            end

            Wait(0)
        end

        if options.anim then ClearPedTasks(player.ped) end

        SendNUIMessage({ module = 'progress', action = cancelled and 'cancel' or 'finish' })

        local p = active
        active = nil
        p:resolve(not cancelled)
    end)

    return Citizen.Await(active)
end

---Cancela a barra em curso (ex.: o servidor recusou a ação a meio).
function progress.cancel()
    if not active then return end

    SendNUIMessage({ module = 'progress', action = 'cancel' })

    local p = active
    active = nil
    p:resolve(false)
end

return progress
