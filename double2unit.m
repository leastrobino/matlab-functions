%
%  double2unit.m
%
%  Created by Léa Strobino.
%  Copyright 2013 hepia. All rights reserved.
%

function s = double2unit(d,n,u)
if nargin < 3 || ~(ischar(u) || iscellstr(u))
  u = '';
end
if ~iscellstr(u)
  u = {u};
end
if numel(u) ~= numel(d)
  v = u;
  u = cell(size(d));
  u(:) = v;
end
if nargin < 2
  n = [];
end
p = {'y','z','a','f','p','n','µ','m','','k','M','G','T','P','E','Z','Y'};
m = floor(log10(abs(d))/3);
m(~isfinite(m)) = 0;
d = d./10.^(3*m);
try
  m = p(m+9);
catch %#ok<CTCH>
  error('Value is out of bounds (1E-24 <= x < 1E+27).');
end
s = double2str(d,n,0);
for i = 1:numel(d)
  s{i} = strtrim([s{i} ' ' m{i} u{i}]);
end
if length(s) == 1
  s = s{1};
end
