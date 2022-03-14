library(phytools)
library(ape)
library(ggplot2)
setwd("C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Josh Info Files")
# Load in data
NameMatch <- read.csv("C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Josh Info Files\\IDNameMatch.csv")
LitReview <- read.csv("C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Josh Info Files\\LitReviewCSV.csv")

# Make all rows into factors
LitReview[sapply(LitReview, is.integer)] <- lapply(LitReview[sapply(LitReview, is.integer)], 
                                       as.factor)
# Load in Tree
ExampleTree <- read.tree("C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\FullConcatTreeFolder\\FullConcatConcat.fas.treefile.tre")

IDsinTree <- NULL
for(ID in 1:length(ExampleTree$tip.label)){
  IDsinTree[ID] <- strsplit(ExampleTree$tip.label, split = "_", fixed = T)[[ID]][1] # The ID
}

# In a dataframe, match the IDsinTree with a name from the NameMatch file
NamesforIDs <- NameMatch$Name[match(IDsinTree, NameMatch$ID_New)]

# Then, match these names with rows in LitReview
LitReviewReordered <- LitReview[match(NamesforIDs, LitReview$SpeciesNameFinal),]
LitReviewReordered$Treename <- ExampleTree$tip.label
LitReview$SpeciesNameFinal[LitReview$SpeciesNameFinal %in% NameMatch$Name == F]

# Recode LitReviewReordered as 1/0
temp <- data.frame(lapply(LitReviewReordered, function(x){
  ifelse(is.na(x) == T, 0, 1)
}))
temp$SpeciesNameFinal <- LitReviewReordered$Treename
write.csv(temp[order(nrow(temp):1),], file ="C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\FullConcatTreeFolder\\ReorderedGrid.csv", row.names = F)

# Building Heatmap
temp <- temp[2:25]
dd <- expand.grid(Metabolite = colnames(temp), Species = LitReviewReordered$Treename)
dd$Presence <- c(t(temp))
head(dd, 50)

PlotGrid <- function(filename, cladename){
  grid <- read.csv(filename)
  Names <- grid$SpeciesNameFinal
  grid <- grid[2:25]
  expandedgrid <- expand.grid(Metabolite = colnames(grid), Species = Names)
  expandedgrid$Presence <- c(t(grid))
  
  filename <- paste0("C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\FullConcatTreeFolder\\LitGridPlot", cladename, ".pdf")
  pdf(file = filename)
  Plot <- ggplot(expandedgrid, aes(x = Metabolite, y = Species, fill = factor(Presence))) +
    geom_tile(color = "black", lwd = 0.1) + 
    theme_light() +
    scale_fill_discrete(name = "Metabolite Presence", labels = c("Absent", "Present")) + 
    theme(text = element_text(size = 5),
          axis.text.x = element_text(angle=90, size = 3, hjust = 1),
          axis.text.y = element_text(size = 1, hjust = 1),
          axis.title.y = element_blank(),
          legend.position = "none")
  print(Plot)
  dev.off()
}
PlotGrid(filename = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\FullConcatTreeFolder\\GridAfrica.csv", cladename = "Africa")

Folder <- "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\FullConcatTreeFolder"
Files <- list.files(Folder, recursive = T, pattern="Grid")[1:13]
Files

for(Grid in 1:length(Files)){
  Clade <- gsub("Grid", "", gsub(".csv", "", Files[Grid]))
  print(Clade)
  PlotGrid(filename = paste0(Folder, "\\", Files[Grid]), cladename = Clade )
}

