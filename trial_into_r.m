function trial_into_r(info, opt, subj)
%TRIAL_INTO_R convert power data into R
% only frequency, but maybe more points?
% 
% INFO
%  .log
% 
% CFG.OPT
%  .cond
%  .freq: two scalars for frequency limit
%  .time: time of interest 
%  .wndw: length of time window
%  .powcorr: which column from trialinfo

error('to be tested with time')

%---------------------------%
%-start log
output = sprintf('%s (%04d) began at %s on %s\n', ...
  mfilename, subj, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
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

%-------%
%-get cond names
uniquecond = eq(opt.cond{1}, opt.cond{2});
for i = 1:numel(opt.cond)
  condname{i} = opt.cond{i}(~uniquecond);
end
%-------%
%-----------------%

dat = '';
%-------------------------------------%
%-loop over conditions
for k = 1:numel(opt.cond)
  
  %---------------------------%
  %-condition to read
  cond = opt.cond{k};
  %---------------------------%
  
  %---------------------------%
  %-read data
  [data] = load_data(info, subj, cond);
  if isempty(data)
    output = sprintf('%sCould not find any file for condition %s\n', ...
      output, cond);
    continue
  end
  %---------------------------%
  
  %---------------------------%
  %-pow on peak
  cfg1 = [];
  cfg1.method = 'mtmconvol';
  cfg1.output = 'pow';
  cfg1.taper = 'hanning';
  cfg1.foilim = opt.freq;
  
  trldur = length(data.time{1})/data.fsample;
  foi = opt.freq(1) : 1/trldur : opt.freq(2);
  cfg1.t_ftimwin = opt.wndw * ones(numel(foi),1);
  cfg1.toi = opt.time;
  cfg1.feedback = 'none';
  cfg1.keeptrials = 'yes';
  freq = ft_freqanalysis(cfg1, data);
  
  pow = mean(freq.powspctrm,3);
  powlog = mean(log(freq.powspctrm),3);
  logpow = log(mean(freq.powspctrm,3));
  %---------------------------%
  
  %---------------------------%
  %-write to file
  for t = 1:size(pow,1);
    for e = 1:size(pow,2);
      dat = sprintf('%s%03.f,%s,%1.f,%1.f,%1.f,%1f,%s,%1f,%1f,%1f\n', ....
        dat, ...
        subj, condname, subjday(subj, k_nssd), data.trialinfo(t, end), t, data.trialinfo(t, opt.powcorr), ...
        data.label{e}, pow(t,e), powlog(t,e), logpow(t,e));
    end
  end
  %---------------------------%
  
end
%-------------------------------------%

%-------------------------------------%
%-write to file
fid = fopen(opt.csv, 'a+');
fprintf(fid, dat);
fclose(fid);
%-------------------------------------%

%---------------------------%
%-end log
toc_t = toc(tic_t);
outtmp = sprintf('%s (%04d) ended at %s on %s after %s\n\n', ...
  mfilename, subj, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'), ...
  datestr( datenum(0, 0, 0, 0, 0, toc_t), 'HH:MM:SS'));
output = [output outtmp];

%-----------------%
fprintf(output)
fid = fopen([info.log '.txt'], 'a');
fwrite(fid, output);
fclose(fid);
%-----------------%
%---------------------------%