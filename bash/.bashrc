# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Source global definitions
if [ -f /etc/bash.bashrc ]; then
        . /etc/bash.bashrc
fi
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

set -o vi

alias ls='ls -aF --color=always'
alias ll='ls -l'
###################################PROMPT STUFF#####################
####aliases for colors
##-ANSI-COLOR-CODES-##
Color_Off="\[\033[0m\]"
###-Regular-###
Red="\[\033[0;31m\]"
Green="\[\033[0;32m\]"
Purple="\[\033[0;35m\]"
Yellow="\[\033[0;36m\]"
Black="\[\033[0;25m\]"
####-Bold-####
BRed="\[\033[1;31m\]"
BPurple="\[\033[1;35m\]"
###################
###########Prmopt Setup
function __prompt_command()
{
# capture the exit status of the last command
EXIT="$?"
PS1=""

if [ $EXIT -eq 0 ]; then PS1+="$Green[\!]$Color_Off"; else PS1+="$Red[\!]$Color_Off"; fi

PS1+="$Black\u$Color_Off@$Red\h$Color_Off$Red[\j]$Color_Off$Yellow[\t]$Color_Off:$Green\W$Color_Off\$ "
}
PROMPT_COMMAND=__prompt_command

############Git#################################
git config --global user.email "craig.henriques@mail.utoronto.com"
git config --global user.name "craig-sh"
git config --global format.pretty oneline
git config --global color.ui true
##################################

#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
export PATH=$PATH:$HOME/wm/panels 

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
