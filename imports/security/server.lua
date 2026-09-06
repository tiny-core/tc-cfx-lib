--- Camada de segurança para eventos de servidor.
--- Cada evento acionável pelo jogador passa por aqui antes de tocar em estado ou BD.

local logger = tc.logger
local security = {}

-- Guarda o último uso por (source, chave). Limpo quando o jogador sai.
local lastUse = {}

AddEventHandler('playerDropped', function()
    lastUse[source] = nil
end)

---Rate limit por jogador e por ação.
---@param src number
---@param key string Identificador da ação (ex.: 'garage:store')
---@param cooldown number Intervalo mínimo em ms
---@return boolean allowed
function security.throttle(src, key, cooldown)
    local now = GetGameTimer()
    local byPlayer = lastUse[src]

    if not byPlayer then
        byPlayer = {}
        lastUse[src] = byPlayer
    end

    if byPlayer[key] and now - byPlayer[key] < cooldown then
        logger.warn(('rate limit: %s (%s) em %s'):format(GetPlayerName(src) or '?', src, key))
        return false
    end

    byPlayer[key] = now
    return true
end

---Valida os argumentos de um evento contra um esquema de tipos.
---Uso: security.validate({ plate, amount }, { 'string', 'number' })
---@param values any[]
---@param schema string[]
---@return boolean ok
function security.validate(values, schema)
    for i = 1, #schema do
        local expected = schema[i]
        local value = values[i]

        if expected:sub(-1) == '?' then
            if value ~= nil and type(value) ~= expected:sub(1, -2) then return false end
        elseif type(value) ~= expected then
            return false
        end
    end

    return true
end

---Verifica se o jogador está suficientemente perto de um ponto do mundo.
---Impede que um cliente modificado dispare ações à distância.
---@param src number
---@param target vector3
---@param radius? number Metros (por omissão 5.0)
---@return boolean
function security.isNear(src, target, radius)
    local ped = GetPlayerPed(src)
    if ped == 0 then return false end

    return #(GetEntityCoords(ped) - target) <= (radius or 5.0)
end

---Wrapper que aplica identidade, throttle e validação de uma só vez.
---@param name string Nome do evento (sem prefixo de recurso)
---@param options { cooldown?: number, schema?: string[] }
---@param handler fun(src: number, ...): any
function security.on(name, options, handler)
    local eventName = ('%s:%s'):format(GetCurrentResourceName(), name)

    RegisterNetEvent(eventName, function(...)
        -- `source` vem sempre do runtime; nunca de um parâmetro do cliente.
        local src = source

        if options.cooldown and not security.throttle(src, name, options.cooldown) then return end

        if options.schema and not security.validate({ ... }, options.schema) then
            logger.warn(('payload inválido em %s vindo de %s'):format(eventName, src))
            return
        end

        handler(src, ...)
    end)
end

return security
