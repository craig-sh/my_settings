-- Classic desktop shell: waybar + dunst + rofi + hyprlock + cliphist.
-- Installed at ~/.config/hypr/shell.lua by shell-classic.nix and loaded by
-- hyprland.lua via require("shell").

local mainMod = "SUPER"
local menu    = "rofi -show drun"

local M = {}

function M.autostart()
    hl.exec_cmd("waybar")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("wl-clip-persist --clipboard regular")
end

---------------------
---- KEYBINDINGS ----
---------------------

hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + S",     hl.dsp.exec_cmd("grimblast copy area"))

hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("dunstctl history-pop"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("dunstctl close"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("dunstctl close-all"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons"))

hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("hyprlock"))

-- Media (locked: fires while screen is locked)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl -p spotify next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl -p spotify play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl -p spotify play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl -p spotify previous"),   { locked = true })

-- Volume / brightness (locked + repeating)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

return M
