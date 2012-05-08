function output = exportneckersd(cfg)
%EXPORTNECKERSD add extra columns to export2csv

output = 'LMER,';

%-----------------%
%-pow peak
load([cfg.dcor 'r_powpeak'], 'powpeak')
f = 1;
output = [output sprintf('%s,%1.3f,%1.3f,%1.3f,%1.3f,', ...
      powpeak(f).name, powpeak(f).time, powpeak(f).wndw, powpeak(f).freq, powpeak(f).band)];
%-----------------%

%-----------------%
%-n electrodes
if iscell(cfg.callr.selelec)
  label = cfg.callr.selelec;
else
  load(cfg.intor.elec, 'label')
end
nelec = numel(label);
%-----------------%

%-----------------%
%-read results
extradata = [cfg.dcor 'dur_pow.csv'];
lmerinfo = dlmread(extradata);
s_lmer = sprintf('%1f,', lmerinfo);
%-----------------%

%-----------------%
%-prepare output
% columns contain:
% 1- lmer powlog only ns
% 2- lmer powlog only sd
% 3- lmer powlog X cond: powlog
% 4- lmer powlog X cond: cond
% 5- lmer powlog X cond: interaction
% 6- lmer mediation
output = [output sprintf('%1.f,%s', nelec, s_lmer)];
%-----------------%

%-----------------%
%-clean up files
delete(extradata)
delete([extradata(1:end-3) 'Rdata'])
delete([cfg.dcor 'r_powpeak.mat'])
delete([cfg.dcor 'lmerelec*']);
if isfield(cfg.intor, 'elec')
  delete(cfg.intor.elec)
end
%-----------------%