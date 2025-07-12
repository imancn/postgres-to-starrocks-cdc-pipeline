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

---

## 🔍 Deep Guide: Creating a Real-Time CDC Pipeline from PostgreSQL to StarRocks Using Apache Flink

This section is designed to guide engineers through understanding, setting up, and customising a full end-to-end real-time Change Data Capture (CDC) architecture. This guide assumes moderate familiarity with Docker, PostgreSQL, and general backend architecture.

---

### 🧠 **1. Understanding the Architecture**

This pipeline aims to replicate every change in a PostgreSQL database (insert/update/delete) into a StarRocks data warehouse in real-time using Flink CDC.

- **PostgreSQL**: Acts as the OLTP data source.
- **Flink**: Acts as a data streaming/ETL engine capturing changes via Debezium CDC.
- **StarRocks**: A fast MPP OLAP engine for real-time analytics.
- **Docker Compose**: To orchestrate services for local or isolated deployments.

---

### 📦 **2. Services Overview**

| Service        | Role                                                   |
|----------------|--------------------------------------------------------|
| PostgreSQL     | Source relational DB storing transactional data        |
| Flink          | Processes data from PostgreSQL and writes to StarRocks |
| StarRocks FE   | Frontend manager, manages metadata and query parsing   |
| StarRocks BE   | Backend worker nodes for data storage & execution      |

---

### ⚙️ **3. Step-by-Step Setup Instructions**

1. **Prepare Your Environment**
   - Install Docker and Docker Compose
   - Make sure ports 5432, 8081, 9030, 8030 are available

2. **Clone or Create Your Project Structure**

    ```
    .
    ├── docker-compose.starrocks.yml
    ├── docker-compose.postgres-flink.yml
    ├── config/
    │   ├── flink-conf.yaml
    │   └── connectors/
    │       └── flink-sql-connector-postgres-cdc.jar
    ├── setup.sh
    └── README.md
    ```

3. **Start All Services**

    ```bash
    chmod +x setup.sh
    ./setup.sh
    ```

4. **Verify Everything Is Up**

    - PostgreSQL → connect via `psql -h localhost -p 5432 -U postgres`
    - Flink UI → http://localhost:8081
    - StarRocks UI → http://localhost:8030

5. **Create the StarRocks Table**

    Connect to StarRocks FE (MySQL protocol on 9030):

    ```sql
    CREATE DATABASE demo;
    USE demo;
    CREATE TABLE user_activity (
        id INT,
        username VARCHAR(255),
        activity VARCHAR(255),
        ts DATETIME
    )
    DUPLICATE KEY(id)
    DISTRIBUTED BY HASH(id) BUCKETS 10
    PROPERTIES("replication_num" = "1");
    ```

6. **Launch CDC Sync Job**

    On Flink UI, open SQL Client or REST submit a CDC job using connector syntax:

    ```sql
    CREATE TABLE postgres_source (
        id INT,
        username STRING,
        activity STRING,
        ts TIMESTAMP(3),
        PRIMARY KEY (id) NOT ENFORCED
    ) WITH (
        'connector' = 'postgres-cdc',
        ...
    );

    CREATE TABLE starrocks_sink (
        ...
    );

    INSERT INTO starrocks_sink SELECT * FROM postgres_source;
    ```

---

### 🛠️ **4. Troubleshooting Tips**

| Issue                                      | Fix                                                                 |
|-------------------------------------------|----------------------------------------------------------------------|
| StarRocks BE/FE Exits                     | Add executable command in dockerfile (CMD or ENTRYPOINT)            |
| Flink JobManager exits with no JAR        | Do not run in `application mode`, use job submission instead         |
| Connector not found                       | Ensure correct connector JAR is in `/opt/flink/lib`                 |
| SQL job fails to submit                   | Check job syntax in Flink SQL or log output                         |

---

### 📚 **5. Learn More**

- [Apache Flink CDC Docs](https://nightlies.apache.org/flink/flink-cdc-connectors-docs-stable/)
- [StarRocks Docs](https://docs.starrocks.io)
- [Debezium Docs](https://debezium.io/)
- [Flink SQL](https://nightlies.apache.org/flink/flink-docs-release-1.20/docs/dev/table/sql/overview/)

---

### 🎓 Final Thoughts

This setup helps build:
- Real-time data sync pipelines
- Modern data lakehouses
- Analytical dashboards with fresh data

It’s suitable for:
- Streaming ingestion
- Real-time dashboards
- Data consistency monitoring
