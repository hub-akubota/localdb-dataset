#!/bin/bash

#wget https://cernbox.cern.ch/index.php/s/QLB0LXI5hRQA7y8/download -O localdb-dump.tar.gz
#tar xzvf localdb-dump.tar.gz

echo -e "[LDB] Download minimum dataset for Local DB: localdb"

wget https://cernbox.cern.ch/index.php/s/tQFDcLwerbcxQEn/download -O localdb.tar.gz
tar xzvf localdb.tar.gz > /dev/null 2>&1
rm localdb.tar.gz > /dev/null 2>&1

echo -e "[LDB] Done."
echo -e ""
