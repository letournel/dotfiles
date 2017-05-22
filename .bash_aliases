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
alias search-grep='grep --recursive --extended-regexp --exclude-dir=.svn --exclude-dir=.git --line-number --text'
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
alias docker-pull-registry-all='docker images --format {{.Repository}}:{{.Tag}} | grep docker-registry | xargs -n 1 docker pull'
alias docker-push-registry-all='docker images --format {{.Repository}}:{{.Tag}} | grep docker-registry | xargs -n 1 docker push'
