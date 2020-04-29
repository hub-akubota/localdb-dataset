#!/bin/bash

./install_mongo.sh

if [[ $? = 1 ]]; then
    exit
fi

./download_minimumdb.sh

./start_mongo.sh

exit
