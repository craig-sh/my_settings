{ config, ... }:
{
  sops.defaultSopsFile = ../secrets/os-secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
  sops.secrets.ca_pub_cert = {
    format="yaml";
  };
}