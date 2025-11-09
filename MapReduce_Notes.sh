# ============================================================================
# HADOOP JAR MANAGEMENT AND EXECUTION COMMANDS
# ============================================================================

# ------------- Inspecting JAR Files -------------
# List all files and classes contained in a JAR file
# -t: List table of contents
# -f: Specify the JAR file to inspect
# Useful for verifying JAR contents, finding class names, and checking package structure
jar -tf file.jar

# ------------- Running MapReduce Jobs with YARN -------------
# Execute a MapReduce job using YARN
# yarn jar: Command to submit JAR to YARN for execution
# file.jar: The JAR file containing your MapReduce application
# package.class: Fully qualified main class name (e.g., wordcount.WordCountJob)
# Usage: yarn jar <jar-file> <main-class> [args...]
yarn jar file.jar package.class

# Execute MapReduce job with input/output paths and custom configuration
# my-jar.jar: Your application JAR file
# mypkg.myDriverClass: Main driver class with package name
# input-file: HDFS path to input data
# output-file: HDFS path where output will be written (must not exist)
# -D mapreduce.job.reduces=10: Set number of reducer tasks to 10
# -D flag allows setting Hadoop configuration properties at runtime
yarn jar my-jar.jar mypkg.myDriverClass input-file output-file -D mapreduce.job.reduces=10

# ------------- Viewing Application Logs -------------
# Retrieve and display logs for a completed YARN application
# Useful for debugging failed jobs or analyzing application behavior
# Application ID format: application_<timestamp>_<sequence_number>
# Logs include stdout, stderr, and syslog from containers
# Usage: yarn logs -applicationId <application_id>
yarn logs -applicationId application_123_12

# ------------- Running Java Applications with Hadoop Dependencies -------------
# Execute a Java class with custom classpath including Hadoop and external libraries
# -cp or -classpath: Specify classpath for Java application
# "../build/project1.jar": Your application JAR
# "/usr/lib/hadoop/client/*": All Hadoop client libraries (wildcard includes all JARs)
# "../mysql-connector-java1-5.148.jar": MySQL JDBC driver for database connectivity
# hdfs-DataLoad: Main class to execute
# Note: Colons (:) separate multiple classpath entries on Linux/Mac (use semicolons on Windows)
java -cp "../build/project1.jar:/usr/lib/hadoop/client/*:../mysql-connector-java1-5.148.jar" hdfs-DataLoad

# ------------- Compiling Java Source Code -------------
# Compile Java source files with Hadoop dependencies
# javac: Java compiler command
# -cp "/usr/lib/hadoop/client/": Classpath containing Hadoop libraries needed for compilation
# -d .: Output directory for compiled .class files (. means current directory)
# /src/hdfs/.java: Path to Java source file(s) to compile
# Note: Missing filename - should be like "/src/hdfs/MyClass.java"
# After compilation, .class files will be in current directory matching package structure
javac -cp "/usr/lib/hadoop/client/" -d . /src/hdfs/.java

# ------------- Creating JAR Files -------------
# Create a JAR archive from compiled Java classes
# java: Should be "jar" command, not "java" (this is a typo in original)
# -c: Create new JAR archive
# -v: Verbose output (show files being added)
# -f /build/project2.jar: Output JAR file path and name
# /hdfs: Directory containing .class files to package
# 
# CORRECTED COMMAND:
# jar -cvf /build/project2.jar -C /hdfs .
# -C: Change to specified directory before adding files
# This creates project2.jar containing all classes from /hdfs directory
java -cvf /build/project2.jar /hdfs

# ============================================================================
# COMPLETE WORKFLOW EXAMPLE
# ============================================================================

# Step 1: Compile Java source files
# javac -cp "/usr/lib/hadoop/client/*" -d build src/wordcount/WordCountJob.java

# Step 2: Create JAR from compiled classes
# jar -cvf wordcount.jar -C build .

# Step 3: Inspect JAR contents (verify classes are included)
# jar -tf wordcount.jar

# Step 4: Run the MapReduce job
# yarn jar wordcount.jar wordcount.WordCountJob /input/data.txt /output/results

# Step 5: View application logs if job fails
# yarn logs -applicationId application_1234567890123_0001

# ============================================================================
# COMMON CONFIGURATION PROPERTIES (-D flags)
# ============================================================================
# -D mapreduce.job.reduces=N          : Set number of reduce tasks
# -D mapreduce.map.memory.mb=4096     : Set mapper memory allocation
# -D mapreduce.reduce.memory.mb=8192  : Set reducer memory allocation
# -D mapreduce.job.name="My Job"      : Set custom job name in UI
# -D mapreduce.input.fileinputformat.split.maxsize=134217728 : Set input split size
# -D mapred.textoutputformat.separator="," : Change output delimiter (default is tab)
