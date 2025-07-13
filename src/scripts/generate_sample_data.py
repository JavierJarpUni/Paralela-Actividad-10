#!/usr/bin/env python3
"""
Sample Text Data Generator
Author: Student Name
Date: July 2025
Course: Big Data with Hadoop MapReduce

This script generates sample text files for testing the WordCount MapReduce job.
It creates realistic text data with varying word frequencies for meaningful analysis.
"""

import os
import random
import string

def generate_sample_text(word_count=1000, unique_words=200):
    """
    Generate sample text with specified word count and vocabulary size
    
    Args:
        word_count: Total number of words to generate
        unique_words: Number of unique words in vocabulary
    
    Returns:
        String containing generated text
    """
    
    # Common English words for more realistic text
    common_words = [
        'the', 'and', 'to', 'of', 'a', 'in', 'is', 'it', 'you', 'that',
        'he', 'was', 'for', 'on', 'are', 'as', 'with', 'his', 'they', 'i',
        'be', 'at', 'one', 'have', 'this', 'from', 'or', 'had', 'by', 'word',
        'but', 'not', 'what', 'all', 'were', 'we', 'when', 'your', 'can', 'said',
        'there', 'each', 'which', 'she', 'do', 'how', 'their', 'if', 'will', 'up',
        'data', 'big', 'hadoop', 'mapreduce', 'distributed', 'computing', 'cluster',
        'processing', 'storage', 'analysis', 'algorithm', 'framework', 'system',
        'database', 'technology', 'information', 'computer', 'science', 'software',
        'development', 'programming', 'java', 'python', 'stream', 'batch', 'real',
        'time', 'performance', 'scalability', 'fault', 'tolerance', 'networking'
    ]
    
    # Generate additional random words to reach desired unique word count
    additional_words = []
    for _ in range(max(0, unique_words - len(common_words))):
        word_length = random.randint(4, 8)
        word = ''.join(random.choices(string.ascii_lowercase, k=word_length))
        additional_words.append(word)
    
    # Combine all words
    all_words = common_words + additional_words
    
    # Create weighted distribution (some words appear more frequently)
    word_weights = []
    for i, word in enumerate(all_words):
        if i < len(common_words):
            # Common words have higher weight
            weight = max(1, 100 - i * 2)
        else:
            # Additional words have lower weight
            weight = random.randint(1, 10)
        word_weights.append(weight)
    
    # Generate text
    generated_words = random.choices(all_words, weights=word_weights, k=word_count)
    
    # Format into sentences and paragraphs
    text_lines = []
    words_per_line = 10
    
    for i in range(0, len(generated_words), words_per_line):
        line_words = generated_words[i:i+words_per_line]
        line = ' '.join(line_words)
        # Capitalize first word and add period
        line = line.capitalize() + '.'
        text_lines.append(line)
    
    return '\n'.join(text_lines)

def create_sample_files():
    """
    Create multiple sample text files with different characteristics
    """
    
    # Create data directory
    data_dir = "data/sample_texts"
    os.makedirs(data_dir, exist_ok=True)
    
    # File configurations
    files_config = [
        {
            'name': 'small_document.txt',
            'word_count': 500,
            'unique_words': 100,
            'description': 'Small document with limited vocabulary'
        },
        {
            'name': 'medium_document.txt',
            'word_count': 2000,
            'unique_words': 300,
            'description': 'Medium-sized document with moderate vocabulary'
        },
        {
            'name': 'large_document.txt',
            'word_count': 5000,
            'unique_words': 500,
            'description': 'Large document with extensive vocabulary'
        },
        {
            'name': 'technical_document.txt',
            'word_count': 1500,
            'unique_words': 200,
            'description': 'Technical document with specialized terms'
        }
    ]
    
    # Generate files
    for config in files_config:
        print(f"Generating {config['name']}...")
        
        # Generate text
        text = generate_sample_text(config['word_count'], config['unique_words'])
        
        # Add header comment
        header = f"# {config['description']}\n# Generated for Hadoop MapReduce WordCount assignment\n# Word count: ~{config['word_count']}, Unique words: ~{config['unique_words']}\n\n"
        
        # Write to file
        file_path = os.path.join(data_dir, config['name'])
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(header + text)
        
        print(f"  Created: {file_path}")
        print(f"  Size: {os.path.getsize(file_path)} bytes")
        print()

def create_readme_for_data():
    """
    Create README file for the data directory
    """
    
    readme_content = """# Sample Text Data

This directory contains sample text files generated for the Hadoop MapReduce WordCount assignment.

## Files

- `small_document.txt`: Small document (~500 words, ~100 unique words)
- `medium_document.txt`: Medium document (~2000 words, ~300 unique words)
- `large_document.txt`: Large document (~5000 words, ~500 unique words)
- `technical_document.txt`: Technical document (~1500 words, ~200 unique words)

## Usage

These files are automatically uploaded to HDFS when you run the setup script:

```bash
./scripts/setup_environment.sh
```

Or you can manually upload them:

```bash
hdfs dfs -put data/sample_texts/*.txt /user/$(whoami)/input/
```

## Adding Your Own Data

You can add your own text files to this directory. Supported formats:
- Plain text files (.txt)
- UTF-8 encoding
- Any size (larger files will provide more interesting results)

## File Statistics

After running the WordCount job, you can analyze the word distribution:

```bash
# View results
hdfs dfs -cat /user/$(whoami)/output/part-r-* | head -20

# Count unique words
hdfs dfs -cat /user/$(whoami)/output/part-r-* | wc -l

# Find most frequent words
hdfs dfs -cat /user/$(whoami)/output/part-r-* | sort -k2 -nr | head -10
```
"""
    
    with open("data/README.md", 'w', encoding='utf-8') as f:
        f.write(readme_content)
    
    print("Created data/README.md")

def main():
    """
    Main function to generate all sample data
    """
    
    print("Generating sample text data for Hadoop MapReduce WordCount...")
    print("=" * 60)
    
    create_sample_files()
    create_readme_for_data()
    
    print("=" * 60)
    print("Sample data generation completed!")
    print()
    print("Next steps:")
    print("1. Run: ./scripts/setup_environment.sh")
    print("2. Run: ./scripts/run_wordcount.sh -p")
    print("3. View results: ./scripts/run_wordcount.sh -r 1")

if __name__ == "__main__":
    main()