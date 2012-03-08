#LMER_ELEC: lmer on each electrode 

#-----------------#
#-pass arguments
#1. file of the dataset
#2. elec file base
args <- commandArgs(TRUE)
#-----------------#

#-----------------#
library('lme4')
load(args[[1]])

mainpow <- numeric(0)
maincond <- numeric(0)
powcond <- numeric(0)
powns <- numeric(0)
powsd <- numeric(0)

for (e in levels(df$elec)){
  lm1 <- lmer(dur ~ powlog * cond + (1|subj), subset(df, elec==e))
  mainpow[e]  <- (summary(lm1))@coefs[2,3]
  maincond[e] <- (summary(lm1))@coefs[3,3]
  powcond[e]  <- (summary(lm1))@coefs[4,3]
  
  lm1 <- lmer(dur ~ powlog + (1|subj), subset(df, elec==e & cond=='ns'))
  powns[e]  <- (summary(lm1))@coefs[2,3]
  
  lm1 <- lmer(dur ~ powlog + (1|subj), subset(df, elec==e & cond=='sd'))
  powsd[e]  <- (summary(lm1))@coefs[2,3]
  
}
#-----------------#

#-----------------#
#-write to file
csvelec <- paste(args[[2]], 'mainpow.csv', sep='')
write.table(mainpow, file=csvelec, col.names=FALSE, quote=FALSE)

csvelec <- paste(args[[2]], 'maincond.csv', sep='')
write.table(maincond, file=csvelec, col.names=FALSE, quote=FALSE)

csvelec <- paste(args[[2]], 'powcond.csv', sep='')
write.table(powcond, file=csvelec, col.names=FALSE, quote=FALSE)

csvelec <- paste(args[[2]], 'powns.csv', sep='')
write.table(powns, file=csvelec, col.names=FALSE, quote=FALSE)

csvelec <- paste(args[[2]], 'powsd.csv', sep='')
write.table(powsd, file=csvelec, col.names=FALSE, quote=FALSE)
#-----------------#
