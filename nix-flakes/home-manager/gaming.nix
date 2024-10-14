{pkgs, ... }:
{

  programs = {
    mangohud = {
      enable = true;
      settings = {
        preset = 3;
        position = "top-right";
        background_alpha = 0.4;
        fps_metrics = "avg,0.1,0.01";
        frametime = false;
        resolution = true;
      };
    };
  };

  home.packages = [
    # pgks.gamemode -- Leaving this out for now
    # WINE 
    pkgs.wine
    pkgs.winetricks
    pkgs.protontricks
    pkgs.vulkan-tools
    # Extra dependencies
    # https://github.com/lutris/docs/
    pkgs.gnutls
    pkgs.openldap
    pkgs.libgpgerror
    pkgs.freetype
    pkgs.sqlite
    pkgs.libxml2
    pkgs.xml2
    pkgs.SDL2
  ];

}
