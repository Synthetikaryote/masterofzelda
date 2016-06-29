require "class"
local sti = require "sti"

-- character sprite sheet is from http://gaurav.munjal.us/Universal-LPC-Spritesheet-Character-Generator/#?sex=female&body=light&eyes=green&nose=none&ears=none&legs=none&clothes=gown&gown-underdress=1&gown-overskirt=0&gown-blue-vest=0&mail=none&armor=none&jacket=none&hair=princess_blonde&hairsara-bottomlayer=0&hairsara-shadow=0&hairsara-toplayer=0&arms=none&shoulders=none&bracers=none&greaves=none&gloves=none&hat=none&hats=tiara_purple&shoes=none&belt=none&buckle=none&necklace=none&cape=none&capeacc=none&weapon=dragonspear&ammo=none&quiver=none

local timeScale = 1
local isPaused = false
local font12 = love.graphics.newFont(12)
local font72 = love.graphics.newFont(72)
local characters = {}
local mapP = {0, 0}

Character = class()
function Character:init(spritesheet, animations, hp, moveSpeed)
    self.spritesheet = spritesheet
    self.animations = animations
    self.hp = hp
    self.moveSpeed = moveSpeed
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
    end
    self.dir = {1, 0}
    self.aniDir = 4
    self.aniFrame = 0
    self.aniLastChange = 0
    self.animationName = select(1, next(self.animations))
    self.p = {0, 0}
    self.attackEnds = 0
end
function Character:update()
    local animation = self.animations[self.animationName]
    if love.timer.getTime() * timeScale - self.aniLastChange > 1 / animation[3] then
        self.aniFrame = (self.aniFrame + 1) % animation[2]
        self.aniLastChange = love.timer.getTime() * timeScale
    end
end
function Character:draw()
    local animation = self.animations[self.animationName]
    local quad = self.animationQuads[self.animationName][self.aniDir][self.aniFrame]
    love.graphics.draw(self.spritesheet, quad, mapP[1] + self.p[1] - animation[7], mapP[2] + self.p[2] - animation[8])
end


Player = class(Character)
function Player:update()
    local joystick = love.joystick.getJoysticks()[1]
    local jx, jy = joystick and joystick:getAxis(1) or 0, joystick and joystick:getAxis(2) or 0
    if math.abs(jx) < 0.06 then jx = 0 end
    if math.abs(jy) < 0.07 then jy = 0 end
    local v = joystick and {jx, jy} or {0, 0}
    local moving = false
    for k, data in pairs(dirData) do
        key, dv = data[1], data[2]
        if love.keyboard.isScancodeDown(key) then
            v[1], v[2] = v[1] + dv[1], v[2] + dv[2]
        end
    end
    local len = math.sqrt(v[1] * v[1] + v[2] * v[2])
    if len > 0 then
        moving = true
        -- vector direction converted to an angle and mapped to the directions in the sprite
        self.aniDir = math.max(1, math.ceil((math.atan2(v[2], -v[1]) + 2) * 0.667 + 0.00001))
        if len > 1 then v[1], v[2] = v[1] / len, v[2] / len end
        v[1] = v[1] * self.moveSpeed * love.timer.getDelta() * timeScale * (love.keyboard.isScancodeDown("lshift") and 10 or 1)
        v[2] = v[2] * self.moveSpeed * love.timer.getDelta() * timeScale * (love.keyboard.isScancodeDown("lshift") and 10 or 1)
        self.p[1], self.p[2] = self.p[1] + v[1], self.p[2] + v[2]
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
function Player:keypressed(c, key, scancode, isRepeat)
    if scancode == "space" then
        self.animationName = "polearm"
        local animation = self.animations[self.animationName]
        local aniDuration = animation[2] * (1 / animation[3])
        self.attackEnds = (love.timer.getTime() + aniDuration) * timeScale
    end
end

Enemy = class(Character)
function Enemy:update()
    Character.update(self)
end
function Enemy:draw()
    Character.draw(self)
end

function love.load()
    player = Player(love.graphics.newImage("assets/character.png"), {
            -- animation name = {y value, frames in animation, frames per second, width, height, y offset, x center, y center}
            cast={0, 7, 20, 64, 64, 0, 32, 56},
            thrust={1, 8, 20, 64, 64, 256, 32, 56},
            walk={2, 8, 18, 64, 64, 512, 32, 56},
            slash={3, 6, 20, 64, 64, 768, 32, 56},
            shoot={4, 13, 20, 64, 64, 1024, 32, 56},
            polearm={5, 8, 30, 192, 192, 1344, 96, 120}
        }, 100, 200)
    player.p = {1000, 1000}
    table.insert(characters, player)

    orc = Enemy(love.graphics.newImage("assets/orc.png"), {
            -- animation name = {y value, frames in animation, frames per second, xSize, ySize}
            cast={0, 7, 20, 64, 64, 0, 32, 56},
            thrust={1, 8, 20, 64, 64, 256, 32, 56},
            walk={2, 8, 18, 64, 64, 512, 32, 56},
            slash={3, 6, 20, 64, 64, 768, 32, 56},
            shoot={4, 13, 20, 64, 64, 1024, 32, 56},
            polearm={5, 8, 30, 192, 192, 1344, 96, 120}
        }, 100, 200)
    table.insert(characters, orc)

    map = sti.new("assets/maps/savageland.lua", { })
    for k, v in pairs(map.tiles) do
        v.sx = 5
        v.sy = 5
    end

    for k, layer in pairs(map.layers) do
        function layer:update(dt)
            mapP[1] = -player.p[1] + love.graphics.getWidth() * 0.5
            mapP[2] = -player.p[2] + love.graphics.getHeight() * 0.5
            self.x = mapP[1]
            self.y = mapP[2]
        end
    end

    dirData = {{"up", {0, -1}},
            {"left", {-1, 0}},
            {"down", {0, 1}},
            {"right", {1, 0}}}

    map:addCustomLayer("Sprite Layer", 6)
    local spriteLayer = map.layers["Sprite Layer"]

    -- update callback for custom layers
    function spriteLayer:update(dt)
    end

    -- draw callback for custom layer
    function spriteLayer:draw()
        for k, v in pairs(characters) do
            v:draw()
        end
    end
end

function love.keypressed(key, scancode, isRepeat)
    if scancode == "pause" then
        isPaused = not isPaused
        timeScale = isPaused and 0 or 1
    end

    if isPaused then
        return
    end

    player:keypressed(key, scancode, isRepeat)
end

function love.update()
    if love.keyboard.isScancodeDown("escape") then
        love.event.quit()
    end

    if isPaused then
        return
    end

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

    love.graphics.print("fps "..love.timer.getFPS().." x, y "..player.p[1]..", "..player.p[2]..", aniDir "..player.aniDir.." frame "..player.aniFrame..(joystick and " joystick "..joystick:getAxis(1)..", "..joystick:getAxis(2) or ""), 400, 300)

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