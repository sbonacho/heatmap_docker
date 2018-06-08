# Heat Map Infrastructure

This repository has the docker infrastructe for a Heat Map Demo.

## Install infrastructure

Run `./run.sh install`. This scripts create all data folders and download all tools.

## Start infrastructure

Use `./run.sh start`. This script wrap the docker-compose command and the initialization of virtual interface. 

```
➜  heatmap_docker git:(master) ✗ ./run.sh start
Starting heatmap_docker_grafana_1    ... done
Starting heatmap_docker_prometheus_1 ... done
Starting heatmap_docker_kafka_1      ... done
Starting heatmap_docker_zookeeper_1  ... done
```

First execution will build the kafka image.

This starts all services:

## Tests the services

### Grafana

open http://localhost:3000 (admin/admin)

Import all dashboards from grafana/dashboards. See http://docs.grafana.org/reference/export_import/ for more information. 

## Stop Infrastructure

Use `./run.sh stop`

```
➜  heatmap_docker git:(master) ✗ ./run.sh stop     
Stopping heatmap_docker_kafka_1      ... done
Stopping heatmap_docker_prometheus_1 ... done
Stopping heatmap_docker_grafana_1    ... done
Stopping heatmap_docker_zookeeper_1  ... done
```
