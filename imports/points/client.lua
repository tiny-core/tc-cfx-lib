--- Gestor de pontos de proximidade.
--- Um único thread trata de TODOS os pontos de TODOS os recursos, com intervalo
--- adaptativo: longe dorme mais. Substitui o padrão de um `while true Wait(0)`
--- por script, que é a causa nº1 de servidores a 15 ms de client.

local player = tc.player

local points = {}
local registry = {}
local nextId = 0
local threadRunning = false

---@class Point
---@field coords vector3
---@field distance number Raio de ativação em metros
---@field onEnter? fun(self: Point)
---@field onExit? fun(self: Point)
---@field nearby? fun(self: Point) Chamado a cada tick enquanto dentro do raio
---@field isInside boolean

local function tick()
    local playerCoords = GetEntityCoords(player.ped)
    local closest = math.huge

    for _, point in pairs(registry) do
        local distance = #(playerCoords - point.coords)

        if distance < point.distance then
            if not point.isInside then
                point.isInside = true
                if point.onEnter then point.onEnter(point) end
            end

            if point.nearby then point.nearby(point) end
        elseif point.isInside then
            point.isInside = false
            if point.onExit then point.onExit(point) end
        end

        if distance < closest then closest = distance end
    end

    -- Intervalo adaptativo: a 200 m do ponto mais próximo não há nada a fazer.
    if closest < 60 then return 0 end
    if closest < 200 then return 300 end

    return 1000
end

local function startThread()
    if threadRunning then return end
    threadRunning = true

    CreateThread(function()
        while next(registry) do
            Wait(tick())
        end

        threadRunning = false
    end)
end

---@param point Point
---@return number id Usar em points.remove
function points.add(point)
    nextId = nextId + 1

    point.isInside = false
    point.distance = point.distance or 5.0
    registry[nextId] = point

    startThread()

    return nextId
end

---@param id number
function points.remove(id)
    local point = registry[id]
    if point and point.isInside and point.onExit then point.onExit(point) end

    registry[id] = nil
end

-- Sem isto, parar um recurso deixava os pontos dele a correr no thread partilhado.
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    registry = {}
end)

return points
