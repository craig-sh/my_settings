{ config, lib, ... }:
let
  mkVirtualHost = _name: svc: {
    serverAliases = [ "www.${svc.domain}" ];
    extraConfig = ''
      tls {
        issuer internal {
          ca local
        }
      }
      reverse_proxy http://127.0.0.1:${toString svc.port}
    '';
  };
in
{
  sops.secrets.ca_pub_cert = {
    owner = lib.mkDefault config.systemd.services.caddy.serviceConfig.User;
    mode = "0444";
  };
  sops.secrets.ca_cert_key = {
    format = "yaml";
    owner = lib.mkDefault config.systemd.services.caddy.serviceConfig.User;
  };
  networking.firewall.allowedTCPPorts = [ 443 ];
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
      name: svc: lib.nameValuePair svc.domain (mkVirtualHost name svc)
    ) config.local.services;
  };
}
