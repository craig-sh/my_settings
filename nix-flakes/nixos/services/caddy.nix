{ config, lib, ... }:
let
  httpsPort = config.local.caddy.httpsPort;
  mkVirtualHost = _name: svc: {
    serverAliases = [ "www.${svc.domain}:${toString httpsPort}" ];
    extraConfig = ''
      tls {
        issuer internal {
          ca local
        }
      }
      reverse_proxy http://localhost:${toString svc.port}
    '';
  };
in
{
  options.local.caddy.httpsPort = lib.mkOption {
    type = lib.types.port;
    default = 443;
    description = "HTTPS port for Caddy to listen on.";
  };

  config = {
    sops.secrets.ca_pub_cert.owner = lib.mkDefault config.systemd.services.caddy.serviceConfig.User;
    sops.secrets.ca_cert_key = {
      format = "yaml";
      owner = lib.mkDefault config.systemd.services.caddy.serviceConfig.User;
    };
    networking.firewall.allowedTCPPorts = [ httpsPort ];
    services.caddy = {
      enable = true;
      globalConfig = ''
        pki {
          ca local {
            name "Baggins CA"
            root {
              cert ${config.sops.secrets.ca_pub_cert.path}
              key ${config.sops.secrets.ca_cert_key.path}
            }
          }
        }
      '';
      virtualHosts = lib.mapAttrs' (
        name: svc: lib.nameValuePair "${svc.domain}:${toString httpsPort}" (mkVirtualHost name svc)
      ) config.local.services;
    };
  };
}
