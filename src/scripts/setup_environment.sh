#!/bin/bash
# Hadoop Environment Setup Script
# Author: Student Name
# Date: July 2025
# Course: Big Data with Hadoop MapReduce

# This script sets up the Hadoop environment for the WordCount MapReduce job.
# It creates necessary HDFS directories and prepares the environment.

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if Hadoop is installed and configured
check_hadoop() {
    print_status "Checking Hadoop installation..."
    
    if ! command -v hadoop &> /dev/null; then
        print_error "Hadoop is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v hdfs &> /dev/null; then
        print_error "HDFS is not installed or not in PATH"
        exit 1
    fi
    
    print_status "Hadoop installation verified"
    hadoop version | head -1
}

# Start Hadoop services
start_hadoop_services() {
    print_status "Starting Hadoop services..."
    
    # Check if services are already running
    if jps | grep -q "NameNode\|DataNode"; then
        print_warning "Hadoop services appear to be already running"
    else
        print_status "Starting HDFS..."
        start-dfs.sh
        
        # Wait a moment for services to start
        sleep 5
        
        # Verify services are running
        if ! jps | grep -q "NameNode"; then
            print_error "Failed to start NameNode"
            exit 1
        fi
        
        if ! jps | grep -q "DataNode"; then
            print_error "Failed to start DataNode"
            exit 1
        fi
        
        print_status "Hadoop services started successfully"
    fi
}

# Create HDFS directories
setup_hdfs_directories() {
    print_status "Setting up HDFS directories..."
    
    # Get current user
    USER=$(whoami)
    
    # Create user directory if it doesn't exist
    hdfs dfs -mkdir -p /user/$USER
    
    # Create input directory
    hdfs dfs -mkdir -p /user/$USER/input
    
    # Create output directory (will be removed before each job)
    hdfs dfs -mkdir -p /user/$USER/output
    
    # Remove any existing output directories from previous runs
    hdfs dfs -rm -r -f /user/$USER/output_*
    
    print_status "HDFS directories created successfully"
    
    # Show directory structure
    print_status "Current HDFS directory structure:"
    hdfs dfs -ls /user/$USER/
}

# Upload sample data
upload_sample_data() {
    print_status "Uploading sample data to HDFS..."
    
    # Check if sample data exists
    if [ -d "data/sample_texts" ]; then
        # Upload all text files
        hdfs dfs -put data/sample_texts/*.txt /user/$(whoami)/input/
        print_status "Sample data uploaded successfully"
        
        # Show uploaded files
        print_status "Files in HDFS input directory:"
        hdfs dfs -ls /user/$(whoami)/input/
    else
        print_warning "Sample data directory not found. Please create data/sample_texts/ and add your text files."
        print_warning "You can upload your own text files using:"
        print_warning "hdfs dfs -put /path/to/your/textfiles/*.txt /user/$(whoami)/input/"
    fi
}

# Make Python scripts executable
setup_python_scripts() {
    print_status "Setting up Python scripts..."
    
    # Make scripts executable
    chmod +x src/python/mapper.py
    chmod +x src/python/reducer.py
    
    # Verify Python scripts
    if [ ! -f "src/python/mapper.py" ]; then
        print_error "mapper.py not found in src/python/"
        exit 1
    fi
    
    if [ ! -f "src/python/reducer.py" ]; then
        print_error "reducer.py not found in src/python/"
        exit 1
    fi
    
    print_status "Python scripts are ready"
}

# Main execution
main() {
    print_status "Starting Hadoop MapReduce WordCount environment setup..."
    
    check_hadoop
    start_hadoop_services
    setup_hdfs_directories
    setup_python_scripts
    upload_sample_data
    
    print_status "Environment setup completed successfully!"
    print_status "You can now run the WordCount job using:"
    print_status "./scripts/run_wordcount.sh"
}

# Run main function
main "$@"