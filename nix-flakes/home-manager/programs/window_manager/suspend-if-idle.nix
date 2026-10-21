# Suspend unless a long-running copy is in progress or someone is logged in
# remotely. Shared by hypridle.nix (classic) and the Noctalia idle config.
{ pkgs }:
pkgs.writeShellScriptBin "suspend-if-idle" ''
  # long running jobs
  if pgrep -x 'rsync|scp|cp' > /dev/null; then
    exit 0
  fi
  # Is anyone logged in remotely
  if [ -n "$(who | grep pts)" ]; then
    exit 0
  fi
  systemctl suspend
''
