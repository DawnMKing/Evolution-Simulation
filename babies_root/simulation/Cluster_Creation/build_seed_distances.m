%% build_seed_distances.m
% function [seed_distances,trace_cluster_seed] = build_seed_distances(base_name,run_name)
% This function determines the distance(s) between each reference organism
% and its nearest neighbors which comprise its seed for clusters. If
% needed, it will also determine the cluster seeds.
% The data, seed_distances, is organized as a row matrix with each organism
% listed along the rows and with the seed neighbors listed in the columns
% with the nearest being in the first column and more distant neighbors
% listed in the following columns accordingly. The size of seed_distances
% is sum(population) x 2, or whatever SIMOPTS.limit is set to be -1.
function [seed_distances] = build_seed_distances(base_name,run_name), 
global SIMOPTS;
this_script = 'make_seed_distances';
% fprintf([this_script '\n']);
land_limit = ((((max(basic_map_size)*2)-1)*2)-1);
try_limits = [   1   2   4   8    16  land_limit*ones(1,2)]'*ones(1,2); %limits 
dc_limits =  [0 1.5 2.9 5.7 11.4 22.7  land_limit*ones(1,3)]'*ones(1,2); %double check limits

fprintf([this_script ' for ' base_name run_name '\n']);
if exist([make_data_name('seed_distances',base_name,run_name,0) '.mat'])~=2 || ...
   SIMOPTS.write_over==1, 
go = 1;
[tcs,skip] = try_catch_load(['trace_cluster_seed_' base_name run_name],go,1);
if go==1, [p,skip] = try_catch_load(['population_' base_name run_name],go,1);
if go==1, [tx,skip] = try_catch_load(['trace_x_' base_name run_name],go,1);
if go==1, [ty,skip] = try_catch_load(['trace_y_' base_name run_name],go,1);
if go==1, 
  fprintf([this_script ' for ' base_name run_name '\n']);
  trace_cluster_seed = tcs.trace_cluster_seed;  clear tcs
  population = p.population; clear p
  trace_x = tx.trace_x; clear tx
  trace_y = ty.trace_y; clear ty
  
  ngen = length(population);
  u = int32(0);  v = int32(0);
  seed_distances = zeros(sum(population),2); %initialize the mate-and-cluster variable (MNC) for this generation
  for gen = 1:ngen
    u = int32(v +1);
    v = int32(sum(population(1:gen)));
    babies = [];
    babies = [trace_x(u:v) trace_y(u:v)];
    for i=1:population(gen) %for each baby
      this_coord = [babies(i,1) babies(i,2)]; %[x y]
      nearest = int32(trace_cluster_seed(i+u-1,1));
      nx = trace_x(nearest-1+u);  ny = trace_y(nearest-1+u);
      seed_distances(i+u-1,1) = sqrt((this_coord(1) -nx).^2 +(this_coord(2) -ny).^2);
      if SIMOPTS.limit>=3, 
        second = int32(trace_cluster_seed(i+u-1,2));
        sx = trace_x(second-1+u);  sy = trace_y(second-1+u);
        seed_distances(i+u-1,2) = sqrt((this_coord(1) -sx).^2 +(this_coord(2) -sy).^2);
      end
    end
  end %end of assigning mates
  if tcs_not_exist==1, 
    save(['trace_cluster_seed_' base_name run_name],'trace_cluster_seed');
  end
  save(['seed_distances_' base_name run_name],'seed_distances');
end %trace_y
end %trace_x
end %population
end %trace_cluster_seed
end %exists
end %function