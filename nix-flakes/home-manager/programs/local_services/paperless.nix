{ config, osConfig, ... }:
let
  version = "2.20";
  servicePort = toString osConfig.local.services.paperless.port;
  internalPort = "8000";
  inherit (config.virtualisation.quadlet) pods;
in
{
  virtualisation.quadlet = {
    enable = true;
    pods.paperlesspod = {
      podConfig.publishPorts = [ "127.0.0.1:${servicePort}:${internalPort}" ];
      autoStart = true;
    };
    containers = {
      paperless = {
        containerConfig = {
          pod = pods.paperlesspod.ref;
          image = "ghcr.io/paperless-ngx/paperless-ngx:${version}";
          environmentFiles = [ "/run/secrets/rendered/paperless.env" ];
          environments = {
            PAPERLESS_REDIS = "redis://localhost:6379";
            PAPERLESS_DBENGINE = "postgresql";
            PAPERLESS_DBHOST = "localhost";
            PAPERLESS_DBPORT = "5432";
            PAPERLESS_DBNAME = "paperless";
            PAPERLESS_DBUSER = "paperless";
            PAPERLESS_ADMIN_USER = "admin";
            PAPERLESS_ADMIN_MAIL = "craig@localdomain";
            PAPERLESS_URL = "https://paperless.localdomain";
            PAPERLESS_TIME_ZONE = "America/Toronto";
            PAPERLESS_OCR_LANGUAGE = "eng";
            USERMAP_UID = "0";
            USERMAP_GID = "0";
          };
          volumes = [
            "paperless-data:/usr/src/paperless/data"
            "/mnt/main-nfs/paperless/media:/usr/src/paperless/media"
            "/mnt/main-nfs/paperless/consume:/usr/src/paperless/consume"
          ];
        };
        unitConfig = {
          Description = "Paperless-ngx Document Manager";
          After = [ "paperlessdb.service" "paperlessredis.service" ];
          Requires = [ "paperlessdb.service" "paperlessredis.service" ];
        };
        serviceConfig.Restart = "always";
      };
      paperlessdb = {
        containerConfig = {
          pod = pods.paperlesspod.ref;
          image = "docker.io/library/postgres:17-alpine";
          volumes = [ "paperless-db:/var/lib/postgresql/data:Z" ];
          environmentFiles = [ "/run/secrets/rendered/paperless.env" ];
          environments = {
            POSTGRES_DB = "paperless";
            POSTGRES_USER = "paperless";
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
        unitConfig.Description = "Paperless-ngx PostgreSQL Database";
        serviceConfig.Restart = "always";
      };
      paperlessredis = {
        containerConfig = {
          pod = pods.paperlesspod.ref;
          image = "docker.io/library/redis:8-alpine";
          volumes = [ "paperless-redis:/data:Z" ];
          dropCapabilities = [ "ALL" ];
          addCapabilities = [ "CHOWN" "SETGID" "SETUID" ];
          noNewPrivileges = true;
        };
        unitConfig.Description = "Paperless-ngx Redis Broker";
        serviceConfig.Restart = "always";
      };
    };
    volumes = {
      "paperless-data" = { };
      "paperless-db" = { };
      "paperless-redis" = { };
    };
  };
}
