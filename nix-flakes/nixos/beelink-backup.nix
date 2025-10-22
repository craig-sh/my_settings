{ pkgs, config, ...}:
{
  programs.ssh = {
    extraConfig = "
      Host backupbox.localdomain
        IdentityFile /run/secrets/oracle_vm_ssh_key
        User ubuntu
    ";
  };

  systemd.timers."container-backup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "03:00";
      Unit = "container-backup.service";
    };
  };
  systemd.services."container-backup" = {
    path = [
      pkgs.bash
      pkgs.restic
      pkgs.hostname
      pkgs.openssh
      pkgs.gzip
      pkgs.curl
      pkgs.su
      pkgs.rsync
    ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
   environment = {
      RESTIC_PASSWORD_FILE = config.sops.secrets.restic_password.path;
      HEALTHCHECK_KEY_FILE = config.sops.secrets.healthcheck_key.path;
      REMOTE_USER = "ubuntu";
      REMOTE_REPO = "backupbox.localdomain";
      REMOTE_PATH = "/backup/restic";
      TMPDIR = "/root/tmpbackup";
      CUSTOM_BACKUP_ROOT = "/root/backup";
    };
    script = ''
      #!/usr/bin/env bash
      set -euo pipefail


      export RESTIC_HOST="$(hostname)";
      export RESTIC_TAG="$(hostname)";
      export HEALTHCHECK_KEY="$(cat $HEALTHCHECK_KEY_FILE)";
      export RESTIC_REPOSITORY="sftp:$REMOTE_USER@$REMOTE_REPO:$REMOTE_PATH";


      mkdir -p $TMPDIR;
      mkdir -p $CUSTOM_BACKUP_ROOT;

      # Frigate
      FRIGRATE_SRC_DIR=$(su -l craig -c 'podman volume inspect --format "{{.Mountpoint}}" frigate-config');
      FRIGRATE_DEST_DIR=$CUSTOM_BACKUP_ROOT/frigate;
      rm -rf $FRIGRATE_DEST_DIR;
      mkdir $FRIGRATE_DEST_DIR;
      rsync -ah $FRIGRATE_SRC_DIR/ $FRIGRATE_DEST_DIR/

      # Actual backup
      restic --verbose backup --tag=$RESTIC_TAG $CUSTOM_BACKUP_ROOT

      # prune
      restic forget \
        --tag=$RESTIC_TAG \
        --keep-within-daily 7d \
        --keep-within-weekly 1m \
        --keep-within-monthly 1y \
        --keep-within-yearly 100y;
      restic prune;

      # Healthcheck
      curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/$HEALTHCHECK_KEY/beelink-backup
    '';
  };

}
