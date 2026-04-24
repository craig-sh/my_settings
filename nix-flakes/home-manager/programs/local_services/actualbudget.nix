let
  version = "26.4.0";
  port = toString 5006;
in
{
  virtualisation.quadlet = {
    enable = true;
    containers = {
      actualbudget = {
        containerConfig = {
          image = "docker.io/actualbudget/actual-server:${version}";
          publishPorts = [ "127.0.0.1:${port}:${port}" ];
          volumes = [ "actualbudget-data:/data" ];
          dropCapabilities = [ "ALL" ];
          noNewPrivileges = true;
          healthCmd = "node src/scripts/health-check.js";
          healthInterval = "60s";
          healthTimeout = "10s";
          healthRetries = 3;
          healthStartPeriod = "20s";
        };
        unitConfig = {
          Description = "Actual Budget";
        };
        serviceConfig = {
          Restart = "always";
        };
      };
    };
  };
  virtualisation.quadlet.volumes."actualbudget-data" = { };

  home.file."backup-scripts/actualbudget.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail
      BACKUP_DIR="$1"
      rsync -ah \
        "$(podman volume inspect --format '{{.Mountpoint}}' actualbudget-data)/" \
        "$BACKUP_DIR/"
    '';
  };
}
