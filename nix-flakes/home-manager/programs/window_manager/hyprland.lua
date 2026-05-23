-- Hyprland config: shared pieces across machines.
-- Per-machine bits live in machine.lua (one of hypernix.lua / carbonnix.lua,
-- installed at ~/.config/hypr/machine.lua via xdg.configFile in each host's
-- home-manager module) and is loaded via the require call at the bottom.

local mainMod  = "SUPER"
local terminal = "kitty"
local menu     = "rofi -show drun"

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("NIXOS_OZONE_WL",   "1")
hl.env("XCURSOR_SIZE",     "16")
hl.env("HYPRCURSOR_SIZE",  "16")
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("hyprctl setcursor rose-pine-hyprcursor 16")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd("wl-clip-persist --clipboard regular")
    hl.dispatch(hl.dsp.exec_cmd("kitty hypr-startup-tmux-w1", { workspace = "1 silent" }))
    hl.dispatch(hl.dsp.exec_cmd("kitty",     { workspace = "2 silent" }))
    hl.dispatch(hl.dsp.exec_cmd("kitty",     { workspace = "7 silent" }))
    hl.dispatch(hl.dsp.exec_cmd("firefox",   { workspace = "6 silent" }))
    hl.dispatch(hl.dsp.exec_cmd("keepassxc", { workspace = "10 silent" }))
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 7,
        border_size = 4,

        col = {
            active_border   = "rgba(93C572EE)",
            inactive_border = "rgba(595959aa)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 2,
        rounding_power   = 2,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    scrolling = {
        follow_min_visible = 0.45,
        column_width       = 0.95,
        focus_fit_method   = 0,
    },

    misc = {
        on_focus_under_fullscreen = 2,
        force_default_wallpaper   = 1,
        disable_hyprland_logo     = false,
    },

    binds = {
        movefocus_cycles_fullscreen = true,
    },

    input = {
        kb_layout    = "us",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "",
        kb_rules     = "",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad     = { natural_scroll = false },
    },

    debug = {
        disable_logs = false,
    },
})

----------------------------
---- CURVES / ANIMATIONS ----
----------------------------

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 7,    bezier = "quick" })

-----------------
---- GESTURE ----
-----------------

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

---------------------------------
---- WORKSPACE / WINDOW RULES ----
---------------------------------

-- Gaming rules on workspace 8
hl.window_rule({ match = { class = "^(steam)$" }, workspace = "8" })
hl.window_rule({ match = { workspace = "8" },     float = true })

-- Music + org special workspaces
hl.window_rule({ match = { workspace = "special:music" }, tag = "+music" })
hl.window_rule({ match = { workspace = "special:music" }, float = true })
hl.window_rule({ match = { workspace = "special:org" },   tag = "+org" })
hl.window_rule({ match = { workspace = "special:org" },   float = true })

hl.workspace_rule({
    workspace = "special:music",
    on_created_empty = "[float; size (monitor_w*0.8) (monitor_h*0.8)] spotify",
})
hl.workspace_rule({
    workspace = "special:org",
    on_created_empty = "[float; size (monitor_w*0.8) (monitor_h*0.8)] kitty --hold -d ~/Documents/org vim todo.org",
})

-- No gaps / border when only one fullscreen window
hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0, border_size = 0 })

-- Per-workspace layouts
hl.workspace_rule({ workspace = "4",  layout = "scrolling" })
hl.workspace_rule({ workspace = "6",  layout = "scrolling" })
hl.workspace_rule({ workspace = "10", layout = "scrolling" })

-- Named ad-hoc rules
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

---------------------
---- KEYBINDINGS ----
---------------------

-- mod + shift: move window
hl.bind(mainMod .. " + SHIFT + H",         hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + L",         hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + K",         hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + J",         hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + backslash", hl.dsp.window.move({ monitor = "+1" }))

-- mod + digit: focus workspace; mod + shift + digit: move active window silently to workspace
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key "0"
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end

-- mod + alt: modify window
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + ALT + P", hl.dsp.layout("swapnext"))
hl.bind(mainMod .. " + ALT + C", hl.dsp.layout("cyclenext"))
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + ALT + M", hl.dsp.exec_cmd("hypr-toggle-monocle"))
hl.bind(mainMod .. " + ALT + W", hl.dsp.window.close())

-- mod + alt: resize (was binde - repeating)
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.resize({ x = 10,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + H", hl.dsp.window.resize({ x = -10, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + K", hl.dsp.window.resize({ x = 0,   y = -10, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.resize({ x = 0,   y = 10,  relative = true }), { repeating = true })

-- mod
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Space",  hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + S",      hl.dsp.exec_cmd("grimblast copy area"))

hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- cyclenext tiled works correctly in monocle layout (plain cyclenext does not)
hl.bind(mainMod .. " + C", hl.dsp.window.cycle_next({ tiled = true }))

hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd("dunstctl history-pop"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("dunstctl close"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("dunstctl close-all"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("rofi -modi clipboard:cliphist-rofi-img -show clipboard -show-icons"))

hl.bind(mainMod .. " + backslash",    hl.dsp.focus({ monitor = "+1" }))
hl.bind(mainMod .. " + bracketleft",  hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + bracketright", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + Tab",          hl.dsp.focus({ workspace = "previous_per_monitor" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace scratchpads
hl.bind(mainMod .. " + M", hl.dsp.workspace.toggle_special("music"))
hl.bind(mainMod .. " + O", hl.dsp.workspace.toggle_special("org"))

-- mod + ctrl: heavy
hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exit())
hl.bind(mainMod .. " + CTRL + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd("hypr-work-display"))
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd("hypr-personal-display"))
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

-- Mouse drag / resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-----------------------
---- PER-MACHINE BITS ----
-----------------------

-- pcall so booting on a host that hasn't shipped a machine.lua doesn't fail.
pcall(require, "machine")
