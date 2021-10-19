require "class"
require "vector"
require "sprite"
require "character"
require "player"
require "localPlayer"
require "enemy"
require "utils"
require "buildMenu"
require "binds"
require "server"

local sti = require "sti"

-- character sprite sheet is from http://gaurav.munjal.us/Universal-LPC-Spritesheet-Character-Generator/#?sex=female&body=light&eyes=green&nose=none&ears=none&legs=none&clothes=gown&gown-underdress=1&gown-overskirt=0&gown-blue-vest=0&mail=none&armor=none&jacket=none&hair=princess_blonde&hairsara-bottomlayer=0&hairsara-shadow=0&hairsara-toplayer=0&arms=none&shoulders=none&bracers=none&greaves=none&gloves=none&hat=none&hats=tiara_purple&shoes=none&belt=none&buckle=none&necklace=none&cape=none&capeacc=none&weapon=dragonspear&ammo=none&quiver=none

timeScale = 1
local isPaused = false
font12 = love.graphics.newFont(12)
font18 = love.graphics.newFont(18)
font48 = love.graphics.newFont(48)
font72 = love.graphics.newFont(72)
characters = {}
mapP = vector(0, 0)
keyboard = {}
gamepads = {}
xyMap = {}
-- to prevent sprites from being culled near the edges of the screen,
-- this keeps track of the biggest offset to render at the edges
-- essentially the biggest pivot of all sprites
leftXOffset = 0
rightXOffset = 0
topYOffset = 0
bottomYOffset = 0
xyMapXWidth = love.graphics.getWidth() * 0.01
coroutines = {}
logString = ""
obstacles = nil
showDebug = false

showAggro = false
showAttackDist = false

showBuildMenu = false
showBinds = true

local lastWheelX = 0
local lastWheelY = 0
local wheelButtonDuration = 0.15
server = nil

local numVisited = 0
function love.load()
    map = sti("assets/maps/savageland.lua", { })
    obstacles = map.layers["level 1 obstacles"]

    for k, layer in pairs(map.layers) do
        function layer:update(dt)
            mapP.x = math.floor(-player.state.p.x + love.graphics.getWidth() * 0.5 + 0.5)
            mapP.y = math.floor(-player.state.p.y + love.graphics.getHeight() * 0.5 + 0.5)
            self.x = mapP.x
            self.y = mapP.y
        end
    end
    local spriteLayer = map.layers["level 1 sprites"]
    -- update callback for custom layers
    function spriteLayer:update(dt)
    end
    -- draw callback for custom layer
    function spriteLayer:draw()
        local topLeft = vector(-mapP.x - leftXOffset, -mapP.y - topYOffset)
        local bottomRight = vector(-mapP.x + love.graphics.getWidth() + rightXOffset, -mapP.y + love.graphics.getHeight() + bottomYOffset)
        if showAttackDist or showAggro then
            visitCharsInRect(topLeft, bottomRight, function(c)
                c:earlyDraw()
            end)
        end
        visitCharsInRect(topLeft, bottomRight, function(c)
            c:draw()
        end)
        -- visitCharsInRect(topLeft, bottomRight, function(c)
        --     c:lateDraw()
        -- end)
    end

    binds = Binds(vector(love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 1), 30, vector(0.5, 1), love.graphics.newFont(10))

    local playerSprite = Sprite("assets/character.png", {
        -- animation name = {y value, frames in animation, frames per second, width, height, y offset, x center, y center}
        cast={0, 7, 20, 64, 64, 0, 32, 56},
        thrust={1, 8, 20, 64, 64, 256, 32, 56},
        walk={2, 8, 18, 64, 64, 512, 32, 56},
        slash={3, 6, 20, 64, 64, 768, 32, 56},
        shoot={4, 13, 20, 64, 64, 1024, 32, 56},
        death={5, 6, 10, 64, 64, 1280, 32, 56},
        polearm={6, 8, 25, 192, 192, 1345, 96, 119}
    }, {
        {310, 50}, {224, 315}, {136, 224}, {45, 136}
    })
    -- function Player:init(id, sprite,     hp,     moveSpeed, invincibilityTime,   attackDist, attackDamage,   attackDamageTime)
    player = LocalPlayer("player", playerSprite, 100,    200,       0.5,                 100,        50,            0.1)
    player:move(vector(5088, 4000))
    characters[player.id] = player

    local orcSprite = Sprite("assets/orc.png", {
        -- animation name = {y value, frames in animation, frames per second, width, height, y offset, x center, y center}
        cast={0, 7, 20, 64, 64, 0, 32, 56},
        thrust={1, 8, 20, 64, 64, 256, 32, 56},
        walk={2, 8, 10, 64, 64, 512, 32, 56},
        slashEmpty={3, 6, 20, 64, 64, 768, 32, 56},
        shoot={4, 13, 20, 64, 64, 1024, 32, 56},
        death={5, 6, 10, 64, 64, 1280, 32, 56},
        attack={6, 6, 5, 192, 192, 1345, 96, 119}
    }, {
        {310, 50}, {226, 315}, {134, 226}, {45, 134}
    })
    local numOrcs = 0
    for i=1,numOrcs do
        -- function Enemy:init(id, sprite,  hp,     moveSpeed,  invincibilityTime,  attackDist,     attackDamage,   attackDamageTime,   collisionDist,  detectDist, collisionDamage,    pursueDist, startAttackDist)
        local orc = Enemy("orc"..i, orcSprite,    100,    100,        0.2,          60,            20,             0.90,               10,             300,        10,                 30,         110)
        orc.scale = 1
        repeat
            orc:move(vector(math.random(0, 7680), math.random(0, 7680)))
        until (orc.p - player.state.p):lenSq() > 400 * 400
        characters[orc.id] = orc
    end

    buildMenu = BuildMenu()

    server = Server(player)
