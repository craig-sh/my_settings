{
  lockTimeout,
  dpmsTimeout,
  suspendTimeout,
}:
{ pkgs, ... }:
let
  suspendIfIdle = pkgs.writeShellScriptBin "hypridle-suspend-if-idle" ''
    # long running jobs
    if pgrep -x 'rsync|scp|cp' > /dev/null; then
      exit 0
    fi
    # Is anyone logged in remotely
    if [ -n "$(who | grep pts)" ]; then
      exit 0
    fi
    systemctl suspend
  '';
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        # Lua config (Hyprland 0.55+): legacy dispatcher strings are rejected;
        # `hyprctl dispatch` takes hl.dsp.* Lua expressions.
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
      };
      listener = [
        {
          timeout = lockTimeout;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = dpmsTimeout;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"off\" })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"on\" })'";
        }
        {
          timeout = suspendTimeout;
          on-timeout = "${suspendIfIdle}/bin/hypridle-suspend-if-idle";
        }
      ];
    };
  };
}
