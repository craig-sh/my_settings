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
            user = lib.mkOption {
              type = lib.types.str;
              default = "conrun";
              description = "User who owns this service (runs containers, HM module owner, used for backups).";
            };
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
            hmModule = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = "Path to the Home Manager module for this service.";
            };
            backup = {
              enable = lib.mkEnableOption "backup for this service";
              scriptFile = lib.mkOption {
                type = lib.types.str;
                default = "/home/${config.user}/backup-scripts/${name}.sh";
                description = ''
                  Absolute path to an executable backup script.
                  Run as the service user with a staging directory as $1.
                  Root copies the staging directory contents to the final backup location.
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
