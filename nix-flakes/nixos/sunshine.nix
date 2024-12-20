{ ... }:
{
  services.sunshine = {
    enable = true;
    autoStart = false;
    #capSysAdmin = true; # only needed for Wayland -- omit this when using with Xorg
    openFirewall = true;
  };
}
