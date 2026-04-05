{ config, osConfig, pkgs, ... }:
let
  version = "2.4";
  servicePort = toString osConfig.local.services.tandoor.port;
  internalPort = "8080";
  inherit (config.virtualisation.quadlet) pods;
  nginxConf = pkgs.writeText "tandoor-nginx.conf" ''
    upstream tandoor {
      server unix:/run/tandoor.sock;
    }

    server {
      listen ${internalPort};
      server_name _;
      client_max_body_size 128m;

      location /static/ {
        alias /static/;
      }

      location /media/ {
        alias /media/;
      }

      location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_pass http://tandoor;
      }
    }
  '';
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
            CSRF_TRUSTED_ORIGINS = "https://tandoor.localdomain:9443"; # TODO remove after migration is complete
            TZ = "America/Toronto";
            GUNICORN_MEDIA = "0";
            SECURE_PROXY_SSL_HEADER = "HTTP_X_FORWARDED_PROTO,https";
          };
          volumes = [
            "tandoor-media:/opt/recipes/mediafiles"
            "tandoor-static:/opt/recipes/staticfiles"
            "tandoor-socket:/run/"
          ];
          dropCapabilities = [ "ALL" ];
          noNewPrivileges = true;
        };
        unitConfig = {
          Description = "Tandoor Recipe Manager";
          After = [ "tandoordb.service" ];
          Requires = [ "tandoordb.service" ];
        };
        serviceConfig.Restart = "always";
      };
      tandoornginx = {
        containerConfig = {
          pod = pods.tandoorpod.ref;
          image = "docker.io/library/nginx:alpine";
          volumes = [
            "tandoor-media:/media:ro"
            "tandoor-static:/static:ro"
            "tandoor-socket:/run/"
            "${nginxConf}:/etc/nginx/conf.d/default.conf:ro"
          ];
          dropCapabilities = [ "ALL" ];
          addCapabilities = [
            "CHOWN"
            "NET_BIND_SERVICE"
            "SETGID"
            "SETUID"
          ];
          noNewPrivileges = true;
          healthCmd = "curl -f http://localhost:${internalPort}/";
          healthInterval = "30s";
          healthTimeout = "10s";
          healthRetries = 5;
          healthStartPeriod = "30s";
        };
        unitConfig = {
          Description = "Tandoor Nginx Proxy";
          After = [ "tandoor.service" ];
          Requires = [ "tandoor.service" ];
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
      "tandoor-socket" = { };
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
