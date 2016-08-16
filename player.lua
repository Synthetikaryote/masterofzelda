require "build"
local newAniDir = 0
local deg = 0

Player = class(Character)
function Player:init(id, sprite, hp, moveSpeed, invincibilityTime, attackDist, attackDamage, attackDamageTime)
    Character.init(self, id, sprite, hp, moveSpeed, invincibilityTime, attackDist, attackDamage, attackDamageTime)
    self.nextHitTime = 0
    self.nextHitQueued = false
    self.killCount = 0
    self.deaths = 0
    self.respawnTime = 0
    self.respawnQueued = false
    self.state.type = "Player"
    self.state.v = vector(0, 0)
    self.state.moving = false
end
function Player:update()
    if self.state.hp <= 0 then
        if self.animationName ~= "death" then
            self.animationName = "death"
            self.aniDir = 1
            self.aniFrame = 0
            self.aniLooping = false
            self.isAlive = false
            local animation = self.sprite.animations[self.animationName]
            local aniDuration = animation[2] * (1 / animation[3])
            self.respawnTime = (love.timer.getTime() + aniDuration * 2) * timeScale
            self.respawnQueued = true
        end
    end
    if self.respawnQueued and love.timer.getTime() * timeScale >= self.respawnTime and #self.coroutines == 0 then
        self:move(vector(5088, 4000))
        self.state.hp = self.maxHp
        self.deaths = self.deaths + 1
        self.respawnQueued = false
        self.isAlive = true
        self.aniLooping = true
    end

    if self.isAlive then
        if self.state.moving then
            self:move(self.state.p + self.state.v)
        end

        if love.timer.getTime() * timeScale <= self.attackEnds then
        elseif self.state.moving then
            self.nextHitQueued = false
            self.animationName = "walk"
        else
            self.nextHitQueued = false
            self.animationName = "walk"
            self.aniFrame = 0
            self.aniLastChange = love.timer.getTime() * timeScale
        end

        -- vector direction converted to an angle and mapped to the directions in the sprite
        if self.state.moving and self.animationName ~= "polearm" then
            self.facingDir = math.atan2(self.state.v.y, self.state.v.x)
            self.aniDir = self.sprite:getAniDirFromAngle(self.facingDir)
        end
    end

    Character.update(self)

    self.state.v = vector(0, 0)
end
function Player:draw()
    Character.draw(self)
end
function Player:keypressed(key, scancode, isRepeat)
    self:checkInput(scancode, nil)
end
function Player:gamepadpressed(gamepad, button)
    self:checkInput(nil, button)
end
function Player:checkInput(scancode, button)
end
function Player:didHitEntity(entity, causedDeath)
    if causedDeath then
        self.killCount = self.killCount + 1
    end
end