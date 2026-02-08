# syncthing template help from https://old.reddit.com/r/NixOS/comments/1draqf1/i_cannot_get_sopsnix_to_import_my_secrets_properly/
{ inputs, config, ... }:
let
  secretspath = builtins.toString inputs.mysecrets;
in
{
  sops = {
    defaultSopsFile = "${secretspath}/secrets/os-secrets.yaml";
    age = {
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
    #templates = {
    #    "st-carbon-tpl".content = ''${config.sops.placeholder.carbonarch-syncthing-id}'';
    #    "st-pixel6-tpl".content = ''${config.sops.placeholder.craigpixel6-syncthing-id}'';
    #    "st-hypernix-tpl".content = ''${config.sops.placeholder.hypernix-syncthing-id}'';
    #    "st-homelab-tpl".content = ''${config.sops.placeholder.homelab-syncthing-id}'';
    #};
    secrets.ca_pub_cert = {
      format = "yaml";
    };
    #secrets.carbonarch-syncthing-id = {
    #  format = "yaml";
    #};
    #secrets.craigpixel6-syncthing-id = {
    #  format = "yaml";
    #};
    #secrets.hypernix-syncthing-id = {
    #  format = "yaml";
    #};
    #secrets.homelab-syncthing-id = {
    #  format = "yaml";
    #};
  };
}
