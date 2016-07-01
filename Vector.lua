require "class"

Vector = class()
function Vector:init(x, y)
    self.x = x
    self.y = y
end
function Vector:__add(o)
    return Vector(self.x + o.x, self.y + o.y)
end
function Vector:__sub(o)
    return Vector(self.x - o.x, self.y - o.y)
end
function Vector:__mul(o)
    return Vector(self.x * o, self.y * o)
end
function Vector:__div(o)
    return Vector(self.x / o, self.y / o)
end
function Vector:__unm()
    return Vector(-self.x, -self.y)
end
function Vector:lenSq()
    return self.x * self.x + self.y * self.y
end
function Vector:len()
    return math.sqrt(self:lenSq())
end
function Vector:normalized()
    return self / self:len()
end
