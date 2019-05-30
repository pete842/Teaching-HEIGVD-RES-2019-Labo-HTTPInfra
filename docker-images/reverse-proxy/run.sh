#! /bin/bash
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

docker run --rm -d --name res-php res/php
docker run -d --name res-express --rm res/express

path=$(realpath "${0%/*}")

echo $path

if [[ "$(docker images -q res/reverse-proxy 2> /dev/null)" == "" ]]
then
    echo "Image not found. Building it!"
    docker build --tag res/reverse-proxy $path
fi

if [[ "$(docker ps -f name="res-reverse-proxy" -q 2>/dev/null)" != "" ]]
then
    echo "Running container found. Stopping it!"
    docker stop res-reverse-proxy &>/dev/null
fi

echo "Running image \"res/reverse-proxy\"."
docker run --rm -p 8080:80 --name res-reverse-proxy -d res/reverse-proxy
