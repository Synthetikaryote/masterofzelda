Enemy = class(Character)
function Enemy:init(id, sprite, hp, moveSpeed, invincibilityTime, attackDist, attackDamage, attackDamageTime, collisionDist, detectDist, collisionDamage, pursueDist, startAttackDist)
    Character.init(self, id, sprite, hp, moveSpeed, invincibilityTime, attackDist, attackDamage, attackDamageTime)
    self.collisionDist = collisionDist
    self.detectDist = detectDist
    self.collisionDamage = collisionDamage
    self.pursueDist = pursueDist
    self.startAttackDist = startAttackDist
    self.nextPlayerHitTime = 0
    self.nextPlayerHitQueued = false
    leftXOffset = math.max(leftXOffset, detectDist + biggestPivotWidth)
    rightXOffset = math.max(rightXOffset, detectDist)
    topYOffset = math.max(topYOffset, detectDist + biggestPivotHeight)
    bottomYOffset = math.max(bottomYOffset, detectDist)
    self.state.type = "Enemy"
end
hits = 0
function Enemy:update()
    local shouldBaseUpdate = false
    if self.state.hp <= 0 then
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
            local dx = player.state.p.x - self.state.p.x
            local dy = player.state.p.y - self.state.p.y
            local distSq = dx * dx + dy * dy
            if distSq < self.detectDist * self.detectDist then
                local dist = math.sqrt(distSq)
                local distInv = 1 / dist
                local vx = dx * distInv
                local vy = dy * distInv
                self.facingDir = math.atan2(vy, vx)
                self.aniDir = self.sprite:getAniDirFromAngle(self.facingDir)
                if player.isAlive and dist < self.collisionDist then
                    hits = hits + 1
                    player:gotHit(self, self.collisionDamage, 0.1, 30, 0)
                    self.nextPlayerHitQueued = false
                end
                local newAniName = nil
                if player.isAlive and dist < self.detectDist and dist >= self.pursueDist then
                    newAniName = "walk"
                    local mult = self.moveSpeed * love.timer.getDelta() * timeScale
                    self:move(vector(self.state.p.x + vx * mult, self.state.p.y + vy * mult))
                else
                    if not player.isAlive or self.animationName ~= "attack" then
                        newAniName = "walk"
                        self.aniLastChange = love.timer.getTime() * timeScale
                    end
                end
                if player.isAlive and dist < self.startAttackDist then
                    newAniName = "attack"
                    if self.animationName ~= "attack" or (self.aniFrame == 0 and self.nextPlayerHitQueued == false) then
                        self.nextPlayerHitTime = (love.timer.getTime() + self.attackDamageTime) * timeScale
                        self.nextPlayerHitQueued = true
                    end
                end
                if newAniName and self.animationName ~= newAniName then
                    self.animationName = newAniName
                    self.aniFrame = 0
                end
                if self.animationName == "attack" then
                    shouldBaseUpdate = true
                    if love.timer.getTime() * timeScale >= self.nextPlayerHitTime and self.nextPlayerHitQueued and dist <= self.attackDist then
                       self.nextPlayerHitQueued = false
                        player:gotHit(self, self.attackDamage, 0.1, 90, 0)
                    end
                end
                shouldBaseUpdate = true
            end
        end
    end
    if shouldBaseUpdate then
        Character.update(self)
    elseif #self.coroutines > 0 then
        Character.updateCoroutines(self)
    end
end
function Enemy:earlyDraw()
    if showAggro then
        local animation = self.sprite.animations[self.animationName]
        local x = mapP.x + self.state.p.x
        local y = mapP.y + self.state.p.y
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