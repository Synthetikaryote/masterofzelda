char = {
    spritesheet = love.graphics.newImage("character.png"),
    animations = {
        -- animation name = {y value, frames in animation, frames per second, xSize, ySize}
        cast={0, 7, 20, 64, 64},
        thrust={1, 8, 20, 64, 64},
        walk={2, 9, 20, 64, 64},
        slash={3, 6, 20, 64, 64},
        shoot={4, 13, 20, 64, 64},
        polearm={5, 8, 20, 256, 256}
    },
    hp = 100,
    dir = {1, 0},
    aniDir = 4,
    aniFrame = 0,
    animationName = "walk",
    p = {}
}

dirData = {{"up", {0, 1}},
        {"left", {-1, 0}},
        {"down", {0, 1}},
        {"right", {1, 0}}}

function love.update()
    if love.keyboard.isScancodeDown("escape") then
        love.event.quit()
    end
    v = {0, 0}
    for k, data in pairs(dirData) do
        key, dv = data[1], data[2]
        if love.keyboard.isScancodeDown(key) then
            v[1], v[2] = v[1] + dv[1], v[2] + dv[2]
            char.aniDir = k
        end
    end

    animation = char.animations[char.animationName]
    char.aniFrame = (char.aniFrame + 1) % animation[2]
end

function love.draw()
    love.graphics.print("Direction: "..char.aniDir, 400, 300)
    animation = char.animations[char.animationName]
    quad = love.graphics.newQuad(char.aniFrame * animation[4], (animation[1] * 4 + char.aniDir - 1) * animation[5], animation[4], animation[5], char.spritesheet:getDimensions())
    love.graphics.draw(char.spritesheet, quad, 50, 50)
end