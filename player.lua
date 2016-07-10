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

Player = class(Character)
function Player:init(id, sprite, hp, moveSpeed, invincibilityTime, attackDist, attackDamage, attackDamageTime)
    Character.init(self, id, sprite, hp, moveSpeed, invincibilityTime, attackDist, attackDamage, attackDamageTime)
    self.nextHitTime = 0
    self.nextHitQueued = false
    self.killCount = 0
    self.deaths = 0
    self.respawnTime = 0
    self.respawnQueued = false
end
function Player:update()
    if self.hp <= 0 then
        if self.animationName ~= "death" then
            self.animationName = "death"
            self.aniDir = 1
            self.aniFrame = 0
            self.aniLooping = false
            self.isAlive = false
            local animation = self.sprite.animations[self.animationName]
            local aniDuration = animation[2] * (1 / animation[3])
            self.respawnTime = (love.timer.getTime() + aniDuration * 2) * timeScale
            self.respawnQueued = true
        end
    end
    if self.respawnQueued and love.timer.getTime() * timeScale >= self.respawnTime and #self.coroutines == 0 then
        self:move(vector(5088, 4000))
        self.hp = self.maxHp
        self.deaths = self.deaths + 1
        self.respawnQueued = false
        self.isAlive = true
        self.aniLooping = true
    end

    if self.isAlive then
        local gamepad = love.joystick.getJoysticks()[1]
        local jx, jy = gamepad and gamepad:getGamepadAxis("leftx") or 0, gamepad and gamepad:getGamepadAxis("lefty") or 0
        if math.abs(jx) < 0.06 then jx = 0 else jx = (jx - 0.06) / (1 - 0.06) end
        if math.abs(jy) < 0.06 then jy = 0 else jy = (jy - 0.06) / (1 - 0.06) end
        local v = gamepad and vector(jx, jy) or vector(0, 0)
        local moving = false
        for k, data in pairs(dirData) do
            local ability, dv = data[1], data[2]
            if abilities[ability] and abilities[ability].pressed then
                v = v + dv
            end
        end
        for k, data in pairs(gamepadDirData) do
            local button, dv = data[1], data[2]
            if gamepads[1] then
                if gamepads[1][button] then
                    v = v + dv
                end
            end
        end
        local len = v:len()
        if len > 0 then
            moving = true
            if len > 1 then v = v / len end
            local running = keyboard["lshift"] or keyboard["rshift"] or gamepad and gamepad:getGamepadAxis("triggerright") > 0.05
            v = v * self.moveSpeed * love.timer.getDelta() * timeScale * (running and 10 or 1)
            self:move(self.p + v)
        end

        if love.timer.getTime() * timeScale <= self.attackEnds then
            if self.nextHitQueued == true and love.timer.getTime() * timeScale >= self.nextHitTime then
                self.nextHitQueued = false
                local animation = self.sprite.animations[self.animationName]
                visitCharsInRadius(vector(self.p.x + self.attackDist * 0.3 * math.cos(self.facingDir), self.p.y + self.attackDist * 0.5 * math.sin(self.facingDir)), self.attackDist * 0.7, function(c)
                    if c ~= self then
                        local wasAlive = c.isAlive
                        c:gotHit(self, self.attackDamage, 0.5, 90, 0.5)
                        if wasAlive and c.hp <= 0 then
                            self.killCount = self.killCount + 1
                        end
                    end
                end)
            end
        elseif moving then
            self.nextHitQueued = false
            self.animationName = "walk"
        else
            self.nextHitQueued = false
            self.animationName = "walk"
            self.aniFrame = 0
            self.aniLastChange = love.timer.getTime() * timeScale
        end

        -- vector direction converted to an angle and mapped to the directions in the sprite
        if moving and self.animationName ~= "polearm" then
            self.facingDir = math.atan2(v.y, v.x)
            self.aniDir = self.sprite:getAniDirFromAngle(self.facingDir)
        end
    end

    Character.update(self)
end
function Player:draw()
    Character.draw(self)
end
function Player:keypressed(key, scancode, isRepeat)
    self:checkInput(scancode, nil)
end
function Player:gamepadpressed(gamepad, button)
    self:checkInput(nil, button)
end
function Player:checkInput(scancode, button)
end
function Player:attack()
    if self.isAlive and self.animationName ~= "polearm" then
        self.animationName = "polearm"
        self.aniFrame = 0
        if self.nextHitQueued == false then
            self.nextHitTime = (love.timer.getTime() + self.attackDamageTime) * timeScale
            self.nextHitQueued = true
        end
        local animation = self.sprite.animations[self.animationName]
        local aniDuration = animation[2] * (1 / animation[3])
        self.attackEnds = (love.timer.getTime() + aniDuration) * timeScale
    end
end
