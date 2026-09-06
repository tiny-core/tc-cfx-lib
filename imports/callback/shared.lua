--- Callbacks bidirecionais com promessas e timeout, sem dependências externas.
--- Assenta no `promise` e `Citizen.Await` que o runtime Cfx já fornece.
---
--- Porquê timeout: sem ele, um handler que rebenta do outro lado deixa a corrotina
--- do chamador pendurada para sempre e o recurso vai acumulando threads mortos.

local utils = tc.utils
local logger = tc.logger

local isServer = IsDuplicityVersion()
local DEFAULT_TIMEOUT = 10000

local handlers = {}   -- [resource:name] = fn
local pending = {}    -- [requestId] = promise

local callback = {}

local REQUEST = 'tc_lib:callback:request'
local RESPONSE = 'tc_lib:callback:response'

---Resolve a promessa pendente correspondente a um pedido.
local function resolve(requestId, ...)
    local p = pending[requestId]
    if not p then return end

    pending[requestId] = nil
    p:resolve({ ... })
end

---@param key string
---@param requestId string
---@param target number|nil Server ID quando estamos no servidor
local function invoke(key, requestId, target, ...)
    local handler = handlers[key]

    if not handler then
        logger.warn(('callback desconhecido: %s'):format(key))
        return
    end

    local ok, result = pcall(table.pack, handler(target, ...))

    if not ok then
        logger.error(('callback %s falhou: %s'):format(key, result))
        result = table.pack(nil)
    end

    if isServer then
        TriggerClientEvent(RESPONSE, target, requestId, table.unpack(result, 1, result.n))
    else
        TriggerServerEvent(RESPONSE, requestId, table.unpack(result, 1, result.n))
    end
end

if isServer then
    RegisterNetEvent(REQUEST, function(key, requestId, ...)
        invoke(key, requestId, source, ...)
    end)

    RegisterNetEvent(RESPONSE, function(requestId, ...)
        resolve(requestId, ...)
    end)
else
    RegisterNetEvent(REQUEST, function(key, requestId, ...)
        invoke(key, requestId, nil, ...)
    end)

    RegisterNetEvent(RESPONSE, function(requestId, ...)
        resolve(requestId, ...)
    end)
end

---Regista um handler. No servidor, o primeiro argumento recebido é sempre o `src`.
---@param name string Nome sem prefixo; o prefixo do recurso é adicionado automaticamente
---@param handler fun(src: number|nil, ...): any
function callback.register(name, handler)
    handlers[('%s:%s'):format(GetInvokingResource() or GetCurrentResourceName(), name)] = handler
end

---Chama o outro lado e espera pela resposta. Bloqueia apenas a corrotina atual.
---@param name string
---@param target number|nil Server ID (obrigatório no servidor, ignorado no cliente)
---@param ... any
---@return any
function callback.await(name, target, ...)
    local key = ('%s:%s'):format(GetInvokingResource() or GetCurrentResourceName(), name)
    local requestId = utils.uid()
    local p = promise.new()

    pending[requestId] = p

    if isServer then
        TriggerClientEvent(REQUEST, target, key, requestId, ...)
    else
        TriggerServerEvent(REQUEST, key, requestId, ...)
    end

    -- Rede: uma resposta que nunca chega tem de falhar em vez de esperar para sempre.
    SetTimeout(DEFAULT_TIMEOUT, function()
        if not pending[requestId] then return end

        pending[requestId] = nil
        logger.warn(('timeout no callback %s'):format(key))
        p:resolve({})
    end)

    return table.unpack(Citizen.Await(p))
end

return callback
