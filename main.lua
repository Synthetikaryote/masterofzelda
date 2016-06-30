require "class"
require "Vector"
require "sprite"
require "character"
require "player"
require "enemy"
require "utils"

local sti = require "sti"

-- character sprite sheet is from http://gaurav.munjal.us/Universal-LPC-Spritesheet-Character-Generator/#?sex=female&body=light&eyes=green&nose=none&ears=none&legs=none&clothes=gown&gown-underdress=1&gown-overskirt=0&gown-blue-vest=0&mail=none&armor=none&jacket=none&hair=princess_blonde&hairsara-bottomlayer=0&hairsara-shadow=0&hairsara-toplayer=0&arms=none&shoulders=none&bracers=none&greaves=none&gloves=none&hat=none&hats=tiara_purple&shoes=none&belt=none&buckle=none&necklace=none&cape=none&capeacc=none&weapon=dragonspear&ammo=none&quiver=none

timeScale = 1
local isPaused = false
local font12 = love.graphics.newFont(12)
local font72 = love.graphics.newFont(72)
local characters = {}
mapP = Vector(0, 0)
keyboard = {}
xyMap = {}
-- to prevent sprites from being culled near the edges of the screen,
-- this keeps track of the biggest offset to render at the edges
-- essentially the biggest pivot of all sprites
leftXOffset = 0
rightXOffset = 0
topYOffset = 0
bottomYOffset = 0
xyMapXWidth = love.graphics.getWidth() * 0.1

local showAggro = false

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
    }, {
        {310, 50}, {224, 315}, {136, 224}, {45, 136}
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
    }, {
        {310, 50}, {226, 315}, {134, 226}, {45, 134}
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