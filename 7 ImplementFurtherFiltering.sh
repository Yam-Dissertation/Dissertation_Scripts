# Run this from the folder containing the original HybPiper FNA outputs
# This does a very similar thing to 3 SubsetSpecies.sh, but with an updated dataset.

SamplesFilter=SamplesKeep4.txt # The final updated sample subset txt file, with one library code on each line.

for recoveryfile in *PercentRecovery* # For each phylogeny folder
do
Tempname="${recoveryfile%PercentRecovery*}"
Folder="${Tempname}TreeFolder"

dos2unix $SamplesFilter
for file in ../$Folder/*SUBSETTED.FNA; # For each FNA file in that phylogeny folder
do
awk '{ if (NR==1) { printf("%s", $0); } else if ((NR>1)&&($0~/^>/)) { printf("\n%s", $0); } else {printf("\t%s", $0); } }' $file > "${file%.*}FIRST.FNA" # Firstly linearise the sequences
grep -Ff $SamplesFilter "${file%.*}FIRST.FNA" > "${file%.*}SECOND.FNA" # Then keep only those matching in the library codes file
tr "\t" "\n" < "${file%.*}SECOND.FNA" > "${file%.*}Further.FNA" # Then delinearise the sequences
done

# Remove intermediate files
rm -r ../$Folder/*FIRST*
rm -r ../$Folder/*SECOND*
rm -r ../$Folder/*SUBSETTED.FNA*

done
