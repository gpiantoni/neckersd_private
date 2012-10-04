function switch_into_r(info, opt, subj)
%SWITCH_INTO_R convert power data into R
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

%---------------------------%
%-start log
output = sprintf('%s (%04d) began at %s on %s\n', ...
  mfilename, subj, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

%-------------------------------------%
%-loop over conditions

if ~isfield(opt, 'trl_index'); opt.trl_index = true; end

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

csvname = regexprep(opt.cond{1}(uniquecond), '*', '');
%-------%
%-----------------%

%-------------------------------------%
%-loop over conditions
dat = '';

for k = 1:numel(opt.cond)
  
  for i = 1:5
    
    %---------------------------%
    %-read data
    cond2read = regexprep(opt.cond{k}, '*', sprintf('_%03d', i));
    [data] = load_data(info, subj, cond2read);
    if isempty(data)
      output = sprintf('%sCould not find any file for condition %s\n', ...
        output, cond2read);
      continue
    end
    %---------------------------%
    
    %---------------------------%
    %-pow on peak
    cfg = [];
    cfg.method = 'mtmconvol';
    cfg.output = 'pow';
    cfg.taper = 'hanning';
    cfg.foilim = opt.freq;
    
    trldur = length(data.time{1})/data.fsample;
    foi = opt.freq(1) : 1/trldur : opt.freq(2);
    cfg.t_ftimwin = opt.wndw * ones(numel(foi),1);
    cfg.toi = opt.time;
    
    cfg.feedback = 'none';
    cfg.keeptrials = 'yes';
    freq = ft_freqanalysis(cfg, data);
    
    pow = mean(freq.powspctrm,3);
    powlog = mean(log(freq.powspctrm),3);
    logpow = log(mean(freq.powspctrm,3));
    
    trl = unique(freq.trialinfo(:,1));
    ntrl = numel(trl);
    
    for t = 1:ntrl
      itrl = trl(t);
      iseg = find(data.trialinfo(:,1) == itrl);
      
      if opt.trl_index
        idur = iseg(1);
      else
        idur = t;
      end
      
      for e = 1:size(pow,2);
        
        dat = sprintf('%s%03.f,%s,%1.f,%1.f,%1.f,%1f,%s,%1f,%1f,%1f\n', ....
          dat, ...
          subj, condname{k}, subjday(subj, k), i, t, data.trialinfo(idur, opt.powcorr), ...
          data.label{e}, mean(pow(iseg, e)), mean(powlog(iseg, e)), mean(logpow(iseg, e)));
        
      end
    end
    %---------------------------%
  end
  
end
%-------------------------------------%

%-------------------------------------%
%-write to file
fid = fopen([info.dcor csvname '.csv'], 'a+');
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