#!/bin/bash
set -e

echo "Creating Docker network..."
docker network create cdc-network || true

echo "Starting StarRocks..."
docker compose -f docker-compose.starrocks.yml up -d

echo "Starting Postgres and Flink..."
docker compose -f docker-compose.postgres-flink.yml up -d
