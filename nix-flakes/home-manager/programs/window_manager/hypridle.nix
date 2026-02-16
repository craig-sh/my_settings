{
  lockTimeout,
  dpmsTimeout,
  suspendTimeout,
}:
_: {
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
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}
