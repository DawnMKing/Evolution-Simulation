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
[pop,go] = try_catch_load(['population_' base_name run_name],go,1); %load population
if go == 1,
[p,go] = try_catch_load(['parents_' base_name run_name],go,1);
if go==1, 
parents = p.parents;  clear p    
population = pop.population;  clear pop
trace_cluster_seed = tcs.trace_cluster_seed;  clear tcs


fprintf([this_script ' for ' base_name run_name '\n']);
  %get number of generations
trace_cluster = zeros(sum(population),1); %initialize trace_cluster
num_clusters = zeros(1,SIMOPTS.NGEN); %initialize num_clusters
phyla = cell(SIMOPTS.NGEN, max(population));
 par_block = cell(SIMOPTS.NGEN-1,max(population));
      
orgsnclusters = []; %allocate memory for orgsnclusters
onc = []; %allocate memory for temporary holder of orgsnclusters
rel = []; %allocate memory for relatives not yet checked
u = 0;  v = 0; u1 = 0; v1 = 0; %u and v are the lower and upper indices for indivs of each generation
time_direction =-1; pgen=SIMOPTS.NGEN;
for gen = 1:SIMOPTS.NGEN, %for each generation
   merge=[];
  script_gen_update(this_script,gen,base_name,run_name);
  u = 1 +v; %increment lower limit of long seed list
  v = sum(population(1:gen)); %increment upper limit of long seed list
  tc = zeros(v-u+1,1);  %initialize labeler of this generation
  
    seeds = trace_cluster_seed(u:v,1) %get seeds of this generation
  if gen>1  
      pgen = pgen+time_direction;
     u1 =u-2; v1=v-2;
            %[u1,v1] = gen_index(population(2:end),pgen);  %index of clusters                         
     pars    = parents(u1:v1,:)  
  else
      pars=[];
  end
    
  c = 0;  %initialize current number of clusters counter and labeler
  for i=1:population(gen), %for each indiv of the population
    if tc(i)==0, %if indiv i is not labeled
        marks = [];
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
      y = find(tc(relatives)==c)
      onc = [onc, length(y)] 
      phyla{gen,c} = relatives%record number of indivs in c
      if gen > 1
     for m = relatives
         marks = [marks; pars(m,:)]
     end
     par_block{gen-1,c} = unique(marks)
     end
    end
  end
  %%%%check parent block for mergers
  if gen>1
  it = cellfun('isempty',par_block(gen-1,:))
  iter = find(it==0)
  iterate = length(iter)

      for jm = 1:iterate-1
          for jk = 2:iterate
          num_same = union(par_block{gen-1,jm}, par_block{gen-1,jk})
          if num_same>0
              merge = [merge; [jm jk]]
          end
      end
  
  
  
  
  end
  num_clusters(gen) = c  %how many unique cluster values
  orgsnclusters = [orgsnclusters, onc] %how many indivs in each cluster
  trace_cluster(u:v) = tc  %cluster labels
  onc = []; seeds = []; %reset for next generation
end
%save the important stuff; note they won't be named the same as actual
%output files from simulations
% if SIMOPTS.limit~=3, 
%   save(['orgsnclusters_' base_name int2str(SIMOPTS.limit) '_limit_' run_name],'orgsnclusters');
%   save(['num_clusters_' base_name int2str(SIMOPTS.limit) '_limit_' run_name],'num_clusters');
%   save(['trace_cluster_' base_name int2str(SIMOPTS.limit) '_limit_' run_name],'trace_cluster');
% else, 
%   save(['orgsnclusters_' base_name run_name],'orgsnclusters');
%   save(['num_clusters_' base_name run_name],'num_clusters');
%   save(['trace_cluster_' base_name run_name],'trace_cluster');
% end
end %if go: population
end%if go:parents
end %if go: trace_cluster_seed
end %exists
end %function'