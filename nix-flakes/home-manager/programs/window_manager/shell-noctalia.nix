# Noctalia v5 desktop shell: bar, notifications, launcher, clipboard, OSD,
# lock screen and idle management in one process.
# Imported by <host>-noctalia.nix; swap for <host>-classic.nix to go back.
# Settings are merged with the host module's and written to
# ~/.config/noctalia/config.toml (see example.toml in the noctalia repo).
{
  lib,
  pkgs,
  ...
}:
let
  suspendIfIdle = import ./suspend-if-idle.nix { inherit pkgs; };
  # Shrinks the status widgets: text (multiplies bar.font_scale) and
  # icon/padding (multiplies bar.scale).
  compactFontScale = 0.8;
  compactScale = 0.85;

  # Backs the launcher's /cmd entry. With no args, lists the argument-free
  # `noctalia msg` commands as "<command>\t<description>" (status/getter
  # commands that only print are skipped). `run <line>` runs the command a
  # listed line names. Apostrophes are stripped from descriptions because
  # Noctalia substitutes the chosen line into exec unescaped.
  noctaliaCommands = pkgs.writeShellScript "noctalia-commands" ''
    if [ "$1" = run ]; then
      exec noctalia msg "''${2%%$'\t'*}"
    fi
    noctalia msg --help 2>&1 | ${pkgs.gawk}/bin/awk '
      /^Commands:/ { f = 1; next }
      /^Options:/  { f = 0 }
      f && NF {
        line = $0
        sub(/^ +/, "", line)
        n = match(line, / {2,}/)
        head = substr(line, 1, n - 1)
        desc = substr(line, n + RLENGTH)
        if (head ~ /</) next
        split(head, a, " ")
        name = a[1]
        if (name ~ /^(status|clipboard-text)$|-(status|get)$|^brightness-list/) next
        gsub(/\x27/, "", desc)
        print name "\t" desc
      }'
  '';
in
{
  # Home Manager's own programs.noctalia module, with pkgs.noctalia from nixpkgs.
  programs.noctalia = {
    enable = true;
    settings = {
      # theme: left unset so the default builtin "Noctalia" palette is used.

      idle.behavior = {
        # Timeouts are set per host.
        lock = {
          action = "lock";
          enabled = true;
        };
        screen-off = {
          action = "screen_off";
          enabled = true;
        };
        suspend = {
          # Custom command so long copies / remote logins block suspend.
          action = "command";
          command = "${suspendIfIdle}/bin/suspend-if-idle";
          enabled = true;
        };
      };

      # Launcher "/cmd": pick and run any argument-free Noctalia command.
      shell.launcher.dmenu.entry.cmd = {
        command = "${noctaliaCommands}";
        exec = "${noctaliaCommands} run '{selection}'";
        prefix = "cmd";
        label = "Noctalia commands";
      };

      widget = {
        workspaces = {
          # Glyph names come from default_name rules in shell-noctalia.lua.
          label_source = "name";
          max_label_chars = 2;
        };
        taskbar = {
          only_active_workspace = true;
          show_window_title = true;
          window_title_max_width = 60;
          font_scale = compactFontScale;
        };
        clock = {
          format = "{:%Y-%m-%d}\n{:%H:%M}";
          tooltip_format = "{:%A, %B %d, %Y}";
        };
        cpu = {
          type = "sysmon";
          font_scale = compactFontScale;
          scale = compactScale;
          stat = "cpu_usage";
        };
        ram = {
          type = "sysmon";
          font_scale = compactFontScale;
          scale = compactScale;
          stat = "ram_used";
        };
        disk = {
          type = "sysmon";
          font_scale = compactFontScale;
          scale = compactScale;
          stat = "disk_used_pct";
          path = "/";
        };
        temp = {
          type = "sysmon";
          font_scale = compactFontScale;
          scale = compactScale;
          stat = "cpu_temp";
        };
        net_rx = {
          type = "sysmon";
          font_scale = compactFontScale;
          scale = compactScale;
          stat = "net_rx";
          network_speed_compact = true;
        };
        net_tx = {
          type = "sysmon";
          font_scale = compactFontScale;
          scale = compactScale;
          stat = "net_tx";
          network_speed_compact = true;
        };
        volume = {
          font_scale = compactFontScale;
          scale = compactScale;
        };
        tray = {
          font_scale = compactFontScale;
          scale = compactScale;
        };
        notifications = {
          font_scale = compactFontScale;
          scale = compactScale;
        };
        "control-center" = {
          font_scale = compactFontScale;
          scale = compactScale;
        };
      };
    };
  };

  # Full mixer for what Noctalia's audio panel lacks (was installed by waybar.nix).
  home.packages = [ pkgs.pavucontrol ];

  xdg.configFile."hypr/shell.lua".text = lib.fileContents ./shell-noctalia.lua;
}
