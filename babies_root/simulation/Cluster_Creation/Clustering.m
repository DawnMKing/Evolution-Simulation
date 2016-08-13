%% Clustering.m
% function [times] = Clustering()
% Determines trace_cluster_seed, seed_distances, num_clusters, trace_clusters, orgsncluster, 
% centroids of clusters and cluster_diversity given the necessary parameter options in SIMOPTS.
% The output gives the time to complete all clustering functions designated.
function [times] = Clustering()
global SIMOPTS;
make_dir = 0; [base_name,dir_name] = NameAndCD(make_dir);
i = 0;  tic;
for run = SIMOPTS.SIMS, 
  i = i +1;
  run_name = int2str(run);
%   fprintf(['generating cluster data for ' make_data_name('',base_name,run_name,0) '\n']);
  if SIMOPTS.reproduction==1, 
      [tcs] = build_cluster_seeds(base_name,run_name);  end
  if SIMOPTS.do_build_clusters==1, 
    [nc,tc,onc] = build_clusters(base_name,run_name); clear nc tc onc;  end
  if SIMOPTS.do_locate_clusters==1, 
    [cx,cy,cdiv] = locate_clusters(base_name,run_name); clear cx cy cdiv; end
  times(i) = toc;
end
end