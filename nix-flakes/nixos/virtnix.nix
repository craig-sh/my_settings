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
    ./services/tailscale_server.nix
    ./hosts/virt/backup.nix
    ./services/container-healthcheck.nix
  ];

  local.containerHealthcheck = {
    enable = true;
    slugPrefix = "virtnix-containers";
  };

  networking.hostName = "virtnix";

  virtualisation.quadlet.enable = true;

  systemd.tmpfiles.rules = [
    "d /mnt/k8sconfig        0755 root   root   - -"
    "d /mnt/k8sconfig/podman 0755 root   root   - -"
    "d /mnt/k8sconfig/podman/conrun   0700 conrun   - - -"
    "d /mnt/k8sconfig/podman/craig    0700 craig    - - -"
    "d /mnt/k8sconfig/podman/podMedia 0700 podMedia - - -"
  ];

  local.services = {
    tandoor = {
      port = 8787;
      hmModule = ../home-manager/programs/local_services/tandoor.nix;
      category = "Recipes";
      icon = "tandoor.png";
      widget = {
        type = "tandoor";
        key = "{{HOMEPAGE_VAR_TANDOOR_KEY}}";
      };
      backup = {
        enable = true;
        pgDumps = [ { container = "tandoordb"; } ];
      };
    };
    paperless = {
      user = "craig";
      port = 8788;
      hmModule = ../home-manager/programs/local_services/paperless.nix;
      category = "Documents";
      icon = "paperless-ngx.png";
      widget = {
        type = "paperlessngx";
        key = "{{HOMEPAGE_VAR_PAPERLESS_KEY}}";
      };
      backup = {
        enable = true;
        scriptFile = null;
        pgDumps = [ { container = "paperlessdb"; } ];
      };
      tier = "critical";
      units = [
        "paperless.service"
        "paperlessdb.service"
        "paperlessredis.service"
        "paperlesspod-pod.service"
      ];
    };
    immich = {
      user = "craig";
      port = 31113;
      version = "v2.7.5";
      firewall.extraTCPPorts = [ 31113 ];
      hmModule = ../home-manager/programs/local_services/immich.nix;
      category = "Photos";
      icon = "immich.png";
      widget = {
        type = "immich";
        key = "{{HOMEPAGE_VAR_IMMICH_KEY}}";
      };
      backup = {
        enable = true;
        scriptFile = null;
        pgDumps = [ { container = "immichdb"; } ];
      };
      tier = "critical";
      units = [
        "immich.service"
        "immich-ml.service"
        "immichdb.service"
        "immichvalkey.service"
        "immichpod-pod.service"
      ];
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
      icon = "syncthing.png";
      backup.enable = true;
    };
    beszel-agent-conrun = {
      user = "conrun";
      version = "0.18.7";
      caddy.enable = false;
      hmModule = ../home-manager/programs/local_services/beszel-agent.nix;
    };
    beszel-agent-craig = {
      user = "craig";
      version = "0.18.7";
      caddy.enable = false;
      hmModule = ../home-manager/programs/local_services/beszel-agent.nix;
    };
    beszel-agent-podMedia = {
      user = "podMedia";
      version = "0.18.7";
      caddy.enable = false;
      hmModule = ../home-manager/programs/local_services/beszel-agent.nix;
    };
    homepage = {
      port = 3000;
      version = "v1.12.3";
      hmModule = ../home-manager/programs/local_services/homepage.nix;
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
