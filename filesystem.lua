-- Filesystem related functionality
-- © zorg @ 2016 § ISC

-- The below function is only needed for two reasons:
-- - Dropping sample folders that may be elsewhere on the filesystem will work,
--   but only until the program is closed;
--   if we save the dropped path, however, this can load it again, without need
--   for the user to drop the folder each time.
-- - Load/Save dialogs that do need to use io functions will also return a
--   path like the above; allowing us to mount the file directly... hopefully.

local ffi = require "ffi"
local liblove = ffi.os == "Windows" and ffi.load("love") or ffi.C

ffi.cdef[[
	int PHYSFS_mount(
		const char * newDir, const char * mountPoint, int appendToPath
	)
	const char * PHYSFS_getLastError(void)
]]

local Fsys = {}

Fsys.mount = function(path, mountPoint, appendToPath)
	local result = liblove.PHYSFS_mount(path, mountPoint, appendToPath)
	if result ~= 0 then 
		return true
	else
		return liblove.PHYSFS_getLastError()
	end
end

-- Load -> file dialog (project files allowed only)
-- Save -> overwrite current file
-- Save as -> file dialog (save as project file)
-- Import -> file dialog (import-supported 3rd party filetypes only)
-- Export -> file dialog (export-supported 3rd party filetypes only)

-- Store a file in the program directory, where we keep default dirs saved.
-- Load those back every time the program is started up.

-- Dialog creation will happen with the "root" being the last saved dir path
-- depending on the called function -> separate last-folder paths per function.

-- Dialog should allow at least these:
-- Going up one level
-- Going inside folders
-- Selecting files
-- Showing only relevant files (with the correct extension)
-- "Sidebar" - allowing us to choose between:
-- Program save folder (löve filesystem)
-- Program exec folder (löve filesystem + getsourcebasedir)
-- Any folder (lua io + PHYSFS_mount)
-- Favourites "folder"? user can choose these -> stored
-- Last visited (and used something from there) "folder"? -> stored