function pow_into_r(cfg, subj)
%POW_INTO_R convert power data into R
% only one time point and frequency

% 12/02/19 gives output

%-----------------%
%-input
if nargin == 1
  subj = cfg.subj;
end
%-----------------%

%---------------------------%
%-start log
output = sprintf('(p%02.f) %s started at %s on %s\n', ...
  subj, mfilename,  datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

%---------------------------%
%-dir and files
ddir = sprintf('%s%04.f/%s/%s/', cfg.data, subj, cfg.mod, cfg.cond); % data

%-------%
%-get cond names
uniquecond = eq(cfg.test{1}, cfg.test{2});
for i = 1:numel(cfg.test)
  condname{i} = cfg.test{i}(~uniquecond);
end
%-------%
%---------------------------%

%-------------------------------------%
%-loop over conditions
dat = '';
for k = 1:numel(cfg.test)
  
  %-----------------%
  %-input and output for each condition
  allfile = dir([ddir '*' cfg.test{k} cfg.endname '.mat']); % files matching a preprocessing
  if isempty(allfile)
    continue
  end
  %-----------------%
  
  %-----------------%
  %-concatenate only if you have more datasets
  if numel(allfile) > 1
    spcell = @(name) sprintf('%s%s', ddir, name);
    allname = cellfun(spcell, {allfile.name}, 'uni', 0);
    
    cfg1 = [];
    cfg1.inputfile = allname;
    data = ft_appenddata(cfg1);
    
  else
    load([ddir allfile(1).name], 'data')
    
  end
  %-----------------%

  %-----------------%
  %-calculate power
  cfg2 = cfg.pow;
  cfg2.feedback = 'none';
  cfg2.keeptrials = 'yes';
  data = ft_freqanalysis(cfg2, data);
  data.time = cfg2.toi;
  %-----------------%
  
  %-----------------%
  %-write to file
  for t = 1:size(data.powspctrm,1);
    for e = 1:size(data.powspctrm,2);
      dat = sprintf('%s%03.f,%s,%1.f,%1f,%s,%1f\n', ....
        dat, ...
        subj, condname{k}, t, data.trialinfo(t, cfg.intor.info), ...
        data.label{e}, data.powspctrm(t,e));
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