mkdir ../BLAST

# Copy fna files to a new folder
for fna in *.FNA;
do
cp $fna ../BLAST
done

cd ../BLAST


# Linearise the sequence, add a column for length of sequence, sort by that new column, remove that column, and delinearise.
for file in *.FNA;
do
awk '/^>/ {if(N>0) printf("\n"); printf("%s\t",$0);N++;next;} {printf("%s",$0);} END {if(N>0) printf("\n");}' $file |\
awk -F '	'  '{printf("%s\t%d\n",$0,length($2));}' |\
sort -t '	' -k 3,3nr |\
cut -f 1,2 |\
tr "\t" "\n" |\
fold -w 60 |\
awk '/^>/{if(N)exit;++N;} {print;}' > "${file%.*}Longest.fasta"
done

for file in ../BLAST/*.FNA;
do
rm $file
done