%
%  exportfig.m
%
%  Created by Léa Strobino.
%  Copyright 2017 hepia. All rights reserved.
%

function exportfig(varargin)
persistent gs gsbuiltin
if isempty(gs)
  [gs,gsbuiltin] = find_gs();
end
varargin = [varargin cell(1,7)];

% Parse figure handle and name
if isa(varargin{1},'matlab.ui.Figure') && ishandle(varargin{1}(1))
  h = varargin{1}(1);
  varargin = varargin(2:end);
else
  h = gcf();
end
figName = sprintf('%.0f',get(h,'Number'));
if ~isempty(get(h,'Name'))
  figName = [figName ' (' get(h,'Name') ')'];
end

try
  
  % Copy figure
  fig = figure(...
    'Color',[1 1 1],...
    'Colormap',get(h,'Colormap'),...
    'HandleVisibility','off',...
    'IntegerHandle','off',...
    'InvertHardcopy','off',...
    'PaperOrientation','portrait',...
    'PaperUnits','centimeters',...
    'Visible','off');
  copyobj(get(h,'Children'),fig);
  
  % Parse file name and format
  pgf = false;
  tpx = false;
  if ~isempty(varargin{1})
    clipboard = false;
    [path,name,ext] = fileparts(varargin{1});
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
      case '.pgf'
        format = '-depsc';
        pgf = true;
      case '.png'
        format = 'png';
      case '.svg'
        format = '-dsvg';
      case {'.tif','.tiff'}
        format = 'tiff';
      case '.tpx'
        format = '-dsvg';
        tmpfile = [tempname() '.svg'];
        tpx = true;
      otherwise
        format = '-dpdf';
        ext = [ext '.pdf'];
    end
    file = fullfile(path,[name ext]);
  else
    clipboard = true;
    if ispc
      format = '-dmeta';
      file = '';
    elseif ismac
      format = '-dpdf';
      file = [tempdir() '/figure.pdf'];
    else
      error('MATLAB:print:InvalidDeviceOption',...
        'Copy to the system clipboard is not supported on this platform.');
    end
  end
  
  % Parse paper size
  paperSize = [20 13.8];
  if ~isempty(varargin{2})
    if ischar(varargin{2})
      if any(varargin{2} == 'x')
        paperSize = sscanf(varargin{2},'%fx%f')'/10;
      elseif any(strcmpi(varargin{2},{'A4','A4h'}))
        paperSize = [28.7 20];
      elseif strcmpi(varargin{2},'A4v')
        paperSize = [20 28.7];
      elseif strcmpi(varargin{2},'A5v')
        paperSize = [13.8 20];
      end
    else
      paperSize = [varargin{2}(1) varargin{2}(2)]/10;
    end
  end
  set(fig,'PaperPosition',[0 0 paperSize],'PaperSize',paperSize);
  
  % Parse margin
  margin = .1;
  maximize = true;
  if ~isempty(varargin{3})
    if ischar(varargin{3})
      if strcmpi(varargin{3},'default')
        maximize = false;
      else
        margin = sscanf(varargin{3},'%f')/10;
      end
    else
      margin = varargin{3}/10;
    end
  end
  
  % Parse font name
  axes = findall(fig,'Type','Axes');
  colorbar = findall(fig,'Type','ColorBar');
  legend = findall(fig,'Type','Legend');
  text = findall(fig,'Type','Text');
  if ~isempty(varargin{4})
    switch lower(varargin{4})
      case {'arial','helvetica'}
        set(axes,'FontName','Helvetica');
      case {'times','timesnewroman'}
        set(axes,'FontName','Times New Roman');
      case 'latex'
        set([axes;colorbar],'TickLabelInterpreter','LaTeX');
        set([legend;text],'Interpreter','LaTeX');
    end
  end
  
  % Parse font size and set default color
  fontSize = 11;
  if ~isempty(varargin{5})
    if ischar(varargin{5})
      fontSize = sscanf(varargin{5},'%f');
    else
      fontSize = varargin{5};
    end
  end
  set(axes,'FontSize',fontSize/1.1,'XColor',[0 0 0],'YColor',[0 0 0],'ZColor',[0 0 0]);
  set(colorbar,'FontSize',fontSize/1.1,'Color',[0 0 0]);
  set(legend,'FontSize',fontSize/1.1);
  set(text,'FontSize',fontSize);
  
  % Maximize the figure
  paperPosition = [0 0 paperSize];
  if maximize
    for i = 1:3
      img = flip(rgb2gray(print(fig,'-RGBImage','-r72')),1);
      s = size(img);
      c = find(~all(img == img(1,1),1));
      r = find(~all(img == img(1,1),2));
      if numel(c) > 1 && numel(r) > 1
        w = [c(1)-1 c(end)-c(1)]/s(2);
        h = [r(1)-1 r(end)-r(1)]/s(1);
        paperPosition = [...
          (margin-paperSize(1)*w(1))/w(2)...
          (margin-paperSize(2)*h(1))/h(2)...
          (paperSize(1)-2*margin)/w(2)...
          (paperSize(2)-2*margin)/h(2)];
        try
          set(fig,'PaperPosition',paperPosition);
        catch
          warning('exportfig:PaperPosition',...
            'Error while setting the ''PaperPosition'' property.');
          maximize = false;
          paperPosition = [0 0 paperSize];
          set(fig,'PaperPosition',paperPosition);
          break
        end
      else
        break
      end
    end
  end
  if pgf || tpx
    set([axes;colorbar],'TickLabelInterpreter','none');
    set([legend;text],'Interpreter','none');
    if pgf
      anchor = 'ctBblr';
      for i = 1:length(legend)
        set(legend(i),'String',cellfun(@(s)['\tex[cl][cl]{' s '}'],get(legend(i),'String'),'UniformOutput',0));
      end
      a = get(text,{'VerticalAlignment','HorizontalAlignment'});
      a = anchor(1+strcmp(a,'top')+2*strcmp(a,'baseline')+3*strcmp(a,'bottom')+4*strcmp(a,'left')+5*strcmp(a,'right'));
      s = get(text,{'String'});
      for i = 1:length(text)
        s{i} = sprintf('\\tex[%s][%s]{\\fontsize{%.3fpt}{0pt}\\selectfont %s}',a(i,:),a(i,:),fontSize,s{i});
      end
      set(text,{'String'},s);
    end
  end
  
  if format(1) == '-'
    % Export vector format
    set(fig,'Color','none');
    s = 1;
    if strcmp(format,'-depsc') || (strcmp(format,'-dpdf') && isa(gs,'function_handle'))
      try %#ok<TRYNC>
        % Export to EPS
        tmpfile = [tempname() '.eps'];
        print(fig,'-depsc','-r300','-painters','-loose',tmpfile);
        % Fix EPS file
        boundingBox = [-paperPosition(1:2) paperSize-paperPosition(1:2)];
        fixEPS(tmpfile,boundingBox);
        if ~isempty(findall(fig,'Type','Patch'))
          try %#ok<TRYNC>
            epsclean(tmpfile,'groupSoft',true);
          end
        end
        if strcmp(format,'-dpdf')
          % Convert to PDF using Ghostscript
          cmd = ['-q -dBATCH -dNOPAUSE -dEPSCrop -dFIXEDMEDIA '...
            sprintf('-dDEVICEWIDTHPOINTS=%.2f -dDEVICEHEIGHTPOINTS=%.2f ',paperSize*72/2.54)...
            '-sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="' file '"'];
          if ~gsbuiltin
            cmd = [cmd ' -dColorConversionStrategy=/sRGB -dProcessColorModel=/DeviceRGB -dUseCIEColor=true'];
          end
          s = gs(cmd,tmpfile);
          delete(tmpfile);
        else
          if ~pgf
            movefile(tmpfile,file,'f');
          end
          s = 0;
        end
      end
    end
    if s
      % Fall back to default method if something went wrong
      if pgf || tpx
        print(fig,format,'-r300','-painters',tmpfile);
      else
        print(fig,format,'-r300','-painters',file);
      end
    end
  else
    % Export bitmap format
    img = flip(print(fig,'-RGBImage','-r300','-opengl'),1);
    if maximize
      s = size(img);
      margin = round(margin*300/2.54);
      if margin < 0
        imgc = img(1-margin:s(1)+margin,1-margin:s(2)+margin,:);
      else
        imgc = 255*ones([s(1:2)+2*margin 3],'uint8');
        imgc((1:s(1))+margin,(1:s(2))+margin,:) = img;
      end
      img = imcrop(imgc,[...
        w(1)*s(2)...
        h(1)*s(1)...
        w(2)*s(2)+2*margin...
        h(2)*s(1)+2*margin]);
    end
    if strcmp(format,'png')
      imwrite(flip(img,1),file,format,...
        'ResolutionUnit','meter',...
        'XResolution',300/.0254,...
        'Software',['MATLAB ' version()]);
    else
      imwrite(flip(img,1),file,format,...
        'Resolution',300,...
        'Description',['MATLAB ' version()]);
    end
  end
  close(fig);
  
