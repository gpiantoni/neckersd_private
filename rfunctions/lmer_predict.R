#LMER_predict: 

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
outputfile <- args[[4]]
load(datfile)

# get rid of confusing columns
df$alphapow <- df[,args[[2]]]
df <- df[,!(names(df) %in% c('pow', 'pow1', 'pow2', 'pow3', 'pow4'))]

sink(outputfile, append=TRUE)
if (args[[3]] == 'sess') {
  dfp <- aggregate(cbind(alphapow, dur, day) ~ subj + cond + trl + sess + time, data = df, mean) # average over electrodes
} else {
  dfp <- aggregate(cbind(alphapow, dur, day, sess) ~ subj + cond + trl + time, data = df, mean) # average over electrodes
}

#aggregate transforms them into numberic again
dfp$day <- factor(dfp$day)
dfp$time <- factor(dfp$time)
dfp$sess <- ordered(dfp$sess)

summary(dfp)
#-----------------#

#-----------------#
tstat <- 0
cnt <- 0
for (t in levels(dfp$time)){
  lm1 <- lmer(dur ~ alphapow + (1|subj) + (1|day:subj) + (1|sess:day:subj), subset(dfp, cond=='ns' & time==t))
  cnt <- cnt + 1
  tstat[cnt] <- summary(lm1)@coefs[2,3]
}

print(levels(dfp$time))
print(tstat, digits=2)
#-----------------#

#-----------------#
sink()

infofile <- paste(substr(outputfile, 1, nchar(outputfile)-12), 'output_predict', '.csv', sep='')
write.table(tstat, file=infofile, row.names=FALSE, col.names=FALSE, quote=FALSE)
#-----------------#