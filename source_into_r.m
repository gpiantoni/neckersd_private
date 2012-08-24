function source_into_r(cfg, subj)
%SOURCE_INTO_R calculate power at the source level and use it for
%correlation
% only one time point and frequency
%
% TODO: use a baseline condition

%---------------------------%
%-start log
output = sprintf('%s (%04d) began at %s on %s\n', ...
  mfilename, subj, datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

[vol, lead, sens] = load_headshape(cfg, subj);

%-------------------------------------%
%-loop over conditions
fid = fopen(sprintf('%s%04d.csv', cfg.soucorr.csv, subj), 'w+');

for k = 1:numel(cfg.soucorr.cond) % XXX cond can also be the 5 session
  
  cond     = cfg.soucorr.cond{k};
  condname = regexprep(cond, '*', '');
  
  %---------------------------%
  %-read data
  [data badchan] = load_data(cfg, subj, cond);
  if isempty(data)
    output = sprintf('%sCould not find any file for condition %s\n', ...
      output, cond);
    continue
  end
  
  outputfile = sprintf('soucorr_%04d_%s', subj, condname);
  %---------------------------%
  
  %---------------------------%
  %-remove bad channels from leadfield
  datachan = ft_channelselection([{'all'}; cellfun(@(x) ['-' x], badchan, 'uni', false)], data.label);
  [leadchan] = prepare_leadchan(lead, datachan);
  %---------------------------%
  
  %---------------------------%
  %-freq analysis
  tmpcfg = [];
  tmpcfg.method = 'mtmfft';
  tmpcfg.output = 'fourier';
 
  tmpcfg.taper = 'dpss';
  tmpcfg.foi = cfg.soucorr.freq;
  tmpcfg.tapsmofrq = cfg.soucorr.tapsmofrq;
  
  tmpcfg.feedback = 'none';
  tmpcfg.channel = datachan;

  freq = ft_freqanalysis(tmpcfg, data);
  %---------------------------%

  %---------------------------%
  %-source analysis (all trials)
  haslambda = isfield(cfg.soucorr.dics, 'lambda') && ~isempty(cfg.soucorr.dics.lambda);
  
  tmpcfg = [];
  
  tmpcfg.frequency = cfg.soucorr.freq;
  
  tmpcfg.method = 'dics';
  tmpcfg.dics = cfg.soucorr.dics;
  tmpcfg.dics.keepfilter = 'yes';
  tmpcfg.dics.feedback = 'none';
  
  tmpcfg.dics.lambda = '10%';
  
  tmpcfg.vol = vol;
  tmpcfg.grid = leadchan;
  tmpcfg.elec = sens;
  
  if haslambda && ~isfield(cfg.soucorr, 'noise') && ~isempty(cfg.soucorr.noise)
    tmpcfg.projectnoise = 'yes';
  end
  
  sou = ft_sourceanalysis(tmpcfg, freq);
  %---------------------------%
  
  %---------------------------%
  %-single trial analysis
  tmpcfg.grid.filter  = sou.avg.filter;
  tmpcfg.rawtrial = 'yes';
  soucorr = ft_sourceanalysis(tmpcfg, freq);
  pow = cat(1, soucorr.trial.pow);
  %---------------------------%

  %---------------------------%
  %-use noise if necessary
  if haslambda && ~isfield(cfg.soucorr, 'noise') && cfg.soucorr.noise
    noise = cat(1, soucorr.trial.noise);
    pow = pow ./ noise; % definition of NAI
  end
  %---------------------------%
  
  %---------------------------%
  %-log
  if ~isfield(cfg.soucorr, 'log') && cfg.soucorr.log
    pow = log(pow);
  end
  %---------------------------%
  
  %---------------------------%
  %-prepare CSV
  trl = unique(freq.trialinfo(:,1));
  ntrl = numel(trl);
  
  for t = 1:ntrl
    itrl = trl(t);
    iseg = find(data.trialinfo(:,1) == itrl);
    
    for e = 1:size(pow,2);
      
      text2write = sprintf('%03d,%s,%d,%d,%f,%d,%f\n', ....
        subj, condname, k, t, data.trialinfo(iseg(1), cfg.soucorr.info), ...
        e, mean(pow(iseg, e))); % mean over the segments

      fprintf(fid, text2write);
    end
  end
  %---------------------------%
  
end
%-----------------%

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
fid = fopen([cfg.log '.txt'], 'a');
fwrite(fid, output);
fclose(fid);
%-----------------%
%---------------------------%