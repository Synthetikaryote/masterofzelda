require "class"
require "build"
require "vector"

local toggleBoxSize = vector(20, 20)
local font = love.graphics.newFont(18)
local spaceAfterToggleBox = 20
local lineHeight = 20
local childIndent = 60
local groupExtraSpace = vector(0, 0)
local lineWidth = 400

ToggleBox = class()
function ToggleBox:init(enabled)
    self.enabled = enabled
end
function ToggleBox:update()
end
function ToggleBox:draw(p)
    love.graphics.rectangle("line", p.x, p.y, toggleBoxSize.x, toggleBoxSize.y)
    if self.enabled then
        love.graphics.rectangle("fill", p.x + toggleBoxSize.x * 0.0, p.y + toggleBoxSize.y * 0.0, toggleBoxSize.x * 1, toggleBoxSize.y * 1)
    end
end

BuildMenuNode = class()
function BuildMenuNode:init(name, description, points, enabled)
    self.name = name
    self.description = description
    self.points = points
    self.isGroup = name == nil and description == nil and enabled == nil
    if enabled ~= nil then
        self.enabled = enabled
        self.toggleBox = ToggleBox(enabled)
    end
end
function BuildMenuNode:addChildren(children)
    if not children then return end
    self.children = {}
    for k, v in pairs(children) do
        local newNode = BuildMenuNode(v.name, v.description, v.points, v.enabled)
        table.insert(self.children, newNode)
        newNode:addChildren(v.children)
    end
end
function BuildMenuNode:getSize()
    local width, height = lineWidth, 0
    if self.toggleBox then
        width, height = toggleBoxSize.x + spaceAfterToggleBox, toggleBoxSize.y
    end
    if self.name then
        width = width + font:getWidth(self.name)
        height = math.max(height, font:getHeight())
    end
    if self.isGroup then
        width = width + groupExtraSpace.x
        height = height + groupExtraSpace.y
    end
    if self.children then
        for k, v in pairs(self.children) do
            local cW, cH = v:getSize()
            width, height = math.max(width, cW), height + lineHeight + cH
        end
    end
    return width, height
end
function BuildMenuNode:update()
end
function BuildMenuNode:draw(p, lineW)
    local x, y = p.x, p.y
    if self.isGroup then
        w, h = self:getSize()
        love.graphics.rectangle("line", x - toggleBoxSize.x, y - lineHeight * 0.5, lineW + toggleBoxSize.x * 2, h, 10, 10, 3)
    else
        if self.toggleBox then
            self.toggleBox:draw(p)
        end
        if self.name then
            love.graphics.print(self.name, x + (self.toggleBox and 30 or 0), y)
        end
        if self.points then
            love.graphics.printf((self.points > 0 and "+" or "")..self.points, x, y, lineW, "right")
        end
    end
    if self.children then
        y = y + (self.isGroup and 0 or lineHeight * 2)
        x = x + (self.isGroup and 0 or childIndent)
        lineW = lineW - (self.isGroup and 0 or childIndent)
        for k, v in pairs(self.children) do
            v:draw(vector(x, y), lineW)
            cW, cH = v:getSize()
            y = y + cH + (v.isGroup and 0 or lineHeight)
        end
    end
end

BuildMenu = class()
function BuildMenu:init()
    self.root = BuildMenuNode()
    self.root:addChildren(build)
    self.root.isGroup = false
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
    love.graphics.setFont(font)
    self.root:draw(vector(100, 80), lineWidth)
    love.graphics.setColor(255, 255, 255, 255)
end