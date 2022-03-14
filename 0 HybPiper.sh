#!/bin/bash

for file in *.fastq;
do
echo "${file%.*}"
done > namelist.txt

while read name;
do
full="${name}".fastq
python ../Packages/HybPiper/reads_first.py --cpu 1 -b test_targets.fasta -r $full --prefix $name --bwa
#python ../Packages/HybPiper/cleanup.py $name
done < namelist.txt

#hybpiper get_seq_lengths test_targets.fasta namelist.txt dna > test_seq_lengths.txt

# In order to view these plots, need to open files in RStudio with gplots and heatmap.plus packages installed

hybpiper stats test_seq_lengths.txt namelist.txt > test_stats.txt

hybpiper retrieve_sequences test/targets.fasta . dna

