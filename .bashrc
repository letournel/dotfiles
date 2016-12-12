# To the extent possible under law, the author(s) have dedicated all 
# copyright and related and neighboring rights to this software to the 
# public domain worldwide. This software is distributed without any warranty. 
# You should have received a copy of the CC0 Public Domain Dedication along 
# with this software. 
# If not, see <http://creativecommons.org/publicdomain/zero/1.0/>. 

# base-files version 4.2-3

# ~/.bashrc: executed by bash(1) for interactive shells.

# The latest version as installed by the Cygwin Setup program can
# always be found at /etc/defaults/etc/skel/.bashrc

# Modifying /etc/skel/.bashrc directly will prevent
# setup from updating it.

# The copy in your home directory (~/.bashrc) is yours, please
# feel free to customise it to create a shell
# environment to your liking.  If you feel a change
# would be benifitial to all, please feel free to send
# a patch to the cygwin mailing list.

# User dependent .bashrc file

# If not running interactively, don't do anything
[[ "$-" != *i* ]] && return

# -------------------------------------------------------------
# Shell Options
# -------------------------------------------------------------

# Don't wait for job termination notification
# set -o notify

# Don't use ^D to exit
# set -o ignoreeof

# Use case-insensitive filename globbing
# shopt -s nocaseglob

# Make bash append rather than overwrite the history on disk
shopt -s histappend

# When changing directory small typos can be ignored by bash
# for example, cd /vr/lgo/apaache would find /var/log/apache
# shopt -s cdspell

# -------------------------------------------------------------
# Completion options
# -------------------------------------------------------------

# Uncomment to turn on programmable completion enhancements.
# Any completions you add in ~/.bash_completion are sourced last.
# [[ -f /etc/bash_completion ]] && . /etc/bash_completion

# use git auto complete
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

_ssh()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$(grep '^Host' ~/.ssh/config | grep -v '[?*]' | cut -d ' ' -f 2-)

    COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
    return 0
}
complete -F _ssh ssh

# -------------------------------------------------------------
# History Options
# -------------------------------------------------------------

# Don't put duplicate lines in the history.
# export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups

# Ignore some controlling instructions
# HISTIGNORE is a colon-delimited list of patterns which should be excluded.
# The '&' is a special pattern which suppresses duplicate entries.
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit'
# export HISTIGNORE=$'[ \t]*:&:[fb]g:exit:ls' # Ignore the ls command as well

# Whenever displaying the prompt, write the previous line to disk
# export PROMPT_COMMAND="history -a"

# -------------------------------------------------------------
# Aliases
# -------------------------------------------------------------

# Some people use a different file for aliases
# if [ -f "${HOME}/.bash_aliases" ]; then
#   source "${HOME}/.bash_aliases"
# fi

# Some example alias instructions
# If these are enabled they will be used instead of any instructions
# they may mask.  For example, alias rm='rm -i' will mask the rm
# application.  To override the alias instruction use a \ before, ie
# \rm will call the real rm not the alias.

# Interactive operation...
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

# Default to human readable figures
alias df='df -h'
alias du='du -h'

# Allow using alias with watch command
alias watch='watch '

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias search-grep='grep --recursive --line-number --text'
alias d='ls -la --color=auto'
alias ll='ls -la --color=auto'
alias ..='cd ..'
alias up='cd ..'
alias up1='cd ..'
alias up2='cd ../..'
alias up3='cd ../../..'
alias up4='cd ../../../..'
alias dump-cygwin-package='cygcheck -c -d | sed -e "1,2d" -e "s/ .*$//"'
alias phpunit='php vendor/phpunit/phpunit/phpunit'

alias docker-check-router='docker exec -ti system_router_1 cat /etc/nginx/conf.d/staging.conf | sed '\''/^\s*$/d'\'''
alias docker-restart-router='docker exec -ti system_router_1 /etc/init.d/nginx restart'
alias docker-rm-containers-all='docker rm -fv $(docker ps -aq)'
alias docker-rm-containers-exited='docker rm -fv $(docker ps -aq --filter="status=exited")'
alias docker-rm-untagged-images='docker rmi $(docker images -q --filter="dangling=true")'
alias docker-psa='docker ps -a --format="table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Command}}\t{{.Status}}"'

# -------------------------------------------------------------
# Umask
# -------------------------------------------------------------

# /etc/profile sets 022, removing write perms to group + others.
# Set a more restrictive umask: i.e. no exec perms for others:
# umask 027
# Paranoid: neither group nor others have any perms:
# umask 077

# -------------------------------------------------------------
# Functions
# -------------------------------------------------------------

# Some people use a different file for functions
# if [ -f "${HOME}/.bash_functions" ]; then
#   source "${HOME}/.bash_functions"
# fi

# composer, keeping parameters
composer() {
    if [ -f composer.phar ]; then
        php composer.phar "$@"
    else
        echo -e "\e[1;33m\e[41m404 : composer.phar not found\e[0m"
    fi
}

# download composer
composer-dl() {
    if [ -f composer.phar ] ; then
        echo -e "\e[1;33m\e[41mcomposer.phar already exists \e[0m"
    else
        curl -sS https://getcomposer.org/installer | php
    fi
}

diff-xxd() {
   diff -y <(xxd "$1") <(xxd "$2") --suppress-common-lines
}

search-find() {
    find . -name "*$1*" | grep -n "$1"
}

search-grep-file-git-history() {
    git rev-list --all $2 | (
        while read revision; do
            git grep -F $1 $revision $2
        done
    )
}

xdebug-enable() {
    ip="172.17.3.62"
    export XDEBUG_CONFIG="idekey=Eclipse remote_host=$ip"
}

xdebug-disable() {
    unset XDEBUG_CONFIG
}

# -------------------------------------------------------------
# Environment
# -------------------------------------------------------------

unset GREP_OPTIONS
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# -------------------------------------------------------------
# Custom prompt
# -------------------------------------------------------------

parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
GREEN="\[\033[0;32m\]"
NO_COLOR="\[\033[0m\]"

PS1="$GREEN\u@\h$NO_COLOR:\w$YELLOW\$(parse_git_branch)$NO_COLOR\$ "

# -------------------------------------------------------------
# Local only bachrc conf
# -------------------------------------------------------------

if [ -f "${HOME}/.bashrc_local" ]; then
    source "${HOME}/.bashrc_local"
fi

# -------------------------------------------------------------
# Take me home please
# -------------------------------------------------------------

cd
