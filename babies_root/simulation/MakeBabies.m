%% MakeBabies.m v4
% function [babies,parents] = MakeBabies3(par,M,land,rndm,sp,rep)
% Inputs:
% par = reference parent
% M = mate
% land = landscape
% rndm = offspring distribution
% sp = save parents option
% rep = reproduction type
% Outputs:
% babies = offspring
% parents = parents of the offspring
%
% This function is updated from v3 and now allows Confined simulations.
% function [babies,parents] = MakeBabies(par,M,land,rndm,sp,rep,et)
% function [babies,parents] = MakeBabies3(par,M,land,rndm,sp,rep)
% function [babies,parents] = MakeBabies2(par,M,land,rndm,sp)
% function [babies] = MakeBabies(par,MNC,land,rndm)
function [babies,parents] = MakeBabies(par,M,land)
global SIMOPTS;
babycount = 1; %start baby count
[max_babies] = getFitnessOfPopulation(par,land);
parents = zeros(max_babies,2);
par_fitness = zeros(size(par,1),1);
u = 0;  v = 0;
for i=1:size(par,1) %for each parent
  if SIMOPTS.reproduction==0 || SIMOPTS.reproduction==2
    r = M(i);
    %now 'i' represents current parent, and 'r' the other parent
    %noise value will be taken from the current, 'i', parent; par(i,4)
    %replaces bnoise in lowb and highb calculations below
    %who is closest in phenotype
    lowb = [min(par(i,1),par(r,1))-par(i,3) min(par(i,2),par(r,2))-par(i,3)]; %low range of the babies phenotype
    highb = [max(par(i,1),par(r,1))+par(i,3) max(par(i,2),par(r,2))+par(i,3)]; %high range of the babies phenotype
  elseif SIMOPTS.reproduction==1
    r = [];
    lowb = [par(i,1)-par(i,3), par(i,2)-par(i,3)];
    highb = [par(i,1)+par(i,3), par(i,2)+par(i,3)];
  end
  par_fitness(i) = land(round(par(i,1)),round(par(i,2))); %how many babies to have (based on fitness map)
  u = v +1;
  v = u +par_fitness(i) -1;
  for baby=u:v %for however many babies i should have for this parent
    if SIMOPTS.distribution==0, 
      ran = rand(2);
    elseif SIMOPTS.distribution==1, 
      ran = randn(2);
    end
    if SIMOPTS.exp_type==3, 
      babies(babycount,1:3) = [ran(1)*size(land,1) ran(2)*size(land,2) par(i,3)];
    else, 
      babies(babycount,1:3) = [lowb(1)+(highb(1)-lowb(1))*ran(1) lowb(2)+(highb(2)-lowb(2))*ran(2)  par(i,3)]; %make baby
    end
%           if (par(i,4)==1 || par(r,4)==1), babies(babycount,4)=1; end %check for trace
    babycount = babycount + 1; %baby is made, and move on to next baby
    if SIMOPTS.save_parents==1, parents(baby,:) = [i r]; end
  end %end of babies for this parent
end %end of making babies
%  if (size(babies,1)>10000), disp(['Exceeded 10000 babies at generation ' num2str(gen) '.']); end
end