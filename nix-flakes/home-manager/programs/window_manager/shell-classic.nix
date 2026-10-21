# Classic desktop shell: waybar + dunst + rofi binds + hyprlock.
# Imported by <host>-classic.nix; swap for <host>-noctalia.nix to use Noctalia.
{ lib, ... }:
{
  imports = [
    ./waybar.nix
    ./hyprlock.nix
  ];

  services.dunst.enable = true;
  home.file.".config/dunst" = {
    source = ../dunst;
    recursive = true;
  };

  catppuccin = {
    hyprlock.enable = true;
    waybar = {
      enable = true;
      # New catppuccin module defaults to prependImport; our waybar_style.css
      # imports catppuccin.css directly, so keep generating that file.
      mode = "createLink";
    };
  };

  xdg.configFile."hypr/shell.lua".text = lib.fileContents ./shell-classic.lua;
}
