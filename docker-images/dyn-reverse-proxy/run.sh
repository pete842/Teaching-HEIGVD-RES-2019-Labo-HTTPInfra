#! /bin/bash
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

docker run --rm -d --name res-php res/php
docker run -d --name res-express --rm res/express

path=$(realpath "${0%/*}")

echo $path

if [[ "$(docker images -q res/dyn-reverse-proxy 2> /dev/null)" == "" ]]
then
    echo "Image not found. Building it!"
    docker build --tag res/dyn-reverse-proxy $path
fi

if [[ "$(docker ps -f name="res-dyn-reverse-proxy" -q 2>/dev/null)" != "" ]]
then
    echo "Running container found. Stopping it!"
    docker stop res-dyn-reverse-proxy &>/dev/null
fi

SERVER_STATIC=$(docker inspect res-php | grep IPAddress\" | head -n 1 | cut -d':' -f2 | cut -d'"' -f2)
SERVER_DYNAMIC=$(docker inspect res-express | grep IPAddress\" | head -n 1 | cut -d':' -f2 | cut -d'"' -f2)

echo "Running image \"res/dyn-reverse-proxy\"."
docker run --rm -p 8080:80 -e STATIC_APP="${SERVER_STATIC}:80" -e DYNAMIC_APP="${SERVER_DYNAMIC}:3000" --name res-dyn-reverse-proxy -d res/dyn-reverse-proxy
