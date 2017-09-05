%
%  frequencyplot.m
%
%  Created by Léa Strobino.
%  Copyright 2014 hepia. All rights reserved.
%

function hplot = frequencyplot(varargin)
h = semilogx(varargin{:});
a = get(h,'Parent');
if iscell(a)
  a = a{1};
end
XLim = objbounds(findall(a));
XTick = [reshape((1:9)'*10.^(-1:5),1,[]) 1E6];
XTickLabel = {'0.10','0.20','0.30','','0.50','','0.70','','',...
  '1','2','3','','5','','7','','',...
  '10','20','30','','50','','70','','',...
  '100','200','300','','500','','700','','',...
  '1k','2k','3k','','5k','','7k','','',...
  '10k','20k','30k','','50k','','70k','','',...
  '100k','200k','300k','','500k','','700k','','',...
  '1M'};
set(a,'XTick',XTick,'XTickLabel',XTickLabel);
set(a,'XMinorTick','off','YMinorTick','off');
set(a,'XGrid','on','YGrid','on','XMinorGrid','off','YMinorGrid','off');
try %#ok<TRYNC>
  set(a,'XLim',XLim(1:2));
end
set(get(a,'XLabel'),'String','Frequency (Hz)');
set(get(a,'YLabel'),'String','SPL (dB)');
if nargout
  hplot = h;
end
