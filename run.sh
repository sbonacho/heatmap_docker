#!/bin/bash

BASEDIR=$2

VIRTUALIP="172.16.123.1"
ORIG=`pwd`
DIRS="mosquitto-data mosquitto-logs influxdb-data grafana-data kafka-data"

# ---------- Defaults --------

if [ "$BASEDIR" == "" ]; then
    BASEDIR="../demo"
fi

# ---------- Functions -------


function network(){
    NET=`ifconfig -a|grep ${VIRTUALIP}`
    if [ "$NET" == "" ]; then
        sudo ifconfig lo0 alias ${VIRTUALIP}
    fi
}

function createDirs(){
    for dir in $DIRS
    do
        mkdir -p ~/$dir
    done
}

function stopSee(){
    ps -ef|grep "docker logs"|grep -v grep|awk '{print $2}'|xargs kill
}

function seeLogs(){
    stopSee
    for proj in $PROJECTS
    do
       if [ -d "$proj" ]; then
        docker logs $proj -f &
       fi
    done
    wait
}

function stop(){
    stopSee
    for proj in $PROJECTS
    do
       if [ -d "$proj" ]; then
        cd $proj
        bash $RUNSCRIPT stop
        cd ..
       fi
    done
}

# ---------- Script -------

if [ -d "$BASEDIR" ]; then
    cd $BASEDIR
fi

case $1 in
    "install")
        ;;
    "start")
        network
        createDirs
        docker-compose -f "$ORIG/docker-compose.yml" up -d
        ;;
    "stop")
        docker-compose -f "$ORIG/docker-compose.yml" stop
        ;;
    "watch")
        seeLogs
        ;;
    "stop-watch")
        stopSee
        ;;
    *)
        echo "use:
./run.sh [install|start|stop|watch|stop-watch]"
        ;;
esac