# Sample Text Data

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
