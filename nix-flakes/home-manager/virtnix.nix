{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./common.nix
    ./common_stable.nix
    ./virtserver.nix
  ];
}
