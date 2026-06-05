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
              type = lib.types.nullOr lib.types.port;
              default = null;
              description = "Port the service listens on locally. Required when caddy.enable is true.";
            };
            widget = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = ''
                Homepage widget config for this service, rendered as-is into services.yaml.
                If `url` is omitted and the service is on the same host as homepage, it
                auto-fills to `http://host.containers.internal:<port>`. Cross-host widgets
                must specify `url` explicitly.
              '';
            };
            category = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = ''
                Homepage dashboard category for this service's tile. Used only when
                `widget` is set; widget-less services are grouped under "Links". If
                omitted on a widget service, falls back to "Other".
              '';
            };
            icon = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = ''
                Homepage tile icon. Accepts a Dashboard Icons name (e.g. "jellyfin.png"),
                a Material Design Icon (e.g. "mdi-folder-#ff0000"), Simple Icons / Selfh.st
                references, or a full URL. See https://gethomepage.dev/configs/services/#icons.
              '';
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
            caddy.enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to expose this service via the Caddy reverse proxy.";
            };
            version = lib.mkOption {
              type = lib.types.str;
              default = "latest";
              description = "Container image version tag for this service.";
            };
            hmModule = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = "Path to the Home Manager module for this service.";
            };
            tier = lib.mkOption {
              type = lib.types.enum [
                "normal"
                "critical"
              ];
              default = "normal";
              description = ''
                Healthcheck tier — units in different tiers ping separate healthchecks.io
                endpoints. Only takes effect for units enumerated in `units`; auto-discovered
                units not listed by any service fall back to "normal".
              '';
            };
            units = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = ''
                Systemd unit names belonging to this service (e.g. "tandoor.service",
                "tandoordb.service"). Used by container-healthcheck to map units to tiers.
              '';
            };
            backup = {
              enable = lib.mkEnableOption "backup for this service";
              scriptFile = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = "/home/${config.user}/backup-scripts/${name}.sh";
                description = ''
                  Absolute path to an executable backup script, or null to skip.
                  Run as the service user with a staging directory as $1.
                  Root copies the staging directory contents to the final backup location.
                '';
              };
              pgDumps = lib.mkOption {
                type = lib.types.listOf (
                  lib.types.submodule {
                    options.container = lib.mkOption {
                      type = lib.types.str;
                      description = "Rootless podman container running postgres. Uses POSTGRES_USER/POSTGRES_DB env vars from the container.";
                    };
                  }
                );
                default = [ ];
                description = "Postgres containers to dump via pg_dump inside the container.";
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
