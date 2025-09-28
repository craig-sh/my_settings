{ config, pkgs, lib, inputs, ... }:

{

  services = {
    dunst = {
      enable = true;
    };
  };

  gtk = {
    enable = true;

    iconTheme = {
      name = "Pop-Icon-Theme";
      package = pkgs.pop-icon-theme;
    };

    theme = {
      name = "palenight";
      package = pkgs.palenight-theme;
    };

    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };
  };

  home.packages = [
    pkgs.pwvucontrol
    pkgs.scrot
  ];

  xsession.enable = true;
  #xsession.initExtra = "xrandr --output DP-2 --auto --output HDMI-1 --right-of DP-1 --rate 143.99 --mode 2560x1440";
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".Xresources" = {source = programs/X11/.Xresources;};
    ".config/dunst" = {source = programs/dunst; recursive = true;};
  };
}
