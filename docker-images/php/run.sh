#! /bin/bash
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

path=$(realpath "${0%/*}")

echo $path

docker build --tag res/php $path

if [[ "$(docker images -q res/php 2> /dev/null)" == "" ]]
then
    echo "Image not found. Building it!"
    docker build --tag res/php $path
fi

if [[ "$(docker ps -f name=res-php -q 2>/dev/null)" != "" ]]
then
    echo "Running container found. Stopping it!"
    docker stop res-php &>/dev/null
fi

echo "Running image \"res/php\"."
docker run -d -p 8080:80 --name res-php --rm res/php
