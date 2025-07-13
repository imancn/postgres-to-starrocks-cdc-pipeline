#!/bin/bash

echo "✅ Using existing Docker containers..."

# Ensure network exists
echo "🔗 Verifying Docker network..."
docker network inspect cdc-network >/dev/null 2>&1 || docker network create cdc-network
echo "✅ Network 'cdc-network' found."

# Ensure required JARs
mkdir -p flink-connectors

PG_CDC_JAR=flink-connectors/flink-sql-connector-postgres-cdc-2.4.1.jar
STARROCKS_JAR=flink-connectors/flink-connector-starrocks-1.2.6_flink-1.17.jar

if [ ! -f "$PG_CDC_JAR" ]; then
  echo "⬇️ Downloading PostgreSQL CDC connector..."
  wget -O "$PG_CDC_JAR" https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-postgres-cdc/2.4.1/flink-sql-connector-postgres-cdc-2.4.1.jar
fi
echo "✅ Found CDC connector JAR: $PG_CDC_JAR"

if [ ! -f "$STARROCKS_JAR" ]; then
  echo "⬇️ Downloading StarRocks connector..."
  wget -O "$STARROCKS_JAR" https://github.com/StarRocks/starrocks-flink-connector/releases/download/1.2.6/flink-connector-starrocks-1.2.6_flink-1.17.jar
fi
echo "✅ Found StarRocks connector JAR: $STARROCKS_JAR"

# Try applying schema
echo "🧱 Applying StarRocks schema DDL..."
if docker exec starrocks-fe mysql -uroot -h127.0.0.1 -P3306 < ./ddl/init.sql 2>/dev/null; then
  echo "✅ StarRocks schema applied."
else
  echo "⚠️ Could not apply DDL. StarRocks FE might not be ready yet."
fi

# Check Flink health
echo "📦 Checking Flink JobManager is healthy..."
STATUS=$(curl -s http://localhost:8081/overview)
echo "$STATUS" | grep -q '"taskmanagers":1' && echo "✅ Flink JobManager is healthy." || { echo "❌ Flink JobManager is not healthy. Exiting."; exit 1; }

# Submit Flink SQL job
echo "📤 Submitting Flink CDC SQL job..."
docker cp "$PG_CDC_JAR" flink-jobmanager:/opt/flink/lib/
docker cp "$STARROCKS_JAR" flink-jobmanager:/opt/flink/lib/
docker cp job.sql flink-jobmanager:/opt/flink/job.sql

docker exec flink-jobmanager flink/bin/sql-client.sh -f /opt/flink/job.sql

echo "✅ Flink CDC job submitted successfully!"

