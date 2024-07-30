#!/bin/bash

# A script to inspect a .fasta alignment file and remove taxa with <300bp of ACGT sequence.

# Check if the input file is provided:
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_fasta> <output_fasta> <removed_samples>"
    exit 1
fi

input_fasta=$1
output_fasta=$2
removed_samples=$3

# Temporary files:
temp_fasta=$(mktemp)
filtered_fasta=$(mktemp)
removed_fasta=$(mktemp)

# Extract sequences from the input FASTA file and process them:
awk '/^>/ { if (seq) { if (acgt_count >= 300) { print header "\n" seq > "'$filtered_fasta'" } else { print header > "'$removed_fasta'" } } header = $0; seq = ""; acgt_count = 0; next } { seq = seq $0; gsub(/[^ACGT]/, "", $0); acgt_count += length($0) } END { if (acgt_count >= 100) { print header "\n" seq > "'$filtered_fasta'" } else { print header > "'$removed_fasta'" } }' "$input_fasta"

# Move filtered results to output file:
mv "$filtered_fasta" "$output_fasta"

# Report removed sequences. Strip the ">" character from the headers of removed sequences:
awk '/^>/ { print substr($0, 2) }' "$removed_fasta" > "$removed_samples"

# Clean up temporary files
rm "$removed_fasta"
