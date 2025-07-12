# 📄 Postgres to StarRocks CDC Pipeline

## 🧱 Architecture Overview

This system uses **Apache Flink**, **PostgreSQL**, and **StarRocks** to build a **real-time change data capture (CDC) pipeline**. The architecture includes:

- `PostgreSQL`: Source database with CDC enabled via WAL.
- `Flink`: Stream processing engine using Flink CDC connectors.
- `StarRocks`: Real-time analytics sink engine.
- `Docker Compose`: Used for orchestrating all components.

---

## 📁 Folder Structure

```
postgres-to-starrocks-cdc-pipeline/
│
├── docker-compose.postgres-flink.yml     # Compose file for Postgres and Flink
├── docker-compose.starrocks.yml          # Compose file for StarRocks FE + BE
├── flink/                                # Flink libs and config
│   └── lib/                              # JAR connectors for PostgreSQL and StarRocks
├── starrocks/
│   ├── fe/                               # StarRocks Frontend volumes
│   └── be/                               # StarRocks Backend volumes
├── setup.sh                              # Full automated setup script
└── README.md                             # Instructions
```

---

## 🛠 Prerequisites

- Docker and Docker Compose installed.
- Network named `cdc-network` already created or will be created by the script.
- Ports:
  - PostgreSQL: `5432`
  - Flink Web UI: `8081`
  - StarRocks FE: `8030`, `9010`, `9020`

---

## 🐘 PostgreSQL + Flink Setup

**File:** `docker-compose.postgres-flink.yml`

- PostgreSQL 15 with CDC (`wal_level=logical`)
- Flink 1.20.1 with Scala 2.12 and Java 8
- Exposes Flink JobManager and TaskManager
- Includes mounted JARs for:
  - `flink-sql-connector-postgres-cdc`
  - `flink-cdc-pipeline-connector-starrocks`

---

## 🌟 StarRocks Setup

**File:** `docker-compose.starrocks.yml`

- Uses `starrocks/fe-ubuntu:3.2-latest` and `starrocks/be-ubuntu:3.2-latest`
- FE and BE volumes for logs and metadata
- Adds a `tail -f` on log files to keep the containers alive
- FE and BE linked via the shared network

---

## 📦 Flink Connectors

**Downloaded JARs:**

```
https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-postgres-cdc/${version}/flink-sql-connector-postgres-cdc-${version}.jar

https://repo1.maven.org/maven2/org/apache/flink/flink-cdc-pipeline-connector-starrocks/${version}/flink-cdc-pipeline-connector-starrocks-${version}.jar
```

Both are placed into: `./flink/lib/`

---

## 🚀 Setup Instructions

### 1. Clone Project

```bash
git clone <your-repo>
cd postgres-to-starrocks-cdc-pipeline
```

### 2. Run Setup Script

```bash
chmod +x setup.sh
./setup.sh
```

This will:
- Create Docker network
- Download necessary Flink JARs
- Start StarRocks FE and BE
- Start PostgreSQL and Flink components

---

## 🧪 Verify

- Access Flink Dashboard at: `http://localhost:8081`
- StarRocks FE Web UI: `http://localhost:8030`

---

## 🛠 Troubleshooting

- If `starrocks-fe` or `starrocks-be` exits immediately, check log mounts and run:
  ```bash
  docker compose -f docker-compose.starrocks.yml up -d --force-recreate
  ```
- If Flink fails, check JobManager logs:
  ```bash
  docker logs flink-jobmanager
  ```

---

## 📌 Notes

- Each container mounts log and data directories locally.
- Uses `cdc-network` to ensure all services communicate across docker-compose groups.
- The FE/BE containers must run with a persistent command (e.g., `tail -f log`) to avoid exit.
