function soucorr_r(cfg)
%SOUCORR_R correlation of the source in R
% 

%---------------------------%
%-start log
output = sprintf('%s started at %s on %s\n', ...
  mfilename,  datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

%---------------------------%
% correlation for each source point
rdir = [cfg.scrp cfg.proj '_private/rfunctions/'];
funname = [rdir 'lmer_source.R'];
args = [cfg.dcor];
system(['Rscript ' funname ' ' args]);
%---------------------------%

%---------------------------%
%-read data
fid = fopen([cfg.dcor 'soucorr.csv'], 'r');
C = textscan(fid, '%n %n');
fclose(fid);
%---------------------------%

%---------------------------%
%-create source
load(cfg.vol.template, 'lead')
source = [];
source.pos = lead.pos;
source.inside = lead.inside;
source.outside = lead.outside;
source.dim = lead.dim;
source.pow = NaN(1, size(source.pos,1));
source.pow(C{1}) = C{2};
%---------------------------%

%---------------------------%
%-interpolate
mri = ft_read_mri([cfg.anly 'smri/neckersd_vigd_avg_smri_t1_spm.nii.gz']);
tmpcfg = [];
tmpcfg.parameter = {'pow'};
source = ft_sourceinterpolate(tmpcfg, source, mri);
%---------------------------%

%---------------------------%
%-plot source
tmpcfg = [];
tmpcfg.funparameter = 'pow';
tmpcfg.method = 'slice';
ft_sourceplot(tmpcfg, source);

%--------%
%-save and link
pngname = 'lmer_source';
saveas(gcf, [cfg.log filesep pngname '.png'])
close(gcf); drawnow

[~, logfile] = fileparts(cfg.log);
system(['ln ' cfg.log filesep pngname '.png ' cfg.rslt pngname '_' logfile '.png']);
%--------%
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