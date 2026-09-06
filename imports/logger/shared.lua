--- Logger com níveis e prefixo por recurso.
--- Substitui o `print` cru: em produção o nível vem da convar `tc_log_level`.

local LEVELS = { debug = 1, info = 2, warn = 3, error = 4 }
local COLORS = { debug = '^7', info = '^5', warn = '^3', error = '^1' }

local threshold = LEVELS[GetConvar('tc_log_level', 'info')] or LEVELS.info

local logger = {}

local function write(level, ...)
    if LEVELS[level] < threshold then return end

    local parts = {}
    for i = 1, select('#', ...) do
        local value = select(i, ...)
        parts[i] = type(value) == 'table' and json.encode(value) or tostring(value)
    end

    print(('%s[%s]^7 [%s] %s'):format(
        COLORS[level], level:upper(),
        GetInvokingResource() or GetCurrentResourceName(),
        table.concat(parts, ' ')
    ))
end

function logger.debug(...) write('debug', ...) end
function logger.info(...) write('info', ...) end
function logger.warn(...) write('warn', ...) end
function logger.error(...) write('error', ...) end

return logger
