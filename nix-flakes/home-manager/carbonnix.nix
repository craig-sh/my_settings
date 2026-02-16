{ inputs, ... }:

{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.catppuccin.homeModules.catppuccin
    ./common.nix
    ./common_unstable.nix
    ./gui.nix
    ./catppuccin.nix
    #./x11gui.nix
    ./programs/neovim_git.nix
    ./programs/window_manager/hyprland.nix
    ./programs/window_manager/waybar.nix
    ./programs/window_manager/carbonnix.nix
    (import ./programs/window_manager/hypridle.nix {
      lockTimeout = 300; # 5 min
      dpmsTimeout = 600; # 10 min
      suspendTimeout = 1200; # 20 min
    })
  ];
}
