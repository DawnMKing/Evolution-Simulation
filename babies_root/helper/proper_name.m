function [n2sb] = proper_name(b)
n2sb = num2str(b);
if b<1
  decimal = find('.'==n2sb);
  %if bnoise is, say 0.51, then the string will be 51
  n2sb = n2sb(decimal+1:end);
%   if length(n2sb)<decimal
%     %if bnoise is, say 0.5, then the string will be 50
%     n2sb = [n2sb '0'];
%   end
else
  decimal = find('.'==n2sb);
  if length(decimal)>0
    %if bnoise is, say 1.25, then the string will be 1_25
    n2sb = [n2sb(1:decimal-1) '_' n2sb(decimal+1:end)];
  else
    n2sb = [n2sb '_0'];
  end
end
end