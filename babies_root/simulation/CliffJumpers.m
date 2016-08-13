%% CliffJumpers
% input - babies, parents, landscape
% output - babies that didn't go out of bounds, their parents, number killed
% Those babies which are not between 0.5 and max(size(land))+0.5 along either phenotype
% axis will be killed.  This code is taken directly from Nate's design
% along with the save parents option. This has been updated to work with global SIMOPTS.
% function [babies,adults,cjkills] = CliffJumpers(babies,adults,land)
function [babies,adults,cjkills] = CliffJumpers(babies,adults,land)
global SIMOPTS;
% within phenotypes 0.5 & 45.5 survive
[outside]=find(babies(:,1) > size(land,1)+0.5 | babies(:,1) < 0.5 |...
               babies(:,2) > size(land,1)+0.5 | babies(:,2) < 0.5);
babies(outside,:) = []; %kill them.
if SIMOPTS.save_parents==1, adults(outside,:) = []; end %remove their parents
if SIMOPTS.save_kills==1, cjkills = length(outside); else, cjkills = [];  end
end