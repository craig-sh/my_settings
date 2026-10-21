# carbonnix Noctalia desktop shell. Swap for carbonnix-classic.nix in
# home-manager/carbonnix.nix to go back to waybar.
_: {
  imports = [ ./shell-noctalia.nix ];

  programs.noctalia.settings = {
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
        "battery"
        "brightness"
        "network"
        "bluetooth"
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
    };

    widget = {
      media = {
        font_scale = 0.8;
        scale = 0.85;
        album_art_only = true; # art (or disc glyph) only; no title/artist
      };
      network = {
        font_scale = 0.8;
        scale = 0.85;
        show_label = false; # icon only; SSID is in the network panel
      };
      bluetooth = {
        font_scale = 0.8;
        scale = 0.85;
      };
      battery = {
        font_scale = 0.8;
        scale = 0.85;
      };
      brightness = {
        font_scale = 0.8;
        scale = 0.85;
      };
    };

    idle.behavior = {
      lock.timeout = 300; # 5 min
      screen-off.timeout = 600; # 10 min
      suspend.timeout = 1200; # 20 min
    };
  };

  # Noctalia only lists existing workspaces; keep the same ones waybar did.
  xdg.configFile."hypr/shell_host.lua".text = ''
    for _, ws in ipairs({ "1", "4", "6", "10" }) do
        hl.workspace_rule({ workspace = ws, persistent = true })
    end
  '';
}
