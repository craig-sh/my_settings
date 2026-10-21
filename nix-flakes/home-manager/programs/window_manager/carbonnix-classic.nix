# carbonnix classic desktop shell: waybar + dunst + hyprlock + hypridle.
# Swap for carbonnix-noctalia.nix in home-manager/carbonnix.nix.
_: {
  imports = [
    ./shell-classic.nix
    (import ./hypridle.nix {
      lockTimeout = 300; # 5 min
      dpmsTimeout = 600; # 10 min
      suspendTimeout = 1200; # 20 min
    })
  ];

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
}
