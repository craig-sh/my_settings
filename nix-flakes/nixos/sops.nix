{ config, ... }:
{
  sops.defaultSopsFile = ../secrets/os-secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
  sops.secrets.ca_pub_cert = {
    format = "yaml";
  };
  sops.secrets.k3s-server-token = {
    format = "yaml";
  };
  sops.secrets.virtnix-tailscale-key = {
    format = "yaml";
  };
}
