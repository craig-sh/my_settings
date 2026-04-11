{ config, ... }:
{
  sops.secrets.tailscale-server-auth-key.format = "yaml";

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.tailscale-server-auth-key.path;
    extraUpFlags = [ "--accept-dns=false" ];
    openFirewall = true;
  };
}
