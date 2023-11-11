{ config, pkgs, ... }:

{
  networking.hostName = "virtnix2";
  networking.firewall.enable = false;
  services.k3s.enable = true;
  services.k3s.role = "agent";
  services.k3s.serverAddr = "https://virtnix.localdomain:6443";
  services.k3s.extraFlags = toString [
    " --node-ip 192.168.1.33 "
  ];
  services.k3s.tokenFile = config.sops.secrets.k3s-server-token.path;
}

