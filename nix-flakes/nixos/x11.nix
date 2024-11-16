{ config, pkgs,lib, ... }:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.windowManager.qtile = {
    enable = true;
    extraPackages = python3Packages: with python3Packages; [
      qtile-extras
      pulsectl-asyncio
    ];
    configFile = "/home/craig/.config/qtile/config.py";
  };
  #services.xserver.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "none+qtile";
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "craig";
  services.xserver.xkb.layout = "us";
}
