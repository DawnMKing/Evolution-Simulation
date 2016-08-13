function [centroid_x,centroid_y,cluster_diversity] = locate_clusters(base_name,run_name), 
global SIMOPTS;
this_script = 'locate_clusters';
centroid_x = [];  centroid_y = [];  cluster_diversity = [];
if (exist([make_data_name('centroid_x',base_name,run_name,0) '.mat'])~=2 || ...
    exist([make_data_name('centroid_y',base_name,run_name,0) '.mat'])~=2 || ...
    exist([make_data_name('cluster_diversity',base_name,run_name,0) '.mat'])~=2) || ...
    SIMOPTS.write_over==1, 
go = 1;
[p,go] = try_catch_load(['population_' base_name run_name],go,1);
if go==1, [tx,go] = try_catch_load(['trace_x_' base_name run_name],go,1);
if go==1, [ty,go] = try_catch_load(['trace_y_' base_name run_name],go,1);
if go==1, 
if SIMOPTS.limit~=3, 
  [tc,go] = try_catch_load(['trace_cluster_' base_name int2str(SIMOPTS.limit) ...
                            '_limit_' run_name],go,1);  
else, 
  [tc,go] = try_catch_load(['trace_cluster_' base_name run_name],go,1);
end
if go==1, [nc,go] = try_catch_load(['num_clusters_' base_name run_name],go,1);
if go==1, 
population = p.population;  clear p
trace_x = tx.trace_x; clear tx
trace_y = ty.trace_y; clear ty
trace_cluster = tc.trace_cluster; clear tc
num_clusters = nc.num_clusters; clear nc

fprintf([this_script ' for ' base_name run_name '\n']);

NGEN = length(find(population));
centroid_x = zeros(sum(num_clusters),1);
% cstd_x = zeros(sum(num_clusters),1);
% cskew_x = zeros(sum(num_clusters),1);
centroid_y = zeros(sum(num_clusters),1);
% cstd_y = zeros(sum(num_clusters),1);
% cskew_y = zeros(sum(num_clusters),1);
cluster_diversity = zeros(sum(num_clusters),1);

low_p = 0; high_p = 0; low_nc = 0; high_nc = 0;

for gen = 1:NGEN, 
  low_p = high_p +1; high_p = sum(population(1:gen)); 
  indiv_x = trace_x(low_p:high_p);  indiv_y = trace_y(low_p:high_p);
  low_nc = high_nc +1; high_nc = sum(num_clusters(1:gen));
  cluster_labels = trace_cluster(low_p:high_p); 
  for this_cluster = 1:num_clusters(gen), 
    these_indivs = find(cluster_labels==this_cluster);  %indivs within cluster
    centroid_x(low_nc+this_cluster-1) = mean(indiv_x(these_indivs));  %calculate centroid_x
%     cstd_x(low_nc+this_cluster-1) = std(indiv_x(these_indivs));
%     cskew_x(low_nc+this_cluster-1) = skewness(indiv_x(these_indivs));
    centroid_y(low_nc+this_cluster-1) = mean(indiv_y(these_indivs));  %calculate centroid_y
%     cstd_y(low_nc+this_cluster-1) = std(indiv_y(these_indivs));
%     cskew_y(low_nc+this_cluster-1) = skewness(indiv_y(these_indivs));
    %calculate cluster_diversity
    cluster_diversity(low_nc+this_cluster-1) = mean(pdist(...
                                              [indiv_x(these_indivs),indiv_y(these_indivs)]));
  end
end

if SIMOPTS.limit~=3, 
  save(['centroid_x_' base_name int2str(SIMOPTS.limit) '_limit_' run_name],'centroid_x');
  save(['centroid_y_' base_name int2str(SIMOPTS.limit) '_limit_' run_name],'centroid_y');
  save(['cluster_diversity_' base_name int2str(SIMOPTS.limit) '_limit_' run_name],...
    'cluster_diversity');
else, 
  save(['centroid_x_' base_name run_name],'centroid_x');
  save(['centroid_y_' base_name run_name],'centroid_y');
  save(['cluster_diversity_' base_name run_name],'cluster_diversity');
end
end %num_clusters
end %trace_cluster
end %trace_y
end %trace_x
end %population
end %exists
end %function