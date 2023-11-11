{ config, pkgs, ... }:

{
  networking.hostName ="virtnix";
  networking.firewall.enable = false;
  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [
    " --disable=traefik" # Optionally add additional args to k3s
    " --write-kubeconfig-mode=0644"
  ];
}

