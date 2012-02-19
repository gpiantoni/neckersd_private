function [cond output] = event2trl_necker(cfg, event)
%EVENT2TRL_NECKER create four types of trials based on stim and resp
% Use as:
%   [cond output] = event2trl_gosdtrl(cfg, event)
% where
%   cfg is cfg.redef
%   
%   cond is a struct with
%     .name = 'tp'
%     .trl = [begsmp endsmp offset extra_trialinfo];
%     .trialinfo = extra_trialinfo (optional)
%   output is a text for output

% 12/02/07 take logarithm of durations afterwards
% 12/02/06 trialinfo is a separate field
% 12/02/03 created, based on event2trl_gosd

%-----------------%
%-create trl where there is a switch
mrk = find(strcmp({event.type}, cfg.trigger));

trl = [[event(mrk).sample] - cfg.prestim * cfg.fsample; ...
  [event(mrk).sample] + cfg.poststim * cfg.fsample; ...
  -cfg.prestim * cfg.fsample * ones(1,numel(mrk))]';

info = [[event(mrk).offset]' [event(mrk).duration]']; % there are the same but switch by one place
info(:,3) = log(info(:,2));
%-----------------%

%-----------------%
%-only keep switch if it's not too close to previous or following switch
enoughdist = all(info(:,1:2) > cfg.mindist, 2) & all(info(:,2) < cfg.maxdist,2);

cond(1).name = 'switch';
cond(1).trl = trl(enoughdist,:);
cond(1).trialinfo = info(enoughdist,:);
%-----------------%

%-----------------%
%-output
output = sprintf('   n events:% 3.f (total switch:% 3.f at mindist% 2.fs, maxdist% 2.fs)\n', ...
  numel(find(enoughdist)), numel(mrk), cfg.mindist, cfg.maxdist);
%-----------------%
