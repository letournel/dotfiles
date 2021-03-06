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

alias docker-log='docker logs -f '
alias docker-ps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias docker-rm-all='docker ps -a -q | xargs -r -n 1 docker rm -fv'
alias docker-rm-exited='docker ps -a -q -f status=exited | xargs -r -n 1 docker rm -fv'
alias docker-rmi-all='docker images -q | xargs -r -n 1 docker rmi -f'
alias docker-rmi-untagged='docker images -q -f dangling=true | xargs -r -n 1 docker rmi'
alias docker-pull-registry-all='docker images --format {{.Repository}}:{{.Tag}} | grep docker-registry | xargs -n 1 docker pull'
alias docker-push-registry-all='docker images --format {{.Repository}}:{{.Tag}} | grep docker-registry | xargs -n 1 docker push'

alias k='kubectl '
alias kg='kubectl get '
alias kcxrawlist='kubectl config get-contexts '
alias kcxraw='kubectl config use-context '
alias knsraw='kubectl config set "contexts.$(kubectl config current-context).namespace"'
alias kghealth='kubectl get componentstatuses'
alias kgd='kubectl get deploy '
alias ked='kubectl describe deploy '
alias kgp='kubectl get pods '
alias kep='kubectl describe pod '
alias kgno='kubectl get nodes -o wide '
alias kgnotaint='kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints '
alias kgns='kubectl get namespaces '
alias kgs='kubectl get svc '
alias kes='kubectl describe svc '
alias kge='kubectl get events --sort-by=".metadata.creationTimestamp"'
alias kgjson='kubectl get -o=json '
alias kgyaml='kubectl get -o=yaml '
alias kgwide='kubectl get -o=wide '
alias klog='kubectl logs '
alias klogf='kubectl logs -f '
alias kcx='kubectx '
alias kns='kubens '
alias krun-busybox='kubectl run --rm -it busybox-$(cat /proc/sys/kernel/random/uuid | cut -c1-8) --image busybox --restart=Never -- /bin/sh'
alias krun-etcdctl='kubectl run --rm -it etcdctl-$(cat /proc/sys/kernel/random/uuid | cut -c1-8) --image quay.io/coreos/etcd --restart=Never -- /bin/sh'
