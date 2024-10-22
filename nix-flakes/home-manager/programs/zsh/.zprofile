# Legacy,we don't source this with home manager
typeset -U PATH path
path=(
  "$HOME/.nix-profile/bin"
  "$PYENV_ROOT/bin"
  "$HOME/.poetry/bin"
  "$HOME/.cargo/bin"
  '/usr/local/sbin'
  '/usr/local/bin'
  '/usr/bin'
  '/usr/sbin'
  '/sbin'
  '/bin'
  '/usr/games'
  "$HOME/wm/panels"
  "$HOME/.local/bin"
  "$HOME/my_settings/my_scripts"
  "$HOME/.local/share/flatpak/exports/share"
  "/var/lib/flatpak/exports/share"
  "$path[@]"
)
