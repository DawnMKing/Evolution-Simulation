%% make_data_name.m
% [data_name] = make_data_name(d_name,base_name,run_name,exp_type,reproduction,limit,generalize)
% 
% This function may be used as a general function to create a string which
% describes a babies data filename. It may also be used to generalize a
% base simulation name. This function also makes use of different
% clustering limits, so it may be used for the non-default limit addition
% to some filenames which are not used for the population-based data like
% population, trace_x, trace_y, etc.
%
% output:
%   data_name - resulting full data name 
% input:
%   d_name - string of the data name
%   base_name - string of simulation name from NameAndCD
%   run_name - string of the run number
%   exp_type - experiment type value from main
%   reproduction - reproduction value from main
%   limit - cluster seed minimum
%   generalize - boolean, 0 = don't generalize base_name, 1 = generalize base
%   name
% function [data_name] = make_data_name(d_name,base_name,run_name,exp_type,reproduction,limit,generalize)
function [data_name] = make_data_name(d_name,base_name,run_name,generalize)
global SIMOPTS;
% population, trace_x, trace_y, parents, trace_cluster_seed, and
% seed_distances don't generalize so make their lim the default limit = 3
if length(d_name)==7, 
  if sum(d_name)==sum('trace_x') || sum(d_name)==sum('trace_y') || sum(d_name)==sum('parents'),
    lim = 3;
  else, 
    lim = SIMOPTS.limit;
  end
elseif length(d_name)==10, 
  if sum(d_name)==sum('population'), 
    lim = 3;
  else, 
    lim = SIMOPTS.limit;
  end
elseif length(d_name)==14, 
  if sum(d_name)==sum('seed_distances'), 
    lim = 3;
  else, 
    lim = SIMOPTS.limit;
  end
elseif length(d_name)==18, 
  if sum(d_name)==sum('trace_cluster_seed'), 
    lim = 3;
  else, 
    lim = SIMOPTS.limit;
  end
else
  lim = SIMOPTS.limit;
end
data_name = [];
if lim==3, 
  if generalize==1, 
    if length(d_name)==0, 
      data_name = generalize_base_name(base_name);
    else, 
      data_name = [d_name '_' generalize_base_name(base_name)];
    end
  else, 
    if length(d_name)==0, 
      if length(run_name)==0, 
        data_name = [base_name(1:(length(base_name)-1))];
      else, 
        data_name = [base_name run_name];
      end
    else, 
      if length(run_name)==0, 
        data_name = [d_name '_' base_name(1:(length(base_name)-1))];
      else, 
        data_name = [d_name '_' base_name run_name];
      end
    end
  end
else, 
  if generalize==1
    if length(d_name)==0
      data_name = [generalize_base_name(base_name) '_' int2str(lim) '_limit'];
    else, 
      data_name = [d_name '_' generalize_base_name(base_name) '_' int2str(lim) '_limit'];
    end
  else, 
    if length(d_name)==0, 
      if length(run_name)==0, 
        data_name = [base_name int2str(lim) '_limit'];
      else, 
        data_name = [base_name int2str(lim) '_limit_' run_name];
      end
    else, 
      if length(run_name)==0, 
        data_name = [d_name '_' base_name int2str(lim) '_limit'];
      else, 
        data_name = [d_name '_' base_name int2str(lim) '_limit_' run_name];
      end
    end
  end
end
end