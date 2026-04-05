{ ... }: {
  imports = [ ../../services/backup.nix ];
  local.backup.onCalendar = "03:30";
  local.backup.tmpDir = "/mnt/k8sconfig/tmpbackup";
  local.backup.workDir = "/mnt/k8sconfig/backup_work_dir";
}
