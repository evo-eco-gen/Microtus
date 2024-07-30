#!/bin/bash

# A script to loop missing data trimming over several alignments.

# Directories for input files and output files:
input_dir=""
output_dir="./filtered_alignments"
removed_samples_dir="./removed_gappy_samples"

# Ensure output directories exist:
mkdir -p "$output_dir"
mkdir -p "$removed_samples_dir"

# Loop through each FASTA file in the input directory:
for input_file in "$input_dir"/*.fas; do
    # Extract the base name (without directory and extension):
    base_name=$(basename "$input_file" .fas)
    
    # Define output file paths:
    output_file="$output_dir/${base_name}_300bb_filtered.fasta"
    removed_samples_file="$removed_samples_dir/${base_name}_removed.txt"
    
    # Run the filter and report script:
    ./trim_missing_data.sh "$input_file" "$output_file" "$removed_samples_file"
done