% Generations.m
% inputs:
% gen - current generation
% NGEN - maximum generations to run
% limit = minimum number of indivs required to continue simulation
% babies = initial population of indivs organized by rows of indivs and columns of [x y mu]
% exp_type = mu among initial population (0 = single mu, 1 = all unique mu (Comp), 
%            2 = two mu duel (Comp))
% basic_map = before two interpolations, the fitness landscape is defined by this
% land = the landscape after interpolating it twice along each dimension

% function [population,trace_noise,trace_x,trace_y,trace_cluster_seed,land,shifted,parents,...
%   finished,kills,nn_dist,rivalries,mnd] = Generations(SIMPOTS,GENVARS)
function [GENOUTS] = Generations(GENVARS)
global SIMOPTS;
%% Initialize 
  % Output data
if SIMOPTS.only_lt==0 && SIMOPTS.append==0, 
  population = zeros(1,SIMOPTS.NGEN); %records the population of each generation
  rivalries = zeros(SIMOPTS.NGEN,1); %records the number of sibling rivalries occuring in each generation
  trace_cluster = []; %records cluster number of traced animals
trace_cluster_seed = []; %records mate and alternate of each organism
seed_distances = []; %records the nearest & second nearest neighbor distances to each organism
trace_x = []; %records x position of traced animals
trace_y = []; %records y position of traced animals
trace_noise = []; % records noise value of traced animals
shifted = []; %records shifted landscape
parents = []; %records parent(s) of each organism
adults = []; %generational record of parents
kills = []; %records the kill counts from each death type
gen = 0; %track generation
az = 0;
t=0;
elseif SIMOPTS.append==0, %if only_ttf==1, then there is no need to record these; this leaves them empty
  population = [];
  rivalries = [];
trace_cluster = []; %records cluster number of traced animals
trace_cluster_seed = []; %records mate and alternate of each organism
seed_distances = []; %records the nearest & second nearest neighbor distances to each organism
trace_x = []; %records x position of traced animals
trace_y = []; %records y position of traced animals
trace_noise = []; % records noise value of traced animals
shifted = []; %records shifted landscape
parents = []; %records parent(s) of each organism
adults = []; %generational record of parents
kills = []; %records the kill counts from each death type
gen = 0; %track generation
az = 0;
t=0

else
    t = length(GENVARS.pop);
    az = SIMOPTS.NGEN - t;
    add_zeros = zeros(1,az);
    population = [GENVARS.pop add_zeros];
    rivalries =[]; %will need to fix this if look at the competition(did not incluse this in the appending yet)
   
    trace_cluster_seed = [GENVARS.tcs]; %records mate and alternate of each organism
    seed_distances = [GENVARS.sd]; %records the nearest & second nearest neighbor distances to each organism
    trace_x = [GENVARS.tx]; %records x position of traced animals
    trace_y = [GENVARS.ty];
    parents = [GENVARS.p]; %records parent(s) of each organism
    kills = [GENVARS.k];
    shifted = []; %records shifted landscape
    gen = t - 1; %track generation

end

finished = SIMOPTS.NGEN; %if simulation ends early, this will tell the final generation simulated
babies = GENVARS.babies;
land = GENVARS.land;
basic_map = GENVARS.basic_map;

% loop parameters

done = 0; %determines when loop is done
while done==0, 
    gen = gen +1; %increment the generation
    
%% Report simulation progress to the Command Window
    if mod(gen,10)==0, %Display progress every 10 generations
      if SIMOPTS.exp_type==0 || SIMOPTS.exp_type==3, %Single mutability or duel
        if mod(gen,100)==0, 
          fprintf(['gen=%1.0f \t pop=%1.0f of ' GENVARS.exp_name '\n'],gen,size(babies,1));
        else, 
          fprintf(['gen=%1.0f \t pop=%1.0f \n'],gen,size(babies,1));
        end
      else, %Competing mutabilities
        if mod(gen,100)==0, 
          fprintf(['gen=%1.0f \t pop=%1.0f \t mus=%1.0f of ' GENVARS.exp_name '\n'],...
                  gen,size(babies,1),length(unique(babies(:,3))));
        else, 
          fprintf(['gen=%1.0f \t pop=%1.0f \t mus=%1.0f \n'],...
                  gen,size(babies,1),length(unique(babies(:,3))));
        end
      end
    end
    
    %set conditional here for intial appending if SIMOPTS.append ==1 && on
    %the first gen to start then do this... else do this... end
    
