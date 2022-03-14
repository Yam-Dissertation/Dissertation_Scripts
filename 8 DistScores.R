library(reshape2)
setwd("C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\FullConcatTreeFolder\\")

DistScores <- function(Distfile, Species1, Species2, NameMatch = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Josh Info Files\\IDNameMatch.csv"){
  DistData <- read.csv(Distfile, row.names = 1)
  NamesMatch <- read.csv(NameMatch, header = T)
  for(row in 1:nrow(DistData)){
    rownames(DistData)[row] <- strsplit(rownames(DistData)[row], "_", fixed=T)[[1]][1]
  }
  # Find out which IDs correspond to those two species
  Species1IDs <- NamesMatch$ID_New[NamesMatch$Name == Species1]
  Species2IDs <- NamesMatch$ID_New[NamesMatch$Name == Species2]
  S1Match <- match(Species1IDs, rownames(DistData))
  S1Match <- S1Match[!is.na(S1Match)]
  S2Match <- match(Species2IDs, rownames(DistData))
  S2Match <- S2Match[!is.na(S2Match)]
  
  # Need to calculate an average of all combinations
  runningtotal <- 0
  for(m in 1:length(S1Match)){
    runningtotal <- runningtotal + sum(as.numeric(DistData[S1Match[m], S2Match]))
  }
  MeanDist <- runningtotal/(length(S1Match) * length(S2Match))
  Score = 1/MeanDist
  return(Score)
}

CladeDist <- function(Distancefile, 
                      NameMatch = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Josh Info Files\\IDNameMatch.csv", 
                      MetaboliteGrid, CladeName){
  Dist <- read.csv(Distancefile, row.names = 1, header = T)
  Names <- read.csv(NameMatch, header = T)
  Grid <- read.csv(MetaboliteGrid , row.names = 1, header = T)
  Grid$Treename <- NULL
  
  Grid[sapply(Grid, is.factor)] <- lapply(Grid[sapply(Grid, is.factor)], 
                                                     as.integer)

  PrioritySpecies <- rownames(Grid[rowSums(Grid[1:ncol(Grid)])==0,])
  MetaboliteSpecies <- rownames(Grid[rowSums(Grid[1:ncol(Grid)])>0,])
  print(CladeName)
  
  if(length(PrioritySpecies) == 0 || length(MetaboliteSpecies) == 0){
    print("You don't have both priority species and metabolite species")
    return("You don't have both priority species and metabolite species")
  }
  
  TiptoName <- function(tipvector){
    for(row in 1:length(tipvector)){
      tipvector[row] <- strsplit(tipvector[row], "_", fixed=T)[[1]][1] # IDs
      tipvector[row] <- Names$Name[Names$ID_New == tipvector[row]][1] # Name
    }
    return(unique(tipvector))
  }
  
  MetaboliteSpecies <- TiptoName(tipvector = MetaboliteSpecies)
  PrioritySpecies <- TiptoName(tipvector = PrioritySpecies)
  print(paste("No. Metabolite Species:", length(MetaboliteSpecies), sep = " "))
  print(paste("No. Priority Species:", length(PrioritySpecies), sep = " "))
  
  OutputTable <- data.frame(matrix(ncol = length(MetaboliteSpecies), nrow = length(PrioritySpecies), data = NA))
  rownames(OutputTable) <- PrioritySpecies
  colnames(OutputTable) <- MetaboliteSpecies
  
  for(S1 in 1:length(MetaboliteSpecies)){
    for(S2 in 1:length(PrioritySpecies)){
      OutputTable[PrioritySpecies[S2], MetaboliteSpecies[S1]] <- DistScores(Distfile = Distancefile, Species1 = MetaboliteSpecies[S1], Species2 = PrioritySpecies[S2])
    }
  }
  print(OutputTable)
  FileOutput <- paste(dirname(Distancefile), "/", "DistanceScores", CladeName, ".csv", sep = "")
  #write.csv(OutputTable, FileOutput)
  
  # Now convert into a ranked table
  RankOutput <- OutputTable
  RankOutput$Priority <- rownames(RankOutput)
  RankOutput <- melt(RankOutput, id.vars = "Priority")
  order.scores <- order(RankOutput$value, decreasing = T)
  RankOutput <- RankOutput[order.scores,]
  colnames(RankOutput) <- c("Priority Species", "Metabolite Species", "Score")
  print(RankOutput)
  RankName <- paste(dirname(Distancefile), "/", "RankScores", CladeName, ".csv", sep = "")
  write.csv(RankOutput, RankName)
}
# HIGHER SCORES = MORE PRIORITY
CladeDist(Distancefile = "DistancesAfrica.csv",
          MetaboliteGrid = "GridAfrica.csv",
          CladeName = "Africa")

Folder <-  "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\FullConcatTreeFolder"
setwd(Folder)
Distances <- list.files(Folder, pattern="\\Distances")
Distances
Grids <- list.files(Folder, pattern="\\Grid")
Grids
Names <- sort(read.csv("CladeIDsCSV.csv")$CladeName)
Names
for(j in 1:length(Names)){
  print(paste(Distances[j], Grids[j], Names[j], sep = " "))
  CladeDist(Distancefile = Distances[j],
            MetaboliteGrid = Grids[j],
            CladeName = Names[j])
}
