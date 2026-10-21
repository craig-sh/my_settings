# hypernix classic desktop shell: waybar (one bar per monitor) + dunst +
# hyprlock + hypridle. Swap for hypernix-noctalia.nix in home-manager/hypernix.nix.
_:
let
  waybarModules = import ./waybar-modules.nix;
in
{
  imports = [
    ./shell-classic.nix
    (import ./hypridle.nix {
      lockTimeout = 600; # 10 min
      dpmsTimeout = 900; # 15 min
      suspendTimeout = 1800; # 30 min
    })
  ];

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
            "HDMI-A-1" = [
              "1"
              "2"
              "3"
              "4"
              "5"
            ];
          };
        };
      };
      otherBar = {
        output = "DP-3";

        modules-left = [
          "hyprland/workspaces"
          "hyprland/workspaces#windows"
        ];
        "hyprland/workspaces" = waybarModules.workspaces // {
          persistent-workspaces = {
            "DP-3" = [
              "6"
              "7"
              "8"
              "9"
              "10"
            ];
          };
        };
        "hyprland/workspaces#windows" = waybarModules.workspacesWindows;
      };
    };
  };
}
