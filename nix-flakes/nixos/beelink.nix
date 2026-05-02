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
    ./services/tailscale_server.nix
    ./services/container-healthcheck.nix
  ];

  local.containerHealthcheck = {
    enable = true;
    slugPrefix = "beelink-containers";
  };

  local.services = {
    forgejo = {
      hmModule = ../home-manager/programs/local_services/forgejo.nix;
      category = "Code";
      widget = {
        type = "forgejo";
        key = "{{HOMEPAGE_VAR_FORGEJO_KEY}}";
      };
    };
    ghostfolio = {
      hmModule = ../home-manager/programs/local_services/ghostfolio.nix;
      category = "Finance";
      widget = {
        type = "ghostfolio";
        key = "{{HOMEPAGE_VAR_GHOSTFOLIO_KEY}}";
      };
    };
    actualbudget.hmModule = ../home-manager/programs/local_services/actualbudget.nix;
    frigate = {
      hmModule = ../home-manager/programs/local_services/frigate.nix;
      category = "Monitoring";
      widget.type = "frigate";
      tier = "critical";
      units = [ "frigate.service" ];
    };
    sparkyfitness.hmModule = ../home-manager/programs/local_services/sparkyfitness.nix;
    donetick = {
      hmModule = ../home-manager/programs/local_services/donetick.nix;
      tier = "critical";
      units = [ "donetick.service" ];
    };
    beszel.hmModule = ../home-manager/programs/local_services/beszel-hub.nix;
    beszel-agent-conrun.hmModule = ../home-manager/programs/local_services/beszel-agent.nix;
    beszel-agent-craig.hmModule = ../home-manager/programs/local_services/beszel-agent.nix;
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
