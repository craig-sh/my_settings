{ pkgs, config, lib, ... }:
let
  setPersonalDisplay = pkgs.writeShellScriptBin "hypr-personal-display" ''
    ddcutil --display 1 setvcp 60 0x12
    ddcutil --display 2 setvcp 60 0x10
  '';
  setWorkDisplay = pkgs.writeShellScriptBin "hypr-work-display" ''
    ddcutil --display 1 setvcp 60 0x10
    ddcutil --display 2 setvcp 60 0x12
  '';
  startupTmuxW1 = pkgs.writeShellScriptBin "hypr-startup-tmux-w1" ''
    SESSION="main"
    tmux new-session -d -s "$SESSION"
    tmux send-keys -t "$SESSION" 'gonix && vim .' Enter
    tmux split-window -t "$SESSION"
    tmux send-keys -t "$SESSION" 'gonix' Enter
    exec tmux attach-session -t "$SESSION"
  '';
  toggleMonocle = pkgs.writeShellScriptBin "hypr-toggle-monocle" ''
    WS=$(hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r '.id')
    LAYOUT=$(hyprctl workspaces -j | ${pkgs.jq}/bin/jq -r --argjson ws "$WS" '.[] | select(.id == $ws) | .tiledLayout')
    ACTIVE=$(hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '.address')
    PREV_FILE="/tmp/hypr-monocle-prev-ws$WS"
    if [ "$LAYOUT" = "monocle" ]; then
      PREV=$(cat "$PREV_FILE" 2>/dev/null || echo "dwindle")
      rm -f "$PREV_FILE"
      hyprctl keyword workspace "$WS, layout:$PREV"
    else
      echo "$LAYOUT" > "$PREV_FILE"
      hyprctl keyword workspace "$WS, layout:monocle"
    fi
    hyprctl dispatch focuswindow address:$ACTIVE
  '';
in
{

  home = {
    packages = with pkgs; [
      playerctl
      grimblast
      hyprpaper

      wayvnc
      wl-clipboard
      cliphist
      setWorkDisplay
      setPersonalDisplay
      toggleMonocle
      startupTmuxW1
      jq
      rose-pine-hyprcursor
      wl-clip-persist
    ];
    pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.rose-pine-hyprcursor;
      name = "BreezeX-RosePine-Linux";
      size = 16;
    };
    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "BreezeX-RosePine-Linux";
      package = pkgs.rose-pine-hyprcursor;
    };

    iconTheme = {
      name = "Pop-Icon-Theme";
      package = pkgs.pop-icon-theme;
    };

    theme = {
      name = "palenight";
      package = pkgs.palenight-theme;
    };

    # Note the different syntax for gtk3 and gtk4
    gtk3.extraConfig = {
      "gtk-cursor-theme-name" = "BreezeX-RosePine-Linux";
    };
    gtk4.theme = config.gtk.theme;
    gtk4.extraConfig = {
      Settings = ''
        gtk-cursor-theme-name=BreezeX-RosePine-Linux
      '';
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    plugins = [
      # pkgs.hyprlandPlugins.hyprfocus
    ];

    # Hyprland 0.55+ Lua config. Home Manager prepends its own startup hook
    # (dbus-update-activation-environment + hyprland-session.target restart)
    # so we only need to ship the body. Per-machine bits ship as
    # hypr/machine.lua via each host's home-manager entry and are required()
    # from the bottom of hyprland.lua.
    configType = "lua";
    extraConfig = lib.fileContents ./hyprland.lua;
  };

  services.hyprpolkitagent.enable = true;
}
