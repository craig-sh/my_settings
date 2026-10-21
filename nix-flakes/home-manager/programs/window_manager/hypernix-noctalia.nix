# hypernix Noctalia desktop shell. Swap for hypernix-classic.nix in
# home-manager/hypernix.nix to go back to waybar.
_: {
  imports = [ ./shell-noctalia.nix ];

  programs.noctalia.settings = {
    # One bar template spawned on every monitor; the workspaces/taskbar widgets
    # only show the bar's own monitor. HDMI-A-1 gets the full bar (was waybar
    # mainBar), DP-3 only workspaces + windows (was waybar otherBar).
    bar.main = {
      position = "top";
      thickness = 30;
      margin_ends = 0;
      widget_spacing = 4;
      start = [
        "workspaces"
        "taskbar"
      ];
      center = [ ];
      end = [
        "media"
        "net_rx"
        "net_tx"
        "disk"
        "ram"
        "cpu"
        "temp"
        "volume"
        "clock"
        "tray"
        "notifications"
        "control-center"
      ];
      monitor.dp3 = {
        match = "DP-3";
        end = [ ];
      };
    };

    widget.media = {
      font_scale = 0.8;
      scale = 0.85;
    };

    idle.behavior = {
      lock.timeout = 600; # 10 min
      screen-off.timeout = 900; # 15 min
      suspend.timeout = 1800; # 30 min
    };
  };

  # Noctalia only lists existing workspaces, so keep 1-10 alive on their
  # monitors (monitor assignment mirrors hypernix.lua).
  xdg.configFile."hypr/shell_host.lua".text = ''
    for i = 1, 10 do
        hl.workspace_rule({
            workspace  = tostring(i),
            monitor    = i <= 5 and "HDMI-A-1" or "DP-3",
            persistent = true,
        })
    end
  '';
}
