function love.conf(t)

	t.identity = "MUSSORGSAL"

	-- The LÖVE version this game was made for.
	t.version = "0.10.2"

	-- Console
	t.console = true

	-- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
	t.accelerometerjoystick = false

	-- True to save files (and read from the save directory) in external storage on Android (boolean)
	t.externalstorage = true

	-- Enable gamma-correct rendering, when supported by the system (boolean)
	t.gammacorrect = false              

	-- The window gets programatically created in either the default, or the given package init function.
	t.window = false

	t.modules.audio    = true          -- Enable the audio module (boolean)
	t.modules.event    = true          -- Enable the event module (boolean)
	t.modules.graphics = true          -- Enable the graphics module (boolean)
	t.modules.image    = true          -- Enable the image module (boolean)
	t.modules.joystick = true          -- Enable the joystick module (boolean)
	t.modules.keyboard = true          -- Enable the keyboard module (boolean)
	t.modules.math     = true          -- Enable the math module (boolean)
	t.modules.mouse    = true          -- Enable the mouse module (boolean)
	t.modules.physics  = true          -- Enable the physics module (boolean)
	t.modules.sound    = true          -- Enable the sound module (boolean)
	t.modules.system   = true          -- Enable the system module (boolean)
	t.modules.timer    = true          -- Enable the timer module (boolean, Disabling it will result in 0 delta time in love.update)
	t.modules.touch    = true          -- Enable the touch module (boolean)
	t.modules.video    = true          -- Enable the video module (boolean)
	t.modules.window   = true          -- Enable the window module (boolean)
	t.modules.thread   = true          -- Enable the thread module (boolean)

end