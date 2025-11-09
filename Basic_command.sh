sudo jps 
sudo jps -lm | grep 'NameNode'
# IN Cloudera hadoop processes are bootstraped for ubantu bigdata virtual machine --
ls -ls *.sh

./Start-Hadoop-Hive.sh
./Stop-Hadoop-Hive.sh

hdfs dfs

hdfs dfsdmin -report  

# check resourse manager UI - http://localhost:8088/

sudo netsata -nputl | grep <process_id_of_resourse_manager>

# check NameNode Status - http://localhost:50070/

# check JobHistory UI - http://localhost:19888/

./run-jobhistory.sh

hdfs dfs -put path.to/filename

hdfs dfs -rm path.to/filename

hdfs dfs -D dfs.blocksize=30 -put stocks.csv

hdfs fsck /user/cloudera/stocks.csv -files -blocks -locations

sudo find / -type f -name <Filename>

sudo find / -type f -name blk:123456789

sudo cat /location/to/datablock

hdfs dfs -mkdir <filename>

hdfs dfs --mkdir -p test/test1/test2

hdfs dfs -getmerge src localdest

hdfs dfs -du 

hdfs dfs -df

#----------------------------------Web HDFS -------------------------------------------------------


http://<NameNode>:50070/webhdfs/v1/<path>?op=<Operation_and_Argument>

curl -i -x PUT "http://<NameNode>:50070/webhdfs/v1/user/cloudera/mydata?op=MKDIR&user.name=cloudera"

curl -i -x PUT "http://<NameNode>:50070/webhdfs/v1/user/cloudera/test?op=DELETE&recursive=True"



hdfs://namenode1:8020/<src1>
