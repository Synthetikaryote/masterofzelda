Character = class()
function Character:init(id, sprite, hp, moveSpeed, invincibilityTime, attackDist, attackDamage, attackDamageTime)
    self.id = id
    self.sprite = sprite
    self.aniDir = 4
    self.aniFrame = 0
    self.aniLastChange = 0
    self.animationName = select(1, next(self.sprite.animations))
    self.hp = hp
    self.moveSpeed = moveSpeed
    self.facingDir = 0
    self.p = Vector(0, 0)
    self.attackEnds = 0
    self.damageEnds = 0
    self.xyMapP = Vector(0, 0)
    self.invincibilityTime = invincibilityTime
    self.nextDamageable = 0
    self.attackDist = attackDist
    self.attackDamage = attackDamage
    self.attackDamageTime = attackDamageTime
    self.damageColorThisFrame = 0
    self.stunEndTime = 0
end
function Character:update()
    local animation = self.sprite.animations[self.animationName]
    if love.timer.getTime() * timeScale - self.aniLastChange > 1 / animation[3] then
        self.aniFrame = (self.aniFrame + 1) % animation[2]
        self.aniLastChange = love.timer.getTime() * timeScale
    end
end
function Character:earlyDraw()
    if showAttackDist then
        local animation = self.sprite.animations[self.animationName]
        local x = mapP.x + self.p.x
        local y = mapP.y + self.p.y
        love.graphics.setColor(0, 0, 255, 255)
        love.graphics.circle("line", x, y, self.attackDist, 40)
        love.graphics.setColor(0, 0, 255, 50)
        love.graphics.circle("fill", x, y, self.attackDist, 40)
        love.graphics.setColor(255, 255, 255, 255)
    end
end
function Character:draw()
    local animation = self.sprite.animations[self.animationName]
    local leftX = mapP.x + self.p.x - animation[7]
    local rightX = leftX + animation[4]
    local topY = mapP.y + self.p.y - animation[8]
    local bottomY = topY + animation[5]
    if rightX >= 0 and leftX < love.graphics.getWidth() and bottomY >= 0 and topY < love.graphics.getHeight() then
        if love.timer.getTime() * timeScale < self.damageEnds then
            self.damageColorThisFrame = math.floor(love.timer.getTime() * 35) % 3
            local offVal = 128
            love.graphics.setColor((self.damageColorThisFrame == 0) and 255 or offVal, (self.damageColorThisFrame == 2) and 255 or offVal, (self.damageColorThisFrame == 1) and 255 or offVal, 255)
        end
        local quad = self.sprite.animationQuads[self.animationName][self.aniDir][self.aniFrame]
        love.graphics.draw(self.sprite.spritesheet, quad, leftX, topY)
        if love.timer.getTime() * timeScale < self.damageEnds then
            love.graphics.setColor(255, 255, 255, 255)
        end
        -- love.graphics.circle("fill", mapP.x + self.p.x, mapP.y + self.p.y, 3, 5)
    end
end
function Character:move(p)
    self.p = p
    local x = math.floor(p.x / xyMapXWidth)
    local y = math.floor(p.y)
    if self.xyMapP.x ~= x or self.xyMapP.y ~= y then
        if xyMap[self.xyMapP.y] ~= nil then
            if xyMap[self.xyMapP.y][self.xyMapP.x] ~= nil then
                xyMap[self.xyMapP.y][self.xyMapP.x][self.id] = nil
            end
        end
        self.xyMapP = Vector(x, y)
        if xyMap[y] == nil then
            xyMap[y] = {}
        end
        if xyMap[y][x] == nil then
            xyMap[y][x] = {}
        end
        xyMap[y][x][self.id] = self
    end
end
function Character:gotHit(source, damage, damageEffectDuration, knockbackDist, stunDuration)
    if love.timer.getTime() * timeScale > self.nextDamageable then
        self.damageEnds = (love.timer.getTime() + damageEffectDuration) * timeScale
        self.nextDamageable = (love.timer.getTime() + self.invincibilityTime) * timeScale
        self.stunEndTime = (love.timer.getTime() + stunDuration) * timeScale
        local dp = source.p - self.p
        local n = dp:normalized()
        table.insert(coroutines, coroutine.create(function()
            local knockbackSpeed = 500
            while knockbackDist > 0 do
                local dist = math.min(knockbackDist, love.timer.getDelta() * timeScale * knockbackSpeed)
                knockbackDist = knockbackDist - dist
                self:move(self.p + -n * dist)
                coroutine.yield()
            end
        end))
    end
end