end

function visitCharsInRadius(p, r, f)
    visitCharsInRect(vector(p.x - r, p.y - r), vector(p.x + r, p.y + r), function(c)
        if (c.state.p - p):lenSq() < r * r then
            f(c)
        end
    end)
end

function visitCharsInRect(topLeft, bottomRight, f)
    topLeft = vector(math.floor(topLeft.x / xyMapXWidth), math.floor(topLeft.y))
    bottomRight = vector(math.floor(bottomRight.x / xyMapXWidth), math.floor(bottomRight.y))
    for y = topLeft.y, bottomRight.y do
        if xyMap[y] then
            for x = topLeft.x, bottomRight.x do
                if xyMap[y][x] then
                    for k, v in pairs(xyMap[y][x]) do
                        f(v)
                    end
                end
            end
        end
    end
end

function checkInput(scancode, button)
	if scancode == "escape" then
        love.event.quit()
    elseif scancode == "pause" or button == "start" then
		isPaused = not isPaused
		timeScale = isPaused and 0 or 1
    elseif scancode == "f3" or button == "rightstick" then
        showDebug = not showDebug
    elseif scancode == "`" or button == "back" then
        showBuildMenu = not showBuildMenu
    elseif scancode == "f4" then
        showBinds = not showBinds
	end
end

function love.mousepressed(x, y, button, isTouch)
    if button == 1 then keyboard["lmb"] = 1 end
    if button == 2 then keyboard["rmb"] = 1 end
    if button == 3 then keyboard["mmb"] = 1 end
    for i = 4, 12 do
        if button == i then keyboard["mb"..i] = 1 end
    end
end

function love.mousereleased(x, y, button, isTouch)
    if button == 1 then keyboard["lmb"] = nil end
    if button == 2 then keyboard["rmb"] = nil end
    if button == 3 then keyboard["mmb"] = nil end
end

function love.wheelmoved(x, y)
    if x < 0 then keyboard["wheelleft"] = 1 keyboard["wheelright"] = nil lastWheelX = love.timer.getTime() end
    if x > 0 then keyboard["wheelright"] = 1 keyboard["wheelleft"] = nil lastWheelX = love.timer.getTime() end
    if y < 0 then keyboard["wheeldown"] = 1 keyboard["wheelup"] = nil lastWheelY = love.timer.getTime() end
    if y > 0 then keyboard["wheelup"] = 1 keyboard["wheeldown"] = nil lastWheelY = love.timer.getTime() end
end

function clearWheelButtonsX()
    keyboard["wheelleft"] = nil
    keyboard["wheelright"] = nil
end
function clearWheelButtonsY()
    keyboard["wheelup"] = nil
    keyboard["wheeldown"] = nil
end

