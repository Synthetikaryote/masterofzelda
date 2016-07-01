Enemy = class(Character)
function Enemy:init(id, sprite, hp, moveSpeed, invincibilityTime, attackDist, attackDamage, attackDamageTime, collisionDist, detectDist, collisionDamage)
    Character.init(self, id, sprite, hp, moveSpeed, invincibilityTime, attackDist, attackDamage, attackDamageTime)
    self.collisionDist = collisionDist
    self.detectDist = detectDist
    self.collisionDamage = collisionDamage
    self.nextPlayerHitTime = 0
    self.nextPlayerHitQueued = false
    leftXOffset = math.max(leftXOffset, detectDist + biggestPivotWidth)
    rightXOffset = math.max(rightXOffset, detectDist)
    topYOffset = math.max(topYOffset, detectDist + biggestPivotHeight)
    bottomYOffset = math.max(bottomYOffset, detectDist)
end
hits = 0
function Enemy:update()
    local shouldBaseUpdate = #self.coroutines > 0
    if self.hp <= 0 then
        if self.animationName ~= "death" then
            self.animationName = "death"
            self.aniDir = 1
            self.aniFrame = 0
            self.aniLooping = false
            self.isAlive = false
            local animation = self.sprite.animations[self.animationName]
            local aniDuration = animation[2] * (1 / animation[3])
            self.despawnTime = (love.timer.getTime() + aniDuration * 2) * timeScale
            self.despawnQueued = true
        end
        shouldBaseUpdate = true
    else
        if love.timer.getTime() * timeScale >= self.stunEndTime then
            local dx = player.p.x - self.p.x
            local dy = player.p.y - self.p.y
            local distSq = dx * dx + dy * dy
            if distSq < self.detectDist * self.detectDist then
                local dist = math.sqrt(distSq)
                local distInv = 1 / dist
                local vx = dx * distInv
                local vy = dy * distInv
                self.facingDir = math.atan2(vy, vx)
                self.aniDir = self.sprite:getAniDirFromAngle(self.facingDir)
                local lastAniName = self.animationName
                if dist < self.collisionDist then
                    hits = hits + 1
                    player:gotHit(self, self.collisionDamage, 0.1, 30, 0)
                    self.nextPlayerHitQueued = false
                elseif dist < self.attackDist then
                    if self.animationName ~= "attack" or (self.aniFrame == 0 and self.nextPlayerHitQueued == false) then
                        self.animationName = "attack"
                        self.nextPlayerHitTime = (love.timer.getTime() + self.attackDamageTime) * timeScale
                        self.nextPlayerHitQueued = true
                    end
                    if love.timer.getTime() * timeScale >= self.nextPlayerHitTime and self.nextPlayerHitQueued then
                       self.nextPlayerHitQueued = false
                        player:gotHit(self, self.attackDamage, 0.1, 90, 0)
                    end
                elseif dist < self.detectDist then
                    self.nextPlayerHitQueued = false
                    self.animationName = "walk"
                    local mult = self.moveSpeed * love.timer.getDelta() * timeScale
                    self:move(Vector(self.p.x + vx * mult, self.p.y + vy * mult))
                else
                    self.nextPlayerHitQueued = false
                    self.animationName = "walk"
                    self.aniFrame = 0
                    self.aniLastChange = love.timer.getTime() * timeScale
                end
                if lastAniName ~= self.animationName then
                    self.aniFrame = 0
                end
                shouldBaseUpdate = true
            end
        end
    end
    if shouldBaseUpdate then
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
    Character.earlyDraw(self)
end
function Enemy:draw()
    Character.draw(self)
end