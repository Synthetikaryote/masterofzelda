require "class"
require "Vector"
local sti = require "sti"

-- character sprite sheet is from http://gaurav.munjal.us/Universal-LPC-Spritesheet-Character-Generator/#?sex=female&body=light&eyes=green&nose=none&ears=none&legs=none&clothes=gown&gown-underdress=1&gown-overskirt=0&gown-blue-vest=0&mail=none&armor=none&jacket=none&hair=princess_blonde&hairsara-bottomlayer=0&hairsara-shadow=0&hairsara-toplayer=0&arms=none&shoulders=none&bracers=none&greaves=none&gloves=none&hat=none&hats=tiara_purple&shoes=none&belt=none&buckle=none&necklace=none&cape=none&capeacc=none&weapon=dragonspear&ammo=none&quiver=none

local timeScale = 1
local isPaused = false
local font12 = love.graphics.newFont(12)
local font72 = love.graphics.newFont(72)
local characters = {}
local mapP = Vector(0, 0)
local keyboard = {}
local xyMap = {}
-- to prevent sprites from being culled near the edges of the screen,
-- this keeps track of the biggest offset to render at the edges
-- essentially the biggest pivot of all sprites
local leftXOffset = 0
local rightXOffset = 0
local topYOffset = 0
local bottomYOffset = 0
local biggestPivotWidth = 0
local biggestPivotHeight = 0
local xyMapXWidth = love.graphics.getWidth() * 0.1

local showAggro = false

Sprite = class()
function Sprite:init(filename, animations)
    self.spritesheet = love.graphics.newImage(filename)
    self.animations = animations
    self.animationQuads = {}
    for aniName, ani in pairs(self.animations) do
        self.animationQuads[aniName] = {}
        for dir = 1, 4 do
            self.animationQuads[aniName][dir] = {}
            for i=0, ani[2]-1 do
                local quad = love.graphics.newQuad(i * ani[4], ani[6] + (dir - 1) * ani[5], ani[4], ani[5], self.spritesheet:getDimensions())
                self.animationQuads[aniName][dir][i] = quad
            end
        end

        biggestPivotWidth = math.max(biggestPivotWidth, ani[7])
        biggestPivotHeight = math.max(biggestPivotHeight, ani[8])
    end
    leftXOffset = math.max(leftXOffset, biggestPivotWidth)
    topYOffset = math.max(topYOffset, biggestPivotHeight)
end

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


Player = class(Character)
function Player:update()
    local joystick = love.joystick.getJoysticks()[1]
    local jx, jy = joystick and joystick:getAxis(1) or 0, joystick and joystick:getAxis(2) or 0
    if math.abs(jx) < 0.06 then jx = 0 end
    if math.abs(jy) < 0.07 then jy = 0 end
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
        self.aniDir = math.max(1, math.ceil((math.atan2(v.y, -v.x) + 2) * 0.667 + 0.00001))
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
end
function Player:keypressed(key, scancode, isRepeat)
    if scancode == "space" then
        self.animationName = "polearm"
        local animation = self.sprite.animations[self.animationName]
        local aniDuration = animation[2] * (1 / animation[3])
        self.attackEnds = (love.timer.getTime() + aniDuration) * timeScale
    end
end

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
        self.aniDir = math.max(1, math.ceil((math.atan2(vy, -vx) + 2) * 0.667 + 0.00001))
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

