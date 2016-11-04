-- Track
-- © zorg @ 2016 § ISC

-- A track can hold notes. It's monophonic.

local track = {}

track.getCell = function(trk, row)

end

local mtTrack = {__index = track}

local new = function()
	local trk = setmetatable({},mtTrack)

	trk.clips = {}

	return trk
end

return new