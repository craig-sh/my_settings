{ config, osConfig, ... }:
let
  version = osConfig.local.services.dawarich.version;
  servicePort = toString osConfig.local.services.dawarich.port;
  internalPort = "3000";
  domain = osConfig.local.services.dawarich.domain;

  image = "docker.io/freikin/dawarich:${version}";

  # Shared by the web and sidekiq containers - both run the same image and
  # need the same view of uploads, imports and generated assets.
  appVolumes = [
    "dawarich-public:/var/app/public"
    "dawarich-watched:/var/app/tmp/imports/watched"
    "dawarich-storage:/var/app/storage"
  ];

  appEnvironments = {
    RAILS_ENV = "production";
    REDIS_URL = "redis://localhost:6379";
    DATABASE_HOST = "localhost";
    DATABASE_PORT = "5432";
    DATABASE_USERNAME = "dawarich";
    DATABASE_NAME = "dawarich";
    APPLICATION_HOSTS = "${domain},localhost,127.0.0.1";
    APPLICATION_PROTOCOL = "https";
    DOMAIN = domain;
    TIME_ZONE = "America/Toronto";
    RAILS_LOG_TO_STDOUT = "true";
    SELF_HOSTED = "true";
    STORE_GEODATA = "true";
  };

  inherit (config.virtualisation.quadlet) pods;
in
{
  virtualisation.quadlet = {
    enable = true;

    pods.dawarichpod = {
      podConfig.publishPorts = [ "127.0.0.1:${servicePort}:${internalPort}" ];
      autoStart = true;
    };

    containers = {
      dawarich = {
        containerConfig = {
          pod = pods.dawarichpod.ref;
          inherit image;
          pull = "newer";
          entrypoint = "web-entrypoint.sh";
          exec = [
            "bin/rails"
            "server"
            "-p"
            internalPort
            "-b"
            "::"
          ];
          environmentFiles = [ "/run/secrets/rendered/dawarich.env" ];
          environments = appEnvironments // {
            WEB_CONCURRENCY = "1";
          };
          # dawarich-db is mounted here so the in-app backup/restore page can
          # reach the database directory, matching upstream's compose file.
          volumes = appVolumes ++ [ "dawarich-db:/dawarich_db_data" ];
        };
        unitConfig = {
          Description = "Dawarich Web";
          After = [
            "dawarichdb.service"
            "dawarichredis.service"
          ];
          Requires = [
            "dawarichdb.service"
            "dawarichredis.service"
          ];
        };
        serviceConfig.Restart = "always";
      };

      dawarich-sidekiq = {
        containerConfig = {
          pod = pods.dawarichpod.ref;
          inherit image;
          pull = "newer";
          entrypoint = "sidekiq-entrypoint.sh";
          exec = "sidekiq";
          environmentFiles = [ "/run/secrets/rendered/dawarich.env" ];
          environments = appEnvironments // {
            BACKGROUND_PROCESSING_CONCURRENCY = "3";
          };
          volumes = appVolumes;
        };
        unitConfig = {
          Description = "Dawarich Sidekiq Worker";
          After = [
            "dawarichdb.service"
            "dawarichredis.service"
            "dawarich.service"
          ];
          Requires = [
            "dawarichdb.service"
            "dawarichredis.service"
            "dawarich.service"
          ];
        };
        serviceConfig.Restart = "always";
      };

      dawarichdb = {
        containerConfig = {
          pod = pods.dawarichpod.ref;
          image = "docker.io/postgis/postgis:17-3.5-alpine";
          pull = "newer";
          shmSize = "1g";
          volumes = [
            "dawarich-db:/var/lib/postgresql/data:Z"
            "dawarich-shared:/var/shared:Z"
          ];
          environmentFiles = [ "/run/secrets/rendered/dawarich.env" ];
          environments = {
            POSTGRES_USER = "dawarich";
            POSTGRES_DB = "dawarich";
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
        unitConfig.Description = "Dawarich PostGIS Database";
        serviceConfig.Restart = "always";
      };

      dawarichredis = {
        containerConfig = {
          pod = pods.dawarichpod.ref;
          image = "docker.io/library/redis:7.4-alpine";
          pull = "newer";
          exec = [
            "redis-server"
            "--save"
            "900"
            "1"
            "--save"
            "300"
            "10"
            "--appendonly"
            "no"
          ];
          # Upstream's compose shares one volume between redis:/data and
          # db:/var/shared. Keep them separate - the redis entrypoint chowns
          # everything under /data to the redis uid before dropping privileges,
          # which would trample anything postgres wrote to the same volume.
          volumes = [ "dawarich-redis:/data:Z" ];
          dropCapabilities = [ "ALL" ];
          addCapabilities = [
            "CHOWN"
            "SETGID"
            "SETUID"
          ];
          noNewPrivileges = true;
        };
        unitConfig.Description = "Dawarich Redis";
        serviceConfig.Restart = "always";
      };
    };

    volumes = {
      "dawarich-db" = { };
      "dawarich-redis" = { };
      "dawarich-shared" = { };
      "dawarich-public" = { };
      "dawarich-watched" = { };
      "dawarich-storage" = { };
    };
  };

  home.file."backup-scripts/dawarich.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      BACKUP_DIR="$1"
      mkdir -p "$BACKUP_DIR/storage"
      rsync -ah \
        "$(podman volume inspect --format '{{.Mountpoint}}' dawarich-storage)/" \
        "$BACKUP_DIR/storage/"
    '';
  };
}
