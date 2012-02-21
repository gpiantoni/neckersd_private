#PREPAREDF: prepare dataframe for alpha dur

#-----------------#
#-pass arguments
#1. data to import, csv
#2. name of the file to save to
args <- commandArgs(TRUE)
#-----------------#

#-----------------#
#-read the data
df <- read.csv(args[[1]], header=FALSE)
colnames(df) <- c('subj', 'cond', 'trl', 'dur', 'elec', 'pow', 'powlog', 'logpow')

df$subj <- factor(df$subj)
df$trl <- factor(df$trl)

save(df, file=args[[2]])
#-----------------#