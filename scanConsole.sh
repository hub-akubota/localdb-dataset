#!/bin/bash

function usage {
    cat <<EOF

    ./scanConsole -c <conn> -s <scan> -W [-d <db>] [-i <site>] [-u <user>]

    - h               Show this usage
    - c <conn>        Path to connectivity config file
    - s <scan>        Scan Type ( d: digital scan, a: analog scan, th: threshold scan, to: tot scan, default: digital scan )
    - W               Upload data into Local DB
    - d <db>          Path to database config file (default: ${HOME}/.yarr/localdb/${HOSTNAME}_database.json)
    - i <site>        Path to user config file (default: ${HOME}/.yarr/localdb/${HOSTNAME}_site.json)
    - u <user>        Path to site config file (default: ${HOME}/.yarr/localdb/user.json)

EOF
}

if [ `echo ${0} | grep bash` ]; then
    echo -e "[LDB] DO NOT 'source'"
    usage
    return
fi

shell_dir=$(cd $(dirname ${BASH_SOURCE}); pwd)
reset=false
scan=d
db=false
dbCfg=${HOME}/.yarr/localdb/${HOSTNAME}_database.json
siteCfg=${HOME}/.yarr/localdb/${HOSTNAME}_site.json
userCfg=${HOME}/.yarr/localdb/user.json
while getopts hc:s:Wd:i:u: OPT
do
    case ${OPT} in
        h ) usage
            exit ;;
        c ) conn=${OPTARG} ;;
        s ) scan=${OPTARG} ;;
        W ) db=true ;;
        d ) dbCfg=${OPTARG} ;;
        i ) siteCfg=${OPTARG} ;;
        u ) userCfg=${OPTARG} ;;
        * ) usage
            exit ;;
    esac
done

if [ -z ${conn} ]; then
    printf '\033[31m%s\033[m\n' "[LDB ERROR] No config files given, please specify config file name under -c option"
    exit 1
fi

if [ ! -e ${path} ]; then
    printf '\033[31m%s\033[m\n' "[LDB ERROR] No config files found in ${path}"
    exit 1
fi

if [ ${scan} = d ]; then
    scan="std_digitalscan"
elif [ ${scan} = a ]; then
    scan="std_analogscan"
elif [ ${scan} = th ]; then
    scan="std_thresholdscan"
elif [ ${scan} = to ]; then
    scan="std_totscan"
else
    printf '\033[31m%s\033[m\n' "[LDB ERROR] Something wrong in specified scan."
    printf '\033[31m%s\033[m\n' "            Specify d (digital scan), a (analog scan), th (threshold scan) or to (tot scan) under -s option."
    exit 1
fi

if "${db}" && [ ! -e ./localdb/bin/localdbtool-upload ]; then
    printf '\033[31m%s\033[m\n' "[LDB ERROR] Not found ./localdb/bin/localdbtool-upload."
    printf '\033[31m%s\033[m\n' "            Move this command scanConsole.sh under YARR directory. ($ mv scanConsole.sh path/to/YARR)"
    exit 1
fi

if [ ! -d ./data ]; then
    mkdir data
fi
if [ -d ./data/last_scan ]; then
    rm -rf ./data/last_scan
    mkdir ./data/last_scan
fi
if [ -d ./data/last_scan_cache ]; then
    rm -rf ./data/last_scan_cache
fi

chipType=`less ${conn} | grep 'chipType'` > /dev/null 2>&1
rd53a=false
fei4b=false
if echo ${chipType} | grep 'RD53A' > /dev/null 2>&1; then
    rd53a=true
fi
if echo ${chipType} | grep 'FEI4B' > /dev/null 2>&1; then
    fei4b=true
fi

### fei4b
if "${fei4b}"; then
    wget https://cernbox.cern.ch/index.php/s/6vxIgww7RRycn2i/download -O data/result.tar.gz > /dev/null 2>&1
    cd data > /dev/null 2>&1
    tar xzvf result.tar.gz > dev/null 2>&1
    mv fei4b-result last_scan_cache > /dev/null 2>&1
    rm -rf fei4b-result > /dev/null 2>&1
    rm result.tar.gz > /dev/null 2>&1
    cd - > /dev/null 2>&1
