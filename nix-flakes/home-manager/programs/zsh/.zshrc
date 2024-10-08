[ -f "/home/craig/.ghcup/env" ] && source "/home/craig/.ghcup/env" # ghcup-env

if [[ -n $VIRTUAL_ENV && -e "${VIRTUAL_ENV}/bin/activate" ]]; then
  source "${VIRTUAL_ENV}/bin/activate"
fi

# TODO should we move these exports to .zprofile?
# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='nvim'
export VISUAL='nvim'
autoload edit-command-line; zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt inc_append_history extendedglob nomatch notify hist_ignore_all_dups share_history
setopt autopushd pushdignoredups
bindkey -v
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward
# ctrl + left|right to jump words
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[ShiftTab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"      beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"       end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"    overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}" backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"    delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"        up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"      down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"      backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"     forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"    beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"  end-of-buffer-or-history
[[ -n "${key[ShiftTab]}"  ]] && bindkey -- "${key[ShiftTab]}"  reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    function zle_application_mode_start {
        echoti smkx
    }
    function zle_application_mode_stop {
        echoti rmkx
    }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search

zstyle ':completion:*' menu select # select completions with arrow keys
zstyle ':completion:*' group-name '' # group results by category
zstyle ':completion:::::' completer _expand _complete _ignored _approximate #enable approximate matches for completion

#Display info for processses that take longer than 10 secs
REPORTTIME=10

if [[ -r ~/.zsh_aliases ]]; then
  source ~/.zsh_aliases
fi

if [ -x /usr/bin/cowsay -a -x /usr/bin/fortune ]; then
      fortune -s | cowsay
fi

if [[ -d "/usr/share/fzf" ]]; then
  source /usr/share/fzf/key-bindings.zsh
  source /usr/share/fzf/completion.zsh
elif [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
fi

eval "$(starship init zsh)"

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
source "${ZINIT_HOME}/zinit.zsh"
zinit ice atclone"dircolors -b LS_COLORS > c.zsh" atpull'%atclone' pick"c.zsh" nocompile'!'
zinit light trapd00r/LS_COLORS
if command -v notify-send 1>/dev/null 2>&1; then
  zinit light MichaelAquilina/zsh-auto-notify
fi
zinit ice silent wait blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions
zinit ice silent wait atinit"zpcompinit; zpcdreplay"
zinit light zdharma/fast-syntax-highlighting
zinit ice silent wait atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions


# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