function love.keypressed(key, scancode, isRepeat)
    keyboard[scancode] = 1

    checkInput(scancode, nil)

    if isPaused then
        return
    end
end

function love.keyreleased(key, scancode, isRepeat)
    keyboard[scancode] = nil
end

function love.gamepadpressed(gamepad, button)
    local id = gamepad:getID()
    if gamepads[id] == nil then
        gamepads[id] = {}
    end
    gamepads[id][button] = 1
    
    checkInput(nil, button)

    if isPaused then
    	return
    end
end

function love.gamepadreleased(gamepad, button)
    local id = gamepad:getID()
    if gamepads[id] == nil then
        gamepads[id] = {}
    end
    gamepads[id][button] = nil
end

function love.update(dt)
    if isPaused then
        return
    end

    binds:update()
    if love.timer.getTime() - lastWheelX > wheelButtonDuration then clearWheelButtonsX() end
    if love.timer.getTime() - lastWheelY > wheelButtonDuration then clearWheelButtonsY() end

    showAggro = keyboard["lctrl"] or keyboard["rctrl"]
    showAttackDist = keyboard["lalt"] or keyboard["ralt"]

    for i = #coroutines, 1, -1 do
        local c = coroutines[i]
        if coroutine.resume(c, dt) == false then
            table.remove(coroutines, i)
        end
    end
    
    local charsToUpdate = {}
    local topLeft = vector(-mapP.x - leftXOffset, -mapP.y - topYOffset)
    local bottomRight = vector(-mapP.x + love.graphics.getWidth() + rightXOffset, -mapP.y + love.graphics.getHeight() + bottomYOffset)
    visitCharsInRect(topLeft, bottomRight, function(c)
        table.insert(charsToUpdate, c)
    end)
    numVisited = #charsToUpdate
    for i, c in ipairs(charsToUpdate) do
        c:update()
    end

    map:update(love.timer.getDelta() * timeScale)

    if showBuildMenu then
        buildMenu:update()
    end

    server:update()

    collectgarbage("step")
end

function love.draw()

    --map:setDrawRange(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    map:draw(0,0,1,1)

    local joystick = love.joystick.getJoysticks()[1]
    local v = joystick and {joystick:getAxis(1), joystick:getAxis(2)} or {0, 0}
    
    love.graphics.setFont(font12)
    love.graphics.print("fps "..love.timer.getFPS(), 10, 10)
    if showDebug then
        love.graphics.print("x, y "..player.state.p.x..", "..player.state.p.y..", aniDir "..player.aniDir.." frame "..player.aniFrame..(joystick and "\njoystick "..joystick:getAxis(1)..", "..joystick:getAxis(2) or "")..
            "\nnumVisited "..numVisited.." nextDamageable "..player.nextDamageable.." hits "..hits.." color "..player.damageColorThisFrame..
            "\ntime "..love.timer.getTime() * timeScale.." nextHitTime "..player.nextHitTime..
            "\nmapP "..player.mapP.x..", "..player.mapP.y, 10, 230)
        print_r(gamepads, 10, 320)
    end

    love.graphics.print(logString, 10, 370)

    love.graphics.setFont(font48)
    love.graphics.print("Kills: "..player.killCount, 40, 40)
    love.graphics.print("Deaths: "..player.deaths, 40, 110)
    love.graphics.setFont(font12)

    if showBinds then
        binds:draw()
    end
    if showBuildMenu then
        buildMenu:draw()
    end

    -- print_r(obstacles, 0, 0, 4)

    if isPaused then
        love.graphics.setFont(font72)
        local message = "paused"
        love.graphics.printf(message, 0, (love.graphics.getHeight() - font72:getHeight(message)) * 0.5, love.graphics.getWidth(), "center")
        love.graphics.setFont(font12)
    end

    -- print_r(player.animationQuads, 800, -2600)
end

function love.run()
 
    if love.math then
        love.math.setRandomSeed(os.time())
    end
 
    if love.load then love.load(arg) end
 
    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end
 
    local dt = 0
 
    -- Main loop time.
    while true do
        -- Process events.
        if love.event then
            love.event.pump()
            for name, a,b,c,d,e,f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a,b,c,d,e,f)
            end
        end
 
        -- Update dt, as we'll be passing it to update
        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end
 
        -- Call update and draw
        if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end
    end
end

function log(s)
    logString = logString..s.."\n"
end