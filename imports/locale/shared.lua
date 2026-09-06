--- Sistema multilíngue.
--- Regra do projeto: nenhuma string visível ao jogador existe em código.
--- Lê locales/<tag>.json do recurso chamador, com fallback para inglês.

local FALLBACK = 'en'
local dictionaries = {}

local locale = { current = GetConvar('tc_locale', 'pt-BR') }

---@param resource string
---@param tag string
---@return table<string, string>?
local function readDictionary(resource, tag)
    local raw = LoadResourceFile(resource, ('locales/%s.json'):format(tag))
    return raw and json.decode(raw) or nil
end

---Carrega o dicionário de um recurso. Chamar uma vez no arranque.
---@param resource? string Nome do recurso (por omissão, o atual)
function locale.load(resource)
    resource = resource or GetCurrentResourceName()

    local primary = readDictionary(resource, locale.current)
    local fallback = readDictionary(resource, FALLBACK)

    if not primary and not fallback then
        error(('nenhum ficheiro de locale encontrado em %s/locales'):format(resource))
    end

    dictionaries[resource] = { primary = primary or {}, fallback = fallback or {} }
    return dictionaries[resource]
end

---@param resource string
local function ensure(resource)
    return dictionaries[resource] or locale.load(resource)
end

---Traduz uma chave, com interpolação nomeada: tc.locale.t('shop.bought', { item = 'Pão' })
---@param key string
---@param params? table<string, string|number>
---@return string
function locale.t(key, params)
    local resource = GetInvokingResource() or GetCurrentResourceName()
    local dict = ensure(resource)

    local value = dict.primary[key] or dict.fallback[key]

    -- Devolver a própria chave torna traduções em falta óbvias em teste,
    -- em vez de mostrar uma string vazia ao jogador.
    if not value then return key end

    if params then
        value = value:gsub('%%{(%w+)}', function(name)
            return params[name] ~= nil and tostring(params[name]) or ('%{' .. name .. '}')
        end)
    end

    return value
end

---Dicionário completo para enviar à NUI (evita duplicar traduções no front-end).
---@return table<string, string>
function locale.dump()
    local dict = ensure(GetInvokingResource() or GetCurrentResourceName())
    local merged = {}

    for k, v in pairs(dict.fallback) do merged[k] = v end
    for k, v in pairs(dict.primary) do merged[k] = v end

    return merged
end

return locale
