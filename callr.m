function callr(cfg)
%CALLR call subfunctions using R
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
Rdata = [cfg.dcor 'dur_pow.Rdata'];
elecbase = [cfg.dcor 'lmerelec'];
load(cfg.sens.layout, 'layout')

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
% 1. prepare df
funname = [rdir 'preparedf.R'];
args = [cfg.intor.csv ' ' Rdata];
system(['Rscript ' funname ' ' args]);
%---------------------------%

% %---------------------------%
% % 2. lmer on each electrodes and plot
% funname = [rdir 'lmer_elec.R'];
% args = [Rdata ' ' elecbase];
% system(['Rscript ' funname ' ' args]);
% eff = {'mainpow' 'maincond' 'powcond' 'powns' 'powsd'};
% 
% for i = 1:numel(eff)
%   h = figure;  
%   plottvalue(eff{i}, layout, elecbase)
%   
%   %--------%
%   %-save and link
%   pngname = sprintf('lmer_topo_%s', eff{i} );
%   saveas(h, [cfg.log filesep pngname '.png'])
%   close(h); drawnow
%   
%   [~, logfile] = fileparts(cfg.log);
%   system(['ln ' cfg.log filesep pngname '.png ' cfg.rslt pngname '_' logfile '.png']);
%   %--------%
% end
% %---------------------------%

%---------------------------%
% 3. lmer_dur_pow
funname = [rdir 'lmer_dur_pow.R'];

pngname = 'lmer_fitted';
args = [Rdata ' ' cfg.log '.txt "' selelec '" ' cfg.callr.sess ' ' [cfg.log filesep pngname '.png']];
system(['Rscript ' funname ' ' args ]);

%--------%
%-save and link
[~, logfile] = fileparts(cfg.log);
system(['ln ' cfg.log filesep pngname '.png ' cfg.rslt pngname '_' logfile '.png']);
%--------%
%---------------------------%

%---------------------------%
% 4. mediation_dur
funname = [rdir 'mediation_dur.R'];

args = [Rdata ' ' cfg.log '.txt "' selelec '" ' cfg.callr.sess];
system(['Rscript ' funname ' ' args ]);
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

%-------------------------------------%
%-subfunction read data and plot
function plottvalue(cond, layout, elecbase)

fid = fopen([elecbase cond '.csv'], 'r');
C = textscan(fid, '%s %n');
fclose(fid);

[~, ilay, idat] = intersect(layout.label, upper(C{1}));

ft_plot_lay(layout, 'label', 'no', 'point', 'no', 'box', 'no')
hold on
[~, h] = ft_plot_topo(layout.pos(ilay, 1), layout.pos(ilay, 2), C{2}(idat), 'mask', layout.mask);
colorbar
title(cond)
set(get(h, 'parent'), 'clim', [-1 1] * 3)
%-------------------------------------%
