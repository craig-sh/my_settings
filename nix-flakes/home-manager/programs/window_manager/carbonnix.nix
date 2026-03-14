_: {
  programs.waybar = {
    settings = {
      mainBar = {
        modules-left = [
          "hyprland/workspaces"
          "hyprland/workspaces#windows"
        ];
        modules-center = [ ];
        modules-right = [
          "custom/spotify"
          "battery"
          "backlight"
          "network"
          "custom/tailscale"
          "disk"
          "memory"
          "cpu"
          "temperature"
          "pulseaudio"
          "clock"
          "tray"
        ];
        "hyprland/workspaces" = {
          persistent-workspaces = {
            "1" = [ ];
            "4" = [ ];
            "6" = [ ];
            "10" = [ ];
          };
        };
      };
    };
  };
  wayland.windowManager.hyprland.settings = {
    # See https://wiki.hypr.land/Configuring/Monitors/
    ################
    ### MONITORS ###
    ################
    "$monitor" = ",preferred,auto,auto";
  };

}
