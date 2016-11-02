-- CLI Interface
-- © zorg, Nixola @ 2016 § ISC

-- TODO: - Maybe the CLI format should be the same as the internal event
--         and network message format as well, which would mean separating 
--         the commands and such out from this file.
--       - Actually, all data structures could define their own event types.
--       - Test the CLI modes on OS X and Linux as well, with others.

-- The prompt symbol.
local prompt  = '>'

-- OS specific newlines.
local nl

-- If this flag is set, the prompt should switch to "continuous input" mode.
-- It's used with commands requiring multiple lines of input.
local continued = false

-- Whether a session is opened to others, or closed/local/private.
local shared = false
local sharedPrefix = {[true] = '+', [false] = '-'}

-- Supported modes and prompt prefixes.
local modes = {'', 'o', 'c', 's', 'd', 'i', 'f', 'p', 'n', 'a', 'r', 't', 'l'}

local mode = {
	-- These are their long prefix names
	'', 'options', 'chat', 'session'
	'dsp', 'instrument', 'effect',
	'pattern', 'note', 'automation',
	'arranger', 'track', 'label'
	-- mode should be an array of arrays containing all possible command
	-- strings, and functions that deal with them.
}

-- Create a thread to do all the CLI input uninterrupted.
local threadData = [[
	local channel = ... 
	local readMode
	local data
	while true do

		-- pull data relating to whether we allow io.read or not.
		-- or at least, whether we process the input read or not.

		data = io.read()
		if data then
			channel:push(data)
			data = nil
		end
	end
]]

-- Threading and message passing.
local thread, channel

-- Class
local CLI = {}

CLI.init = function()
	-- Set up OS-specific variables.
	local os = love.system.getOS()
	if os == 'Windows' then
		nl = '\r\n'
	elseif os == 'OS X' then
		nl = '\r'
	else--if os == 'Linux' then
		nl = '\n'
	end

	-- Print out title.
	local version = 'v0.0.1'
	local currentYear = os.date('%Y', os.time())
	local title = table.concat({
		"MUSSORGSAL - Multi-User Sound Studio",
		version, "by zorg", ("2016-%s"):format(currentYear), "License: ISC"
	}," - ")
	io.write(('%s%s'):format(title, nl))

	-- Write out prompt.
	io.write(prompt)

	-- Create thread to read input, and messaging channel.
	channel = love.thread.newChannel()
	thread  = love.thread.newThread(threadData)
	thread:start(channel)
end

CLI.update = function(dt)
	-- Get data from the input thread.
	if channel:getCount() > 0 then
		local data = channel:pop()

		-- TODO: Implement per-mode command handling, as stated above.

	end
end