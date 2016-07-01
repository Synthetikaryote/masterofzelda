local newAniDir = 0
local deg = 0

Player = class(Character)
function Player:init(id, sprite, hp, moveSpeed, invincibilityTime, attackDist, attackDamage, attackDamageTime)
    Character.init(self, id, sprite, hp, moveSpeed, invincibilityTime, attackDist, attackDamage, attackDamageTime)
    self.nextHitTime = 0
    self.nextHitQueued = false
end
function Player:update()
    local joystick = love.joystick.getJoysticks()[1]
    local jx, jy = joystick and joystick:getAxis(1) or 0, joystick and joystick:getAxis(2) or 0
    if math.abs(jx) < 0.06 then jx = 0 else jx = (jx - 0.06) / (1 - 0.06) end
    if math.abs(jy) < 0.06 then jy = 0 else jy = (jy - 0.06) / (1 - 0.06) end
    local v = joystick and Vector(jx, jy) or Vector(0, 0)
    local moving = false
    for k, data in pairs(dirData) do
        local key, dv = data[1], data[2]
        if keyboard[key] then
            v = v + dv
        end
    end
    local len = v:len()
    if len > 0 then
        moving = true
        -- vector direction converted to an angle and mapped to the directions in the sprite
        self.facingDir = math.atan2(v.y, v.x)
        self.aniDir = self.sprite:getAniDirFromAngle(self.facingDir)
        if len > 1 then v = v / len end
        v = v * self.moveSpeed * love.timer.getDelta() * timeScale * ((keyboard["lshift"] or keyboard["rshift"]) and 10 or 1)
        self:move(self.p + v)
    end

    if love.timer.getTime() * timeScale <= self.attackEnds then
        if self.nextHitQueued == true and love.timer.getTime() * timeScale >= self.nextHitTime then
            self.nextHitQueued = false
            local animation = self.sprite.animations[self.animationName]
            visitCharsInRadius(Vector(self.p.x + self.attackDist * 0.5 * math.cos(self.facingDir), self.p.y + self.attackDist * 0.5 * math.sin(self.facingDir)), self.attackDist * 0.5, function(c)
                if c ~= self then
                    c:gotHit(self, self.attackDamage, 0.5, 90, 0.5)
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

    Character.update(self)
end
function Player:draw()
    Character.draw(self)
end
function Player:keypressed(key, scancode, isRepeat)
    if scancode == "space" then
        if self.animationName ~= "polearm" then
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
end