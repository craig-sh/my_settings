{ config, osConfig, ... }:
let
  inherit (osConfig.local.services.endurain) version domain;
  servicePort = toString osConfig.local.services.endurain.port;
  internalPort = "8080";
  inherit (config.virtualisation.quadlet) pods;
in
{
  virtualisation.quadlet = {
    enable = true;
    pods.endurainpod = {
      podConfig = {
        publishPorts = [ "127.0.0.1:${servicePort}:${internalPort}" ];
      };
      autoStart = true;
    };
    containers = {
      endurain = {
        containerConfig = {
          pod = pods.endurainpod.ref;
          image = "ghcr.io/endurain-project/endurain:${version}";
          pull = "newer";
          environmentFiles = [ "/run/secrets/rendered/endurain.env" ];
          environments = {
            DB_HOST = "localhost";
            DB_PORT = "5432";
            DB_USER = "endurain";
            DB_DATABASE = "endurain";
            ENDURAIN_HOST = "https://${domain}";
            BEHIND_PROXY = "true";
            TZ = "America/Toronto";
          };
          # The image pre-creates these dirs owned by its uid 1000 app user, so
          # the named volumes inherit that ownership on first copy-up.
          volumes = [
            "endurain-data:/app/backend/data:Z"
            "endurain-logs:/app/backend/logs:Z"
          ];
          dropCapabilities = [ "ALL" ];
          noNewPrivileges = true;
        };
        unitConfig = {
          Description = "Endurain";
          After = [ "endurainpostgres.service" ];
          Requires = [ "endurainpostgres.service" ];
        };
        serviceConfig.Restart = "always";
      };
      endurainpostgres = {
        containerConfig = {
          pod = pods.endurainpod.ref;
          image = "docker.io/library/postgres:18-alpine";
          pull = "newer";
          volumes = [ "endurain-postgres:/var/lib/postgresql/data:Z" ];
          environmentFiles = [ "/run/secrets/rendered/endurain.env" ];
          environments = {
            POSTGRES_USER = "endurain";
            POSTGRES_DB = "endurain";
            # postgres 18 moved its default data dir; pin it under the volume
            # like upstream's compose does.
            PGDATA = "/var/lib/postgresql/data/pgdata";
          };
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
        unitConfig.Description = "Endurain PostgreSQL Database";
        serviceConfig.Restart = "always";
      };
    };
    volumes = {
      "endurain-data" = { };
      "endurain-logs" = { };
      "endurain-postgres" = { };
    };
  };

  # Logs are skipped; the database is covered by backup.pgDumps.
  # Files are owned by the container's uid 1000 (a subuid on the host), so read
  # them from inside the user namespace.
  home.file."backup-scripts/endurain.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      BACKUP_DIR="$1"
      mkdir -p "$BACKUP_DIR/data"
      podman unshare rsync -ah \
        "$(podman volume inspect --format '{{.Mountpoint}}' endurain-data)/" \
        "$BACKUP_DIR/data/"
    '';
  };
}
