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

composer-dl()
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
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.CreatedAt}}\t{{.Status}}" "$@"
}

docker-shell() {
    local CONTAINER_NAME="$1"
    local COMMAND="bash"

    if [ "$#" -gt 1 ]; then
        COMMAND=$(echo "$@" | cut -d' ' -f2-)
    fi

    docker exec -ti "${CONTAINER_NAME}" ${COMMAND}
}
