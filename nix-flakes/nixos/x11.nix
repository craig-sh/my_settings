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
  services.xserver.xkb.layout = "us";

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = [ "gnome" ];
}