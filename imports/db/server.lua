--- Ponte Lua para o tc_db. Devolve resultados de forma síncrona para quem chama,
--- usando promessas por baixo — o thread do recurso nunca fica bloqueado.
---
--- Regra dura: nunca concatenar valores em SQL. Sempre placeholders `?`.

local db = {}

---@param method string
---@param sql string
---@param params? table
---@return any
local function await(method, sql, params)
    local p = promise.new()

    exports.tc_db[method](sql, params or {}):next(function(result)
        p:resolve(result)
    end, function(err)
        tc.logger.error(('%s falhou: %s'):format(method, err))
        p:resolve(nil)
    end)

    return Citizen.Await(p)
end

---Todas as linhas.
---@param sql string
---@param params? table
---@return table[]
function db.query(sql, params) return await('query', sql, params) or {} end

---Primeira linha, ou nil.
---@param sql string
---@param params? table
---@return table?
function db.single(sql, params) return await('single', sql, params) end

---Primeiro valor da primeira linha. Para COUNT, SUM, um único campo.
---@param sql string
---@param params? table
---@return any
function db.scalar(sql, params) return await('scalar', sql, params) end

---@param sql string
---@param params? table
---@return number? insertId
function db.insert(sql, params) return await('insert', sql, params) end

---@param sql string
---@param params? table
---@return number affectedRows
function db.update(sql, params) return await('update', sql, params) or 0 end

---Executa várias consultas de forma atómica.
---@param queries { sql: string, params?: table }[]
---@return boolean ok
function db.transaction(queries)
    local p = promise.new()

    exports.tc_db:transaction(queries):next(function(result)
        p:resolve(result)
    end, function(err)
        tc.logger.error(('transação falhou: %s'):format(err))
        p:resolve(false)
    end)

    return Citizen.Await(p)
end

return db
