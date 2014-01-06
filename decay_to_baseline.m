function decay_to_baseline(info, opt)
%DECAY_TO_BASELINE compute decay of alpha power based on last seconds
%
% INFO
%  .log
%
% CFG.OPT
%  .csvname
%  .powtype 
%  .baseline

opt.baseline = [-2 -1.5];

%---------------------------%
%-start log
output = sprintf('%s began at %s on %s\n', ...
  mfilename,  datestr(now, 'HH:MM:SS'), datestr(now, 'dd-mmm-yy'));
tic_t = tic;
%---------------------------%

%---------------------------%
%-read
colnames = {'subj', 'cond', 'day', 'sess', 'trl', 'dur', 'time', 'pow', 'pow1', 'pow2', 'pow3', 'pow4'};
for col = 1:numel(colnames)
  decay.(colnames{col}) = [];
end


f = fopen(opt.csvname, 'r');
cnt = 0;
while ~feof(f)
  l = fgetl(f);
  cnt = cnt + 1;
  
  val = textscan(l, '%d%s%d%d%d%f%f%f%f%f%f%f', 'delimiter', ',');
  
  for col = 1:numel(colnames)
    if col == 2
      if strcmp(val{col}, 'ns')
        val{col} = 1;
      elseif strcmp(val{col}, 'sd')
        val{col} = 2;
      end
    end
    
    decay.(colnames{col}) = [decay.(colnames{col}); val{col}];
  end
  
end

fclose(f);
decay.dur = -1 * decay.dur;
%---------------------------%

%---------------------------%
%-normalize to baseline
all_combinations = double(decay.subj) * 1e6 + double(decay.cond) * 1e5 + double(decay.sess) * 1e4 + double(decay.trl);
n_rows = numel(unique(all_combinations));

col_timecourse = {'subj', 'cond', 'sess', 'trl'};
for i = unique(decay.dur)'
  col_timecourse = [col_timecourse sprintf('%06.1f', i)]; 
end

timecourse = NaN(n_rows, numel(col_timecourse));

cnt = 0;
for s = unique(decay.subj)'
  for c = unique(decay.cond(decay.subj == s))'
    for ss = unique(decay.sess(decay.subj == s & decay.cond == c))'
      for t = unique(decay.trl(decay.subj == s & decay.cond == c & decay.sess == ss))'
        cnt = cnt + 1;
        timecourse(cnt, 1) = s;
        timecourse(cnt, 2) = c;
        timecourse(cnt, 3) = ss;
        timecourse(cnt, 4) = t;
        for d = unique(decay.dur(decay.subj == s & decay.cond == c & decay.sess == ss & decay.trl == t))'
          i_row = decay.subj == s & decay.cond == c & decay.sess == ss & decay.trl == t & decay.dur == d;
          if numel(find(i_row)) ~= 1
            disp('error')
          end
          i_col = strcmp(col_timecourse, sprintf('%06.1f', d));
          timecourse(cnt, i_col) = decay.(opt.powtype)(i_row);
          
        end
      end
    end
  end
end
%---------------------------%

%---------------------------%
%-correct baseline
bl1 = find(strcmp(col_timecourse, sprintf('%06.1f', opt.baseline(1))));
bl2 = find(strcmp(col_timecourse, sprintf('%06.1f', opt.baseline(2))));

for i = 1:size(timecourse, 1)
  timecourse(i, 5:end) = log(timecourse(i, 5:end) / nanmean(timecourse(i, bl1:bl2)));  
end
%---------------------------%

%---------------------------%
subj_timecourse = nan(numel(unique(decay.subj)), size(timecourse, 2) - 4);
for s = unique(decay.subj)'
  i_row = timecourse(:, 1) == s & timecourse(:, 2) == 2;
  subj_timecourse(s, :) = nanmean(timecourse(i_row, 5:end));
end
%---------------------------%

%---------------------------%
%-make a plot
n = sum(~isnan(subj_timecourse), 1);
m = nanmean(subj_timecourse);
sd = nanstd(subj_timecourse);
sem = sd ./ sqrt(n);

output = [output sprintf('% 5.1f\t', unique(decay.dur)') '\n'];
output = [output sprintf('%0.4f\t', m) '\n'];
output = [output sprintf('%0.4f\t', sem) '\n'];
output = [output sprintf('%d\t', n) '\n'];
%---------------------------%

%---------------------------%
%-plot
h = figure('vis', 'off');
hold on
plot( unique(decay.dur)', m)
plot( unique(decay.dur)', m + sem / 2, 'color',[.5 .5 .5])
plot( unique(decay.dur)', m - sem / 2, 'color',[.5 .5 .5])
saveas(h, [info.log filesep 'alpha_decay.png'])
saveas(h, [info.log filesep 'alpha_decay.pdf'])
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
fid = fopen([info.log '.txt'], 'a');
fwrite(fid, output);
fclose(fid);
%-----------------%
%---------------------------%