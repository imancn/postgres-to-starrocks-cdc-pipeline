#!/bin/bash
set -e

echo "Creating Docker network..."
docker network create cdc-network || true

echo "Downloading Flink CDC and connectors..."
mkdir -p flink-connectors && cd flink-connectors

VERSION=3.4.0
curl -sLO https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-postgres-cdc/$VERSION/flink-sql-connector-postgres-cdc-$VERSION.jar
curl -sLO https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-starrocks/$VERSION/flink-cdc-pipeline-connector-starrocks-$VERSION.jar

cd ..

echo "Starting StarRocks..."
docker-compose -f docker-compose.starrocks.yml up -d

echo "Starting Postgres and Flink..."
docker-compose -f docker-compose.postgres-flink.yml up -d

echo "Waiting for StarRocks BE to become healthy..."
for i in {1..30}; do
  STATUS=$(docker inspect -f '{{.State.Health.Status}}' starrocks-be || echo "unknown")
  if [ "$STATUS" = "healthy" ]; then
    echo "StarRocks is healthy."
    break
  fi
  sleep 5
done

echo "Creating database in StarRocks..."
docker exec starrocks-fe mysql -uroot -h127.0.0.1 -P9030 -e "CREATE DATABASE IF NOT EXISTS app_db;"

echo "Submitting Flink CDC job..."
docker run --rm --network cdc-network   -v $(pwd)/postgres-to-starrocks.yaml:/job.yaml   -v $(pwd)/flink-connectors:/opt/flink/lib   flink:1.20.1-scala_2.12-java8   bash -c "/opt/flink/bin/sql-client.sh embedded -f /job.yaml"
