%
%  unit2double.m
%
%  Created by Léa Strobino.
%  Copyright 2013 hepia. All rights reserved.
%

function x = unit2double(s,u)
if nargin < 2
  u = '';
end
if ~isempty(s) && iscellstr(s)
  if ~iscellstr(u)
    v = u;
    u = cell(size(s));
    u(:) = {v};
  end
  x = cellfun(@unit2double,s,u);
else
  s = strtrim(s);
  k = strfind(s,u);
  if isempty(k)
    k = length(s)+1;
  end
  if k == 1
    e = 0;
  else
    e = s(k(end)-1);
    p = 'yzafpnµumkMGTPEZY';
    e = sum([-24:3:-6 -6 -3 3:3:24].*(e==p));
  end
  if e == 0
    s = s(1:k(end)-1);
  else
    s = s(1:k(end)-2);
  end
  if isempty(s)
    x = 0;
  else
    x = 10^e*str2double(s);
  end
end
