{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.xkb.layout = "us";

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = [ "gnome" ];
}
