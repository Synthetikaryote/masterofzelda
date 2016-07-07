Bind = class()
function Bind:init(scancode, position, size, text)
    self.scancode = scancode
    self.position = position or vector(0, 0)
    self.size = size or vector(1, 1)
    self.text = text or self.scancode
    self.lit = false
end
function Bind:update()
    self.lit = keyboard[self.scancode]
end
function Bind:draw(position, scale, font)
    local scaledSize = self.size * scale - vector(3, 3)
    local pos = position + self.position * scale
    local r = 0.1 * scale
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle(self.lit and "fill" or "line", pos.x, pos.y, scaledSize.x, scaledSize.y, r, r, 4)
    local textPos = vector(math.floor(pos.x + 4), math.floor(pos.y + 4))
    love.graphics.setFont(font)
    n = self.lit and 0 or 255
    love.graphics.setColor(n, n, n)
    love.graphics.print(self.text, textPos.x, textPos.y)
end

Binds = class()
function Binds:init(position, scale, pivot, font)
    self.position = position or vector(0, 0)
    self.scale = scale or 1
    self.pivot = pivot or vector(0.5, 1)
    self.binds = {}
    self.font = font

    table.insert(self.binds, Bind("escape", vector(0, 0), vector(1, 1), "esc"))
    for i = 1, 12 do table.insert(self.binds, Bind("f"..i, vector(2 + i + math.floor((i - 1) / 4) * 0.5 - 1, 0), vector(1, 1))) end
    local s = "`1234567890-+" for i = 1, #s do table.insert(self.binds, Bind(s:sub(i, i), vector(i - 1, 1), vector(1, 1))) end
    table.insert(self.binds, Bind("backspace", vector(13, 1), vector(2, 1)))
    table.insert(self.binds, Bind("tab", vector(0, 2), vector(1.5, 1)))
    s = "qwertyuiop[]" for i = 1, #s do table.insert(self.binds, Bind(s:sub(i, i), vector(1.5 + i - 1, 2), vector(1, 1))) end
    table.insert(self.binds, Bind("\\", vector(13.5, 2), vector(1.5, 1)))
    table.insert(self.binds, Bind("capslock", vector(0, 3), vector(1.8, 1)))
    s = "asdfghjkl;'" for i = 1, #s do table.insert(self.binds, Bind(s:sub(i, i), vector(1.8 + i - 1, 3), vector(1, 1))) end
    table.insert(self.binds, Bind("return", vector(12.8, 3), vector(2.2, 1)))
    table.insert(self.binds, Bind("lshift", vector(0, 4), vector(2.1, 1)))
    s = "zxcvbnm,./" for i = 1, #s do table.insert(self.binds, Bind(s:sub(i, i), vector(2.1 + i - 1, 4), vector(1, 1))) end
    table.insert(self.binds, Bind("rshift", vector(12.1, 4), vector(2.9, 1)))
    table.insert(self.binds, Bind("lctrl", vector(0, 5), vector(1.3, 1)))
    table.insert(self.binds, Bind("lgui", vector(1.3, 5), vector(1.3, 1)))
    table.insert(self.binds, Bind("lalt", vector(2.6, 5), vector(1.3, 1)))
    table.insert(self.binds, Bind("space", vector(3.9, 5), vector(7.2, 1)))
    table.insert(self.binds, Bind("ralt", vector(11.1, 5), vector(1.3, 1)))
    table.insert(self.binds, Bind("rgui", vector(12.4, 5), vector(1.3, 1)))
    table.insert(self.binds, Bind("rctrl", vector(13.7, 5), vector(1.3, 1)))

    self.size = vector(15, 6) * self.scale
    self.offset = vector(-self.size.x * self.pivot.x, -self.size.y * self.pivot.y)
end

function Binds:update()
    for k, v in ipairs(self.binds) do
        v:update()
    end
end
function Binds:draw()
    local pos = self.position + self.offset
    for k, v in ipairs(self.binds) do
        v:draw(pos, self.scale, self.font)
    end
    love.graphics.setColor(255, 255, 255)
end