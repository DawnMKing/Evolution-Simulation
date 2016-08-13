%% build_trace_cluster_seed - takes a string representing a simulation base
%name ('Expt9_500gen_') and a particular run name of a trial set ('17' or
%int2str(17)) and returns a sum(population) x 2 matrix with the first
%column representing the mate of the indiv labeled by its row while the
%second column represents the second nearest neighbor of indiv as indexed
%by the row as well.
%[a matrix size sum(population) x 2] = CHECK_trace_cluster_seed('string','string')
%function [trace_cluster_seed] = build_trace_cluster_seed(base_name,run_name,limit,rep)
function [trace_cluster_seed,seed_distances] = build_trace_cluster_seed(base_name,run_name)
global SIMOPTS;
if (exist([make_data_name('trace_cluster_seed',base_name,run_name,0) '.mat'])~=2) || ...
    SIMOPTS.write_over==1, 
go = 1;
[p,go] = try_catch_load(['population_' base_name run_name],go); %get corresponding population
if go==1, 
NGEN = length(find(population)); %determine number of generations
trace_cluster_seed = zeros(sum(population),SIMOPTS.limit-1,'single');  %initialize tcs
if SIMOPTS.reproduction~=2, 
  [tx,go] = try_catch_load(['trace_x_' base_name run_name],go); %get corresponding trace_x
  if go==1,
    [ty,go] = try_catch_load(['trace_y_' base_name run_name],go);  %get corresponding trace_x
  end
end
if go==1, 
  
fprintf(['seeding clusters for ' base_name run_name]);

trace_cluster_seed = zeros(sum(population),2);

u = 0; v = 0; %u and v index each population within trace_x/y
for gen = 1:NGEN, 
  u = v +1; %update lower limit index of this population
  v = sum(population(1:gen)); %update upper limit index of this population
  if SIMOPTS.reproduction~=2, 
    ix = trace_x(u:v);  %retrieve indiv x-coordinate for this population
    iy = trace_y(u:v);  %retrieve indiv y-coordinate for this population
    id = zeros(population(gen),1);
    for i = 1:population(gen), 
      id = ((ix-ix(i)).^2) + ((iy-iy(i)).^2); %calculate distance from indiv i to all others
      sid = sort(id);
      %u+i-1 = index of current indiv i, adding u accounts for placement in
      %tcs while subtracting 1 is needed since u and i both start from 1 so
      %this adjustment is needed to obtain proper placement in tcs
      trace_cluster_seed(u+i-1,1) = find(id==sid(2)); %set mate to tcs
      seed_distances(u+i-1,1) = sid(2);
      if SIMOPTS.limit>=3, 
        trace_cluster_seed(u+i-1,2) = find(id==sid(3)); %set 2nd nearest neighbor to tcs
        seed_distances(u+1-1,2) = sid(3);
      end
    end
  elseif SIMOPTS.reproduction==2, %Random_Mating
    M = ceil(population(gen)*rand(population(gen),1));  %select a random mate for each organism
    %check if mate and second nearest are the same, so need three unique indivs to make a 
    %Nate cluster...maybe set SN post simulation......
    same = find([1:population(gen)]'==M); %see if there are mates which identical to their partner
    while length(same)>0, %while there is a mate that is itself
      alt = ceil(rand(1,length(same))*population(gen)); %try an alternate mate
      M(same) = alt; %set the alternative
      same = find([1:population(gen)]'==M); %see if there are mates which are identical to their partner
    end
    SN = ceil(population(gen)*rand(population(gen),1));
    same2 = find([1:population(gen)]'==SN | M==SN); %see if there are mates which identical to their partner
    while length(same2)>0, %while there is a mate that is itself
      alt = ceil(rand(1,length(same2))*population(gen)); %try an alternate mate
      SN(same2) = alt; %set the alternative
      same2 = find([1:population(gen)]'==SN | M==SN); %see if there are mates which are identical to their partner
    end
    trace_cluster_seed(u:v,:) = [M SN];
%     clear M SN
  end
end
if SIMOPTS.limit~=3, 
  tcsn = ['trace_cluster_seed_' base_name int2str(SIMOPTS.limit) '_limit_' run_name];
  sdn = ['seed_distances_' base_name int2str(SIMOPTS.limit) '_limit_' run_name];
else, 
  tcsn = ['trace_cluster_seed_' base_name run_name];
  sdn = ['seed_distances_' base_name run_name];
end
save(tcsn,'trace_cluster_seed');
save(sdn,'seed_distances');
end %trace_x trace_y
end %population
end %exists
end %function