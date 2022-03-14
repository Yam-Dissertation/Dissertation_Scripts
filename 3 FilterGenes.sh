# RUN THIS FROM THE FOLDER CONTAINING FNA FILES

for recoveryfile in *PercentRecovery*
do
Tempname="${recoveryfile%PercentRecovery*}"
Newfolder="${Tempname}TreeFolder"
GenesFilter="${Tempname}SubsettedGenes.txt"
SpeciesFilter="${Tempname}SubsettedSpecies.txt"

dos2unix $GenesFilter
mkdir ../$Newfolder
while read -r gene;
do
cp "${gene}.FNA" ../$Newfolder/
done < $GenesFilter
done
