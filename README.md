# Heat Map Infrastructure

This repository has the docker infrastructe for a Heat Map Demo.

## Start infrastructure

Use the docker-compose command `docker-compose up -d`

```
➜  heatmap_docker git:(master) ✗ docker-compose up -d
Starting heatmap_docker_influxdb_1  ... done
Starting heatmap_docker_kafka_1     ... done
Starting heatmap_docker_mosquitto_1 ... done
Starting heatmap_docker_zookeeper_1 ... done
Starting heatmap_docker_grafana_1   ... done
```

First execution will build the kafka image.

This starts all services:

## Tests the services

### Grafana

open http://localhost:3000 (admin/admin)

## Stop Infrastructure

Use the docker-compose command `docker-compose stop`

```
➜  heatmap_docker git:(master) ✗ docker-compose stop     
Stopping heatmap_docker_grafana_1   ... done
Stopping heatmap_docker_zookeeper_1 ... done
Stopping heatmap_docker_mosquitto_1 ... done
Stopping heatmap_docker_kafka_1     ... done
Stopping heatmap_docker_influxdb_1  ... done
```
