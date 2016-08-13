%% cat_row.m
% [result] = cat_row(old,new)
% input:
% old - matrix to which you want to append new
% new - row vector to which you want to append to new
%
% output:
% result - resulting matrix which buffers any columns mismatched with zeros
function [result] = cat_row(old,new)
[rn cn] = size(new);
[ro co] = size(old);
result = [];
if cn>co
  result = zeros((ro+rn),cn);
  result(1:ro,1:co) = old;
  result((ro+1):(ro+rn),:) = new;
else
  result = zeros((ro+rn),co);
  result(1:ro,:) = old;
  result((ro+1):(ro+rn),1:cn) = new;
end
end