#LMER_dur_POW: 

#-----------------#
#-pass arguments
#1. file of the dataset
#2. 'pow', 'pow1', 'pow2', 'pow3', 'pow4'
#3. output file
args <- commandArgs(TRUE)
#-----------------#

#-----------------#
#-library
library('lme4')
#-----------------#

#-----------------#
#-data
datfile <- args[[1]]
load(datfile)
outputfile <- args[[3]]

# get rid of confusing columns
df$alphapow <- df[,args[[2]]]
df <- df[,!(names(df) %in% c('pow', 'pow1', 'pow2', 'pow3', 'pow4'))]

# rename dur into dista (it's the distance from zero)
colnames(df)[6] <- 'dist'

sink(outputfile, append=TRUE)
cat('\n\n\nLMER_DECAY\n\n')

summary(df)
#-----------------#

#-----------------#
print('XXX Correlation ALPHAPOW ~ DIST XXX')
lm1 <- lmer(alphapow ~ dist + (1|subj) + (1|day:subj) + (1|sess:day:subj), subset(df, cond=='ns'))
summary(lm1)
sink()
#-----------------#

# p <- ggplot(df, aes(x=dist, y=alphapow, color=factor(subj)))
# p + geom_point()
