# RUN THIS FROM THE FOLDER CONTAINING FNA FILES

for recoveryfile in *PercentRecovery*
do
Tempname="${recoveryfile%PercentRecovery*}"
Folder="${Tempname}TreeFolder"
SamplesFilter="${Tempname}SubsettedSpecies.txt"
GenesFilter="${Tempname}SubsettedGenes.txt"

dos2unix $SamplesFilter

for file in ../$Folder/*.FNA;
do
awk '{ if (NR==1) { printf("%s", $0); } else if ((NR>1)&&($0~/^>/)) { printf("\n%s", $0); } else {printf("\t%s", $0); } }' $file > "${file%.*}FIRST.FNA" # Firstly linearise the sequences
grep -Ff $SamplesFilter "${file%.*}FIRST.FNA" > "${file%.*}SECOND.FNA" # Then keep only those matching in the file
tr "\t" "\n" < "${file%.*}SECOND.FNA" > "${file%.*}SUBSETTED.FNA" # Then delinearise the sequences
done

rm -r ../$Folder/*FIRST*
rm -r ../$Folder/*SECOND*
find ../$Folder/ -type f ! -name '*SUBSETTED.FNA' -delete

cp NameMatchFinal.csv ../$Folder/
cp $recoveryfile ../$Folder/
cp -r Final\ Scripts ../$Folder/
cp $GenesFilter ../$Folder/
cp $SamplesFilter ../$Folder/

done
