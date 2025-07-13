CREATE DATABASE IF NOT EXISTS test_db;

CREATE TABLE IF NOT EXISTS test_db.users (
  id INT,
  name STRING,
  email STRING,
  created_at DATETIME
)
DUPLICATE KEY(id)
DISTRIBUTED BY HASH(id) BUCKETS 3
PROPERTIES (
  "replication_num" = "1"
);

CREATE TABLE IF NOT EXISTS test_db.orders (
  id INT,
  user_id INT,
  item STRING,
  price DOUBLE,
  created_at DATETIME
)
DUPLICATE KEY(id)
DISTRIBUTED BY HASH(id) BUCKETS 3
PROPERTIES (
  "replication_num" = "1"
);
