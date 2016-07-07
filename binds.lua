Bind = class()
function Bind:init(scancode, position, size) {
    self.scancode = scancode
    self.position = position or vector(0, 0)
    self.size = size or vector(1, 1)
}
function Bind:update()
end
function Bind:draw()

Binds = class()
function Binds:init(position, scale, pivot) {
    self.position = position or vector(0, 0)
    self.scale = scale or 1
    self.pivot = pivot or vector(0.5, 1)
    self.binds = {}

    table.insert(self.binds, Bind("escape", vector(0, 0), vector(1, 1)))
    for i = 1, 12 do table.insert(self.binds, Bind("f"..i, vector(2 + i + math.floor(i / 4) * 0.5, 0), vector(1, 1))) end
    local s = "`1234567890-+" for i = 1, #s do table.insert(self.binds, Bind(s:sub(i, i), vector(i, 1), vector(1, 1))) end
    table.insert(self.binds, Bind("backspace", vector(0, 1), vector(2, 1)))
    table.insert(self.binds, Bind("tab", vector(0, 2), vector(1.5, 1)))
    s = "qwertyuiop[]" for i = 1, #s do table.insert(self.binds, Bind(s:sub(i, i), vector(1.5 + i, 2), vector(1, 1))) end
    table.insert(self.binds, Bind("\\", vector(13.5, 2), vector(1.5, 1)))
    table.insert(self.binds, Bind("capslock", vector(0, 3), vector(1.8, 1)))
    s = "asdfghjkl;'" for i = 1, #s do table.insert(self.binds, Bind(s:sub(i, i), vector(1.8 + i, 3), vector(1, 1))) end
    table.insert(self.binds, Bind("return", vector(12.8, 3), vector(2.2, 1)))
    table.insert(self.binds, Bind("lshift", vector(0, 4), vector(2.1, 1)))
    s = "zxcvbnm,./" for i = 1, #s do table.insert(self.binds, Bind(s:sub(i, i), vector(2.1 + i, 3), vector(1, 1))) end
    table.insert(self.binds, Bind("rshift", vector(12.1, 4), vector(2.9, 1)))
    table.insert(self.binds, Bind("lctrl", vector(0, 4), vector(1.3, 1)))
    table.insert(self.binds, Bind("lgui", vector(1.3, 4), vector(1.3, 1)))
    table.insert(self.binds, Bind("lalt", vector(2.6, 4), vector(1.3, 1)))
    table.insert(self.binds, Bind("space", vector(3.9, 4), vector(7.2, 1)))
    table.insert(self.binds, Bind("ralt", vector(11.1, 4), vector(1.3, 1)))
    table.insert(self.binds, Bind("rgui", vector(12.4, 4), vector(1.3, 1)))
    table.insert(self.binds, Bind("rctrl", vector(13.7, 4), vector(1.3, 1)))
}

function Binds:update() {

}
function Binds:draw() {

}