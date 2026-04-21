{ config, osConfig, ... }:
let
  version = osConfig.local.services.immich.version;
  servicePort = toString osConfig.local.services.immich.port;
  internalPort = "2283";

  libraryPath = "/mnt/main-nfs/one/immich-hl";

  inherit (config.virtualisation.quadlet) pods;
in
{
  virtualisation.quadlet = {
    enable = true;

    pods.immichpod = {
      autoStart = true;
      podConfig.publishPorts = [ "127.0.0.1:${servicePort}:${internalPort}" ];
    };

    containers = {
      immich = {
        autoStart = true;
        unitConfig = {
          Description = "Immich Server";
          Wants = "network-online.target nfs-client.target";
          After = [
            "network-online.target"
            "nfs-client.target"
            "immichdb.service"
            "immichvalkey.service"
          ];
          Requires = [
            "immichdb.service"
            "immichvalkey.service"
          ];
        };
        containerConfig = {
          pod = pods.immichpod.ref;
          image = "ghcr.io/immich-app/immich-server:${version}";
          user = "0:0";
          environmentFiles = [ "/run/secrets/rendered/immich.env" ];
          environments = {
            DB_HOSTNAME = "localhost";
            DB_PORT = "5432";
            DB_USERNAME = "immich";
            DB_DATABASE_NAME = "immich";
            REDIS_HOSTNAME = "localhost";
            REDIS_PORT = "6379";
            IMMICH_MACHINE_LEARNING_URL = "http://localhost:3003";
            TZ = "America/Toronto";
          };
          volumes = [
            "${libraryPath}:/data"
          ];
        };
        serviceConfig.Restart = "always";
      };

      immich-ml = {
        autoStart = true;
        unitConfig.Description = "Immich Machine Learning";
        containerConfig = {
          pod = pods.immichpod.ref;
          image = "ghcr.io/immich-app/immich-machine-learning:${version}";
          environments.TZ = "America/Toronto";
          volumes = [ "immich-ml-cache:/cache" ];
        };
        serviceConfig.Restart = "always";
      };

      immichdb = {
        autoStart = true;
        unitConfig.Description = "Immich PostgreSQL (VectorChord)";
        containerConfig = {
          pod = pods.immichpod.ref;
          image = "ghcr.io/immich-app/postgres:16-vectorchord0.4.3";
          volumes = [ "immich-db:/var/lib/postgresql/data:Z" ];
          environmentFiles = [ "/run/secrets/rendered/immich.env" ];
          environments = {
            POSTGRES_USER = "immich";
            POSTGRES_DB = "immich";
            POSTGRES_INITDB_ARGS = "--data-checksums";
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
        serviceConfig.Restart = "always";
      };

      immichvalkey = {
        autoStart = true;
        unitConfig.Description = "Immich Valkey";
        containerConfig = {
          pod = pods.immichpod.ref;
          image = "docker.io/valkey/valkey:8-bookworm";
          volumes = [ "immich-valkey:/data:Z" ];
          dropCapabilities = [ "ALL" ];
          addCapabilities = [
            "CHOWN"
            "SETGID"
            "SETUID"
          ];
          noNewPrivileges = true;
        };
        serviceConfig.Restart = "always";
      };
    };

    volumes = {
      "immich-db" = { };
      "immich-valkey" = { };
      "immich-ml-cache" = { };
    };
  };
}
