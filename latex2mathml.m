%
%  latex2mathml.m
%
%  Created by Léa Strobino.
%  Copyright 2016 hepia. All rights reserved.
%

function mml = latex2mathml(s)
persistent MathToWeb
if isempty(MathToWeb)
  mlock();
  addToClassPath([fileparts(mfilename('fullpath')) filesep 'mathtoweb.jar']);
  MathToWeb = mathtoweb.engine.MathToWeb('conversion_utility');
end
o = MathToWeb.convertLatexToMathMLUtility(['$ ' s ' $'],'-line -rep -unicode');
if strcmp(o(1),'Success')
  if nargout
    mml = char(o(3));
  else
    o = java.awt.datatransfer.StringSelection(o(3));
    java.awt.Toolkit.getDefaultToolkit().getSystemClipboard().setContents(o,[]);
  end
else
  error('latex2mathml:mathtoweb','%s',deblank(strrep(char(o(2)),char([10 10]),char(10))));
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
end
