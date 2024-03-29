Character = class(NetworkEntity)
function Character:init(id, sprite, hp, moveSpeed, invincibilityTime, attackDist, attackDamage, attackDamageTime)
    NetworkEntity.init(self)
    self.id = id
    self.sprite = sprite
    self.aniDir = 4
    self.aniFrame = 0
    self.aniLastChange = 0
    self.aniLooping = true
    self.animationName = select(1, next(self.sprite.animations))
    self.maxHp = hp
    self.state.hp = hp
    self.moveSpeed = moveSpeed
    self.facingDir = 0
    self.state.p = vector(0, 0)
    self.mapP = vector(0, 0)
    self.attackEnds = 0
    self.damageEnds = 0
    self.xyMapP = vector(0, 0)
    self.invincibilityTime = invincibilityTime
    self.nextDamageable = 0
    self.attackDist = attackDist
    self.attackDamage = attackDamage
    self.attackDamageTime = attackDamageTime
    self.damageColorThisFrame = 0
    self.stunEndTime = 0
    self.despawnTime = 0
    self.despawnQueued = false
    self.isAlive = true
    self.coroutines = {}
    self.scale = 1
    self.state.type = "Character"
end
function Character:update()
    self:updateCoroutines()
    if self.despawnQueued and love.timer.getTime() * timeScale >= self.despawnTime and #self.coroutines == 0 then
        self:despawn()
        return
    end
    local animation = self.sprite.animations[self.animationName]
    if love.timer.getTime() * timeScale - self.aniLastChange > 1 / animation[3] then
        self.aniFrame = self.aniLooping and ((self.aniFrame + 1) % animation[2]) or math.min(self.aniFrame + 1, animation[2] - 1)
        self.aniLastChange = love.timer.getTime() * timeScale
    end
end
function Character:despawn()
        self:removeFromMap()
        characters[self.id] = nil
        self = nil
end
function Character:updateCoroutines()
    for i = #self.coroutines, 1, -1 do
        local c = self.coroutines[i]
        if coroutine.resume(c) == false then
            table.remove(self.coroutines, i)
        end
    end
end
function Character:earlyDraw()
    if showAttackDist then
        local animation = self.sprite.animations[self.animationName]
        local x = mapP.x + self.state.p.x
        local y = mapP.y + self.state.p.y
        love.graphics.setColor(0, 0, 255, 255)
        love.graphics.circle("line", x, y, self.attackDist, 40)
        love.graphics.setColor(0, 0, 255, 50)
        love.graphics.circle("fill", x, y, self.attackDist, 40)
        love.graphics.setColor(255, 255, 255, 255)
    end
end
function Character:draw()
    local animation = self.sprite.animations[self.animationName]
    local leftX = math.floor(mapP.x + self.state.p.x - animation[7] * self.scale + 0.5)
    local rightX = leftX + animation[4] * self.scale
    local topY = math.floor(mapP.y + self.state.p.y - animation[8] * self.scale + 0.5)
    local bottomY = topY + animation[5] * self.scale
    if rightX >= 0 and leftX < love.graphics.getWidth() and bottomY >= 0 and topY < love.graphics.getHeight() then
        if love.timer.getTime() * timeScale < self.damageEnds then
            self.damageColorThisFrame = math.floor(love.timer.getTime() * 35) % 3
            local offVal = 128
            love.graphics.setColor((self.damageColorThisFrame == 0) and 255 or offVal, (self.damageColorThisFrame == 2) and 255 or offVal, (self.damageColorThisFrame == 1) and 255 or offVal, 255)
        end
        local quad = self.sprite.animationQuads[self.animationName][self.aniDir][self.aniFrame]
        love.graphics.draw(self.sprite.spritesheet, quad, leftX, topY, 0, self.scale, self.scale)
        if love.timer.getTime() * timeScale < self.damageEnds then
            love.graphics.setColor(255, 255, 255, 255)
        end
        -- love.graphics.circle("fill", mapP.x + self.state.p.x, mapP.y + self.state.p.y, 3, 5)
    end

    if self.state.hp < self.maxHp and self.isAlive then
        self:drawHpBar()
    end
end
function Character:lateDraw()

