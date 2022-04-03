# This should be run from the directory containing the Hybpiper outputs in FNA format and the subset files.

for recoveryfile in *PercentRecovery*
do
Tempname="${recoveryfile%PercentRecovery*}" # For each phylogeny
Newfolder="${Tempname}TreeFolder"
GenesFilter="${Tempname}SubsettedGenes.txt" # The name of the gene subset file for that tree

dos2unix $GenesFilter
mkdir ../$Newfolder # Make a new folder for that phylogeny
while read -r gene; # For each gene in that gene subset file
do
cp "${gene}.FNA" ../$Newfolder/ # Copy the corresponding FNA file to the new folder
done < $GenesFilter

done
