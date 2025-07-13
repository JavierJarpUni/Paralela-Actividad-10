#!/bin/bash
"""
Hadoop MapReduce WordCount Execution Script
Author: Student Name
Date: July 2025
Course: Big Data with Hadoop MapReduce

This script executes the WordCount MapReduce job using Python Streaming
with different configurations for performance analysis.
"""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[HEADER]${NC} $1"
}

# Configuration
USER=$(whoami)
INPUT_DIR="/user/$USER/input"
HADOOP_STREAMING_JAR="$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-*.jar"
MAPPER_SCRIPT="src/python/mapper.py"
REDUCER_SCRIPT="src/python/reducer.py"

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Hadoop is running
    if ! jps | grep -q "NameNode\|DataNode"; then
        print_error "Hadoop services are not running. Please run ./scripts/setup_environment.sh first"
        exit 1
    fi
    
    # Check if input directory exists and has files
    if ! hdfs dfs -test -d $INPUT_DIR; then
        print_error "Input directory $INPUT_DIR does not exist"
        exit 1
    fi
    
    # Check if input directory has files
    if [ $(hdfs dfs -ls $INPUT_DIR | wc -l) -eq 0 ]; then
        print_error "No input files found in $INPUT_DIR"
        exit 1
    fi
    
    # Check if Python scripts exist
    if [ ! -f "$MAPPER_SCRIPT" ] || [ ! -f "$REDUCER_SCRIPT" ]; then
        print_error "Python scripts not found. Please ensure mapper.py and reducer.py are in src/python/"
        exit 1
    fi
    
    # Check if Hadoop Streaming JAR exists
    if ! ls $HADOOP_STREAMING_JAR 1> /dev/null 2>&1; then
        print_error "Hadoop Streaming JAR not found at $HADOOP_STREAMING_JAR"
        exit 1
    fi
    
    print_status "Prerequisites check passed"
}

# Function to run WordCount with specified number of reducers
run_wordcount() {
    local num_reducers=$1
    local output_dir="/user/$USER/output_${num_reducers}reducers"
    
    print_header "Running WordCount with $num_reducers reducer(s)"
    
    # Remove output directory if it exists
    hdfs dfs -rm -r -f $output_dir
    
    # Record start time
    start_time=$(date +%s)
    
    # Run the MapReduce job
    print_status "Executing Hadoop Streaming job..."
    
    hadoop jar $HADOOP_STREAMING_JAR \
        -D mapreduce.job.reduces=$num_reducers \
        -D mapreduce.job.name="WordCount_${num_reducers}reducers" \
        -file $MAPPER_SCRIPT -mapper mapper.py \
        -file $REDUCER_SCRIPT -reducer reducer.py \
        -input $INPUT_DIR \
        -output $output_dir
    
    # Check if job was successful
    if [ $? -eq 0 ]; then
        # Record end time
        end_time=$(date +%s)
        execution_time=$((end_time - start_time))
        
        print_status "Job completed successfully in $execution_time seconds"
        
        # Show output statistics
        print_status "Output statistics:"
        hdfs dfs -ls $output_dir
        
        # Show first few results
        print_status "First 10 words with highest counts:"
        hdfs dfs -cat $output_dir/part-r-* | sort -k2 -nr | head -10
        
        # Save execution time to log file
        echo "Reducers: $num_reducers, Execution Time: $execution_time seconds" >> results/execution_times.log
        
        return 0
    else
        print_error "Job failed with $num_reducers reducer(s)"
        return 1
    fi
}

# Function to run performance analysis
run_performance_analysis() {
    print_header "Starting Performance Analysis"
    
    # Create results directory
    mkdir -p results
    
    # Clear previous results
    > results/execution_times.log
    
    # Array of reducer counts for testing
    reducer_counts=(1 2 4)
    
    for reducers in "${reducer_counts[@]}"; do
        print_status "Performance test $reducers of ${#reducer_counts[@]}"
        
        if run_wordcount $reducers; then
            print_status "Test with $reducers reducer(s) completed successfully"
        else
            print_error "Test with $reducers reducer(s) failed"
            continue
        fi
        
        # Wait a moment between tests
        sleep 2
    done
    
    print_header "Performance Analysis Complete"
    print_status "Results saved to results/execution_times.log"
    
    # Display summary
    if [ -f "results/execution_times.log" ]; then
        print_status "Execution Time Summary:"
        cat results/execution_times.log
    fi
}

# Function to display results
show_results() {
    local num_reducers=${1:-1}
    local output_dir="/user/$USER/output_${num_reducers}reducers"
    
    print_header "Results for $num_reducers reducer(s)"
    
    if hdfs dfs -test -d $output_dir; then
        print_status "Total word count (unique words):"
        hdfs dfs -cat $output_dir/part-r-* | wc -l
        
        print_status "Top 20 most frequent words:"
        hdfs dfs -cat $output_dir/part-r-* | sort -k2 -nr | head -20
        
        print_status "Sample of less frequent words:"
        hdfs dfs -cat $output_dir/part-r-* | sort -k2 -n | head -10
        
        # Download results to local filesystem
        print_status "Downloading results to local filesystem..."
        hdfs dfs -get $output_dir results/output_${num_reducers}reducers
        print_status "Results downloaded to results/output_${num_reducers}reducers/"
    else
        print_error "Output directory $output_dir not found"
    fi
}

# Function to clean up previous runs
cleanup() {
    print_status "Cleaning up previous runs..."
    hdfs dfs -rm -r -f /user/$USER/output_*
    rm -rf results/output_*
    print_status "Cleanup completed"
}

# Function to test locally (without Hadoop)
test_locally() {
    print_header "Testing Python scripts locally"
    
    # Create test input
    echo -e "hello world\nhello hadoop\nworld of big data" > /tmp/test_input.txt
    
    # Test mapper
    print_status "Testing mapper..."
    cat /tmp/test_input.txt | python3 $MAPPER_SCRIPT | head -10
    
    # Test full pipeline
    print_status "Testing full pipeline..."
    cat /tmp/test_input.txt | python3 $MAPPER_SCRIPT | sort | python3 $REDUCER_SCRIPT
    
    # Cleanup
    rm -f /tmp/test_input.txt
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTION]"
    echo "Options:"
    echo "  -s, --single          Run WordCount with single reducer"
    echo "  -p, --performance     Run performance analysis with 1, 2, and 4 reducers"
    echo "  -r, --results [NUM]   Show results for specified number of reducers (default: 1)"
    echo "  -c, --cleanup         Clean up previous runs"
    echo "  -t, --test            Test Python scripts locally"
    echo "  -h, --help            Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -s                 # Run with single reducer"
    echo "  $0 -p                 # Run performance analysis"
    echo "  $0 -r 2               # Show results for 2 reducers"
}

# Main script logic
main() {
    case "$1" in
        -s|--single)
            check_prerequisites
            run_wordcount 1
            ;;
        -p|--performance)
            check_prerequisites
            run_performance_analysis
            ;;
        -r|--results)
            local num_reducers=${2:-1}
            show_results $num_reducers
            ;;
        -c|--cleanup)
            cleanup
            ;;
        -t|--test)
            test_locally
            ;;
        -h|--help)
            show_usage
            ;;
        "")
            print_status "No option provided. Running single reducer WordCount..."
            check_prerequisites
            run_wordcount 1
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"