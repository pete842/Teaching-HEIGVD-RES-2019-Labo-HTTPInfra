#!/bin/bash

if [[ "$(docker ps -f name="res-reverse-proxy-load-balancer" -q 2>/dev/null)" != "" ]]
then
    echo "Running res-reverse-proxy-load-balancer container found. Stopping it!"
    docker stop res-reverse-proxy-load-balancer &>/dev/null
fi

if [[ "$(docker ps -f name="res-php1" -q 2>/dev/null)" != "" ]]
then
    echo "Running res-php1 container found. Stopping it!"
    docker stop res-php1 &>/dev/null
fi

if [[ "$(docker ps -f name="res-php2" -q 2>/dev/null)" != "" ]]
then
    echo "Running res-php2 container found. Stopping it!"
    docker stop res-php2 &>/dev/null
fi

if [[ "$(docker ps -f name="res-express1" -q 2>/dev/null)" != "" ]]
then
    echo "Running res-express1 container found. Stopping it!"
    docker stop res-express1 &>/dev/null
fi

if [[ "$(docker ps -f name="res-express2" -q 2>/dev/null)" != "" ]]
then
    echo "Running res-express2 container found. Stopping it!"
    docker stop res-express2 &>/dev/null
fi
