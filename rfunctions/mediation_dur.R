#MEDIATION_DUR

#-----------------#
#-pass arguments
#1. file of the dataset
#2. 'pow', 'pow1', 'pow2', 'pow3', 'pow4'
#3. output file
args <- commandArgs(TRUE)
#-----------------#

#-----------------#
#-library
library('nlme')
#-----------------#

#-----------------#
#-data
datfile <- args[[1]]
load(datfile)
outputfile <- args[[3]]

# get rid of confusing columns
df$alphapow <- df[,args[[2]]]
df <- df[,!(names(df) %in% c('pow', 'pow1', 'pow2', 'pow3', 'pow4'))]

sink(outputfile, append=TRUE)
cat('\n\n\nMEDIATION_DUR\n\n')

summary(df)
#-----------------#

#-----------------#
#-run models
model1 <- lme(dur ~ cond, random = ~ 1|subj/day/sess, data = df)
model2 <- lme(dur ~ cond + alphapow, random = ~ 1|subj/day/sess, data = df)
model3 <- lme(alphapow ~ cond, random = ~ 1|subj/day/sess, data = df)

formula(model1)
print(summary(model1)$tTable)
formula(model2)
print(summary(model2)$tTable)
formula(model3)
print(summary(model3)$tTable)
#-----------------#

#-----------------#
#-collect and print info
r.1 <- summary(model1)$tTable[2,1]
se.1 <- summary(model1)$tTable[2,2]

r.2b <- summary(model2)$tTable[3,1]
se.2b <- summary(model2)$tTable[3,2]

r.3 <- summary(model3)$tTable[2,1]
se.3 <- summary(model3)$tTable[2,2]

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

print('ab')
print(indir)
print('ab (s.e.)')
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
