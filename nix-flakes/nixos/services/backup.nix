{ pkgs, config, lib, ... }:
let
  enabledServices = lib.filterAttrs (_: svc: svc.backup.enable) config.local.services;
  backupCalls = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: svc: ''
      echo "==> Backing up ${name}"
      BACKUP_DIR="$CUSTOM_BACKUP_ROOT/${name}"
      STAGING_DIR="/tmp/backup-staging-${name}"
      rm -rf "$STAGING_DIR"
      mkdir -p "$BACKUP_DIR" "$STAGING_DIR"
      chown ${svc.user} "$STAGING_DIR"
      ${lib.optionalString (svc.backup.scriptFile != null) ''
        if ! su -l ${svc.user} -s /bin/sh -c "${svc.backup.scriptFile} $STAGING_DIR"; then
          echo "ERROR: backup script for ${name} failed"
          BACKUP_FAILED=1
        fi
      ''}
      ${lib.concatMapStringsSep "\n" (dump: ''
        echo "  -> pg_dump ${dump.container}"
        if ! su -l ${svc.user} -s /bin/sh -c "podman exec ${dump.container} sh -c 'pg_dump -U \"\$POSTGRES_USER\" \"\$POSTGRES_DB\"'" \
            > "$STAGING_DIR/${dump.container}.sql"; then
          echo "ERROR: pg_dump for ${dump.container} failed"
          BACKUP_FAILED=1
        fi
      '') svc.backup.pgDumps}
      rsync -a "$STAGING_DIR/" "$BACKUP_DIR/"
      rm -rf "$STAGING_DIR"
    '') enabledServices
  );
in
{
  options.local.backup.onCalendar = lib.mkOption {
    type = lib.types.str;
    default = "03:00";
    description = "When to run the backup timer (systemd OnCalendar format).";
  };

  config = lib.mkIf (enabledServices != { }) {
    sops.secrets.oracle_vm_ssh_key.format = lib.mkDefault "yaml";

    programs.ssh.extraConfig = ''
      Host backupbox.localdomain
        IdentityFile /run/secrets/oracle_vm_ssh_key
        User ubuntu
    '';

    systemd.timers."container-backup" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = config.local.backup.onCalendar;
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

        BACKUP_FAILED=0

        ${backupCalls}

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
        if [ "$BACKUP_FAILED" -eq 0 ]; then
          curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/$HEALTHCHECK_KEY/$(hostname)-backup
        else
          echo "ERROR: one or more backups failed, skipping healthcheck"
          exit 1
        fi
      '';
    };
  };
}
