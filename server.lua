local socket = require "socket"
local binser = require "binser"

-- this isn't working.  working around vector serialization below
binser.register(getmetatable(vector), "vector", function(vec) return vec.x, vec.y end, function(x, y) return vector(x, y) end)

NetworkEntity = class()
function NetworkEntity:init()
    self.nid = nil
    self.state = {}
end

Server = class()
function Server:init(player)
    self.address = "ec2-54-187-163-147.us-west-2.compute.amazonaws.com"
    self.port = 52135
    self.udp = socket.udp()
    self.udp:settimeout(0)
    self.udp:setpeername(self.address, self.port)

    self.networkEntities = {}
    self.playerEntity = player

    self.heartbeatFrequency = 1
    self.nextHeartbeat = 0 --right away

    self.udp:send(binser.serialize("requestId", {state=self.playerEntity.state}))
end
function Server:update()
    if self.playerEntity.nid and love.timer.getTime() >= self.nextHeartbeat then
        self.udp:send(binser.serialize("heartbeat"))
        self.nextHeartbeat = love.timer.getTime() + self.heartbeatFrequency
    end

    repeat
        bindata, msg = self.udp:receive()

        if bindata then
            local cmd, data = binser.deserializeN(bindata, 2)
            if cmd == "assignId" then
                self.playerEntity.nid = data.nid
                self.networkEntities[self.playerEntity.nid] = self.playerEntity
                log("received network id "..self.playerEntity.nid)
            elseif cmd == "newEntity" then
                local entity = nil
                if data.state.type == "Player" then
                    entity = createPlayer(data.nid, data.state)
                end
                if entity then
                    self.networkEntities[entity.nid] = entity
                else
                    log("newEntity: unrecognised type \""..(data.state.type or "nil").."\"")
                end
            elseif cmd == "updateEntity" then
                -- log("updateEntity "..data.nid)
                local entity = self.networkEntities[data.nid]
                if not entity then
                    log("server tried to update entity I don't have: "..data.nid)
                else
                    entity.state = data.state
                    if entity.state.type == "Player" then
                        entity.state.p = vector(entity.state.p.x, entity.state.p.y)
                        entity:move(entity.state.p)
                        entity.state.v = vector(entity.state.v.x, entity.state.v.y)
                    end
                end
            elseif cmd == "removeEntity" then
                local entity = self.networkEntities[data.nid]
                if entity ~= nil then
                    if entity.state.type == "Player" or entity.state.type == "Enemy" or entity.state.type == "Character" then
                        entity:despawn()
                    end
                    self.networkEntities[data.nid] = nil
                else
                    log("entity to remove was not found: nid "..data.nid)
                end
            elseif cmd == "hitEntity" then
                local entity = self.networkEntities[data.nid]
                if entity ~= nil then
                    if entity.state.type == "Player" or entity.state.type == "Enemy" or entity.state.type == "Character" then
                        local source = self.networkEntities[data.sourceNid]
                        if source ~= nil then
                            local wasAlive = entity.isAlive
                            entity:gotHit(source, data.damage, data.damageEffectDuration, data.knockbackDist, data.stunDuration)
                            if source.state.type == "Player" then
                                source:didHitEntity(entity, wasAlive and not entity.isAlive)
                            end
                        else
                            log("source entity of the hit was not found: source nid "..data.sourceNid..", hit nid "..data.nid)
                        end
                    end
                else
                    log("entity to hit was not found: nid "..data.nid)
                end
            else
                log("unrecognised command: \""..cmd.."\"")
            end
        elseif msg ~= "timeout" then 
            error("Network error: "..tostring(msg))
        end
    until not bindata
end

function createPlayer(nid, state)
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
    local player = Player("player"..nid, playerSprite, 100,    200,       0.5,                 100,        50,            0.1)
    player.nid = nid
    player.state = state
    player.state.p = vector(state.p.x, state.p.y)
    player.state.v = vector(state.v.x, state.v.y)
    player:move(player.state.p)
    characters[player.id] = player
    return player
end

function Server:attackLocation(p, r, damage, damageEffectDuration, knockbackDist, stunDuration)
    log("attackLocation")
    self.udp:send(binser.serialize("attackLocation", {p=p, r=r, damage=damage, damageEffectDuration=damageEffectDuration, knockbackDist=knockbackDist, stunDuration=stunDuration}))
end

function Server:updateEntity(nid, state)
    self.udp:send(binser.serialize("updateEntity", {nid=nid, state=state}))
end

function Server:serialize(cmd, data)
    return binser.serialize(cmd, data)
end

function Server:send(preSerialized)
    self.udp:send(preSerialized)
end