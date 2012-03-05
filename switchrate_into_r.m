function switchrate_into_r(cfg, subj)
%SWITCHRATE_INTO_R write switchrate into R for nicer calculations

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
%-loop over test
getdur = @(x)[x(strcmp({x.type}, 'switch')).duration];
dat = '';

for k = 1:numel(cfg.test)
  
  %-----------------%
  %-input and output for each condition
  allfile = dir([ddir cfg.test{k} cfg.endname '.mat']); % files matching a preprocessing
  %-----------------%
  
  %-----------------%
  %-concatenate only if you have more datasets
  if numel(allfile) > 1
    spcell = @(name) sprintf('%s%s', ddir, name);
    allname = cellfun(spcell, {allfile.name}, 'uni', 0);
    
    cfg1 = [];
    cfg1.inputfile = allname;
    data = ft_appenddata(cfg1);
    
  elseif numel(allfile) == 1
    load([ddir allfile(1).name], 'data')
    
  else
    output = sprintf('%sCould not find any file in %s for test %s\n', ...
      output, ddir, cfg.test{k});
    
  end
  %-----------------%
  
  %-----------------%
  alldur = [];
  for i = 1:numel(data.cfg.previous)
    event = ft_findcfg(data.cfg.previous{i}, 'event');
    alldur = [alldur getdur(event)];
  end
  %-----------------%
  
  %-----------------%
  %-write to file
  for i = 1:numel(alldur)
    dat = sprintf('%s%1.f,%s,%1f\n', ....
      dat, subj, condname{k}, alldur(i));
  end
  %-----------------%
  
end
%-------------------------------------%

%-------------------------------------%
%-write to file
fid = fopen(cfg.switchrate.csv, 'a+');
fprintf(fid, dat);
fclose(fid);
%-------------------------------------%