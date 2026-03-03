{ lib, ... }:
{
  options.local.services = lib.mkOption {
    default = { };
    description = "Services managed via local.services, with automatic Caddy and backup integration.";
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
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
            backup = {
              enable = lib.mkEnableOption "backup for this service";
              scriptFile = lib.mkOption {
                type = lib.types.str;
                default = "/home/conrun/backup-scripts/${name}.sh";
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
}
