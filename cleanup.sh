#!/bin/bash
echo "Stopping and removing all containers..."
docker rm -f postgres-db flink-jobmanager flink-taskmanager starrocks-fe starrocks-be || true

echo "Pruning Docker volumes and networks..."
docker volume prune -f
docker network rm cdc-network || true
docker network prune -f
docker system prune -f
