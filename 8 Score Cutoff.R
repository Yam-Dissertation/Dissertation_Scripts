ScoreCutoff <- function(RankedScores){
  ScoreData <- read.csv(RankedScores, header = T) # Read in a table of Ranked Scores
  Scores <- ScoreData$Score
  Cutoff <- mean(Scores) + (2*sd(Scores)) # Calculate a cutoff value
  print(ScoreData[ScoreData$Score > Cutoff,]) # Print species pairs whose distance score is greater than the cutoff value.
  print(paste0("Num Prio Species: ", length(unique(ScoreData$Priority.Species[ScoreData$Score > Cutoff])))) # Print the number of priority species
  return(Cutoff)
}
