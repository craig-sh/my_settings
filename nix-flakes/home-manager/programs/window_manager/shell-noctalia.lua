-- Noctalia v5 desktop shell.
-- Installed at ~/.config/hypr/shell.lua by shell-noctalia.nix and loaded by
-- hyprland.lua via require("shell"). Host-specific workspace persistence is
-- loaded from shell_host.lua at the bottom.

local mainMod = "SUPER"
local ipc     = "noctalia msg "

local M = {}

function M.autostart()
    hl.exec_cmd("noctalia")
end

-----------------------------
---- WORKSPACE GLYPH NAMES ----
-----------------------------

-- Noctalia's workspaces widget shows these via label_source = "name"
-- (same glyphs as waybar-modules.nix format-icons).
local workspace_names = {
    [1] = "", -- terminals
    [2] = "", -- coding
    [3] = "󰆩", -- scratchpad
    [4] = "󰭻", -- comms
    [5] = "5",
    [6] = "󰖟", -- browser
    [7] = "󰢹", -- remote sessions
    [8] = "󰊴", -- gaming
    [9] = "9",
    [10] = "󰘨", -- long running
}
for id, name in pairs(workspace_names) do
    hl.workspace_rule({ workspace = tostring(id), default_name = name })
end

---------------------
---- KEYBINDINGS ----
---------------------

hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mainMod .. " + V",     hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))
hl.bind(mainMod .. " + A",     hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind(mainMod .. " + S",     hl.dsp.exec_cmd(ipc .. "screenshot-region"))

-- Notifications (dunst equivalents: history, dismiss, dismiss all)
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center notifications"))
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(ipc .. "notification-clear-active"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(ipc .. "notification-clear-active"))

hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd(ipc .. "session lock"))

-- Media (locked: fires while screen is locked)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd(ipc .. "media next"),     { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd(ipc .. "media toggle"),   { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd(ipc .. "media toggle"),   { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd(ipc .. "media previous"), { locked = true })

-- Volume / brightness (locked + repeating); Noctalia shows its OSD
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(ipc .. "volume-up"),       { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(ipc .. "volume-down"),     { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(ipc .. "volume-mute"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd(ipc .. "mic-mute"),        { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(ipc .. "brightness-up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"), { locked = true, repeating = true })

-----------------------------
---- WINDOW / LAYER RULES ----
-----------------------------

hl.window_rule({
    match = { class = "dev.noctalia.Noctalia" },
    float = true,
    size  = { 1080, 920 },
})

-- Blur Noctalia surfaces and let Noctalia run its own layer animations.
hl.layer_rule({
    name  = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
    },
    no_anim      = true,
    ignore_alpha = 0.5,
    blur         = true,
    blur_popups  = true,
})

pcall(require, "shell_host")

return M
