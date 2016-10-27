-- User related data
-- © zorg @ 2016 § ISC

local User = {
	uuid, -- Generated once, used for authentication.
	address,   -- Either the received external IP, if connected to an online server; a LAN IP, or 127.0.0.1
	name, -- The chosen nick/name that shows up in chat, also default artist name.
}

User.preferences = {} -- TODO

User.keyBindings = {} -- TODO

-- saving(serializing), loading(deserializing), ...

return User