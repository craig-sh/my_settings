{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    syntaxHighlighting = {
      enable = false;
    };
    enableAutosuggestions = true;
    enableCompletion = true;
    autocd = true;
    defaultKeymap = "viins";

    history = {
      extended = true;
      ignoreDups = true;
      save = 1000000;
      size = 1000000;
      expireDuplicatesFirst = true;
    };
    historySubstringSearch = {
      enable = true;
    };

    zplug = {
      enable = true;
      plugins = [
        { name = "MichaelAquilina/zsh-auto-notify"; }
        { name = "zdharma-continuum/fast-syntax-highlighting"; }
        { name = "zpm-zsh/ls"; }
        #{ name = "zpm-zsh/dircolors-neutral"; }
      ];
    };

    initExtraBeforeCompInit = ''
unsetopt BEEP
source ~/.zsh_aliases

fpath+=(${pkgs.exa}/share/zsh/site-functions)

autoload edit-command-line; zle -N edit-command-line
bindkey -M vicmd v edit-command-line

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

key[Home]="''${terminfo[khome]}"
key[End]="''${terminfo[kend]}"
key[Insert]="''${terminfo[kich1]}"
key[Backspace]="''${terminfo[kbs]}"
key[Delete]="''${terminfo[kdch1]}"
key[Up]="''${terminfo[kcuu1]}"
key[Down]="''${terminfo[kcud1]}"
key[Left]="''${terminfo[kcub1]}"
key[Right]="''${terminfo[kcuf1]}"
key[PageUp]="''${terminfo[kpp]}"
key[PageDown]="''${terminfo[knp]}"
key[ShiftTab]="''${terminfo[kcbt]}"

# setup key accordingly
[[ -n "''${key[Home]}"      ]] && bindkey -- "''${key[Home]}"      beginning-of-line
[[ -n "''${key[End]}"       ]] && bindkey -- "''${key[End]}"       end-of-line
[[ -n "''${key[Insert]}"    ]] && bindkey -- "''${key[Insert]}"    overwrite-mode
[[ -n "''${key[Backspace]}" ]] && bindkey -- "''${key[Backspace]}" backward-delete-char
[[ -n "''${key[Delete]}"    ]] && bindkey -- "''${key[Delete]}"    delete-char
[[ -n "''${key[Up]}"        ]] && bindkey -- "''${key[Up]}"        up-line-or-history
[[ -n "''${key[Down]}"      ]] && bindkey -- "''${key[Down]}"      down-line-or-history
[[ -n "''${key[Left]}"      ]] && bindkey -- "''${key[Left]}"      backward-char
[[ -n "''${key[Right]}"     ]] && bindkey -- "''${key[Right]}"     forward-char
[[ -n "''${key[PageUp]}"    ]] && bindkey -- "''${key[PageUp]}"    beginning-of-buffer-or-history
[[ -n "''${key[PageDown]}"  ]] && bindkey -- "''${key[PageDown]}"  end-of-buffer-or-history
[[ -n "''${key[ShiftTab]}"  ]] && bindkey -- "''${key[ShiftTab]}"  reverse-menu-complete


## Finally, make sure the terminal is in application mode, when zle is
## active. Only then are the values from ''$terminfo valid.
if (( ''${+terminfo[smkx]} && ''${+terminfo[rmkx]} )); then
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

[[ -n "''${key[Up]}"   ]] && bindkey -- "''${key[Up]}"   up-line-or-beginning-search
[[ -n "''${key[Down]}" ]] && bindkey -- "''${key[Down]}" down-line-or-beginning-search

zstyle ':completion:*' list-colors ''''''
zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

zstyle ':completion:*' menu select # select completions with arrow keys
zstyle ':completion:*' group-name '''''' # group results by category
#zstyle ':completion:::::' completer _expand _complete _ignored _approximate #enable approximate matches for completion

    '';

    shellAliases = {
      ls = "${pkgs.exa}/bin/exa --colour=auto";
    };

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      ARCHFLAGS="-arch x86_64";
      FZF_DEFAULT_OPTS = ''--prompt \" λ \"'';
      LANG="en_US.UTF-8";
    };
  };
}

