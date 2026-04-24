{ pkgs, ... }:
let
  port = toString 2021;
  configFile = pkgs.writeText "selfhosted.yaml" ''
    name: "selfhosted"
    is_done_tick_dot_com: false
    is_user_creation_disabled: false
    database:
      type: "sqlite"
      migration: true
    jwt:
      session_time: 168h
      max_refresh: 1440h
    server:
      port: 2021
      read_timeout: 10s
      write_timeout: 10s
      rate_period: 60s
      rate_limit: 300
      cors_allow_origins:
        - "http://localhost:5173"
        - "http://localhost:7926"
        - "https://donetick.localdomain"
        - "capacitor://localhost"
        - "https://localhost"
        - "http://localhost"
      serve_frontend: true
    logging:
      level: "info"
      encoding: "json"
      development: false
    scheduler_jobs:
      due_job: 30m
      overdue_job: 3h
      pre_due_job: 3h
    realtime:
      enabled: true
      sse_enabled: true
      heartbeat_interval: 60s
      connection_timeout: 120s
      max_connections: 1000
      max_connections_per_user: 5
      event_queue_size: 2048
      cleanup_interval: 2m
      stale_threshold: 5m
      enable_compression: true
      enable_stats: true
      allowed_origins:
        - "*"
  '';
in
{
  virtualisation.quadlet = {
    enable = true;
    containers = {
      donetick = {
        containerConfig = {
          image = "docker.io/donetick/donetick:v0.1.75";
          publishPorts = [ "0.0.0.0:${port}:${port}" ];
          volumes = [
            "donetick-data:/donetick-data:Z"
            "${configFile}:/config/selfhosted.yaml:ro"
          ];
          environmentFiles = [ "/run/secrets/rendered/donetick.env" ];
          environments = {
            DT_ENV = "selfhosted";
            DT_SQLITE_PATH = "/donetick-data/donetick.db";
          };
          dropCapabilities = [ "ALL" ];
          noNewPrivileges = true;
        };
        unitConfig = {
          Description = "Donetick Task Manager";
        };
        serviceConfig = {
          Restart = "always";
        };
      };
    };
    volumes."donetick-data" = { };
  };

  home.file."backup-scripts/donetick.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      BACKUP_DIR="$1"
      rsync -ah \
        "$(podman volume inspect --format '{{.Mountpoint}}' donetick-data)/" \
        "$BACKUP_DIR/"
    '';
  };
}
