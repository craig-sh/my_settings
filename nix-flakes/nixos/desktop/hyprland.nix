{ pkgs, ... }:
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  programs.hyprland = {
    enable = true;
    #withUWSM = true; # recommended for most users
    xwayland.enable = true; # Xwayland can be disabled.
  };
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-hyprland ];
  };
}
