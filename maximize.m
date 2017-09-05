%
%  maximize.m
%
%  Created by Léa Strobino.
%  Copyright 2015 hepia. All rights reserved.
%

function maximize(h)
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
if nargin == 0
  h = gcf;
end
if ischar(h)
  if strcmpi(h,'all')
    h = findobj('Type','figure');
  else
    error('Argument must be a correct string.');
  end
else
  for n = 1:length(h)
    if ~ishghandle(h(n)) || ~strcmpi(get(h(n),'Type'),'figure')
      error('Argument(s) must be (a) correct handle(s).');
    end
  end
end
for n = length(h):-1:1
  jh = handle(h(n));
  jh.JavaFrame.setMaximized(true);
end
