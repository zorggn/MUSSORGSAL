-- MUSSORGSAL Multi-User Sound Studio Originally Rapid Gamedev Software As LöVe
-- (Also Danish for "mouse grief floor", even though it's highly irrelevant...)
-- © zorg, Nixola @ 2016 § ISC

-- Uses the following libraries:
--[[
	-- robingvx  - bitser (serializing)
	-- vrld      - HUMP/gamestates (using pre-force-update version)
	-- lpghatguy - QueueableSource.lua (with löve versions prior to 0.11.0... if we want to support them, that is.)
	-- Ikroth    - sone
--]]

local net = require 'net'



function love.load(args)
	print(table.concat({love.getVersion()},'.'):sub(0,6))

	net.init()

	if args[2] == '-s' then
		net.host(6789)
	else
		net.connect('84.3.28.160',6789)
	end

	love.window.setMode(800, 600, {vsync=true})
	love.window.setTitle("Multi-User Sound Studio (Originally Rapid Gamedev Software as LÖVE)")
	love.graphics.setLineStyle('rough')
end



function love.keypressed(k,s)
	net.getServer():send(('kd: %s, %s'):format(k,s))
end

function love.keyreleased(k,s)
	net.getServer():send(('ku: %s, %s'):format(k,s))
end



local peerCursors = {}
function net.client(client, event)
	local b,i,k,x,y = event.data:match('(%S*)%s(%S*)%s(%S*)%s(%S*)[,](%S*)')
	i = i:match('%D(%d*)%D')
	if k == 'mp:' then
		peerCursors[i] = {x,y}
	end
end



local md,mt,mx,my = 1/20,0.0,0,0
function love.update(dt)
	-- Send mouse position once in a while, for show.
	mt = mt + dt
	if mt >= md then
		local x,y = love.mouse.getPosition()
		if x ~= mx and y ~= my then
			net.getServer():send(('mp: %d,%d'):format(x,y))
			mx, my = x, y
		end
		mt = mt - md
	end

	-- Update network stuff
	net.update(dt)
end



function love.draw()
	love.graphics.setColor(255,255,255)
	love.graphics.print(net.isServer() and 'Server' or 'Client',0,0)
	local it,ot,id,od = net:getTraffic()
	love.graphics.print(('Inbound  bytes total: %dB'):format(it),0,12)
	love.graphics.print(('Outbound bytes total: %dB'):format(ot),0,24)
	love.graphics.print(('Inbound  bytes delta: %dB/s'):format(id),0,36)
	love.graphics.print(('Outbound bytes delta: %dB/s'):format(od),0,48)
	for k,v in pairs(peerCursors) do
		love.graphics.setColor(0,127,255)
		love.graphics.circle('fill',v[1],v[2],10)
		love.graphics.setColor(255,255,255)
		love.graphics.printf(k,v[1]-5,v[2]-5,10,'center')
	end
end



love.run = function()
	if love.math then
		love.math.setRandomSeed(os.time())
	end
 
	if love.load then love.load(arg) end
 
	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0.0    -- delta time
 
	local tr = 1/100  -- tick rate
	local fr = 1/75   -- frame rate

	local da = 0.0    -- draw accumulator
	local ua = 0.0    -- update accumulator
 
	-- Main loop time.
	while true do
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end
 
		-- Update dt, as we'll be passing it to update
		if love.timer then
			love.timer.step()
			dt = love.timer.getDelta()
			da = da + dt
			ua = ua + dt
		end
 
		-- Call audio
		if love.atomic then love.atomic(dt) end

		-- Call update
		if ua > tr then
			if love.update then
				love.update(tr) -- will pass 0 if love.timer is disabled
			end
			ua = ua % tr
		end
 
		-- Call draw
		if da > fr then
			if love.graphics and love.graphics.isActive() then
				love.graphics.clear(love.graphics.getBackgroundColor())
				love.graphics.origin()
				if love.draw then love.draw() end -- no interpolation
				love.graphics.present()
			end
			da = da % fr
		end
 
		-- Optimal sleep time, anything higher does not go below 0.40 % cpu
		-- utilization; 0.001 results in 0.72 %, so this is an improvement.
		if love.timer then love.timer.sleep(0.002) end
	end
end