local numVisited = 0
function love.load()
    map = sti.new("assets/maps/savageland.lua", { })
    for k, v in pairs(map.tiles) do
        v.sx = 5
        v.sy = 5
    end

    for k, layer in pairs(map.layers) do
        function layer:update(dt)
            mapP.x = -player.p.x + love.graphics.getWidth() * 0.5
            mapP.y = -player.p.y + love.graphics.getHeight() * 0.5
            self.x = mapP.x
            self.y = mapP.y
        end
    end

    map:addCustomLayer("Sprite Layer", 6)
    local spriteLayer = map.layers["Sprite Layer"]

    -- update callback for custom layers
    function spriteLayer:update(dt)
    end

    -- draw callback for custom layer
    function spriteLayer:draw()
        numVisited = 0
        local topY = math.floor(-mapP.y - topYOffset)
        local bottomY = math.floor(-mapP.y + love.graphics.getHeight() + bottomYOffset)
        local leftX = math.floor((-mapP.x - leftXOffset) / xyMapXWidth)
        local rightX = math.floor((-mapP.x + love.graphics.getWidth()) / xyMapXWidth + rightXOffset)
        for i = 1, 2 do -- 2 passes: earlyDraw, draw
            for y = topY, bottomY do
                if xyMap[y] then
                    for x = leftX, rightX do
                        if xyMap[y][x] then
                            for k, v in pairs(xyMap[y][x]) do
                                if i == 1 then
                                    numVisited = numVisited + 1
                                    v:earlyDraw()
                                elseif i == 2 then
                                    v:draw()
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local playerSprite = Sprite("assets/character.png", {
        -- animation name = {y value, frames in animation, frames per second, width, height, y offset, x center, y center}
        cast={0, 7, 20, 64, 64, 0, 32, 56},
        thrust={1, 8, 20, 64, 64, 256, 32, 56},
        walk={2, 8, 18, 64, 64, 512, 32, 56},
        slash={3, 6, 20, 64, 64, 768, 32, 56},
        shoot={4, 13, 20, 64, 64, 1024, 32, 56},
        polearm={5, 8, 30, 192, 192, 1345, 96, 119}
    })
    player = Player("player", playerSprite, 100, 200)
    player:move(Vector(0, 0))
    table.insert(characters, player)

    local orcSprite = Sprite("assets/orc.png", {
        -- animation name = {y value, frames in animation, frames per second, xSize, ySize}
        cast={0, 7, 20, 64, 64, 0, 32, 56},
        thrust={1, 8, 20, 64, 64, 256, 32, 56},
        walk={2, 8, 18, 64, 64, 512, 32, 56},
        slashEmpty={3, 6, 20, 64, 64, 768, 32, 56},
        shoot={4, 13, 20, 64, 64, 1024, 32, 56},
        attack={5, 6, 10, 192, 192, 1345, 96, 119}
    })
    local numOrcs = 400
    for i=1,numOrcs do
        orc = Enemy("orc"..i, orcSprite, 100, 100, 200, 50)
        orc:move(Vector(math.random(0, 7680), math.random(0, 7680)))
        table.insert(characters, orc)
    end

    dirData = {
        {"up", Vector(0, -1)},
        {"left", Vector(-1, 0)},
        {"down", Vector(0, 1)},
        {"right", Vector(1, 0)}
    }
end

function love.keypressed(key, scancode, isRepeat)
    keyboard[scancode] = 1

    if scancode == "escape" then
        love.event.quit()
    elseif scancode == "pause" then
        isPaused = not isPaused
        timeScale = isPaused and 0 or 1
    end

    if isPaused then
        return
    end

    player:keypressed(key, scancode, isRepeat)
end

function love.keyreleased(key, scancode, isRepeat)
    keyboard[scancode] = nil
end

function love.update()
    if isPaused then
        return
    end

    showAggro = keyboard["lctrl"] or keyboard["rctrl"]


    for k, v in pairs(characters) do
        v:update()
    end

    map:update(love.timer.getDelta() * timeScale)
end

function love.draw()

    map:setDrawRange(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    map:draw()

    local joystick = love.joystick.getJoysticks()[1]
    local v = joystick and {joystick:getAxis(1), joystick:getAxis(2)} or {0, 0}

    love.graphics.print("fps "..love.timer.getFPS().." x, y "..player.p.x..", "..player.p.y..", aniDir "..player.aniDir.." frame "..player.aniFrame..(joystick and "\njoystick "..joystick:getAxis(1)..", "..joystick:getAxis(2) or "").."\nnumVisited "..numVisited, 400, 300)

    if isPaused then
        love.graphics.setFont(font72)
        local message = "paused"
        love.graphics.printf(message, 0, (love.graphics.getHeight() - font72:getHeight(message)) * 0.5, love.graphics.getWidth(), "center")
        love.graphics.setFont(font12)
    end

    -- print_r(player.animationQuads, 800, -2600)
end

function print_r ( t, x, y )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        love.graphics.print(indent.."["..pos.."] => "..tostring(t).." {", x, y)
                        y = y + 20
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        love.graphics.print(indent..string.rep(" ",string.len(pos)+6).."}", x, y)
                        y = y + 20
                    elseif (type(val)=="string") then
                        love.graphics.print(indent.."["..pos..'] => "'..val..'"', x, y)
                        y = y + 20
                    else
                        love.graphics.print(indent.."["..pos.."] => "..tostring(val), x, y)
                        y = y + 20
                    end
                end
            else
                love.graphics.print(indent..tostring(t), x, y)
                y = y + 20
            end
        end
    end
    if (type(t)=="table") then
        love.graphics.print(tostring(t).." {", x, y)
        y = y + 20
        sub_print_r(t,"  ")
        love.graphics.print("}", x, y)
        y = y + 20
    else
        sub_print_r(t,"  ")
    end
    love.graphics.print("", x, y)
    y = y + 20
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end