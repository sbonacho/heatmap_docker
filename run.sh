#!/bin/bash

# Dependencies

KAFKA_DOCKER_GIT=https://github.com/wurstmeister/kafka-docker.git
JMX_AGENT_URL=https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.9/jmx_prometheus_javaagent-0.9.jar
JMX_CONF_URL=https://raw.githubusercontent.com/prometheus/jmx_exporter/master/example_configs/kafka-0-8-2.yml
MAP_PLUGIN_URL=https://grafana.com/api/plugins/grafana-worldmap-panel/versions/0.0.21/download

# Definitions

ORIG=`pwd`
DATA_DIR=.heatmap_docker
VIRTUALIP="172.16.123.1"
GRAFANA_DATA="$DATA_DIR/grafana-data"
DIRS="$DATA_DIR/mosquitto-data $DATA_DIR/mosquitto-log $DATA_DIR/influxdb-data $GRAFANA_DATA $DATA_DIR/kafka-data $DATA_DIR/prometheus-data"
KAFKA_JMX_AGENT=prometheus/prometheus.jar
KAFKA_JMX_CONF=prometheus/kafka.yml
GRAFANA_PLUGINS="grafana-worldmap-panel-c0f73da"

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

function grafana(){
    for plugin in $GRAFANA_PLUGINS
    do
        if [ ! -d ~/$GRAFANA_DATA/plugins/$plugin ]; then
            unzip "grafana/plugins/$plugin" -d ~/$GRAFANA_DATA/plugins
        fi
    done
}

function prometheus(){
    if [ ! -f "$KAFKA_JMX_AGENT" ]; then
        mkdir -p prometheus
        curl $JMX_AGENT_URL -o $KAFKA_JMX_AGENT
        curl $JMX_CONF_URL -o $KAFKA_JMX_CONF
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
        createDirs
        grafana
        downloadKafka
        prometheus
        network
        ;;
    "start")
        createDirs
        grafana
        downloadKafka
        prometheus
        network
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