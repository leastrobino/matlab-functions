%
%  fixd.m
%
%  Created by Léa Strobino.
%  Copyright 2013 hepia. All rights reserved.
%

function str = fixd(d,n,~)
if nargin < 2 || isempty(n)
  n = 3;
end
if numel(n) ~= numel(d)
  n = n(1)*ones(size(d));
end
str = cell(size(d));
for i = 1:numel(d)
  if ~isfinite(d(i))
    str{i} = sprintf('%f',d(i));
  elseif n(i) < 0
    str{i} = sprintf('%d',round(d(i)*10^n(i))*10^-n(i));
  else
    str{i} = sprintf(sprintf('%%.%df',n(i)),d(i));
  end
end
if numel(d) == 1 && nargin < 3
  str = str{1};
end
