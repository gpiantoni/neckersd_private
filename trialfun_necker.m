function [trl, event] = trialfun_necker(cfg)

% 12/02/04 fixneckerevent is a standalone function
% 12/02/01 more consistent output and events
% 09/07/17 created

%-----------------%
% set default for timing
if ~isempty(cfg.trialdef.prestim);  prestim  = cfg.trialdef.prestim;  else prestim  = 2; end
if ~isempty(cfg.trialdef.poststim); poststim = cfg.trialdef.poststim; else poststim = 2; end
if prestim < 0; warning('the trial does not contain the marker'); end
%-----------------%

%-----------------%
% read the header and event information
warning off % creating fake channel names
hdr = ft_read_header(cfg.headerfile);
evt = ft_read_event(cfg.headerfile);
warning on
%-----------------%

[~, filename] = fileparts(cfg.dataset);
fprintf('%s\n', filename);

event = fixneckerevent(evt, hdr);

trl = [event(1).sample+1 event(end).sample 0];