%% Determine nearest (mates) and second nearest (alternates) neighbors

if gen ~= t %set conditional to bypass if appending to bypass find mates at first pass
    [M,M_DIST,SN,SN_DIST] = FindMates(babies,land);%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Record basic population data
  if SIMOPTS.only_lt==0, 
    population(gen) = size(babies,1); %record population
    if SIMOPTS.exp_type~=0, trace_noise = [trace_noise; babies(:,3)]; end;  %record mutability
    trace_x = [trace_x; babies(:,1)]; %records x position of traced animals
    trace_y = [trace_y; babies(:,2)]; %records y position of traced animals
    trace_cluster_seed = [trace_cluster_seed; [M,SN]]; %record cluster seeds
    seed_distances = [seed_distances; [M_DIST,SN_DIST]];
    parents = [parents; adults];
  end
else
    if SIMOPTS.only_lt == 0,
      trace_x = [trace_x]; %records x position of traced animals
    trace_y = [trace_y]; %records y position of traced animals
    trace_cluster_seed = [trace_cluster_seed]; %record cluster seeds
    seed_distances = [seed_distances];
    parents = [parents];
    kills = [kills];
    u=sum(population(az-1))+1;
    v=sum(population);
    M = trace_cluster_seed(u:v);
    end
end

%% Reproduction & Death
  %BABIES GROW UP
  par = babies; %current babies are the new parents!

  %MAKE BABIES
  babies=[]; %clear previous population of babies
  [babies,adults] = MakeBabies(par,M,land);%%%%%%%%

  %OVERPOPULATION DEATH
  [babies,adults,odkills,sibrivals] = OverpopulationDeath(babies,adults);
%   % record nearest neighbor distances and the mean neighbor distance
%   if SIMOPTS.only_ttf==0
%     nn_dist = [nn_dist; nnd]; %update nn_dist (nearest neighbor distance)
%     mnd(gen) = mean(nnd); %update mnd (mean of nearest neighbor distances)
%   end

  %ALSO SOME RANDOM DEATH FOR THIS GENERATION
  [babies,adults,rdkills] = RandomDeath(babies,adults);

  %ALSO KILL BABIES OUTSIDE OF phenotype values allowed in the mapping
  if SIMOPTS.reproduction~=3,  
    [babies,adults,cjkills] = CliffJumpers(babies,adults,land);
  else, cjkills = []; end
  %%% If anyone decides to implement cylindrical or toroidal landscapes, %%%
  %%% then they'll need to update or remove CliffJumpers. %%%

  %ADJUST LANDSCAPE randomly for the babies. Add feedback??
  [land,basic_map,old_land] = AdjustLandscape(basic_map,land,gen);
    
  if SIMOPTS.only_lt==0, 
    %Collect kill counts
    kills = [kills; [odkills, rdkills, cjkills]];
    rivalries(gen) = [sibrivals];
    %Collect landscapes
    if SIMOPTS.shock==0, 
      shifted = [old_land; shifted(2:(size(shifted,1)),:)]; %update shifted
    else, 
      shifted = [old_land; shifted]; %update shifted
    end
  end
%% Determine whether to end generation looping
  %if competing mus & only 1 mu left      or last gen  or not enough babies     then end of sim                   
  if (SIMOPTS.exp_type==1 && length(unique(babies(:,3)))==1) || gen==SIMOPTS.NGEN ||...
      size(babies,1)<SIMOPTS.limit, done = 1; end
end
finished = gen; %report the last generation simulated
%% Clean up some output data
if SIMOPTS.only_lt==0
  population = population(population>=SIMOPTS.limit); %get non-zero populations
  rivalries = rivalries(population>=SIMOPTS.limit);
  %In case simulation ends earlier than NGEN
  if finished<SIMOPTS.NGEN
    %get only non-zero rows of shifted
    if SIMOPTS.landscape_heights(1)~=SIMOPTS.landscape_heights(2)
      shifted = shifted(shifted(:,1)~=0);
    end
  end
end

%% Bundle the output data into GENOUTS
GENOUTS = struct('population',population,'trace_x',trace_x,...
  'trace_y',trace_y,'trace_cluster_seed',trace_cluster_seed,'seed_distances',seed_distances,...
  'parents',parents,'kills',kills,'rivalries',rivalries,'land',land,'shifted',shifted,...
  'finished',finished); %need to add back if tracking competition...'trace_noise',trace_noise,i.e. may need to fix
end