-- Main window
-- © zorg @ 2016 § ISC

-- This file includes the following:
-- - The functionality of the menubar.
-- - The CLI implementation of the menubar (exported into the CLI namespace.)
-- - The graphic representation of the menubar.

--------------------------------------------------------------------------------

-- Main Namespace (not exposed in any way, does its work & passes events.)
local Main = {}

Main.new = function(template)
	-- if a template is given, try to load it, else create an empty project.
end

--------------------------------------------------------------------------------

-- CLI Namespace
local CLI = {}
CLI._symbol = '' -- Symbol of the CLI "namespace" used as a key.
CLI._prefix = '' -- Name of the CLI "namespace", gets displayed in the prompt.

CLI.new = function(args)
	-- Check input.
end

CLI._parse = function(data)
	-- Separate command from parameters, and see if we have a command or not.
	local arg = {}
	for word in data:gmatch("%S+") do
		table.insert(arg, word)
	end
	local command = table.remove(arg,1)
	if CLI[command] then
		CLI[command](arg)
	else
		io.write(("No command '%s' found in mode '%s'."):format(
			command, CLI.currentMode))
	end
end

--------------------------------------------------------------------------------

-- GUI Namespace
local GUI

--------------------------------------------------------------------------------

local cli = require 'CLI'
cli:addMode(CLI)