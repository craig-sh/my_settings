{ ... }:
{
  programs.waybar = {
    settings = {
      mainBar = {
        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ ];
        modules-right = [
          "battery"
          "backlight"
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
    };
  };
  wayland.windowManager.hyprland.settings = {
    # See https://wiki.hypr.land/Configuring/Monitors/
    ################
    ### MONITORS ###
    ################
    "$monitor" = ",preferred,auto,auto";
    workspace = [
      "1, persistent:true" # monitor:\"DP-2\""
      "2, persistent:true"
      "3, persistent:true"
      "4, persistent:true"
      "5, persistent:true"
      "6, persistent:true"
      "7, persistent:true"
      "8, persistent:true"
      "9, persistent:true"
      "10, persistent:true"
    ];
  };

}
