function lmer_dur_pow(cfg)
% call lmer to do lmm on dur and pow
% model 
% dur ~ pow subset(data, cond =='ns')
% then
% dur ~ pow * cond where interaction and main effect are not significant

