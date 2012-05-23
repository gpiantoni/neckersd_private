function between_into_r(cfg, subj)
%BETWEEN_INTO_R convert power data into R, using inbetween data
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
%-use predefined power-peaks for areas of interest
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
  %-loop over session
  for i = 1:numel(allfile)
    load([ddir allfile(i).name], 'data')
    
    cfg1 = [];
    cfg1.method = 'mtmfft';
    cfg1.output = 'pow';
    cfg1.taper = 'hanning';
    cfg1.foilim = powpeak(f).freq;
    cfg1.feedback = 'none';
    cfg1.keeptrials = 'yes';
    freq = ft_freqanalysis(cfg1, data);
    
    pow = mean(freq.powspctrm,3);
    powlog = mean(log(freq.powspctrm),3);
    logpow = log(mean(freq.powspctrm,3));
    
    trl = unique(freq.trialinfo(:,1));
    ntrl = numel(trl);
    
    for t = 1:ntrl
      itrl = trl(t);
      iseg = find(data.trialinfo(:,1) == itrl);

      for e = 1:size(pow,2);
        
        dat = sprintf('%s%03.f,%s,%1.f,%1.f,%1.f,%1f,%s,%1f,%1f,%1f\n', ....
          dat, ...
          subj, condname{k}, subjday(subj, k), i, t, data.trialinfo(iseg(1), cfg.intor.info), ...
          data.label{e}, mean(pow(iseg, e)), mean(powlog(iseg, e)), mean(logpow(iseg, e)));
        
      end
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