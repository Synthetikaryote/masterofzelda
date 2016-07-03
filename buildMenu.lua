require "class"
require "build"

ToggleBox = class()
function ToggleBox:init(p, enabled)
    self.p = p
    self.enabled = enabled
end
function ToggleBox:update()
end
function ToggleBox:draw()
end

BuildMenuNode = class()
function BuildMenuNode:init(name, description, points, enabled)
    self.name = name
    self.description = description
    self.points = points
    self.enabled = enabled or false
end
function BuildMenuNode:addChildren(children)
    if not children then return end
    self.children = {}
    for k, v in pairs(children) do
        local newNode = BuildMenuNode(k, v.description, v.points, v.enabled)
        table.insert(self.children, newNode)
        newNode:addChildren(v.children)
    end
end
function BuildMenuNode:update()
end
function BuildMenuNode:draw()
end

BuildMenu = class()
function BuildMenu:init()
    self.root = BuildMenuNode()
    self.root:addChildren(build)
end
function BuildMenu:update()
    self.root:update()
end
function BuildMenu:draw()
    love.graphics.setColor(0, 0, 0, 220)
    love.graphics.rectangle("fill", 50, 50, love.graphics.getWidth() - 100, love.graphics.getHeight() - 100)
    love.graphics.setColor(192, 192, 192, 255)
    love.graphics.rectangle("line", 50, 50, love.graphics.getWidth() - 100, love.graphics.getHeight() - 100)
    -- love.graphics.setColor(255, 255, 255, 255)
    -- print_r(buildMenu, 60, 60, 20)
    self.root:draw()
    love.graphics.setColor(255, 255, 255, 255)
end