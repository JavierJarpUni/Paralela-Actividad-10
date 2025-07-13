#!/usr/bin/env python3
"""
Hadoop MapReduce WordCount - Mapper Script
Author: Student Name
Date: July 2025
Course: Big Data with Hadoop MapReduce

This script implements the Mapper phase of the WordCount MapReduce job.
It reads input text line by line from stdin, tokenizes each line into words,
and emits key-value pairs in the format: word<TAB>1
"""

import sys
import re

def main():
    """
    Main mapper function that processes input from stdin
    and emits word counts to stdout
    """
    
    # Process each line from standard input
    for line in sys.stdin:
        # Remove leading/trailing whitespace and convert to lowercase
        line = line.strip().lower()
        
        # Skip empty lines
        if not line:
            continue
            
        # Remove punctuation and split into words
        # This regex keeps only alphanumeric characters and spaces
        words = re.findall(r'[a-zA-Z0-9]+', line)
        
        # Emit each word with count of 1
        for word in words:
            # Skip empty words and very short words (optional)
            if len(word) > 0:
                # Output format: word<TAB>1
                print(f"{word}\t1")

if __name__ == "__main__":
    main()