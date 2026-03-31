{ osConfig, ... }:
let
  version = "14.0.3";
  httpPort = "3001";
  sshPort = "2222";
  uid = toString osConfig.users.users.conrun.uid;
in
{
  virtualisation.quadlet = {
    enable = true;
    containers.forgejo = {
      containerConfig = {
        image = "codeberg.org/forgejo/forgejo:${version}-rootless";
        user = "${uid}:${uid}";
        userns = "keep-id";
        publishPorts = [
          "127.0.0.1:${httpPort}:3000"
          "0.0.0.0:${sshPort}:${sshPort}"
        ];
        volumes = [
          "forgejo-data:/var/lib/gitea"
          "forgejo-conf:/etc/gitea"
        ];
        environments = {
          FORGEJO__server__SSH_LISTEN_PORT = sshPort;
          FORGEJO__server__SSH_PORT = sshPort;
        };
        dropCapabilities = [ "ALL" ];
        noNewPrivileges = true;
        healthCmd = "curl -f http://localhost:3000/api/healthz";
        healthInterval = "60s";
        healthTimeout = "10s";
        healthRetries = 3;
        healthStartPeriod = "30s";
      };
      unitConfig.Description = "Forgejo Git Service";
      serviceConfig.Restart = "always";
    };
  };
  virtualisation.quadlet.volumes."forgejo-data" = { };
  virtualisation.quadlet.volumes."forgejo-conf" = { };

  home.file."backup-scripts/forgejo.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      BACKUP_DIR="$1"
      mkdir -p "$BACKUP_DIR/data" "$BACKUP_DIR/conf"
      rsync -ah \
        "$(podman volume inspect --format '{{.Mountpoint}}' forgejo-data)/" \
        "$BACKUP_DIR/data/"
      rsync -ah \
        "$(podman volume inspect --format '{{.Mountpoint}}' forgejo-conf)/" \
        "$BACKUP_DIR/conf/"
    '';
  };
}
