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
  "$path[@]"
)
export PATH
eval "$(pyenv init -)"
