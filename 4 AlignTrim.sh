# This should be run from the directory containing the Hybpiper outputs in FNA format and the subset files.

for recoveryfile in *PercentRecovery* # For each treefolder
do
Tempname="${recoveryfile%PercentRecovery*}"
Folder="${Tempname}TreeFolder"

for file in ../$Folder/*.FNA; # For each FNA file in that folder
do
# Align all sequences in that FNA file
mafft --auto $file > "${file%SUBSETTED*}MAFFT.FNA"
# Trim gaps which contain no information but increase time taken to construct phylogenies
trimal -in "${file%SUBSETTED*}MAFFT.FNA" -out "${file%SUBSETTED*}TRIMAL.fasta" -automated1
done

done

# The output will be a series of files ending TRIMAL.fasta
