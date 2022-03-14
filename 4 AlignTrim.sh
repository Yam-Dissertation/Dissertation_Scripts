# RUN THIS FOLDER CONTAINING FNAS
for recoveryfile in *PercentRecovery*
do
Tempname="${recoveryfile%PercentRecovery*}"
Folder="${Tempname}TreeFolder"

for file in ../$Folder/*.FNA;
do
# Align
mafft --auto $file > "${file%SUBSETTED*}MAFFT.FNA"
# Trim
trimal -in "${file%SUBSETTED*}MAFFT.FNA" -out "${file%SUBSETTED*}TRIMAL.fasta" -automated1
done

done
