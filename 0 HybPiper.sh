#!/bin/bash

# Run this file from the directory containing paired end sequence output.
# It assumes that the HybPiper python scripts are stored in ../Packages/HybPiper/

for file in *.fastq; # Loops through all paired end sequence files in the current directory
do
echo "${file%.*}"
done > namelist.txt # Writes the file prefixes to a list

while read name; # For each of the file prefixes in that list
do
full="${name}".fastq # The full filename is stored
python ../Packages/HybPiper/reads_first.py --cpu 1 -b target_genes.fasta -r $full --prefix $name --bwa # Gene extraction of the target genes is undertaken in that file
python ../Packages/HybPiper/cleanup.py $name # Optional line to clean up the many files that HybPiper produces
done < namelist.txt

python ../Packages/HybPiper/get_seq_lengths.py test_targets.fasta namelist.txt dna > test_seq_lengths.txt # The gene recovery percentages which are used to identify extraction failure

# In order to view these plots, need to open files in RStudio with gplots and heatmap.plus packages installed

python ../Packages/HybPiper/stats.py test_seq_lengths.txt namelist.txt > test_stats.txt # Optional line to produce series of summary statistics about the data

python ../Packages/HybPiper/retrieve_sequences.py test/targets.fasta . dna # Retrieves the sequences for the same gene for many samples and generates an unaligned multi-FASTA file

# These FASTA or FNA files becomes the input for the next stage.
