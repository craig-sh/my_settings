let
  port = toString 2021;
in
{
  virtualisation.quadlet = {
    enable = true;
    containers = {
      donetick = {
        containerConfig = {
          image = "docker.io/donetick/donetick:v0.1.74";
          publishPorts = [ "127.0.0.1:${port}:${port}" ];
          volumes = [
            "donetick-data:/donetick-data:Z"
            "%h/donetick-config:/config:ro"
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

  home.file."donetick-config/selfhosted.yaml".text = ''
    name: "selfhosted"
    database:
      type: "sqlite"
      migration: true
    server:
      port: 2021
      cors_allow_origins:
        - "https://donetick.localdomain"
        - "capacitor://localhost"
      serve_frontend: true
    realtime:
      enabled: true
      sse_enabled: true
  '';

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
