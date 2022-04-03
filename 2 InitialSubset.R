# Data cleaning using test_seq_lengths.txt from HybPiper

# The species threshold value and gene threshold value can be modified here relative to the size of your dataset.
# wd should be set as the directory containing the HybPiper FNA files and the test_seq_lengths.txt file.

SubsetbyCutoff <- function(wd,
                               seq_lengths = "test_seq_lengths.txt",
                               gene_subset = NULL,
                               speciesthreshold = 1,
                               genethreshold = 300,
                               name){
  setwd(wd)
  Data <- read.table(seq_lengths, header = T)

  for(colname in 2:length(colnames(Data))){
    colnames(Data)[colname] <- substr(colnames(Data)[colname], 2, nchar(colnames(Data)[colname]))
  }
  
  if(!is.null(gene_subset)){
    Data <- data.frame(Data[, 1], Data[, gene_subset])
    for(colname in 2:length(colnames(Data))){ # This needs to be repeated because the headings are weirdly formatted when you subset by a vector of strings
      colnames(Data)[colname] <- substr(colnames(Data)[colname], 2, nchar(colnames(Data)[colname]))
    }
  }
  colnames(Data)[1] <- "ID"
  
  print(paste("Initial Species Count:", length(rownames(Data))-1, sep = ""))
  print(paste("Initial Gene Count:", length(Data)-1, sep = ""))
  
  # Calculate % of total
  Data$Percentoftotal[1] <- NA
  for(row in 1:length(rownames(Data))){
    if(length(Data) == 3){
      Data$Percentoftotal[row] <- (Data[row,2]/Data[1,2])*100
    } else {
      Data$Percentoftotal[row] <- (sum(Data[row,3:length(Data)-1])/sum(Data[1,3:length(Data)-1])) * 100
    }
  }
  
  # Remove rows below 1% threshold
  DataSubset <- Data[Data$Percentoftotal > speciesthreshold | is.na(Data$Percentoftotal),]
  #print(Data[Data$Percentoftotal < speciesthreshold,1])
  PercentRecovery <- DataSubset[,c(1,length(DataSubset))]
  PercentRecovery <- PercentRecovery[-c(1),]
  PercentRecovery$Percentoftotal <- round(PercentRecovery$Percentoftotal, digits = 1)
  write.table(PercentRecovery, paste(name, "PercentRecovery.txt", sep = ""), row.names=F, col.names=F, quote=F) # Needed for tree plotting
  DataSubset$Percentoftotal <- NULL
  
  print(paste("Updated Species Count:", length(rownames(DataSubset))-1, sep = ""))
  
  # Calculate % of 0s in column
  NewRow <- c(NA)
  for(col in 2:length(DataSubset)){
    NewRow[col] <- length(which(DataSubset[,col] == 0))
  }
  DataDoubleSubset <- rbind(DataSubset, NewRow)
  DataDoubleSubset[length(rownames(DataDoubleSubset)),]
  
  #print(DataDoubleSubset[c(1,length(rownames(DataDoubleSubset))),])
  
  # Remove columns with <100 missing value
  DataDoubleSubset <- DataDoubleSubset[,NewRow < genethreshold | is.na(NewRow)]
  print(paste("Updated Gene Count:", length(DataDoubleSubset)-1, sep = ""))
  
  
  # Output names to a txt file so that I can copy certain subsets across
  if(length(gene_subset) == 1){
    colnames(DataDoubleSubset)[2] <- gene_subset
  }
  
  OutputGenes <- colnames(DataDoubleSubset)[2:length(DataDoubleSubset)]
  print(OutputGenes)
  OutputSpecies <- DataDoubleSubset[2:(length(rownames(DataDoubleSubset))-1),1]
  print(OutputSpecies)
  write.table(OutputGenes, file=paste(name, "SubsettedGenes.txt", sep = ""), row.names=F, col.names=F, quote=F)
  write.table(OutputSpecies, file=paste(name, "SubsettedSpecies.txt", sep = ""), row.names=F, col.names=F, quote=F)
}

# This takes into account genes filtered out by visual inspection of cophylo
# 4 genes were removed in total: 270, 272, 273, and 279
FinalGeneSubset <- c("261", "262", "263", "264", "265", "266", "267", "268", "269", "271", "274",
                     "275", "276", "277", "278", "280", "281", "282", "283", "284", "285", "286",
                     "287", "288", "289", "290", "291", "292", "293", "294", "295", "296", "297",
                     "298", "299", "300", "301", "302", "303")

# FullConcat
SubsetbyCutoff(gene_subset = FinalGeneSubset, name = "FullConcat")

# Steroids
SubsetbyCutoff(gene_subset = c("263", "264", "265", "266", "267", "268", "269", "271", "274", "275", "276",
                               "277", "278", "280", "281", "282", "283", "284", "285", "286", "287", "288",
                               "289", "290"), name = "Steroids")

# Starch
SubsetbyCutoff(gene_subset = c("291", "292", "293", "294", "295", "296", "297", "298", "299", "300", "301",
                               "302", "303"), name = "Starch")

# Individual Genes
for(gene in 1:length(FinalGeneSubset)){
  SubsetbyCutoff(gene_subset = FinalGeneSubset[gene], name = FinalGeneSubset[gene])
}

# The outputs will be two files for each gene. One file of gene IDs and one with library codes.
