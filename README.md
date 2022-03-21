Dear Marker,

This repository contains the code associated with my BIOL0019 dissertation at UCL.
Please find here the scripts referenced in the "Materials and Methods" of my dissertation.

Thank you for your time.



The following is a brief step-by-step guide on using the scripts above.

Preparation:
To begin with, you should have
a) A folder containing all of these scripts within an overall project folder
b) A target capture file in FASTA format
c) A folder containing all of the paired-end sequence data in FASTQ format

Step 1: Extracting gene sequences
1. Navigate to the "0 HybPiper.sh" script in bash and open it using an editor in nano
2. Change the "test_targets.fasta" text on lines 11 and 15 to the name of the target capture file.
3. Navigate to the folder containing the paired-end sequence data.
4. Run "0 HybPiper.sh" from that folder, and it will iterate over all the genes.
5. Move the resulting FNA output files and the test_seq_lengths.txt file to a new folder in the the overall project folder using -mv. In the text here this folder is called JuanHybpiperOutput.

Step 2: Find the longest sequence in each file
1. From within this folder, run "1 LongSeqBlast.sh". These sequences can then be used in the online NCBI BLASTN tool to study gene function.

Step 3: Remove library codes and genes with a high proportion of missing data:
1. Open "2 SubsetSpecies.R" in RStudio
2. Run the SubsetbyCutoff function using te parameters for your code. Do this for each group of genes (e.g. FullConcat, Steroids, Starch) and each individual gene, as  shown in the example code.
3. Then, return to bash, and navigate to the folder containing the FNA files and run "3 FilterGenes.sh" and "3 FilterSpecies.sh" in that order.

Step 4: Aligning and Trimming FNA files and converting to FASTA.
1. From the same location, run "4 AlignTrim.sh" - This will take between 10 minutes and a couple of hours depending on how many library codes you have.

Step 5: Tree building
1. From the same location, run "5 ConcatIQTree.sh" - This can take a very long time, since treebuilding is a computationally intense process (It took mine 35 hours).

Step 6: Looking at trees and excluding further library codes and genes:
1. Open "6 TreePlotting.R" in RStudio, load in the function, and use it to visualise the trees. The additive tree will allow you to identify library codes to be excluded (i.e. long branches). The cophylogeny tree (for which you need to give two files - see function arguments), will allow you to identify incongruent genes to be removed. Both must be done manually.
2. Library codes to be removed should be written in a text file, with one on each line. Once this has been done, open "7 FurtherFiltering.R" and use the FurtherFiltering function to produce a file of library codes to be kept. Then, in bash, run "7 ImplementFurtherFiltering.sh" from the file containing the FNA files to remove these library codes from the PercentRecovery text files (which determine which library codes are removed from the fasta file(s) for each phylogeny).
3. Genes to be removed should be done so by simply removing their FNA files from the folder (move it to another location for safe storage if you wish). If necessary, comparison can be done using PAUP and a partition homogeneity test. For this you will need to use "9 CombinedNexus.py" in Python to produce the nexus file to be entered into PAUP.

Step 7: Re-run steps 3-6 until all erroneous or incongruent data has been excluded from the tree.

Step 8: Priority scores
1. For the tree of interest, manually identify the first and last library code of each clade, and enter them into an excel file with the columns [cladename, start, end]
2. You will need the literature review of all the species in the tree of interest, ordered in the same order as the tree. These should be split by clade.
3. Open "8 CalcPatristicDist.R" in RStudio and run the CalcPatristicDist function on the tree of interest using the clade codes excel file and literature review grid.
4. Open "8 DistScores.R" in Rstudio, which takes input the results from above, and produces scores for each pair of metabolite species.
5. Open "8 Score Cutoff.R" in Rstudio, and give as input each of the RankScore files from the previous step. It will output the priority scores and the cutoff threshold.

If you have any queries about using the scripts given here, please don't hesitate to reach out with questions.
