{ ... }: {
  imports = [ ../../services/backup.nix ];
  local.backup.onCalendar = "03:30";
}
