{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./common.nix
    ./common_stable.nix
    #./programs/aider.nix
    ./virtserver.nix
  ];
}
