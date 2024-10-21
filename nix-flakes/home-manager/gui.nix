{ config, pkgs, lib, inputs, ... }:

{

  nixpkgs.config.allowUnfree = true;

  programs = {
    rofi = {
      enable = true;
    };
    kitty = {
      enable = true;
    };
    firefox = {
      enable = true;
    };
  };

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
    pkgs.spotify
    pkgs.kdenlive
    pkgs.keepassxc
  ];

  xsession.enable = true;
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/kitty" = {source = programs/kitty; recursive = true;};
    ".config/rofi" = {source = programs/rofi; recursive = true;};
    ".config/dunst" = {source = programs/dunst; recursive = true;};
    ".Xresources" = {source = programs/X11/.Xresources;};
    ".config/qtile" = {source = programs/qtile; recursive = true;};
  };

}
