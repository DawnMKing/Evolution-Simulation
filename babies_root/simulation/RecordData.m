%% RecordData.m
%function [] = RecordData(base_name,GENVARS,GENOUTS)
%inputs - base_name (simulation descriptor name), GENVARS (generation variables), &
%GENOUTS (generation data output)
%outputs - none
%
%RecordData is an update of Record4 to account for globalization of SIMOPTS and handling of the
%generation variables & parameters.
%RecordData is set up to work with only the cluster seed information and does nothing about actual
%cluster data. One must run Clustering.m from main_babies.m to generate the cluster data from
%trace_cluster_seed.

%%
function [] = RecordData(base_name,GENVARS,GENOUTS)
global SIMOPTS;
run_name = int2str(GENVARS.run);
if SIMOPTS.loaded==0, 
  population = GENOUTS.population;
  pop_name = ['population_' base_name run_name];
  save(pop_name,'population');  clear population
  if SIMOPTS.exp_type~=0, 
    trace_noise = GENOUTS.trace_noise;
    tn_name = ['trace_noise_' base_name run_name];
    save(tn_name,'trace_noise');  clear trace_noise
  end
  trace_x = GENOUTS.trace_x;
  tx_name = ['trace_x_' base_name run_name];
  save(tx_name,'trace_x');  clear trace_x
  trace_y = GENOUTS.trace_y;
  ty_name = ['trace_y_' base_name run_name];
  save(ty_name,'trace_y');  clear trace_y
  if SIMOPTS.reproduction~=1, 
    trace_cluster_seed = GENOUTS.trace_cluster_seed;
    tcs_name = ['trace_cluster_seed_' base_name run_name];
    save(tcs_name,'trace_cluster_seed');  clear trace_cluster_seed
    seed_distances = GENOUTS.seed_distances;
    sd_name = ['seed_distances_' base_name run_name];
    save(sd_name,'seed_distances'); clear seed_distances
  end
  if size(unique(GENOUTS.land),1)~=1, 
    land = GENOUTS.land;
    l_name = ['land_' base_name run_name];
    save(l_name,'land');  clear land
  end
  if size(GENOUTS.shifted,1)~=0, 
    shifted = GENOUTS.shifted;
    s_name = ['shifted_' base_name run_name];
    save(s_name,'shifted'); clear shifted
  end
  if SIMOPTS.save_parents==1, 
    parents = GENOUTS.parents;
    par_name = ['parents_' base_name run_name];
    save(par_name,'parents'); clear parents
  end
  if SIMOPTS.save_kills==1, 
    kills = GENOUTS.kills;
    kill_name = ['kills_' base_name run_name];
    save(kill_name,'kills');  clear kills
    if SIMOPTS.save_rivalries==1, 
      rivalries = GENOUTS.rivalries;
      rvl_name = ['rivalries_' base_name run_name];
      save(rvl_name,'rivalries'); clear rivalries
    end
  end
else, 
  pop_name = ['population_' base_name run_name];
  load(pop_name);
  population = [population GENOUTS.population];
  save(pop_name,'population');  clear population
  if SIMOPTS.exp_type~=0, 
    tn_name = ['trace_noise_' base_name run_name];
    load(tn_name);
    trace_noise = [trace_noise; GENOUTS.trace_noise];
    save(tn_name,'trace_noise');  clear trace_noise
  end
  tx_name = ['trace_x_' base_name run_name];
  load(tx_name);
  trace_x = [trace_x; GENOUTS.trace_x];
  save(tx_name,'trace_x');  clear trace_x
  ty_name = ['trace_y_' base_name run_name];
  load(ty_name);
  trace_y = [trace_y; GENOUTS.trace_y];
  save(ty_name,'trace_y');  clear trace_y
  tcs_name = ['trace_cluster_seed_' base_name run_name];
  load(tcs_name);
  trace_cluster_seed = [trace_cluster_seed; GENOUTS.trace_cluster_seed];
  save(tcs_name,'trace_cluster_seed');  clear trace_cluster_seed
  sd_name = ['seed_distances_' base_name run_name];
  seed_distances = [seed_distances; GENOUTS.seed_distances];
  save(sd_name,'seed_distances');
  if size(unique(GENOUTS.land),1)~=1, 
    l_name = ['land_' base_name run_name];
    load(l_name);
    land = [l GENOUTS.land];
    save(l_name,'land');  clear land
  end
  if size(GENOUTS.shifted,1)~=0, 
    s_name = ['shifted_' base_name run_name];
    load(s_name);
    shifted = [GENOUTS.shifted shifted];
    save(s_name,'shifted'); clear shifted
  end
  if SIMOPTS.save_parents==1, 
    par_name = ['parents_' base_name run_name];
    load(par_name);
    parents = [parents; GENOUTS.parents];
    save(par_name,'parents'); clear parents
  end
  if GENOUTS.save_kills==1, 
    kill_name = ['kills_' base_name run_name];
    load(kill_name);
    kills = [kills; GENOUTS.kills];
    save(kill_name,'kills');  clear kills
  end
end
end