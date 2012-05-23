#LMER_durlog_POW: 

#-----------------#
#-pass arguments
#1. file of the dataset
#2. output file
#3. electrode list
#4. name of pngfile
args <- commandArgs(TRUE)
#-----------------#

#-----------------#
#-library
library('lme4')
library('ggplot2')
#-----------------#

#-----------------#
#-data
datfile <- args[[1]]
load(datfile)
sink(args[[2]], append=TRUE)
dfp <- subset(df, elec %in% eval(parse(text=args[[3]])))
dfp <- aggregate(cbind(durlog, powlog, pow, day) ~ subj + cond + trl + sess, data = dfp, mean) # average over electrodes

#aggregate transforms them into numberic again
dfp$day <- factor(dfp$day)
dfp$sess <- ordered(dfp$sess)

summary(dfp)
#-----------------#

#-----------------#
print('XXX Power-durlogation Correlation (NS) XXX')
lm1 <- lmer(durlog ~ powlog + (1|subj) + (1|day:subj) + (1|sess:day:subj), subset(dfp, cond=='ns'))
summary(lm1)
est.ns.pow <- summary(lm1)@coefs[2,1]
t.ns.pow <- summary(lm1)@coefs[2,3]
#-----------------#

#-----------------#
print('XXX Sleep Deprivation and Alpha Power (1) XXX')
lm1 <- lmer(powlog ~ cond + (1|subj) + (1|day:subj) + (1|sess:day:subj), dfp)
summary(lm1)
#-----------------#

#-----------------#
print('XXX Sleep Deprivation and Alpha Power (2) XXX')
lm1 <- lmer(durlog ~ powlog + (1|subj) + (1|day:subj) + (1|sess:day:subj), subset(dfp, cond=='sd'))
summary(lm1)
est.sd.pow <- summary(lm1)@coefs[2,1]
t.sd.pow <- summary(lm1)@coefs[2,3]
#-----------------#

#-----------------#
#-model
print('XXX Sleep Deprivation and Alpha Power (3) XXX')
lm1 <- lmer(durlog ~ powlog * cond + (1|subj) + (1|day:subj) + (1|sess:day:subj), dfp)
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

infofile <- paste(substr(datfile, 1, nchar(datfile)-6), 'csv', sep='.')
write.table(tocsv, file=infofile, row.names=FALSE, col.names=FALSE, quote=FALSE)
#-----------------#

#-----------------#
#-plot
png(filename=args[[4]])
dfp$durlogfit <- fitted(lm1)
q <- ggplot(dfp, aes(x=powlog, y=durlogfit, color=cond))
q + geom_point() + facet_grid(subj ~ .)
dev.off()
#-----------------#