{ lib, ... }: {
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
  # Per-machine Hyprland Lua config. hyprland.lua loads this via
  # require("machine").
  xdg.configFile."hypr/machine.lua".text = lib.fileContents ./carbonnix.lua;
}
