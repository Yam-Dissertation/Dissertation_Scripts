# Run this from the folder containing the HybPiper output files in FNA format

# Copy fna files to a new folder called BLAST
mkdir ../BLAST
for fna in *.FNA;
do
cp $fna ../BLAST
done

# Navigate to that folder
cd ../BLAST


# Linearise the sequence, add a column for length of sequence, sort by that new column, remove that column, and delinearise.
for file in *.FNA; # For each of the FNA files
do
awk '/^>/ {if(N>0) printf("\n"); printf("%s\t",$0);N++;next;} {printf("%s",$0);} END {if(N>0) printf("\n");}' $file |\
awk -F '	'  '{printf("%s\t%d\n",$0,length($2));}' |\
sort -t '	' -k 3,3nr |\
cut -f 1,2 |\
tr "\t" "\n" |\
fold -w 60 |\
awk '/^>/{if(N)exit;++N;} {print;}' > "${file%.*}Longest.fasta"
done

# Remove the original FNA file (so that only the FASTA files sorted by sequence length remain).
for file in ../BLAST/*.FNA;
do
rm $file
done

# For each of the FNA files (one for each gene), the first sequence in the FASTA file will be the longest and should be used for BLAST.
