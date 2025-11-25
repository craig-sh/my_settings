{config, ...}: {

  networking.firewall.allowedTCPPorts = [443];
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
    virtualHosts = {
      "frigate.localdomain" = {
        serverAliases = [ "www.frigate.localdomain" ];
        extraConfig = ''
          tls {
            issuer internal {
              ca local
            }
          }
          reverse_proxy http://localhost:8971
        '';
      };
      "ghostfolio.localdomain" = {
        serverAliases = [ "www.ghostfolio.localdomain" ];
        extraConfig = ''
          tls {
            issuer internal {
              ca local
            }
          }
          reverse_proxy http://localhost:3333
        '';
      };
    };
  };
}

