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

  home.packages = [
    pkgs.spotify
    #pkgs.kdenlive
    pkgs.keepassxc
    pkgs.meld
    pkgs.remmina
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".config/kitty" = {source = programs/kitty; recursive = true;};
    ".config/rofi" = {source = programs/rofi; recursive = true;};
    ".config/qtile" = {source = programs/qtile; recursive = true;};
  };

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
    "org/gnome/meld" = {
      custom-font="FantasqueSansM Nerd Font Mono 12";
      enable-space-drawer=true;
      highlight-current-line=true;
      highlight-syntax=true;
      indent-width=4;
      insert-spaces-instead-of-tabs=true;
      prefer-dark-theme=true;
      show-line-numbers=true;
      style-scheme="meld-dark";
      use-system-font=false;
      wrap-mode="none";
    };
  };
}
