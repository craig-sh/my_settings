export PYENV_ROOT="$HOME/.pyenv"
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
export PATH
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
fi

