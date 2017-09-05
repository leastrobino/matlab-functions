%
%  gcc.m
%
%  Created by Léa Strobino.
%  Copyright 2017 hepia. All rights reserved.
%

function gcc(varargin)
persistent cmd
if isempty(cmd)
  if ispc
    cmd = ['"' getenv('MW_MINGW64_LOC') '\bin\gcc"'];
  else
    cmd = 'gcc';
  end
end
varargin = [repmat({' "'},1,nargin) ; varargin ; repmat({'"'},1,nargin)];
[s,o] = system([cmd varargin{:}]);
if s
  error('MATLAB:MinGW:gcc','%s',deblank(o));
else
  fprintf('%s',o);
end
