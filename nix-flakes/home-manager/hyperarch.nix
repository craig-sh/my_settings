{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./common.nix
    ./programs/neovim_git.nix
  ];
}
