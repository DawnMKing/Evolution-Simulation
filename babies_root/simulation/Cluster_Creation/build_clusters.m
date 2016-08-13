%% build_clusters.m
% [num_clusters,trace_cluster,orgsnclusters] = build_clusters(base_name,run_name)
% Takes the population, simulation name, and the run name to return 
% num_clusters, trace_cluster, and orgsnclusters information while
% also saving the three information on clusters.  Within this function,
% trace_cluster_seed and population are used.
% Inputs:
% base_name = experiment base name
% run_name = string representation of specific simulation run number
% Outputs:
% num_clusters = vector of number of clusters per generation
% trace_cluster = each indiv's cluster assignment listed in order by generation
% orgsnclusters = number of indivs in each cluster
% function [num_clusters,trace_cluster,orgsnclusters] = build_clusters(base_name,run_name,limit)
function [num_clusters,trace_cluster,orgsnclusters] = build_clusters(base_name,run_name), 
global SIMOPTS;
this_script = 'build_clusters';
num_clusters = [];  trace_cluster = []; orgsnclusters = [];
if (exist([make_data_name('num_clusters',base_name,run_name,0) '.mat'])~=2 || ...
    exist([make_data_name('trace_cluster',base_name,run_name,0) '.mat'])~=2 || ...
    exist([make_data_name('orgsnclusters',base_name,run_name,0) '.mat'])~=2) || ...
    SIMOPTS.write_over==1, 
go = 1;

  [tcs,go] = try_catch_load(['trace_cluster_seed_' base_name run_name],go,1);

if go==1,
% trace_cluster_seed = uint16(trace_cluster_seed);
[p,go] = try_catch_load(['population_' base_name run_name],go,1); %load population
if go==1, 
population = p.population;  clear p
trace_cluster_seed = tcs.trace_cluster_seed;  clear tcs

fprintf([this_script ' for ' base_name run_name '\n']);

NGEN = length(find(population));  %get number of generations
trace_cluster = zeros(sum(population),1); %initialize trace_cluster
num_clusters = zeros(1,NGEN); %initialize num_clusters
orgsnclusters = []; %allocate memory for orgsnclusters
onc = []; %allocate memory for temporary holder of orgsnclusters
rel = []; %allocate memory for relatives not yet checked
u = 0;  v = 0;  %u and v are the lower and upper indices for indivs of each generation

for gen = 1:NGEN, %for each generation
  script_gen_update(this_script,gen,base_name,run_name);
  u = 1 +v; %increment lower limit of long seed list
  v = sum(population(1:gen)); %increment upper limit of long seed list
  tc = zeros(v-u+1,1);  %initialize labeler of this generation
  if SIMOPTS.limit~=3, 
    seeds = trace_cluster_seed(u:v,1) %get seeds of this generation
  else, 
    seeds = trace_cluster_seed(u:v,:); %get seeds of this generation
  end
  c = 0;  %initialize current number of clusters counter and labeler
  for i=1:population(gen), %for each indiv of the population
    if tc(i)==0, %if indiv i is not labeled
      c = c +1; %there's a new cluster!
      relatives = [i, seeds(i,:)]  %start with current unassigned indiv and neighbors
      notdoneyet = 1; %determine if more labeling is needed
      while notdoneyet==1, %while there are still relatives not labeled
        rel = relatives(find(tc(relatives)~=c)) %determine relatives not labeled
%         tc(rel) = c;  %update cluster labels for relatives found
        if length(rel)~=0, %if all relatives have not been checked for other relatives
          tc(rel) = c  %update cluster labels for relatives found
          for j=rel, %check on those newly labeled
            [rr col] = find(seeds==j)  %check for relatives of not checked relatives
            %update relatives list 
            %[previously known, new guys, j's neighbors, new guys' neighbors]
            for lim = 1:(SIMOPTS.limit-1),
              relatives = unique([relatives, rr', seeds(j,:), seeds(rr,lim)'])
            end
          end
        else, %if all are labeled
          notdoneyet = 0; %exit while loop
        end
%         tc(relatives) = c;  %update cluster labels for relatives found
      end
      onc = [onc, length(find(tc(relatives)==c))] %record number of indivs in c
    end
  end
  num_clusters(gen) = c;  %how many unique cluster values
  orgsnclusters = [orgsnclusters, onc]; %how many indivs in each cluster
  trace_cluster(u:v) = tc;  %cluster labels
  onc = []; seeds = []; %reset for next generation
end
%save the important stuff; note they won't be named the same as actual
%output files from simulations
% if SIMOPTS.limit~=3, 
%   save(['orgsnclusters_' base_name int2str(SIMOPTS.limit) '_limit_' run_name],'orgsnclusters');
%   save(['num_clusters_' base_name int2str(SIMOPTS.limit) '_limit_' run_name],'num_clusters');
%   save(['trace_cluster_' base_name int2str(SIMOPTS.limit) '_limit_' run_name],'trace_cluster');
% else, 
   save(['orgsnclusters_' base_name run_name],'orgsnclusters');
   save(['num_clusters_' base_name run_name],'num_clusters');
   save(['trace_cluster_' base_name run_name],'trace_cluster');
% end
end %population
end %trace_cluster_seed
end %exists
end %function