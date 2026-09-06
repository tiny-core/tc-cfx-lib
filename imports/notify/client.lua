--- Notificações próprias, desenhadas na NUI do tc_lib.
--- Um único recurso desenha as notificações de todos os produtos: evita cinco
--- NUIs iguais abertas ao mesmo tempo e mantém a identidade visual coerente.

local notify = {}

---@class NotifyOptions
---@field title? string
---@field description string
---@field type? 'info'|'success'|'warning'|'error'
---@field duration? number Milissegundos

---@param options NotifyOptions
function notify.send(options)
    SendNUIMessage({
        module = 'notify',
        action = 'push',
        payload = {
            id = tc.utils.uid(),
            title = options.title,
            description = options.description,
            type = options.type or 'info',
            duration = options.duration or 4000,
        },
    })
end

RegisterNetEvent('tc_lib:notify', function(options)
    -- Evento vindo do servidor: só aceitamos o formato esperado.
    if type(options) ~= 'table' or type(options.description) ~= 'string' then return end
    notify.send(options)
end)

return notify
