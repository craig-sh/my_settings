{ ... }:

{
  imports = [
    ./common.nix
    ./common_unstable.nix
    ./gui.nix
    ./x11gui.nix
    ./programs/neovim_git.nix
  ];
}
