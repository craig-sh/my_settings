{
  inputs,
  outputs,
  username,
  config,
  lib,
  ...
}:
let
  serviceModulesFor =
    user:
    lib.mapAttrsToList (_: svc: svc.hmModule) (
      lib.filterAttrs (_: svc: svc.hmModule != null && svc.user == user) config.local.services
    );
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
    "d /mnt/k8sconfig/podman/podMedia 0700 podMedia - - -"
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
        scriptFile = null;
        pgDumps = [ { container = "paperlessdb"; } ];
      };
    };
    immich = {
      user = "craig";
      port = 31113;
      version = "v2.5.6";
      firewall.extraTCPPorts = [ 31113 ];
      hmModule = ../home-manager/programs/local_services/immich.nix;
      backup = {
        enable = true;
        scriptFile = null;
        pgDumps = [ { container = "immichdb"; } ];
      };
    };
    syncthing = {
      user = "craig";
      port = 8797;
      version = "2.0.16";
      firewall.extraTCPPorts = [ 22000 ];
      firewall.extraUDPPorts = [
        22000
        21027
      ];
      hmModule = ../home-manager/programs/local_services/syncthing.nix;
      backup.enable = true;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.craig.imports = [
      ../home-manager/virtnix.nix
    ]
    ++ serviceModulesFor "craig";
    users.conrun.imports = [
      ../home-manager/conrun.nix
      {
        home.file.".config/containers/storage.conf".text = ''
          [storage]
          driver = "overlay"
          graphRoot = "/mnt/k8sconfig/podman/conrun"
        '';
      }
    ]
    ++ serviceModulesFor "conrun";
    users.podMedia.imports = [
      ../home-manager/conrun.nix
      {
        home.file.".config/containers/storage.conf".text = ''
          [storage]
          driver = "overlay"
          graphRoot = "/mnt/k8sconfig/podman/podMedia"
        '';
      }
    ]
    ++ serviceModulesFor "podMedia";
    extraSpecialArgs = { inherit inputs outputs username; };
  };
}
