%% RandomDeath
% input - babies, parents
% output - remaining babies, their parents, and number killed
% Depending on indiv_death option, either population scaled death or equal chance.
% Random individuals are killed off based on a uniformly distributed random
% number scaled by the maximum fraction of the population able to kill,
% death_max.  This determines a percentage of the population to kill at
% random.  This is an update to the RandomDeath function which did not have
% the save parents option included.
% function [babies] = RandomDeath(babies,death_max)
% function [babies,parents,rdkills] = RandomDeath(babies,death_max,indiv_death,parents,sp,k)
function [babies,parents,rdkills] = RandomDeath(babies,parents)
global SIMOPTS;
if SIMOPTS.indiv_death == 0, 
%   death_percent = 0.35; %hard set death_percent for control conditions only
  death_percent = (SIMOPTS.dm)*rand; %pick the random percentage of babies to kill
  death_number = round(death_percent * size(babies,1));%exactly how many to kill
  death_row = round(1 + (size(babies,1)-1)*rand(death_number,1)); %which ones to kill
elseif SIMOPTS.indiv_death == 1, %each has a certain percentage of dying based off of death_max
  death_percent = rand(size(babies,1),1);
  death_row = find(death_percent <= SIMOPTS.dm);
  death_number = length(death_row);
end
babies(death_row,:) = []; %kill them.
if SIMOPTS.save_parents==1, parents(death_row,:) = [];  end
if SIMOPTS.save_kills==1, rdkills = death_number; else, rdkills = []; end
end