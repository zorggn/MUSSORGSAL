-- Pattern
-- © zorg @ 2016 § ISC

-- A pattern can hold an arbitrary number of tracks.

local pattern = {}

pattern.getCell = function(pat, row)

end

local mtPattern = {__index = pattern}

local new = function()
	local pat = setmetatable({},mtPattern)

	pat.tracks = {}

	return pat
end

return new