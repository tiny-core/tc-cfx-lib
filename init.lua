--- tc_lib — Copyright (C) 2026 tiny-core
--- Licenciado sob a LGPL-3.0-or-later. Ver LICENSE e licenses/GPL-3.0.txt.
--- Sem QUALQUER GARANTIA, na medida permitida por lei.

--- tc_lib — carregador de módulos com lazy loading.
--- Os módulos só são lidos do disco na primeira vez que são acedidos através de `tc`,
--- para manter o custo de arranque perto de zero em servidores com muitos recursos.

local context = IsDuplicityVersion() and 'server' or 'client'
local resourceName = 'tc_lib'

---@class TcLib
local tc = {
    context = context,
    version = GetResourceMetadata(resourceName, 'version', 0),
}

local loaded = {}

---Carrega um módulo de imports/<nome>/<contexto>.lua, com fallback para shared.lua.
---@param name string
---@return unknown?
local function loadModule(name)
    local candidates = {
        ('imports/%s/%s.lua'):format(name, context),
        ('imports/%s/shared.lua'):format(name),
    }

    for _, file in ipairs(candidates) do
        local source = LoadResourceFile(resourceName, file)

        if source then
            -- O chunkname com @ dá stack traces legíveis no console do servidor.
            local chunk, err = load(source, ('@@%s/%s'):format(resourceName, file), 't')
            if not chunk then error(('erro ao carregar %s: %s'):format(file, err), 2) end
            return chunk()
        end
    end
end

setmetatable(tc, {
    __index = function(self, name)
        if loaded[name] ~= nil then return loaded[name] or nil end

        local module = loadModule(name)
        loaded[name] = module or false
        rawset(self, name, module)

        return module
    end,
})

_ENV.tc = tc
return tc
