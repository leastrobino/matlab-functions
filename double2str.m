%
%  double2str.m
%
%  Created by Léa Strobino.
%  Copyright 2013 hepia. All rights reserved.
%

function str = double2str(d,n,~)
if nargin < 2 || isempty(n)
  n = 3;
end
if numel(n) ~= numel(d)
  n = n(1)*ones(size(d));
end
str = cell(size(d));
for i = 1:numel(d)
  if ~isfinite(d(i))
    s = sprintf('%f',d(i));
  elseif d(i) == 0
    s = sprintf(sprintf('%%.%df',n(i)),0);
  else
    sd = -floor(log10(abs(d(i)))-n(i)+1);
    if sd > 0
      s = sprintf('%d',round(abs(d(i))*10^sd));
      l = length(s);
      if l == abs(sd)
        s = ['0.' s(1:end)];
      elseif l < abs(sd)
        s = sprintf(sprintf('0.%%0%dd%%s',abs(sd)-l),0,s);
      else
        s = [s(1:(l-sd)) '.' s((l-sd+1):end)];
      end
      if d(i) < 0
        s = ['-' s(1:end)];
      end
    else
      s = sprintf('%d',round(d(i)*10^sd)*10^-sd);
    end
  end
  str{i} = s;
end
if numel(d) == 1 && nargin < 3
  str = str{1};
end
