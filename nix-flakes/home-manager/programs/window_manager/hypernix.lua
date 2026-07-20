-- Per-machine Hyprland config for hypernix (desktop, DP-3 + HDMI-A-1).
-- Loaded by hyprland.lua via require("machine"); installed at
-- ~/.config/hypr/machine.lua by home-manager.

------------------
---- MONITORS ----
------------------

hl.monitor({
    output        = "DP-3",
    mode          = "2560x1440@180",
    position      = "0x0",
    scale         = 1.6,
    vrr           = 2,
    bitdepth      = 10,
    cm            = "hdr",
    sdrbrightness = 0.33,
    sdrsaturation = 1.0,
    sdr_max_luminance = 1156,
    sdr_min_luminance = 0.0513,
})

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "2560x1440@60",
    position = "auto-left",
    scale    = 1.6,
})

-----------------------------------
---- WORKSPACES BOUND TO MONITORS ----
-----------------------------------

-- Persistence is intentionally driven by waybar's persistent-workspaces
-- (see hypernix.nix), not Hyprland's persistent = true. When Hyprland marks
-- a workspace persistent, waybar's active-only filter on the taskbar module
-- treats every workspace as always-visible and renders windows from all
-- workspaces on that monitor at once.
hl.workspace_rule({ workspace = "1",  monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "2",  monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "3",  monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "4",  monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "5",  monitor = "HDMI-A-1" })
hl.workspace_rule({ workspace = "6",  monitor = "DP-3" })
hl.workspace_rule({ workspace = "7",  monitor = "DP-3" })
hl.workspace_rule({ workspace = "8",  monitor = "DP-3" })
hl.workspace_rule({ workspace = "9",  monitor = "DP-3" })
hl.workspace_rule({ workspace = "10", monitor = "DP-3" })

---------------
---- BINDS ----
---------------

-- Game mode: re-apply DP-3 with full VRR + higher SDR saturation
hl.bind("SUPER + CTRL + G", function()
    hl.monitor({
        output        = "DP-3",
        mode          = "2560x1440@180",
        position      = "0x0",
        scale         = 1,
        vrr           = 1,
        bitdepth      = 10,
        cm            = "hdr",
        sdrbrightness = 0.33,
        sdrsaturation = 1.0,
        sdr_max_luminance = 1156,
        sdr_min_luminance = 0.0513,
    })
end, { description = "Game mode (DP-3 @180Hz, full VRR)" })
