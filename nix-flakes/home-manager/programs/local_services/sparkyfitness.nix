{ osConfig, config, ... }:
let
  servicePort = "3004";
  internalPort = "80"; # frontend nginx port
  inherit (config.virtualisation.quadlet) pods;
  version = "v0.16.5.8";
  uid = toString osConfig.users.users.conrun.uid;
in
{
  virtualisation.quadlet = {
    enable = true;
    pods.sfpod = {
      podConfig = {
        publishPorts = [
          "127.0.0.1:${servicePort}:${internalPort}"
        ];
      };
      autoStart = true;
    };
    containers = {
      sffrontend = {
        containerConfig = {
          pod = pods.sfpod.ref;
          image = "docker.io/codewithcj/sparkyfitness:${version}";
          environmentFiles = [ "/run/secrets/rendered/sparkyfitness.env" ];
          dropCapabilities = [ "ALL" ];
          addCapabilities = [
            "CHOWN"
            "NET_BIND_SERVICE"
            "SETGID"
            "SETUID"
          ];
          noNewPrivileges = true;
        };
        unitConfig = {
          Description = "SparkyFitness Frontend";
          After = [ "sfserver.service" ];
          Requires = [ "sfserver.service" ];
        };
        serviceConfig.Restart = "always";
      };
      sfserver = {
        containerConfig = {
          pod = pods.sfpod.ref;
          image = "docker.io/codewithcj/sparkyfitness_server:${version}";
          environmentFiles = [ "/run/secrets/rendered/sparkyfitness.env" ];
          volumes = [
            "sf-server-backup:/app/SparkyFitnessServer/backup:Z"
            "sf-server-uploads:/app/SparkyFitnessServer/uploads:Z"
          ];
          dropCapabilities = [ "ALL" ];
          noNewPrivileges = true;
        };
        unitConfig = {
          Description = "SparkyFitness Server";
          After = [ "sfpostgres.service" ];
          Requires = [ "sfpostgres.service" ];
        };
        serviceConfig.Restart = "always";
      };
      sfpostgres = {
        containerConfig = {
          pod = pods.sfpod.ref;
          image = "docker.io/library/postgres:17-alpine";
          volumes = [ "sf-postgres:/var/lib/postgresql/data:Z" ];
          environmentFiles = [ "/run/secrets/rendered/sparkyfitness.env" ];
          dropCapabilities = [ "ALL" ];
          addCapabilities = [
            "CHOWN"
            "DAC_READ_SEARCH"
            "FOWNER"
            "SETGID"
            "SETUID"
          ];
          noNewPrivileges = true;
        };
        unitConfig.Description = "SparkyFitness PostgreSQL Database";
        serviceConfig.Restart = "always";
      };
    };
    volumes = {
      "sf-postgres" = { };
      "sf-server-backup" = { };
      "sf-server-uploads" = { };
    };
  };

  home.file."backup-scripts/sparkyfitness.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      BACKUP_DIR="$1"
      mkdir -p "$BACKUP_DIR/uploads" "$BACKUP_DIR/backup"
      rsync -ah \
        "$(podman volume inspect --format '{{.Mountpoint}}' sf-server-uploads)/" \
        "$BACKUP_DIR/uploads/"
      rsync -ah \
        "$(podman volume inspect --format '{{.Mountpoint}}' sf-server-backup)/" \
        "$BACKUP_DIR/backup/"
    '';
  };
}
