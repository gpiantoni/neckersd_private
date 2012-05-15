function pow_into_r(cfg, subj)
%POW_INTO_R convert power data into R
% only one time point and frequency

%---------------------------%
%-start log
output = sprintf('(p%02.f) %s started at %s on %s\n', ...
  subj, mfilename,  datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

%---------------------------%
%-dir and files
ddir = sprintf('%s%04.f/%s/%s/', cfg.data, subj, cfg.mod, cfg.nick); % data
load(cfg.sens.layout, 'layout')

%-------%
%-get cond names
uniquecond = eq(cfg.intor.cond{1}, cfg.intor.cond{2});
for i = 1:numel(cfg.intor.cond)
  condname{i} = cfg.intor.cond{i}(~uniquecond);
end
%-------%
%---------------------------%

%---------------------------%
%-use predefined or power-peaks for areas of interest
powpeak = cfg.intor.powpeak;
save([cfg.dcor 'r_powpeak'], 'powpeak') % used by exportneckersd
%---------------------------%

%-------------------------------------%
%-loop over conditions
%-----------------%
%-assign day, based on subj number and condition
subjday = [2 1 % EK
  1 2 % HE
  1 2 % MS
  1 2 % MW
  2 1 % NR
  2 1 % RW
  1 2 % TR
  2 1]; % WM
%-----------------%

f = 1; % only first powpeak

dat = '';
for k = 1:numel(cfg.intor.cond)
  
  %-----------------%
  %-input and output for each condition
  allfile = dir([ddir cfg.intor.cond{k} cfg.endname '.mat']); % files matching a preprocessing
  if isempty(allfile)
    continue
  end
  %-----------------%
  
  %-----------------%
  %-concatenate only if you have more datasets
  if numel(allfile) > 1
    spcell = @(name) sprintf('%s%s', ddir, name);
    allname = cellfun(spcell, {allfile.name}, 'uni', 0);

    dataall = [];
    for i = 1:numel(allname)
      load(allname{i}, 'data')
      data.trialinfo = [data.trialinfo repmat(i, numel(data.trial), 1)];
      dataall{i} = data;
    end
    
    cfg1 = [];
    data = ft_appenddata(cfg1, dataall{:});
    clear dataall
    
  else
    load([ddir allfile(1).name], 'data')
    
  end
  %-----------------%
  
  %-----------------%
  %-pow on peak
  cfg1 = [];
  cfg1.method = 'mtmconvol';
  cfg1.output = 'pow';
  cfg1.taper = 'hanning';
  cfg1.foilim = powpeak(f).freq;
  
  cfg1.t_ftimwin = powpeak(f).wndw * ones(numel(cfg1.foi),1);
  cfg1.toi = powpeak(f).time;
  cfg1.feedback = 'none';
  cfg1.keeptrials = 'yes';
  freq = ft_freqanalysis(cfg1, data);
  
  pow = mean(freq.powspctrm,3);
  powlog = mean(log(freq.powspctrm),3);
  logpow = log(mean(freq.powspctrm,3));
  %-----------------%
  
  %-----------------%
  %-write to file
  for t = 1:size(pow,1);
    for e = 1:size(pow,2);
      dat = sprintf('%s%03.f,%s,%1.f,%1.f,%1.f,%1f,%s,%1f,%1f,%1f\n', ....
        dat, ...
        subj, condname{k}, subjday(subj, k), data.trialinfo(t, end), t, data.trialinfo(t, cfg.intor.info), ...
        data.label{e}, pow(t,e), powlog(t,e), logpow(t,e));
    end
  end
  %-----------------%
  
end
%-------------------------------------%

%-------------------------------------%
%-write to file
fid = fopen(cfg.intor.csv, 'a+');
fprintf(fid, dat);
fclose(fid);
%-------------------------------------%

%---------------------------%
%-end log
toc_t = toc(tic_t);
outtmp = sprintf('(p%02.f) %s ended at %s on %s after %s\n\n', ...
  subj, mfilename, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'), ...
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
%-subfunction FINDBIGGEST
function lgrp_i = findbiggest(x)
i_x = find(x > 0);

i_bnd = find(diff(i_x) ~= 1);
bnd = [1 i_bnd+1; i_bnd numel(i_x)]';

for i = 1:size(bnd,1)
  grp(i) = sum(x(i_x(bnd(i,1)):i_x(bnd(i,2))));
end

[~, lgrp] = max(grp);
lgrp_i = i_x(bnd(lgrp,1)):(i_x(bnd(lgrp,2)));
%-------------------------------------%