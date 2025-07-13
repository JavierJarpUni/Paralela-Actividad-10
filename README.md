# Hadoop MapReduce WordCount Project

## Project Overview

This project implements the classic WordCount example using **Hadoop MapReduce**, demonstrating the core principles of distributed data processing. The goal is to count the occurrences of each word within a collection of text documents stored in the Hadoop Distributed File System (HDFS). This assignment fulfills the requirements for the "Big Data with Hadoop MapReduce" activity in Week 10.

---

## Objectives

- **Comprehend the MapReduce programming model** and its architecture within Hadoop
- **Implement a MapReduce job** (WordCount) on a real dataset using Java or Python Streaming
- **Analyze and compare the performance** of the job's execution in different configurations

## Quick Start Guide

### Step 1: Generate Sample Data
```bash
# Generate sample text files for testing
python3 scripts/generate_sample_data.py
```

### Step 2: Setup Environment
```bash
# Setup Hadoop environment and HDFS directories
./scripts/setup_environment.sh
```

### Step 3: Run WordCount
```bash
# Run WordCount with single reducer
./scripts/run_wordcount.sh -s

# Run performance analysis with 1, 2, and 4 reducers
./scripts/run_wordcount.sh -p

# View results
./scripts/run_wordcount.sh -r 1
```

---

## Detailed Setup Instructions Technologies Used

- **Apache Hadoop 3.x**: Core framework for distributed storage (HDFS) and processing (MapReduce)
- **Java** or **Python**: Programming language for implementing the MapReduce job
- **HDFS**: Hadoop Distributed File System for storing input and output data
- **Hadoop Streaming**: For Python implementation

---

## Environment Setup

### Prerequisites

- Linux/macOS environment (recommended)
- Java 8 or higher
- Apache Hadoop 3.x installed and configured
- Python 3.x (for streaming implementation)

### 1. Hadoop Environment Preparation

#### Install Hadoop (if not already installed)
```bash
# Download Hadoop 3.x from Apache website
wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.4/hadoop-3.3.4.tar.gz
tar -xzf hadoop-3.3.4.tar.gz
sudo mv hadoop-3.3.4 /opt/hadoop
```

#### Configure Environment Variables
```bash
export HADOOP_HOME=/opt/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
```

#### Verify Installation
```bash
hadoop version
hdfs dfs -ls /
```

### 2. Start Hadoop Services

```bash
# Start HDFS
start-dfs.sh

# Start YARN (optional for this project)
start-yarn.sh

# Verify services are running
jps
```

### 3. Prepare Data in HDFS

#### Create Input Directory
```bash
# Create user directory (if it doesn't exist)
hdfs dfs -mkdir -p /user/$(whoami)

# Create input directory
hdfs dfs -mkdir /user/$(whoami)/input
```

#### Upload Text Files
```bash
# Upload your text documents to HDFS
hdfs dfs -put /path/to/your/local/documents/*.txt /user/$(whoami)/input/

# Example:
hdfs dfs -put ~/data/sample_texts/*.txt /user/$(whoami)/input/

# Verify files are uploaded
hdfs dfs -ls /user/$(whoami)/input/
```

---

## Script Usage Guide

### Core Scripts

#### 1. **setup_environment.sh** - Environment Setup
```bash
# Setup Hadoop environment and HDFS directories
./scripts/setup_environment.sh
```

**What it does:**
- Checks Hadoop installation
- Starts Hadoop services (HDFS)
- Creates HDFS directories (`/user/$(whoami)/input`, `/user/$(whoami)/output`)
- Makes Python scripts executable
- Uploads sample data to HDFS

#### 2. **run_wordcount.sh** - WordCount Execution
```bash
# Run with single reducer
./scripts/run_wordcount.sh -s

# Run performance analysis (1, 2, 4 reducers)
./scripts/run_wordcount.sh -p

# Show results for specific reducer count
./scripts/run_wordcount.sh -r 2

# Test Python scripts locally (without Hadoop)
./scripts/run_wordcount.sh -t

# Clean up previous runs
./scripts/run_wordcount.sh -c

# Show help
./scripts/run_wordcount.sh -h
```

#### 3. **generate_sample_data.py** - Sample Data Generator
```bash
# Generate sample text files
python3 scripts/generate_sample_data.py
```

**Generated files:**
- `small_document.txt` (~500 words, ~100 unique words)
- `medium_document.txt` (~2000 words, ~300 unique words)  
- `large_document.txt` (~5000 words, ~500 unique words)
- `technical_document.txt` (~1500 words, ~200 unique words)

### Python Scripts

#### **mapper.py** - Mapper Implementation
- Reads input text line by line from stdin
- Tokenizes each line into words (removes punctuation)
- Converts to lowercase
- Emits key-value pairs: `word<TAB>1`

#### **reducer.py** - Reducer Implementation
- Reads sorted key-value pairs from stdin
- Aggregates counts for each word
- Emits final word count: `word<TAB>total_count`

### Manual Execution (Advanced)

If you prefer manual execution:

