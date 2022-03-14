# RUN THIS FROM THE SUBSETTED FOLDER

for recoveryfile in *PercentRecovery*
do

Tempname="${recoveryfile%PercentRecovery*}"
Folder="${Tempname}TreeFolder"
ConcatOutput="${Tempname}Concat.fas"

FastaCount=$(ls -lR ../$Folder/*.fasta | wc -l)
cd ../$Folder/
if [ $FastaCount -eq 1 ];
then

iqtree -s "${Tempname}TRIMAL.fasta" -alrt 1000 -bb 1000 -nt AUTO

else
mkdir TempForConcat

for file in *TRIMAL.fasta;
do
cp $file TempForConcat
done

cd TempForConcat

perl ../../../../Packages\ and\ Software/FASconCAT-G-master/FASconCAT-G-master/FASconCAT-G_v1.05.pl -s

mv FcC_info.xls ../"${Tempname}Concat.xls"
mv FcC_supermatrix.fas ../$ConcatOutput

cd ../

iqtree -s $ConcatOutput -alrt 1000 -bb 1000 -nt AUTO

rm -r TempForConcat
fi

done
