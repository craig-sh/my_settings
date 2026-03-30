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
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = lockTimeout;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = dpmsTimeout;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = suspendTimeout;
          on-timeout = "${suspendIfIdle}/bin/hypridle-suspend-if-idle";
        }
      ];
    };
  };
}
