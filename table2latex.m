%
%  table2latex.m
%
%  Created by Léa Strobino.
%  Copyright 2016 hepia. All rights reserved.
%

function s = table2latex(var,n,hline)
if nargin < 2 || isempty(n)
  n = 3;
end
if nargin < 3 || isempty(hline)
  hline = false;
else
  hline = logical(hline);
end
if numel(n) ~= size(var,2)
  n = n(1)*ones(size(var,2));
end
d = cell(size(var));
for i = 1:size(d,2)
  d(:,i) = fixd(var(:,i),n(i),0);
end
s = ''; %#ok<*AGROW>
if hline
  s = ['\hline' 10];
end
for i = 1:size(d,1)
  s = [s sprintf('%s & ',d{i,:})];
  s = [s(1:end-2) '\\' 10];
  if hline
    s = [s '\hline' 10];
  end
end
s = s(1:end-1);
if ~nargout
  t = s;
  t(t == 10) = ' ';
  t = ['\begin{tabular}{|' repmat('c|',1,size(d,2)) '}' t '\end{tabular}'];
  if ispc
    fs = 10;
  else
    fs = 16;
  end
  h = figure(...
    'Color',[1 1 1],...
    'DockControls','off',...
    'MenuBar','none',...
    'Resize','off',...
    'Toolbar','none',...
    'WindowStyle','normal');
  a = axes(...
    'Units','pixels',...
    'Parent',h,...
    'Position',[10 10 1 1],...
    'Visible','off');
  t = text(0,0,t,...
    'Units','pixels',...
    'FontSize',fs,...
    'HorizontalAlignment','left',...
    'Interpreter','LaTeX',...
    'Parent',a,...
    'VerticalAlignment','bottom');
  ss = get(0,'ScreenSize');
  w = warning('off','MATLAB:handle_graphics:exceptions:SceneNode');
  e = get(t,'Extent');
  warning(w);
  if all(e == 0)
    close(h);
    warning('table2latex:LatexTableTooBig',...
      'LaTeX table is too big to be displayed in a figure.');
  else
    set(h,'Position',[(ss(3:4)-e(3:4))/2-10 e(3:4)+20]);
    set(a,'Position',[10 10 e(3:4)]);
  end
end
