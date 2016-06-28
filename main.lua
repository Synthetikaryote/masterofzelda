function love.update()
    if love.keyboard.isScancodeDown("escape") then
        love.event.quit()
    end
end


function love.draw()
    love.graphics.print('Hello World2!', 400, 300)
end