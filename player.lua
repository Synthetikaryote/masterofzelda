local newAniDir = 0
local deg = 0

Player = class(Character)
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
        self.aniDir = self.sprite:getAniDirFromAngle(math.atan2(v.y, -v.x))
        if len > 1 then v = v / len end
        v = v * self.moveSpeed * love.timer.getDelta() * timeScale * ((keyboard["lshift"] or keyboard["rshift"]) and 10 or 1)
        self:move(self.p + v)
    end

    if love.timer.getTime() * timeScale <= self.attackEnds then
        self.animationName = "polearm"
    elseif moving then
        self.animationName = "walk"
    else
        self.animationName = "walk"
        self.aniFrame = 0
        self.aniLastChange = love.timer.getTime() * timeScale
    end

    Character.update(self)
end
function Player:draw()
    Character.draw(self)

    love.graphics.print("aniDir "..(newAniDir or "nil").." deg "..deg)
end
function Player:keypressed(key, scancode, isRepeat)
    if scancode == "space" then
        self.animationName = "polearm"
        local animation = self.sprite.animations[self.animationName]
        local aniDuration = animation[2] * (1 / animation[3])
        self.attackEnds = (love.timer.getTime() + aniDuration) * timeScale
    end
end