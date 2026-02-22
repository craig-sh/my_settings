let
  version = "26.2.0";
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
          volumes = [ "/mnt/actualbudget/data:/data:Z" ];
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
}
