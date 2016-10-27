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

local uuid

function love.load(args)

	print(love.getVersion())

	uuid = require 'uuid'
	-- If UUID exists, load it, else generate one.
	print(uuid.generate())

	love.window.setMode(1000, 1000, {vsync=true})
	love.window.setTitle("Multi-User Sound Studio (Originally Rapid Gamedev Software as LÖVE)")

end