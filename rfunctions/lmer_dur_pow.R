#LMER_DUR_POW: 

#-----------------#
#-pass arguments
#1. file of the dataset
#2. output file
#3. electrode list
#4. 
args <- commandArgs(TRUE)
#-----------------#

#-----------------#
#-library
library('lme4')
options(contrasts=c("contr.sum", "contr.poly"))
library('ggplot2')
#-----------------#

#-----------------#
#-data
datfile <- args[[1]]
load(datfile)
sink(args[[2]], append=TRUE)
dfp <- subset(df, elec %in% eval(parse(text=args[[3]])))
dfp <- aggregate(cbind(dur, logpow, powlog, pow) ~ subj + cond + trl, data = dfp, mean)
#-----------------#

#-----------------#
#-model
lm1 <- lmer(dur ~ logpow * cond + (logpow * cond|subj), dfp)
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

#-----------------#
#-plot
png(filename=args[[4]])
dfp$durfit <- fitted(lm1)
q <- ggplot(dfp, aes(x=logpow, y=durfit, color=cond))
q + geom_point() + facet_grid(subj ~ .)
dev.off()
#-----------------#
