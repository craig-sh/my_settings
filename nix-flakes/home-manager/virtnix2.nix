{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./common.nix
    ./virtserver.nix
  ];
}
