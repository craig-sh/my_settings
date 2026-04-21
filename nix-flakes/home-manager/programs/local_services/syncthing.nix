{ osConfig, ... }:
let
  version = osConfig.local.services.syncthing.version;
  servicePort = toString osConfig.local.services.syncthing.port;
  internalPort = "8384";
in
{
  virtualisation.quadlet = {
    enable = true;
    containers = {
      syncthing = {
        autoStart = true;
        unitConfig = {
          Description = "Syncthing";
          Wants = "network-online.target";
          After = "network-online.target";
        };
        containerConfig = {
          image = "docker.io/syncthing/syncthing:${version}";
          publishPorts = [
            "127.0.0.1:${servicePort}:${internalPort}/tcp"
            "0.0.0.0:22000:22000/tcp"
            "0.0.0.0:22000:22000/udp"
            "0.0.0.0:21027:21027/udp"
          ];
          volumes = [
            "syncthing-data:/var/syncthing:U"
          ];
          environments = {
            PUID = "0";
            PGID = "0";
            TZ = "America/Toronto";
          };
          healthCmd = "curl -fkLsS -m 2 127.0.0.1:${internalPort}/rest/noauth/health | grep -o --color=never OK || exit 1";
          healthInterval = "1m";
          healthTimeout = "10s";
          healthRetries = 3;
        };
        serviceConfig.Restart = "always";
      };
    };
    volumes = {
      "syncthing-data" = { };
    };
  };

  home.file."backup-scripts/syncthing.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      BACKUP_DIR="$1"
      rsync -ah \
        "$(podman volume inspect --format '{{.Mountpoint}}' syncthing-data)/" \
        "$BACKUP_DIR/"
    '';
  };
}
