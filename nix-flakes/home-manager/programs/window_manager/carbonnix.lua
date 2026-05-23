-- Per-machine Hyprland config for carbonnix (laptop).
-- Loaded by hyprland.lua via require("machine"); installed at
-- ~/.config/hypr/machine.lua by home-manager.

------------------
---- MONITORS ----
------------------

-- Catch-all rule: any output gets its preferred mode + auto placement / scale.
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
