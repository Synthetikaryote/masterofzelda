Character = class()
function Character:init(id, sprite, hp, moveSpeed)
    self.id = id
    self.sprite = sprite
    self.aniDir = 4
    self.aniFrame = 0
    self.aniLastChange = 0
    self.animationName = select(1, next(self.sprite.animations))
    self.hp = hp
    self.moveSpeed = moveSpeed
    self.dir = Vector(1, 0)
    self.p = Vector(0, 0)
    self.attackEnds = 0
    self.xyMapP = Vector(0, 0)
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
        local quad = self.sprite.animationQuads[self.animationName][self.aniDir][self.aniFrame]
        love.graphics.draw(self.sprite.spritesheet, quad, leftX, topY)
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
