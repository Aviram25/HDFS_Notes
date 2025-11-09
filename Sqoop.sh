# ============================================================================
# SQOOP - SQL TO HADOOP DATA IMPORT/EXPORT TOOL
# ============================================================================
# Sqoop enables bulk data transfer between Hadoop and relational databases
# Uses MapReduce to parallelize data transfer and handle large datasets

# ------------- Basic Sqoop Import - Complete Table -------------
# Import entire table from MySQL database to HDFS
sqoop import \
  --connect jdbc:mysql://host/nyse \        # JDBC connection URL: jdbc:mysql://<hostname>/<database>
  --table StockPrices \                     # Source table name to import
  --target-dir /hdfs/output/path \          # HDFS destination directory for imported data
  --as-textfile                             # Output format: plain text (CSV-like), alternatives: --as-avrodatafile, --as-parquetfile

# ------------- Common Sqoop Import Options (commented examples) -------------
# --split-by column_name                   # Column used to split work between mappers (must be indexed, typically primary key)
                                            # Required when using multiple mappers with non-primary key tables
                                            
# --username <user> --password <pass>      # Database authentication credentials
                                            # Alternative: --password-file for security
                                            
# --query "SELECT..."                       # Custom SQL query instead of importing entire table
                                            # Must include $CONDITIONS placeholder for parallel imports
                                            
# --num-mappers 2 or -m 2                   # Number of parallel map tasks for import
                                            # Default is 4, use 1 for non-splittable imports
                                            
# --driver com.mysql.jdbc.Driver           # JDBC driver class (usually auto-detected)
                                            # Required for some databases or custom drivers

# ============================================================================
# EXAMPLE 1: Basic Table Import with Authentication
# ============================================================================
# Import entire 'test' table from MySQL to HDFS
sqoop import \
  --connect jdbc:mysql://quickstart.cloudera:3306/test \  # Database: 'test' on quickstart.cloudera:3306
  --driver com.mysql.jdbc.Driver \                        # MySQL JDBC driver
  --username root \                                       # MySQL username
  --password password \                                   # MySQL password (plain text - use --password-file for security)
  --table test                                            # Table name to import

# Default behavior:
# - Creates directory: /user/<username>/test in HDFS
# - Imports all rows and columns
# - Uses 4 parallel mappers by default
# - Output format: CSV with comma delimiter
# - Uses primary key for splitting data between mappers

# ============================================================================
# EXAMPLE 2: Import with Custom Query and Split Configuration
# ============================================================================
# Import filtered data using SQL query with custom parallelization
sqoop import \
  --connect jdbc:mysql://quickstart.cloudera:3306/test \  # Database connection
  --driver com.mysql.jdbc.Driver \                        # JDBC driver
  --username root \                                       # Username
  --password password \                                   # Password
  --query "select * from test s where s.salary>90000 and \$CONDITIONS" \  # Custom SQL query with filter
  --split-by gender \                                     # Split work by 'gender' column
  -m 2 \                                                  # Use 2 mappers (short form of --num-mappers)
  --target-dir salaries3                                  # Output directory in HDFS

# Key points about --query:
# - Must include "$CONDITIONS" placeholder (escaped as \$CONDITIONS in shell)
# - $CONDITIONS is replaced by Sqoop with parallelization logic
# - Cannot use --table when using --query
# - Must specify --target-dir (no default directory)
# - WHERE clause allows data filtering at source

# Key points about --split-by:
# - Specifies column for parallelizing the import
# - Column should have good data distribution
# - Creates WHERE clauses like: gender='M', gender='F' for different mappers
# - Required when using --query with multiple mappers

# ============================================================================
# MYSQL DATABASE OPERATIONS
# ============================================================================

# ------------- Connect to MySQL -------------
# Login to MySQL database with password prompt
# -u root: Username is 'root'
# -p: Prompt for password (more secure than inline password)
mysql -u root -p

# ------------- Load Data into MySQL Table -------------
# Bulk load data from local text file into MySQL table
# Useful for preparing test data or importing external datasets
# 
# CORRECTED COMMAND:
# load data local infile '/tmp/data.txt' 
# into table data 
# fields terminated by ',';
#
# Breakdown:
# - load data local infile: MySQL command to load data from file
# - local: File is on client machine (not MySQL server)
# - '/tmp/data.txt': Path to source data file
# - into table data: Target table name
# - fields terminated by ',': CSV format with comma delimiter
# - Optional clauses: lines terminated by '\n', ignore 1 lines (for headers)

# ============================================================================
# COMPLETE SQOOP WORKFLOW EXAMPLE
# ============================================================================

# Step 1: Verify MySQL table and data
# mysql -u root -p
# USE test;
# SELECT * FROM test LIMIT 10;
# DESCRIBE test;

# Step 2: Import table to HDFS
# sqoop import --connect jdbc:mysql://localhost:3306/test \
#   --username root --password-file /user/cloudera/.password \
#   --table employees --target-dir /data/employees \
#   --split-by emp_id -m 4

# Step 3: Verify imported data in HDFS
# hdfs dfs -ls /data/employees
# hdfs dfs -cat /data/employees/part-m-00000 | head -n 10

# Step 4: Process with MapReduce or Hive
# hive> CREATE EXTERNAL TABLE employees_hdfs (...)
#       LOCATION '/data/employees';

# ============================================================================
# ADDITIONAL SQOOP IMPORT OPTIONS
# ============================================================================
# --where "condition"                      # Filter rows (simpler than --query)
# --columns "col1,col2,col3"               # Import specific columns only
# --incremental append                      # Incremental import (append new rows)
# --check-column id                         # Column to check for incremental import
# --last-value 1000                         # Import rows with id > 1000
# --compress                                # Compress data with gzip
# --direct                                  # Use database-specific fast path (MySQL, PostgreSQL)
# --null-string '\\N'                       # String to represent NULL in text output
# --null-non-string '\\N'                   # String to represent NULL for non-string columns
# --fields-terminated-by '\t'               # Change field delimiter (default: comma)
# --lines-terminated-by '\n'                # Change line delimiter
# --enclosed-by '"'                         # Enclose fields in quotes
# --escaped-by '\\'                         # Escape character for special chars
# --boundary-query "SELECT min(id), max(id) FROM table"  # Custom query for split boundaries
# --fetch-size 1000                         # Number of rows to fetch per round trip
# --warehouse-dir /user/hive/warehouse      # Parent directory for all table imports

# ============================================================================
# SQOOP EXPORT (HDFS to Database)
# ============================================================================
# sqoop export --connect jdbc:mysql://localhost:3306/test \
#   --username root --password password \
#   --table results \
#   --export-dir /user/cloudera/output \
#   --input-fields-terminated-by ','

# ============================================================================
# SECURITY BEST PRACTICES
# ============================================================================
# 1. Never use plain text passwords in commands (visible in logs/history)
#    Use: --password-file /path/to/.password
#
# 2. Store password file in HDFS with restricted permissions:
#    echo -n "mypassword" > .password
#    hdfs dfs -put .password /user/cloudera/
#    hdfs dfs -chmod 400 /user/cloudera/.password
#
# 3. Use --password-alias with Hadoop credential provider
#
# 4. For production, use Kerberos authentication or connection managers
