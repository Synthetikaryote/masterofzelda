local sti = require "sti"

char = {
    spritesheet = love.graphics.newImage("character.png"),
    animations = {
        -- animation name = {y value, frames in animation, frames per second, xSize, ySize}
        cast={0, 7, 20, 64, 64},
        thrust={1, 8, 20, 64, 64},
        walk={2, 8, 18, 64, 64},
        slash={3, 6, 20, 64, 64},
        shoot={4, 13, 20, 64, 64},
        polearm={5, 8, 20, 256, 256}
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
    moveSpeed = 200
}

local timeScale = 1
local isPaused = false
local font12 = love.graphics.newFont(12)
local font72 = love.graphics.newFont(72)


function love.load()
    map = sti.new("alex - crown island.lua", { })
    for k, v in pairs(map.tiles) do
        v.sx = 5
        v.sy = 5
    end

    local spriteLayer = map.layers["Sprite Layer"]

    -- update callback for custom layers
    function spriteLayer:update(dt)
    end

    -- draw callback for custom layer
    function spriteLayer:draw()
        local animation = char.animations[char.animationName]
        local quad = char.animationQuads[char.animationName][char.aniDir][char.aniFrame]
        love.graphics.draw(char.spritesheet, quad, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.5)
    end

    local worldMapLayer = map.layers["world map"]
    function worldMapLayer:update(dt)
        self.x = -char.p[1]
        self.y = -char.p[2]
    end
end

for aniName, ani in pairs(char.animations) do
    char.animationQuads[aniName] = {}
    for dir = 1, 4 do
        char.animationQuads[aniName][dir] = {}
        for i=0, ani[2]-1 do
            local quad = love.graphics.newQuad(i * ani[4], (ani[1] * 4 + dir - 1) * ani[5], ani[4], ani[5], char.spritesheet:getDimensions())
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
end

function love.update()
    if love.keyboard.isScancodeDown("escape") then
        love.event.quit()
    end

    if isPaused then
        return
    end

    local v = {0, 0}
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
        v[1] = v[1] / len * char.moveSpeed * love.timer.getDelta() * timeScale
        v[2] = v[2] / len * char.moveSpeed * love.timer.getDelta() * timeScale
        char.p[1], char.p[2] = char.p[1] + v[1], char.p[2] + v[2]
    end

    if moving then
        local animation = char.animations[char.animationName]
        if love.timer.getTime() * timeScale - char.aniLastChange > 1 / animation[3] then
            char.aniFrame = (char.aniFrame + 1) % animation[2]
            char.aniLastChange = love.timer.getTime() * timeScale
        end
    else
        char.aniFrame = 0
        char.aniLastChange = love.timer.getTime() * timeScale
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