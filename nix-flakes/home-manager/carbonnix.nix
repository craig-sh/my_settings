{ ... }:

{
  imports = [
    ./common.nix
    ./common_unstable.nix
    ./gui.nix
    #./x11gui.nix
    ./programs/neovim_git.nix
    ./programs/window_manager/hyprland.nix
    ./programs/window_manager/waybar.nix
    ./programs/window_manager/carbonnix.nix
  ];
}
