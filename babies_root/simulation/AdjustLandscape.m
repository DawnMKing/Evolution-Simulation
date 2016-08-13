%% AdjustLandscape.m
% inputs - basic_map, landscape
% function [land,basic_map,old_land] = AdjustLandscape(basic_map,land,gen)
function [land,basic_map,old_land] = AdjustLandscape(basic_map,land,gen)
global SIMOPTS;
old_land = [];
if SIMOPTS.shock==0, 
  if ~mod(gen,SIMOPTS.landscape_movement),
    if SIMOPTS.landscape_heights(1)~=SIMOPTS.landscape_heights(2), 
      old_land = land(end-4:end,:);
      basic_map=[rand(1,size(basic_map,1))*4.0; basic_map(1:end-1,:);]; %create new random landscape column for left side
      land=ceil(interp2(basic_map,2)); %put new map together and interpolate
    end
  end %end of landscape adjustment
else, 
  if ~mod(gen,SIMOPTS.landscape_movement),
    old_land = basic_map;
    basic_map=rand(size(basic_map))*SIMOPTS.landscape_heights(2);
    land=ceil(interp2(basic_map,2)); %put new map together and interpolate
  end
end
end