end
function Character:drawHpBar()
    local p = self.state.hp / self.maxHp
    local a = 170
    love.graphics.setColor(0, 0, 0, a)
    love.graphics.rectangle("fill", math.floor(mapP.x + self.state.p.x - 25 * self.scale + 0.5), math.floor(mapP.y + self.state.p.y - 60 * self.scale + 0.5), 52 * self.scale, 4 * self.scale)
    love.graphics.setColor(math.min(1, 2 - p*2) * 255, math.min(1, p*2) * 255, 0, a)
    love.graphics.rectangle("fill", math.floor(mapP.x + self.state.p.x - 25 * self.scale + 1 + 0.5), math.floor(mapP.y + self.state.p.y - 60 * self.scale + 1 + 0.5), 52 * self.state.hp / self.maxHp * self.scale - 2, 4 * self.scale - 2)
    love.graphics.setColor(255, 255, 255, 255)
end

function Character:move(p, skipCollision, slideAlongWalls)
    local slideAlongWalls = slideAlongWalls == nil and true or false
    local mapX, mapY = map:convertPixelToTile(p.x, p.y)
    mapX, mapY = math.floor(mapX) + 1, math.floor(mapY) + 1

    if not skipCollision then
        -- list the tiles this will move through
        local dp = p - self.state.p
        local dist = dp:len()
        local n = dp / dist
        local d = 0
        local q = self.state.p
        local m = vector(0, 0)
        local tW, tH = 32, 32
        local tilesHit = {}
        local i = 0
        repeat
            i = i + 1
            m.x, m.y = map:convertPixelToTile(q.x + d * n.x, q.y + d * n.y)
            local dx = n.x ~= 0 and ((math.floor(m.x + (n.x > 0 and 0.99 or 0)) - m.x) * tW / n.x) or dist
            local dy = n.y ~= 0 and ((math.floor(m.y + (n.y > 0 and 0.99 or 0)) - m.y) * tH / n.y) or dist
            d = d + math.min(dx, dy)
            if d < dist then
                local collisionPoint = vector(q.x + d * n.x + (n.x > 0 and -0.001 or 0), q.y + d * n.y + (n.y > 0 and -0.001 or 0))
                local newDir = (dx < dy) and vector(0, n.y == 0 and 0 or (n.y > 0 and 1 or -1)) or vector(n.x == 0 and 0 or (n.x > 0 and 1 or -1), 0)
                table.insert(tilesHit, {vector(m.x + 1, m.y + 1), collisionPoint, newDir, dist - d})
            end
        until d >= dist or i >= 10
        -- go through the hit tiles in order to check if they have an entry on the obstacles
        for k, v in ipairs(tilesHit) do
            local m, cp, newDir, d = v[1], v[2], v[3], v[4]
            if obstacles.data[mapY] then
                if obstacles.data[mapY][mapX] then
                    -- a collision was found.  move the player to the collision point (without collision check)
                    -- then move them along that wall the rest of their intended travel distance
                    self:move(cp, true, false)
                    if slideAlongWalls then
                        self:move(self.state.p + newDir * d, false, false)
                    end
                    return
                end
            end
        end
    end
    self.state.p = p
    self.mapP = vector(mapX, mapY)
    local x = math.floor(p.x / xyMapXWidth)
    local y = math.floor(p.y)
    if self.xyMapP.x ~= x or self.xyMapP.y ~= y then
        self:removeFromMap()
        self.xyMapP = vector(x, y)
        if xyMap[y] == nil then
            xyMap[y] = {}
        end
        if xyMap[y][x] == nil then
            xyMap[y][x] = {}
        end
        xyMap[y][x][self.id] = self
    end
end
function Character:removeFromMap()
    if xyMap[self.xyMapP.y] ~= nil then
        if xyMap[self.xyMapP.y][self.xyMapP.x] ~= nil then
            xyMap[self.xyMapP.y][self.xyMapP.x][self.id] = nil
        end
    end
end
function Character:gotHit(source, damage, damageEffectDuration, knockbackDist, stunDuration)
    if love.timer.getTime() * timeScale > self.nextDamageable then
        self.state.hp = math.max(0, self.state.hp - damage)
        self.damageEnds = (love.timer.getTime() + damageEffectDuration) * timeScale
        self.nextDamageable = (love.timer.getTime() + self.invincibilityTime) * timeScale
        self.stunEndTime = (love.timer.getTime() + stunDuration) * timeScale
        local dp = source.state.p - self.state.p
        local n = dp:normalized()
        table.insert(self.coroutines, coroutine.create(function()
            local knockbackSpeed = 500
            while knockbackDist > 0 and self ~= nil do
                local dist = math.min(knockbackDist, love.timer.getDelta() * timeScale * knockbackSpeed)
                knockbackDist = knockbackDist - dist
                if self ~= nil then
                    self:move(self.state.p + -n * dist)
                end
                coroutine.yield()
            end
        end))
    end
end