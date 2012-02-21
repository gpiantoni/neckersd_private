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
datfile <- args[[1]]
load(datfile)
sink(args[[2]], append=TRUE)
dfp <- subset(df, elec %in% eval(parse(text=args[[3]])))
lm1 <- lmer(dur ~ powlog * cond + (1|subj), dfp)
summary(lm1)
sink()
#-----------------#

#-----------------#
#-write to file
est.pow <- summary(lm1)@coefs[2,1]
t.pow <- summary(lm1)@coefs[2,3]

est.cond <- summary(lm1)@coefs[3,1]
t.cond <- summary(lm1)@coefs[3,3]

est.int <- summary(lm1)@coefs[4,1]
t.int <- summary(lm1)@coefs[4,3]
tocsv <- c(est.pow, est.cond, est.int, t.pow, t.cond, t.int)

infofile <- paste(substr(datfile, 1, nchar(datfile)-6), 'csv', sep='.')
write.table(tocsv, file=infofile, row.names=FALSE, col.names=FALSE, quote=FALSE)
#-----------------#