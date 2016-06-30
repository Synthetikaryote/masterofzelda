Enemy = class(Character)
function Enemy:init(id, sprite, hp, moveSpeed, detectDist, attackDist)
    Character.init(self, id, sprite, hp, moveSpeed)
    self.detectDist = detectDist
    self.attackDist = attackDist
    leftXOffset = math.max(leftXOffset, detectDist + biggestPivotWidth)
    rightXOffset = math.max(rightXOffset, detectDist)
    topYOffset = math.max(topYOffset, detectDist + biggestPivotHeight)
    bottomYOffset = math.max(bottomYOffset, detectDist)
end
function Enemy:update()
    local dx = player.p.x - self.p.x
    local dy = player.p.y - self.p.y
    local distSq = dx * dx + dy * dy
    if distSq < self.detectDist * self.detectDist then -- 300 dist
        local dist = math.sqrt(distSq)
        local distInv = 1 / dist
        local vx = dx * distInv
        local vy = dy * distInv
        self.aniDir = self.sprite:getAniDirFromAngle(math.atan2(vy, -vx))
        local lastAniName = self.animationName
        if dist < self.attackDist then
            self.animationName = "attack"
        elseif dist < self.detectDist then
            self.animationName = "walk"
            local mult = self.moveSpeed * love.timer.getDelta() * timeScale
            self:move(Vector(self.p.x + vx * mult, self.p.y + vy * mult))
        else
            self.animationName = "walk"
            self.aniFrame = 0
            self.aniLastChange = love.timer.getTime() * timeScale
        end

        if lastAniName ~= self.animationName then
            self.aniFrame = 0
        end

        Character.update(self)
    end
end
function Enemy:earlyDraw()
    if showAggro then
        local animation = self.sprite.animations[self.animationName]
        local x = mapP.x + self.p.x
        local y = mapP.y + self.p.y
        love.graphics.setColor(255, 0, 0, 255)
        love.graphics.circle("line", x, y, self.detectDist, 40)
        love.graphics.setColor(255, 0, 0, 50)
        love.graphics.circle("fill", x, y, self.detectDist, 40)
        love.graphics.setColor(255, 255, 255, 255)
    end
    Character.earlyDraw()
end
function Enemy:draw()
    Character.draw(self)
end