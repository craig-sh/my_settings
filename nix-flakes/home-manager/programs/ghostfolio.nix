{config, ...}: let
  version = "2.228.0";
  internalPort = toString 3333;
  servicePort = toString 3333;
  inherit (config.virtualisation.quadlet) pods;
in {
  virtualisation.quadlet = {
    enable = true;
    pods.ghostfoliopod = {
      podConfig = {
        publishPorts = [
          "127.0.0.1:${servicePort}:${internalPort}"
        ];
      };
      autoStart = true;
    };
    containers = {
      ghostfolio = {
        containerConfig = {
          pod = pods.ghostfoliopod.ref;
          environmentFiles = ["/run/secrets/rendered/ghostfolio.env"];
          image = "docker.io/ghostfolio/ghostfolio:${version}";
          #timezone = "America/Toronto";
          dropCapabilities = [ "ALL" ];
          noNewPrivileges = true;
          podmanArgs = [ "--init" ];
          healthCmd = "curl -f http://localhost:3333/api/v1/health";
          healthInterval = "10s";
          healthTimeout = "5s";
          healthRetries = 5;
        };
        unitConfig = let
          inherit (config.virtualisation.quadlet.containers) gfpostgres gfredis;
        in {
          Description = "Ghostfolio Application";
          After = [ "gfpostgres.service" "gfredis.service" ];
          Requires = [ "gfpostgres.service" "gfredis.service" ];
        };
        serviceConfig = {
          Restart = "always";
          #TimeoutStartSec = "infinity";
        };
      };
      gfredis = {
        containerConfig = {
          pod = pods.ghostfoliopod.ref;
          image = "docker.io/library/redis:alpine";
          dropCapabilities = [ "ALL" ];
          #userns = "keep-id:uid=999"; # this is redis user id inside the container
          noNewPrivileges = true;
          environmentFiles = ["/run/secrets/rendered/ghostfolio.env"];
          exec = ''/bin/sh -c 'redis-server --requirepass "''${REDIS_PASSWORD:?REDIS_PASSWORD variable is not set}"' '';
          #healthCmd = ''redis-cli --pass "''${REDIS_PASSWORD}" ping | grep PONG'';
          #healthInterval = "10s";
          #healthTimeout = "5s";
          #healthRetries = 5;
          volumes = [ "gf-redis:/data:Z" ];
        };
        unitConfig = {
          Description = "Ghostfolio Redis Cache";
        };
        serviceConfig = {
          Restart = "always";
          #TimeoutStartSec = "infinity";
        };
      };
      gfpostgres = {
        containerConfig = {
          pod = pods.ghostfoliopod.ref;
          image = "docker.io/library/postgres:15-alpine";
          volumes = [ "gf-postgres:/var/lib/postgresql/data" ];
          environmentFiles = ["/run/secrets/rendered/ghostfolio.env"];
          dropCapabilities = [ "ALL" ];
          addCapabilities = [ "CHOWN" "DAC_READ_SEARCH" "FOWNER" "SETGID" "SETUID" ];
          noNewPrivileges = true;
          #healthCmd = ''pg_isready -hlocalhost -d "''${POSTGRES_DB}" -U ''${POSTGRES_USER}'';
          #healthInterval = "10s";
          #healthTimeout = "5s";
          #healthRetries = 5;
        };
        unitConfig = {
          Description = "Ghostfolio PostgreSQL Database";
        };
        serviceConfig = {
          Restart = "always";
          #TimeoutStartSec = "infinity";
        };
      };
    };
    volumes = {
      "gf-postgres" = { };
      "gf-redis" = { };
    };
  };
}
