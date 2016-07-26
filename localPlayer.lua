require "build"
local newAniDir = 0
local deg = 0

local dirData = {
    {"up", vector(0, -1)},
    {"left", vector(-1, 0)},
    {"down", vector(0, 1)},
    {"right", vector(1, 0)}
}
local gamepadDirData = {
    {"dpup", vector(0, -1)},
    {"dpleft", vector(-1, 0)},
    {"dpdown", vector(0, 1)},
    {"dpright", vector(1, 0)}
}

LocalPlayer = class(Player)
function LocalPlayer:init(id, sprite, hp, moveSpeed, invincibilityTime, attackDist, attackDamage, attackDamageTime)
    Player.init(self, id, sprite, hp, moveSpeed, invincibilityTime, attackDist, attackDamage, attackDamageTime)

    local arrow = love.graphics.newImage("assets/ability icons/arrow512.png")
    abilities["up"] = Ability("up", arrow)
    abilities["up"].rotation = -math.pi * 0.5
    binds.binds["e"].ability = abilities["up"]
    binds.binds["up"].ability = abilities["up"]
    abilities["left"] = Ability("left", arrow)
    abilities["left"].rotation = -math.pi
    binds.binds["s"].ability = abilities["left"]
    binds.binds["left"].ability = abilities["left"]
    abilities["down"] = Ability("left", arrow)
    abilities["down"].rotation = math.pi * 0.5
    binds.binds["d"].ability = abilities["down"]
    binds.binds["down"].ability = abilities["down"]
    abilities["right"] = Ability("right", arrow)
    binds.binds["f"].ability = abilities["right"]
    binds.binds["right"].ability = abilities["right"]
    local spear = love.graphics.newImage("assets/ability icons/sword.png")
    abilities["attack"] = Ability("attack", spear, function() player:attack() end)
    binds.binds["space"].ability = abilities["attack"]
    binds.binds["lmb"].ability = abilities["attack"]
    binds.binds["rmb"].ability = abilities["attack"]
end
function LocalPlayer:update()
    self.moving = false
    if self.isAlive then
        local gamepad = love.joystick.getJoysticks()[1]
        local jx, jy = gamepad and gamepad:getGamepadAxis("leftx") or 0, gamepad and gamepad:getGamepadAxis("lefty") or 0
        if math.abs(jx) < 0.06 then jx = 0 else jx = (jx - 0.06) / (1 - 0.06) end
        if math.abs(jy) < 0.06 then jy = 0 else jy = (jy - 0.06) / (1 - 0.06) end
        self.v = gamepad and vector(jx, jy) or vector(0, 0)
        for k, data in pairs(dirData) do
            local ability, dv = data[1], data[2]
            if abilities[ability] and abilities[ability].pressed then
                self.v = self.v + dv
            end
        end
        for k, data in pairs(gamepadDirData) do
            local button, dv = data[1], data[2]
            if gamepads[1] then
                if gamepads[1][button] then
                    self.v = self.v + dv
                end
            end
        end
        local len = self.v:len()
        if len > 0 then
            self.moving = true
            if len > 1 then self.v = self.v / len end
            local running = keyboard["lshift"] or keyboard["rshift"] or gamepad and gamepad:getGamepadAxis("triggerright") > 0.05
            self.v = self.v * self.moveSpeed * love.timer.getDelta() * timeScale * (running and 10 or 1)
        end
    end

    Player.update(self)
end
function LocalPlayer:draw()
    Player.draw(self)
end
function LocalPlayer:attack()
    Player.attack(self)
end
