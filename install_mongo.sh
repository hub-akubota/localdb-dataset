#!/bin/bash

echo -e "[LDB] Select your OS from the list. (Type a-d from the list)"
echo -e ""
echo -e "OS supported by tutorial"
echo -e "  a) RHEL 6.2 Linux x64"
echo -e "  b) RHEL 7.0 Linux x64"
echo -e "  c) macOS x64"
echo -e "OS not supported by tutorial"
echo -e "  d) Others"
echo -e ""
unset answer
while [ -z "${answer}" ];
do
    read -p "[LDB] > " answer
done
echo -e ""
if [[ ${answer} = "a" ]]; then
    echo -e "[LDB] Start to download MongoDB Package: mongodb-4.2.6"
    wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel62-4.2.6.tgz
    tar xzvf mongodb-linux-x86_64-rhel62-4.2.6.tgz > /dev/null 2>&1
    mv mongodb-linux-x86_64-rhel70-4.2.6 mongodb-4.2.6 > /dev/null 2>&1
    rm mongodb-linux-x86_64-rhel62-4.2.6.tgz > /dev/null 2>&1
    echo -e "[LDB] Done."
    echo -e "[LDB] Check README to get how to use commands in ./mongodb-4.2.6/bin"
    echo -e ""
    exit 0
elif [[ ${answer} = "b" ]]; then
    echo -e "[LDB] Start to download MongoDB Package: mongodb-4.2.6"
    wget https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-4.2.6.tgz
    tar xzvf mongodb-linux-x86_64-rhel70-4.2.6.tgz > /dev/null 2>&1
    mv mongodb-linux-x86_64-rhel70-4.2.6 mongodb-4.2.6 > /dev/null 2>&1
    rm mongodb-linux-x86_64-rhel70-4.2.6.tgz > /dev/null 2>&1
    echo -e "[LDB] Done."
    echo -e "[LDB] Check README to get how to use commands in ./mongodb-4.2.6/bin"
    echo -e ""
    exit 0
elif [[ ${answer} = "c" ]]; then
    echo -e "[LDB] Start to download MongoDB Package: mongodb-4.2.6"
    wget https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-4.2.6.tgz
    tar xzvf mongodb-macos-x86_64-4.2.6.tgz > /dev/null 2>&1
    mv mongodb-macos-x86_64-4.2.6 mongodb-4.2.6 > /dev/null 2>&1
    rm mongodb-macos-x86_64-4.2.6.tgz > /dev/null 2>&1
    echo -e "[LDB] Done."
    echo -e "[LDB] Check README to get how to use commands in ./mongodb-4.2.6/bin"
    echo -e ""
    exit 0
elif [[ ${answer} = "d" ]]; then
    echo "[LDB WARNING] Trial tutorial has not supportet your OS yet."
    echo "[LDB WARNING] Check the download url of tgz file for your OS from https://www.mongodb.com/download-center/community "
    echo "[LDB WARNING] Try to download by 'wget https://###.tgz' in console on your OS and follow the tutorial."
    echo "[LDB WARNING] Probably the tutorial doesn't work, sorry."
    echo -e ""
    exit 1
else
    echo "[LDB ERROR] Select the alphabet a-d from the list and just type one alphabet (e.g. [LDB] > a), exit..."
    echo -e ""
    exit 1
fi
