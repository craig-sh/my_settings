{ config, pkgs, ... }:

{
  networking.hostName = "virtnix";
  networking.firewall.enable = false;
  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [
    " --disable=traefik" # Optionally add additional args to k3s
    " --write-kubeconfig-mode=0644"
  ];

  # k8s backupscript still needs some hardcoded setup like keys to backup server
  systemd.timers."k3s-backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "04:00";
      Unit = "k3s-backup.service";
    };
  };

  systemd.services."k3s-backup" = {
    path = [
      pkgs.bash
      pkgs.restic
      pkgs.k3s
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

}

