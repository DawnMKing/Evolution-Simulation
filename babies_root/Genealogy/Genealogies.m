%% Genealogies.m
% function [times] = Genealogies()
% Determines (num_descendants), num_descendant_clusters, descendant_clusters,
% num_clusters_fused, clusters_fused, num_clusters_produced, and clusters_produced
% given the necessary parameter options in SIMOPTS.
% The output gives the time to complete each run round (so length is that of SIMS) 
% of genealogy functions.
function [times] = Genealogies()
global SIMOPTS;
make_dir = 0; [base_name,dir_name] = NameAndCD(make_dir);
i = 0;  tic;
for run = SIMOPTS.SIMS, 
  i = i +1;
  run_name = int2str(run);
%   fprintf(['generating genealogy data for ' make_data_name('',base_name,run_name,0) '\n']);
if SIMOPTS.do_build_species_tree==1, 
      [nd] = build_species(base_name,run_name);  end
  if SIMOPTS.do_indiv_lineage==1, 
      [nd] = build_num_descendants(base_name,run_name);  end
  if SIMOPTS.do_indiv_cluster_lineage==1, 
    [ndc,dc] = build_descendant_clusters(base_name,run_name); clear ndc dc;  end
  if SIMOPTS.do_cluster_lineage==1, 
    [ncf,cf] = build_clusters_fused(base_name,run_name); clear ncf cf; 
    [ncp,cp] = build_clusters_produced(base_name,run_name);  clear ncp cp; end
  times(i) = toc;
end
end