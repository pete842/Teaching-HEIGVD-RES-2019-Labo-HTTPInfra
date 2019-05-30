#! /bin/bash

if [[ "$(docker ps -f name=res-php -q 2>/dev/null)" != "" ]]
then
    echo "Stopping \"res-php\" container."
    docker stop res-php &>/dev/null
else
    echo "No container named \"res-php\" found! Do nothing."
fi
