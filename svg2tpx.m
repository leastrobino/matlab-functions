%
%  svg2tpx.m
%
%  Created by Léa Strobino.
%  Copyright 2017 hepia. All rights reserved.
%

function svg2tpx(infile,outfile)
persistent TpX
if isempty(TpX)
  TpX = 'C:\Program Files\TpX\TpX.exe';
  if ~exist(TpX,'file')
    TpX = 'C:\Program Files (x86)\TpX\TpX.exe';
    if ~exist(TpX,'file')
      url = 'http://tpx.sourceforge.net';
      error('svg2tpx:TpXNotFound',...
        'TpX not found. Have you installed it? See <a href="%s">%s</a>.',url,url);
    end
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
