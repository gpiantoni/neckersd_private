function switchrate(cfg)
%SWITCHRATE read the events (not the trials) and make nice stats in R

%---------------------------%
%-subfunction

%---------------------------%

%---------------------------%
%-read all the datasets
trialinfo = [];
for subj = subjall
  disp(subj)

end
%---------------------------%

%---------------------------%
%-hist and collect info
histedge = [0:2.5:60];
histall = NaN(numel(histedge), numel(subjall), numel(cfg.test));
for subj = subjall
  for k = 1:numel(cfg.test)
    %-----------------%
    %-duration
    histall(:,subj,k) = hist(trialinfo{subj,k}, histedge);
    %-----------------%
  end
end
%---------------------------%
    
%---------------------------%
%-get count data
rdir = '/data1/projects/neckersd/results/';

%-----------------%
%-absolute poisson test (on absolute values)
poisson_test = @(a,b) 1 - binocdf(max(a,b)-1,a+b,.5) + binocdf(min(a,b),a+b,.5);
sprintf('\nnecker switch after normal sleep% 5.f, after sleep deprivation% 5.f, P-value of Poisson test: %e\n', ...
sum(sum(histall(:,:,1))), sum(sum(histall(:,:,2))), ...
poisson_test(sum(sum(histall(:,:,1))), sum(sum(histall(:,:,2))))); % very significant
%-----------------%

%-----------------%
%-absolute distribution
h = figure;
plot(histedge, mean(histall(:,:,1),2))
hold on
plot(histedge, mean(histall(:,:,2),2), 'r')
xlim([histedge(1) histedge(end)])
xlabel('time bins in s')
ylabel('number of switches')
legend('ns', 'sd')
saveas(h, [rdir '120207a_switch_distribution_absolute.png'])
%-----------------%

%-----------------%
%-do stats in R
% This part creates a R file and csv databased, it executes "prop.test" and
% it returns the pval
progdir = '/data1/projects/neckersd/analysis/';
histfile = [progdir 'histall.csv'];
Rfile = [progdir 'rscript.R'];
csvwrite(histfile, squeeze(sum(histall,2)))

%-------%
%-R script
fid = fopen(Rfile, 'w+');
fprintf(fid, ['df <- read.csv(''%s'', header=FALSE) \n' ....
'p.val <- 0\n' ...
'for (i in 1:nrow(df)) { ptest <- prop.test(as.numeric(df[i,]), colSums(df)); p.val[i] <- ptest$p.value}\n' ...
'p.val[is.nan(p.val)] <- 1\n' ...
'write.table(p.val, ''%s'', col.names=FALSE, row.names=FALSE, sep='','')\n'], ...
histfile, histfile);
fclose(fid);
%-------%

system(['R CMD BATCH ' Rfile ]);
pval = csvread(histfile);
delete(histfile)
delete(Rfile)
%-----------------%

%-----------------%
%-probability distribution
clear pneck
pneck(:,:,1) = histall(:,:,1) / sum(sum(histall(:,:,1)));
pneck(:,:,2) = histall(:,:,2) / sum(sum(histall(:,:,2)));

h = figure;
plot(histedge, mean(pneck(:,:,1),2))
hold on
plot(histedge, mean(pneck(:,:,2),2), 'r')
xlim([histedge(1) histedge(end)])
xlabel('time bins in s')
ylabel('probability of switches')
legend('ns', 'sd')

%-------%
%-plot p-val
ypos = max(mean(pneck(:,:,1),2)) /2;
for i = 1:numel(pval)
  if pval(i) < 0.01
    plot(histedge(i), ypos, 'g*', 'markersize', 15)
  elseif pval(i) < 0.05
    plot(histedge(i), ypos, 'g*', 'markersize', 10)
  elseif pval(i) < 0.1
    plot(histedge(i), ypos, 'g.', 'markersize', 1)
  end

end
%-------%

saveas(h, [rdir '120207b_switch_distribution_relative.png'])
%-----------------%
%---------------------------%