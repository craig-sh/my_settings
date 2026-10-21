{
  inputs,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.catppuccin.homeModules.catppuccin
    ./common.nix
    ./common_unstable.nix
    ./gui.nix
    ./catppuccin.nix
    ./waylandgui.nix
    #./programs/aider.nix
    ./programs/neovim_git.nix
    ./gaming.nix
    ./programs/window_manager/hyprland.nix
    # Desktop shell: keep exactly one of these uncommented.
    #./programs/window_manager/hypernix-classic.nix # waybar + dunst + hyprlock + hypridle
    ./programs/window_manager/hypernix-noctalia.nix # noctalia v5
    #./programs/claude.nix
    #./x11gui.nix
  ];
  # Per-machine Hyprland Lua config (monitors, workspace assignments,
  # host-specific binds). hyprland.lua loads this via require("machine").
  xdg.configFile."hypr/machine.lua".text = lib.fileContents ./programs/window_manager/hypernix.lua;

  #xsession.initExtra = "xrandr  --output DP-1 --rate 180 --mode 2560x1440 --output  HDMI-1 --auto --left-of DP-1";
  xsession.initExtra = "xrandr  --output DP-3 --rate 180 --mode 2560x1440 --output  HDMI-1 --auto --left-of DP-3";

  home = {
    packages = [
      pkgs.google-chrome
    ];
  };
}
