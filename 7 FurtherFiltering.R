# This requires you to have a text file with IDs to remove on each line.
# This must be created manually by looking at the file (to identify particularly long branches with low gene percentage recovery).
# This should be iterated several times, since removing IDs changes the tree topology, leading to the identification of new erroneous IDs.

FurtherFiltering <- function(wd, filetoedit, toberemoved, output, namematch=NULL){
  setwd(wd)
  OldKeep <- read.table(filetoedit)[,1]
  print(paste("Original Number: ", length(OldKeep), sep = ""))
  ToRemove <- read.table(toberemoved)[,1]
  
  if(!is.null(namematch)){ # This assumes that the SamplesFilter file has IDs of an old format and an updated format.
    NameTable <- read.csv(namematch) # Read in data
    print(paste("Number with no New ID : ", length(ToRemove[!(ToRemove %in% NameTable[,1])]), sep = ""))
    print(paste("These are: ", ToRemove[!(ToRemove %in% NameTable[,1])]), sep = "")
    ToRemove <- sort(ToRemove[ToRemove %in% NameTable[,1]])
    print(paste("Number to be removed: ", length(ToRemove), sep = ""))
    print(NameTable$ID[match(ToRemove, NameTable$ID)])
    NewIDRemove <- NameTable$ID_New[match(ToRemove, NameTable$ID)]
    SamplesKeep <- OldKeep[!(OldKeep %in% NewIDRemove)]
    print(paste("Number of matches: ", length(OldKeep[(OldKeep %in% NewIDRemove)])), sep = "")
    print(paste("Updated Number: ", length(SamplesKeep), sep = ""))
    
  } else {
    ToRemove <- sort(ToRemove)
    print(paste("Number to be removed: ", length(ToRemove), sep = ""))
    SamplesKeep <- OldKeep[!(OldKeep %in% ToRemove)]
    print(paste("Updated Number: ", length(SamplesKeep), sep = ""))
  }
  write.table(SamplesKeep, file=output, col.names = F, row.names = F, quote = F)
}



# Initial and largest filtering from Juan's Tree
FurtherFiltering(wd = "E:\\BIOL0019\\Working Directory\\hybpiper\\JuanHybPiperOutput",
                 filetoedit = "SubsettedSpecies.txt",
                 toberemoved = "SamplesFilter1.txt",
                 output = "SamplesKeep1.txt",
                 namematch="NameMatch.csv")

# Second smaller filtering from Juan's tree
FurtherFiltering(wd = "E:\\BIOL0019\\Working Directory\\hybpiper\\JuanHybPiperOutput",
                 filetoedit = "SamplesKeep1.txt",
                 toberemoved = "SamplesFilter2.txt",
                 output = "SamplesKeep2.txt",
                 namematch="NameMatch.csv")

# Third filtering from Juan's tree
FurtherFiltering(wd = "E:\\BIOL0019\\Working Directory\\hybpiper\\JuanHybPiperOutput",
                 filetoedit = "SamplesKeep2.txt",
                 toberemoved = "SamplesFilter3.txt",
                 output = "SamplesKeep3.txt",
                 namematch="NameMatch.csv")

# Final filtering to make files match
FurtherFiltering(wd = "E:\\BIOL0019\\Working Directory\\hybpiper\\JuanHybPiperOutput",
                 filetoedit = "SamplesKeep3.txt",
                 toberemoved = "SamplesFilter4.txt",
                 output = "SamplesKeep4.txt",
                 namematch="NameMatch.csv")
