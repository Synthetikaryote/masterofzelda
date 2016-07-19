local socket = require "socket"
local binser = require "binser"

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

    self.udp:send(binser.serialize("requestId"))
end
function Server:update()
    -- send update
    if self.playerEntity.nid then
        local request = {nid=self.playerEntity.nid, state=self.playerEntity.state}
        self.udp:send(binser.serialize("updateEntity", request))
    end

    repeat
        bindata, msg = self.udp:receive()

        if bindata then
            local cmd, data = binser.deserializeN(bindata, 2)
            if cmd == "assignId" then
                self.playerEntity.nid = data.nid
                self.playerEntity.state = data.state
                self.networkEntities[self.playerEntity.nid] = self.playerEntity
                log("received network id "..self.playerEntity.nid)
            elseif cmd == "newEntity" then
                log("newEntity "..data.nid)
                local entity = NetworkEntity()
                entity.nid = data.nid
                entity.state = data.state
                self.networkEntities[entity.nid] = entity
            elseif cmd == "updateEntity" then
                log("updateEntity "..data.nid)
                local entity = self.networkEntities[data.nid]
                if not entity then
                    log("server tried to update entity I don't have: "..data.nid)
                else
                    entity.state = data.state
                end
            elseif cmd == "removeEntity" then
                log("removeEntity "..data.nid)
                self.networkEntities[data.nid] = nil
            else
                log("unrecognised command: \""..cmd.."\"")
            end
        elseif msg ~= "timeout" then 
            error("Network error: "..tostring(msg))
        end
    until not bindata
end