#!/bin/bash

./install_mongo.sh

if [[ $? = 1 ]]; then
    exit
fi

./download_minimumdb.sh

exit
