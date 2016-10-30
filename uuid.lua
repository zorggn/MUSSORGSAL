-- "Good Enough" UUID Generator & Validator
-- © zorg @ 2016 § ISC

local fl = math.floor

-- Lua sleep functionality for delay.
os.sleep = function(n) local t0=os.clock() while os.clock()-t0<=n do end end

-- If the server is standalone, use basic lua functions instead.
local setSeed = love and love.math.setRandomSeed or math.randomseed
local getRand = love and love.math.random        or math.random
local getTime = os.time
local getClck = love and love.timer.getTime      or os.clock
local sleep = love and love.timer.sleep          or os.sleep

-- Converts a 32 significant-digit pseudorandom number into a 15 long hexstring.
-- Correction: converts a 16-digit prn into a 8-digit hex string, because löve.
local function generate(seed)
	setSeed(seed)
	local rand = getRand()
	--print(rand)
	local i,t,s,a = 1, {}, (("%16.16f"):format(rand)):sub(3), 0.0
	--print(s)
	for c in s:gmatch"." do t[fl(i)]=(t[fl(i)] or 0.0)+tonumber(c); i=i+.5 end
	--print(table.concat(t))
	for i=1, #t do a = a + fl(t[i] / 16); t[i] = t[i] % 16 end
	--print(table.concat(t))
	while a > 0.0 do t[#t + 1] = a % 16; a = fl(a / 16) end
	--print(table.concat(t))
	for i=1, #t do t[i] = ("%X"):format(t[i]) end
	--print(table.concat(t))
	if #t > 8 then for i=#t, 9, -1 do t[i] = nil end end
	--print(table.concat(t))
	return table.concat(t)
end

-- UUID format: xxxxxxxx-xxxx-zxxx-wyyy-yyyyyyyyyyyy-xy
-- x:time, y:clock, w:checksum, z:literal.

local UUID = {}

UUID.generate = function()
	-- Since löve has issues with prng significant digits, this is necessary.
	local t,k = generate(getTime()), generate(getClck())
	sleep(1.0)
	local T,K = generate(getTime()), generate(getClck())
	local a,b,c,d
	a,b,c,d = tonumber(t,16), tonumber(k,16), tonumber(T,16), tonumber(K,16)
	local checksum = ('%x'):format((a+b+c+d) % 16)
	return table.concat{
		t:sub(1,8), '-', T:sub(1,4), '-z',
		T:sub(5,7), '-', checksum,
		k:sub(1,3), '-', k:sub(4,8),
		K:sub(1,7), '-', T:sub(8,8), K:sub(8,8)}
end

UUID.calcChecksum = function(s)
	local a = s:sub( 1, 8)
	local b = table.concat{s:sub(10,13), s:sub(16,18), s:sub(38,38)}
	local c = table.concat{s:sub(21,23), s:sub(25,29)}
	local d = table.concat{s:sub(30,36), s:sub(39,39)}
	a,b,c,d = tonumber(a,16), tonumber(b,16), tonumber(c,16), tonumber(d,16)
	return ('%x'):format((a+b+c+d) % 16)
end

UUID.validate = function(s)
	if not type(s)=='string' then return false end
	if s:sub(15,15) ~= 'z'   then return false end
	local checksum = UUID.calcChecksum(s)
	return s:sub(20,20) == checksum
end

return UUID