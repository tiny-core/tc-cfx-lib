--- Cache com expiração, para evitar consultas repetidas à base de dados
--- ou natives caros dentro de loops.

local cache = {}
local store = {}

---@param key string
---@param ttl number Tempo de vida em ms
---@param producer fun(): any Executado apenas quando não há valor válido
---@return any
function cache.get(key, ttl, producer)
    local entry = store[key]
    local now = GetGameTimer()

    if entry and now - entry.at < ttl then return entry.value end

    local value = producer()
    store[key] = { value = value, at = now }

    return value
end

---@param key? string Quando omitido, limpa tudo
function cache.invalidate(key)
    if key then store[key] = nil else store = {} end
end

return cache
