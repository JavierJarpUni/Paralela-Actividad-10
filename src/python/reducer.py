#!/usr/bin/env python3
"""
Hadoop MapReduce WordCount - Reducer Script
Author: Student Name
Date: July 2025
Course: Big Data with Hadoop MapReduce

This script implements the Reducer phase of the WordCount MapReduce job.
It reads key-value pairs from stdin (sorted by key), aggregates counts
for each word, and emits the final word count.
"""

import sys
from collections import defaultdict

def main():
    """
    Main reducer function that processes sorted key-value pairs
    and emits aggregated word counts
    """
    
    current_word = None
    current_count = 0
    
    # Process each line from standard input
    for line in sys.stdin:
        # Remove leading/trailing whitespace
        line = line.strip()
        
        # Skip empty lines
        if not line:
            continue
            
        # Parse the key-value pair (word<TAB>count)
        try:
            word, count = line.split('\t')
            count = int(count)
        except ValueError:
            # Skip malformed lines
            continue
        
        # If this is the same word as the previous one, add to count
        if current_word == word:
            current_count += count
        else:
            # If we have a previous word, emit its total count
            if current_word is not None:
                print(f"{current_word}\t{current_count}")
            
            # Start counting the new word
            current_word = word
            current_count = count
    
    # Don't forget to emit the last word's count
    if current_word is not None:
        print(f"{current_word}\t{current_count}")

if __name__ == "__main__":
    main()