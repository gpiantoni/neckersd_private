function callr(cfg)
%CALLR call subfunctions using R

% call lmer to do lmm on dur and pow
% model 
% dur ~ pow subset(data, cond =='ns')
% then
% dur ~ pow * cond where interaction and main effect are not significant

rdir = [cfg.scrp cfg.proj '_private/rfunctions/'];

for i = 1:numel(cfg.callr.fun)
  funname = [rdir cfg.callr.fun(i).name];
  args = sprintf(' %s', cfg.callr.fun(i).arg{:}); % this should be more flexible
  system(['Rscript ' funname ' ' args]);
end

