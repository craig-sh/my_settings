{ osConfig, ... }:
let
  version = osConfig.local.services.beszel.version;
  servicePort = toString osConfig.local.services.beszel.port;
  internalPort = "8090";
in
{
  virtualisation.quadlet = {
    enable = true;
    containers.beszel = {
      autoStart = true;
      unitConfig = {
        Description = "Beszel monitoring hub";
        Wants = "network-online.target";
        After = "network-online.target";
      };
      containerConfig = {
        image = "docker.io/henrygd/beszel:${version}";
        publishPorts = [ "127.0.0.1:${servicePort}:${internalPort}" ];
        volumes = [ "beszel-data:/beszel_data" ];
        environments = {
          TZ = "America/Toronto";
        };
        dropCapabilities = [ "ALL" ];
        noNewPrivileges = true;
      };
      serviceConfig.Restart = "always";
    };
    volumes."beszel-data" = { };
  };

  home.file."backup-scripts/beszel.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      BACKUP_DIR="$1"
      rsync -ah \
        "$(podman volume inspect --format '{{.Mountpoint}}' beszel-data)/" \
        "$BACKUP_DIR/"
    '';
  };
}
