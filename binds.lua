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
    local pos = position + size * 0.5
    local pivotX = math.floor(self.sizeX * 0.5 * scale + 0.5)
    local pivotY = math.floor(self.sizeY * 0.5 * scale + 0.5)
    drawScaleRotate(self.image, self.quad, math.floor(pos.x + 0.5), math.floor(pos.y + 0.5), scale, self.rotation or 0, pivotX, pivotY)
end
function Ability:activate()
    if self.func then self.func() end
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
    local wasLit = self.lit
    self.lit = keyboard[self.scancode]
    if self.ability then
        if not wasLit and self.lit then
            self.ability:activate()
        end
        self.ability.pressed = self.ability.pressed or self.lit
    end
end
function Bind:draw(position, scale)
    local scaledSize = self.size * scale - vector(3, 3)
    local pos = position + self.position * scale
    local r = 0.1 * scale
    local n = self.lit and 255 or 0
    if self.ability then
        love.graphics.setColor(128, 128, 128, 128)
        love.graphics.rectangle("fill", pos.x, pos.y, scaledSize.x, scaledSize.y, r, r, 4)
    end
    love.graphics.setColor(255, 255, 255, 255)
    if self.ability then self.ability:draw(pos, scaledSize) end
    local textPos = vector(math.floor(pos.x + scale * 0.1), math.floor(pos.y + scale * 0.05))
    love.graphics.setColor(255, 255, 255)
    love.graphics.print(self.text, textPos.x, textPos.y)
    love.graphics.setColor(n * 0.1, n * 0.2, n * 0.6)
    love.graphics.rectangle("line", pos.x, pos.y, scaledSize.x, scaledSize.y, r, r, 4)
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

    self:addBind("printscreen", vector(15, 0), vector(1, 1), "prt\nscr")
    self:addBind("scrolllock", vector(16, 0), vector(1, 1), "scroll\nlock")
    self:addBind("pause", vector(17, 0), vector(1, 1), "pau\nbrk")
    self:addBind("insert", vector(15, 1), vector(1, 1))
    self:addBind("home", vector(16, 1), vector(1, 1))
    self:addBind("pageup", vector(17, 1), vector(1, 1), "pgup")
    self:addBind("delete", vector(15, 2), vector(1, 1))
    self:addBind("end", vector(16, 2), vector(1, 1))
    self:addBind("pagedown", vector(17, 2), vector(1, 1), "pgdn")
    self:addBind("up", vector(16, 4), vector(1, 1))
    self:addBind("left", vector(15, 5), vector(1, 1))
    self:addBind("down", vector(16, 5), vector(1, 1))
    self:addBind("right", vector(17, 5), vector(1, 1))

    self:addBind("numlock", vector(18, 1), vector(1, 1), "num\nlock")
    self:addBind("kp/", vector(19, 1), vector(1, 1), "/")
    self:addBind("kp*", vector(20, 1), vector(1, 1), "*")
    self:addBind("kp-", vector(21, 1), vector(1, 1), "-")
    s = "789456123" for i = 1, #s do self:addBind("kp"..s:sub(i, i), vector(18 + (i - 1) % 3, 2 + math.floor((i - 1) / 3)), vector(1, 1), s:sub(i, i)) end
    self:addBind("kp+", vector(21, 2), vector(1, 2), "+")
    self:addBind("kpenter", vector(21, 4), vector(1, 2), "en-\nter")
    self:addBind("kp0", vector(18, 5), vector(2, 1), "0")
    self:addBind("kp.", vector(20, 5), vector(1, 1), ".")

    self:addBind("lmb", vector(23, 1), vector(1, 2), "lmb")
    self:addBind("mmb", vector(24.5, 1.5), vector(1, 1), "mmb")
    self:addBind("rmb", vector(26, 1), vector(1, 2), "rmb")
    self:addBind("wheelup", vector(24.75, 1), vector(0.5, 0.5), "up")
    self:addBind("wheelleft", vector(24, 1.75), vector(0.5, 0.5), "lf")
    self:addBind("wheeldown", vector(24.75, 2.5), vector(0.5, 0.5), "dn")
    self:addBind("wheelright", vector(25.5, 1.75), vector(0.5, 0.5), "rt")


    self.size = vector(27, 6) * self.scale
    self.offset = vector(-self.size.x * self.pivot.x, -self.size.y * self.pivot.y)
end
function Binds:addBind(scancode, position, size, text)
    self.binds[scancode] = Bind(scancode, position, size or vector(1, 1), text or scancode)
end

function Binds:update()
    for k, v in pairs(abilities) do
        v.pressed = false
    end
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