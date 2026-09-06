--- Utilitários partilhados. Tudo aqui é puro: sem estado, sem natives caros.

local utils = {}

---Gera um identificador único para correlacionar pedidos e respostas.
---@return string
function utils.uid()
    return ('%x%x'):format(GetGameTimer(), math.random(0, 0xFFFFFF))
end

---Cópia profunda. Necessária sempre que se entrega config a código de terceiros.
---@generic T
---@param source T
---@return T
function utils.deepCopy(source)
    if type(source) ~= 'table' then return source end

    local copy = {}
    for key, value in pairs(source) do copy[key] = utils.deepCopy(value) end

    return setmetatable(copy, getmetatable(source))
end

---Remove espaços nas pontas e limita o comprimento. Usar em tudo o que vem do jogador.
---@param value any
---@param maxLength? number
---@return string?
function utils.sanitize(value, maxLength)
    if type(value) ~= 'string' then return nil end

    local trimmed = value:gsub('^%s+', ''):gsub('%s+$', '')
    if #trimmed == 0 then return nil end

    return trimmed:sub(1, maxLength or 255)
end

---Arredonda com casas decimais.
---@param value number
---@param decimals? number
---@return number
function utils.round(value, decimals)
    local factor = 10 ^ (decimals or 0)
    return math.floor(value * factor + 0.5) / factor
end

---Executa fn e devolve (ok, resultado|erro), sem rebentar o thread do recurso.
---@param fn function
---@param ... any
---@return boolean ok, any result
function utils.try(fn, ...)
    return pcall(fn, ...)
end

return utils
