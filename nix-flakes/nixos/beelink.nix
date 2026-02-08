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

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.craig.imports = [
      ../home-manager/common.nix
      ../home-manager/beelink.nix
    ];
    users.conrun.imports = [ ../home-manager/conrun.nix ];
    extraSpecialArgs = { inherit inputs outputs username; };
  };
}
