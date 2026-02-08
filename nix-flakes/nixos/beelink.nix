{
  inputs,
  outputs,
  username,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.quadlet-nix.nixosModules.quadlet
    inputs.home-manager.nixosModules.home-manager
    ./services/sops.nix
    ./hosts/beelink/hardware-configuration.nix
    ./hosts/beelink/configuration.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.craig.imports = [
    ../home-manager/common.nix
    ../home-manager/beelink.nix
  ];
  home-manager.users.conrun.imports = [ ../home-manager/conrun.nix ];
  home-manager.extraSpecialArgs = { inherit inputs outputs username; };
}
