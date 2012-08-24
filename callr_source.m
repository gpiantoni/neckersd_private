function callr(cfg)
%CALLR call subfunctions using R for source data
% this cannot be more flexible, it depends on the subfunctions anyway

%---------------------------%
%-start log
output = sprintf('%s started at %s on %s\n', ...
  mfilename,  datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

%---------------------------%
%-common
rdir = [cfg.scrp cfg.proj '_private/rfunctions/'];

%-----------------%
%-elec for specific analysis
if iscell(cfg.callr.selelec)
  label = cfg.callr.selelec;
else
  load(cfg.intor.elec, 'label')
end

s_elec = sprintf('''%s'',', label{:});
selelec = ['c(' s_elec(1:end-1) ')']; 
%-----------------%
%---------------------------%

%---------------------------%
% lmer on each source location
funname = [rdir 'lmer_elec.R'];
args = [Rdata ' ' elecbase];
system(['Rscript ' funname ' ' args]);
eff = {'mainpow' 'maincond' 'powcond' 'powns' 'powsd'};

for i = 1:numel(eff)
  h = figure;  
  plottvalue(eff{i}, layout, elecbase)
  
  %--------%
  %-save and link
  pngname = sprintf('lmer_topo_%s', eff{i} );
  saveas(h, [cfg.log filesep pngname '.png'])
  close(h); drawnow
  
  [~, logfile] = fileparts(cfg.log);
  system(['ln ' cfg.log filesep pngname '.png ' cfg.rslt pngname '_' logfile '.png']);
  %--------%
end
%---------------------------%


%---------------------------%
%-end log
toc_t = toc(tic_t);
outtmp = sprintf('%s ended at %s on %s after %s\n\n', ...
  mfilename, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'), ...
  datestr( datenum(0, 0, 0, 0, 0, toc_t), 'HH:MM:SS'));
output = [output outtmp];

%-----------------%
fprintf(output)
fid = fopen([cfg.log '.txt'], 'a');
fwrite(fid, output);
fclose(fid);
%-----------------%
%---------------------------%

