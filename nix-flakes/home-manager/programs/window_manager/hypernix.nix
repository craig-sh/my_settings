_:
let
  modules = import ./waybar-modules.nix;
in
{
  programs.waybar = {
    settings = {
      mainBar = {
        output = "HDMI-A-1";
        modules-left = [
          "hyprland/workspaces"
          "hyprland/workspaces#windows"
        ];
        modules-center = [ ];
        modules-right = [
          #"custom/spotify" # This is possibly causing freezing because incorrect IPC communication
          "network"
          "disk"
          "memory"
          "cpu"
          "temperature"
          "pulseaudio"
          "clock"
          "tray"
        ];
      };
      otherBar = {
        output = "DP-3";
        modules-left = [
          "hyprland/workspaces"
          "hyprland/workspaces#windows"
        ];
        "hyprland/window" = modules.window;
        "hyprland/workspaces#windows" = modules.workspacesWindows;
      };
    };
  };
  wayland.windowManager.hyprland.settings = {
    # See https://wiki.hypr.land/Configuring/Monitors/
    ################
    ### MONITORS ###
    ################
    monitor = [
      "DP-3, 2560x1440@180, 0x0, 1.6, vrr, 2, bitdepth,10, cm, hdr, sdrbrightness, 1.33, sdrsaturation, 1.12"
      "HDMI-A-1, 2560x1440@60, auto-left, 1.6"
    ];
    bind = [
      # game mode
      "$mainMod CTRL, g, exec, hyprctl keyword  monitor DP-3, 2560x1440@180, 0x0, 1, vrr, 1, bitdepth,10, cm, hdr, sdrbrightness, 1.33, sdrsaturation, 1.12" # game mode
    ];
    workspace = [
      "1, persistent:true monitor:HDMI-A-1"
      "2, persistent:true monitor:HDMI-A-1"
      "3, persistent:true monitor:HDMI-A-1"
      "4, persistent:true monitor:HDMI-A-1"
      "5, persistent:true monitor:HDMI-A-1"
      "6, persistent:true monitor:DP-3"
      "7, persistent:true monitor:DP-3"
      "8, persistent:true monitor:DP-3"
      "9, persistent:true monitor:DP-3"
      "10, persistent:true monitor:DP-3"
    ];
  };
}
