%% get_indiv_cluster_lineage.m
%
%
this_script = 'get_indiv_cluster_lineage';
fprintf([this_script '\n']);
global SIMOPTS;
% close all;
for op = overpop, SIMOPTS.op = op;
for dm = death_max, SIMOPTS.dm = dm;
for mu = mutability, SIMOPTS.mu = mu;
  make_dir = 0; [base_name,dir_name] = NameAndCD(make_dir);
  for run = SIMS
    run_name = int2str(run);
    if exist([make_data_name('num_descendant_clusters',base_name,run_name,0)...
              '.mat'])~=2 && exist([make_data_name('num_descendants',base_name,run_name,0)...
                                    '.mat'])~=2, 
    go = 1;
    [nd,go,error] = try_catch_load(['num_descendants_' base_name run_name],go);
    if go==1, [par,go,error] = try_catch_load(['parents_' base_name run_name],go);
    if go==1, [pop,go,error] = try_catch_load(['population_' base_name run_name],go);
    if go==1, [tc,go,error] = try_catch_load(['trace_cluster_' base_name run_name],go);
    if go==1, [nc,go,error] = try_catch_load(['num_clusters_' base_name run_name],go);
    if go==1,             
      fprintf([this_script ' for ' base_name run_name '\n']);      
      population = pop.population;  clear pop
      parents = par.parents;  clear par
      num_descendants = nd.num_descendants; clear nd
      trace_cluster = tc.trace_cluster; clear tc
      num_clusters = nc.num_clusters; clear nc

      ngen = length(find(population>=limit));
      ipop = population(1);
      tc = trace_cluster(ipop+1:end);
      num_descendant_clusters = zeros(size(num_descendants)); %initialize descendant cluster counts
      num_descendant_clusters(:,1) = ones(ipop,1);  %first generation contains only one cluster each
      descendant_clusters = zeros(ipop,size(find(num_descendant_clusters),2));
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
          desc_clus = [desc_clus, unique(into_these_clusters)']; %#ok<AGROW> %track involved clusters
          num_descendant_clusters(indiv,gen-1) = length(unique(into_these_clusters));  %count clusters
          old_orgs = new_orgs;
        end
        descendant_clusters = cat_row(descendant_clusters,desc_clus);
      end
%% algorithm end      
      save(make_data_name('num_descendant_clusters',base_name,run_name,0),...
                          'num_descendant_clusters');
      save(make_data_name('descendant_clusters',base_name,run_name,0),...
                          'descendant_clusters');
    end
    end
    end
    end
    end
    end
  end
end
end
end