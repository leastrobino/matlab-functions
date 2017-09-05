%
%  frequencybar.m
%
%  Created by Léa Strobino.
%  Copyright 2013 hepia. All rights reserved.
%

function hbar = frequencybar(x,varargin)
h = bar(log10(x),varargin{:});
a = get(h,'Parent');
if iscell(a)
  a = a{1};
end
if length(x) > 10
  x = x(round(linspace(1,length(x),12)));
end
set(a,'XTick',log10(x),'XTickLabel',double2unit(x,3));
set(get(a,'XLabel'),'String','Frequency (Hz)');
set(get(a,'YLabel'),'String','SPL (dB)');
if nargout
  hbar = h;
end
