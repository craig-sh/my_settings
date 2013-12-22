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


# mint-fortune
/usr/bin/mint-fortune

#PS1="\[\033[1;30m\][\[\033[1;34m\]\u\[\033[1;30m\]@\[\033[0;35m\]\h\[\033[1;30m\]][\t] \[\033[0;37m\]\W \[\033[1;30m\]\$\[\033[0m\]"

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


#PS1="\[$Black\]\u\[$Color_Off\]@\[$BRed\]\h\[$Color_Off\]\[$Red\][\j]\[$Color_Off\]\[$Yellow\][\t]\[$Color_Off\]:\[$Green\]\W\[$Color_Off\]\$ "
#PS1="$Black\u$Color_Off@$BRed\h$Color_Off$Red[\j]$Color_Off$Yellow[\t]$Color_Off:$Green\W$Color_Off\$ "
#############################################################################################






###############################Git stuff, Use when you know what it means###########################
#function __prompt_command()
#{
#    # capture the exit status of the last command
#    EXIT="$?"
#    PS1=""
# 
#    if [ $EXIT -eq 0 ]; then PS1+="\[$Green\][\!]\[$Color_Off\] "; else PS1+="\[$Red\][\!]\[$Color_Off\] "; fi
# 
#    # if logged in via ssh shows the ip of the client
#    if [ -n "$SSH_CLIENT" ]; then PS1+="\[$Yellow\]("${$SSH_CLIENT%% *}")\[$Color_Off\]"; fi
# 
#    # debian chroot stuff (take it or leave it)
#    PS1+="${debian_chroot:+($debian_chroot)}"
# 
#    # basic information (user@host:path)
#    #PS1+="\[$BRed\]\u\[$Color_Off\]@\[$BRed\]\h\[$Color_Off\]:\[$BPurple\]\w\[$Color_Off\] " 
#    PS1+="\[$Black\]\u\[$Color_Off\]@\[$BRed\]\h\[$Color_Off\]\[$Red\][\j]\[$Color_Off\]$Yellow\][\t]\[$Color_Off\]:\[$Green\]\W\[$Color_Off\]"
#    # check if inside git repo
#    local git_status="`git status -unormal 2>&1`"    
#    if ! [[ "$git_status" =~ Not\ a\ git\ repo ]]; then
#        # parse the porcelain output of git status
#        if [[ "$git_status" =~ nothing\ to\ commit ]]; then
#            local Color_On=$Green
#        elif [[ "$git_status" =~ nothing\ added\ to\ commit\ but\ untracked\ files\ present ]]; then
#            local Color_On=$Purple
#        else
#            local Color_On=$Red
#        fi
# 
#        if [[ "$git_status" =~ On\ branch\ ([^[:space:]]+) ]]; then
#            branch=${BASH_REMATCH[1]}
#        else
#            # Detached HEAD. (branch=HEAD is a faster alternative.)
#            branch="(`git describe --all --contains --abbrev=4 HEAD 2> /dev/null || echo HEAD`)"
#        fi
# 
#        # add the result to prompt
#        PS1+="\[$Color_On\][$branch]\[$Color_Off\] "
#    fi
# 
#    # prompt $ or # for root
#    PS1+="\$ "
#}
#PROMPT_COMMAND=__prompt_command

############Git#################################
git config --global user.email "craig.henriques@mail.utoronto.com"
git config --global user.name "craig-sh"
git config --global format.pretty oneline
git config --global color.ui true
##################################

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