catch e
  close(fig);
  rethrow(e);
end

% Convert to PGF or TpX
if pgf || tpx
  try
    w = warning('off','MATLAB:DELETE:Permission');
    if pgf
      eps2pgf(tmpfile,file,fontSize/1.1);
    else
      svg2tpx(tmpfile,file)
    end
    delete(tmpfile);
    warning(w);
  catch e
    delete(tmpfile);
    warning(w);
    rethrow(e);
  end
end

% Display success message
if clipboard
  fprintf('Figure %s has been copied to the clipboard.\n',figName);
  if ispc
    % Display crop options
    fprintf('Crop options for Microsoft Office:\n');
    fprintf('  Picture position:\n');
    fprintf('    Width:    % 6.2f cm   Height:   % 6.2f cm\n',...
      paperPosition(3:4));
    fprintf('    Offset X: % 6.2f cm   Offset Y: % 6.2f cm\n',...
      ((paperPosition(3:4)-paperSize)/2+paperPosition(1:2)).*[1 -1]);
    fprintf('  Crop position:\n');
    fprintf('    Width:    % 6.2f cm   Height:   % 6.2f cm\n',...
      paperSize);
  else
    % Copy to system clipboard
    [~,~] = system(['osascript -e ''set the clipboard to POSIX file ("' file '")''']);
  end
