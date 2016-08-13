%% Simulations.m
% Inputs - none
% Outputs - lifetimes
% [lifetimes] = Simulations()
function [lifetimes] = Simulations()
global SIMOPTS;

%% Initialize generation variables
GENVARS = struct('babies',[],'basic_map',[],'land',[],'run',[]);

%% Initialize output
if SIMOPTS.only_lt==1,  global lifetimes; end
lifetimes = zeros(length(SIMOPTS.SIMS),1); %number of generations each simulation lasts

%% Naming scheme
make_dir = 1; [base_name,dir_name,old_dir,old_name] = NameAndCD(make_dir);
% if SIMOPTS.append==1
%     
%     cd([old_dir])
%     move_data(old_name,dir_name,run_name)
%     cd(dir_name)
% end

%% Determine whether to do lifetimes or relaxations
[~,go_lta] = try_catch_load(['lifetimes_' base_name int2str(SIMOPTS.SIMS(1)) '_' ...
                            ],1,0);
[~,go_ltb] = try_catch_load(['lifetimes_' base_name(1:end-1)],1,0);
[~,go_ra] = try_catch_load(['relaxations_' base_name int2str(SIMOPTS.SIMS(1)) '_' ...
                            ],1,0);
[~,go_rb] = try_catch_load(['lifetimes_' base_name(1:end-1)],1,0);
if ((go_lta==0 || go_ltb==0) && SIMOPTS.only_lt==0) || ...
   ((go_ra==0 || go_rb==0) && SIMOPTS.only_relax==0) || ...
   SIMOPTS.write_over==1, 
 
%% State whether lifetimes or relaxations
if SIMOPTS.only_lt==1, 
  fprintf(['lifetimes of ' base_name int2str(SIMOPTS.SIMS(1)) '_' ...
           int2str(SIMOPTS.SIMS(end)) '\n']); 
elseif SIMOPTS.only_relax==1, 
  fprintf(['relaxations of ' base_name int2str(SIMOPTS.SIMS(1)) '_' ...
           int2str(SIMOPTS.SIMS(end)) '\n']); 
end

%% Simulation loop
i = 0;
for run = SIMOPTS.SIMS 
  go_pop = 1; go_tx = 1;  go_ty = 1;
 
  if SIMOPTS.append==1
    run_name = int2str(run)
    cd([old_dir 'Data\'])
    move_data(old_name,dir_name,run_name)
    cd([dir_name 'Data\'])
    movefile_data_set(old_name,base_name,run_name);
  end
  
  %% Determine whether to do simulation for te run value
  if SIMOPTS.only_lt==0 && SIMOPTS.only_relax==0, 
    [~,go_pop] = try_catch_load(['population_' base_name int2str(run)],go_pop,0);
    [~,go_tx] = try_catch_load(['trace_x_' base_name int2str(run)],go_tx,0);
    [~,go_ty] = try_catch_load(['trace_y_' base_name int2str(run)],go_ty,0);
  end %if not only_lt and only_relax
  if (go_pop==0 || go_tx==0 || go_ty==0) || SIMOPTS.write_over==1 || ...
      SIMOPTS.append == 1 || SIMOPTS.only_lt==1 || SIMOPTS.only_relax==1,  
  run_name = int2str(run);
  GENVARS.run = run;
  i = i +1;

  if isempty(SIMOPTS.load_name) && SIMOPTS.loaded==1, SIMOPTS.load_name = base_name; end

  %% FITNESS LANDSCAPE
  if SIMOPTS.loaded==0, 
    if SIMOPTS.landscape_heights(1)~=SIMOPTS.landscape_heights(2), 
      GENVARS.basic_map = rand(SIMOPTS.basic_map_size)*SIMOPTS.landscape_heights(2);
    elseif SIMOPTS.landscape_heights(1)==SIMOPTS.landscape_heights(2), 
      GENVARS.basic_map = SIMOPTS.landscape_heights(1)*ones(SIMOPTS.basic_map_size);
    end
  else, 
    load(['basic_map_' SIMOPTS.load_name]);
    GENVARS.basic_map = basic_map;  clear basic_map
  end
  % for linear landscapes
  if SIMOPTS.linear==1, 
    GENVARS.land = ceil(interp1(GENVARS.basic_map,2));
  else, 
    GENVARS.land = ceil(interp2(GENVARS.basic_map,2)); %round up the landscape values
  end

  %% ORIGINAL POPULATION
  if SIMOPTS.loaded==0 && SIMOPTS.append==0, 
    %Set initial mutability(ies) for population
    [IBN] = setInitialMutabilities();
    %Set initial locations for population
    location = [rand(SIMOPTS.IPOP,1)*(size(GENVARS.land,1)-1)+1 ...
      rand(SIMOPTS.IPOP,1)*(size(GENVARS.land,1)-1)+1]; 
    %Build the first population
    GENVARS.babies = [location IBN];  clear IBN location
  elseif SIMOPTS.append == 0, 
    %Load the first population
    load(['babies_' SIMOPTS.load_name]);
    GENVARS.babies = babies;  clear babies
  else  %loads population last generation of the population and the coressponding trace_x & trace_y to make babies vector.
         load(['population_' base_name int2str(run)]);
         load(['trace_x_' base_name int2str(run)]);
         load(['trace_y_' base_name int2str(run)]);
         load(['trace_cluster_seed_' base_name int2str(run)]);
         load(['parents_' base_name int2str(run)]);
         load(['seed_distances_' base_name int2str(run)]);
         load(['kills_' base_name int2str(run)]);
          
        
         b = find(population ~=0);
         gen_start = length(b)- 1;
         gen_finish = length(b);
         gs= sum(population(1:gen_start))+1;
         gf = sum(population(1:gen_finish));
         BN = SIMOPTS.mu*ones(population(gen_finish),1);
         GENVARS.babies = [trace_x(gs:gf) trace_y(gs:gf) BN];%gives coordinates of the final generation that will be added to
         GENVARS.pop = population; 
         GENVARS.tx = trace_x;
         GENVARS.ty = trace_y;
         GENVARS.tcs = trace_cluster_seed;
         GENVARS.sd = seed_distances;
         GENVARS.p = parents;
         GENVARS.k = kills;
        
  end

  %just to let you know in the Command Window what you're running
  if SIMOPTS.only_lt==0 && SIMOPTS.only_relax==0, 
    fprintf(['normal sim of ' base_name run_name '\n']); 
  else
    fprintf([base_name int2str(run) '\n']);
  end
  GENVARS.exp_name = [base_name run_name];

  %% generation loop
  [GENOUTS] = Generations(GENVARS);

  %% RECORD INFORMATION
  if SIMOPTS.only_lt==0
    RecordData(base_name,GENVARS,GENOUTS);  % save data (returns a 1 for saved if successful)
  end

  lifetimes(i) = GENOUTS.finished;

  %% RESET & CLEAN-UP
  clear GENVARS GENOUTS;
  end %population, trace_x, or trace_y does not exist OR write_over is true

end %SIMS
end %only_lt & only_relax & write_over
%% Record lifetimes
if SIMOPTS.only_lt==1
  save_lifetimes(base_name);
end
end