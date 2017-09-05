%DEPENDS Computes dependencies for a given function, f.
%
%   c = depends(f[,'mfile'])
%
%   Inputs:
%   f        string, name of function or path to function
%   'mfile'  list .m files instead of .p files
%
%   Outputs:
%   c        cell array of paths to dependencies
%
%   Example:
%
%   % Get dependencies and zip into a file
%   c = depends('myfun');
%   zip('myfun.zip',c);
%
%   % Get dependencies and extract just file base names and print
%   c = depends('myfun');
%   n = regexprep(c,['^.*\' filesep],'')
%   fprintf('myfun depends on:\n');
%   fprintf(' %s\n',n{:})
%
%   See also matlab.codetools.requiredFilesAndProducts.

%  Created by Léa Strobino.
%  Copyright 2016 hepia. All rights reserved.

function c = depends(f,mfile)
e = {'.m','.p'};
if nargin == 2 && strcmpi(mfile,'mfile')
  e = e([2 1]);
end
c = matlab.codetools.requiredFilesAndProducts(f);
for i = 1:numel(c)
  if strcmp(c{i}(end-1:end),e{1}) && exist([c{i}(1:end-2) e{2}],'file')
    c{i} = [c{i}(1:end-2) e{2}];
  end
end
c = sort(unique(c'));
