library(ape)
library(adephylo)
library(phytools)
CalcPatristicDist <- function(wd, tree, clades, grid){
  setwd(wd)
  Tree <- read.tree(file = tree)
  Tree <- force.ultrametric(Tree, method="nnls")
  DistancesPatristic <- as.data.frame(as.matrix(distTips(Tree, tips = "all", method = "patristic")))
  CladeVals <- read.csv(clades)
  Grid <- read.csv(grid)
  Grid <- apply(Grid, 2, rev)
  Gric <- as.data.frame(Grid)
  
  IDsinTree <- NULL
  for(ID in 1:length(Tree$tip.label)){
    IDsinTree[ID] <- strsplit(Tree$tip.label, split = "_", fixed = T)[[ID]][1] # The ID
  }
  
  for(row in 1:nrow(CladeVals)){
    Cladename <- CladeVals$CladeName[row]
    Values <- match(c(CladeVals$Start[row], CladeVals$End[row]), IDsinTree)
    CladePatristicDist <- DistancesPatristic[Values[1]:Values[2], Values[1]:Values[2]]
    CladeGrid <- Grid[Values[1]:Values[2],]
    OutName <- paste("Distances", strsplit(Cladename, ".", fixed=T)[[1]][1], ".csv", sep = "")
    write.csv(CladePatristicDist, file=OutName)
    OutName2 <- paste("Grid", strsplit(Cladename, ".", fixed=T)[[1]][1], ".csv", sep = "")
    write.csv(CladeGrid, file=OutName2, row.names = F)
  }
}

CalcPatristicDist(wd = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\FullConcatTreeFolder",
                  tree = "FullConcatConcat.fas.treefile.tre", clade = "CladeIDsCSV.csv",
                  grid = "ReorderedGrid.csv")