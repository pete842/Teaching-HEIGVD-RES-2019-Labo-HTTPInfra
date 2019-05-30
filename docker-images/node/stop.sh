#! /bin/bash

if [[ "$(docker ps -f name="res-express" -q 2>/dev/null)" != "" ]]
then
    echo "Stopping \"res-express\" container."
    docker stop res-express &>/dev/null
else
    echo "No container named \"res-express\" found! Do nothing."
fi
