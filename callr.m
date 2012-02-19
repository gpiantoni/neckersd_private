function callr(cfg)
%CALLR call subfunctions using R
% this cannot be more flexible, it depends on the subfunctions anyway

%-----------------%
%-common
rdir = [cfg.scrp cfg.proj '_private/rfunctions/'];
Rdata = [cfg.dpow 'dur_pow.Rdata'];
elecbase = [cfg.dpow 'lmerelec'];
load(cfg.sens.layout, 'layout')
%-----------------%

%-----------------%
% 1. prepare df
funname = [rdir 'preparedf.R'];
args = [cfg.intor.csv ' ' Rdata];
system(['Rscript ' funname ' ' args]);
%-----------------%

%-----------------%
% 2. lmer on each electrodes and plot
funname = [rdir 'lmer_elec.R'];
args = [Rdata ' ' elecbase];
system(['Rscript ' funname ' ' args]);
eff = {'mainpow' 'maincond' 'powcond'};

h = figure;
for i = 1:numel(eff)
  subplot(2,2,i)
  plottvalue(eff{i}, layout, elecbase)
end

%--------%
%-save and link
pngname = sprintf('lmer_topo');
saveas(h, [cfg.log filesep pngname '.png'])
close(h); drawnow

[~, logfile] = fileparts(cfg.log);
system(['ln ' cfg.log filesep pngname '.png ' cfg.rslt pngname '_' logfile '.png']);
%--------%
%-----------------%


% cfg.callr.fun(1).arg{1} = cfg.intor.csv;
% cfg.callr.fun(1).arg{2} = Rdata;
% 
% cfg.callr.fun(2).name = 'lmer_dur_pow.R';
% cfg.callr.fun(2).arg{1} = Rdata;
% cfg.callr.fun(2).arg{2} = [cfg.dpow 'outputR.txt'];
% cfg.callr.fun(2).arg{3} = 'E21';

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
