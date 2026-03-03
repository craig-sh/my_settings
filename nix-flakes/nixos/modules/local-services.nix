{ lib, config, ... }:
{
  options.local.services = lib.mkOption {
    default = { };
    description = "Services managed via local.services, with automatic Caddy, firewall, and backup integration.";
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }:
        {
          options = {
            port = lib.mkOption {
              type = lib.types.port;
              description = "Port the service listens on locally.";
            };
            domain = lib.mkOption {
              type = lib.types.str;
              default = "${name}.localdomain";
              description = "Hostname for the Caddy virtual host.";
            };
            firewall = {
              extraTCPPorts = lib.mkOption {
                type = lib.types.listOf lib.types.port;
                default = [ ];
                description = "Additional TCP ports to open in the firewall.";
              };
              extraUDPPorts = lib.mkOption {
                type = lib.types.listOf lib.types.port;
                default = [ ];
                description = "Additional UDP ports to open in the firewall.";
              };
            };
            backup = {
              enable = lib.mkEnableOption "backup for this service";
              user = lib.mkOption {
                type = lib.types.str;
                default = "conrun";
                description = "User whose podman session owns this service's volumes.";
              };
              scriptFile = lib.mkOption {
                type = lib.types.str;
                default = "/home/${config.backup.user}/backup-scripts/${name}.sh";
                description = ''
                  Absolute path to an executable backup script.
                  Called by the backup service with the backup destination dir as $1.
                '';
              };
            };
          };
        }
      )
    );
  };

  config.networking.firewall = {
    allowedTCPPorts = lib.concatMap (svc: svc.firewall.extraTCPPorts) (lib.attrValues config.local.services);
    allowedUDPPorts = lib.concatMap (svc: svc.firewall.extraUDPPorts) (lib.attrValues config.local.services);
  };
}
