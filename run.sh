#!/bin/bash

# Dependencies

KAFKA_DOCKER_GIT=https://github.com/wurstmeister/kafka-docker.git
JMX_AGENT_URL=https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.9/jmx_prometheus_javaagent-0.9.jar
KAFKA_DASHBOARD_URL=https://raw.githubusercontent.com/prometheus/jmx_exporter/master/example_configs/kafka-0-8-2.yml
MAP_PLUGIN_URL=https://grafana.com/api/plugins/grafana-worldmap-panel/versions/0.0.21/download
GRAFANA_PLUGINS="grafana-worldmap-panel-c0f73da"

# Definitions

VIRTUALIP="172.16.123.1"
ORIG=`pwd`
GRAFANA_DATA=".heatmap_docker/grafana-data"
DIRS=".heatmap_docker/mosquitto-data .heatmap_docker/mosquitto-log .heatmap_docker/influxdb-data $GRAFANA_DATA .heatmap_docker/kafka-data .heatmap_docker/prometheus-data"
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

function grafana(){
    for plugin in $GRAFANA_PLUGINS
    do
        if [ ! -d ~/$GRAFANA_DATA/plugins/$plugin ]; then
            unzip "grafana/plugins/$plugin" -d ~/$GRAFANA_DATA/plugins
        fi
    done
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