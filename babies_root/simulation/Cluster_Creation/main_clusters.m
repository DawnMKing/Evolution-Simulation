%% main_clusters.m *******************************************************
% This is the primary m-file to generate cluster information. Data files generated include
% num_clusters, trace_cluster, orgsnclusters, centroid_x, centroid_y, and
% cluster_diversity. For reference, the original defaults are: overpop = 0.25; 
% death_max = 0.70; NGEN = 2000; range = 7; IPOP = 300; landscape_movement = 2; 
% landscape_heights = [1 4]; basic_map_size = [12 12]; Cluster information must be run post 
% simulation for RAM resource reasons on most computers. However, enough information may be 
% output so that every indiv may be traced by generation, cluster, phylogeny, death, etc. 
% Furthermore, landscape scenarios to model Neutral Theory (#_Flatscape), static Natural 
% Selection (Frozenscape), rolling Natural Selection (#_Shifting), and drastic Natural 
% Selection (#_Shock) are included. There is no feedback mechanism as an option for now. 
% Reproduction options include Assortative Mating, Bacterial Splitting, and Random Mating. 
% Assortative and Random are sexual reproduction types, whereas Bacterial is asexual. Finally, 
% one may choose simulations of competition or single mutability values for the population.
% This currently relies on three other functions, two of which generate the cluster data.
% Naming_Scheme is used to build simulation file names to call up organism data.
% build_clusters generates num_clusters, trace_cluster, and orgsnclusters. locate_clusters
% generates centroid_x, centroid_y, and cluster_diversity.

%% START CLEAN
clear; clc; %close all;

%% PARAMETERS
% Simulation numbers
SIMS = [1:5]; %simulation identifiers used in simulation looping

% General settings
NGEN = 2000; %number of generations to run
IPOP = 300; %number of initial population
overpop = 0.25; %if closer than this distance, overpopulated, and baby dies
death_max = 0.70; %percent of random babies dying varies from 0 to this value.
limit = 3;
loaded = 0;
load_name = [''];

% Landscape options
flat = 1; %Set this to 1 for a flat landscape at fitness==landscape_heights(1)
shock = 0; %Set this to 1 to generate a new random map every landscape_movement generations

  % Landscape settings
  landscape_movement = 2*NGEN; %land moves every "landscape_movement" generations
    %There is only a default shift of 1 basic_map row, we could add this in if 
    %we really want to, but it may be unnecessary.
  landscape_heights = [3 4]; %min and max of landscape; for flat landscapes, only min is taken
  basic_map_size = [12 12]; %X and Y lengths for the basic map size

% Reproduction options
rndm = 0; %offspring distrubtion: 0=uniform, 1=normal
reproduction = 2; %assortative mating = 0, bacterial cleaving = 1, random mating = 2

% Save options
save_parents = 1; %no phylogeny = 0, NEED to make phylogeny? = 1
save_kills = 1; %don't save kills = 0, save kills = 1

% Mutability options
exp_type = 0; %same mutability = 0; competition = 1; duel = 2

  % Single Mutability settings
  dbn = 0.01; %increment mu by dbn
  bn = [0.20:dbn:1.0 1.25:0.25:3.0]; %need to do runs 4 and 5 for 1.05 & 4 and 5 for 2.03
%   bn = [2.10:dbn:3.0]; %birth noise factor (mutability)
    %if you want more ranges to run consecutively, then just add more mins and maxs 
    %here and below within the for loop

  % Two mu competition settings
  % if this is not a set of zeros, then the simulation will toggle to two mu competition
  % automatically
  bi = [1.31 2.31; 150 150];

  % Mutability competition settings
  range = 7; % 0 to range possible mutabilities
cd E:\_Research\Programming\Babies\generalized_Expt\Random_Mating\Mu_x\Uniform\3_Flatscape
tic;
for bnoise = bn
  %build the simulation names for which you have chosen to generate cluster data
  [base_name] = NamingScheme(exp_type,bnoise,bi,rndm,landscape_movement,...
    NGEN,flat,landscape_heights,shock,IPOP,range,reproduction,loaded,load_name,...
    death_max,basic_map_size);
  for run = SIMS
    run_name = int2str(run);
    what_is_happening = [base_name run_name] %just so you know what's being worked on
    %generates trace_cluster_seed IF YOU NEED IT, UNCOMMENT IT
    load(['trace_cluster_seed_' base_name run_name]);
    if size(trace_cluster_seed,2)==1
      [tcs] = build_trace_cluster_seed(base_name,run_name); clear tcs;
    end
    %generates num_clusters, trace_clusters, & orgsnclusters data files
    [nc,tc,onc] = build_clusters(base_name,run_name); clear nc tc onc;
    %generates centroid_x, centroid_y & cluster_diversity
    [cx,cy,cdiv] = locate_clusters(base_name,run_name); clear cx cy cdiv;
  end
end
toc;

cd E:\_Research\Programming\Babies\generalized_Expt\Random_Mating\Mu_x\Uniform\2_Flatscape
tic;
landscape_heights = [2 4];
for bnoise = bn
  %build the simulation names for which you have chosen to generate cluster data
  [base_name] = NamingScheme(exp_type,bnoise,bi,rndm,landscape_movement,...
    NGEN,flat,landscape_heights,shock,IPOP,range,reproduction,loaded,load_name);
  for run = SIMS
    run_name = int2str(run);
    what_is_happening = [base_name run_name] %just so you know what's being worked on
    %generates trace_cluster_seed IF YOU NEED IT, UNCOMMENT IT
    load(['trace_cluster_seed_' base_name run_name]);
    if size(trace_cluster_seed,2)==1
      [tcs] = build_trace_cluster_seed(base_name,run_name); clear tcs;
    end
    %generates num_clusters, trace_clusters, & orgsnclusters data files
    [nc,tc,onc] = build_clusters(base_name,run_name); clear nc tc onc;
    %generates centroid_x, centroid_y & cluster_diversity
    [cx,cy,cdiv] = locate_clusters(base_name,run_name); clear cx cy cdiv;
  end
end
toc;