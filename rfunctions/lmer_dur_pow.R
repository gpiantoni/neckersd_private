#LMER_DUR_POW: 

#-----------------#
#-pass arguments
#1. file of the dataset
#2. output file
#3. electrode list
args <- commandArgs(TRUE)
#-----------------#

#-----------------#
library('lme4')
load(args[[1]])
sink(args[[2]], append=TRUE)
dfp <- subset(df, elec %in% eval(parse(text=args[[3]])))
lm1 <- lmer(dur ~ powlog * cond + (1|subj), dfp)
summary(lm1)
sink()
#-----------------#

