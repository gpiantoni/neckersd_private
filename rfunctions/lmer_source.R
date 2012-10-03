#LMER_ELEC: lmer on each electrode 

#-----------------#
#-pass arguments
#1. dir to import, csv
args <- commandArgs(TRUE)
#-----------------#

#-----------------#
#-read the data
filenames <- list.files(path = args[[1]], pattern = 'soucorr_', full.names=TRUE)
df <- do.call("rbind", lapply(filenames, read.csv, header = FALSE)) 

colnames(df) <- c('subj', 'cond', 'sess', 'trl', 'dur', 'pos', 'pow')

df$subj <- factor(df$subj)
df$trl <- factor(df$trl)
df$sess <- ordered(df$sess)
df$pos <- factor(df$pos)
#-----------------#

#-----------------#
library('lme4')

powcorr <- numeric(0)

for (e in levels(df$pos)){
  lm1 <- lmer(dur ~ pow + (1|subj) + (1|sess:subj), subset(df, pos==e))
  powcorr[e]  <- (summary(lm1))@coefs[2,3]
  }
#-----------------#

#-----------------#
#-write to file
csvpos <- paste(args[[1]], 'soucorr.csv', sep='')
write.table(powcorr, file=csvpos, col.names=FALSE, quote=FALSE)
#-----------------#