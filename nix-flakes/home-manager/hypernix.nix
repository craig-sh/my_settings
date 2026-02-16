{ inputs, ... }:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.catppuccin.homeModules.catppuccin
    ./common.nix
    ./common_unstable.nix
    ./gui.nix
    ./catppuccin.nix
    ./waylandgui.nix
    ./programs/neovim_git.nix
    ./gaming.nix
    ./programs/window_manager/hyprland.nix
    ./programs/window_manager/hyprlock.nix
    ./programs/window_manager/waybar.nix
    ./programs/window_manager/hypernix.nix
    (import ./programs/window_manager/hypridle.nix {
      lockTimeout = 600; # 10 min
      dpmsTimeout = 900; # 15 min
      suspendTimeout = 1800; # 30 min
    })
    #./programs/claude.nix
    #./x11gui.nix
  ];
  #xsession.initExtra = "xrandr  --output DP-1 --rate 180 --mode 2560x1440 --output  HDMI-1 --auto --left-of DP-1";
  xsession.initExtra = "xrandr  --output DP-3 --rate 180 --mode 2560x1440 --output  HDMI-1 --auto --left-of DP-3";
}
