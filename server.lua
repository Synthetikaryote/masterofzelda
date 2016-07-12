local socket = require "socket"
local binser = require "binser"

NetworkEntity = class()
function NetworkEntity:init()
    self.state = {}
end

Server = class()
function Server:init()
    self.address = "ec2-54-187-163-147.us-west-2.compute.amazonaws.com"
    self.port = 52135
    self.udp = socket.udp()
    self.udp:settimeout(0)
    self.udp:setpeername(self.address, self.port)

    self.networkEntities = {}
    self.playerEntity = NetworkEntity()

    self.udp:send(binser.serialize("requestId"))

    return self.playerEntity
end
function Server:update()
    -- send update
    if self.playerEntity.id then
        local request = {self.playerEntity.id, self.playerEntity.state}
        self.udp:send(binser.serialize("updateState", request))
    end

    repeat
        bindata, msg = udp:receive()

        if bindata then
            local cmd, data = binser.deserializeN(bindata, 2)
            if cmd == "assignId" then
                self.playerEntity.id = data.id
                self.playerEntity.state = state
                networkPlayers[self.playerEntity.id] = self.playerEntity
            else
                print("unrecognised command:", cmd)
            end
        elseif msg ~= "timeout" then 
            error("Network error: "..tostring(msg))
        end
    until not data
end