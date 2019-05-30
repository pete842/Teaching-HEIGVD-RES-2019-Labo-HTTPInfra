#!/bin/bash

if [[ "$(docker ps -f name="res-reverse-proxy" -q 2>/dev/null)" != "" ]]
then
    echo "Running res-reverse-proxy container found. Stopping it!"
    docker stop res-reverse-proxy &>/dev/null
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
