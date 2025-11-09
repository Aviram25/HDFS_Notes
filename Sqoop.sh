sqoop import --connect jdbc:mysql://host/nyse \
--table StockPrices \
--target-dir /hdfs/output/path \
--as-textfile

# --split-by column_name

# --username and --password

# --query

# --num-mappers 2

# --driver com.mysql.jdbc.Driver

sqoop import --connect jdbc:mysql://quickstart.cloudera:3306/test \
--driver com.mysql.jdbc.Driver \
--username root --password password
--table test

sqoop import --connect jdbc:mysql://quickstart.cloudera:3306/test \
--driver com.mysql.jdbc.Driver \
--username root --password password
--query "select * from test s where s.salary>90000 and \$CONDITIONS" \
--split-by gender -m 2 --target-dir salaries3

mysql -u root -p

# load data local infile '/tmp/data.txt' into table data fields terminated ',';
