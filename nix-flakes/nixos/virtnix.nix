{ inputs, outputs, username, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
    ./keep-calendar-sync.nix
    ./services/sops.nix
    ./hosts/virt/hardware-configuration.nix
    ./hosts/virt/base-configuration.nix
    ./hosts/virt/k3s-controller.nix
    ./hosts/virt/tailscale.nix
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.craig.imports = [
      ../home-manager/virtnix.nix
    ];
    extraSpecialArgs = { inherit inputs outputs username; };
  };
}
