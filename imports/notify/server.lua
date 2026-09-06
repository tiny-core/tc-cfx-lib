--- Envio de notificações a partir do servidor.

local notify = {}

---@param src number
---@param options NotifyOptions
function notify.send(src, options)
    TriggerClientEvent('tc_lib:notify', src, options)
end

return notify
