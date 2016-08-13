%% try_catch_load.m
% [data,flag,error] = try_catch_load(data_name,flag,do_print)
% This function will attempt to load the data file passed to it, data_name.
% If successful, the data is loaded.
% Otherwise, an error message is displayed and the flag, which is boolean,
% will toggle to the opposing state of it's input value.

function [data,flag,error] = try_catch_load(data_name,flag,do_print), 
error = []; data = [];
try, 
  data = load(data_name);
catch error, 
  if do_print==1, fprintf([error.message '\n']);  end
  if flag==1, flag = 0; else, flag = 1; end
end 
end