else
  s = strrep(file,'''','''''');
  if ispc
    h = ['winopen(''' s ''')'];
  elseif ismac
    h = ['!open ''' file ''' &'];
  else
    h = ['open(''' s ''')'];
  end
  fprintf('Figure %s has been saved to <a href="matlab:%s">%s</a>.\n',figName,h,file);
end

end

function fixEPS(file,boundingBox)
% Read EPS file
h = fopen(file,'r');
eps = fread(h,'*char')';
fclose(h);
eps = strrep(eps,sprintf('\r\n'),sprintf('\n'));
% Fix creator and title
eps = regexprep(eps,'%%Creator:[^\n]*\n',['%%Creator: MATLAB ' version() '\n'],'once');
eps = regexprep(eps,'%%Title:[^\n]*\n','%%Title:\n','once');
% Fix pages and bounding box
for s = {'Pages','BoundingBox'}
  [b,e] = regexp(eps,['%%' s{1} ':[^%]*%%']);
  if numel(b) == 2
    eps = eps([1:b(1)-1 b(2):e(2)-2 e(1)-1:b(2)-1 e(2)-1:end]);
  end
end
eps = regexprep(eps,'%%BoundingBox:[^\n]*\n',[...
  '%%BoundingBox:' sprintf(' %.0f',boundingBox*72/2.54) '\n'...
  '%%HiResBoundingBox:' sprintf(' %.2f',boundingBox*72/2.54) '\n'],'once');
% Fix line width
eps = strrep(eps,sprintf('\n10.0 ML\n'),sprintf('\n1 LJ\n'));
eps = strrep(eps,sprintf('\n2 setlinecap\n1 LJ\nN'),sprintf('\n2 setlinecap\n1 LJ\n0.667 LW\nN'));
% Write EPS file
h = fopen(file,'w');
fwrite(h,eps);
fclose(h);
end

function [f,builtin] = find_gs()
builtin = false;
if ispc
  p = 'C:\Program Files\gs\';
  d = dir([p 'gs*.*\']);
  if isempty(d)
    p = 'C:\Program Files (x86)\gs\';
    d = dir([p 'gs*.*\']);
  end
  if ~isempty(d)
    for e = {'\bin\gswin64c.exe','\bin\gswin32c.exe'}
      path = [p d(end).name e{1}];
      if exist(path,'file')
        if gs(path,'-v','') == 0
          f = @(cmd,file) gs(path,cmd,file);
          return
        end
      end
    end
  end
else
  for p = {'/usr/bin/gs','/usr/local/bin/gs'}
    path = p{1};
    if exist(path,'file')
      if gs(path,'-v','') == 0
        f = @(cmd,file) gs(path,cmd,file);
        return
      end
    end
  end
end
if ~isempty(which('-all','gscript'))
  f = @gsbuiltin;
  builtin = true;
  return
end
if ismac
  url = 'http://pages.uoregon.edu/koch';
else
  url = 'http://www.ghostscript.com';
end
warning('exportfig:find_gs:gsNotFound',...
  'Ghostscript not found. Have you installed it? See <a href="%s">%s</a>.',url,url);
f = false;
end

function s = gs(path,cmd,file)
[s,~] = system(['"' path '" ' cmd ' "' file '"']);
end

function s = gsbuiltin(cmd,file)
persistent gs include
if isempty(gs)
  d = which('-all','gscript');
  d = cd(fileparts(d{1}));
  gs = @gscript;
  cd(d);
  d = fullfile(matlabroot,'sys','extern',computer('arch'),'ghostscript');
  include = sprintf('-I"%s" -I"%s"',fullfile(d,'fonts',''),fullfile(d,'ps_files',''));
end
rsp = [tempname() '.rsp'];
h = fopen(rsp,'w');
fprintf(h,'%s %s',cmd,include);
fclose(h);
s = gs(['@' rsp],file,0);
delete(rsp);
end
