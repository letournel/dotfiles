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

aws-cloudformation-logs-cli() {
    if [ "$#" -lt 2 ]; then
        aws-cloudformation-logs-groups $@
    elif [ "$#" -eq 2 ]; then
        aws-cloudformation-logs-groups $@ | xargs -I '{}'\
        echo "awslogs get {} -GS -s 10m"
    fi
}

aws-cloudformation-logs-cloudwatch() {
    if [ "$#" -lt 2 ]; then
        aws-cloudformation-logs-groups $@
    elif [ "$#" -eq 2 ]; then
        aws-cloudformation-logs-groups $@ | xargs -I '{}'\
        echo "https://console.aws.amazon.com/cloudwatch/home#logEventViewer:group={}"
    fi
}

aws-cloudformation-logs-groups() {
    if [ "$#" -eq 0 ]; then
        echo "Choose your aws profile and add it as parameter:"
        grep "^\[profile" ~/.aws/config | sed "s/\[profile\s*\(.*\)\]/\1/" | sort | xargs
    elif [ "$#" -eq 1 ]; then
        echo "Choose your stack arn and add it as parameter:"
        aws cloudformation list-stacks --profile "$1" --stack-status-filter CREATE_COMPLETE ROLLBACK_COMPLETE UPDATE_COMPLETE UPDATE_ROLLBACK_COMPLETE | grep -o "arn:\S*" | sort | uniq
    elif [ "$#" -eq 2 ]; then
        (
          aws cloudformation describe-stack-resources --profile "$1" --stack-name "$2" | grep "AWS::Logs::LogGroup" | cut -f3 &&
          aws cloudformation describe-stacks --profile "$1" --stack-name "$2" | grep "^OUTPUTS" | grep "LogGroupAccess" | grep -o "logEventViewer:group=\S*" | sed "s/logEventViewer:group=//"
        ) | sort | uniq
    fi
}

aws-cloudformation-ssh-cmd() {
    if [ "$#" -eq 0 ]; then
        echo "Choose your aws profile and add it as parameter:"
        grep "^\[profile" ~/.aws/config | sed "s/\[profile\s*\(.*\)\]/\1/" | sort | xargs
    elif [ "$#" -eq 1 ]; then
        echo "Choose your stack arn and add it as parameter:"
        aws cloudformation list-stacks --profile "$1" --stack-status-filter CREATE_COMPLETE ROLLBACK_COMPLETE UPDATE_COMPLETE UPDATE_ROLLBACK_COMPLETE | grep -o "arn:\S*" | sort | uniq
    elif [ "$#" -eq 2 ]; then
        aws cloudformation describe-stack-resources --profile "$1" --stack-name "$2" | grep "AWS::EC2::Instance" | cut -f3 | xargs -r\
        aws ec2 describe-instances --profile "$1" --instance-ids | grep "^PRIVATEIPADDRESSES\b" | cut -f3 | xargs -I '{}'\
        echo "ssh -t bastion-$1 ssh {}"
    fi
}

aws-ecs-ssh-cmd() {
    if [ "$#" -eq 0 ]; then
        echo "Choose your aws profile and add it as parameter:"
        grep "^\[profile" ~/.aws/config | sed "s/\[profile\s*\(.*\)\]/\1/" | sort | xargs
    elif [ "$#" -eq 1 ]; then
        echo "Choose your cluster arn and add it as parameter:"
        aws ecs list-clusters --profile "$1" | grep -o "arn:\S*" | sort | uniq
    elif [ "$#" -eq 2 ]; then
        echo "Choose your service arn and add it as parameter:"
        aws ecs list-services --profile "$1" --cluster "$2" | grep -o "arn:\S*" | sort | uniq
    elif [ "$#" -eq 3 ]; then
        aws ecs list-tasks --profile "$1" --cluster "$2" --service-name "$3" | grep "^TASKARNS\b" | grep -o "arn:\S*" | xargs -r\
        aws ecs describe-tasks --profile "$1" --cluster "$2" --tasks | grep "^TASKS\b" | cut -f5 | xargs -r\
        aws ecs describe-container-instances --profile "$1" --cluster "$2" --container-instances | grep "^CONTAINERINSTANCES\b" | cut -f4 | xargs -r\
        aws ec2 describe-instances --profile "$1" --instance-ids | grep "^PRIVATEIPADDRESSES\b" | cut -f3 | xargs -I '{}'\
        echo "ssh -t bastion-$1 ssh {}"
    fi
}

aws-profile-get() {
    echo "$AWS_PROFILE"
}

aws-profile-set() {
    if [ "$#" -gt 0 ]; then
        export AWS_PROFILE="$1"
    else
        unset AWS_PROFILE
    fi
}

aws-region-get() {
    echo "$AWS_REGION"
}

aws-region-set() {
    if [ "$#" -gt 0 ]; then
        export AWS_REGION="$1"
    else
        unset AWS_REGION
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

scp-through() {
    if [ "$#" -ne 3 ]; then
        echo "Incorrect number of arguments: scp-through <bastion> <host> <absolutefilepath>"
    elif [[ ! "${@:(-1):1}" = "/"* ]]; then
        echo "No absolute file path in last argument: scp-through <bastion> <host> <absolutefilepath>"
    else
        bastion="${@:1:1}"
        host="${@:2:1}"
        absolutefilepath="${@:3:1}"
        filename=$(basename $absolutefilepath)
        echo "scp -ro ProxyCommand=\"ssh $bastion nc $host 22\" $host:$absolutefilepath $host-$filename"
    fi
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

git-subdir-branches()
{
    if [[ -z "$1" ]]; then
        echo "Usage: $FUNCNAME <dir>" >&2
        return 1
    fi

    if [[ ! -d "$1" ]]; then
        echo "Invalid dir specified: '${1}'"
        return 1
    fi

    # Subshell so we don't end up in a different dir than where we started.
    (
        cd "$1"
        for sub in *; do
            [[ -d "${sub}/.git" ]] || continue
            echo "$sub [$(cd "$sub"; git branch | grep '^\*' | cut -d' ' -f2)]"
        done
    )
}

git-subdir-allbranches()
{
    if [[ -z "$1" ]]; then
        echo "Usage: $FUNCNAME <dir>" >&2
        return 1
    fi

    if [[ ! -d "$1" ]]; then
        echo "Invalid dir specified: '${1}'"
        return 1
    fi

    # Subshell so we don't end up in a different dir than where we started.
    (
        cd "$1"
        for sub in *; do
            [[ -d "${sub}/.git" ]] || continue
            echo "$sub"
            echo "$(cd "$sub"; git branch)"
        done
    )
}
