abilities = {}
Ability = class()
function Ability:init(name, image, func)
    self.image = image
    self.func = func
    self.pressed = false
    self.sizeX, self.sizeY = self.image:getDimensions()
    self.quad = love.graphics.newQuad(0, 0, self.sizeX, self.sizeY, self.sizeX, self.sizeY)
end
function Ability:draw(position, size)
    local scale = math.min(size.x / self.sizeX, size.y / self.sizeY)
    drawScaleRotate(self.image, self.quad, position.x, position.y, scale, self.rotation or 0, size.x * 0.5, size.y * 0.5)
end
function Ability:activate()
    if self.f then self.f() end
end

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
    if self.ability then
        if not self.ability.pressed and self.lit then
            self.ability:activate()
        end
        self.ability.pressed = self.lit
    end
end
function Bind:draw(position, scale)
    local scaledSize = self.size * scale - vector(3, 3)
    local pos = position + self.position * scale

    if self.ability then self.ability:draw(pos, scaledSize) end
    local r = 0.1 * scale
    local n = self.lit and 255 or 0
    love.graphics.setColor(n * 0.1, n * 0.6, n)
    love.graphics.rectangle("line", pos.x, pos.y, scaledSize.x, scaledSize.y, r, r, 4)
    local textPos = vector(math.floor(pos.x + 4), math.floor(pos.y + 4))
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(self.text, textPos.x, textPos.y)
end

Binds = class()
function Binds:init(position, scale, pivot, font)
    self.position = position or vector(0, 0)
    self.scale = scale or 1
    self.pivot = pivot or vector(0.5, 1)
    self.binds = {}
    self.font = font

    self:addBind("escape", vector(0, 0), vector(1, 1), "esc")
    for i = 1, 12 do self:addBind("f"..i, vector(2 + i + math.floor((i - 1) / 4) * 0.5 - 1, 0), vector(1, 1)) end
    local s = "`1234567890-+" for i = 1, #s do self:addBind(s:sub(i, i), vector(i - 1, 1), vector(1, 1)) end
    self:addBind("backspace", vector(13, 1), vector(2, 1))
    self:addBind("tab", vector(0, 2), vector(1.5, 1))
    s = "qwertyuiop[]" for i = 1, #s do self:addBind(s:sub(i, i), vector(1.5 + i - 1, 2), vector(1, 1)) end
    self:addBind("\\", vector(13.5, 2), vector(1.5, 1))
    self:addBind("capslock", vector(0, 3), vector(1.8, 1))
    s = "asdfghjkl;'" for i = 1, #s do self:addBind(s:sub(i, i), vector(1.8 + i - 1, 3), vector(1, 1)) end
    self:addBind("return", vector(12.8, 3), vector(2.2, 1))
    self:addBind("lshift", vector(0, 4), vector(2.1, 1))
    s = "zxcvbnm,./" for i = 1, #s do self:addBind(s:sub(i, i), vector(2.1 + i - 1, 4), vector(1, 1)) end
    self:addBind("rshift", vector(12.1, 4), vector(2.9, 1))
    self:addBind("lctrl", vector(0, 5), vector(1.3, 1))
    self:addBind("lgui", vector(1.3, 5), vector(1.3, 1))
    self:addBind("lalt", vector(2.6, 5), vector(1.3, 1))
    self:addBind("space", vector(3.9, 5), vector(7.2, 1))
    self:addBind("ralt", vector(11.1, 5), vector(1.3, 1))
    self:addBind("rgui", vector(12.4, 5), vector(1.3, 1))
    self:addBind("rctrl", vector(13.7, 5), vector(1.3, 1))

    self.size = vector(15, 6) * self.scale
    self.offset = vector(-self.size.x * self.pivot.x, -self.size.y * self.pivot.y)
end
function Binds:addBind(scancode, position, size, text)
    self.binds[scancode] = Bind(scancode, position, size or vector(1, 1), text or scancode)
end

function Binds:update()
    for k, v in pairs(self.binds) do
        v:update()
    end
end
function Binds:draw()
    love.graphics.setFont(self.font)
    local pos = self.position + self.offset
    for k, v in pairs(self.binds) do
        v:draw(pos, self.scale, self.font)
    end
    love.graphics.setColor(255, 255, 255)
end