fi

### rd53a
if "${rd53a}"; then
    wget https://cernbox.cern.ch/index.php/s/LMoGhPAwgSvE5nO/download -O data/result.tar.gz > /dev/null 2>&1
    cd data > /dev/null 2>&1
    tar xzvf result.tar.gz > /dev/null 2>&1
    mv rd53a-result last_scan_cache > /dev/null 2>&1
    rm -rf rd53a-result > /dev/null 2>&1
    rm result.tar.gz > /dev/null 2>&1
    cd - > /dev/null 2>&1
fi

if [ ! -d ./data/last_scan_cache ]; then
    printf '\033[31m%s\033[m\n' "[LDB ERROR] There are probably chipType missing in connectivity config: ${conn}"
    printf '\033[31m%s\033[m\n' "            Specify 'FEI4B' or 'RD53A' in ${conn}"
    exit 1
fi

now=`date +%s`

python3 <<EOF
import os, sys, json
path = "${conn}"
with open(path, 'r') as f: conn_j = json.load(f)
path = 'chips.txt'
chips = open(path, 'w')
for i in conn_j['chips']:
    if not "serialNumber" in i: sys.exit(1)
    name = i["serialNumber"]
    # before/after
    if "${fei4b}"=="true":
        p = './data/last_scan_cache/fei4b_test.json'
    if "${rd53a}"=="true":
        p = './data/last_scan_cache/rd53a_test.json'
    with open('{}.before'.format(p), 'r') as f:
        chip_j = json.load(f)
    if "${fei4b}"=="true":
        chip_j["FE-I4B"]["name"] = name
    if "${rd53a}"=="true":
        chip_j["RD53A"]["Parameter"]["Name"] = name
    with open('./data/last_scan/{}.json.before'.format(name), 'w') as f: json.dump(chip_j, f, indent=4)

    with open('{}.after'.format(p), 'r') as f:
        chip_j = json.load(f)
    if "${fei4b}"=="true":
        chip_j["FE-I4B"]["name"] = name
    if "${rd53a}"=="true":
        chip_j["RD53A"]["Parameter"]["Name"] = name
    with open('./data/last_scan/{}.json.after'.format(name), 'w') as f: json.dump(chip_j, f, indent=4)

    chips.write(name)
p = './data/last_scan_cache/scanLog.json'
if os.path.isfile(p):
    with open(p, 'r') as f: log_j = json.load(f)
    log_j["connectivity"] = conn_j
    log_j["startTime"] = ${now}
    log_j["finishTime"] = ${now}
    log_j["testType"] = "${scan}"
    p = './data/last_scan/scanLog.json'
    with open(p, 'w') as f: json.dump(log_j, f, indent=4)
EOF
if [ $? = 1 ]; then
    printf '\033[31m%s\033[m\n' "[LDB ERROR] No chip serialNumber found in ${conn}"
    printf '\033[31m%s\033[m\n' "            Enter chips.i.serialNumber."
    exit 1
fi

chips=$(cat chips.txt)
data_array=$( echo "EnMask.json EnMask.png L1Dist.json L1Dist.pdf OccupancyMap.json OccupancyMap.png" )

for chip in ${chips[@]}; do
    for data in ${data_array[@]}; do
        if [ -f ./data/last_scan_cache/JohnDoe_0_${data} ]; then
            cp ./data/last_scan_cache/JohnDoe_0_${data} ./data/last_scan/${chip}_${data}
        fi
    done
done
cp ./data/last_scan_cache/std_digitalscan.json ./data/last_scan/${scan}.json

rm -rf ./data/last_scan_cache
rm chips.txt

if "${db}"; then
    ./localdb/bin/localdbtool-upload scan ./data/last_scan
fi
