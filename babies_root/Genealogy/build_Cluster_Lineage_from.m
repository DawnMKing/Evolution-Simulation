%% build_Cluster_Lineage_from.m
% Two data vectors are saved, num_clusters_produced & clusters_produced. num_clusters_produced(x) tells the number of offspring
% clusters come from each parent cluster, so it's length is sum(population(1:(NGEN-1))) to
% index the parent information. clusters_produced tells which offspring clusters came from each parent
% cluster, so each set of offspring clusters is grouped by a length of num_clusters_produced(x), in 
% order of parent cluster id by generation.
% This function uses population, parents, num_clusters, and trace_clusters. It also
% considers the cluster seed limit value (limit), so it will name the mat files
% accordingly.
% 
% if num_clusters_produced(x) = 0, then parent cluster died out
% if num_clusters_produced(x) = 1, then pure cluster
% if num_clusters_produced(x) > 1, then parent clusters split (diverge)
this_script = 'build_Cluster_Lineage_from';
fprintf([this_script '\n']);
global SIMOPTS;
for op = overpop, SIMOPTS.op = op;
for dm = death_max, SIMOPTS.dm = dm;
for mu = mutability, SIMOPTS.mu = mu;
  make_dir = 0; [base_name,dir_name] = NameAndCD(make_dir);
  for run = SIMS
    run_name = int2str(run);
    if exist([make_data_name('clusters_produced',base_name,run_name,0)...
              '.mat'])~=2 && exist([make_data_name('num_clusters_produced',base_name,run_name,0)...
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
      clusters_produced = [];  %the offspring clusters from each parent cluster
      num_clusters_produced = zeros(sum(num_clusters(1:(ngen-1))),1);  %the number of offspring clusters from each parent cluster
      for gen = 1:(ngen-1)
        script_gen_update(this_script,gen,base_name,run_name);
        ou = ov +1; ov = sum(population(2:(gen+1)));
        pu = pv +1; pv = sum(population(1:gen));
        ocu = ocv +1; ocv = sum(num_clusters(2:(gen+1)));
        pcu = pcv +1; pcv = sum(num_clusters(1:gen));

        par = parents(ou:ov,:);
        offspring_clusters = trace_cluster((pv+1):(ov+IPOP));
        parent_clusters = trace_cluster(pu:pv);
        for pc = 1:num_clusters(gen)
          parents_of_clusters = find(parent_clusters==pc);
          offspring_of_parents_of_clusters = [];
          for ip = 1:length(parents_of_clusters)
            offspring_of_parents_of_clusters = unique([offspring_of_parents_of_clusters; ...
                                                       find(par(:,1)==parents_of_clusters(ip)); ...
                                                       find(par(:,2)==parents_of_clusters(ip))]);
          end
          clusters_of_offspring = unique(offspring_clusters(offspring_of_parents_of_clusters));
          num_clusters_produced(pcu+pc-1) = length(clusters_of_offspring);
          clusters_produced = [clusters_produced; clusters_of_offspring];
        end
      end
      % end debug level
      save(make_data_name('clusters_produced',base_name,run_name,0),'clusters_produced');
      save(make_data_name('num_clusters_produced',base_name,run_name,0),'num_clusters_produced');
    end
    end
    end
    end
    end
  end
end
end
end