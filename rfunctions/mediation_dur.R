#MEDIATION_DUR

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
cat('\n\n\nMEDIATION_DUR\n\n')

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
#-run models
model1 <- lmer(dur ~ cond + (1|subj) + (1|day:subj) + (1|sess:day:subj), data = dfp)
model2 <- lmer(dur ~ cond + alphapow + (1|subj) + (1|day:subj) + (1|sess:day:subj), data = dfp)
model3 <- lmer(alphapow ~ cond + (1|subj) + (1|day:subj) + (1|sess:day:subj), data = dfp)

formula(model1)
print(summary(model1)@coefs)
formula(model2)
print(summary(model2)@coefs)
formula(model3)
print(summary(model3)@coefs)
#-----------------#

#-----------------#
#-collect and print info
r.1 <- summary(model1)@coefs[2,1]
se.1 <- summary(model1)@coefs[2,2]

r.2b <- summary(model2)@coefs[3,1]
se.2b <- summary(model2)@coefs[3,2]

r.3 <- summary(model3)@coefs[2,1]
se.3 <- summary(model3)@coefs[2,2]

indir <- r.3 * r.2b
effvar <- r.3^2 * se.2b^2 + r.2b^2 * se.3^2
serr <- sqrt(effvar)
zvalue <- indir/serr

print('a (cond -> alpha)')
print(r.3)
print('a (s.e.)')
print(se.3)

print('b (ALPHA + cond -> durlog)')
print(r.2b)
print('b (s.e.)')
print(se.2b)

print('c prime')
print(indir)
print('c prime (s.e.)')
print(serr)

print('c')
print(r.1)
print('c (s.e.)')
print(se.1)

print('zvalue')
print(zvalue)
print('p-value')
print(2*(1-pnorm(abs(zvalue))))

sink()
#-----------------#

#-----------------#
#-print to file
infofile <- paste(substr(outputfile, 1, nchar(outputfile)-12), 'output_mediation', '.csv', sep='')
write.table(zvalue, file=infofile, row.names=FALSE, col.names=FALSE, quote=FALSE, append=TRUE)
#-----------------#
