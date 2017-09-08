%
%  svg2tpx.m
%
%  Created by Léa Strobino.
%  Copyright 2017 hepia. All rights reserved.
%

function svg2tpx(infile,outfile)
persistent TpX
if isempty(TpX)
  s = 0;
  if ismac
    wine = '/Applications/Wine Stable.app/Contents/Resources/wine/bin/wine';
    TpX = '/Applications/TpX.app/Contents/Resources/TpX.exe';
    if exist(wine,'file') && exist(TpX,'file')
      TpX = [wine '" "' TpX];
      s = 1;
    end
  else
    TpX = 'C:\Program Files\TpX\TpX.exe';
    s = exist(TpX,'file');
    if ~s
      TpX = 'C:\Program Files (x86)\TpX\TpX.exe';
      s = exist(TpX,'file');
    end
  end
  if ~s
    url = 'http://tpx.sourceforge.net';
    error('svg2tpx:TpXNotFound',...
      'TpX not found. Have you installed it? See <a href="%s">%s</a>.',url,url);
  end
end
[~,~] = system(['"' TpX '" "' infile '" -o "' outfile '" -m tikz']);
h = fopen(outfile,'r');
d = fread(h,'*char')';
fclose(h);
d = regexprep(d,'<comment>.*</comment>',['<comment>Created by MATLAB ' version() '</comment>'],'once');
h = fopen(outfile,'w');
fwrite(h,d);
fclose(h);
