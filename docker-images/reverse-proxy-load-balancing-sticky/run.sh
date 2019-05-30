#! /bin/bash
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

docker run --rm -d --name res-php1 res/php
docker run --rm -d --name res-php2 res/php
docker run -d --name res-express1 --rm res/express
docker run -d --name res-express2 --rm res/express

path=$(realpath "${0%/*}")

echo $path

if [[ "$(docker images -q res/reverse-proxy-load-balancer-sticky 2> /dev/null)" == "" ]]
then
    echo "Image not found. Building it!"
    docker build --tag res/reverse-proxy-load-balancer-sticky $path
fi

if [[ "$(docker ps -f name="res-reverse-proxy-load-balancer-sticky" -q 2>/dev/null)" != "" ]]
then
    echo "Running container found. Stopping it!"
    docker stop res-reverse-proxy-load-balancer-sticky &>/dev/null
    fi

echo "Running image \"res/reverse-proxy-load-balancer-sticky\"."
docker run --rm -p 8080:80 --name res-reverse-proxy-load-balancer-sticky -d res/reverse-proxy-load-balancer-sticky
