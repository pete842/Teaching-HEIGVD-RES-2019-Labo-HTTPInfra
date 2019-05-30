#! /bin/bash
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

path=$(realpath "${0%/*}")

echo $path

if [[ "$(docker images -q expressjs 2> /dev/null)" == "" ]]
then
    echo "Image not found. Building it!"
    docker build --tag expressjs $path
fi

if [[ "$(docker ps -f name=expressjs -q 2>/dev/null)" != "" ]]
then
    echo "Running container found. Stopping it!"
    docker stop expressjs &>/dev/null
fi

echo "Running image \"expressjs\"."
docker run -it -d -p 3000:3000 --name expressjs --rm expressjs
