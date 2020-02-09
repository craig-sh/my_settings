export PYENV_ROOT="$HOME/.pyenv"
export PYENV_VERSION="3.8.1"
typeset -U PATH path
path=(
  "$PYENV_ROOT/bin"
  "$HOME/.cargo/bin"
  '/usr/local/sbin'
  '/usr/local/bin'
  '/usr/sbin'
  '/usr/bin'
  '/sbin'
  '/bin'
  '/usr/games'
  "$HOME/wm/panels"
  "$HOME/.local/bin"
  "$HOME/my_settings/my_scripts"
  "$path[@]"
)
export PATH

if command -v pyenv 1>/dev/null 2>&1; then
   eval "$(pyenv init -)"
fi

if [[ -n $VIRTUAL_ENV && -e "${VIRTUAL_ENV}/bin/activate" ]]; then
  source "${VIRTUAL_ENV}/bin/activate"
fi
