# ============================================================================
# HADOOP CLUSTER MANAGEMENT AND HDFS COMMANDS REFERENCE
# ============================================================================

# ------------- Check Running Hadoop Processes -------------
# List all Java processes running on the system
sudo jps 

# Filter and display only NameNode process with full class name and arguments
# Useful for verifying NameNode is running and checking its configuration
sudo jps -lm | grep 'NameNode'

# ------------- Cloudera VM Hadoop Service Management -------------
# Note: In Cloudera Hadoop, processes are bootstrapped for Ubuntu BigData virtual machine
# List all shell scripts in current directory with file sizes
ls -ls *.sh

# Start Hadoop and Hive services
# Launches HDFS (NameNode, DataNode), YARN (ResourceManager, NodeManager), and Hive services
./Start-Hadoop-Hive.sh

# Stop Hadoop and Hive services
# Gracefully shuts down all Hadoop and Hive processes
./Stop-Hadoop-Hive.sh

# ------------- Basic HDFS Commands -------------
# Display HDFS command help and available operations
hdfs dfs

# Check HDFS cluster health and get detailed report
# Shows available/used space, number of DataNodes, block info, etc.
# Note: Command has typo - should be "dfsadmin" not "dfsdmin"
hdfs dfsadmin -report  

# ------------- Hadoop Web UI Monitoring -------------
# Check ResourceManager UI - monitors YARN applications and cluster resources
# Shows running applications, completed jobs, cluster metrics, node status
# Access at: http://localhost:8088/

# Check which process is using port 8088 (ResourceManager)
# Replace <process_id_of_resourse_manager> with actual PID
# Note: Command has typo - should be "netstat" not "netsata"
sudo netstat -nputl | grep <process_id_of_resourse_manager>

# Check NameNode Status UI - monitors HDFS health and storage
# Shows DataNode status, file system statistics, block information
# Access at: http://localhost:50070/

# Check JobHistory Server UI - view completed MapReduce job details
# Shows job logs, counters, task attempts, and execution statistics
# Access at: http://localhost:19888/

# Start JobHistory Server if not already running
# Required to view historical job information in the web UI
./run-jobhistory.sh

# ------------- HDFS File Operations -------------
# Upload a file from local filesystem to HDFS
# Usage: hdfs dfs -put <local_path> <hdfs_path>
hdfs dfs -put path.to/filename

# Delete a file from HDFS
# Usage: hdfs dfs -rm <hdfs_path>
hdfs dfs -rm path.to/filename

# Upload file with custom block size (30 bytes in this example)
# -D flag sets configuration property for this command only
# Default HDFS block size is typically 128MB or 256MB
hdfs dfs -D dfs.blocksize=30 -put stocks.csv

# Check file system integrity and get detailed block information
# -files: List all files in the path
# -blocks: Show block IDs and their locations
# -locations: Show which DataNodes store each block replica
hdfs fsck /user/cloudera/stocks.csv -files -blocks -locations

# ------------- Finding Physical Block Locations -------------
# Search entire filesystem for a specific file
# -type f: Search for files only (not directories)
sudo find / -type f -name <Filename>

# Find physical location of HDFS data block on disk
# Block files are stored in DataNode's configured data directories
# Format: blk_<block_id>
sudo find / -type f -name blk_123456789

# View contents of a physical HDFS block file
# Note: Block files contain raw data without metadata
sudo cat /location/to/datablock

# ------------- HDFS Directory Operations -------------
# Create a single directory in HDFS
hdfs dfs -mkdir <filename>

# Create nested directories recursively
# -p flag creates parent directories if they don't exist
# Similar to 'mkdir -p' in Linux
hdfs dfs -mkdir -p test/test1/test2

# ------------- HDFS Data Retrieval -------------
# Merge multiple HDFS files into a single local file
# Useful for downloading MapReduce output (part-r-00000, part-r-00001, etc.)
# Usage: hdfs dfs -getmerge <hdfs_source_dir> <local_destination_file>
hdfs dfs -getmerge src localdest

# ------------- HDFS Space Usage Commands -------------
# Display disk usage of files and directories
# Shows size of each file/directory in specified path
hdfs dfs -du 

# Display filesystem capacity, used space, and available space
# Similar to 'df' command in Linux
hdfs dfs -df

# ============================================================================
# WEB HDFS REST API
# ============================================================================
# WebHDFS provides RESTful HTTP access to HDFS operations
# Allows remote file operations without needing Hadoop client installation

# ------------- WebHDFS URL Format -------------
# General format for WebHDFS operations:
# http://<NameNode>:50070/webhdfs/v1/<path>?op=<Operation_and_Arguments>

# Create a directory via WebHDFS REST API
# -i: Include HTTP headers in output
# -X PUT: Use HTTP PUT method
# op=MKDIR: Operation to create directory
# user.name=cloudera: Specify the user performing the operation
curl -i -X PUT "http://<NameNode>:50070/webhdfs/v1/user/cloudera/mydata?op=MKDIR&user.name=cloudera"

# Delete a directory recursively via WebHDFS
# op=DELETE: Operation to delete file/directory
# recursive=true: Delete directory and all its contents
curl -i -X PUT "http://<NameNode>:50070/webhdfs/v1/user/cloudera/test?op=DELETE&recursive=true"

# ============================================================================
# DISTCP - DISTRIBUTED COPY
# ============================================================================
# DistCp is a tool for large inter/intra-cluster copying
# Uses MapReduce to distribute the copy operation across cluster

# Copy data between two different Hadoop clusters
# Useful for data migration, backup, or replication
# Usage: hadoop distcp <source_cluster> <destination_cluster>
hadoop distcp hdfs://<namenode1>:8020/<source> hdfs://<namenode2>:8020/<destination>

# Copy multiple sources to a destination
# Can copy from multiple directories/files in one operation
# All sources must exist before running the command
hadoop distcp hdfs://<namenode1>:8020/<source1> hdfs://<namenode1>:8020/<source2> hdfs://<namenode2>:8020/<destination>
