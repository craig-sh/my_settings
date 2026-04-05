{ ... }: {
  imports = [ ../../services/backup.nix ];
  local.backup.onCalendar = "03:00";
  local.backup.tmpDir = "/root/tmpbackup";
  local.backup.workDir = "/root/backup";
}
