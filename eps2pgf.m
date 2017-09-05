%
%  eps2pgf.m
%
%  Created by Léa Strobino.
%  Copyright 2016 hepia. All rights reserved.
%

function eps2pgf(infile,outfile,fontSize)
persistent dir eps2pgf_version log
if isempty(dir)
  dir = [fileparts(mfilename('fullpath')) filesep 'eps2pgf'];
  mlock();
  addToClassPath([dir filesep 'eps2pgf.jar']);
  eps2pgf_version = char(net.sf.eps2pgf.Main.APP_VERSION);
  log = tempname();
  h = java.util.logging.FileHandler(log);
  h.setFormatter(java.util.logging.SimpleFormatter());
  l = java.util.logging.Logger.getLogger('net.sourceforge.eps2pgf');
  l.addHandler(h);
  l.setLevel(java.util.logging.Level.SEVERE);
  l = java.util.logging.Logger.getLogger('');
  h = l.getHandlers();
  if ~isempty(h) && isa(h(1),'java.util.logging.ConsoleHandler')
    l.removeHandler(h(1));
  end
end
d = java.lang.System.setProperty('user.dir',dir);
try
  o = net.sf.eps2pgf.Options();
  o.parse(['-m directcopy "' infile '" -o "' outfile '"']);
  c = net.sf.eps2pgf.Converter(o);
  c.convert();
  e = [];
  h = fopen(log,'r');
  while ~feof(h)
    fgets(h);
    s = fgets(h);
    e = [e s(find(s == ':',1)+2:end)]; %#ok<AGROW>
  end
  fclose(h);
  h = fopen(log,'w');
  fclose(h);
  if ~isempty(e)
    e(e == 13) = [];
    error('eps2pgf:Exception','%s',deblank(e));
  end
catch e
  java.lang.System.setProperty('user.dir',d);
  if exist(outfile,'file')
    w = warning('off','MATLAB:DELETE:Permission');
    delete(outfile);
    warning(w);
  end
  if strcmp(e.identifier,'MATLAB:Java:GenericException')
    e = MException(e.identifier,'%s',char(e.ExceptionObject));
    throw(e);
  else
    rethrow(e);
  end
end
java.lang.System.setProperty('user.dir',d);
h = fopen(outfile,'r');
fgets(h);
l = fgets(h);
pgf = fread(h,'*char')';
fclose(h);
h = fopen(outfile,'w');
fprintf(h,'%% Created by MATLAB %s, eps2pgf %s\n',version(),eps2pgf_version);
fwrite(h,l);
if nargin == 3
  fprintf(h,'\\fontsize{%.3fpt}{0pt}\\selectfont\n',fontSize);
end
fwrite(h,pgf);
fclose(h);
end

function addToClassPath(jar)
clm = com.mathworks.jmi.ClassLoaderManager.getClassLoaderManager();
classPath = clm.getClassPath();
if ~isempty(classPath)
  classPath = cell(classPath)';
end
clm.setClassPath([classPath,jar]);
com.mathworks.jmi.OpaqueJavaInterface.enableClassReloading(1);
clear('java');
end
