biggestPivotWidth = 0
biggestPivotHeight = 0

local images = {}

Sprite = class()
function Sprite:init(filename, animations, aniDirs)
    local image = images[filename]
    if not image then
        image = love.graphics.newImage(filename)
        images[filename] = image
    end
    self.spritesheet = image
    self.spritesheet:setFilter("nearest", "nearest")
    self.animations = animations
    self.aniDirs = aniDirs
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

        biggestPivotWidth = math.max(biggestPivotWidth, ani[7])
        biggestPivotHeight = math.max(biggestPivotHeight, ani[8])
    end
    leftXOffset = math.max(leftXOffset, biggestPivotWidth)
    topYOffset = math.max(topYOffset, biggestPivotHeight)
end
function Sprite:getAniDirFromAngle(a)
    deg = (math.deg(a) + 90) % 360
    for k, v in pairs(self.aniDirs) do
        low, high = v[1], v[2]
        if low > high then
            if deg >= low or deg < high then
                return k
            end
        end
        if deg >= low and deg < high then
            return k
        end
    end
end