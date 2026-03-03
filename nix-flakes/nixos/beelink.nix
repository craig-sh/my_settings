{
  inputs,
  outputs,
  username,
  config,
  lib,
  ...
}:
let
  serviceModulesFor = user:          # (1) takes "craig" or "conrun"
    lib.mapAttrsToList               # (4) attrset → list, extracting .hmModule
      (_: svc: svc.hmModule)
      (lib.filterAttrs               # (3) keep only services matching the user
        (_: svc: svc.hmModule != null && svc.user == user)
        config.local.services);      # (2) all declared services
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.quadlet-nix.nixosModules.quadlet
    inputs.home-manager.nixosModules.home-manager
    ./modules/local-services.nix
    ./services/sops.nix
    ./hosts/beelink/hardware-configuration.nix
    ./hosts/beelink/configuration.nix
  ];

  local.services = {
    forgejo.hmModule    = ../home-manager/programs/forgejo.nix;
    ghostfolio.hmModule = ../home-manager/programs/ghostfolio.nix;
    actualbudget.hmModule = ../home-manager/programs/actualbudget.nix;
    frigate.hmModule    = ../home-manager/programs/frigate.nix;
    sparkyfitness.hmModule = ../home-manager/programs/sparkyfitness.nix;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.craig.imports = [
      ../home-manager/common.nix
      ../home-manager/beelink.nix
    ] ++ serviceModulesFor "craig";
    users.conrun.imports = [
      ../home-manager/conrun.nix
    ] ++ serviceModulesFor "conrun";
    extraSpecialArgs = { inherit inputs outputs username; };
  };
}
