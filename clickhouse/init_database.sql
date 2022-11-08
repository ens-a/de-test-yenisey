SET allow_experimental_database_materialized_mysql = 1;
CREATE DATABASE IF NOT EXISTS db_mysql
ENGINE = MaterializedMySQL(
  'mysql-db:3306',
  'db',
  'clickhouse-user',
  'CHonelove'
);



CREATE TABLE IF NOT EXISTS clicks
(
    click_id UInt32,
    user_id UInt32,
    ua String,
    ip String,
    country String,
    created_at DateTime64

) ENGINE = MergeTree() ORDER BY click_id;

CREATE TABLE IF NOT EXISTS default.clicks_queue
(
    click_id UInt32,
    user_id UInt32,
    ua String,
    ip String,
    country String,
    created_at DateTime64
      
) ENGINE = Kafka('broker:9092', 'clicks', 'clickhouse', 'JSONEachRow') 
SETTINGS kafka_thread_per_consumer = 0, kafka_num_consumers = 1;

CREATE MATERIALIZED VIEW IF NOT EXISTS default.clicks_mv TO default.clicks AS
SELECT *
FROM default.clicks_queue
SETTINGS
stream_like_engine_allow_direct_select = 1;



CREATE MATERIALIZED VIEW IF NOT EXISTS default.clicks_conversions_mart_mv 
ENGINE = MergeTree() ORDER BY click_id POPULATE
AS
SELECT 
	click_id,
    user_id,
    ua,
    ip,
    country,
    cl.created_at as click_created_at,
    conversion_id,
    amount,
    status,
    co.created_at as conversion_created_at,
    updated_at as conversion_updated_at
FROM clicks cl
LEFT OUTER JOIN db_mysql.conversions co 
USING click_id;



CREATE MATERIALIZED VIEW IF NOT EXISTS default.report_users_conversions 
ENGINE = SummingMergeTree() order by temp_col POPULATE
AS
select  'key' as temp_col,
		uniqExactIf(user_id, conversion_id!=0) as users_with_conv, 
		uniqExact(user_id) - uniqExactIf(user_id, conversion_id!=0) as users_without_conv
from clicks_conversions_mart_mv
group by temp_col;

CREATE MATERIALIZED VIEW IF NOT EXISTS default.report_users_countries 
ENGINE = AggregatingMergeTree()
ORDER BY user_id POPULATE
AS
select user_id, 
        groupUniqArray(country) as countries
from clicks_conversions_mart_mv
group by user_id
;