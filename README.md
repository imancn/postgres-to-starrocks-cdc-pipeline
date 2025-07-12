# PostgreSQL to StarRocks Real-Time CDC Pipeline

This project implements a fully automated, real-time Change Data Capture (CDC) pipeline using **Apache Flink** to stream changes from **PostgreSQL** into **StarRocks**.

It supports full schema syncing (including `ALTER TABLE`) and uses **Flink CDC** connectors via YAML configuration – no Java JAR or custom builds needed.

---

## 🏗 Architecture

```text
PostgreSQL (CDC Source)
       │
       ▼
Apache Flink (JobManager + TaskManager)
       │
       ▼
StarRocks (Frontend + Backend)
```

Flink reads changes using PostgreSQL logical decoding (`wal_level=logical`) and applies them to StarRocks via its native streaming load protocol.

---

## 📦 Project Structure

```
.
├── docker-compose.postgres-flink.yml   # Flink + PostgreSQL setup
├── docker-compose.starrocks.yml        # StarRocks FE + BE cluster
├── flink-connectors/                   # CDC connector JARs (auto-downloaded)
├── postgres-to-starrocks.yaml          # Flink CDC job config
├── sample_init.sql                     # Init script for Postgres
├── setup.sh                            # One-click setup script
├── README.md                           # This file
└── INSTRUCTION.md                      # Step-by-step guide
```

---

## ⚙ Requirements

- Docker
- Docker Compose
- Bash shell (for `setup.sh`)
- Internet connection (for downloading JARs)

---

## 🚀 Quick Start

```bash
git clone https://your-repo
cd postgres-to-starrocks-cdc-pipeline
chmod +x setup.sh
./setup.sh
```

Then visit:
- Flink UI: http://localhost:8081
- StarRocks FE: http://localhost:8030
- PostgreSQL: localhost:5432 (user/pass: postgres/postgres)

---

## 🧪 Test the Pipeline

Connect to Postgres:

```bash
docker exec -it postgres-db psql -U postgres -d app_db
```

Insert or modify data:

```sql
INSERT INTO users (name, email) VALUES ('Charlie', 'charlie@example.com');
```

Check StarRocks:

```bash
docker exec -it starrocks-fe mysql -uroot -h127.0.0.1 -P9030 -e "SELECT * FROM app_db.users;"
```

You should see the new row in StarRocks.

---

## 🧼 Clean Up

```bash
docker-compose -f docker-compose.postgres-flink.yml down -v
docker-compose -f docker-compose.starrocks.yml down -v
docker network rm cdc-network
```

---

## ❗ Troubleshooting

- ❌ **FE Not Alive**: Wait a few seconds; backend auto-registers on delay.
- ❌ **No tables in StarRocks**: Make sure `app_db` exists (`setup.sh` handles this).
- ❌ **JAR errors in Flink**: Ensure connector JARs are downloaded to `flink-connectors/`.

For more, see `INSTRUCTION.md`.

