#!/bin/bash

if [[ "$(docker ps -f name="res-dyn-reverse-proxy" -q 2>/dev/null)" != "" ]]
then
    echo "Running res-dyn-reverse-proxy container found. Stopping it!"
    docker stop res-dyn-reverse-proxy &>/dev/null
fi

if [[ "$(docker ps -f name="res-php" -q 2>/dev/null)" != "" ]]
then
    echo "Running res-php container found. Stopping it!"
    docker stop res-php &>/dev/null
fi

if [[ "$(docker ps -f name="res-express" -q 2>/dev/null)" != "" ]]
then
    echo "Running res-express container found. Stopping it!"
    docker stop res-express &>/dev/null
fi
