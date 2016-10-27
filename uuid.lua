-- "Good Enough" UUID Generator & Validator
-- © zorg @ 2016 § ISC

local fl = math.floor

-- If the server is standalone, use basic lua functions instead.
local setSeed = love and love.math.setRandomSeed or math.randomseed
local getRand = love and love.math.random        or math.random
local getTime = os.time
local getClck = love and love.timer.getTime      or os.clock

-- Converts a 32 significant-digit pseudorandom number into a 15 long hexstring.
local function generate(seed)
	setSeed(seed)
	local rand = getRand()
	--print(rand)
	local i,t,s,a = 1, {}, (("%32.32f"):format(rand)):sub(3, -4), 0.0
	--print(s)
	for c in s:gmatch"." do t[fl(i)]=(t[fl(i)] or 0.0)+tonumber(c); i=i+1 end
	--print(table.concat(t))
	for i=1, #t do a = a + fl(t[i] / 16); t[i] = t[i] % 16 end
	--print(table.concat(t))
	while a > 0.0 do t[#t + 1] = a % 16; a = fl(a / 16) end
	--print(table.concat(t))
	for i=1, #t do t[i] = ("%x"):format(t[i]) end
	--print(table.concat(t))
	if #t > 15 then for i=#t, 16, -1 do t[i] = nil end end
	--print(table.concat(t))
	return table.concat(t)
end

-- UUID format: xxxxxxxx-xxxx-zxxx-wyyy-yyyyyyyyyyyy
-- x:time, y:clock, w:checksum, z:literal.

local UUID = {}

UUID.generate = function()
	local t,c = generate(getTime()), generate(getClck())
	local chksum = ('%x'):format((tonumber(t,16) + tonumber(c,16)) % 16)
	return table.concat{t:sub( 1, 8),'-',t:sub( 9,12),'-z',t:sub(13,15),
						'-',chksum,c:sub( 1, 3),'-',c:sub( 4,15)}
end

UUID.validate = function(uuid)
	assert(type(uuid)=='string' and uuid,"no input given")
	if uuid:sub(15,15) ~= 'z' then return false end
	local t = table.concat{uuid:sub( 1, 8),uuid:sub(10,13),uuid:sub(16,18)}
	local c = table.concat{uuid:sub(21,23),uuid:sub(25,37)}
	return uuid:sub(20,20) == ('%x'):format((tonumber(t,16)+tonumber(c,16))%16)
end

return UUID