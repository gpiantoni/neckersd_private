function output = exportneckersd(cfg)
%EXPORTNECKERSD add extra columns to export2csv

output = 'LMER,';

%-----------------%
%-pow peak
load([cfg.dpow 'r_powpeak'], 'powpeak')
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
extradata = [cfg.dpow 'dur_pow.csv'];
lmerinfo = dlmread(extradata);
s_lmer = sprintf('%1f,', lmerinfo);
%-----------------%

%-----------------%
%-prepare output
output = [output sprintf('%1.f,%s', nelec, s_lmer)];
%-----------------%

%-----------------%
%-clean up files
delete(extradata)
delete([extradata(1:end-3) 'Rdata'])
delete([cfg.dpow 'r_powpeak.mat'])
delete([cfg.dpow 'lmerelec*']);
if isfield(cfg.intor, 'elec')
  delete(cfg.intor.elec)
end
%-----------------%