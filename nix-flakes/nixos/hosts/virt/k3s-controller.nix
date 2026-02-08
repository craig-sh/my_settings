{ config, pkgs, ... }:

{
  networking = {
    hostName = "virtnix";
    firewall.enable = false;
  };

  # if we want to configure firewall for tailscale
  #    # always allow traffic from your Tailscale network
  #    trustedInterfaces = [ "tailscale0" ];
  #
  #    # allow the Tailscale UDP port through the firewall
  #    allowedUDPPorts = [ config.services.tailscale.port ];

  services.k3s = {
    enable = true;
    package = pkgs.k3s_1_34;
    role = "server";
    extraFlags = toString [
      " --disable=traefik" # Optionally add additional args to k3s
      " --write-kubeconfig-mode=0644"
    ];
  };

  # k8s backupscript still needs some hardcoded setup like keys to backup server
  systemd = {
    timers."k3s-backup" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "04:00";
        Unit = "k3s-backup.service";
      };
    };

    services."k3s-backup" = {
      path = [
        pkgs.bash
        pkgs.restic
        pkgs.k3s_1_34
        pkgs.hostname
        pkgs.openssh
        pkgs.gzip
        pkgs.curl
      ];
      script = ''
        set -eu
        cd /home/craig/homelab/backup
        ./restic_run
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };

}
