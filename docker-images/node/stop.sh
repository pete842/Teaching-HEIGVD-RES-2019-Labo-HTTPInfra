#! /bin/bash

if [[ "$(docker ps -f name=expressjs -q 2>/dev/null)" != "" ]]
then
    echo "Stopping \"expressjs\" container."
    docker stop expressjs &>/dev/null
else
    echo "No container named \"expressjs\" found! Do nothing."
fi
