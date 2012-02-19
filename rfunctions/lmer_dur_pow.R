#LMER_DUR_POW: 

#-----------------#
#-pass arguments
#1. file of the dataset
#2. output file
#3. electrode
args <- commandArgs(TRUE)
#-----------------#

#-----------------#
library('lme4')

# parietalelec <- c('E12', 'E13', 'E14', 'E25', 'E26', 'E27', 'E28', 'E40', 'E41', 'E42', 'E43', 'E44')
# dfp <- subset(df, elec %in% parietalelec)
load(args[[1]])
sink(args[[2]])
lm1 <- lmer(dur ~ powlog * cond + (1|subj), subset(df, elec == args[[3]]))
summary(lm1)
sink()
#-----------------#

