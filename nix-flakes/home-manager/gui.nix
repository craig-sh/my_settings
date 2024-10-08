{ config, pkgs, lib, inputs, ... }:

{
  programs = {
    rofi = {
      enable = true;
    };
    kitty = {
      enable = true;
    };

  };

  services = {
    dunst = {
      enable = true;
    };
  };


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/kitty" = {source = programs/kitty; recursive = true;};
    ".config/rofi" = {source = programs/rofi; recursive = true;};
    ".config/dunst" = {source = programs/dunst; recursive = true;};
    ".config/qtile" = {source = programs/qtile; recursive = true;};
  };

}