```bash
# Basic execution
hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar \
    -file src/python/mapper.py -mapper mapper.py \
    -file src/python/reducer.py -reducer reducer.py \
    -input /user/$(whoami)/input \
    -output /user/$(whoami)/output

# With specific number of reducers
hadoop jar $HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar \
    -D mapreduce.job.reduces=2 \
    -D mapreduce.job.name="WordCount_2reducers" \
    -file src/python/mapper.py -mapper mapper.py \
    -file src/python/reducer.py -reducer reducer.py \
    -input /user/$(whoami)/input \
    -output /user/$(whoami)/output_2reducers
```

---

## 📊 Results and Analysis

### Viewing Results
```bash
# View results for single reducer
./scripts/run_wordcount.sh -r 1

# View results for multiple reducers
./scripts/run_wordcount.sh -r 2
./scripts/run_wordcount.sh -r 4
```

### Manual Result Access
```bash
# List output files
hdfs dfs -ls /user/$(whoami)/output_1reducers/

# View first 20 most frequent words
hdfs dfs -cat /user/$(whoami)/output_1reducers/part-r-* | sort -k2 -nr | head -20

# Count total unique words
hdfs dfs -cat /user/$(whoami)/output_1reducers/part-r-* | wc -l

# Download results to local filesystem
hdfs dfs -get /user/$(whoami)/output_1reducers ./results/
```

### Performance Analysis Results

After running `./scripts/run_wordcount.sh -p`, you'll get:

1. **Execution Times**: Logged in `results/execution_times.log`
2. **Output Files**: Downloaded to `results/output_*reducers/`
3. **Performance Summary**: Displayed in terminal

**Expected Performance Characteristics:**
- **1 Reducer**: Slower but single output file
- **2 Reducers**: Faster processing, 2 output files
- **4 Reducers**: Fastest processing, 4 output files

### Sample Output Format
```
apple    145
hadoop   89
data     67
big      45
the      1234
and      987
```

---

## Project Structure

```
hadoop-mapreduce-wordcount/
├── README.md                       # This file
├── src/
│   └── python/
│       ├── mapper.py               # Python mapper script
│       └── reducer.py              # Python reducer script
├── scripts/
│   ├── setup_environment.sh        # Environment setup script
│   ├── run_wordcount.sh            # WordCount execution script
│   └── generate_sample_data.py     # Sample data generator
├── data/
│   ├── README.md                   # Data documentation
│   └── sample_texts/               # Sample input files
│       ├── small_document.txt
│       ├── medium_document.txt
│       ├── large_document.txt
│       └── technical_document.txt
├── results/                        # Local copies of results
│   ├── execution_times.log         # Performance analysis results
│   └── output_*/                   # Downloaded HDFS results
└── docs/
    ├── Report_MapReduce_WordCount.pdf
    └── Video_Presentation_Link.txt
```

---

## Troubleshooting Guide

### Common Issues and Solutions

#### 1. **Hadoop Services Not Running**
```bash
# Check if services are running
jps

# If NameNode/DataNode not running:
start-dfs.sh

# If still issues, format namenode (CAUTION: deletes all HDFS data)
hdfs namenode -format
```

#### 2. **Permission Denied Errors**
```bash
# Make scripts executable
chmod +x scripts/*.sh
chmod +x src/python/*.py

# Check HDFS permissions
hdfs dfs -ls /user/$(whoami)/
```

#### 3. **Output Directory Already Exists**
```bash
# Remove existing output directory
hdfs dfs -rm -r /user/$(whoami)/output_1reducers

# Or use cleanup script
./scripts/run_wordcount.sh -c
```

#### 4. **Python Script Errors**
```bash
# Test scripts locally first
./scripts/run_wordcount.sh -t

# Check Python version
python3 --version

# Verify script syntax
python3 -m py_compile src/python/mapper.py
python3 -m py_compile src/python/reducer.py
```

#### 5. **No Input Files**
```bash
# Generate sample data
python3 scripts/generate_sample_data.py

# Upload to HDFS
hdfs dfs -put data/sample_texts/*.txt /user/$(whoami)/input/
```

### Debug Commands
```bash
# Check Hadoop logs
hadoop logs -applicationId application_xxxxx

# Check HDFS health
hdfs fsck /

# Monitor job progress
yarn application -list

# Check available resources
yarn node -list
```

### Performance Optimization Tips

1. **Adjust Input Split Size**
   ```bash
   -D mapreduce.input.fileinputformat.split.maxsize=134217728
   ```

2. **Enable Combiner** (Add to mapper.py)
   ```python
   # Use reducer as combiner for better performance
   ```

3. **Optimize Reducer Count**
   ```bash
   # Rule of thumb: 0.95 * (nodes * mapreduce.tasktracker.reduce.tasks.maximum)
   -D mapreduce.job.reduces=2
   ```

4. **Memory Settings**
   ```bash
   -D mapreduce.map.memory.mb=1024
   -D mapreduce.reduce.memory.mb=2048
   ```

---

## MapReduce Flow Overview

### 1. **Map Phase**
- Input text files are split into lines
- Each line is tokenized into words
- Mapper emits key-value pairs: (word, 1)

### 2. **Shuffle and Sort Phase**
- Framework groups all values by key
- Data is partitioned and sorted
- Combiner (if used) performs local aggregation

### 3. **Reduce Phase**
- Reducer receives grouped data: (word, [1, 1, 1, ...])
- Sums up all values for each word
- Outputs final count: (word, total_count)

---
