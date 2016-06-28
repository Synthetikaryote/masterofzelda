local sti = require "sti"

-- character sprite sheet is from http://gaurav.munjal.us/Universal-LPC-Spritesheet-Character-Generator/#?sex=female&body=light&eyes=green&nose=none&ears=none&legs=none&clothes=gown&gown-underdress=1&gown-overskirt=0&gown-blue-vest=0&mail=none&armor=none&jacket=none&hair=princess_blonde&hairsara-bottomlayer=0&hairsara-shadow=0&hairsara-toplayer=0&arms=none&shoulders=none&bracers=none&greaves=none&gloves=none&hat=none&hats=tiara_purple&shoes=none&belt=none&buckle=none&necklace=none&cape=none&capeacc=none&weapon=dragonspear&ammo=none&quiver=none

char = {
    spritesheet = love.graphics.newImage("assets/character.png"),
    animations = {
        -- animation name = {y value, frames in animation, frames per second, xSize, ySize}
        cast={0, 7, 20, 64, 64, 0, 32, 56},
        thrust={1, 8, 20, 64, 64, 256, 32, 56},
        walk={2, 8, 18, 64, 64, 512, 32, 56},
        slash={3, 6, 20, 64, 64, 768, 32, 56},
        shoot={4, 13, 20, 64, 64, 1024, 32, 56},
        polearm={5, 8, 30, 192, 192, 1344, 96, 120}
    },
    animationQuads = {},
    hp = 100,
    dir = {1, 0},
    aniDir = 4,
    aniFrame = 0,
    aniLastChange = 0,
    animationName = "walk",
    quad = love.graphics.newQuad(0, 0, 1, 1, 1, 1),
    p = {0, 0},
    moveSpeed = 200,
    attackEnds = 0
}

local timeScale = 1
local isPaused = false
local font12 = love.graphics.newFont(12)
local font72 = love.graphics.newFont(72)


function love.load()
    map = sti.new("assets/maps/savageland.lua", { })
    for k, v in pairs(map.tiles) do
        v.sx = 5
        v.sy = 5
    end

    for k, layer in pairs(map.layers) do
        function layer:update(dt)
            self.x = -char.p[1]
            self.y = -char.p[2]
        end
    end

    map:addCustomLayer("Sprite Layer", 6)
    local spriteLayer = map.layers["Sprite Layer"]

    -- update callback for custom layers
    function spriteLayer:update(dt)
    end

    -- draw callback for custom layer
    function spriteLayer:draw()
        local animation = char.animations[char.animationName]
        local quad = char.animationQuads[char.animationName][char.aniDir][char.aniFrame]
        love.graphics.draw(char.spritesheet, quad, love.graphics.getWidth() * 0.5 - animation[7], love.graphics.getHeight() * 0.5 - animation[8])
    end
end

for aniName, ani in pairs(char.animations) do
    char.animationQuads[aniName] = {}
    for dir = 1, 4 do
        char.animationQuads[aniName][dir] = {}
        for i=0, ani[2]-1 do
            local quad = love.graphics.newQuad(i * ani[4], ani[6] + (dir - 1) * ani[5], ani[4], ani[5], char.spritesheet:getDimensions())
            char.animationQuads[aniName][dir][i] = quad
        end
    end
end

dirData = {{"up", {0, -1}},
        {"left", {-1, 0}},
        {"down", {0, 1}},
        {"right", {1, 0}}}

function love.keypressed(key, scancode, isRepeat)
    if scancode == "pause" then
        isPaused = not isPaused
        timeScale = isPaused and 0 or 1
    end

    if isPaused then
        return
    end

    if scancode == "space" then
        char.animationName = "polearm"
        local animation = char.animations[char.animationName]
        local aniDuration = animation[2] * (1 / animation[3])
        char.attackEnds = (love.timer.getTime() + aniDuration) * timeScale
    end
end

function love.update()
    if love.keyboard.isScancodeDown("escape") then
        love.event.quit()
    end

    if isPaused then
        return
    end

    local joystick = love.joystick.getJoysticks()[1]
    local v = joystick and {joystick:getAxis(1), joystick:getAxis(2)} or {0, 0}
    local moving = false
    for k, data in pairs(dirData) do
        key, dv = data[1], data[2]
        if love.keyboard.isScancodeDown(key) then
            v[1], v[2] = v[1] + dv[1], v[2] + dv[2]
            char.aniDir = k
            moving = true
        end
    end
    local len = math.sqrt(v[1] * v[1] + v[2] * v[2])
    if len > 0 then
        v[1] = v[1] / len * char.moveSpeed * love.timer.getDelta() * timeScale * (love.keyboard.isScancodeDown("lshift") and 10 or 1)
        v[2] = v[2] / len * char.moveSpeed * love.timer.getDelta() * timeScale * (love.keyboard.isScancodeDown("lshift") and 10 or 1)
        char.p[1], char.p[2] = char.p[1] + v[1], char.p[2] + v[2]
    end

    if love.timer.getTime() * timeScale <= char.attackEnds then
        local animation = char.animations[char.animationName]
        if love.timer.getTime() * timeScale - char.aniLastChange > 1 / animation[3] then
            char.aniFrame = (char.aniFrame + 1) % animation[2]
            char.aniLastChange = love.timer.getTime() * timeScale
        end
    elseif moving then
        char.animationName = "walk"
        local animation = char.animations[char.animationName]
        if love.timer.getTime() * timeScale - char.aniLastChange > 1 / animation[3] then
            char.aniFrame = (char.aniFrame + 1) % animation[2]
            char.aniLastChange = love.timer.getTime() * timeScale
        end
    else
        char.animationName = "walk"
        char.aniFrame = 0
    end

    map:update(love.timer.getDelta() * timeScale)
end

function love.draw()
    love.graphics.print("fps "..love.timer.getFPS().." x, y "..char.p[1]..", "..char.p[2]..", aniDir "..char.aniDir.." frame "..char.aniFrame, 400, 300)

    map:setDrawRange(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    map:draw()

    if isPaused then
        love.graphics.setFont(font72)
        local message = "paused"
        love.graphics.printf(message, 0, (love.graphics.getHeight() - font72:getHeight(message)) * 0.5, love.graphics.getWidth(), "center")
        love.graphics.setFont(font12)
    end

    -- print_r(char.animationQuads, 800, -2600)
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