{
  config,
  pkgs,
  lib,
  ...
}:
{
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    xkb.layout = "us";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = [ "gnome" ];
  };
}
