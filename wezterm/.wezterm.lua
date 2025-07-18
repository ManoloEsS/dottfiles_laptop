-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = "tokyonight-storm"
config.hide_mouse_cursor_when_typing = true
config.hide_tab_bar_if_only_one_tab = true
config.enable_tab_bar = true
config.window_background_opacity = 0.93

-- Font fallback list for missing glyphs:
config.keys = {
	{ key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
}
term = "xterm-256color"
-- and finally, return the configuration to wezterm
return config
