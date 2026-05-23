{ lib, ... }:
let
  waybarModules = import ./waybar-modules.nix;
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
        "hyprland/workspaces" = {
          persistent-workspaces = {
            "1" = [ ];
            "4" = [ ];
            "6" = [ ];
            "10" = [ ];
          };
        };
      };
      otherBar = {
        output = "DP-3";

        modules-left = [
          "hyprland/workspaces"
          "hyprland/workspaces#windows"
        ];
        "hyprland/workspaces" = waybarModules.workspaces;
        "hyprland/workspaces#windows" = waybarModules.workspacesWindows;
      };
    };
  };
  # Per-machine Hyprland Lua config (monitors, workspace assignments,
  # host-specific binds). hyprland.lua loads this via require("machine").
  xdg.configFile."hypr/machine.lua".text = lib.fileContents ./hypernix.lua;
}
