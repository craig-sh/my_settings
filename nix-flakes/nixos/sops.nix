# syncthing template help from https://old.reddit.com/r/NixOS/comments/1draqf1/i_cannot_get_sopsnix_to_import_my_secrets_properly/
{ config, ... }:
{
  sops.defaultSopsFile = ../secrets/os-secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
  sops.age.generateKey = true;
  #sops.templates = {
  #    "st-carbon-tpl".content = ''${config.sops.placeholder.carbonarch-syncthing-id}'';
  #    "st-pixel6-tpl".content = ''${config.sops.placeholder.craigpixel6-syncthing-id}'';
  #    "st-hypernix-tpl".content = ''${config.sops.placeholder.hypernix-syncthing-id}'';
  #    "st-homelab-tpl".content = ''${config.sops.placeholder.homelab-syncthing-id}'';
  # };
  sops.secrets.ca_pub_cert = {
    format = "yaml";
  };
  sops.secrets.k3s-server-token = {
    format = "yaml";
  };
  sops.secrets.virtnix-tailscale-key = {
    format = "yaml";
  };
  #sops.secrets.carbonarch-syncthing-id = {
  #  format = "yaml";
  #};
  #sops.secrets.craigpixel6-syncthing-id = {
  #  format = "yaml";
  #};
  #sops.secrets.hypernix-syncthing-id = {
  #  format = "yaml";
  #};
  #sops.secrets.homelab-syncthing-id = {
  #  format = "yaml";
  #};
}
