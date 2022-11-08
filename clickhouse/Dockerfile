FROM clickhouse/clickhouse-server:22.3.10

ADD ./gap.sh /docker-entrypoint-initdb.d
ADD ./init_database.sql /docker-entrypoint-initdb.d