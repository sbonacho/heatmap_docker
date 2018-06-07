#!/bin/bash

# Dependencies

KAFKA_DOCKER_GIT=https://github.com/wurstmeister/kafka-docker.git
JMX_AGENT_URL=https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.9/jmx_prometheus_javaagent-0.9.jar
KAFKA_DASHBOARD_URL=https://raw.githubusercontent.com/prometheus/jmx_exporter/master/example_configs/kafka-0-8-2.yml
MAP_PLUGIN_URL=https://grafana.com/api/plugins/grafana-worldmap-panel/versions/0.0.21/download

# Definitions

VIRTUALIP="172.16.123.1"
ORIG=`pwd`
DIRS="mosquitto-data mosquitto-logs influxdb-data grafana-data kafka-data prometheus-data"
PROMETHEUS=prometheus/prometheus.jar
DASHBOARD=prometheus/kafka.yml

# ---------- Defaults --------

# ---------- Functions -------


function network(){
    NET=`ifconfig -a|grep ${VIRTUALIP}`
    if [ "$NET" == "" ]; then
        sudo ifconfig lo0 alias ${VIRTUALIP}
    fi
}

function downloadKafka(){
    if [ ! -d "kafka-docker" ]; then
        git clone $KAFKA_DOCKER_GIT
    fi
}

function prometheus(){
    if [ ! -f "$PROMETHEUS" ]; then
        mkdir -p prometheus
        curl $JMX_AGENT_URL -o $PROMETHEUS
        curl $KAFKA_DASHBOARD_URL -o $DASHBOARD
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

case $1 in
    "install")
        downloadKafka
        prometheus
        network
        createDirs
        ;;
    "start")
        downloadKafka
        prometheus
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