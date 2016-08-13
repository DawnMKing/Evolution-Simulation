%% FindMates.m
% [M,SN,M_dist,SN_dist] = FindMates3(babies,rep,land)
% Inputs:
% babies
% rep = reproduction type
% Outputs:
% M = vector of mates
% SN = vector of second nearest neighbors
% M_dist = vector of mate distances
% SN_dist = vector of second nearest neighbor distances
%
% FindMates3 adds an automated search region to FindMates2.
% Searches are done by finding individuals within an area in the shape of squares.
% The internal variable, try_coords, is organized as:
% | square_max_x    square_max_y |
% | square_min_x    square_min_y |
function [M,M_dist,SN,SN_dist] = FindMates(babies,land)
global SIMOPTS;
pop = size(babies,1); ls = max(size(land));
ttl = 2.^[0:10]; ittl = find(ttl<=ls);  
if ttl(ittl(end))>=ls, fin = ttl(ittl(end));  
elseif ttl(ittl(end))<=ls,  fin = ls; end
try_limits = [ttl(ittl) fin fin fin fin]'*ones(1,2); %limits 
dc_limits =  sqrt(2)*[0 ttl(ittl) fin fin fin fin fin]'*ones(1,2); %double check limits
if SIMOPTS.reproduction~=1, 
  if SIMOPTS.reproduction==0, 
    M = zeros(pop,1); %initialize the mate-and-cluster variable (MNC) for this generation
    SN = zeros(pop,1); %list second neighbors
    M_dist = M;
    SN_dist = SN;
    for i=1:pop %for each baby
      this_coord = [babies(i,1) babies(i,2)]; %[x y]
      j = 0;  last = 0; double_checked = 0;
      
      while M(i)==0 && SN(i)==0 && double_checked==0
      
        j = j +1;
        if last==0
          try_coords = [this_coord+try_limits(j,:); this_coord-try_limits(j,:)]; %determine search area
        else
          try_coords = [this_coord+dc_limits(j,:); this_coord-dc_limits(j,:)]; %determine search area
        end
        try_these = find((babies(:,1)>try_coords(2,1) & babies(:,1)<try_coords(1,1) & ...
          babies(:,2)>try_coords(2,2) & babies(:,2)<try_coords(1,2))); %find possible neighbors
      if SIMOPTS.limit >= 3
        if length(try_these)>2
          if last==0
            last = 1;
          else
            distance = (babies(try_these,1)-babies(i,1)).^2 + ...
              (babies(try_these,2)-babies(i,2)).^2; %find the distance to all other babies
            sort_distance = sort(distance); %sort the distances
            %find the other seeds for clustering and record it.
            M(i) = try_these(distance==sort_distance(2));
            M_dist(i) = sqrt(sort_distance(2));
            
            SN(i) = try_these(distance==sort_distance(3));
            SN_dist(i) = sqrt(sort_distance(3));
           
                
            
            double_checked = 1;
          end%last
        end
      else
          if length(try_these)>1
            if last==0
            last = 1;
            else
            distance = (babies(try_these,1)-babies(i,1)).^2 + ...
              (babies(try_these,2)-babies(i,2)).^2; %find the distance to all other babies
            sort_distance = sort(distance); %sort the distances
            %find the other seeds for clustering and record it.
            M(i) = try_these(distance==sort_distance(2));
            M_dist(i) = sqrt(sort_distance(2));
            
            
                SN(i) = 0;
                SN_dist(i) = 0;
            
            double_checked = 1;
          end%last
            
        end%try_these >2
      end%limit>=3
      end%while
    end %end of assigning mates
  elseif SIMOPTS.reproduction==2, %Random_Mating
    M_dist = [];
    SN_dist = [];
    M = ceil(pop*rand(pop,1));  %select a random mate for each organism
    %check if mate and second nearest are the same, so need three unique indivs to make a 
    %Nate cluster...maybe set SN post simulation......
    same = find([1:pop]'==M); %see if there are mates which identical to their partner
    while length(same)>0 %while there is a mate that is itself
      alt = ceil(rand(1,length(same))*pop); %try an alternate mate
      M(same) = alt; %set the alternative
      same = find([1:pop]'==M); %see if there are mates which are identical to their partner
    end
    if SIMOPTS.limit >= 3
    SN = ceil(pop*rand(pop,1));
    same2 = find([1:pop]'==SN | M==SN); %see if there are mates which identical to their partner
    while length(same2)>0 %while there is a mate that is itself
      alt = ceil(rand(1,length(same2))*pop); %try an alternate mate
      SN(same2) = alt; %set the alternative
      same2 = find([1:pop]'==SN | M==SN); %see if there are mates which are identical to their partner
    end
    end
    if SIMOPTS.limit < 3
        SN= [];
    end
  end
else, %Bacterial
  M = [];
  SN = [];
  M_dist = [];
  SN_dist = [];
end
end
%   cluster_assignment = 1; %initiate cluster assignment variable
%   while (find(MNC(:,4)==0)), %while there are still unassigned babies,
%       [first,col] = find(MNC(:,4)==0,1); %find the first unassigned baby
%       MNC(first,4) = cluster_assignment; %and give it an assignment.
%       list = [MNC(first,1) MNC(first,2) MNC(first,3)]; %create a list to search and make more assignments
%       list = unique(list); %no repeats on the list (sorts the list also)
%       already_searched = []; %to make for faster searching, start a record of what was searched.
%       while list, %while there is still a list,
%           for searching4 = list, %for each number on the list
%               [r,c] = find(MNC(:,1:3)==searching4); %find places where these numbers exist elsewhere
%               MNC(r,4) = cluster_assignment; %give them the same assignment
%               already_searched = [already_searched searching4]; %update the list of what you have searched
%               list = [list (MNC(r,1))' (MNC(r,2))' (MNC(r,3))']; %put their mates on the list to search also
%               list = unique(list); %take off any repeats.
%               for i=1:length(already_searched), %for each item that has already been searched
%                   list(find(list==already_searched(i)))=[]; %take off anything that has already been searched.
%               end %end of editing list based on what has already been searched
%           end %end of searching this list
%       end %end of searching the ever-expanding list
%       cluster_assignment = cluster_assignment+1;
%   end %all babies have a cluster assignment!
% end