{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.nix-flatpak.nixosModules.nix-flatpak
    ./services/sops.nix
    ./hosts/carbonnix/hardware-configuration.nix
    ./hosts/carbonnix/configuration.nix
  ];
}
