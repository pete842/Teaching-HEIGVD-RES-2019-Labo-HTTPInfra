#! /bin/bash
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

path=$(realpath "${0%/*}")

echo $path

if [[ "$(docker images -q res/express 2> /dev/null)" == "" ]]
then
    echo "Image not found. Building it!"
    docker build --tag res/express $path
fi

if [[ "$(docker ps -f name="res/express" -q 2>/dev/null)" != "" ]]
then
    echo "Running container found. Stopping it!"
    docker stop res-express &>/dev/null
fi

echo "Running image \"res/express\"."
docker run -d -p 3000:3000 --name res-express --rm res/express
