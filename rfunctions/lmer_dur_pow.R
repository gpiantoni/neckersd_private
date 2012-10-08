#LMER_dur_POW: 

#-----------------#
#-pass arguments
#1. file of the dataset
#2. 'pow', 'pow1', 'pow2', 'pow3', 'pow4'
#3. 'sess' or 'nosess'
#4. output file
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
outputfile <- args[[4]]

# get rid of confusing columns
df$alphapow <- df[,args[[2]]]
df <- df[,!(names(df) %in% c('pow', 'pow1', 'pow2', 'pow3', 'pow4'))]

sink(outputfile, append=TRUE)
cat('\n\n\nLMER_DUR_POW\n\n')

if (args[[3]] == 'sess') {
  dfp <- aggregate(cbind(alphapow, dur, day) ~ subj + cond + trl + sess, data = df, mean) # average over electrodes
} else {
  dfp <- aggregate(cbind(alphapow, dur, day, sess) ~ subj + cond + trl, data = df, mean) # average over electrodes
}

#aggregate transforms them into numberic again
dfp$day <- factor(dfp$day)
dfp$sess <- ordered(dfp$sess)

summary(dfp)
#-----------------#

#-----------------#
print('XXX Power-duration Correlation (NS) XXX')
lm1 <- lmer(dur ~ alphapow + (1|subj) + (1|day:subj) + (1|sess:day:subj), subset(dfp, cond=='ns'))
summary(lm1)
est.ns.pow <- summary(lm1)@coefs[2,1]
t.ns.pow <- summary(lm1)@coefs[2,3]
#-----------------#

#-----------------#
print('XXX Power-duration Correlation (SD) XXX')
lm1 <- lmer(dur ~ alphapow + (1|subj) + (1|day:subj) + (1|sess:day:subj), subset(dfp, cond=='sd'))
summary(lm1)
est.sd.pow <- summary(lm1)@coefs[2,1]
t.sd.pow <- summary(lm1)@coefs[2,3]
#-----------------#

#-----------------#
print('XXX Sleep Deprivation and Alpha Power XXX')
lm1 <- lmer(alphapow ~ cond + (1|subj) + (1|day:subj) + (1|sess:day:subj), dfp)
summary(lm1)
#-----------------#

#-----------------#
#-model
print('XXX Full MODEL: Sleep Deprivation and Alpha Power XXX')
lm1 <- lmer(dur ~ alphapow * cond + (1|subj) + (1|day:subj) + (1|sess:day:subj), dfp)
summary(lm1)
sink()
#-----------------#

#-----------------#
#-write to file only the full model
est.pow <- summary(lm1)@coefs[2,1]
t.pow <- summary(lm1)@coefs[2,3]

est.cond <- summary(lm1)@coefs[3,1]
t.cond <- summary(lm1)@coefs[3,3]

est.int <- summary(lm1)@coefs[4,1]
t.int <- summary(lm1)@coefs[4,3]
tocsv <- c(t.ns.pow, t.sd.pow, t.pow, t.cond, t.int)

infofile <- paste(substr(outputfile, 1, nchar(outputfile)-12), 'output_main', '.csv', sep='')
write.table(tocsv, file=infofile, row.names=FALSE, col.names=FALSE, quote=FALSE)
#-----------------#
