# RUN THIS FROM THE FOLDER CONTAINING FNA FILES AND FURTHER FILTERING OUTPUT

SamplesFilter=SamplesKeep4.txt

for recoveryfile in *PercentRecovery*
do
Tempname="${recoveryfile%PercentRecovery*}"
Folder="${Tempname}TreeFolder"

dos2unix $SamplesFilter
for file in ../$Folder/*SUBSETTED.FNA;
do
awk '{ if (NR==1) { printf("%s", $0); } else if ((NR>1)&&($0~/^>/)) { printf("\n%s", $0); } else {printf("\t%s", $0); } }' $file > "${file%.*}FIRST.FNA" # Firstly linearise the sequences
grep -Ff $SamplesFilter "${file%.*}FIRST.FNA" > "${file%.*}SECOND.FNA" # Then keep only those matching in the file
tr "\t" "\n" < "${file%.*}SECOND.FNA" > "${file%.*}Further.FNA" # Then delinearise the sequences
done

rm -r ../$Folder/*FIRST*
rm -r ../$Folder/*SECOND*
rm -r ../$Folder/*SUBSETTED.FNA*

done
