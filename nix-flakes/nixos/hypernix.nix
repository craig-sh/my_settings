{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.nix-flatpak.nixosModules.nix-flatpak
    ./services/sops.nix
    ./hosts/hypernix/hardware-configuration.nix
    ./hosts/hypernix/configuration.nix
  ];
}
