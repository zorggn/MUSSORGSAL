-- Track
-- © zorg @ 2016 § ISC

-- A track can hold notes.

local track = {}

track.getCell = function(trk, row)

end

local mtTrack = {__index = track}

local new = function()
	local trk = setmetatable({},mtTrack)

	trk.notes = {}

	return trk
end

return new