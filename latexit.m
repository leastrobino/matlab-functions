%
%  latexit.m
%
%  Created by Léa Strobino.
%  Copyright 2016 hepia. All rights reserved.
%

function latexit(s,fs,file)
persistent tmp
if isempty(tmp)
  tmp = [tempdir() '/equation.pdf'];
end
if nargin < 2 || isempty(fs)
  fs = 11;
end
if nargin < 3
  file = '';
end
if ~isempty(file)
  [path,name,ext] = fileparts(file);
  if isempty(path)
    path = pwd();
  end
  switch lower(ext)
    case '.emf'
      if ~ispc
        error('MATLAB:print:InvalidDeviceOption',...
          'EMF export is only supported on Microsoft Windows platforms.');
      end
      format = '-dmeta';
    case '.eps'
      format = '-depsc';
    case '.pdf'
      format = '-dpdf';
    case '.png'
      format = '-dpng';
    case {'.tif','.tiff'}
      format = '-dtiff';
    otherwise
      format = '-dpdf';
      ext = [ext '.pdf'];
  end
  file = fullfile(path,[name ext]);
end
h = figure(...
  'Units','points',...
  'PaperUnits','points',...
  'Visible','off');
a = axes(...
  'Units','points',...
  'Parent',h,...
  'Position',[0 0 1 1],...
  'Visible','off');
if ispc
  if ~isempty(file) && strcmp(format,'-dpdf')
    o = [1 2];
  else
    o = [1.5 3.5];
  end
  m = [0 0 2 5];
else
  o = [.5 1];
  m = [0 0 1.5 3.5];
end
t = text(o(1),o(2),['$$' s '$$'],...
  'Units','points',...
  'FontSize',fs,...
  'HorizontalAlignment','left',...
  'Interpreter','LaTeX',...
  'Parent',a,...
  'VerticalAlignment','bottom');
w = warning('off','MATLAB:handle_graphics:exceptions:SceneNode');
e = get(t,'Extent');
warning(w);
if all(e(3:4) == 0)
  close(h);
  error('latexit:SyntaxError','Syntax error in LaTeX string.');
end
e = e+m;
set(h,'PaperPosition',e,'PaperSize',e(3:4));
if ispc
  if isempty(file)
    print(h,'-dmeta');
  else
    print(h,format,'-r600','-painters',file);
  end
else
  if isempty(file)
    print(h,'-dpdf',tmp);
    [~,~] = system(['osascript -e ''set the clipboard to POSIX file ("' tmp '")''']);
  else
    print(h,format,'-r600','-painters',file);
  end
end
close(h);
