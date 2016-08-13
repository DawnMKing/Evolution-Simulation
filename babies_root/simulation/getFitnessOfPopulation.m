%% getFitnessOfPopulation
% inputs - parents, landscape
% output - maximum offspring production
% This function determines how many offspring will be produced by the
% MakeBabies function. This is also the summed fitness of the population.
% This function may also be useful during analysis when determining the
% fitness of a population of a generation (be careful to use this for
% single generations if the landscape is shift or shock; this can be used
% for all generations if the landscape is frozen or flat).
function [potential] = getFitnessOfPopulation(babies,land)
pop = size(babies,1);
organisms = zeros(size(babies));
%Need to round to the nearest grid point. Some locations may be near 0,
%so we need to determine which ones are less than 0.5 at least to round
%them up.  Additionally, some locations may be between 45 and 45.5, so
%for those meeting this criteria will need to be floored.  Otherwise,
%just round the locations to the grid points.
x1 = find(babies(:,1)>=0.5 & babies(:,1)<=45);
x2 = find(babies(:,1)<0.5);
x3 = find(babies(:,1)>45);
organisms(x1,1) = round(babies(x1,1));
organisms(x2,1) = ceil(babies(x2,1));
organisms(x3,1) = floor(babies(x3,1));
y1 = find(babies(:,2)>=0.5 & babies(:,2)<=45);
y2 = find(babies(:,2)<0.5);
y3 = find(babies(:,2)>45);
organisms(y1,2) = round(babies(y1,2));
organisms(y2,2) = ceil(babies(y2,2));
organisms(y3,2) = floor(babies(y3,2));
potential = 0;
for i = 1:pop
  potential = potential +land(organisms(i,1),organisms(i,2));
end
end