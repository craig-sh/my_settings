{ ... }:

{
  imports = [
    ./common.nix
    ./common_unstable.nix
    ./gui.nix
    ./catppuccin.nix
    ./waylandgui.nix
    ./programs/neovim_git.nix
    ./gaming.nix
    ./programs/window_manager/hyprland.nix
    ./programs/window_manager/waybar.nix
    ./programs/window_manager/hypernix.nix
    #./x11gui.nix
  ];
  #xsession.initExtra = "xrandr  --output DP-1 --rate 180 --mode 2560x1440 --output  HDMI-1 --auto --left-of DP-1";
  xsession.initExtra = "xrandr  --output DP-3 --rate 180 --mode 2560x1440 --output  HDMI-1 --auto --left-of DP-3";
}
