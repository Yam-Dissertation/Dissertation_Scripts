# This should be run from the directory containing the Hybpiper outputs in FNA format and the subset files.

for recoveryfile in *PercentRecovery* # For each phylogeny
do

Tempname="${recoveryfile%PercentRecovery*}"
Folder="${Tempname}TreeFolder"
ConcatOutput="${Tempname}Concat.fas"

FastaCount=$(ls -lR ../$Folder/*.fasta | wc -l) # Count the number of FASTA files in that folder
cd ../$Folder/
if [ $FastaCount -eq 1 ]; # If there is only one FASTA file (i.e. it's a single gene phylogeny)
then

iqtree -s "${Tempname}TRIMAL.fasta" -alrt 1000 -bb 1000 -nt AUTO # Run IQ-Tree

else # If there are more than one FASTA file (i.e. it's a functionally grouped tree or a full GOI/LCN tree)
mkdir TempForConcat

for file in *TRIMAL.fasta; # Copy all FASTA files into a new folder
do
cp $file TempForConcat
done

cd TempForConcat # Enter that folder

perl ../../../../Packages\ and\ Software/FASconCAT-G-master/FASconCAT-G-master/FASconCAT-G_v1.05.pl -s # Concatenate them using FASconCAT-G

mv FcC_info.xls ../"${Tempname}Concat.xls" # Move the concatenated file back to the original folder
mv FcC_supermatrix.fas ../$ConcatOutput

cd ../ # Return to the original folder

iqtree -s $ConcatOutput -alrt 1000 -bb 1000 -nt AUTO # Run IQ-Tree

rm -r TempForConcat # Remove the temporary concatination folder
fi

done

# Note: This will take a very long time, especially if you have lots of species and or genes.
# For 39 genes and 333 species this took 36 hours.
