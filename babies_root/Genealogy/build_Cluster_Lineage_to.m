%% build_Cluster_Lineage_to.m
% Two data vectors are saved, num_clusters_fused & clusters_fused. num_clusters_fused(x) tells the number of parent
% clusters to each offspring cluster, so it's length is sum(population(2:NGEN)) to
% index the offspring information. clusters_fused tells which parent clusters go to each offspring
% cluster, so each set of parent clusters is grouped by length of num_clusters_fused(x), in order of 
% offspring cluster id by generation.
% This function uses population, parents, num_clusters, and trace_clusters. It also
% considers the cluster seed limit value (limit), so it will name the mat files
% accordingly.
%
% if num_clusters_fused(x) = 0, then impossible
% if num_clusters_fused(x) = 1, then pure cluster from parent's generation
% if num_clusters_fused(x) > 1, then parent clusters mixed (converge)
this_script = 'build_Cluster_Lineage_to';
fprintf([this_script '\n']);
global SIMOPTS;
for op = overpop, SIMOPTS.op = op;
for dm = death_max, SIMOPTS.dm = dm;
for mu = mutability, SIMOPTS.mu = mu;
  make_dir = 0; [base_name,dir_name] = NameAndCD(make_dir);
  for run = SIMS
    run_name = int2str(run);
    if exist([make_data_name('clusters_fused',base_name,run_name,0)...
              '.mat'])~=2 && exist([make_data_name('num_clusters_fused',base_name,run_name,0)...
                                    '.mat'])~=2 
    go = 1;
    [tc,go,error] = try_catch_load(['trace_cluster_' base_name run_name],go,1);
    if go==1, [nc,go,error] = try_catch_load(['num_clusters_' base_name run_name],go,1);
    if go==1, [par,go,error] = try_catch_load(['parents_' base_name run_name],go,1);
    if go==1, [pop,go,error] = try_catch_load(['population_' base_name run_name],go,1);
    if go==1,             
      fprintf([this_script ' for ' base_name run_name '\n']);
      trace_cluster = tc.trace_cluster;  clear tc
      num_clusters = nc.num_clusters;  clear nc
      parents = par.parents;  clear par
      population = pop.population;  clear pop

      % begin debug level
      ou = 0; ov = 0; pu = 0; pv = 0; % Generational indices for offspring and parents
      ocu = 0;  ocv = 0;  pcu = 0;  pcv = 0;  % Generational indices for offspring and parent clusters
      ngen = length(population);
      IPOP = population(1);
      clusters_fused = [];  %the parent clusters to each offspring cluster
      num_clusters_fused = zeros(sum(num_clusters(2:ngen)),1);  %the number of parent clusters to each offspring cluster
      for gen = 1:(ngen-1), 
        script_gen_update(this_script,gen,base_name,run_name);
        ou = ov +1; ov = sum(population(2:(gen+1)));
        pu = pv +1; pv = sum(population(1:gen));
        ocu = ocv +1; ocv = sum(num_clusters(2:gen+1));
        pcu = pcv +1; pcv = sum(num_clusters(1:gen));

        par = parents(ou:ov,:);
        offspring_clusters = trace_cluster((pv+1):(ov+IPOP));
        parent_clusters = trace_cluster(pu:pv);
        for oc = 1:num_clusters(gen+1)
          offspring_of_clusters = find(offspring_clusters==oc);
          parents_of_offspring_of_clusters = unique([par(offspring_of_clusters,1); ...
                                                     par(offspring_of_clusters,2)]);
          clusters_of_parents = unique(parent_clusters(parents_of_offspring_of_clusters));
          num_clusters_fused(ocu+oc-1) = length(clusters_of_parents);
          clusters_fused = [clusters_fused; clusters_of_parents];
        end
      end
      % end debug level
      save(make_data_name('clusters_fused',base_name,run_name,0),'clusters_fused');
      save(make_data_name('num_clusters_fused',base_name,run_name,0),'num_clusters_fused');
    end
    end
    end
    end 
    end
  end
end
end
end