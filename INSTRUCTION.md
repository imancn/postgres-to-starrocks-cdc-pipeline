# INSTRUCTION.md

## ✅ Setup Instructions

1. **Clone the Project**
```bash
git clone https://your-repo
cd postgres-to-starrocks-cdc-pipeline
```

2. **Make `setup.sh` Executable**
```bash
chmod +x setup.sh
```

3. **Run Setup**
```bash
./setup.sh
```

This will:
- Create Docker network
- Download Flink CDC connectors
- Start StarRocks FE and BE
- Start PostgreSQL and Flink
- Create the target database in StarRocks
- Submit Flink CDC job

---

## 🔍 Monitoring

- **Flink UI**: http://localhost:8081 – check CDC job is running
- **StarRocks UI**: http://localhost:8030 – login as root

---

## 🧪 Test CDC Replication

```bash
docker exec -it postgres-db psql -U postgres -d app_db
```

Insert data:

```sql
INSERT INTO orders (item, quantity, price) VALUES ('NewItem', 3, 12.50);
```

Then:

```bash
docker exec -it starrocks-fe mysql -uroot -h127.0.0.1 -P9030 -e "SELECT * FROM app_db.orders;"
```

---

## 🔄 Schema Change Example

In Postgres:

```sql
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
UPDATE users SET phone = '+123456789' WHERE name = 'Alice';
```

Check StarRocks:

```bash
docker exec -it starrocks-fe mysql -uroot -h127.0.0.1 -P9030 -e "DESC app_db.users;"
```

---

## 🧼 Cleanup

```bash
docker-compose -f docker-compose.postgres-flink.yml down -v
docker-compose -f docker-compose.starrocks.yml down -v
docker network rm cdc-network
```

---

## 🆘 Common Errors

- **Flink CDC not detecting slot**: Ensure `wal_level=logical` and slot name matches
- **BE not joining FE**: Wait for health check in `setup.sh` or manually inspect logs
- **CDC job stuck in snapshot**: Allow time or restart the job
