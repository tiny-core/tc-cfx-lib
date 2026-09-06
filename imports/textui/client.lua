--- Texto de ajuda persistente ("Prima E para abrir").
--- Chamar show/hide por eventos, nunca dentro de um loop por tick.

local textui = {}
local shown = false

---@param text string
---@param icon? string
function textui.show(text, icon)
    if shown then return end

    shown = true
    SendNUIMessage({ module = 'textui', action = 'show', payload = { text = text, icon = icon } })
end

function textui.hide()
    if not shown then return end

    shown = false
    SendNUIMessage({ module = 'textui', action = 'hide' })
end

return textui
