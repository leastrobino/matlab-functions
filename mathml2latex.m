%
%  mathml2latex.m
%
%  Created by Léa Strobino.
%  Copyright 2017 hepia. All rights reserved.
%

function s = mathml2latex(mml)
persistent s9api tmp
if isempty(s9api)
  dir = [fileparts(mfilename('fullpath')) '/mml2tex'];
  mlock();
  addToClassPath([dir '/saxon9he.jar']);
  s9api = net.sf.saxon.s9api.Processor(0).newXsltCompiler().compile(javax.xml.transform.stream.StreamSource([dir '/xsl/invoke-mml2tex.xsl'])).load();
  tmp = [tempname() '.xml'];
  h = java.io.File(tmp);
  h.deleteOnExit();
  d = net.sf.saxon.s9api.Serializer();
  d.setOutputFile(h);
  s9api.setDestination(d);
end
h = fopen(tmp,'w');
fwrite(h,unicode2native(mml,'UTF-8'));
fclose(h);
try
  s9api.setSource(javax.xml.transform.stream.StreamSource(tmp));
  s9api.transform();
catch
  error('mathml2latex:s9api:mml2tex','Error during call to mml2tex.');
end
h = fopen(tmp,'r');
o = fread(h,'*char')';
fclose(h);
m = regexp(o,'<\?mml2tex (.*)\?>','tokens','once');
if isempty(m)
  error('mathml2latex:mml2tex','Error during call to mml2tex.');
else
  if nargout
    s = m{1};
  else
    m = java.awt.datatransfer.StringSelection(m{1});
    java.awt.Toolkit.getDefaultToolkit().getSystemClipboard().setContents(m,[]);
  end
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
