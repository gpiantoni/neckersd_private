function output = exportneckersd(cfg)
%EXPORTNECKERSD add extra columns to export2csv

output = 'LMER,';

%-------------------------------------%
%-redef
output = [output sprintf('%s,', cfg.redef.event2trl)];
output = [output sprintf('%s,', cfg.redef.trigger)];
output = [output sprintf('%f,', cfg.redef.mindist)];
output = [output sprintf('%f,', cfg.redef.maxdist)];

if strcmp(cfg.redef.event2trl, 'event2trl_trial')
  output = [output sprintf('%f,', cfg.redef.prestim)];
  output = [output sprintf('%f,', cfg.redef.poststim)];
  
else
  output = [output sprintf('%f,', cfg.redef.pad)];
  output = [output sprintf('%f,', cfg.redef.trldur)];
  output = [output sprintf('%f,', cfg.redef.overlap)];
  
end
%-------------------------------------%

%-------------------------------------%
%-POW info
output = [output sprintf('%f,', cfg.intor.powpeak.freq(1))];
output = [output sprintf('%f,', cfg.intor.powpeak.freq(2))];
%-------------------------------------%

%-------------------------------------%
%-stats
output = [output sprintf('%f,', numel(cfg.callr.selelec))];
%-------------------------------------%

%-------------------------------------%
%-read results
extradata = [cfg.dcor 'dur_pow.csv'];
lmerinfo = dlmread(extradata);
output = [output  sprintf('%f,', lmerinfo)];

%-----------------%
%-prepare output
% columns contain:
% 1- lmer powlog only ns
% 2- lmer powlog only sd
% 3- lmer powlog X cond: powlog
% 4- lmer powlog X cond: cond
% 5- lmer powlog X cond: interaction
% 6- lmer mediation
%-----------------%
%-------------------------------------%

%-------------------------------------%
%-clean up files
delete(extradata)
% delete([extradata(1:end-3) 'Rdata'])
% delete([cfg.dcor 'r_powpeak.mat'])
delete([cfg.dcor 'lmerelec*']);
%-------------------------------------%