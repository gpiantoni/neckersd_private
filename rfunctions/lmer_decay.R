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

df$dist <- -1 * df$dist
summary(df)
#-----------------#

#-----------------#
print('XXX Correlation ALPHAPOW ~ DIST XXX')
lm1 <- lmer(alphapow ~ dist + (1|subj) + (1|day:subj) + (1|sess:day:subj), subset(df, cond=='ns'), REML=FALSE)
lm2 <- lmer(alphapow ~ dist + I(dist ^ 2) + (1|subj) + (1|day:subj) + (1|sess:day:subj), subset(df, cond=='ns'), REML=FALSE)
lm3 <- lmer(alphapow ~ dist + I(dist ^ 2) + I(dist ^ 3) + (1|subj) + (1|day:subj) + (1|sess:day:subj), subset(df, cond=='ns'), REML=FALSE)
print('XXX MODEL COMPARISONS XXX')
anova(lm1, lm2, lm3)

print('XXX SUMMARY OF WINNING MODEL XXX')
summary(lm2)

findmax <- function(a,b){-b / (2*a)}
sprintf('The peak of alpha is at %.2fs', findmax(fixef(lm2)[3], fixef(lm2)[2]))
sink()
#-----------------#

# pl <- subset(df, cond=='ns')
# pl$f <- fitted(lm2)
# pl$grp <- paste(pl$sess,pl$subj)
# p <- ggplot(pl, aes(x=dist, y=f, color=factor(subj)))
# p + geom_line(aes(group=grp)) +  theme_set(theme_bw(24))

