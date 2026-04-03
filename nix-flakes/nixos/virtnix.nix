{ inputs, outputs, username, config, lib, ... }:
let
  serviceModulesFor = user:
    lib.mapAttrsToList (_: svc: svc.hmModule)
      (lib.filterAttrs (_: svc: svc.hmModule != null && svc.user == user)
        config.local.services);
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
    inputs.quadlet-nix.nixosModules.quadlet
    ./modules/local-services.nix
    ./keep-calendar-sync.nix
    ./services/sops.nix
    ./services/caddy.nix
    ./hosts/virt/hardware-configuration.nix
    ./hosts/virt/base-configuration.nix
    ./hosts/virt/k3s-controller.nix
    ./hosts/virt/tailscale.nix
    ./hosts/virt/backup.nix
  ];

  virtualisation.quadlet.enable = true;

  local.caddy.httpsPort = 9443;
  local.services = {
    tandoor = {
      port = 8787;
      hmModule = ../home-manager/programs/local_services/tandoor.nix;
      backup = {
        enable = true;
        pgDumps = [ { container = "tandoordb"; } ];
      };
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.craig.imports = [
      ../home-manager/virtnix.nix
    ];
    users.conrun.imports = [
      ../home-manager/conrun.nix
    ] ++ serviceModulesFor "conrun";
    extraSpecialArgs = { inherit inputs outputs username; };
  };
}
