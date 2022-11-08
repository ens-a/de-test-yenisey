mysql -u root -p$MYSQL_ROOT_PASSWORD << EOF

GRANT ALL PRIVILEGES ON *.* TO 'clickhouse-user'@'%' IDENTIFIED BY 'CHonelove';

CREATE TABLE db.conversions (
    conversion_id INT(25),
    click_id INT(25) NOT NULL,
    amount FLOAT(2)NOT NULL,
    status TEXT NOT NULL,
    created_at DATE NOT NULL,
    updated_at DATE NOT NULL,
    PRIMARY KEY (conversion_id)
);

LOAD DATA INFILE '/var/lib/mysql-files/data_conversions.csv' 
INTO TABLE db.conversions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

EOF
