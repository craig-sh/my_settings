{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    ./services/sops.nix
    ./hosts/virt/hardware-configuration.nix
    ./hosts/virt/base-configuration.nix
    ./hosts/virt/k3s-agent.nix
  ];
}
