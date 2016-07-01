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
end
function Character:update()
    local animation = self.sprite.animations[self.animationName]
    if love.timer.getTime() * timeScale - self.aniLastChange > 1 / animation[3] then
        self.aniFrame = (self.aniFrame + 1) % animation[2]
        self.aniLastChange = love.timer.getTime() * timeScale
    end
end
function Character:earlyDraw()
end
function Character:draw()
    local animation = self.sprite.animations[self.animationName]
    local leftX = mapP.x + self.p.x - animation[7]
    local rightX = leftX + animation[4]
    local topY = mapP.y + self.p.y - animation[8]
    local bottomY = topY + animation[5]
    if rightX >= 0 and leftX < love.graphics.getWidth() and bottomY >= 0 and topY < love.graphics.getHeight() then
        if love.timer.getTime() * timeScale < self.damageEnds then
            love.graphics.setColor(255, 0, 0, 255)
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
    local animation = self.sprite.animations[self.animationName]
    local x = math.floor((p.x - animation[7]) / xyMapXWidth)
    local y = math.floor(p.y - animation[8])
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
function Character:gotHit(source, damage, knockbackDist)
    if love.timer.getTime() * timeScale > self.nextDamageable then
        self.damageEnds = (love.timer.getTime() + 0.1) * timeScale
        self.nextDamageable = (love.timer.getTime() + self.invincibilityTime) * timeScale
        local dp = source.p - self.p
        n = dp:normalized()
        vt = Vector(n.x, n.y)
        table.insert(coroutines, coroutine.create(function()
            local knockbackSpeed = 500
            while knockbackDist > 0 do
                iterations = iterations + 1
                local dist = math.min(knockbackDist, love.timer.getDelta() * timeScale * knockbackSpeed)
                knockbackDist = knockbackDist - dist
                self:move(self.p + -n * dist)
                coroutine.yield()
            end
        end))
    end
end