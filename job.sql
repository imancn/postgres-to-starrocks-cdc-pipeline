-- Source: PostgreSQL CDC table
CREATE TABLE users (
  id INT,
  name STRING,
  email STRING,
  created_at TIMESTAMP(3),
  PRIMARY KEY (id) NOT ENFORCED
) WITH (
  'connector' = 'postgres-cdc',
  'hostname' = 'postgres-db',
  'port' = '5432',
  'username' = 'postgres',
  'password' = 'password',
  'database-name' = 'test_db',
  'schema-name' = 'public',
  'table-name' = 'users',
  'slot.name' = 'flink_cdc_slot',
  'decoding.plugin.name' = 'pgoutput'
);

-- Sink: StarRocks table
CREATE TABLE users_sink (
  id INT,
  name STRING,
  email STRING,
  created_at TIMESTAMP
) WITH (
  'connector' = 'starrocks',
  'jdbc-url' = 'jdbc:mysql://starrocks-fe:9030',
  'load-url' = 'starrocks-fe:8030',
  'username' = 'root',
  'password' = '',
  'database-name' = 'test_db',
  'table-name' = 'users',
  'sink.buffer-flush.interval-ms' = '30000',
  'sink.properties.format' = 'json',
  'sink.properties.strip_outer_array' = 'true'
);

-- Start streaming
INSERT INTO users_sink
SELECT id, name, email, created_at FROM users;

