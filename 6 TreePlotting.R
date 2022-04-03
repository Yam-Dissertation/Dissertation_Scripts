# This function includes a lot of options
# 1. You can plot either a fan or an additive phylogeny by specifying the plot parameter
# 2. You can build a cophylogeny by providing two treefiles
# 3. You can root the tree by an outgroup, but bear in mind that this must be monophyletic
# 4. If the outgroup you wish to root by is polyphyletic, you may wish to remove certain tip labels by supplying a list of IDs to the ToDrop parameter.
# 5. Finally, you can choose whether the tree will be ultrametric or not (only for additive/tall phylogenies)

library(phytools)
library(ape)

PlotTree <- function(wd,
                     matchtable = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\JuanHybPiperOutput\\IDNameMatch.csv",
                     recovery = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\JuanHybPiperOutput\\FullConcatPercentRecovery.txt",
                     recovery2 = NULL,
                     plot = "tall",
                     treefile,
                     treefile2 = NULL,
                     ultrametric = F,
                     ToDrop = NULL,
                     outgroupspecies = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\JuanHybPiperOutput\\OutgroupList.txt"){
  # Loading in files
  setwd(wd)
  NameTable <- read.csv(matchtable)
  RecoveryPercentages <- read.table(recovery)
  if(!is.null(recovery2)){
    RecoveryPercentages2 <- read.table(recovery2) 
  }
  alloutgroup <- read.table(outgroupspecies)[,1]
  trichopus <- alloutgroup[1:2]
  tacca <- alloutgroup[3:10]

  # SPECIES LABEL FUNCTION
  LabelFunction <- function(tree, recoveryarg){
    Matches <- match(tree$tip.label, NameTable$ID_New)
    
    if(sum(is.na(Matches)) > 0){
      print(sort(tree$tip.label[!(tree$tip.label %in% NameTable$ID_New)]))
    }
    
    RecoveryMatches <- match(tree$tip.label, recoveryarg$V1)
    tree$tip.label <- gsub(" ", "_", paste(tree$tip.label, "_", NameTable$Name[Matches], "_", recoveryarg$V2[RecoveryMatches], sep = ""))
    
    if(treefile == "FullConcatSupermatrix.fas.treefile"){
      write.table(data.frame(unique(NameTable$Name[Matches])), file = "FinalTreeSubset.txt", col.names = F, row.names = F, quote = F)
    }
    
    return(tree$tip.label)
  }
  
  # TREE 1
  Tree1 <- read.tree(treefile)
  Tree1 <- drop.tip(Tree1, ToDrop)
  Tree1Cophylo <- Tree1
  
  fileprefix <- strsplit(basename(treefile), "TRIMAL", fixed=T)[[1]][1]
  filename <- paste(dirname(treefile), "/", fileprefix, ".tre", sep = "")
  
  # Rooting the tree using an outgroup (prioritise trichopus)
  if(sum(!is.na(Tree1$tip.label[match(tacca, Tree1$tip.label)])) > 0){
    print("Tacca")
    outgroup <- Tree1$tip.label[match(tacca, Tree1$tip.label)]
  } else {
    outgroup <- Tree1$tip.label[match(trichopus, Tree1$tip.label)]
    print("Trichopus")
  }
  outgroup <- outgroup[!is.na(outgroup)]
  
  Tree1 <- tryCatch(root(Tree1, outgroup = outgroup),
                    error = function(e){
                      print(paste("Could not root", fileprefix, sep = " "))
                      return(Tree1)
                      }
                    )
  
  Tree1$tip.label <- LabelFunction(Tree1, RecoveryPercentages)
  write.tree(Tree1, filename)
  
  if(ultrametric == T){
    Tree1 <- force.ultrametric(Tree1, method="nnls", message=F)
    fileprefix <- paste(fileprefix, "Ultrametric", sep = "")
  } else {
    fileprefix <- paste(fileprefix, "Additive", sep = "")
  }
  
  # TREE 2
  if(!is.null(treefile2)){
    Tree2 <- read.tree(treefile2)
    Tree2 <- drop.tip(Tree2, ToDrop)
    Tree2Cophylo <- Tree2
    
    fileprefix2 <- strsplit(basename(treefile2), "TRIMAL", fixed=T)[[1]][1]
    filename2 <- paste(dirname(treefile2), "/", fileprefix2, ".tre", sep = "")
    
    # Rooting the tree using an outgroup (prioritise trichopus)
    if(sum(!is.na(Tree2$tip.label[match(tacca, Tree2$tip.label)])) > 0){
      outgroup2 <- Tree2$tip.label[match(tacca, Tree2$tip.label)]
    } else {
      outgroup2 <- Tree2$tip.label[match(trichopus, Tree2$tip.label)]
    }
    outgroup2 <- outgroup2[!is.na(outgroup2)]

    Tree2 <- tryCatch(root(Tree2, outgroup = outgroup2),
                      error = function(e){
                        print(paste("Could not root", fileprefix2, sep = " "))
                        return(Tree2)
                        }
                      )
    Tree2$tip.label <- LabelFunction(Tree2, RecoveryPercentages2)
    write.tree(Tree2, filename2)
    
    if(ultrametric == T){
      Tree2 <- force.ultrametric(Tree2, method="nnls", message=F)
      fileprefix2 <- paste(fileprefix2, "Ultrametric", sep = "")
    } else {
      fileprefix2 <- paste(fileprefix2, "Additive", sep = "")
    }
  }
#  
  # PLOT AN INDIVIDUAL TREE AND MAKE PDF
  IndividualPlotting <- function(tree, prefix){
    treeprefix <- paste(dirname(treefile), "/", prefix, sep = "")
    if(plot == "tall"){
      pdf(file = paste(treeprefix, "PlotTall.pdf", sep = ""))
      plot.phylo(tree, cex = 0.1, edge.width = 0.2, show.node.label=T)
      dev.off()
    } else if(plot == "fan"){
      pdf(file = paste(treeprefix, "PlotRound.pdf", sep = ""))
      plot.phylo(tree, type = "fan", cex = 0.1, edge.width = 0.2)
      dev.off()
    }
  }
  
  # PLOT A COPHYLO TREE AND MAKE PDF
  CophyloPlotting <- function(tree1, tree2){
    ladderize(tree2, right = T)
    Mirrorplot <- cophylo(tree1, tree2)
    cophyloname = paste(fileprefix, fileprefix2, "Cophylo.pdf", sep = "")
    pdf(file = cophyloname)
    if(ultrametric == T){
      linewidth <- F
    } else {
      linewidth <- 0.1
    }
    plot(Mirrorplot,
         link.type="curved", link.lwd=0.1, link.lty="solid", link.col="darkgreen",
         fsize = 0.1,
         lwd=0.2, lty="solid",
         tip.lwd = linewidth, pts = F)
    dev.off()
  }
  
  IndividualPlotting(Tree1, prefix = fileprefix)
  
  if(!is.null(treefile2)){
    IndividualPlotting(Tree2, prefix = fileprefix2)
    CophyloPlotting(Tree1Cophylo, Tree2Cophylo)
  }
}

