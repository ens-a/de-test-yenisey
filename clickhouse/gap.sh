sleep 5

# clickhouse-client << EOF
# SET allow_experimental_database_materialized_mysql = 1;
# EOF

# clickhouse-client << EOF
# # CREATE TABLE conversions (
# #     conversion_id UInt32,
# #     click_id UInt32,
# #     amount Float32,
# #     status String,
# #     created_at DateTime,
# #     updated_at Date
# # )
# # ENGINE = MySQL('mysql-db:3306','db','conversions', '${MYSQL_USER}', '${MYSQL_PASSWORD}');

# # CREATE DATABASE mysql_replica ENGINE = MaterializedMySQL('mysql-db:3306', 'db', '${MYSQL_USER}', '${MYSQL_PASSWORD}')

# EOF

# clickhouse-client << EOF
# CREATE TABLE clicks
# (
#     click_id UInt32,
#     user_id UInt32,
#     ua String,
#     ip String,
#     country String,
#     created_at DateTime64

# ) ENGINE = MergeTree() ORDER BY click_id;
# EOF

# clickhouse-client << EOF
# CREATE TABLE default.clicks_queue
# (
#     click_id UInt32,
#     user_id UInt32,
#     ua String,
#     ip String,
#     country String,
#     created_at DateTime64
      
# ) ENGINE = Kafka('broker:9092', 'clicks', 'clickhouse', 'JSONEachRow') 
# SETTINGS kafka_thread_per_consumer = 0, kafka_num_consumers = 1;
# EOF

# clickhouse-client << EOF
# CREATE MATERIALIZED VIEW default.clicks_mv TO default.clicks AS
# SELECT *
# FROM default.clicks_queue
# SETTINGS
# stream_like_engine_allow_direct_select = 1;

# EOF