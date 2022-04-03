# This should be run from the directory containing the Hybpiper outputs in FNA format and the subset files.

for recoveryfile in *PercentRecovery*
do
Tempname="${recoveryfile%PercentRecovery*}" # For each Treefolder
Folder="${Tempname}TreeFolder"
SamplesFilter="${Tempname}SubsettedSpecies.txt"

dos2unix $SamplesFilter

for file in ../$Folder/*.FNA; # For each FNA file
do
awk '{ if (NR==1) { printf("%s", $0); } else if ((NR>1)&&($0~/^>/)) { printf("\n%s", $0); } else {printf("\t%s", $0); } }' $file > "${file%.*}FIRST.FNA" # Firstly linearise the sequences
grep -Ff $SamplesFilter "${file%.*}FIRST.FNA" > "${file%.*}SECOND.FNA" # Then keep only those matching in the file
tr "\t" "\n" < "${file%.*}SECOND.FNA" > "${file%.*}SUBSETTED.FNA" # Then delinearise the sequences
done

# Remove intermediate and outdated files
rm -r ../$Folder/*FIRST*
rm -r ../$Folder/*SECOND*
find ../$Folder/ -type f ! -name '*SUBSETTED.FNA' -delete

# Copy a number of useful files into the tree folder (if they are modified elsewhere later, these files will reflect their state at the time of folder creation)
cp NameMatchFinal.csv ../$Folder/
cp $recoveryfile ../$Folder/
cp -r Final\ Scripts ../$Folder/
cp $GenesFilter ../$Folder/
cp $SamplesFilter ../$Folder/

done
