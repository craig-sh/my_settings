{ config, pkgs, ... }:
let
  waybarModules = import ./waybar-modules.nix;
  mediaStatus = pkgs.writeShellScriptBin "mediastatus" ''
    # From https://github.com/Alexays/Waybar/issues/34
    player_status=$(playerctl -p spotify status 2> /dev/null)
    if [ "$player_status" = "Playing" ]; then
        echo "󰝚 $(playerctl -p spotify metadata artist) - $(playerctl -p spotify metadata title)"
    elif [ "$player_status" = "Paused" ]; then
        echo " $(playerctl -p spotify metadata artist) - $(playerctl -p spotify metadata title)"
    fi
  '';
in
{
  home.packages = with pkgs; [
    waybar
    pavucontrol # For pulseaudio control
    networkmanagerapplet # For network management
    mediaStatus # Custom spotify
  ];

  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 26;

        "hyprland/workspaces" = waybarModules.workspaces;
        "hyprland/workspaces#windows" = waybarModules.workspacesWindows;
        "hyprland/window" = waybarModules.window;

        clock = {
          format = "{:%Y-%m-%d\n   %H:%M}";
          format-alt = "{:%Y-%m-%d}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        cpu = {
          format = " {usage}%";
          tooltip = false;
        };

        memory = {
          format = " {}%";
          interval = 30;
        };
        disk = {
          interval = 30;
          format = "󰋊 {percentage_used}% ";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-icons = [
            "󰁻"
            "󰁽"
            "󰁿"
            "󰂁"
            "󱟢"
          ];
        };

        backlight = {
          format = "󰃝 {percent}%";
        };

        network = {
          format-wifi = "󰖩 {essid} {signalStrength}%\n{bandwidthDownBytes}|{bandwidthUpBytes}";
          format-ethernet = "󰱓 {bandwidthDownBytes}\n  {bandwidthUpBytes}";
          format-disconnected = "󰖪 Disconnected";
          tooltip-format = "{ifname}: {ipaddr}";
          interval = 5;
        };
        "custom/tailscale" = {
          exec = "echo '󰒄'";
          exec-if = "tailscale status";
          interval = 5;
          format = "{}";
          hide-empty-text = true;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-bluetooth = "{icon}  {volume}%";
          format-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            speaker = "";
            speaker-muted = "󰝟";
            default = [
              ""
              ""
            ];
            default-muted = [
              "󰝟"
              "󰝟"
            ];
          };
          on-click = "pavucontrol";
        };

        tray = {
          icon-size = 21;
          spacing = 10;
        };
        "custom/spotify" = {
          format = " {}";
          max-length = 40;
          exec = "mediastatus";
          exec-if = "pgrep spotify";
          interval = 5;
        };
        "wlr/taskbar" = {
          "format" = "{icon}";
          "icon-size" = 16;
          "tooltip-format" = "{title}";
          "on-click" = "activate";
          "on-click-middle" = "close";
          "ignore-list" = [ ];
          "all-outputs" = false;
        };
      };
    };
    style = builtins.readFile ./waybar_style.css;
  };
}
