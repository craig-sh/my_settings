{ config, pkgs, ... }:

{
  networking = {
    hostName = "virtnix2";
    firewall.enable = false;
  };
  services.k3s = {
    enable = true;
    role = "agent";
    serverAddr = "https://virtnix.localdomain:6443";
    extraFlags = toString [
      " --node-ip 192.168.1.33 "
    ];
    tokenFile = config.sops.secrets.k3s-server-token.path;
  };
}
