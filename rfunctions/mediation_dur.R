#MEDIATION_DUR

#-----------------#
#-pass arguments
#1. file of the dataset
#2. output file
#3. electrode
args <- commandArgs(TRUE)
#-----------------#

#-----------------#
library('lme4')
datfile <- args[[1]]
load(datfile)
sink(args[[2]], append=TRUE)

dfp <- subset(df, elec %in% eval(parse(text=args[[3]])))

model1 <- lmer(dur ~ cond + (1|subj), data = dfp)
model2 <- lmer(dur ~ cond + powlog + (1|subj), data = dfp)
model3 <- lmer(powlog ~ cond + (1|subj), data = dfp)

formula(model1)
print(summary(model1)@coefs)
formula(model2)
print(summary(model2)@coefs)
formula(model3)
print(summary(model3)@coefs)

r.2b <- summary(model2)@coefs[3,1]
se.2b <- summary(model2)@coefs[3,2]

r.3 <- summary(model3)@coefs[2,1]
se.3 <- summary(model3)@coefs[2,2]

indir <- r.3 * r.2b
effvar <- r.3^2 * se.2b^2 + r.2b^2 * se.3^2
serr <- sqrt(effvar)
zvalue <- indir/serr

print('zvalue')
print(zvalue)
sink()

infofile <- paste(substr(datfile, 1, nchar(datfile)-6), 'csv', sep='.')
write.table(zvalue, file=infofile, row.names=FALSE, col.names=FALSE, quote=FALSE, append=TRUE)
#-----------------#