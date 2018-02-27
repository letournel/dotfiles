composer() {
    if [ -f composer.phar ]; then
        php composer.phar "$@"
    else
        echo -e "\e[1;33m\e[41m404 : composer.phar not found\e[0m"
    fi
}

composer-install() {
    if [ -f composer.phar ] ; then
        php composer.phar install --prefer-dist --ignore-platform-reqs
    else
        echo -e "\e[1;33m\e[41m404 : composer.phar not found\e[0m"
    fi
}

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

docker-psa() {
    docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Status}}" "$@"
}

docker-shell() {
    local CONTAINER_NAME="$1"
    local COMMAND="bash"

    if [ "$#" -gt 1 ]; then
        COMMAND=$(echo "$@" | cut -d' ' -f2-)
    fi

    docker exec -ti "${CONTAINER_NAME}" ${COMMAND}
}

docker-pull-registry-tag() {
    docker images --format {{.Repository}}:{{.Tag}} | grep $1 | sed 's/$1/$2/' | xargs -n 1 docker pull
}

aws-get-profile() {
    if [ "$#" -gt 0 ]; then
        export AWS_PROFILE="$1"
    else
        unset AWS_PROFILE
    fi
}

aws-set-profile() {
    if [ "$#" -gt 0 ]; then
        export AWS_PROFILE="$1"
    else
        unset AWS_PROFILE
    fi
}

aws-logcmd-cloudformation() {
    if [ "$#" -eq 0 ]; then
        echo "Choose your aws profile and add it as parameter:"
        grep "^\[profile" ~/.aws/config | sed "s/\[profile\s*\(.*\)\]/\1/" | sort | xargs
    elif [ "$#" -eq 1 ]; then
        echo "Choose your stack arn and add it as parameter:"
        aws-set-profile "$1"
        aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE ROLLBACK_COMPLETE UPDATE_COMPLETE UPDATE_ROLLBACK_COMPLETE | grep -o "arn:\S*" | sort | uniq
    elif [ "$#" -eq 2 ]; then
        aws-set-profile "$1"
        aws cloudformation describe-stack-resources --stack-name "$2" | grep "AWS::Logs::LogGroup" | cut -f3 | xargs -I '{}'\
        echo "awslogs get -GS -s 10m {}"
    fi
}

aws-sshcmd-cloudformation() {
    if [ "$#" -eq 0 ]; then
        echo "Choose your aws profile and add it as parameter:"
        grep "^\[profile" ~/.aws/config | sed "s/\[profile\s*\(.*\)\]/\1/" | sort | xargs
    elif [ "$#" -eq 1 ]; then
        echo "Choose your stack arn and add it as parameter:"
        aws-set-profile "$1"
        aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE ROLLBACK_COMPLETE UPDATE_COMPLETE UPDATE_ROLLBACK_COMPLETE | grep -o "arn:\S*" | sort | uniq
    elif [ "$#" -eq 2 ]; then
        aws-set-profile "$1"
        aws cloudformation describe-stack-resources --stack-name "$2" | grep "AWS::EC2::Instance" | cut -f3 | xargs -r\
        aws ec2 describe-instances --instance-ids | grep "^PRIVATEIPADDRESSES\b" | cut -f3 | xargs -I '{}'\
        echo "ssh -t bastion-$1 ssh {}"
    fi
}

aws-sshcmd-ecs() {
    if [ "$#" -eq 0 ]; then
        echo "Choose your aws profile and add it as parameter:"
        grep "^\[profile" ~/.aws/config | sed "s/\[profile\s*\(.*\)\]/\1/" | sort | xargs
    elif [ "$#" -eq 1 ]; then
        echo "Choose your cluster arn and add it as parameter:"
        aws-set-profile "$1"
        aws ecs list-clusters | grep -o "arn:\S*" | sort | uniq
    elif [ "$#" -eq 2 ]; then
        echo "Choose your service arn and add it as parameter:"
        aws-set-profile "$1"
        aws ecs list-services --cluster "$2" | grep -o "arn:\S*" | sort | uniq
    elif [ "$#" -eq 3 ]; then
        aws-set-profile "$1"
        aws ecs describe-services --cluster "$2" --services "$3" | grep "^LOADBALANCERS\b" | grep -o "arn:\S*" | head -n1 | xargs -I '{}'\
        aws elbv2 describe-target-health --target-group-arn "{}" | grep "^TARGET\b" | cut -f2 | xargs -r\
        aws ec2 describe-instances --instance-ids | grep "^PRIVATEIPADDRESSES\b" | cut -f3 | xargs -I '{}'\
        echo "ssh -t bastion-$1 ssh {}"
    fi
}

tmux-spliter() {
    if [ "$#" -eq 0 ]; then
        echo "No tmux layout in arguments"
    elif [ "$#" -eq 1 ]; then
        while read cmd
        do
            tmux split-window "$cmd"
            tmux select-layout $1
        done
    elif [ "$#" -gt 1 ]; then
        for cmd in ${@:2}
        do
            tmux split-window "$cmd"
            tmux select-layout $1
        done
    fi
}

tmux-tiled() {
    tmux-spliter "tiled" $@
}

tmux-vertical() {
    tmux-spliter "even-vertical" $@
}

ssh-hops-tunneling() {
    if [ "$#" -lt 2 ]; then
        echo "Not enough argument: ssh-hops-tunneling [hops] <lasthop> <target:port>"
    elif [[ ! "${@:(-1):1}" = *":"* ]]; then
        echo "No port in last argument: ssh-hops-tunneling [hops] <lasthop> <target:port>"
    else
        cmd=""
        port=$(shuf -i 2000-65000 -n 1)
        for hop in ${@:1:(-2)}
        do
            cmd+="ssh -L${port}:localhost:${port} ${hop} -t "
        done
        cmd+="ssh -L${port}:${@:(-1):1} -t ${@:(-2):1}"
        echo $cmd
    fi
}
