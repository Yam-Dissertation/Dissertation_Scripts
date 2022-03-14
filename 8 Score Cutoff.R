ScoreCutoff <- function(RankedScores){
  ScoreData <- read.csv(RankedScores, header = T)
  Scores <- ScoreData$Score
  Cutoff <- mean(Scores) + (2*sd(Scores))
  print(ScoreData[ScoreData$Score > Cutoff,])
  print(paste0("Num Prio Species: ", length(unique(ScoreData$Priority.Species[ScoreData$Score > Cutoff]))))
  return(Cutoff)
}
ScoreCutoff("C:\\Users\\joshu\\OneDrive\\Josh\\BIOL0019\\Working Directory\\FinalRun\\FullConcatTreeFolder\\RankScoresEnantiophyllum.csv")
