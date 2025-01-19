{ ... }:

{
  imports = [
    ./common.nix
    ./common_unstable.nix
    ./gui.nix
    ./programs/neovim_git.nix
    ./gaming.nix
  ];
  #xsession.initExtra = "xrandr  --output DP-1 --rate 180 --mode 2560x1440 --output  HDMI-1 --auto --left-of DP-1";
  xsession.initExtra = "xrandr  --output DP-3 --auto --output  HDMI-1 --auto --left-of DP-3";
}