# 3 types of plot for each tree.
Folder <- "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun"
SF <- list.files(Folder, recursive = T, pattern="*.treefile$")
WD <- paste("C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\", dirname(SF), sep="" )
TR <- basename(SF)
Folder
Recoveries <- basename(dir(Folder, pattern="*TreeFolder$", recursive = F))
for(i in 1:length(Recoveries)){
  Recoveries[i] <- gsub("TreeFolder", "", Recoveries[i], fixed = T)
  Recoveries[i] <- paste("C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\JuanHybpiperOutput\\",Recoveries[i],"PercentRecovery.txt", sep = "")
}
Recoveries

DropTips <- list(c("W17", "W23", "W20", "Z86"), "Z86", "Z86", "Z86", "Z86", NULL, c("Z86", "W20"),
                 NULL, "R070", c("W20", "Z85", "Z86"), "Z86", c("Y64", "W20", "Z86"), c("P10", "W20"), "R003", "Z86",
                 NULL, c("W23", "W20", "Z86"), "Z86", c("X60", "Z44"), NULL, "Z86", "Z86", c("W20", "Z86"),
                 c("W20", "Z86", "W18", "Z85", "W22"), c("S07", "Z86", "Z85"), c("W20", "Z86"), "Z86", "W20", c("W20", "Z86"),
                 NULL, "Z86", c("Z86", "W23"), NULL, "W20", NULL, NULL, "Z86", c("W20", "Z86"), NULL, "Z86", "Z86", "Z86")
length(DropTips)
TR
WD
Recoveries
c(DropTips[[1]], "Z86")

for(tree in 1:length(TR)){
  PlotTree(wd = WD[tree], treefile = TR[tree],
           recovery = Recoveries[tree], ToDrop = DropTips[[tree]])
  PlotTree(wd = WD[tree], treefile = TR[tree], plot = "fan",
           recovery = Recoveries[tree], ToDrop = DropTips[[tree]])
  PlotTree(wd = WD[tree], treefile = TR[tree], ultrametric = T,
           recovery = Recoveries[tree], ToDrop = DropTips[[tree]])
  PlotTree(wd = WD[tree], 
           treefile = TR[tree],
           treefile2 = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\FullConcatTreeFolder\\FullConcatConcat.fas.treefile",
           ultrametric = T,
           recovery = Recoveries[tree],
           recovery2 = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\JuanHybpiperOutput\\FullConcatPercentRecovery.txt",
           ToDrop = c(DropTips[[tree]],"Z86"))
}

#Example function calls
PlotTree(wd = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\261TreeFolder",
         treefile = "261TRIMAL.fasta.treefile",
         recovery = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\JuanHybpiperOutput\\261PercentRecovery.txt",
         ToDrop = c("W17", "W23", "W20", "Z86"))

PlotTree(wd = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\263TreeFolder", 
         treefile = "263TRIMAL.fasta.treefile",
         treefile2 = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\FullConcatTreeFolder\\FullConcatConcat.fas.treefile",
         ultrametric = T,
         recovery = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\JuanHybpiperOutput\\263PercentRecovery.txt",
         recovery2 = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\JuanHybpiperOutput\\FullConcatPercentRecovery.txt",
         ToDrop = "Z86")

# Plot Josh Tree against Juan Tree
setwd("C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\FullConcatTreeFolder")
JuanTree <- read.tree("JuanTree.tre")
JuanPercentage <- c()
for(m in 1:length(JuanTree$tip.label)){
  JuanPercentage[m] <- strsplit(JuanTree$tip.label[m], "_", fixed = T)[[1]][length(strsplit(JuanTree$tip.label[m], "_", fixed = T)[[1]])]
  JuanTree$tip.label[m] <- strsplit(JuanTree$tip.label[m], "_", fixed = T)[[1]][1]
}
write.tree(JuanTree, "JuanTreeUpdated.tre")
JuanRecovery <- data.frame(JuanTree$tip.label, JuanPercentage)
write.table(JuanRecovery, file="JuanPercentRecovery.txt", row.names=F, col.names=F, quote=F)      

PlotTree(wd = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\FullConcatTreeFolder", 
         treefile = "JuanTreeUpdated.tre",
         treefile2 = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\FullConcatTreeFolder\\FullConcatConcat.fas.treefile",
         ultrametric = T,
         recovery = "C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\JuanHybpiperOutput\\263PercentRecovery.txt",
         recovery2 = "JuanPercentRecovery.txt")
