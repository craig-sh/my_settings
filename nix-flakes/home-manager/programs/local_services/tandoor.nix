{ config, osConfig, ... }:
let
  version = "2.4";
  servicePort = toString osConfig.local.services.tandoor.port;
  internalPort = "8080";
  inherit (config.virtualisation.quadlet) pods;
in
{
  virtualisation.quadlet = {
    enable = true;
    pods.tandoorpod = {
      podConfig.publishPorts = [ "127.0.0.1:${servicePort}:${internalPort}" ];
      autoStart = true;
    };
    containers = {
      tandoor = {
        containerConfig = {
          pod = pods.tandoorpod.ref;
          image = "docker.io/vabene1111/recipes:${version}";
          environmentFiles = [ "/run/secrets/rendered/tandoor.env" ];
          environments = {
            DB_ENGINE = "django.db.backends.postgresql";
            POSTGRES_HOST = "localhost";
            POSTGRES_PORT = "5432";
            ALLOWED_HOSTS = "*";
            TIMEZONE = "America/Toronto";
            GUNICORN_MEDIA = "1";
          };
          volumes = [
            "tandoor-media:/opt/recipes/mediafiles"
            "tandoor-static:/opt/recipes/staticfiles"
          ];
          dropCapabilities = [ "ALL" ];
          noNewPrivileges = true;
          healthCmd = "curl -f http://localhost:${internalPort}/";
          healthInterval = "30s";
          healthTimeout = "10s";
          healthRetries = 5;
          healthStartPeriod = "30s";
        };
        unitConfig = {
          Description = "Tandoor Recipe Manager";
          After = [ "tandoordb.service" ];
          Requires = [ "tandoordb.service" ];
        };
        serviceConfig.Restart = "always";
      };
      tandoordb = {
        containerConfig = {
          pod = pods.tandoorpod.ref;
          image = "docker.io/library/postgres:17-alpine";
          volumes = [ "tandoor-db:/var/lib/postgresql/data:Z" ];
          environmentFiles = [ "/run/secrets/rendered/tandoor.env" ];
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
        unitConfig.Description = "Tandoor PostgreSQL Database";
        serviceConfig.Restart = "always";
      };
    };
    volumes = {
      "tandoor-media" = { };
      "tandoor-static" = { };
      "tandoor-db" = { };
    };
  };

  home.file."backup-scripts/tandoor.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      BACKUP_DIR="$1"
      mkdir -p "$BACKUP_DIR/media"
      rsync -ah \
        "$(podman volume inspect --format '{{.Mountpoint}}' tandoor-media)/" \
        "$BACKUP_DIR/media/"
    '';
  };
}
