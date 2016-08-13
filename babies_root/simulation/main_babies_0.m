%% main_babies_0.m *******************************************************
% This is the primary m-file to run the evolution simulation, babies. For reference,
% the original defaults are: overpop = 0.25; death_max = 0.70; NGEN = 2000; range = 7; 
% IPOP = 300; landscape_movement = 2; landscape_heights = [1 4]; basic_map_size = [12 12];
% Cluster information must be run post simulation for RAM resource reasons on most
% computers. However, enough information may be output so that every indiv may be traced
% by generation, cluster, phylogeny, death, etc. Furthermore, landscape scenarios to model 
% Neutral Theory (#_Flatscape), static Natural Selection (Frozenscape), rolling Natural 
% Selection (#_Shifting), and drastic Natural Selection (#_Shock) are included. There is
% no feedback mechanism as an option for now. Reproduction options include Assortative
% Mating, Bacterial Splitting, and Random Mating. Assortative and Random are sexual
% reproduction types, whereas Bacterial is asexual. Finally, one may choose simulations of
% competition of many mutabilities in the population, competition of two mutability 
% populations, or single mutability values for the population.

%% START CLEAN
clear; clc; close all;
% rng(100000);
% rand(ceil(100*rand)); %need if running in pre-2007 instances of Matlab

%% PARAMETERS

% Data creation options
  % Save options
  record = 1; %save general information? no = 0, yes = 1
  save_parents = 1; %no phylogeny = 0, NEED to make phylogeny? = 1
  save_kills = 0; %don't save kills = 0, save kills = 1
  save_rivalries = 1;
  source = 'C:\Users\Dawn\Desktop\babies_root\';
  write_over = 1;
  append = 0; %append more generations(1)-run normally(0)-to already existing data set ***MUST indicate 
                  %the generation number in the simulations loop of the
                  %old_dir and old_name****
  
  only_lt = 0; %record only times to fixation if 1 and disregard all other data
  only_relax = 0;
  do_simulations = 1; %generates population, trace_x, trace_y, trace_noise, trace_cluster_seed*
  do_clustering = 0;  %generates trace_cluster_seed* & allows building and locating clusters
    do_build_clusters = 0;  %generates num_clusters, trace_cluster, orgsnclusters, 
    do_locate_clusters = 0; %generates centroid_x, centroid_y, cluster_diversity
  do_genealogies = 1; %generates lineage info of original population & of the clusters
    do_indiv_lineage = 0; %generates num_descendants
    do_indiv_cluster_lineage = 0; %generates num_descendant_clusters, descendant_clusters
    do_cluster_lineage = 1; %generates num_clusters_produced, clusters produced, 
    do_build_species_tree = 0;
                            %num_clusters_fused, clusters_fused

% Simulation numbers
SIMS = [3]; %simulation identifiers used in simulation looping

% Initial parameter settings
NGEN = 20; %number of generations to run
IPOP = 2; %number of initial population
relax = 0;
limit = 2; %minimum cluster size/extinction population +1
loaded = 0; %choose to load predefined variables, 0 = no load, 1 = load load_name variables
load_name = ['']; %string which identifies predefined variables babies and basic_map

% Death settings
  % Local options
  overpop = 0.25; %if closer than this distance, overpopulated, and baby dies
  random_walk = 0; %0 = coalescing, 1 = annihilating
  % Global options
  ddm = 0;  death_max = [0.01]; %percent of random babies dying varies from 0 to this value.
  indiv_death = 1;  %random percentage of entire pop dies = 0; individual probability = 1

% Landscape options
shock = 0; %Set this to 1 to generate a new random map every landscape_movement generations
landscape_movement = 2*NGEN; %land moves every "landscape_movement" generations
  %There is only a default shift of 1 basic_map row, we could add this in if 
  %we really want to, but it may be unnecessary.
landscape_heights = [2 2]; %min and max of landscape; for flat landscapes, only min is taken
  %If both values are the same, then a flatscape will be generated.
basic_map_size = [12 12]; %X and Y lengths for the basic map size
linear = 0;
  %May just put in a check on whether one basic_map_size values is 1

% Reproduction options
distribution = 0; %offspring distrubtion: 0=uniform, 1=normal
reproduction =0; %assortative mating = 0, bacterial cleaving = 1, random mating = 2

% Mutability option
exp_type = 0; %same mutability = 0; competition = 1; duel = 2

% Single Mutability settings
dmu = 0.005;  mutability = [0.300];

% Two mu competition settings
bi = [1.31 2.31; 150 150]; %[mu1 mu2; IPOP1 IPOP2];

% Mutability competition settings
range = 7; % 0 to range possible mutabilities

% Initialize any global variables
if only_lt==1, global lifetimes; end

global SIMOPTS;
%% Simulations loop
for op = overpop, 
  for dm = death_max, 
    for mu = mutability, 
      % Bundle simulation options into SIMOPTS
      SIMOPTS = struct('record',record,'save_parents',save_parents,'save_kills',save_kills,...
      'save_rivalries',save_rivalries,'source',source,...
      'only_lt',only_lt,'only_relax',only_relax,'write_over',write_over,...
      'do_simulations',do_simulations,'do_clustering',do_clustering,...
      'do_build_clusters',do_build_clusters,'do_locate_clusters',do_locate_clusters,...
      'do_genealogies',do_genealogies,'do_indiv_lineage',do_indiv_lineage,...
      'do_cluster_lineage',do_cluster_lineage,'do_indiv_cluster_lineage',do_indiv_cluster_lineage,...
      'do_build_species_tree',do_build_species_tree,'SIMS',SIMS,'NGEN',NGEN,'IPOP',IPOP,'relax',relax,...
      'limit',limit,'loaded',loaded,'load_name',load_name,...
      'op',op,'random_walk',random_walk,'dm',dm,'indiv_death',indiv_death,...
      'shock',shock,'landscape_movement',landscape_movement,...
      'landscape_heights',landscape_heights,'basic_map_size',basic_map_size,'linear',linear,...
      'distribution',distribution,'reproduction',reproduction,'exp_type',exp_type,'mu',mu,...
      'bi',bi,'range',range,'append',append);
      if do_simulations==1, sim_times = Simulations(); end
      if do_clustering==1,  clu_times = Clustering();  end
      if do_genealogies==1, lin_times = Genealogies(); end
    end
  end
end

%% Update information
%%updates as of Nov 2014 DMK  added append to main_babies options. This
%%1) will load data files to add more generations to existing data.  *Must 1st
%%create a new directory with the new genrations, then copy data to the
%%file, and then rename to the proper gen name before can start the
%%simulations.
% updates as of Feb 2012 ADS & DMK
% 1) Capability to change random death from population size based to 
% individually based was added. -DMK
% 2) There is a new analysis function which can look at percolation of
% largest clusters. The new script is percolation_lengths.m. -ADS
% 3) Writing Excel files for use in Sigma Plot has been modified and
% expanded. The script, write_sigma_plot_files.m, still exists, but it
% includes new sub-scripts: write_populations.m, write_clusters.m,
% write_time_to_fixation.m. This rearrangement results in three separate
% xls files for each type of data. New capability to write out a similar
% file for the nearest neighbor measure, R, was also added. This
% sub-script, write_R.m, may be enacted by toggling record_R in
% main_analysis.m. -ADS
% 4) Added mkdir capability to NameAndCD.m. Any new simulations do not
% require manually making the appropriate directories. Instead, NameAndCD
% will automatically create new directories to house a new set of
% simulation data. -ADS
%
% updates as of Jan 2012 ADS -
% 1) There are many new analysis functions added. See main_analysis.m for
% all the fancy new analyses.
% 2) There is basic functionality for loaded runs. Use main_loader to make load
% files from pre-existing data. There is no functionality yet for self made
% data starts. It may be while until that's included, since it's not yet
% needed.
% 3) Included directory handling to NamingScheme.m which is now
% NameAndCD.m. See NameAndCD.m documentation for how to customize the use
% of the source parameter in main_babies_#.m for the location of your data.
% 4) Took out the flat option. For flatscapes, just set both
% landscape_heights values to the same value.
%
% updates as of July 2011 ADS - 
% 1) An option to load predefined variables for babies and basic_map is now available. Note 
% that predefined shiftedscapes are not yet possible with this update. Simulations will run
% akin to a historical contingency idea based on a moment of landscape in time and not an 
% underlying landscape throughout time. Functions updated include: main_babies, Simulations, 
% NamingScheme.  
% 2) The function, Record (now on 4th iteration), no longer saves a trace_noise file if the 
% exp_type is 0 (for single mutability). Functions updated include: Simulations, Record.
% 3) Fixed a bug with populations less than limit being saved, especially in bacterial
% simulations. The function updated to remove this bug is Simulations. Two new functions
% were created to fix population data that includes the excess population, modify_data.m
% and fix_population.m. See their help info for more information. The final updates for
% this bug include modification of build_clusters, locate_clusters, and
% build_trace_cluster_seed which had been temporarily changed to account for the excess
% population data value. They are now back to running as normal with the exception that
% build_trace_cluster_seed and build_clusters now take limit as an input.
%
% updates as of June 2011 ADS - 
% 1) Reproduction options for assortative mating (default), random mating and bacterial
% splitting included. Functions updated for reproduction toggling include: main_babies, 
% Simulations, Generations, MakeBabies, FindMates, NamingScheme.
% 2) Re-added in option to save kill counts. Functions updated include: main_babies,
% Simulations, Generations, OverpopulationLimit, RandomDeath, CliffJumpers, Record.
% 3) New option to determine minimum population needed to run (Limit). Since bacterial
% species is very controversial, the mimumum population needed to determine a species may
% be different sizes, so change Limit to accomodate for different potential minimum
% cluster sizes. Functions updated include: main_babies, Simulations, Generations.
% 4) Some function names end with a 2 or 3 to indicate these latest changes.
% 5) Changed the two competiting mutability handling so that exp_type = 2 determines
% competition between two mutabilities. Functions updated include: main_babies,
% Simulations, setInitialMutabilities, NamingSchemes.
%
% updates as of May 2011 ADS -
% 1) Created two new primary functions, Generations and Simulations.  These
% are meant to help break up babies so that multiple experiments may be run
% consecutively.  Generations is just the generations loop of babies_noBias
% and Simulations is just the simulations loop of babies_noBias.
%
% updates as of March 2011 ADS - 
% 1) Revamped functions throughout the program into explicit function calls. 
% 2) Included naming scheme according to competition or not, distribution 
%   of offspring type, and landscape scenarios.
% 3) Can now save parents for absolute phylogeny determination.  Some 
%   function names end with a 2.  This indicates that they are set up to 
%   save the parents.  Without the 2, the functions will not save data for 
%   parents.
% 4) Extended range of possible mu values within competition up from 1 to 7. 
% 5) Eased changes needed between scenarios so only the beginning values 
%   need changing. 
% 6) Altered the order of Overpopulation Limit check so that there is no 
%   longer bias for the early organisms listed in variable babies. 
% 7) Some simulations require more resources than available on most
%   lab computers, so I've set this up so that only 1st and 2nd nearest
%   neighbors are saved.  This allows for cluster data to be generated from
%   the trace_cluster_seed file.  Changes associated with this are 
%   designated on lines with a long string of the percent signs.  The 
%   original cluster variables are still in place, but are commented out.  
%   Use the script, determine_cluster_info, to determine full cluster data 
%   set.
% 8) Defaults are noted under the Parameters section.  If running defaults,
%   there will be no indication of those settings within the
%   simulation/filename.  However, the naming scheme does not yet account
%   for every parameter change you may make, so that will need to be
%   included in order to make the filenames describe the simulation
%   scenario explicitly.
%
%
% evol model ND & SB 2009 - Babies 30  --   Shifting landscape with tracers
% new version summer 2009 to have babies with different noises competing
% against each other
%
% Overpopulation derived from small circles surrounding each individual.
% Mating using the matching hypothesis - mate with the one closest to you
% (in terms of phenotype = assortative mating).
%
% A fitness landscape lies below the phenotype placements.  It is 
% based on a random matrix, with values in the landscape (rounded)
% equaling the number of babies an organism with that fitness would produce.
%
% SO - a certain phenotype puts you in a place on the map, where a certain
% fitness lies below you, and determines how many babies you produce.
%
% A Clustering mechanism is included, with statistics recorded.
%
% Still needing a feedback mechanism for landscape.. do have a changing
% landscape option based on randomness.
%**************************************************************************

%% old stuff

%cluster_perc_cutoff = 4.293; %when grouping organisms, percent cutoff represents 
%the percent change in the distance between the organisms when the next baby 
%is included.  A way to limit clustering based on closeness -if too many
%are clustered together, go lower. if clusters are too sparse, go higher...
%NOTE:  I've never used cluster_perc_cutoff. This was included in Nate's
%original design of the program.  I think we've abandoned this concept for
%various reasons.