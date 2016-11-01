--[[
	IP:port (6789 by default)
	Host -> server
	Connect -> client
--]]



-- Require networking library, and fix itself trying too hard to be a global.
local enet = require "enet"; _G.enet = nil

-- Require the event queue library
local event = require "eventqueue"

-- Require the uuid library for generation, but mostly validating.
local UUID = require 'uuid'



-- The uuid of our own client.
local uuid

-- Whether we're the server or not.
local isServer

-- The host object if we're acting as server;
-- treat the server as a peer object in all cases.
local _server, server

-- The local client separated from the other clients, them being peer objects.
local client

-- The list of client objects, whether we're the server or not; indexed by uuid.
local clients = {}

-- The amount of time between sending/receiving packets, and the timer.
local serviceInterval = 0.0 --0.05 -- 50 ms by default, 20 checks per second.
local serviceTimer = 0.0
local service = false



-- Module namespace.
local net = {}

net.init = function()

	-- event.log(enet.linked_version())

	-- Check whether we have an uuid generated or not;
	-- If we do, load it in, else generate one, and serialize it immediately.

	local file = '/usr/ini/uuid'

	if love.filesystem.exists(file) then
		print 'YES'
		--event.log "UUID file found."
		uuid = love.filesystem.read(file, 39)
		if not UUID.validate(uuid) then
			--event.log "Invalid UUID loaded!")
			return false
		end
		--event.log ("UUID file loaded from %s."):format(file)
	else
		print 'NO'
		print(love.filesystem.createDirectory('/usr/ini/'))
		--event.log "UUID file not found, generating..."
		uuid = UUID.generate()
		if not UUID.validate(uuid) then
			--event.log "Invalid UUID generated! (This shouldn't happen)"
			print "BAD CHECKSUM"
			return false
		end
		--event.log "UUID generated."
		love.filesystem.write(file, uuid, 39)
		--event.log ("UUID serialized to %s."):format(file)
	end
	return true
end

net.fine = function()
	-- Finalize stuff.

	server:destroy()
	for k,v in pairs(clients) do v:destroy() end
	collectgarbage()
	return true
end

net.host = function(port)
	-- We're going to host the server.

	client = enet.host_create() -- returns a host object!
	client:compress_with_range_coder()
	--if not client then event.log "net.connect -> Could not create client!" return false end

	--if port % 1 ~= 0 then event.log "net.host -> Port number not an integer!" return false end
	--if port < 0 or port > 65535 then event.log "net.host -> Port number not in range!" return false end
	_server = enet.host_create(("*:%d"):format(port), 64, 5, 0, 0) -- returns a host object!
	_server:compress_with_range_coder()
	--if not _server then event.log "net.host -> Could not create server!" return false end
	server = client:connect(("localhost:%d"):format(port), 5) -- returns a peer object!
	--if not server then event.log "net.connect -> Could not connect to server!" return false end

	isServer = true
	return true
end

net.connect = function(address, port)
	-- We're only a client, server is another instance.

	client = enet.host_create() -- returns a host object!
	client:compress_with_range_coder()
	--if not client then event.log "net.connect -> Could not create client!" return false end

	--if port % 1 ~= 0 then event.log "net.connect -> Port number not an integer!" return false end
	--if port < 0 or port > 65535 then event.log "net.connect -> Port number not in range!" return false end
	server = client:connect(("%s:%d"):format(address, port), 5) -- returns a peer object!
	--if not server then event.log "net.connect -> Could not connect to server!" return false end

	isServer = false
	return true
end

net.isServer = function() return isServer end

net.setUpdateInterval = function(s)
	serviceInterval = s
end

net.getUpdateInterval = function()
	return serviceInterval
end

net.getClient = function() return client, uuid end -- host object!
net.getServer = function() return server end -- peer object!


local lastIns, lastOuts = 0,0
local averageIns, averageOuts = {},{}
local avgIn, avgOut = 0,0
local averageLength = 10
local aptr = 0

net.getTraffic = function()
	local lc = client
	local sent = lc:total_sent_data()
	local recv = lc:total_received_data()
	return sent, recv, avgIn, avgOut
end

net.update = function(dt)

	-- Calculating sent/received byte deltas over service interval.
	local ins, outs = net.getTraffic()
	averageIns[aptr+1]  = (ins  - lastIns)
	averageOuts[aptr+1] = (outs - lastOuts)
	aptr = (aptr + 1) % averageLength
	avgIn = 0.0
	for i=1,#averageIns do avgIn = avgIn + averageIns[i] end
	avgOut = 0.0
	for i=1,#averageOuts do avgOut = avgOut + averageIns[i] end
	lastIns, lastOuts = ins, outs

	-- Timing sends/receives.
	serviceTimer = serviceTimer + dt
	if serviceTimer >= serviceInterval then
		service = true
		serviceTimer = serviceTimer - serviceInterval
	end

	-- Client update
	if service then
	do
		local event = client:service()
		if event then
			if event.type == 'connect' then
				print(("client: %s: %s %s (%s)"):format(event.type, tostring(event.peer:index()), tostring(event.peer:connect_id()), event.data))
			elseif event.type == 'disconnect' then
				print(("client: %s: %s %s (%s)"):format(event.type, tostring(event.peer:index()), tostring(event.peer:connect_id()), event.data))
			elseif event.type == 'receive' then
				print(("client: %s: %s %s (%s)"):format(event.type, tostring(event.peer:index()), tostring(event.peer:connect_id()), event.data))
				-- Process data in client callback.
				if net.client then net.client(client, event) end
			end
		end
	end


	-- Server update, if applicable.
	if isServer then
		local event = _server:service()
		if event then
			if event.type == 'connect' then
				print(("server: %s: %s %s (%s)"):format(event.type, tostring(event.peer:index()), tostring(event.peer:connect_id()), event.data))
			elseif event.type == 'disconnect' then
				print(("server: %s: %s %s (%s)"):format(event.type, tostring(event.peer:index()), tostring(event.peer:connect_id()), event.data))
			elseif event.type == 'receive' then
				print(("server: %s: %s %s (%s)"):format(event.type, tostring(event.peer:index()), tostring(event.peer:connect_id()), event.data))
				-- Process data in server callback.
				if net.server then net.server(_server, event) end
				_server:broadcast(('broadcast (%s) %s'):format(event.peer:index(), event.data))
			end
		end
	end
	end

	service = false

end

return net