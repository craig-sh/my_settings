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
    ./services/tailscale_server.nix
    ./hosts/virt/backup.nix
  ];

  virtualisation.quadlet.enable = true;

  systemd.tmpfiles.rules = [
    "d /mnt/k8sconfig/podman/conrun 0700 conrun - - -"
    "d /mnt/k8sconfig/podman/craig  0700 craig  - - -"
  ];

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
    paperless = {
      user = "craig";
      port = 8788;
      hmModule = ../home-manager/programs/local_services/paperless.nix;
      backup = {
        enable = true;
        pgDumps = [ { container = "paperlessdb"; } ];
      };
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.craig.imports = [
      ../home-manager/virtnix.nix
    ] ++ serviceModulesFor "craig";
    users.conrun.imports = [
      ../home-manager/conrun.nix
      {
        home.file.".config/containers/storage.conf".text = ''
          [storage]
          driver = "overlay"
          graphRoot = "/mnt/k8sconfig/podman/conrun"
        '';
      }
    ] ++ serviceModulesFor "conrun";
    extraSpecialArgs = { inherit inputs outputs username; };
  };
}
