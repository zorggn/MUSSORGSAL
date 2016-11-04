-- Note
-- © zorg @ 2016 § ISC

-- A note represents one voice for an instrument.

local Note = {}

Note.getCell = function(note, row)

end

local mtNote = {__index = Note}

local new = function()
	local note = setmetatable({},mtNote)

	return note
end

return new