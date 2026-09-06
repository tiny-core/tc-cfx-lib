--- Atalhos de teclado remapeáveis pelo jogador (menu de definições do FiveM).
--- Nunca usar IsControlJustPressed em loop para atalhos: consome um thread por
--- tecla e ignora as preferências de quem comprou o script.

local keys = {}

---@param name string Identificador único do comando
---@param description string Texto mostrado nas definições do FiveM
---@param defaultKey string Ex.: 'E', 'F5'
---@param onPressed fun()
---@param onReleased? fun()
function keys.register(name, description, defaultKey, onPressed, onReleased)
    local command = ('%s_%s'):format(GetCurrentResourceName(), name)

    RegisterCommand(('+%s'):format(command), onPressed, false)
    RegisterCommand(('-%s'):format(command), onReleased or function() end, false)
    RegisterKeyMapping(('+%s'):format(command), description, 'keyboard', defaultKey)
end

return keys
