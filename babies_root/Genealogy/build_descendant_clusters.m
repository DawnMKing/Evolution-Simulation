%% build_descendant_clusters.m
% function [num_descendant_clusters,descendant_clusters] = build_descendant_clusters(...
%   base_name,run_name)
% This determines the cluster associations within each lineage of the
% original population, IPOP. This depends upon the data from population,
% trace_cluster, parents, num_clusters, and num_descendants. The output
% comes as two data objects. num_descendant_clusters is a matrix with the
% same dimensions as num_descendants (see build_descendants.m for details).
% descendant_clusters is organized with rows for each of the cluster
% lineage details from the original population, IPOP. The columns list the
% clusters each lineage is involved in and has length 
% max(sum(num_descendant_clusters,2)). The majority of the final columns
% will likely be zeros, which is fine since num_descendant_clusters tells
% how many clusters are listed for each generation, and this is generally 
% highly variable for each lineage. Think of num_descendant_clusters as the
% analog to num_clusters & descendant_clusters as the analog to
% trace_cluster; each are arranged by generation in sets.
function [num_descendant_clusters,descendant_clusters] = build_descendant_clusters(...
  base_name,run_name) 
global SIMOPTS;
num_descendant_clusters = []; descendant_clusters = [];
this_script = 'build_descendant_clusters';

go = 1;
[nd,go,error] = try_catch_load(['num_descendants_' base_name int2str(SIMOPTS.limit)...
                '_limit_' run_name],go,1);
if go==1, [par,go,error] = try_catch_load(['parents_' base_name run_name],go,1);
if go==1, [pop,go,error] = try_catch_load(['population_' base_name run_name],go,1);
if go==1, [tc,go,error] = try_catch_load(['trace_cluster_' base_name run_name],go,1);
if go==1, [nc,go,error] = try_catch_load(['num_clusters_' base_name run_name],go,1);
if go==1,             
  fprintf([this_script ' for ' base_name run_name '\n']);      
  population = pop.population;  clear pop
  parents = par.parents;  clear par
  num_descendants = nd.num_descendants; clear nd
  trace_cluster = tc.trace_cluster; clear tc
  num_clusters = nc.num_clusters; clear nc

  ngen = length(find(population>=SIMOPTS.limit));
  ipop = population(1);
  tc = trace_cluster(ipop+1:end);
  num_descendant_clusters = zeros(size(num_descendants)); %initialize descendant cluster counts
  num_descendant_clusters(:,1) = ones(ipop,1);  %first generation contains only one cluster each
  %descendant_clusters = zeros(ipop,size(find(num_descendant_clusters),2))
%% debug variables
% population = [6 8 7 4];
% parents = [1 2 2 4 5 5 6 6, 2 3 5 5 6 6 8, 4 4 5 7]';
% trace_cluster = [1 2 1 1 2 2, 1 1 2 1 1 1 2 2, 1 2 1 1 1 2 2, 1 1 1 1];
% tc = trace_cluster(ipop+1:end);
% num_descendants = [1 0 0; 2 2 0; 0 0 0; 1 0 0; 2 4 3; 2 1 1];
% ngen = length(population);
% ipop = population(1);
% num_descendant_clusters = zeros(size(num_descendants));
% descendant_clusters = [];
% expect num_descendant_clusters = [1 2 0 1 1 1; 0 2 0 0 2 1; 0 0 0 0 1 1]'
%% algorithm start
  for indiv = 1:ipop, 
    indiv_update(indiv);
    old_orgs = indiv;
    u = ipop; v = 0;  %population indices
    pu = 0; pv = 0; %parents indices
    linlt = length(find(num_descendants(indiv,:))) +1; %lineage lifetime
    desc_clus = []; %contains this indiv's descendant clusters
    for gen = 2:linlt, 
      u = v +1; v = sum(population(1:gen));
      pu = pv +1; pv = sum(population(2:gen));  %update parents indices
      this_gens_pars = parents(pu:pv,1);
      new_orgs = [];
      for i = 1:length(old_orgs), %get the children from the current parents
        new_orgs = [new_orgs; find(this_gens_pars==old_orgs(i))]; %#ok<AGROW>
      end
      into_these_clusters = [];
      into_these_clusters = tc(pu-1+new_orgs); %get these_orgs' cluster ID's
      desc_clus = [desc_clus, unique(into_these_clusters)'] %#ok<AGROW> %track involved clusters
      num_descendant_clusters(indiv,gen-1) = length(unique(into_these_clusters));  %count clusters
      old_orgs = new_orgs;
    end
    descendant_clusters = cat_row(descendant_clusters,desc_clus)
  end
%% algorithm end      
  save(make_data_name('num_descendant_clusters',base_name,run_name,0),...
                      'num_descendant_clusters');
  save(make_data_name('descendant_clusters',base_name,run_name,0),...
                      'descendant_clusters');
end %num_clusters
end %trace_cluster
end %population
end %parents
end %num_descendants

end %funciton